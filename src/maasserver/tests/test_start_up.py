# Copyright 2012-2014 Canonical Ltd.  This software is licensed under the
# GNU Affero General Public License version 3 (see the file LICENSE).

"""Test the start up utility."""

from __future__ import (
    absolute_import,
    print_function,
    unicode_literals,
    )

str = None

__metaclass__ = type
__all__ = []

from maasserver import (
    eventloop,
    locks,
    start_up,
    )
from maasserver.models import (
    BootSource,
    NodeGroup,
    )
from maasserver.testing.eventloop import RegionEventLoopFixture
from maasserver.testing.testcase import MAASServerTestCase
from maastesting.fakemethod import FakeMethod
from maastesting.matchers import MockCalledOnceWith
from testtools.matchers import HasLength


class LockChecker:
    """Callable.  Records calls, and whether the startup lock was held."""

    def __init__(self, lock_file=None):
        self.call_count = 0
        self.lock_was_held = None

    def __call__(self):
        self.call_count += 1
        self.lock_was_held = locks.startup.is_locked()


class TestStartUp(MAASServerTestCase):
    """Tests for the `start_up` function.

    The actual work happens in `inner_start_up` and `test_start_up`; the tests
    you see here are for the locking wrapper only.
    """

    def setUp(self):
        super(TestStartUp, self).setUp()
        self.useFixture(RegionEventLoopFixture())
        self.patch(start_up, 'create_gnupg_home')

    def tearDown(self):
        super(TestStartUp, self).tearDown()
        # start_up starts the Twisted event loop, so we need to stop it.
        eventloop.reset().wait(5)

    def test_start_up_runs_in_exclusion(self):
        lock_checker = LockChecker()
        self.patch(start_up, 'inner_start_up', lock_checker)
        start_up.start_up()
        self.assertEqual(1, lock_checker.call_count)
        self.assertEqual(True, lock_checker.lock_was_held)


class TestInnerStartUp(MAASServerTestCase):
    """Tests for the actual work done in `inner_start_up`."""

    def setUp(self):
        super(TestInnerStartUp, self).setUp()
        self.mock_create_gnupg_home = self.patch(
            start_up, 'create_gnupg_home')

    def test__calls_write_full_dns_config(self):
        recorder = FakeMethod()
        self.patch(start_up, 'write_full_dns_config', recorder)
        start_up.inner_start_up()
        self.assertEqual(
            (1, [()]),
            (recorder.call_count, recorder.extract_args()))

    def test__creates_master_nodegroup(self):
        start_up.inner_start_up()
        clusters = NodeGroup.objects.all()
        self.assertThat(clusters, HasLength(1))
        self.assertItemsEqual([NodeGroup.objects.ensure_master()], clusters)

    def test__calls_create_gnupg_home(self):
        start_up.inner_start_up()
        self.assertThat(self.mock_create_gnupg_home, MockCalledOnceWith())

    def test__initialises_boot_source_config(self):
        self.assertItemsEqual([], BootSource.objects.all())
        start_up.inner_start_up()
        self.assertThat(BootSource.objects.all(), HasLength(1))