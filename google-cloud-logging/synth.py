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
    'logging', 'v2',
    config_path='/google/logging/artman_logging.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-logging'
)
s.copy(v2_library / 'lib/google/cloud/logging/v2')
s.copy(v2_library / 'lib/google/logging/v2')

# Omitting lib/google/cloud/logging/v2.rb for now because we are not exposing
# the low-level API.

# PERMANENT: We don't want the generated overview.rb file because we have our
# own toplevel docs for the handwritten layer.
os.remove('lib/google/cloud/logging/v2/doc/overview.rb')

# PERMANENT: Handwritten layer owns Logging.new so low-level clients need to
# use Logging::V2.new instead of Logging.new(version: :v2). Update the
# examples and tests.
s.replace(
    [
      'lib/google/cloud/logging/v2/config_service_v2_client.rb',
      'lib/google/cloud/logging/v2/logging_service_v2_client.rb',
      'lib/google/cloud/logging/v2/metrics_service_v2_client.rb'
    ],
    'require "google/cloud/logging"',
    'require "google/cloud/logging/v2"')
s.replace(
    'lib/google/cloud/logging/v2/config_service_v2_client.rb',
    'Google::Cloud::Logging::Config\\.new\\(version: :v2\\)',
    'Google::Cloud::Logging::V2::ConfigServiceV2Client.new')
s.replace(
    'lib/google/cloud/logging/v2/logging_service_v2_client.rb',
    'Google::Cloud::Logging::Logging\\.new\\(version: :v2\\)',
    'Google::Cloud::Logging::V2::LoggingServiceV2Client.new')
s.replace(
    'lib/google/cloud/logging/v2/metrics_service_v2_client.rb',
    'Google::Cloud::Logging::Metrics\\.new\\(version: :v2\\)',
    'Google::Cloud::Logging::V2::MetricsServiceV2Client.new')

# https://github.com/googleapis/gapic-generator/issues/2124
s.replace(
    'lib/google/cloud/logging/v2/credentials.rb',
    'SCOPE = \[[^\]]+\]\.freeze',
    'SCOPE = ["https://www.googleapis.com/auth/logging.admin"].freeze')

# https://github.com/googleapis/gapic-generator/issues/2242
def escape_braces(match):
    expr = re.compile('([^#\\$\\\\])\\{([\\w,]+)\\}')
    content = match.group(0)
    while True:
        content, count = expr.subn('\\1\\\\\\\\{\\2}', content)
        if count == 0:
            return content
s.replace(
    'lib/google/cloud/logging/v2/**/*.rb',
    '\n(\\s+)#[^\n]*[^\n#\\$\\\\]\\{[\\w,]+\\}',
    escape_braces)
