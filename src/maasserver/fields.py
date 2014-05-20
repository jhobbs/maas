# Copyright 2012-2014 Canonical Ltd.  This software is licensed under the
# GNU Affero General Public License version 3 (see the file LICENSE).

"""Custom model fields."""

from __future__ import (
    absolute_import,
    print_function,
    unicode_literals,
    )

str = None

__metaclass__ = type
__all__ = [
    "EditableBinaryField",
    "MAC",
    "MACAddressField",
    "MACAddressFormField",
    "register_mac_type",
    "VerboseRegexValidator",
    ]

from copy import deepcopy
from json import (
    dumps,
    loads,
    )
import re

from django.core.exceptions import ValidationError
from django.core.validators import RegexValidator
from django.db.models import (
    BinaryField,
    Field,
    SubfieldBase,
    )
from django.forms import (
    CharField,
    ModelChoiceField,
    )
from django.utils.encoding import force_text
from maasserver.utils.orm import get_one
import psycopg2.extensions
from south.modelsinspector import add_introspection_rules


MAC_RE = re.compile(r'^\s*([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}\s*$')


MAC_ERROR_MSG = "'%(value)s' is not a valid MAC address."


class VerboseRegexValidator(RegexValidator):
    """A verbose `RegexValidator`.

    This `RegexValidator` includes the checked value in the rendered error
    message when the validation fails.
    """
    # Set a bugus code to circumvent Django's attempt to re-interpret a
    # validator's error message using the field's message it is attached
    # to.
    code = 'bogus-code'

    def __call__(self, value):
        """Validates that the input matches the regular expression."""
        if not self.regex.search(force_text(value)):
            raise ValidationError(
                self.message % {'value': value}, code=self.code)


mac_validator = VerboseRegexValidator(regex=MAC_RE, message=MAC_ERROR_MSG)


def validate_mac(value):
    """Django validator for a MAC."""
    if isinstance(value, MAC):
        value = value.get_raw()
    mac_validator(value)


# The MACAddressField, JSONObjectField and XMLField don't introduce any new
# parameters compared to their parent's constructors so South will handle
# them just fine.
# See http://south.aeracode.org/docs/customfields.html#extending-introspection
# for details.
add_introspection_rules(
    [], [
        "^maasserver\.fields\.MACAddressField",
        "^maasserver\.fields\.JSONObjectField",
        "^maasserver\.fields\.XMLField",
        "^maasserver\.fields\.EditableBinaryField",
    ])


class NodeGroupFormField(ModelChoiceField):
    """Form field: reference to a :class:`NodeGroup`.

    Node groups are identified by their subnets.  More precisely: this
    field will accept any IP as an identifier for the nodegroup whose subnet
    contains the IP address.

    Unless `queryset` is explicitly given, this field covers all NodeGroup
    objects.
    """

    def __init__(self, **kwargs):
        # Avoid circular imports.
        from maasserver.models import NodeGroup

        kwargs.setdefault('queryset', NodeGroup.objects.all())
        super(NodeGroupFormField, self).__init__(**kwargs)

    def label_from_instance(self, nodegroup):
        """Django method: get human-readable choice label for nodegroup."""
        interfaces = sorted(
            interface.ip for interface in nodegroup.get_managed_interfaces())
        if len(interfaces) > 0:
            return "%s: %s" % (nodegroup.name, ', '.join(interfaces))
        else:
            return nodegroup.name

    def _get_nodegroup_from_string(self, value=None):
        """Identify a `NodeGroup` ID from a text value.

        :param value: A `unicode` that identifies a `NodeGroup` somehow: as a
            numerical ID in text form, as a UUID, as a cluster name, or as the
            empty string to denote the master nodegroup.  `None` also gets the
            master nodegroup.
        :return: Matching `NodeGroup`, or `None`.
        """
        # Avoid circular imports.
        from maasserver.models import NodeGroup

        if value is None or value == '':
            # No identification given.  Default to the master.
            return NodeGroup.objects.ensure_master()

        if value.isnumeric():
            # Try value as an ID.
            nodegroup = get_one(NodeGroup.objects.filter(id=int(value)))
            if nodegroup is not None:
                return nodegroup

        # Try value as a UUID.
        nodegroup = get_one(NodeGroup.objects.filter(uuid=value))
        if nodegroup is not None:
            return nodegroup

        # Try value as a cluster name.
        return get_one(NodeGroup.objects.filter(cluster_name=value))

    def clean(self, value):
        """Django method: provide expected output for various inputs.

        There seems to be no clear specification on what `value` can be.
        This method accepts the types that we see in practice:
         * :class:`NodeGroup`
         * the nodegroup's numerical id in text form
         * the nodegroup's uuid
         * the nodegroup's cluster_name

        If no nodegroup is indicated, it defaults to the master.
        """
        # Avoid circular imports.
        from maasserver.models import NodeGroup

        if isinstance(value, bytes):
            value = value.decode('utf-8')

        if value is None or isinstance(value, unicode):
            nodegroup = self._get_nodegroup_from_string(value)
        elif isinstance(value, NodeGroup):
            nodegroup = value
        else:
            nodegroup = None

        if nodegroup is None:
            raise ValidationError("Invalid nodegroup: %s." % value)

        return nodegroup


class VerboseRegexField(CharField):

    def __init__(self, regex, message, *args, **kwargs):
        """A field that validates its value with a regular expression.

        :param regex: Either a string or a compiled regular expression object.
        :param message: Error message to use when the validation fails.
        """
        super(VerboseRegexField, self).__init__(*args, **kwargs)
        self.validators.append(
            VerboseRegexValidator(regex=regex, message=message))


class MACAddressFormField(VerboseRegexField):
    """Form field type: MAC address."""

    def __init__(self, *args, **kwargs):
        super(MACAddressFormField, self).__init__(
            regex=MAC_RE, message=MAC_ERROR_MSG, *args, **kwargs)


class MACAddressField(Field):
    """Model field type: MAC address."""

    __metaclass__ = SubfieldBase

    description = "MAC address"

    default_validators = [validate_mac]

    def db_type(self, *args, **kwargs):
        return "macaddr"


class MAC:
    """A MAC address represented as a database value.

    PostgreSQL supports MAC addresses as a native type.  They show up
    client-side as this class.  It is essentially a wrapper for either a
    string, or None.
    """

    def __init__(self, value):
        """Wrap a MAC address, or None, into a `MAC`.

        :param value: A MAC address, in the form of a string or a `MAC`;
            or None.
        """
        if isinstance(value, MAC):
            # Avoid double-wrapping.  It's the value that matters, not the
            # MAC object that wraps it.
            value = value.get_raw()
        elif isinstance(value, bytes):
            value = value.decode("ascii")
        else:
            # TODO bug=1215447: Remove this assertion.
            assert value is None or isinstance(value, unicode)
        # The wrapped attribute is stored as self._wrapped, following
        # ISQLQuote's example.
        self._wrapped = value

    def __conform__(self, protocol):
        """Tell psycopg2 that this type implements the adapter protocol."""
        # The psychopg2 docs say to check that the protocol is ISQLQuote,
        # but not what to do if it isn't.
        assert protocol == psycopg2.extensions.ISQLQuote, (
            "Unsupported psycopg2 adapter protocol: %s" % protocol)
        return self

    def getquoted(self):
        """Render this object in SQL.

        This is part of psycopg2's adapter protocol.
        """
        value = self.get_raw()
        if value is None:
            return 'NULL'
        else:
            return "'%s'::macaddr" % value

    def get_raw(self):
        """Return the wrapped value."""
        return self._wrapped

    @staticmethod
    def parse(value, cur):
        """Turn a value as received from the database into a MAC."""
        return MAC(value)

    def __repr__(self):
        """Represent the MAC as a string.
        """
        return self.get_raw()

    def __eq__(self, other):
        # Two MACs are equal if they wrap the same value.
        #
        # Also, a MAC is equal to the value it wraps.  This is non-commutative,
        # but it supports Django code that compares input values to various
        # kinds of "null" or "empty."
        if isinstance(other, MAC):
            other = other.get_raw()
        return self.get_raw() == other

    def __ne__(self, other):
        return not (self == other)

    def __hash__(self):
        return self.get_raw().__hash__()


def register_mac_type(cursor):
    """Register our `MAC` type with psycopg2 and Django."""

    # This is standard, but not built-in, magic to register a type in
    # psycopg2: execute a query that returns a field of the corresponding
    # database type, then get its oid out of the cursor, use that to create
    # a "typecaster" in psycopg (by calling new_type(), confusingly!), then
    # register that type in psycopg.
    cursor.execute("SELECT NULL::macaddr")
    oid = cursor.description[0][1]
    mac_caster = psycopg2.extensions.new_type((oid, ), b"macaddr", MAC.parse)
    psycopg2.extensions.register_type(mac_caster)

    # Now do the same for the type array-of-MACs.  The "typecaster" created
    # for MAC is passed in; it gets used for parsing an individual element
    # of an array's text representation as received from the database.
    cursor.execute("SELECT '{}'::macaddr[]")
    oid = cursor.description[0][1]
    psycopg2.extensions.register_type(psycopg2.extensions.new_array_type(
        (oid, ), b"macaddr", mac_caster))


class JSONObjectField(Field):
    """A field that will store any jsonizable python object."""

    __metaclass__ = SubfieldBase

    def to_python(self, value):
        """db -> python: json load."""
        assert not isinstance(value, bytes)
        if value is not None:
            if isinstance(value, unicode):
                try:
                    return loads(value)
                except ValueError:
                    pass
            return value
        else:
            return None

    def get_db_prep_value(self, value, connection=None, prepared=False):
        """python -> db: json dump."""
        if value is not None:
            return dumps(deepcopy(value))
        else:
            return None

    def get_internal_type(self):
        return 'TextField'

    def get_prep_lookup(self, lookup_type, value):
        if lookup_type not in ['exact', 'isnull']:
            raise TypeError("Lookup type %s is not supported." % lookup_type)
        return super(JSONObjectField, self).get_prep_lookup(
            lookup_type, value)


class XMLField(Field):
    """A field for storing xml natively.

    This is not like the removed Django XMLField which just added basic python
    level checking on top of a text column.

    Really inserts should be wrapped like `XMLPARSE(DOCUMENT value)` but it's
    hard to do from django so rely on postgres supporting casting from char.
    """

    description = "XML document or fragment"

    def db_type(self, connection):
        return "xml"

    def get_db_prep_lookup(self, lookup_type, value, **kwargs):
        """Limit lookup types to those that work on xml.

        Unlike character fields the xml type is non-comparible, see:
        <http://www.postgresql.org/docs/devel/static/datatype-xml.html>
        """
        if lookup_type != 'isnull':
            raise TypeError("Lookup type %s is not supported." % lookup_type)
        return super(XMLField, self).get_db_prep_lookup(
            lookup_type, value, **kwargs)


class EditableBinaryField(BinaryField):
    """An editable binary field.

    An editable version of Django's BinaryField.
    """

    def __init__(self, *args, **kwargs):
        super(EditableBinaryField, self).__init__(*args, **kwargs)
        self.editable = True
