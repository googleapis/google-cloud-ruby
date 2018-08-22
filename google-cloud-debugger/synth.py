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
import re

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
s.copy(v2_library / 'test/google/cloud/debugger/v2')

# PERMANENT: We don't want the generated overview.rb file because we have our
# own toplevel docs for the handwritten layer.
os.remove('lib/google/cloud/debugger/v2/doc/overview.rb')

# PERMANENT: Handwritten layer owns Debugger.new so low-level clients need to
# use Debugger::V2.new instead of Debugger.new(version: :v2). Update the
# examples and tests.
s.replace(
    [
      'lib/google/cloud/debugger/v2/controller2_client.rb',
      'lib/google/cloud/debugger/v2/debugger2_client.rb',
      'test/google/cloud/debugger/v2/controller2_client_test.rb',
      'test/google/cloud/debugger/v2/debugger2_client_test.rb'
    ],
    'require "google/cloud/debugger"',
    'require "google/cloud/debugger/v2"')
s.replace(
    [
      'lib/google/cloud/debugger/v2/controller2_client.rb',
      'test/google/cloud/debugger/v2/controller2_client_test.rb'
    ],
    'Google::Cloud::Debugger::Controller2\\.new\\(version: :v2\\)',
    'Google::Cloud::Debugger::V2::Controller2.new')
s.replace(
    [
      'lib/google/cloud/debugger/v2/debugger2_client.rb',
      'test/google/cloud/debugger/v2/debugger2_client_test.rb'
    ],
    'Google::Cloud::Debugger::Debugger2\\.new\\(version: :v2\\)',
    'Google::Cloud::Debugger::V2::Debugger2.new')

# PERMANENT: API name for clouddebugger
s.replace(
    'lib/google/cloud/debugger/v2.rb',
    '/debugger\\.googleapis\\.com', '/clouddebugger.googleapis.com')

# https://github.com/googleapis/gapic-generator/issues/2242
def escape_braces(match):
    expr = re.compile('([^#\\$\\\\])\\{([\\w,]+)\\}')
    content = match.group(0)
    while True:
        content, count = expr.subn('\\1\\\\\\\\{\\2}', content)
        if count == 0:
            return content
s.replace(
    'lib/google/cloud/debugger/v2/**/*.rb',
    '\n(\\s+)#[^\n]*[^\n#\\$\\\\]\\{[\\w,]+\\}',
    escape_braces)
