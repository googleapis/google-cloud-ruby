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

AUTOSYNTH_MULTIPLE_COMMITS = True

logging.basicConfig(level=logging.DEBUG)

gapic = gcp.GAPICGenerator()

v1_library = gapic.ruby_library(
    'spanner', 'v1',
    config_path='/google/spanner/artman_spanner.legacy.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-spanner'
)
s.copy(v1_library / 'lib/google/cloud/spanner/v1')
s.copy(v1_library / 'lib/google/spanner/v1')
s.copy(v1_library / 'test/google/cloud/spanner/v1')

v1_database_library = gapic.ruby_library(
    'spanneradmindatabase', 'v1',
    config_path='/google/spanner/admin/database/artman_spanner_admin_database.legacy.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-spanner_admin_database')
s.copy(v1_database_library / 'lib/google/cloud/spanner/admin/database.rb')
s.copy(v1_database_library / 'lib/google/cloud/spanner/admin/database/v1.rb')
s.copy(v1_database_library / 'lib/google/cloud/spanner/admin/database/v1')
s.copy(v1_database_library / 'lib/google/spanner/admin/database/v1')
s.copy(v1_database_library / 'test/google/cloud/spanner/admin/database/v1')

v1_instance_library = gapic.ruby_library(
    'spanneradmininstance', 'v1',
    config_path='/google/spanner/admin/instance/artman_spanner_admin_instance.legacy.yaml',
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

# Support for service_address
s.replace(
    [
        'lib/google/cloud/spanner/v*/*_client.rb',
        'lib/google/cloud/spanner/admin/*/v*/*_client.rb'
    ],
    '\n(\\s+)#(\\s+)@param exception_transformer',
    '\n\\1#\\2@param service_address [String]\n' +
        '\\1#\\2  Override for the service hostname, or `nil` to leave as the default.\n' +
        '\\1#\\2@param service_port [Integer]\n' +
        '\\1#\\2  Override for the service port, or `nil` to leave as the default.\n' +
        '\\1#\\2@param exception_transformer'
)
s.replace(
    [
        'lib/google/cloud/spanner/v*/*_client.rb',
        'lib/google/cloud/spanner/admin/*/v*/*_client.rb'
    ],
    '\n(\\s+)metadata: nil,\n\\s+exception_transformer: nil,\n',
    '\n\\1metadata: nil,\n\\1service_address: nil,\n\\1service_port: nil,\n\\1exception_transformer: nil,\n'
)
s.replace(
    [
        'lib/google/cloud/spanner/v*/*_client.rb',
        'lib/google/cloud/spanner/admin/*/v*/*_client.rb'
    ],
    ',\n(\\s+)lib_name: lib_name,\n\\s+lib_version: lib_version',
    ',\n\\1service_address: service_address,\n\\1service_port: service_port,\n\\1lib_name: lib_name,\n\\1lib_version: lib_version'
)
s.replace(
    [
        'lib/google/cloud/spanner/v*/*_client.rb',
        'lib/google/cloud/spanner/admin/*/v*/*_client.rb'
    ],
    'service_path = self\\.class::SERVICE_ADDRESS',
    'service_path = service_address || self.class::SERVICE_ADDRESS'
)
s.replace(
    [
        'lib/google/cloud/spanner/v*/*_client.rb',
        'lib/google/cloud/spanner/admin/*/v*/*_client.rb'
    ],
    'port = self\\.class::DEFAULT_SERVICE_PORT',
    'port = service_port || self.class::DEFAULT_SERVICE_PORT'
)

# Remove legacy release level from documentation
s.replace(
    'lib/google/cloud/**/*.rb',
    '\\s+\\(\\[\\w+\\]\\(https://github\\.com/(googleapis|GoogleCloudPlatform)/google-cloud-ruby#versioning\\)\\)',
    ''
)

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
    expr = re.compile('^([^`]*(`[^`]*`[^`]*)*)([^`#\\$\\\\])\\{([\\w,]+)\\}')
    content = match.group(0)
    while True:
        content, count = expr.subn('\\1\\3\\\\\\\\{\\4}', content)
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

# https://github.com/googleapis/gapic-generator/issues/2279
s.replace(
    'lib/**/*.rb',
    '\\A(((#[^\n]*)?\n)*# (Copyright \\d+|Generated by the protocol buffer compiler)[^\n]+\n(#[^\n]*\n)*\n)([^\n])',
    '\\1\n\\6')

# https://github.com/googleapis/gapic-generator/issues/2323
s.replace(
    'lib/**/*.rb',
    'https://github\\.com/GoogleCloudPlatform/google-cloud-ruby',
    'https://github.com/googleapis/google-cloud-ruby'
)
s.replace(
    'lib/**/*.rb',
    'https://googlecloudplatform\\.github\\.io/google-cloud-ruby',
    'https://googleapis.github.io/google-cloud-ruby'
)

# https://github.com/googleapis/google-cloud-ruby/issues/3058
s.replace(
    'lib/google/cloud/spanner/admin/database/v1/*_admin_client.rb',
    '(require \".*credentials\"\n)\n',
    '\\1require "google/cloud/spanner/version"\n\n'
)
s.replace(
    'lib/google/cloud/spanner/admin/database/v1/*_admin_client.rb',
    'Gem.loaded_specs\[.*\]\.version\.version',
    'Google::Cloud::Spanner::VERSION'
)
s.replace(
    'lib/google/cloud/spanner/admin/instance/v1/*_admin_client.rb',
    '(require \".*credentials\"\n)\n',
    '\\1require "google/cloud/spanner/version"\n\n'
)
s.replace(
    'lib/google/cloud/spanner/admin/instance/v1/*_admin_client.rb',
    'Gem.loaded_specs\[.*\]\.version\.version',
    'Google::Cloud::Spanner::VERSION'
)
s.replace(
    'lib/google/cloud/spanner/v1/spanner_client.rb',
    '(require \".*credentials\"\n)\n',
    '\\1require "google/cloud/spanner/version"\n\n'
)
s.replace(
    'lib/google/cloud/spanner/v1/spanner_client.rb',
    'Gem.loaded_specs\[.*\]\.version\.version',
    'Google::Cloud::Spanner::VERSION'
)

# Fix links for devsite migration
s.replace(
    'lib/**/*.rb',
    'https://googleapis.github.io/google-cloud-ruby/#/docs/google-cloud-logging/latest/google/cloud/logging/logger',
    'https://googleapis.dev/ruby/google-cloud-logging/latest'
)
s.replace(
    'lib/**/*.rb',
    'https://googleapis.github.io/google-cloud-ruby/#/docs/.*/authentication',
    'https://googleapis.dev/ruby/google-cloud-spanner/latest/file.AUTHENTICATION.html'
)

# We recently added ruby_package proto options, but we want those to apply only
# when we move to the microgenerator. Undo their effect while the monolith is
# still in use.
s.replace(
    'lib/google/spanner/v1/*_pb.rb',
    '\nmodule Google::Cloud::Spanner::V1\n',
    '\nmodule Google\n  module Spanner\n  end\nend\nmodule Google::Spanner::V1\n',
)
s.replace(
    'lib/google/spanner/admin/database/v1/*_pb.rb',
    '\nmodule Google::Cloud::Spanner::Admin::Database::V1\n',
    '\nmodule Google\n  module Spanner\n    module Admin\n      module Database\n      end\n    end\n  end\nend\nmodule Google::Spanner::Admin::Database::V1\n',
)
s.replace(
    'lib/google/spanner/admin/instance/v1/*_pb.rb',
    '\nmodule Google::Cloud::Spanner::Admin::Instance::V1\n',
    '\nmodule Google\n  module Spanner\n    module Admin\n      module Instance\n      end\n    end\n  end\nend\nmodule Google::Spanner::Admin::Instance::V1\n',
)
