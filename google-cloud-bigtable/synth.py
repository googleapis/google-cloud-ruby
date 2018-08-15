# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""This script is used to synthesize generated parts of this library."""

import synthtool as s
import synthtool.gcp as gcp
import logging
import os

logging.basicConfig(level=logging.DEBUG)

gapic = gcp.GAPICGenerator()

v2_library = gapic.ruby_library(
    'bigtable', 'v2', config_path='/google/bigtable/artman_bigtable.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-bigtable'
)
s.copy(v2_library / 'lib/google/cloud/bigtable/v2')
s.copy(v2_library / 'lib/google/cloud/bigtable/v2.rb')
s.copy(v2_library / 'lib/google/bigtable/v2')
s.copy(v2_library / 'test/google/cloud/bigtable/v2')

v2_admin_library = gapic.ruby_library(
    'bigtableadmin', 'v2',
    config_path='/google/bigtable/admin/artman_bigtableadmin.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-bigtable_admin'
)
s.copy(v2_admin_library / 'lib/google/cloud/bigtable/admin/v2')
s.copy(v2_admin_library / 'lib/google/cloud/bigtable/admin/v2.rb')
s.copy(v2_admin_library / 'lib/google/cloud/bigtable/admin.rb')
s.copy(v2_admin_library / 'lib/google/bigtable/admin/v2')
s.copy(v2_admin_library / 'test/google/cloud/bigtable/admin/v2')

# PERMANENT: We don't want the generated overview.rb filesbecause we have our
# own toplevel docs for the handwritten layer.
os.remove('lib/google/cloud/bigtable/v2/doc/overview.rb')
os.remove('lib/google/cloud/bigtable/admin/v2/doc/overview.rb')

# PERMANENT: We're combining bigtable and bigtable-admin into one gem.
s.replace(
    [
      'lib/google/cloud/bigtable/admin/v2/bigtable_instance_admin_client.rb',
      'lib/google/cloud/bigtable/admin/v2/bigtable_table_admin_client.rb'
    ],
    "Gem.loaded_specs\\['google-cloud-bigtable-admin'\\]",
    "Gem.loaded_specs['google-cloud-bigtable']")

# PERMANENT: Handwritten layer owns Bigtable.new so low-level clients need to
# use Bigtable::V2.new instead of Bigtable.new(version: :v2). Update the
# examples and tests.
s.replace(
    [
      'lib/google/cloud/bigtable/v2/bigtable_client.rb',
      'test/google/cloud/bigtable/v2/bigtable_client_test.rb'
    ],
    'require "google/cloud/bigtable"',
    'require "google/cloud/bigtable/v2"')
s.replace(
    [
      'lib/google/cloud/bigtable/v2/bigtable_client.rb',
      'test/google/cloud/bigtable/v2/bigtable_client_test.rb'
    ],
    'Google::Cloud::Bigtable\\.new\\(version: :v2\\)',
    'Google::Cloud::Bigtable::V2.new')

# PERMANENT: API name for bigtableadmin
s.replace(
    [
      'lib/google/cloud/bigtable/admin.rb',
      'lib/google/cloud/bigtable/admin/v2.rb',
    ],
    '/bigtable-admin\\.googleapis\\.com', '/bigtableadmin.googleapis.com')
