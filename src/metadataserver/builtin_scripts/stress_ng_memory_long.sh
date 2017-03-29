#!/bin/sh -e
#
# stress_ng_memory_long - Run stress-ng memory tests over 12 hours.
#
# Author: Lee Trager <lee.trager@canonical.com>
#
# Copyright (C) 2017 Canonical
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

sudo apt-get install -q -y stress-ng

sudo stress-ng \
     --aggressive -a 0 --class memory --ignite-cpu --log-brief --metrics \
     --times --tz --verify --timeout 12h