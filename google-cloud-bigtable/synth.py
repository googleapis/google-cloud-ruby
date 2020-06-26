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
    config_path='/google/bigtable/admin/artman_bigtableadmin.legacy.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-bigtable_admin'
)
s.copy(v2_admin_library / 'lib/google/cloud/bigtable/admin/v2')
s.copy(v2_admin_library / 'lib/google/cloud/bigtable/admin/v2.rb')
s.copy(v2_admin_library / 'lib/google/cloud/bigtable/admin.rb')
s.copy(v2_admin_library / 'lib/google/bigtable/admin/v2')
s.copy(v2_admin_library / 'test/google/cloud/bigtable/admin/v2')

# Support for service_address
s.replace(
    [
        'lib/google/cloud/bigtable/v*.rb',
        'lib/google/cloud/bigtable/v*/*_client.rb',
        'lib/google/cloud/bigtable/admin/v*.rb',
        'lib/google/cloud/bigtable/admin/v*/*_client.rb'
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
        'lib/google/cloud/bigtable/v*.rb',
        'lib/google/cloud/bigtable/v*/*_client.rb',
        'lib/google/cloud/bigtable/admin/v*.rb',
        'lib/google/cloud/bigtable/admin/v*/*_client.rb'
    ],
    '\n(\\s+)metadata: nil,\n\\s+exception_transformer: nil,\n',
    '\n\\1metadata: nil,\n\\1service_address: nil,\n\\1service_port: nil,\n\\1exception_transformer: nil,\n'
)
s.replace(
    [
        'lib/google/cloud/bigtable/v*.rb',
        'lib/google/cloud/bigtable/v*/*_client.rb',
        'lib/google/cloud/bigtable/admin/v*.rb',
        'lib/google/cloud/bigtable/admin/v*/*_client.rb'
    ],
    ',\n(\\s+)lib_name: lib_name,\n\\s+lib_version: lib_version',
    ',\n\\1lib_name: lib_name,\n\\1service_address: service_address,\n\\1service_port: service_port,\n\\1lib_version: lib_version'
)
s.replace(
    [
        'lib/google/cloud/bigtable/v*/*_client.rb',
        'lib/google/cloud/bigtable/admin/v*/*_client.rb'
    ],
    'service_path = self\\.class::SERVICE_ADDRESS',
    'service_path = service_address || self.class::SERVICE_ADDRESS'
)
s.replace(
    [
        'lib/google/cloud/bigtable/v*/*_client.rb',
        'lib/google/cloud/bigtable/admin/v*/*_client.rb'
    ],
    'port = self\\.class::DEFAULT_SERVICE_PORT',
    'port = service_port || self.class::DEFAULT_SERVICE_PORT'
)

# PERMANENT: We're combining bigtable and bigtable-admin into one gem.
s.replace(
    [
      'lib/google/cloud/bigtable/admin/v2/bigtable_instance_admin_client.rb',
      'lib/google/cloud/bigtable/admin/v2/bigtable_table_admin_client.rb'
    ],
    "Gem.loaded_specs\\['google-cloud-bigtable-admin'\\]",
    "Gem.loaded_specs['google-cloud-bigtable']")
s.replace(
    [
      'lib/google/cloud/bigtable/admin.rb',
      'lib/google/cloud/bigtable/admin/v2.rb'
    ],
    '# \\$ gem install google-cloud-bigtable-admin',
    '# $ gem install google-cloud-bigtable')

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

# Fix for tests that assume protos implement to_hash
s.replace(
    'test/google/cloud/bigtable/admin/v2/bigtable_instance_admin_client_test.rb',
    'assert_equal\\(clusters, request\\.clusters\\)',
    'assert_equal(clusters, request.clusters.to_h)'
)
s.replace(
    'test/google/cloud/bigtable/admin/v2/bigtable_instance_admin_client_test.rb',
    'assert_equal\\(labels, request\\.labels\\)',
    'assert_equal(labels, request.labels.to_h)'
)

# Remove legacy release level from documentation
s.replace(
    'lib/google/cloud/**/*.rb',
    '\\s+\\(\\[\\w+\\]\\(https://github\\.com/(googleapis|GoogleCloudPlatform)/google-cloud-ruby#versioning\\)\\)',
    ''
)

# https://github.com/googleapis/gapic-generator/issues/2232
s.replace(
    [
      'lib/google/cloud/bigtable/admin/v2/bigtable_instance_admin_client.rb',
      'lib/google/cloud/bigtable/admin/v2/bigtable_table_admin_client.rb'
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
    'lib/google/cloud/bigtable/admin/v2/**/*.rb',
    '\n(\\s+)#[^\n]*[^\n#\\$\\\\]\\{[\\w,]+\\}',
    escape_braces)

# https://github.com/googleapis/gapic-generator/issues/2243
s.replace(
    [
      'lib/google/cloud/bigtable/v2/*_client.rb',
      'lib/google/cloud/bigtable/admin/v2/*_client.rb'
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
    'lib/google/cloud/bigtable/admin/v2/bigtable_*_admin_client.rb',
    '(require \".*credentials\"\n)\n',
    '\\1require "google/cloud/bigtable/version"\n\n'
)
s.replace(
    'lib/google/cloud/bigtable/admin/v2/bigtable_*_admin_client.rb',
    'Gem.loaded_specs\[.*\]\.version\.version',
    'Google::Cloud::Bigtable::VERSION'
)
s.replace(
    'lib/google/cloud/bigtable/v2/bigtable_client.rb',
    '(require \".*credentials\"\n)\n',
    '\\1require "google/cloud/bigtable/version"\n\n'
)
s.replace(
    'lib/google/cloud/bigtable/v2/bigtable_client.rb',
    'Gem.loaded_specs\[.*\]\.version\.version',
    'Google::Cloud::Bigtable::VERSION'
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
    'https://googleapis.dev/ruby/google-cloud-bigtable/latest/file.AUTHENTICATION.html'
)

# Fix product links
s.replace(
    [
        "lib/google/cloud/bigtable/admin/v2.rb",
        "lib/google/cloud/bigtable/admin.rb"
    ],
    "https://cloud.google.com/bigtable-admin",
    "https://cloud.google.com/bigtable/docs/reference/admin/rpc"
)

# We recently added ruby_package proto options, but we want those to apply only
# when we move to the microgenerator. Undo their effect while the monolith is
# still in use.
s.replace(
    'lib/google/bigtable/v2/*_pb.rb',
    '\nmodule Google::Cloud::Bigtable::V2\n',
    '\nmodule Google\n  module Bigtable\n  end\nend\nmodule Google::Bigtable::V2\n',
)
s.replace(
    'lib/google/bigtable/admin/v2/*_pb.rb',
    '\nmodule Google::Cloud::Bigtable::Admin::V2\n',
    '\nmodule Google\n  module Bigtable\n    module Admin\n    end\n  end\nend\nmodule Google::Bigtable::Admin::V2\n',
)
