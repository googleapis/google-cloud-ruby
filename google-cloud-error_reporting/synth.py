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

v1beta1_library = gapic.ruby_library(
    'errorreporting', 'v1beta1',
    config_path='/google/devtools/clouderrorreporting/artman_errorreporting.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-error_reporting'
)
s.copy(v1beta1_library / 'lib/google/cloud/error_reporting/v1beta1')
s.copy(v1beta1_library / 'lib/google/devtools/clouderrorreporting/v1beta1')

# Omitting lib/google/cloud/error_reporting/v1beta1.rb for now because we are
# not exposing the low-level API.

# PERMANENT: We don't want the generated overview.rb file because we have our
# own toplevel docs for the handwritten layer.
os.remove('lib/google/cloud/error_reporting/v1beta1/doc/overview.rb')

# https://github.com/googleapis/gapic-generator/issues/2242
def escape_braces(match):
    expr = re.compile('([^#\\$\\\\])\\{([\\w,]+)\\}')
    content = match.group(0)
    while True:
        content, count = expr.subn('\\1\\\\\\\\{\\2}', content)
        if count == 0:
            return content
s.replace(
    'lib/google/cloud/error_reporting/v1beta1/**/*.rb',
    '\n(\\s+)#[^\n]*[^\n#\\$\\\\]\\{[\\w,]+\\}',
    escape_braces)

# https://github.com/googleapis/gapic-generator/issues/2243
s.replace(
    'lib/google/cloud/error_reporting/v1beta1/*_client.rb',
    '(\n\\s+class \\w+Client\n)(\\s+)(attr_reader :\\w+_stub)',
    '\\1\\2# @private\n\\2\\3')
