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
from textwrap import dedent

logging.basicConfig(level=logging.DEBUG)

gapic = gcp.GAPICGenerator()

v1_library = gapic.ruby_library(
    'speech', 'v1',
    artman_output_name='google-cloud-ruby/google-cloud-speech'
)
s.copy(v1_library / 'lib/google/cloud/speech/v1')
s.copy(v1_library / 'lib/google/cloud/speech/v1.rb')
s.copy(v1_library / 'lib/google/cloud/speech.rb')

# PERMANENT: Install partial gapics
s.replace(
    'lib/google/cloud/speech/v1.rb',
    'require "google/cloud/speech/v1/speech_client"',
    'require "google/cloud/speech/v1/speech_client"\nrequire "google/cloud/speech/v1/helpers"')

# PERMANENT: Remove methods replaced by partial gapics
s.replace(
    'lib/google/cloud/speech/v1/speech_client.rb',
    '\n\n(\s{10}#[^\n]*\n)+\n*\s{10}def streaming_recognize[^\n]+\n(\s{12}[^\n]+\n+)+\s{10}end\n',
    '\n')

# PERMANENT: Add migration guide to docs
s.replace(
    'lib/google/cloud/speech.rb',
    '# ### Preview',
    dedent("""\
      # ### Migration Guide
          #
          # The 0.30.0 release introduced breaking changes relative to the previous
          # release, 0.29.0. For more details and instructions to migrate your code,
          # please visit the [migration
          # guide](https://cloud.google.com/speech-to-text/docs/ruby-client-migration).
          #
          # ### Preview"""))

# https://github.com/googleapis/gapic-generator/issues/2122
s.replace(
    'lib/google/cloud/speech.rb',
    'gs://gapic-toolkit/hello.flac',
    'gs://bucket-name/hello.flac')
s.replace(
    'lib/google/cloud/speech/v1.rb',
    'gs://gapic-toolkit/hello.flac',
    'gs://bucket-name/hello.flac')
