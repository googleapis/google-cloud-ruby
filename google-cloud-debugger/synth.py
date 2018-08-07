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
    'debugger', 'v2',
    config_path='/google/devtools/artman_clouddebugger.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-debugger'
)
s.copy(v2_library / 'lib/google/cloud/debugger/v2')
s.copy(v2_library / 'lib/google/cloud/debugger/v2.rb')
s.copy(v2_library / 'lib/google/devtools')

# PERMANENT: We don't want the generated overview.rb file because we have our
# own toplevel docs for the handwritten layer.
os.remove('lib/google/cloud/debugger/v2/doc/overview.rb')

# https://github.com/googleapis/gapic-generator/issues/2182
s.replace(
    'lib/google/cloud/debugger/v2/credentials.rb',
    'DEBUGGER_KEYFILE\\n(\s+)DEBUGGER_CREDENTIALS\n',
    'DEBUGGER_CREDENTIALS\\n\\1DEBUGGER_KEYFILE\n')
s.replace(
    'lib/google/cloud/debugger/v2/credentials.rb',
    'DEBUGGER_KEYFILE_JSON\\n(\s+)DEBUGGER_CREDENTIALS_JSON\n',
    'DEBUGGER_CREDENTIALS_JSON\\n\\1DEBUGGER_KEYFILE_JSON\n')

# https://github.com/googleapis/gapic-generator/issues/2195
s.replace(
    'lib/google/cloud/debugger/v2.rb',
    '\\(https://console\\.cloud\\.google\\.com/apis/api/debugger\\)',
    '(https://console.cloud.google.com/apis/library/clouddebugger.googleapis.com)')
