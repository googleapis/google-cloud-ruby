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

v1_library = gapic.ruby_library(
    'spanner', 'v1',
    config_path='/google/spanner/artman_spanner.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-spanner'
)
s.copy(v1_library / 'lib/google/cloud/spanner/v1')
s.copy(v1_library / 'lib/google/spanner/v1')

# Omitting lib/google/cloud/spanner/v1.rb for now because we are not exposing
# the low-level API.

# PERMANENT: We don't want the generated overview.rb file because we have our
# own toplevel docs for the handwritten layer.
os.remove('lib/google/cloud/spanner/v1/doc/overview.rb')

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
