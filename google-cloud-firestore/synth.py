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

v1beta1_library = gapic.ruby_library(
    'firestore', 'v1beta1',
    config_path='/google/firestore/artman_firestore.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-firestore'
)
s.copy(v1beta1_library / 'lib/google/cloud/firestore/v1beta1')
s.copy(v1beta1_library / 'lib/google/cloud/firestore/v1beta1.rb')
s.copy(v1beta1_library / 'lib/google/firestore/v1beta1')
s.copy(v1beta1_library / 'test/google/cloud/firestore/v1beta1')

# PERMANENT: We don't want the generated overview.rb file because we have our
# own toplevel docs for the handwritten layer.
os.remove('lib/google/cloud/firestore/v1beta1/doc/overview.rb')

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

# https://github.com/googleapis/gapic-generator/issues/2182
s.replace(
    'lib/google/cloud/firestore/v1beta1/credentials.rb',
    'FIRESTORE_KEYFILE\\n(\s+)FIRESTORE_CREDENTIALS\n',
    'FIRESTORE_CREDENTIALS\\n\\1FIRESTORE_KEYFILE\n')
s.replace(
    'lib/google/cloud/firestore/v1beta1/credentials.rb',
    'FIRESTORE_KEYFILE_JSON\\n(\s+)FIRESTORE_CREDENTIALS_JSON\n',
    'FIRESTORE_CREDENTIALS_JSON\\n\\1FIRESTORE_KEYFILE_JSON\n')

# https://github.com/googleapis/gapic-generator/issues/2195
s.replace(
    'lib/google/cloud/firestore/v1beta1.rb',
    '\\(https://console\\.cloud\\.google\\.com/apis/api/firestore\\)',
    '(https://console.cloud.google.com/apis/library/firestore.googleapis.com)')
