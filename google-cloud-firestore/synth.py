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
    'firestore', 'v1',
    config_path='/google/firestore/artman_firestore_v1.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-firestore'
)
s.copy(v1_library / 'lib/google/cloud/firestore/v1')
s.copy(v1_library / 'lib/google/cloud/firestore/v1.rb')
s.copy(v1_library / 'lib/google/firestore/v1')
s.copy(v1_library / 'test/google/cloud/firestore/v1')

v1beta1_library = gapic.ruby_library(
    'firestore', 'v1beta1',
    config_path='/google/firestore/artman_firestore.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-firestore'
)
s.copy(v1beta1_library / 'lib/google/cloud/firestore/v1beta1')
s.copy(v1beta1_library / 'lib/google/cloud/firestore/v1beta1.rb')
s.copy(v1beta1_library / 'lib/google/firestore/v1beta1')
s.copy(v1beta1_library / 'test/google/cloud/firestore/v1beta1')

admin_v1_library = gapic.ruby_library(
    'firestore-admin', 'v1',
    config_path='/google/firestore/admin/artman_firestore_v1.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-firestore_admin'
)
s.copy(admin_v1_library / 'lib/google/cloud/firestore/admin.rb')
s.copy(admin_v1_library / 'lib/google/cloud/firestore/admin/v1')
s.copy(admin_v1_library / 'lib/google/cloud/firestore/admin/v1.rb')
s.copy(admin_v1_library / 'lib/google/firestore/admin/v1')
s.copy(admin_v1_library / 'test/google/cloud/firestore/admin/v1')

# PERMANENT: Handwritten layer owns Firestore.new so low-level clients need to
# use Firestore::V1beta1.new instead of Firestore.new(version: :v1beta1).
# Update the examples and tests.
s.replace(
    [
      'lib/google/cloud/firestore/v1beta1/firestore_client.rb',
      'test/google/cloud/firestore/v1beta1/firestore_client_test.rb'
    ],
    'require "google/cloud/firestore"',
    'require "google/cloud/firestore/v1beta1"')
s.replace(
    [
      'lib/google/cloud/firestore/v1beta1/firestore_client.rb',
      'test/google/cloud/firestore/v1beta1/firestore_client_test.rb'
    ],
    'Google::Cloud::Firestore\\.new\\(version: :v1beta1\\)',
    'Google::Cloud::Firestore::V1beta1.new')
s.replace(
    [
      'lib/google/cloud/firestore/v1/firestore_client.rb',
      'test/google/cloud/firestore/v1/firestore_client_test.rb'
    ],
    'require "google/cloud/firestore"',
    'require "google/cloud/firestore/v1"')
s.replace(
    [
      'lib/google/cloud/firestore/v1/firestore_client.rb',
      'test/google/cloud/firestore/v1/firestore_client_test.rb'
    ],
    'Google::Cloud::Firestore\\.new\\(version: :v1\\)',
    'Google::Cloud::Firestore::V1.new')
s.replace(
    [
      'lib/google/cloud/firestore/v1/firestore_admin_client.rb',
      'test/google/cloud/firestore/v1/firestore_admin_client_test.rb'
    ],
    'require "google/cloud/firestore"',
    'require "google/cloud/firestore/v1"')
s.replace(
    [
      'lib/google/cloud/firestore/v1/firestore_admin_client.rb',
      'test/google/cloud/firestore/v1/firestore_admin_client_test.rb'
    ],
    'Google::Cloud::Firestore\\.new\\(version: :v1\\)',
    'Google::Cloud::Firestore::V1::FirestoreAdminClient.new')

# Support for service_address
s.replace(
    [
        'lib/google/cloud/firestore/v*.rb',
        'lib/google/cloud/firestore/v*/*_client.rb',
        'lib/google/cloud/firestore/admin/v*.rb',
        'lib/google/cloud/firestore/admin/v*/*_client.rb'
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
        'lib/google/cloud/firestore/v*.rb',
        'lib/google/cloud/firestore/v*/*_client.rb',
        'lib/google/cloud/firestore/admin/v*.rb',
        'lib/google/cloud/firestore/admin/v*/*_client.rb'
    ],
    '\n(\\s+)metadata: nil,\n\\s+exception_transformer: nil,\n',
    '\n\\1metadata: nil,\n\\1service_address: nil,\n\\1service_port: nil,\n\\1exception_transformer: nil,\n'
)
s.replace(
    [
        'lib/google/cloud/firestore/v*.rb',
        'lib/google/cloud/firestore/v*/*_client.rb',
        'lib/google/cloud/firestore/admin/v*.rb',
        'lib/google/cloud/firestore/admin/v*/*_client.rb'
    ],
    ',\n(\\s+)lib_name: lib_name,\n\\s+lib_version: lib_version',
    ',\n\\1lib_name: lib_name,\n\\1service_address: service_address,\n\\1service_port: service_port,\n\\1lib_version: lib_version'
)
s.replace(
    [
        'lib/google/cloud/firestore/v*/*_client.rb',
        'lib/google/cloud/firestore/admin/v*/*_client.rb'
    ],
    'service_path = self\\.class::SERVICE_ADDRESS',
    'service_path = service_address || self.class::SERVICE_ADDRESS'
)
s.replace(
    [
        'lib/google/cloud/firestore/v*/*_client.rb',
        'lib/google/cloud/firestore/admin/v*/*_client.rb'
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
        'lib/google/cloud/firestore/v1*/**/*.rb',
        'lib/google/cloud/firestore/admin/v1*/**/*.rb'
    ],
    '\n\\s+#[^\n]*[^\n#\\$\\\\]\\{[\\w,]+\\}',
    escape_braces)

# https://github.com/googleapis/gapic-generator/issues/2243
s.replace(
    [
        'lib/google/cloud/firestore/v1*/*_client.rb',
        'lib/google/cloud/firestore/admin/v1*/*_client.rb'
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
for version in ['v1', 'v1beta1', 'admin/v1']:
    s.replace(
        f'lib/google/cloud/firestore/{version}/*_client.rb',
        f'(require \".*credentials\"\n)\n',
        f'\\1require "google/cloud/firestore/version"\n\n'
    )
    s.replace(
        f'lib/google/cloud/firestore/{version}/*_client.rb',
        'Gem.loaded_specs\[.*\]\.version\.version',
        'Google::Cloud::Firestore::VERSION'
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
    'https://googleapis.dev/ruby/google-cloud-firestore/latest/file.AUTHENTICATION.html'
)

# Mark v1beta1 client as deprecated
# https://github.com/googleapis/google-cloud-ruby/issues/5952
s.replace(
    'lib/google/cloud/firestore/v1beta1/firestore_client.rb',
    'module V1beta1',
    'module V1beta1\n        # @deprecated Use Google::Cloud::Firestore::V1::FirestoreClient instead.\n        #'
)
s.replace(
    'lib/google/cloud/firestore/v1beta1.rb',
    '^      ##$',
    '      ##\n      # @deprecated Use Google::Cloud::Firestore::V1 instead.\n      #'
)

# Fix product links
s.replace(
    [
        "lib/google/cloud/firestore/admin/v1.rb",
        "lib/google/cloud/firestore/admin.rb"
    ],
    "https://cloud.google.com/firestore-admin",
    "https://cloud.google.com/firestore/docs/reference/rpc"
)

# We recently added ruby_package proto options, but we want those to apply only
# when we move to the microgenerator. Undo their effect while the monolith is
# still in use.
s.replace(
    'lib/google/firestore/v1/*_pb.rb',
    '\nmodule Google::Cloud::Firestore::V1\n',
    '\nmodule Google\n  module Firestore\n  end\nend\nmodule Google::Firestore::V1\n',
)
s.replace(
    'lib/google/firestore/v1beta1/*_pb.rb',
    '\nmodule Google::Cloud::Firestore::V1beta1\n',
    '\nmodule Google\n  module Firestore\n  end\nend\nmodule Google::Firestore::V1beta1\n',
)
s.replace(
    'lib/google/firestore/admin/v1/*_pb.rb',
    '\nmodule Google::Cloud::Firestore::Admin::V1\n',
    '\nmodule Google\n  module Firestore\n    module Admin\n    end\n  end\nend\nmodule Google::Firestore::Admin::V1\n',
)
