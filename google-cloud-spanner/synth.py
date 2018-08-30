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
import re

logging.basicConfig(level=logging.DEBUG)

gapic = gcp.GAPICGenerator()

v1_library = gapic.ruby_library(
    'spanner', 'v1',
    config_path='/google/spanner/artman_spanner.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-spanner'
)
s.copy(v1_library / 'lib/google/cloud/spanner/v1')
s.copy(v1_library / 'lib/google/spanner/v1')
s.copy(v1_library / 'test/google/cloud/spanner/v1')

v1_database_library = gapic.ruby_library(
    'spanneradmindatabase', 'v1',
    config_path='/google/spanner/admin/database/artman_spanner_admin_database.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-spanner_admin_database')
s.copy(v1_database_library / 'lib/google/cloud/spanner/admin/database.rb')
s.copy(v1_database_library / 'lib/google/cloud/spanner/admin/database/v1.rb')
s.copy(v1_database_library / 'lib/google/cloud/spanner/admin/database/v1')
s.copy(v1_database_library / 'lib/google/spanner/admin/database/v1')
s.copy(v1_database_library / 'test/google/cloud/spanner/admin/database/v1')

v1_instance_library = gapic.ruby_library(
    'spanneradmininstance', 'v1',
    config_path='/google/spanner/admin/instance/artman_spanner_admin_instance.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-spanner_admin_instance')
s.copy(v1_instance_library / 'lib/google/cloud/spanner/admin/instance.rb')
s.copy(v1_instance_library / 'lib/google/cloud/spanner/admin/instance/v1.rb')
s.copy(v1_instance_library / 'lib/google/cloud/spanner/admin/instance/v1')
s.copy(v1_instance_library / 'lib/google/spanner/admin/instance/v1')
s.copy(v1_instance_library / 'test/google/cloud/spanner/admin/instance/v1')

# Omitting lib/google/cloud/spanner/v1.rb for now because we are not exposing
# the low-level API.

# PERMANENT: We're combining three APIs into one gem.
s.replace(
    [
      'lib/google/cloud/spanner/admin/database/v1/database_admin_client.rb',
      'lib/google/cloud/spanner/admin/instance/v1/instance_admin_client.rb',
    ],
    "Gem.loaded_specs\\['google-cloud-spanner-admin-\\w+'\\]",
    "Gem.loaded_specs['google-cloud-spanner']")
s.replace(
    [
      'lib/google/cloud/spanner/admin/database.rb',
      'lib/google/cloud/spanner/admin/database/v1.rb',
      'lib/google/cloud/spanner/admin/instance.rb',
      'lib/google/cloud/spanner/admin/instance/v1.rb'
    ],
    '# \\$ gem install google-cloud-spanner-admin-\\w+',
    '# $ gem install google-cloud-spanner')

# PERMANENT: Handwritten layer owns Spanner.new so low-level clients need to
# use Spanner::V1.new instead of Spanner.new(version: :v1). Update the
# examples and tests.
s.replace(
    [
      'lib/google/cloud/spanner/v1/spanner_client.rb',
      'test/google/cloud/spanner/v1/spanner_client_test.rb'
    ],
    'require "google/cloud/spanner"',
    'require "google/cloud/spanner/v1"')
s.replace(
    [
      'lib/google/cloud/spanner/v1/spanner_client.rb',
      'test/google/cloud/spanner/v1/spanner_client_test.rb'
    ],
    'Google::Cloud::Spanner\\.new\\(version: :v1\\)',
    'Google::Cloud::Spanner::V1::SpannerClient.new')

# PERMANENT: API names for admin APIs
s.replace(
    [
      'lib/google/cloud/spanner/admin/database.rb',
      'lib/google/cloud/spanner/admin/database/v1.rb',
      'lib/google/cloud/spanner/admin/instance.rb',
      'lib/google/cloud/spanner/admin/instance/v1.rb'
    ],
    '/spanner-admin-\\w+\\.googleapis\\.com', '/spanner.googleapis.com')

# https://github.com/googleapis/gapic-generator/issues/2196
s.replace(
    [
      'lib/google/cloud/spanner/admin/database.rb',
      'lib/google/cloud/spanner/admin/database/v1.rb',
      'lib/google/cloud/spanner/admin/instance.rb',
      'lib/google/cloud/spanner/admin/instance/v1.rb'
    ],
    '\\[Product Documentation\\]: https://cloud\\.google\\.com/spanner-admin-\\w+\n',
    '[Product Documentation]: https://cloud.google.com/spanner\n')

# https://github.com/googleapis/gapic-generator/issues/2232
s.replace(
    [
      'lib/google/cloud/spanner/admin/database/v1/database_admin_client.rb',
      'lib/google/cloud/spanner/admin/instance/v1/instance_admin_client.rb'
    ],
    '\n\n(\\s+)class OperationsClient < Google::Longrunning::OperationsClient',
    '\n\n\\1# @private\n\\1class OperationsClient < Google::Longrunning::OperationsClient')

# https://github.com/googleapis/gapic-generator/issues/2242
def escape_braces(match):
    expr = re.compile('([^#\\$\\\\])\\{([\\w,]+)\\}')
    content = match.group(0)
    while True:
        content, count = expr.subn('\\1\\\\\\\\{\\2}', content)
        if count == 0:
            return content
s.replace(
    [
      'lib/google/cloud/spanner/v1/**/*.rb',
      'lib/google/cloud/spanner/admin/**/*.rb'
    ],
    '\n(\\s+)#[^\n]*[^\n#\\$\\\\]\\{[\\w,]+\\}',
    escape_braces)

# https://github.com/googleapis/gapic-generator/issues/2243
s.replace(
    [
      'lib/google/cloud/spanner/v1/*_client.rb',
      'lib/google/cloud/spanner/admin/*/v1/*_client.rb'
    ],
    '(\n\\s+class \\w+Client\n)(\\s+)(attr_reader :\\w+_stub)',
    '\\1\\2# @private\n\\2\\3')
