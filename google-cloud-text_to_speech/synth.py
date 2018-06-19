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
common = gcp.CommonTemplates()

v1_library = gapic._generate_code(
    'texttospeech', 'v1', 'ruby',
    config_path='artman_texttospeech_v1.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-texttospeech')

s.copy(v1_library / "lib/google/cloud/text_to_speech/v1")
s.copy(v1_library / "lib/google/cloud/text_to_speech/v1.rb")
s.copy(v1_library / "lib/google/cloud/texttospeech/v1")
s.copy(v1_library / "test/google/cloud/text_to_speech/v1")

# Temporary until https://github.com/googleapis/gapic-generator/pull/2079
# shows up in a build.
s.replace(
    "lib/google/cloud/text_to_speech/v1/text_to_speech_client.rb",
    'require "google/cloud/text_to_speech/credentials"',
    'require "google/cloud/text_to_speech/v1/credentials"')

# https://github.com/googleapis/gapic-generator/issues/2080
s.replace(
    "test/google/cloud/text_to_speech/v1/text_to_speech_client_test.rb",
    "assert_not_nil",
    "refute_nil")
