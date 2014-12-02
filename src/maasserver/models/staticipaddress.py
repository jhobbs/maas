# Copyright 2014 Canonical Ltd.  This software is licensed under the
# GNU Affero General Public License version 3 (see the file LICENSE).

"""Model definition for StaticIPAddress.

Contains all the in-use static IP addresses that are allocated by MAAS.
Generally speaking, these are written out to the DHCP server as "host"
blocks which will tie MACs into a specific IP.  The IPs are separate
from the dynamic range that the DHCP server itself allocates to unknown
clients.
"""

from __future__ import (
    absolute_import,
    print_function,
    unicode_literals,
    )

str = None

__metaclass__ = type
__all__ = [
    'StaticIPAddress',
    ]

from collections import defaultdict

from django.contrib.auth.models import User
from django.db import (
    connection,
    IntegrityError,
    )
from django.db.models import (
    ForeignKey,
    IntegerField,
    Manager,
    )
from maasserver import (
    DefaultMeta,
    locks,
    )
from maasserver.enum import IPADDRESS_TYPE
from maasserver.exceptions import (
    StaticIPAddressExhaustion,
    StaticIPAddressOutOfRange,
    StaticIPAddressUnavailable,
    )
from maasserver.fields import MAASIPAddressField
from maasserver.models.cleansave import CleanSave
from maasserver.models.timestampedmodel import TimestampedModel
from maasserver.utils import strip_domain
from netaddr import (
    IPAddress,
    IPRange,
    )
from provisioningserver.utils.enum import map_enum_reverse


class StaticIPAddressManager(Manager):
    """A utility to manage collections of IPAddresses."""

    def _verify_alloc_type(self, alloc_type, user=None):
        """Check validity of an `alloc_type` parameter when allocating.

        Also checks consistency with the `user` parameter.  If `user` is not
        `None`, then the allocation has to be `USER_RESERVED`, and vice versa.
        """
        possible_alloc_types = map_enum_reverse(IPADDRESS_TYPE)
        if alloc_type not in possible_alloc_types:
            raise ValueError(
                "IP address type %r is not a member of "
                "IPADDRESS_TYPE." % alloc_type)

        if user is None:
            if alloc_type == IPADDRESS_TYPE.USER_RESERVED:
                raise AssertionError(
                    "Must provide user for USER_RESERVED alloc_type.")
        else:
            if alloc_type != IPADDRESS_TYPE.USER_RESERVED:
                raise AssertionError(
                    "Must not provide user for alloc_type other "
                    "than USER_RESERVED.")

    def _attempt_allocation(self, requested_address, alloc_type, user=None):
        """Attempt to allocate `requested_address`.

        All parameters must have been checked first.  This method relies on
        `IntegrityError` to detect addresses that are already in use, so
        nothing else must cause that error.

        Transaction model and isolation level have changed over time, and may
        do so again, so relying on database-level uniqueness validation is the
        most robust way we have of checking for clashes.

        :param requested_address: An `IPAddress` for the address that should
            be allocated.
        :param alloc_type: Allocation type.
        :param user: Optional user.
        :return: `StaticIPAddress` if successful.
        :raise StaticIPAddressUnavailable: if the address was already taken.
        """
        ipaddress = StaticIPAddress(
            ip=requested_address.format(), alloc_type=alloc_type)
        try:
            # Try to save this address to the database.
            ipaddress.save()
        except IntegrityError:
            # The address is already taken.
            raise StaticIPAddressUnavailable(
                "The IP address %s is already in use." %
                requested_address.format())
        else:
            # We deliberately do *not* save the user until now because it
            # might result in an IntegrityError, and we rely on the latter
            # in the code above to indicate an already allocated IP
            # address and nothing else.
            ipaddress.user = user
            ipaddress.save()
            return ipaddress

    def allocate_new(self, range_low, range_high,
                     alloc_type=IPADDRESS_TYPE.AUTO, user=None,
                     requested_address=None):
        """Return a new StaticIPAddress.

        :param range_low: The lowest address to allocate in a range
        :param range_high: The highest address to allocate in a range
        :param alloc_type: What sort of IP address to allocate in the
            range of choice in IPADDRESS_TYPE.
        :param user: If providing a user, the alloc_type must be
            IPADDRESS_TYPE.USER_RESERVED. Conversely, if the alloc_type is
            IPADDRESS_TYPE.USER_RESERVED the user must also be provided.
            AssertionError is raised if these conditions are not met.
        :param requested_address: Optional IP address that the caller wishes
            to use instead of being allocated one at random.

        All IP parameters can be strings or netaddr.IPAddress.

        Note that this method has been designed to work even when the database
        is running with READ COMMITTED isolation. Try to keep it that way.
        """
        # This check for `alloc_type` is important for later on. We rely on
        # detecting IntegrityError as a sign than an IP address is already
        # taken, and so we must first eliminate all other possible causes.
        self._verify_alloc_type(alloc_type, user)

        range_low = IPAddress(range_low)
        range_high = IPAddress(range_high)
        static_range = IPRange(range_low, range_high)

        if requested_address is None:
            return self._find_free_ip(
                range_low, range_high, static_range, alloc_type, user)
        else:
            requested_address = IPAddress(requested_address)
            if requested_address not in static_range:
                raise StaticIPAddressOutOfRange(
                    "%s is not inside the range %s to %s" % (
                        requested_address.format(), range_low.format(),
                        range_high.format()))
            return self._attempt_allocation(
                requested_address, alloc_type, user)

    def _find_free_ip(self, range_low, range_high, static_range, alloc_type,
                      user):
        """Helper function that finds a free IP address using a lock."""
        with locks.staticip_acquire:
            # The set of _allocated_ addresses in the range is going to be
            # smaller or at least no bigger than the set of addresses in the
            # whole range, so we materialise a Python set of only allocated
            # addreses. We can iterate through `static_range` without
            # materialising every address within. This is critical for IPv6,
            # where ranges may contain 2^64 addresses without blinking.
            existing = self.filter(
                ip__gte=range_low.format(),
                ip__lte=range_high.format(),
            )
            # We might consider limiting this query, but that's premature. If
            # MAAS is managing even as many as 10k nodes in a single network
            # then my hat is most certainly on the menu. However, we do care
            # only about the IP address field here.
            existing = existing.values_list("ip", flat=True)
            # Now materialise the set.
            existing = {IPAddress(ip) for ip in existing}
            # Now find the first free address in the range.
            for requested_address in static_range:
                if requested_address not in existing:
                    try:
                        return self._attempt_allocation(
                            requested_address, alloc_type, user)
                    except StaticIPAddressUnavailable:
                        # That address has been taken since we obtained the
                        # list of existing addresses from the database. This
                        # is a race!  It also ought to be impossible as
                        # this critical section is in a lock...
                        continue
            else:
                raise StaticIPAddressExhaustion(
                    "No more IPs available in range %s-%s" % (
                        range_low.format(), range_high.format()))

    def _deallocate(self, filter):
        """Helper func to deallocate the records in the supplied queryset
        filter and return a list of IPs deleted."""
        deallocated_ips = {record.ip.format() for record in filter}
        filter.delete()
        return deallocated_ips

    def deallocate_by_node(self, node):
        """Given a node, deallocate all of its AUTO StaticIPAddresses."""
        qs = self.filter(
            alloc_type=IPADDRESS_TYPE.AUTO).filter(
            macaddress__node=node)
        return self._deallocate(qs)

    def delete_by_node(self, node):
        """Given a node, delete ALL of its StaticIPAddresses.

        Unlike `deallocate_by_node`, which only removes AUTO IPs,
        this will delete every single IP associated with the node.
        """
        qs = self.filter(macaddress__node=node)
        return self._deallocate(qs)

    def get_hostname_ip_mapping(self, nodegroup):
        """Return hostname mappings for `StaticIPAddress` entries.

        Returns a mapping `{hostnames -> [ips]}` corresponding to current
        `StaticIPAddress` objects for the nodes in `nodegroup`.

        At most one IPv4 address and one IPv6 address will be returned per
        node, each the one for whichever `MACAddress` was created first.

        Any domain will be stripped from the hostnames.
        """
        cursor = connection.cursor()

        # DISTINCT ON returns the first matching row for any given
        # hostname, using the query's ordering.  Here, we're trying to
        # return the IP for the oldest MAC address.
        #
        # For nodes that have disable_ipv4 set, leave out any IPv4 address.
        cursor.execute("""
            SELECT DISTINCT ON (node.hostname, family(staticip.ip))
                node.hostname, staticip.ip
            FROM maasserver_macaddress AS mac
            JOIN maasserver_node AS node ON
                node.id = mac.node_id
            JOIN maasserver_macstaticipaddresslink AS link ON
                link.mac_address_id = mac.id
            JOIN maasserver_staticipaddress AS staticip ON
                staticip.id = link.ip_address_id
            WHERE
                node.nodegroup_id = %s AND
                (
                    node.disable_ipv4 IS FALSE OR
                    family(staticip.ip) <> 4
                )
            ORDER BY node.hostname, family(staticip.ip), mac.id
            """, (nodegroup.id,))
        mapping = defaultdict(list)
        for hostname, ip in cursor.fetchall():
            hostname = strip_domain(hostname)
            mapping[hostname].append(ip)
        return mapping


class StaticIPAddress(CleanSave, TimestampedModel):

    class Meta(DefaultMeta):
        verbose_name = "Static IP Address"
        verbose_name_plural = "Static IP Addresses"

    ip = MAASIPAddressField(
        unique=True, null=False, editable=False, blank=False,
        verbose_name='IP')

    # The MACStaticIPAddressLink table is used to link StaticIPAddress to
    # MACAddress.  See MACAddress.ip_addresses, and the reverse relation
    # self.macaddress_set (which will only ever contain one MAC due to
    # the unique FK restriction on the link table).

    alloc_type = IntegerField(
        editable=False, null=False, blank=False, default=IPADDRESS_TYPE.AUTO)

    user = ForeignKey(
        User, default=None, blank=True, null=True, editable=False)

    objects = StaticIPAddressManager()

    def __unicode__(self):
        # Attempt to show the symbolic alloc_type name if possible.
        type_names = map_enum_reverse(IPADDRESS_TYPE)
        strtype = type_names.get(self.alloc_type, '%s' % self.alloc_type)
        return "<StaticIPAddress: <%s:type=%s>>" % (self.ip, strtype)

    def deallocate(self):
        """Mark this IP address as no longer in use.

        After return, this object is no longer valid.
        """
        self.delete()

    def full_clean(self, exclude=None, validate_unique=False):
        """Overrides Django's default for validating unique columns.

        Django's ORM has a misfeature: `Model.full_clean` -- which our
        CleanSave mix-in calls -- checks every unique key against the database
        before actually saving the row. Django runs READ COMMITTED by default,
        which means there's a racey period between the uniqueness validation
        check and the actual insert.

        Here we disable this misfeature so that we will get `IntegrityError`
        alone from trying to insert a duplicate key. We also save a query or
        two. We could consider disabling this misfeature globally.
        """
        return super(StaticIPAddress, self).full_clean(
            exclude=exclude, validate_unique=validate_unique)
