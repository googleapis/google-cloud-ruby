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

v1_library = gapic.ruby_library(
    'trace', 'v1',
    config_path='/google/devtools/cloudtrace/artman_cloudtrace_v1.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-trace'
)
s.copy(v1_library / 'lib/google/cloud/trace/v1')
s.copy(v1_library / 'lib/google/devtools/cloudtrace/v1')

# Omitting lib/google/cloud/trace/v1.rb for now because we are not exposing the
# low-level API.

# PERMANENT: We don't want the generated overview.rb file because we have our
# own toplevel docs for the handwritten layer.
os.remove('lib/google/cloud/trace/v1/doc/overview.rb')

# https://github.com/googleapis/gapic-generator/issues/2124
s.replace(
    'lib/google/cloud/trace/v1/credentials.rb',
    'SCOPE = \[[^\]]+\]\.freeze',
    'SCOPE = ["https://www.googleapis.com/auth/cloud-platform"].freeze')

# https://github.com/googleapis/gapic-generator/issues/2182
s.replace(
    'lib/google/cloud/trace/v1/credentials.rb',
    'TRACE_KEYFILE\\n(\s+)TRACE_CREDENTIALS\n',
    'TRACE_CREDENTIALS\\n\\1TRACE_KEYFILE\n')
s.replace(
    'lib/google/cloud/trace/v1/credentials.rb',
    'TRACE_KEYFILE_JSON\\n(\s+)TRACE_CREDENTIALS_JSON\n',
    'TRACE_CREDENTIALS_JSON\\n\\1TRACE_KEYFILE_JSON\n')

v2_library = gapic.ruby_library(
    'trace', 'v2',
    config_path='/google/devtools/cloudtrace/artman_cloudtrace_v2.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-trace'
)
s.copy(v2_library / 'lib/google/cloud/trace/v2')
s.copy(v2_library / 'lib/google/devtools/cloudtrace/v2')

# Omitting lib/google/cloud/trace/v2.rb for now because we are not exposing the
# low-level API.

# PERMANENT: We don't want the generated overview.rb file because we have our
# own toplevel docs for the handwritten layer.
os.remove('lib/google/cloud/trace/v2/doc/overview.rb')

# https://github.com/googleapis/gapic-generator/issues/2124
s.replace(
    'lib/google/cloud/trace/v2/credentials.rb',
    'SCOPE = \[[^\]]+\]\.freeze',
    'SCOPE = ["https://www.googleapis.com/auth/cloud-platform"].freeze')

# https://github.com/googleapis/gapic-generator/issues/2182
s.replace(
    'lib/google/cloud/trace/v2/credentials.rb',
    'TRACE_KEYFILE\\n(\s+)TRACE_CREDENTIALS\n',
    'TRACE_CREDENTIALS\\n\\1TRACE_KEYFILE\n')
s.replace(
    'lib/google/cloud/trace/v2/credentials.rb',
    'TRACE_KEYFILE_JSON\\n(\s+)TRACE_CREDENTIALS_JSON\n',
    'TRACE_CREDENTIALS_JSON\\n\\1TRACE_KEYFILE_JSON\n')
