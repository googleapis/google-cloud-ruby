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

logging.basicConfig(level=logging.DEBUG)

gapic = gcp.GAPICGenerator()

v2_library = gapic.ruby_library(
    'logging', 'v2',
    config_path='/google/logging/artman_logging.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-logging'
)
s.copy(v2_library / 'lib/google/cloud/logging/v2')
s.copy(v2_library / 'lib/google/logging/v2')

# Omitting lib/google/cloud/logging/v2.rb for now because we are not exposing
# the low-level API.

# https://github.com/googleapis/gapic-generator/issues/2182
s.replace(
    'lib/google/cloud/logging/v2/credentials.rb',
    'LOGGING_KEYFILE\\n(\s+)LOGGING_CREDENTIALS\n',
    'LOGGING_CREDENTIALS\\n\\1LOGGING_KEYFILE\n')
s.replace(
    'lib/google/cloud/logging/v2/credentials.rb',
    'LOGGING_KEYFILE_JSON\\n(\s+)LOGGING_CREDENTIALS_JSON\n',
    'LOGGING_CREDENTIALS_JSON\\n\\1LOGGING_KEYFILE_JSON\n')
