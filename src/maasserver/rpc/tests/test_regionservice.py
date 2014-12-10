# Copyright 2014 Canonical Ltd.  This software is licensed under the
# GNU Affero General Public License version 3 (see the file LICENSE).

"""Tests for the region's RPC implementation."""

from __future__ import (
    absolute_import,
    print_function,
    unicode_literals,
    )

str = None

__metaclass__ = type
__all__ = []

from collections import defaultdict
from contextlib import closing
from hashlib import sha256
from hmac import HMAC
from itertools import product
from operator import attrgetter
import os.path
import random
import threading
from urlparse import urlparse

from crochet import wait_for_reactor
from django.db import connection
from django.db.utils import ProgrammingError
from maasserver import (
    dhcp,
    eventloop,
    locks,
    monitor_connect,
    )
from maasserver.bootresources import get_simplestream_endpoint
from maasserver.enum import (
    NODE_STATUS,
    NODEGROUP_STATUS_CHOICES,
    POWER_STATE,
    )
from maasserver.models import (
    Config,
    DHCPLease,
    Event,
    EventType,
    MACAddress,
    Node,
    )
from maasserver.models.nodegroup import NodeGroup
from maasserver.rpc import (
    events as events_module,
    regionservice,
    )
from maasserver.rpc.regionservice import (
    Region,
    RegionAdvertisingService,
    RegionServer,
    RegionService,
    )
from maasserver.rpc.testing.doubles import HandshakingRegionServer
from maasserver.rpc.testing.fixtures import MockLiveRegionToClusterRPCFixture
from maasserver.security import get_shared_secret
from maasserver.testing.architecture import make_usable_architecture
from maasserver.testing.eventloop import (
    RegionEventLoopFixture,
    RunningEventLoopFixture,
    )
from maasserver.testing.factory import factory
from maasserver.testing.orm import reload_object
from maasserver.testing.testcase import MAASServerTestCase
from maasserver.utils.async import transactional
from maastesting.djangotestcase import TransactionTestCase
from maastesting.matchers import (
    MockCalledOnceWith,
    MockCallsMatch,
    MockNotCalled,
    Provides,
    )
from maastesting.testcase import MAASTestCase
from mock import (
    ANY,
    call,
    Mock,
    )
import netaddr
from provisioningserver.network import discover_networks
from provisioningserver.rpc import (
    cluster,
    common,
    exceptions,
    )
from provisioningserver.rpc.exceptions import (
    CannotRegisterCluster,
    NoSuchCluster,
    NoSuchEventType,
    NoSuchNode,
    )
from provisioningserver.rpc.interfaces import IConnection
from provisioningserver.rpc.region import (
    Authenticate,
    CreateNode,
    GetArchiveMirrors,
    GetBootSources,
    GetBootSourcesV2,
    GetClusterInterfaces,
    GetClusterStatus,
    GetProxies,
    Identify,
    ListNodePowerParameters,
    MarkNodeFailed,
    MonitorExpired,
    Register,
    RegisterEventType,
    ReportBootImages,
    ReportForeignDHCPServer,
    RequestNodeInfoByMACAddress,
    SendEvent,
    SendEventMACAddress,
    UpdateLeases,
    UpdateNodePowerState,
    )
from provisioningserver.rpc.testing import (
    always_fail_with,
    always_succeed_with,
    are_valid_tls_parameters,
    call_responder,
    TwistedLoggerFixture,
    )
from provisioningserver.rpc.testing.doubles import DummyConnection
from provisioningserver.testing.config import set_tftp_root
from provisioningserver.utils.twisted import asynchronous
from simplejson import dumps
from testtools.deferredruntest import (
    assert_fails_with,
    extract_result,
    )
from testtools.matchers import (
    AfterPreprocessing,
    AllMatch,
    Equals,
    HasLength,
    Is,
    IsInstance,
    MatchesListwise,
    MatchesStructure,
    )
from twisted.application.service import Service
from twisted.internet import (
    reactor,
    tcp,
    )
from twisted.internet.defer import (
    CancelledError,
    Deferred,
    DeferredList,
    fail,
    inlineCallbacks,
    succeed,
    )
from twisted.internet.error import ConnectionClosed
from twisted.internet.interfaces import IStreamServerEndpoint
from twisted.internet.protocol import Factory
from twisted.internet.threads import deferToThread
from twisted.protocols import amp
from twisted.python import log
from twisted.python.failure import Failure
from zope.interface.verify import verifyObject


@transactional
def transactional_reload_object(obj):
    return reload_object(obj)


class TestRegionProtocol_Identify(MAASTestCase):

    def test_identify_is_registered(self):
        protocol = Region()
        responder = protocol.locateResponder(Identify.commandName)
        self.assertIsNotNone(responder)

    @wait_for_reactor
    def test_identify_reports_event_loop_name(self):
        d = call_responder(Region(), Identify, {})

        def check(response):
            self.assertEqual({"ident": eventloop.loop.name}, response)

        return d.addCallback(check)


class TestRegionProtocol_Authenticate(MAASServerTestCase):

    def test_authenticate_is_registered(self):
        protocol = Region()
        responder = protocol.locateResponder(Authenticate.commandName)
        self.assertIsNotNone(responder)

    @wait_for_reactor
    @inlineCallbacks
    def test_authenticate_calculates_digest_with_salt(self):
        message = factory.make_bytes()
        secret = yield get_shared_secret()

        args = {b"message": message}
        response = yield call_responder(Region(), Authenticate, args)
        digest = response["digest"]
        salt = response["salt"]

        expected_digest = HMAC(secret, message + salt, sha256).digest()
        self.assertEqual(expected_digest, digest)
        self.assertThat(salt, HasLength(16))


class TestRegionProtocol_Register(TransactionTestCase):

    def test__is_registered(self):
        protocol = Region()
        responder = protocol.locateResponder(Register.commandName)
        self.assertIsNotNone(responder)

    @transactional
    def get_nodegroup(self, uuid):
        return NodeGroup.objects.get_by_natural_key(uuid)

    @wait_for_reactor
    @inlineCallbacks
    def test__registers_cluster_with_only_uuid(self):
        uuid = factory.make_UUID()
        args = {"uuid": uuid}
        response = yield call_responder(Region(), Register, args)
        self.assertEqual({}, response)
        nodegroup = yield deferToThread(self.get_nodegroup, uuid)
        self.assertEqual(uuid, nodegroup.uuid)

    @transactional
    def get_cluster_networks(self, cluster):
        return [
            {"interface": ngi.interface, "ip": ngi.ip,
             "subnet_mask": ngi.subnet_mask}
            for ngi in cluster.nodegroupinterface_set.all()
        ]

    @wait_for_reactor
    @inlineCallbacks
    def test__registers_cluster_with_uuid_and_networks(self):
        uuid = factory.make_UUID()
        networks = discover_networks()
        args = {"uuid": uuid, "networks": networks}
        response = yield call_responder(Region(), Register, args)
        self.assertEqual({}, response)
        nodegroup = yield deferToThread(self.get_nodegroup, uuid)
        self.assertEqual(uuid, nodegroup.uuid)
        networks_observed = yield deferToThread(
            self.get_cluster_networks, nodegroup)
        self.assertItemsEqual(networks, networks_observed)

    @wait_for_reactor
    @inlineCallbacks
    def test__raises_CannotRegisterCluster_when_it_cant(self):
        args = {
            "uuid": factory.make_UUID(),
            "networks": [
                # The IP address is invalid, so the region will reject
                # this registration.
                {"interface": "eth0", "ip": "1.2.3",
                 "subnet_mask": "255.255.255.255"},
            ],
        }
        error = yield assert_fails_with(
            call_responder(Region(), Register, args),
            CannotRegisterCluster)
        self.assertDocTestMatches(
            """\
            The cluster ... could not be registered:
            * interfaces: ...
            """,
            unicode(error))


class TestRegionProtocol_StartTLS(MAASTestCase):

    def test_StartTLS_is_registered(self):
        protocol = Region()
        responder = protocol.locateResponder(amp.StartTLS.commandName)
        self.assertIsNotNone(responder)

    def test_get_tls_parameters_returns_parameters(self):
        # get_tls_parameters() is the underlying responder function.
        # However, locateResponder() returns a closure, so we have to
        # side-step it.
        protocol = Region()
        cls, func = protocol._commandDispatch[amp.StartTLS.commandName]
        self.assertThat(func(protocol), are_valid_tls_parameters)

    @wait_for_reactor
    def test_StartTLS_returns_nothing(self):
        # The StartTLS command does some funky things - see _TLSBox and
        # _LocalArgument for an idea - so the parameters returned from
        # get_tls_parameters() - the registered responder - don't end up
        # travelling over the wire as part of an AMP message. However,
        # the responder is not aware of this, and is called just like
        # any other.
        d = call_responder(Region(), amp.StartTLS, {})

        def check(response):
            self.assertEqual({}, response)

        return d.addCallback(check)


class TestRegionProtocol_ReportBootImages(MAASTestCase):

    def test_report_boot_images_is_registered(self):
        protocol = Region()
        responder = protocol.locateResponder(ReportBootImages.commandName)
        self.assertIsNotNone(responder)

    @wait_for_reactor
    def test_report_boot_images_can_be_called(self):
        uuid = factory.make_name("uuid")
        images = [
            {"architecture": factory.make_name("architecture"),
             "subarchitecture": factory.make_name("subarchitecture"),
             "release": factory.make_name("release"),
             "purpose": factory.make_name("purpose")},
        ]

        d = call_responder(Region(), ReportBootImages, {
            b"uuid": uuid, b"images": images,
        })

        def check(response):
            self.assertEqual({}, response)

        return d.addCallback(check)

    @wait_for_reactor
    def test_report_boot_images_with_real_things_to_report(self):
        # tftppath.report_boot_images()'s return value matches the
        # arguments schema that ReportBootImages declares, and is
        # serialised correctly.

        # Example boot image definitions.
        archs = "i386", "amd64"
        subarchs = "generic", "special"
        releases = "precise", "trusty"
        purposes = "commission", "install"

        # Create a TFTP file tree with a variety of subdirectories.
        tftpdir = self.make_dir()
        for options in product(archs, subarchs, releases, purposes):
            os.makedirs(os.path.join(tftpdir, *options))

        # Ensure that report_boot_images() uses the above TFTP file tree.
        self.useFixture(set_tftp_root(tftpdir))

        images = [
            {"architecture": arch, "subarchitecture": subarch,
             "release": release, "purpose": purpose}
            for arch, subarch, release, purpose in product(
                archs, subarchs, releases, purposes)
        ]

        d = call_responder(Region(), ReportBootImages, {
            b"uuid": factory.make_name("uuid"), b"images": images,
        })

        def check(response):
            self.assertEqual({}, response)

        return d.addCallback(check)


class TestRegionProtocol_UpdateLeases(TransactionTestCase):

    def test_update_leases_is_registered(self):
        protocol = Region()
        responder = protocol.locateResponder(UpdateLeases.commandName)
        self.assertIsNotNone(responder)

    @transactional
    def make_node_group(self, uuid):
        return factory.make_NodeGroup(uuid=uuid)

    @transactional
    def make_node_group_interface(self, nodegroup):
        return factory.make_NodeGroupInterface(nodegroup=nodegroup)

    @transactional
    def make_mac_address(self):
        return factory.make_MACAddress_with_Node()

    @transactional
    def get_leases_for(self, nodegroup):
        return [
            (ng.ip, ng.mac)
            for ng in DHCPLease.objects.filter(nodegroup=nodegroup)]

    @wait_for_reactor
    @inlineCallbacks
    def test__stores_leases(self):
        uuid = factory.make_name("uuid")
        nodegroup = yield deferToThread(self.make_node_group, uuid)
        mapping = {
            "ip": factory.make_ipv4_address(),
            "mac": factory.make_mac_address()
        }

        response = yield call_responder(Region(), UpdateLeases, {
            b"uuid": uuid, b"mappings": [mapping]})

        self.assertThat(response, Equals({}))

        [(ip, mac)] = yield deferToThread(
            self.get_leases_for, nodegroup=nodegroup)
        self.expectThat(ip, Equals(mapping["ip"]))
        self.expectThat(mac, Equals(mapping["mac"]))

    @wait_for_reactor
    def test__raises_NoSuchCluster_if_cluster_not_found(self):
        uuid = factory.make_name("uuid")
        d = call_responder(
            Region(), UpdateLeases, {b"uuid": uuid, b"mappings": []})
        return assert_fails_with(d, NoSuchCluster)


class TestRegionProtocol_GetBootSources(TransactionTestCase):

    def test_get_boot_sources_is_registered(self):
        protocol = Region()
        responder = protocol.locateResponder(GetBootSources.commandName)
        self.assertIsNotNone(responder)

    @wait_for_reactor
    def test_get_boot_sources_returns_simplestreams_endpoint(self):
        uuid = factory.make_name("uuid")

        d = call_responder(Region(), GetBootSources, {b"uuid": uuid})

        def check(response):
            self.assertEqual(
                {b"sources": [get_simplestream_endpoint()]},
                response)

        return d.addCallback(check)


class TestRegionProtocol_GetBootSourcesV2(TransactionTestCase):

    def test_get_boot_sources_v2_is_registered(self):
        protocol = Region()
        responder = protocol.locateResponder(GetBootSourcesV2.commandName)
        self.assertIsNotNone(responder)

    @wait_for_reactor
    def test_get_boot_sources_v2_returns_simplestreams_endpoint(self):
        uuid = factory.make_name("uuid")

        d = call_responder(Region(), GetBootSourcesV2, {b"uuid": uuid})

        def check(response):
            self.assertEqual(
                {b"sources": [get_simplestream_endpoint()]},
                response)

        return d.addCallback(check)


class TestRegionProtocol_GetArchiveMirrors(TransactionTestCase):

    def test_get_archive_mirrors_is_registered(self):
        protocol = Region()
        responder = protocol.locateResponder(GetArchiveMirrors.commandName)
        self.assertIsNotNone(responder)

    @transactional
    def set_main_archive(self, url):
        Config.objects.set_config("main_archive", url)

    @transactional
    def set_ports_archive(self, url):
        Config.objects.set_config("ports_archive", url)

    @wait_for_reactor
    @inlineCallbacks
    def test_get_archive_mirrors_with_main_archive_port_archive_default(self):
        yield deferToThread(self.set_main_archive,
                            "http://archive.ubuntu.com/ubuntu")
        yield deferToThread(self.set_ports_archive,
                            "http://ports.ubuntu.com/ubuntu-ports")

        response = yield call_responder(Region(), GetArchiveMirrors, {})

        self.assertEqual(
            {b"main": urlparse("http://archive.ubuntu.com/ubuntu"),
             b"ports": urlparse("http://ports.ubuntu.com/ubuntu-ports")},
            response)

    @wait_for_reactor
    @inlineCallbacks
    def test_get_archive_mirrors_with_main_archive_set(self):
        url = factory.make_parsed_url()
        yield deferToThread(self.set_main_archive, url.geturl())

        response = yield call_responder(Region(), GetArchiveMirrors, {})

        self.assertEqual(
            {b"main": url,
             b"ports": urlparse("http://ports.ubuntu.com/ubuntu-ports")},
            response)

    @inlineCallbacks
    def test_get_archive_mirrors_with_ports_archive_set(self):
        url = factory.make_parsed_url()
        yield deferToThread(self.set_ports_archive, url.geturl())

        response = yield call_responder(Region(), GetArchiveMirrors, {})

        self.assertEqual(
            {b"main": urlparse("http://arhive.ubuntu.com/ubuntu"),
             b"ports": url},
            response)


class TestRegionProtocol_GetProxies(TransactionTestCase):

    def test_get_proxies_is_registered(self):
        protocol = Region()
        responder = protocol.locateResponder(GetProxies.commandName)
        self.assertIsNotNone(responder)

    @transactional
    def set_http_proxy(self, url):
        Config.objects.set_config("http_proxy", url)

    @wait_for_reactor
    @inlineCallbacks
    def test_get_proxies_with_http_proxy_not_set(self):
        yield deferToThread(self.set_http_proxy, None)

        response = yield call_responder(Region(), GetProxies, {})

        self.assertEqual(
            {b"http": None, "https": None},
            response)

    @wait_for_reactor
    @inlineCallbacks
    def test_get_proxies_with_http_proxy_set(self):
        url = factory.make_parsed_url()
        yield deferToThread(self.set_http_proxy, url.geturl())

        response = yield call_responder(Region(), GetProxies, {})

        self.assertEqual(
            {b"http": url, b"https": url},
            response)


class TestRegionProtocol_GetClusterStatus(TransactionTestCase):

    def test_get_boot_sources_is_registered(self):
        protocol = Region()
        responder = protocol.locateResponder(GetClusterStatus.commandName)
        self.assertIsNot(responder, None)

    @wait_for_reactor
    def test_get_cluster_status_can_be_called(self):
        uuid = factory.make_name("uuid")
        d = call_responder(Region(), GetClusterStatus, {b"uuid": uuid})
        return assert_fails_with(d, NoSuchCluster)

    @transactional
    def make_cluster_with_random_status(self):
        status = factory.pick_choice(NODEGROUP_STATUS_CHOICES)
        nodegroup = factory.make_NodeGroup(status=status)
        return nodegroup.uuid, status

    @wait_for_reactor
    @inlineCallbacks
    def test_get_cluster_status_with_real_cluster(self):
        uuid, status = yield deferToThread(
            self.make_cluster_with_random_status)

        response = yield call_responder(
            Region(), GetClusterStatus, {b"uuid": uuid})

        self.assertEqual({b"status": status}, response)


class TestRegionProtocol_MarkNodeFailed(TransactionTestCase):

    def test_mark_failed_is_registered(self):
        protocol = Region()
        responder = protocol.locateResponder(MarkNodeFailed.commandName)
        self.assertIsNotNone(responder)

    @transactional
    def create_deploying_node(self):
        node = factory.make_Node(status=NODE_STATUS.DEPLOYING)
        return node.system_id

    @transactional
    def get_node_status(self, system_id):
        node = Node.objects.get(system_id=system_id)
        return node.status

    @transactional
    def get_node_error_description(self, system_id):
        node = Node.objects.get(system_id=system_id)
        return node.error_description

    @wait_for_reactor
    @inlineCallbacks
    def test_mark_node_failed_changes_status_and_updates_error_msg(self):
        self.patch(monitor_connect, 'MONITOR_CANCEL_CONNECT', False)

        system_id = yield deferToThread(self.create_deploying_node)

        error_description = factory.make_name('error-description')
        response = yield call_responder(
            Region(), MarkNodeFailed,
            {b'system_id': system_id, b'error_description': error_description})

        self.assertEqual({}, response)
        new_status = yield deferToThread(self.get_node_status, system_id)
        new_error_description = yield deferToThread(
            self.get_node_error_description, system_id)
        self.assertEqual(
            (NODE_STATUS.FAILED_DEPLOYMENT, error_description),
            (new_status, new_error_description))

    @wait_for_reactor
    def test_mark_node_failed_errors_if_node_cannot_be_found(self):
        system_id = factory.make_name('unknown-system-id')
        error_description = factory.make_name('error-description')

        d = call_responder(
            Region(), MarkNodeFailed,
            {b'system_id': system_id, b'error_description': error_description})

        def check(error):
            self.assertIsInstance(error, Failure)
            self.assertIsInstance(error.value, NoSuchNode)
            # The error message contains a reference to system_id.
            self.assertIn(system_id, error.value.message)

        return d.addErrback(check)


class TestRegionProtocol_ListNodePowerParameters(TransactionTestCase):

    @transactional
    def create_nodegroup(self, **kwargs):
        nodegroup = factory.make_NodeGroup(**kwargs)
        return nodegroup

    @transactional
    def create_node(self, nodegroup, **kwargs):
        node = factory.make_Node(nodegroup=nodegroup, **kwargs)
        return node

    @transactional
    def get_node_power_parameters(self, node):
        return node.get_effective_power_parameters()

    def test__is_registered(self):
        protocol = Region()
        responder = protocol.locateResponder(
            ListNodePowerParameters.commandName)
        self.assertIsNotNone(responder)

    @wait_for_reactor
    @inlineCallbacks
    def test__returns_correct_arguments(self):
        nodegroup = yield deferToThread(self.create_nodegroup)
        nodes = []
        for _ in range(3):
            node = yield deferToThread(self.create_node, nodegroup)
            power_params = yield deferToThread(
                self.get_node_power_parameters, node)
            nodes.append({
                'system_id': node.system_id,
                'hostname': node.hostname,
                'power_state': node.power_state,
                'power_type': node.get_effective_power_type(),
                'context': power_params,
                })

        # Create a node with an invalid power type (i.e. the empty string).
        # This will not be reported by the call to ListNodePowerParameters.
        yield deferToThread(self.create_node, nodegroup, power_type="")

        response = yield call_responder(
            Region(), ListNodePowerParameters,
            {b'uuid': nodegroup.uuid})

        self.assertItemsEqual(nodes, response['nodes'])

    @wait_for_reactor
    def test__raises_exception_if_nodegroup_doesnt_exist(self):
        uuid = factory.make_UUID()

        d = call_responder(
            Region(), ListNodePowerParameters,
            {b'uuid': uuid})

        return assert_fails_with(d, NoSuchCluster)


class TestRegionProtocol_UpdateNodePowerState(TransactionTestCase):

    @transactional
    def create_node(self, power_state):
        node = factory.make_Node(power_state=power_state)
        return node

    @transactional
    def get_node_power_state(self, system_id):
        node = Node.objects.get(system_id=system_id)
        return node.power_state

    def test__is_registered(self):
        protocol = Region()
        responder = protocol.locateResponder(UpdateNodePowerState.commandName)
        self.assertIsNotNone(responder)

    @wait_for_reactor
    @inlineCallbacks
    def test__changes_power_state(self):
        power_state = factory.pick_enum(POWER_STATE)
        node = yield deferToThread(self.create_node, power_state)

        new_state = factory.pick_enum(POWER_STATE, but_not=power_state)
        yield call_responder(
            Region(), UpdateNodePowerState,
            {b'system_id': node.system_id, b'power_state': new_state})

        db_state = yield deferToThread(
            self.get_node_power_state, node.system_id)
        self.assertEqual(new_state, db_state)

    @wait_for_reactor
    def test__errors_if_node_cannot_be_found(self):
        system_id = factory.make_name('unknown-system-id')
        power_state = factory.pick_enum(POWER_STATE)

        d = call_responder(
            Region(), UpdateNodePowerState,
            {b'system_id': system_id, b'power_state': power_state})

        def check(error):
            self.assertIsInstance(error, Failure)
            self.assertIsInstance(error.value, NoSuchNode)
            # The error message contains a reference to system_id.
            self.assertIn(system_id, error.value.message)

        return d.addErrback(check)


class TestRegionProtocol_RegisterEventType(TransactionTestCase):

    def test_register_event_type_is_registered(self):
        protocol = Region()
        responder = protocol.locateResponder(RegisterEventType.commandName)
        self.assertIsNotNone(responder)

    @transactional
    def get_event_type(self, name):
        return EventType.objects.get(name=name)

    @wait_for_reactor
    @inlineCallbacks
    def test_register_event_type_creates_object(self):
        name = factory.make_name('name')
        description = factory.make_name('description')
        level = random.randint(0, 100)
        response = yield call_responder(
            Region(), RegisterEventType,
            {b'name': name, b'description': description, b'level': level})

        self.assertEqual({}, response)
        event_type = yield deferToThread(self.get_event_type, name)
        self.assertThat(
            event_type,
            MatchesStructure.byEquality(
                name=name, description=description, level=level)
        )

    @wait_for_reactor
    @inlineCallbacks
    def test_register_event_type_does_not_error_for_existing_event_types(self):
        # This is a regression test for bug 1373357.
        name = factory.make_name('name')
        old_description = factory.make_name('old-description')
        level = random.randint(0, 100)
        response = yield call_responder(
            Region(), RegisterEventType,
            {b'name': name, b'description': old_description, b'level': level})
        self.assertEqual({}, response)

        new_description = factory.make_name('new-description')
        response = yield call_responder(
            Region(), RegisterEventType,
            {b'name': name, b'description': new_description, b'level': level})
        # If we get this far, no error has been raised, even though we
        # sent a duplicate request for registration.
        self.assertEqual({}, response)


class TestRegionProtocol_SendEvent(TransactionTestCase):

    def test_send_event_is_registered(self):
        protocol = Region()
        responder = protocol.locateResponder(SendEvent.commandName)
        self.assertIsNotNone(responder)

    @transactional
    def get_event(self, system_id, type_name):
        # Pre-fetch the related 'node' and 'type' because the caller
        # runs in the event-loop and this can't dereference related
        # objects (unless they have been prefetched).
        all_events_qs = Event.objects.all().select_related(
            'node', 'type')
        event = all_events_qs.get(
            node__system_id=system_id, type__name=type_name)
        return event

    @transactional
    def create_event_type(self, name, description, level):
        EventType.objects.create(
            name=name, description=description, level=level)

    @transactional
    def create_node(self):
        return factory.make_Node().system_id

    @wait_for_reactor
    @inlineCallbacks
    def test_send_event_stores_event(self):
        name = factory.make_name('type_name')
        description = factory.make_name('description')
        level = random.randint(0, 100)
        yield deferToThread(self.create_event_type, name, description, level)
        system_id = yield deferToThread(self.create_node)

        event_description = factory.make_name('description')
        response = yield call_responder(
            Region(), SendEvent,
            {
                b'system_id': system_id,
                b'type_name': name,
                b'description': event_description,
            }
        )

        self.assertEqual({}, response)
        event = yield deferToThread(self.get_event, system_id, name)
        self.assertEquals(
            (system_id, event_description, name),
            (event.node.system_id, event.description, event.type.name)
        )

    @wait_for_reactor
    def test_create_node_raises_if_unknown_type(self):
        name = factory.make_name('type_name')
        system_id = factory.make_name('system_id')
        description = factory.make_name('description')

        d = call_responder(
            Region(), SendEvent,
            {
                b'system_id': system_id,
                b'type_name': name,
                b'description': description,
            })

        def check(error):
            self.assertIsInstance(error, Failure)
            self.assertIsInstance(error.value, NoSuchEventType)

        return d.addErrback(check)

    @wait_for_reactor
    @inlineCallbacks
    def test_create_node_logs_if_unknown_node(self):
        maaslog = self.patch(events_module, 'maaslog')
        name = factory.make_name('type_name')
        description = factory.make_name('description')
        level = random.randint(0, 100)
        yield deferToThread(self.create_event_type, name, description, level)

        system_id = factory.make_name('system_id')
        event_description = factory.make_name('event-description')
        d = call_responder(
            Region(), SendEvent,
            {
                b'system_id': system_id,
                b'type_name': name,
                b'description': event_description,
            })

        def check(result):
            self.assertThat(
                maaslog.debug, MockCalledOnceWith(
                    "Event '%s: %s' sent for non-existent node '%s'.",
                    name, event_description, system_id))

        yield d.addCallback(check)


class TestRegionProtocol_SendEventMACAddress(TransactionTestCase):

    def test_send_event_mac_address_is_registered(self):
        protocol = Region()
        responder = protocol.locateResponder(
            SendEventMACAddress.commandName)
        self.assertIsNotNone(responder)

    @transactional
    def get_event(self, mac_address, type_name):
        # Pre-fetch the related 'node' and 'type' because the caller
        # runs in the event-loop and this can't dereference related
        # objects (unless they have been prefetched).
        all_events_qs = Event.objects.all().select_related(
            'node', 'type')
        node = MACAddress.objects.get(mac_address=mac_address).node
        event = all_events_qs.get(node=node, type__name=type_name)
        return event

    @transactional
    def create_event_type(self, name, description, level):
        EventType.objects.create(
            name=name, description=description, level=level)

    @transactional
    def make_mac_address(self):
        return factory.make_MACAddress_with_Node()

    @wait_for_reactor
    @inlineCallbacks
    def test_send_event_mac_address_stores_event(self):
        name = factory.make_name('type_name')
        description = factory.make_name('description')
        level = random.randint(0, 100)
        yield deferToThread(self.create_event_type, name, description, level)
        MAC_address = yield deferToThread(self.make_mac_address)
        mac_address = MAC_address.mac_address.get_raw()

        event_description = factory.make_name('description')
        response = yield call_responder(
            Region(), SendEventMACAddress,
            {
                b'mac_address': mac_address,
                b'type_name': name,
                b'description': event_description,
            }
        )

        self.assertEqual({}, response)
        event = yield deferToThread(self.get_event, mac_address, name)
        self.assertEquals(
            (MAC_address.node.system_id, event_description, name),
            (event.node.system_id, event.description, event.type.name)
        )

    @wait_for_reactor
    def test_create_node_raises_if_unknown_type(self):
        name = factory.make_name('type_name')
        mac_address = factory.make_mac_address()
        description = factory.make_name('description')

        d = call_responder(
            Region(), SendEventMACAddress,
            {
                b'mac_address': mac_address,
                b'type_name': name,
                b'description': description,
            })

        def check(error):
            self.assertIsInstance(error, Failure)
            self.assertIsInstance(error.value, NoSuchEventType)

        return d.addErrback(check)

    @wait_for_reactor
    @inlineCallbacks
    def test_create_node_raises_if_unknown_node(self):
        maaslog = self.patch(events_module, 'maaslog')
        name = factory.make_name('type_name')
        description = factory.make_name('description')
        level = random.randint(0, 100)
        yield deferToThread(self.create_event_type, name, description, level)

        mac_address = factory.make_mac_address()
        event_description = factory.make_name('event-description')
        d = call_responder(
            Region(), SendEventMACAddress,
            {
                b'mac_address': mac_address,
                b'type_name': name,
                b'description': event_description,
            })

        def check(result):
            self.assertThat(
                maaslog.debug, MockCalledOnceWith(
                    "Event '%s: %s' sent for non-existent node with MAC "
                    "address '%s'.",
                    name, event_description, mac_address))

        yield d.addCallback(check)


class TestRegionServer(MAASServerTestCase):

    def test_interfaces(self):
        protocol = RegionServer()
        # transport.getHandle() is used by AMP._getPeerCertificate, which we
        # call indirectly via the peerCertificate attribute in IConnection.
        self.patch(protocol, "transport")
        verifyObject(IConnection, protocol)

    def test_connectionMade_identifies_the_remote_cluster(self):
        service = RegionService()
        service.running = True  # Pretend it's running.
        protocol = service.factory.buildProtocol(addr=None)  # addr is unused.
        example_uuid = factory.make_UUID()
        callRemote = self.patch(protocol, "callRemote")
        callRemote.return_value = succeed({b"ident": example_uuid})
        protocol.connectionMade()
        # The Identify command was called on the cluster. Authenticate too,
        # but we're not looking at that right now.
        self.assertThat(callRemote, MockCallsMatch(
            call(cluster.Identify),
            call(cluster.Authenticate, message=ANY),
        ))
        # The UUID has been saved on the protocol instance.
        self.assertThat(protocol.ident, Equals(example_uuid))

    def test_connectionMade_drops_the_connection_on_ident_failure(self):
        service = RegionService()
        service.running = True  # Pretend it's running.
        protocol = service.factory.buildProtocol(addr=None)  # addr is unused.
        callRemote = self.patch(protocol, "callRemote")
        callRemote.return_value = fail(IOError("no paddle"))
        transport = self.patch(protocol, "transport")
        logger = self.useFixture(TwistedLoggerFixture())
        protocol.connectionMade()
        # The transport is instructed to lose the connection.
        self.assertThat(transport.loseConnection, MockCalledOnceWith())
        # The connection is not in the service's connection map.
        self.assertDictEqual({}, service.connections)
        # The error is logged.
        self.assertDocTestMatches(
            """\
            Cluster could not be identified; dropping connection.
            Traceback (most recent call last):
            Failure: exceptions.IOError: no paddle
            """,
            logger.dump())

    def test_connectionMade_updates_services_connection_set(self):
        service = RegionService()
        service.running = True  # Pretend it's running.
        service.factory.protocol = HandshakingRegionServer
        protocol = service.factory.buildProtocol(addr=None)  # addr is unused.
        self.assertDictEqual({}, service.connections)
        protocol.connectionMade()
        self.assertDictEqual(
            {protocol.ident: {protocol}},
            service.connections)

    def test_connectionMade_drops_connection_if_service_not_running(self):
        service = RegionService()
        service.running = False  # Pretend it's not running.
        service.factory.protocol = HandshakingRegionServer
        protocol = service.factory.buildProtocol(addr=None)  # addr is unused.
        transport = self.patch(protocol, "transport")
        self.assertDictEqual({}, service.connections)
        protocol.connectionMade()
        # The protocol is not added to the connection set.
        self.assertDictEqual({}, service.connections)
        # The transport is instructed to lose the connection.
        self.assertThat(transport.loseConnection, MockCalledOnceWith())

    def test_connectionLost_updates_services_connection_set(self):
        service = RegionService()
        service.running = True  # Pretend it's running.
        service.factory.protocol = HandshakingRegionServer
        protocol = service.factory.buildProtocol(addr=None)  # addr is unused.
        protocol.connectionMade()
        connectionLost_up_call = self.patch(amp.AMP, "connectionLost")
        self.assertDictEqual(
            {protocol.ident: {protocol}},
            service.connections)
        protocol.connectionLost(reason=None)
        # The connection is removed from the set, but the key remains.
        self.assertDictEqual({protocol.ident: set()}, service.connections)
        # connectionLost() is called on the superclass.
        self.assertThat(connectionLost_up_call, MockCalledOnceWith(None))

    def patch_authenticate_for_failure(self, client):
        authenticate = self.patch_autospec(client, "authenticateCluster")
        authenticate.side_effect = always_succeed_with(False)

    def patch_authenticate_for_error(self, client, exception):
        authenticate = self.patch_autospec(client, "authenticateCluster")
        authenticate.side_effect = always_fail_with(exception)

    def test_connectionMade_drops_connections_if_authentication_fails(self):
        service = RegionService()
        service.running = True  # Pretend it's running.
        service.factory.protocol = HandshakingRegionServer
        protocol = service.factory.buildProtocol(addr=None)  # addr is unused.
        self.patch_authenticate_for_failure(protocol)
        transport = self.patch(protocol, "transport")
        self.assertDictEqual({}, service.connections)
        protocol.connectionMade()
        # The protocol is not added to the connection set.
        self.assertDictEqual({}, service.connections)
        # The transport is instructed to lose the connection.
        self.assertThat(transport.loseConnection, MockCalledOnceWith())

    def test_connectionMade_drops_connections_if_authentication_errors(self):
        logger = self.useFixture(TwistedLoggerFixture())

        service = RegionService()
        service.running = True  # Pretend it's running.
        service.factory.protocol = HandshakingRegionServer
        protocol = service.factory.buildProtocol(addr=None)  # addr is unused.
        exception_type = factory.make_exception_type()
        self.patch_authenticate_for_error(protocol, exception_type())
        transport = self.patch(protocol, "transport")
        self.assertDictEqual({}, service.connections)
        protocol.connectionMade()
        # The protocol is not added to the connection set.
        self.assertDictEqual({}, service.connections)
        # The transport is instructed to lose the connection.
        self.assertThat(transport.loseConnection, MockCalledOnceWith())

        # The log was written to.
        self.assertDocTestMatches(
            """\
            Cluster '...' could not be authenticated; dropping connection.
            Traceback (most recent call last):...
            """,
            logger.dump())

    def test_handshakeFailed_does_not_log_when_connection_is_closed(self):
        server = RegionServer()
        with TwistedLoggerFixture() as logger:
            server.handshakeFailed(Failure(ConnectionClosed()))
        # Nothing was logged.
        self.assertEqual("", logger.output)

    def make_running_server(self):
        service = RegionService()
        service.running = True  # Pretend it's running.
        # service.factory.protocol = RegionServer
        return service.factory.buildProtocol(addr=None)  # addr is unused.

    def test_authenticateCluster_accepts_matching_digests(self):
        server = self.make_running_server()

        def calculate_digest(_, message):
            # Use the region's own authentication responder.
            return Region().authenticate(message)

        callRemote = self.patch_autospec(server, "callRemote")
        callRemote.side_effect = calculate_digest

        d = server.authenticateCluster()
        self.assertTrue(extract_result(d))

    def test_authenticateCluster_rejects_non_matching_digests(self):
        server = self.make_running_server()

        def calculate_digest(_, message):
            # Return some nonsense.
            response = {
                "digest": factory.make_bytes(),
                "salt": factory.make_bytes(),
            }
            return succeed(response)

        callRemote = self.patch_autospec(server, "callRemote")
        callRemote.side_effect = calculate_digest

        d = server.authenticateCluster()
        self.assertFalse(extract_result(d))

    def test_authenticateCluster_propagates_errors(self):
        server = self.make_running_server()
        exception_type = factory.make_exception_type()

        callRemote = self.patch_autospec(server, "callRemote")
        callRemote.return_value = fail(exception_type())

        d = server.authenticateCluster()
        self.assertRaises(exception_type, extract_result, d)

    def test_authenticateCluster_end_to_end(self):
        self.useFixture(RegionEventLoopFixture("rpc"))
        self.useFixture(RunningEventLoopFixture())
        rpc_fixture = self.useFixture(MockLiveRegionToClusterRPCFixture())
        server = rpc_fixture.makeCluster(factory.make_NodeGroup())
        self.assertThat(
            server.Authenticate,
            MockCalledOnceWith(server, message=ANY))


class TestRegionService(MAASTestCase):

    def test_init_sets_appropriate_instance_attributes(self):
        service = RegionService()
        self.assertThat(service, IsInstance(Service))
        self.assertThat(service.connections, IsInstance(defaultdict))
        self.assertThat(service.connections.default_factory, Is(set))
        self.assertThat(
            service.endpoints, AllMatch(Provides(IStreamServerEndpoint)))
        self.assertThat(service.factory, IsInstance(Factory))
        self.assertThat(service.factory.protocol, Equals(RegionServer))

    @wait_for_reactor
    def test_starting_and_stopping_the_service(self):
        service = RegionService()
        self.assertThat(service.starting, Is(None))
        service.startService()
        self.assertThat(service.starting, IsInstance(Deferred))

        def check_started(_):
            # Ports are saved as private instance vars.
            self.assertThat(service.ports, HasLength(1))
            [port] = service.ports
            self.assertThat(port, IsInstance(tcp.Port))
            self.assertThat(port.factory, IsInstance(Factory))
            self.assertThat(port.factory.protocol, Equals(RegionServer))
            return service.stopService()

        service.starting.addCallback(check_started)

        def check_stopped(ignore, service=service):
            self.assertThat(service.ports, Equals([]))

        service.starting.addCallback(check_stopped)

        return service.starting

    @wait_for_reactor
    def test_startService_returns_Deferred(self):
        service = RegionService()

        # Don't configure any endpoints.
        self.patch(service, "endpoints", [])

        d = service.startService()
        self.assertThat(d, IsInstance(Deferred))
        # It's actually the `starting` Deferred.
        self.assertIs(service.starting, d)

        def started(_):
            return service.stopService()

        return d.addCallback(started)

    @wait_for_reactor
    def test_start_up_can_be_cancelled(self):
        service = RegionService()

        # Return an inert Deferred from the listen() call.
        endpoints = self.patch(service, "endpoints", [Mock()])
        endpoints[0].listen.return_value = Deferred()

        service.startService()
        self.assertThat(service.starting, IsInstance(Deferred))

        service.starting.cancel()

        def check(port):
            self.assertThat(port, Is(None))
            self.assertThat(service.ports, HasLength(0))
            return service.stopService()

        return service.starting.addCallback(check)

    @wait_for_reactor
    @inlineCallbacks
    def test_start_up_errors_are_logged(self):
        service = RegionService()

        # Ensure that endpoint.listen fails with a obvious error.
        exception = ValueError("This is not the messiah.")
        endpoints = self.patch(service, "endpoints", [Mock()])
        endpoints[0].listen.return_value = fail(exception)

        err_calls = []
        self.patch(log, "err", err_calls.append)

        err_calls_expected = [
            AfterPreprocessing(
                (lambda failure: failure.value),
                Is(exception)),
        ]

        yield service.startService()
        self.assertThat(err_calls, MatchesListwise(err_calls_expected))

    @wait_for_reactor
    def test_stopping_cancels_startup(self):
        service = RegionService()

        # Return an inert Deferred from the listen() call.
        endpoints = self.patch(service, "endpoints", [Mock()])
        endpoints[0].listen.return_value = Deferred()

        service.startService()
        service.stopService()

        def check(_):
            # The CancelledError is suppressed.
            self.assertThat(service.ports, HasLength(0))

        return service.starting.addCallback(check)

    @wait_for_reactor
    @inlineCallbacks
    def test_stopping_closes_connections_cleanly(self):
        service = RegionService()
        service.starting = Deferred()
        service.factory.protocol = HandshakingRegionServer
        connections = {
            service.factory.buildProtocol(None),
            service.factory.buildProtocol(None),
        }
        for conn in connections:
            # Pretend it's already connected.
            service.connections[conn.ident].add(conn)
        transports = {
            self.patch(conn, "transport")
            for conn in connections
        }
        yield service.stopService()
        self.assertThat(
            transports, AllMatch(
                AfterPreprocessing(
                    attrgetter("loseConnection"),
                    MockCalledOnceWith())))

    @wait_for_reactor
    @inlineCallbacks
    def test_stopping_logs_errors_when_closing_connections(self):
        service = RegionService()
        service.starting = Deferred()
        service.factory.protocol = HandshakingRegionServer
        connections = {
            service.factory.buildProtocol(None),
            service.factory.buildProtocol(None),
        }
        for conn in connections:
            transport = self.patch(conn, "transport")
            transport.loseConnection.side_effect = IOError("broken")
            # Pretend it's already connected.
            service.connections[conn.ident].add(conn)
        logger = self.useFixture(TwistedLoggerFixture())
        # stopService() completes without returning an error.
        yield service.stopService()
        # Connection-specific errors are logged.
        self.assertDocTestMatches(
            """\
            Unhandled Error
            Traceback (most recent call last):
            ...
            exceptions.IOError: broken
            ---
            Unhandled Error
            Traceback (most recent call last):
            ...
            exceptions.IOError: broken
            """,
            logger.dump())

    @wait_for_reactor
    def test_stopping_when_start_up_failed(self):
        service = RegionService()

        # Ensure that endpoint.listen fails with a obvious error.
        exception = ValueError("This is a very naughty boy.")
        endpoints = self.patch(service, "endpoints", [Mock()])
        endpoints[0].listen.return_value = fail(exception)
        # Suppress logged messages.
        self.patch(log.theLogPublisher, "observers", [])

        service.startService()
        # The test is that stopService() succeeds.
        return service.stopService()

    @wait_for_reactor
    def test_getClientFor_errors_when_no_connections(self):
        service = RegionService()
        service.connections.clear()
        return assert_fails_with(
            service.getClientFor(factory.make_UUID(), timeout=0),
            exceptions.NoConnectionsAvailable)

    @wait_for_reactor
    def test_getClientFor_errors_when_no_connections_for_cluster(self):
        service = RegionService()
        uuid = factory.make_UUID()
        service.connections[uuid].clear()
        return assert_fails_with(
            service.getClientFor(uuid, timeout=0),
            exceptions.NoConnectionsAvailable)

    @wait_for_reactor
    def test_getClientFor_returns_random_connection(self):
        c1 = DummyConnection()
        c2 = DummyConnection()
        chosen = DummyConnection()

        service = RegionService()
        uuid = factory.make_UUID()
        conns_for_uuid = service.connections[uuid]
        conns_for_uuid.update({c1, c2})

        def check_choice(choices):
            self.assertItemsEqual(choices, conns_for_uuid)
            return chosen
        self.patch(random, "choice", check_choice)

        def check(client):
            self.assertThat(client, Equals(common.Client(chosen)))

        return service.getClientFor(uuid).addCallback(check)

    @wait_for_reactor
    def test_getAllClients_empty(self):
        service = RegionService()
        service.connections.clear()
        self.assertThat(service.getAllClients(), Equals([]))

    @wait_for_reactor
    def test_getAllClients(self):
        service = RegionService()
        uuid1 = factory.make_UUID()
        c1 = DummyConnection()
        c2 = DummyConnection()
        service.connections[uuid1].update({c1, c2})
        uuid2 = factory.make_UUID()
        c3 = DummyConnection()
        c4 = DummyConnection()
        service.connections[uuid2].update({c3, c4})
        clients = service.getAllClients()
        self.assertItemsEqual(clients, {
            common.Client(c1), common.Client(c2),
            common.Client(c3), common.Client(c4),
        })

    def test_addConnectionFor_adds_connection(self):
        service = RegionService()
        uuid = factory.make_UUID()
        c1 = DummyConnection()
        c2 = DummyConnection()

        service._addConnectionFor(uuid, c1)
        service._addConnectionFor(uuid, c2)

        self.assertEqual({uuid: {c1, c2}}, service.connections)

    def test_addConnectionFor_notifies_waiters(self):
        service = RegionService()
        uuid = factory.make_UUID()
        c1 = DummyConnection()
        c2 = DummyConnection()

        waiter1 = Mock()
        waiter2 = Mock()
        service.waiters[uuid].add(waiter1)
        service.waiters[uuid].add(waiter2)

        service._addConnectionFor(uuid, c1)
        service._addConnectionFor(uuid, c2)

        self.assertEqual({uuid: {c1, c2}}, service.connections)
        # Both mock waiters are called twice. A real waiter would only be
        # called once because it immediately unregisters itself once called.
        self.assertThat(waiter1.callback, MockCallsMatch(call(c1), call(c2)))
        self.assertThat(waiter2.callback, MockCallsMatch(call(c1), call(c2)))

    def test_removeConnectionFor_removes_connection(self):
        service = RegionService()
        uuid = factory.make_UUID()
        c1 = DummyConnection()
        c2 = DummyConnection()

        service._addConnectionFor(uuid, c1)
        service._addConnectionFor(uuid, c2)
        service._removeConnectionFor(uuid, c1)

        self.assertEqual({uuid: {c2}}, service.connections)

    def test_removeConnectionFor_is_okay_if_connection_is_not_there(self):
        service = RegionService()
        uuid = factory.make_UUID()

        service._removeConnectionFor(uuid, DummyConnection())

        self.assertEqual({uuid: set()}, service.connections)

    @wait_for_reactor
    def test_getConnectionFor_returns_existing_connection(self):
        service = RegionService()
        uuid = factory.make_UUID()
        conn = DummyConnection()

        service._addConnectionFor(uuid, conn)

        d = service._getConnectionFor(uuid, 1)
        # No waiter is added because a connection is available.
        self.assertEqual({uuid: set()}, service.waiters)

        def check(conn_returned):
            self.assertThat(conn_returned, Is(conn))

        return d.addCallback(check)

    @wait_for_reactor
    def test_getConnectionFor_waits_for_connection(self):
        service = RegionService()
        uuid = factory.make_UUID()
        conn = DummyConnection()

        # Add the connection later (we're in the reactor thread right
        # now so this won't happen until after we return).
        reactor.callLater(0, service._addConnectionFor, uuid, conn)

        d = service._getConnectionFor(uuid, 1)
        # A waiter is added for the connection we're interested in.
        self.assertEqual({uuid: {d}}, service.waiters)

        def check(conn_returned):
            self.assertThat(conn_returned, Is(conn))
            # The waiter has been unregistered.
            self.assertEqual({uuid: set()}, service.waiters)

        return d.addCallback(check)

    @wait_for_reactor
    def test_getConnectionFor_with_concurrent_waiters(self):
        service = RegionService()
        uuid = factory.make_UUID()
        conn = DummyConnection()

        # Add the connection later (we're in the reactor thread right
        # now so this won't happen until after we return).
        reactor.callLater(0, service._addConnectionFor, uuid, conn)

        d1 = service._getConnectionFor(uuid, 1)
        d2 = service._getConnectionFor(uuid, 1)
        # A waiter is added for each call to _getConnectionFor().
        self.assertEqual({uuid: {d1, d2}}, service.waiters)

        d = DeferredList((d1, d2))

        def check(results):
            self.assertEqual([(True, conn), (True, conn)], results)
            # The waiters have both been unregistered.
            self.assertEqual({uuid: set()}, service.waiters)

        return d.addCallback(check)

    @wait_for_reactor
    def test_getConnectionFor_cancels_waiter_when_it_times_out(self):
        service = RegionService()
        uuid = factory.make_UUID()

        d = service._getConnectionFor(uuid, 1)
        # A waiter is added for the connection we're interested in.
        self.assertEqual({uuid: {d}}, service.waiters)
        d = assert_fails_with(d, CancelledError)

        def check(_):
            # The waiter has been unregistered.
            self.assertEqual({uuid: set()}, service.waiters)

        return d.addCallback(check)


class TestRegionAdvertisingService(MAASTestCase):

    def tearDown(self):
        super(TestRegionAdvertisingService, self).tearDown()
        # Django doesn't notice that the database needs to be reset.
        with closing(connection):
            with closing(connection.cursor()) as cursor:
                cursor.execute("DROP TABLE IF EXISTS eventloops")

    def test_init(self):
        ras = RegionAdvertisingService()
        self.assertEqual(60, ras.step)
        self.assertEqual((deferToThread, (ras.update,), {}), ras.call)

    @wait_for_reactor
    def test_starting_and_stopping_the_service(self):
        service = RegionAdvertisingService()
        self.assertThat(service.starting, Is(None))
        service.startService()
        self.assertThat(service.starting, IsInstance(Deferred))

        def check_query_eventloops():
            with closing(connection):
                with closing(connection.cursor()) as cursor:
                    cursor.execute("SELECT * FROM eventloops")

        service.starting.addCallback(
            lambda ignore: self.assertTrue(service.running))
        service.starting.addCallback(
            lambda ignore: deferToThread(check_query_eventloops))
        service.starting.addCallback(
            lambda ignore: service.stopService())

        def check_stopped(ignore, service=service):
            self.assertFalse(service.running)

        service.starting.addCallback(check_stopped)

        return service.starting

    @wait_for_reactor
    def test_start_up_can_be_cancelled(self):
        service = RegionAdvertisingService()

        lock = threading.Lock()
        with lock:
            # Prevent prepare - which is deferred to a thread - from
            # completing while we hold the lock.
            service.prepare = lock.acquire
            # Start the service, but cancel it before prepare is able to
            # complete.
            service.startService()
            self.assertThat(service.starting, IsInstance(Deferred))
            service.starting.cancel()

        def check(ignore):
            # The service never started.
            self.assertFalse(service.running)

        return service.starting.addCallback(check)

    @wait_for_reactor
    def test_start_up_errors_are_logged(self):
        service = RegionAdvertisingService()
        # Prevent real pauses.
        self.patch_autospec(regionservice, "pause").return_value = None
        # Ensure that service.prepare fails with a obvious error.
        exception = ValueError("You don't vote for kings!")
        self.patch(service, "prepare").side_effect = [exception, None]
        # Capture all Twisted logs.
        logger = self.useFixture(TwistedLoggerFixture())

        def check_logs(ignore):
            self.assertDocTestMatches(
                """\
                Preparation of ... failed; will try again in 5 seconds.
                Traceback (most recent call last):...
                Failure: exceptions.ValueError: You don't vote for kings!
                """,
                logger.dump())

        service.startService()
        service.starting.addCallback(check_logs)
        return service.starting

    @wait_for_reactor
    def test_stopping_cancels_startup(self):
        service = RegionAdvertisingService()

        lock = threading.Lock()
        with lock:
            # Prevent prepare - which is deferred to a thread - from
            # completing while we hold the lock.
            service.prepare = lock.acquire
            # Start the service, but stop it again before prepare is
            # able to complete.
            service.startService()
            service.stopService()

        def check(ignore):
            self.assertTrue(service.starting.called)
            self.assertFalse(service.running)

        return service.starting.addCallback(check)

    @wait_for_reactor
    def test_stopping_when_start_up_failed(self):
        service = RegionAdvertisingService()

        # Ensure that service.prepare fails with a obvious error.
        exception = ValueError("First, shalt thou take out the holy pin.")
        self.patch(service, "prepare").side_effect = exception
        # Suppress logged messages.
        self.patch(log.theLogPublisher, "observers", [])

        service.startService()
        # The test is that stopService() succeeds.
        return service.stopService()

    def test_prepare(self):
        service = RegionAdvertisingService()

        with closing(connection):
            # Before service.prepare is called, there's not eventloops
            # table, and selecting from it elicits an error.
            with closing(connection.cursor()) as cursor:
                self.assertRaises(
                    ProgrammingError, cursor.execute,
                    "SELECT * FROM eventloops")

        service.prepare()

        with closing(connection):
            # After service.prepare is called, the eventloops table
            # exists, and selecting from it works fine, though it is
            # empty.
            with closing(connection.cursor()) as cursor:
                cursor.execute("SELECT * FROM eventloops")
                self.assertEqual([], list(cursor))

    def test_prepare_holds_startup_lock(self):
        # Creating tables in PostgreSQL is a transactional operation
        # like any other. If the isolation level is not sufficient - the
        # default in Django - it is susceptible to races. Using a higher
        # isolation level may lead to serialisation failures, for
        # example. However, PostgreSQL provides advisory locking
        # functions, and that's what RegionAdvertisingService.prepare
        # takes advantage of to prevent concurrent creation of the
        # eventloops table.

        # A record of the lock's status, populated when a custom
        # patched-in _do_create() is called.
        locked = []

        def _do_create(cursor):
            locked.append(locks.eventloop.is_locked())

        service = RegionAdvertisingService()
        service._do_create = _do_create

        # The lock is not held before and after prepare() is called.
        self.assertFalse(locks.eventloop.is_locked())
        service.prepare()
        self.assertFalse(locks.eventloop.is_locked())

        # The lock was held when _do_create() was called.
        self.assertEqual([True], locked)

    def test_update(self):
        example_addresses = [
            (factory.make_ipv4_address(), factory.pick_port()),
            (factory.make_ipv4_address(), factory.pick_port()),
        ]

        service = RegionAdvertisingService()
        service._get_addresses = lambda: example_addresses
        service.prepare()
        service.update()

        with closing(connection):
            with closing(connection.cursor()) as cursor:
                cursor.execute("SELECT address, port FROM eventloops")
                self.assertItemsEqual(example_addresses, list(cursor))

    def test_update_does_not_insert_when_nothings_listening(self):
        service = RegionAdvertisingService()
        service._get_addresses = lambda: []
        service.prepare()
        service.update()

        with closing(connection):
            with closing(connection.cursor()) as cursor:
                cursor.execute("SELECT address, port FROM eventloops")
                self.assertItemsEqual([], list(cursor))

    def test_update_deletes_old_records(self):
        service = RegionAdvertisingService()
        service.prepare()
        # Populate the eventloops table by hand with two records, one
        # fresh ("vic") and one old ("bob").
        with closing(connection):
            with closing(connection.cursor()) as cursor:
                cursor.execute("""\
                  INSERT INTO eventloops
                    (name, address, port, updated)
                  VALUES
                    ('vic', '192.168.1.1', 1111, DEFAULT),
                    ('bob', '192.168.1.2', 2222, NOW() - INTERVAL '6 mins')
                """)
        # Both event-loops, vic and bob, are visible.
        self.assertItemsEqual(
            [("vic", "192.168.1.1", 1111),
             ("bob", "192.168.1.2", 2222)],
            service.dump())
        # Updating also garbage-collects old event-loop records.
        service.update()
        self.assertItemsEqual(
            [("vic", "192.168.1.1", 1111)],
            service.dump())

    def test_dump(self):
        example_addresses = [
            (factory.make_ipv4_address(), factory.pick_port()),
            (factory.make_ipv4_address(), factory.pick_port()),
        ]

        service = RegionAdvertisingService()
        service._get_addresses = lambda: example_addresses
        service.prepare()
        service.update()

        expected = [
            (eventloop.loop.name, addr, port)
            for (addr, port) in example_addresses
        ]

        self.assertItemsEqual(expected, service.dump())

    def test_remove(self):
        service = RegionAdvertisingService()
        service._get_addresses = lambda: [("192.168.0.1", 9876)]
        service.prepare()
        service.update()
        service.remove()

        self.assertItemsEqual([], service.dump())

    @wait_for_reactor
    @inlineCallbacks
    def test_stopping_calls_remove(self):
        service = RegionAdvertisingService()
        service._get_addresses = lambda: [("192.168.0.1", 9876)]

        # It's hard to no guarantee that the timed call will run at
        # least once while the service is started, so we neuter it here
        # and call service.update() explicitly.
        service.call = (lambda: None), (), {}

        yield service.startService()
        yield deferToThread(service.update)
        yield service.stopService()

        dump = yield deferToThread(service.dump)
        self.assertItemsEqual([], dump)

    def test__get_addresses(self):
        service = RegionAdvertisingService()

        example_port = factory.pick_port()
        getServiceNamed = self.patch(eventloop.services, "getServiceNamed")
        getPort = getServiceNamed.return_value.getPort
        getPort.side_effect = asynchronous(lambda: example_port)

        example_ipv4_addrs = {
            factory.make_ipv4_address(),
            factory.make_ipv4_address(),
        }
        example_ipv6_addrs = {
            factory.make_ipv6_address(),
            factory.make_ipv6_address(),
        }
        example_link_local_addrs = {
            factory.pick_ip_in_network(netaddr.ip.IPV4_LINK_LOCAL),
            factory.pick_ip_in_network(netaddr.ip.IPV6_LINK_LOCAL),
        }
        get_all_interface_addresses = self.patch(
            regionservice, "get_all_interface_addresses")
        get_all_interface_addresses.return_value = (
            example_ipv4_addrs | example_ipv6_addrs |
            example_link_local_addrs)

        # IPv6 addresses and link-local addresses are excluded, and thus
        # not advertised.
        self.assertItemsEqual(
            [(addr, example_port) for addr in example_ipv4_addrs],
            service._get_addresses())

        getServiceNamed.assert_called_once_with("rpc")
        get_all_interface_addresses.assert_called_once_with()

    def test__get_addresses_when_rpc_down(self):
        service = RegionAdvertisingService()

        getServiceNamed = self.patch(eventloop.services, "getServiceNamed")
        # getPort() returns None when the RPC service is not running or
        # not able to bind a port.
        getPort = getServiceNamed.return_value.getPort
        getPort.side_effect = asynchronous(lambda: None)

        get_all_interface_addresses = self.patch(
            regionservice, "get_all_interface_addresses")
        get_all_interface_addresses.return_value = [
            factory.make_ipv4_address(),
            factory.make_ipv4_address(),
        ]

        # If the RPC service is down, _get_addresses() returns nothing.
        self.assertItemsEqual([], service._get_addresses())


class TestRegionProtocol_ReportForeignDHCPServer(TransactionTestCase):

    def test_create_node_is_registered(self):
        protocol = Region()
        responder = protocol.locateResponder(
            ReportForeignDHCPServer.commandName)
        self.assertIsNotNone(responder)

    @transactional
    def create_cluster_interface(self):
        cluster = factory.make_NodeGroup()
        return factory.make_NodeGroupInterface(cluster)

    @wait_for_reactor
    @inlineCallbacks
    def test_sets_foreign_dhcp_value(self):
        foreign_dhcp_ip = factory.make_ipv4_address()
        cluster_interface = yield deferToThread(
            self.create_cluster_interface)
        cluster = cluster_interface.nodegroup

        response = yield call_responder(
            Region(), ReportForeignDHCPServer,
            {
                b'cluster_uuid': cluster.uuid,
                b'interface_name': cluster_interface.name,
                b'foreign_dhcp_ip': foreign_dhcp_ip,
            })

        self.assertEqual({}, response)
        cluster_interface = yield deferToThread(
            transactional_reload_object, cluster_interface)

        self.assertEqual(
            foreign_dhcp_ip, cluster_interface.foreign_dhcp_ip)

    def test_does_not_trigger_update_signal(self):
        configure_dhcp = self.patch_autospec(dhcp, "configure_dhcp")

        foreign_dhcp_ip = factory.make_ipv4_address()
        cluster_interface = yield deferToThread(
            self.create_cluster_interface)
        cluster = cluster_interface.nodegroup

        response = yield call_responder(
            Region(), ReportForeignDHCPServer,
            {
                b'cluster_uuid': cluster.uuid,
                b'interface_name': cluster_interface.name,
                b'foreign_dhcp_ip': foreign_dhcp_ip,
            })

        self.assertEqual({}, response)
        self.assertThat(configure_dhcp, MockNotCalled())


class TestRegionProtocol_GetClusterInterfaces(TransactionTestCase):

    def test_create_node_is_registered(self):
        protocol = Region()
        responder = protocol.locateResponder(
            GetClusterInterfaces.commandName)
        self.assertIsNotNone(responder)

    @transactional
    def create_cluster_and_interfaces(self):
        cluster = factory.make_NodeGroup()
        for _ in range(3):
            factory.make_NodeGroupInterface(cluster)
        interfaces = [
            {
                'name': interface.name,
                'interface': interface.interface,
                'ip': interface.ip,
            }
            for interface in cluster.nodegroupinterface_set.all()]
        return cluster, interfaces

    @wait_for_reactor
    @inlineCallbacks
    def test_returns_all_cluster_interfaces(self):
        cluster, expected_interfaces = yield deferToThread(
            self.create_cluster_and_interfaces)

        response = yield call_responder(
            Region(), GetClusterInterfaces,
            {b'cluster_uuid': cluster.uuid})

        self.assertIsNot(None, response)
        self.assertItemsEqual(
            expected_interfaces, response["interfaces"])


class TestRegionProtocol_CreateNode(TransactionTestCase):

    def test_create_node_is_registered(self):
        protocol = Region()
        responder = protocol.locateResponder(
            CreateNode.commandName)
        self.assertIsNotNone(responder)

    @transactional
    def create_node(self):
        return factory.make_Node()

    @wait_for_reactor
    @inlineCallbacks
    def test_calls_create_node_function(self):
        create_node_function = self.patch(regionservice, 'create_node')
        create_node_function.return_value = yield deferToThread(
            self.create_node)

        params = {
            'cluster_uuid': factory.make_name('uuid'),
            'architecture': make_usable_architecture(self),
            'power_type': factory.make_name("power_type"),
            'power_parameters': dumps({}),
            'mac_addresses': [factory.make_mac_address()],
        }

        response = yield call_responder(
            Region(), CreateNode, params)
        self.assertIsNotNone(response)

        self.assertThat(
            create_node_function,
            MockCalledOnceWith(
                params['cluster_uuid'], params['architecture'],
                params['power_type'], params['power_parameters'],
                params['mac_addresses']))
        self.assertEqual(
            create_node_function.return_value.system_id,
            response['system_id'])


class TestRegionProtocol_TimerExpired(MAASTestCase):

    def test_timer_expired_node_is_registered(self):
        protocol = Region()
        responder = protocol.locateResponder(
            CreateNode.commandName)
        self.assertIsNotNone(responder)

    @wait_for_reactor
    @inlineCallbacks
    def test_calls_handle_monitor_expired(self):
        handle_monitor_expired = self.patch(
            regionservice, 'handle_monitor_expired')

        params = {
            'id': factory.make_name('id'),
            'context': factory.make_name("ctx"),
        }

        response = yield call_responder(
            Region(), MonitorExpired, params)
        self.assertIsNotNone(response)

        self.assertThat(
            handle_monitor_expired,
            MockCalledOnceWith(params['id'], params['context']))


class TestRegionProtocol_RequestNodeInforByMACAddress(TransactionTestCase):

    def test_request_node_info_by_mac_address_is_registered(self):
        protocol = Region()
        responder = protocol.locateResponder(
            RequestNodeInfoByMACAddress.commandName)
        self.assertIsNotNone(responder)

    @transactional
    def make_mac_address(self, node):
        return factory.make_MACAddress(node=node)

    @transactional
    def create_node(self):
        return factory.make_Node()

    @wait_for_reactor
    @inlineCallbacks
    def test_calls_request_node_info_by_mac_address_function(self):
        purpose = factory.make_name('purpose')
        node = yield deferToThread(self.create_node)
        node_info_function = self.patch(
            regionservice, 'request_node_info_by_mac_address')
        node_info_function.return_value = (node, purpose)
        mac_address = yield deferToThread(
            self.make_mac_address, node)

        params = {
            'mac_address': mac_address.mac_address.get_raw(),
        }

        response = yield call_responder(
            Region(), RequestNodeInfoByMACAddress, params)
        self.assertIsNotNone(response)
        self.assertThat(
            node_info_function,
            MockCalledOnceWith(params['mac_address']))
        response_purpose = response.pop('purpose')
        self.assertEqual(purpose, response_purpose)
        self.assertAttributes(node, response)

    @wait_for_reactor
    def test_request_node_info_by_mac_address_raises_if_unknown_mac(self):
        params = {
            'mac_address': factory.make_mac_address(),
        }

        response = yield call_responder(
            Region(), RequestNodeInfoByMACAddress, params)

        def check(error):
            self.assertIsInstance(error, Failure)
            self.assertIsInstance(error.value, NoSuchNode)

        yield response.addErrback(check)