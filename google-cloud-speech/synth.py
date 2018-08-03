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
import re
from textwrap import dedent

logging.basicConfig(level=logging.DEBUG)

gapic = gcp.GAPICGenerator()

v1_library = gapic.ruby_library(
    'speech', 'v1',
    artman_output_name='google-cloud-ruby/google-cloud-speech'
)

s.copy(v1_library / 'acceptance')

# https://github.com/googleapis/gapic-generator/issues/2185
s.replace(
    'acceptance/google/cloud/speech/v1/speech_smoke_test.rb',
    'describe "SpeechSmokeTest"',
    'describe "SpeechSmokeTest V1"')
s.replace(
    'acceptance/google/cloud/speech/v1/speech_smoke_test.rb',
    'speech_client = Google::Cloud::Speech\\.new',
    'speech_client = Google::Cloud::Speech.new version: :v1')

s.copy(v1_library / 'lib/google/cloud/speech/v1.rb')

# PERMANENT: Install partial gapics
s.replace(
    'lib/google/cloud/speech/v1.rb',
    'require "google/cloud/speech/v1/speech_client"',
    'require "google/cloud/speech/v1/speech_client"\nrequire "google/cloud/speech/v1/helpers"')

# https://github.com/googleapis/gapic-generator/issues/2122
s.replace(
    'lib/google/cloud/speech/v1.rb',
    'gs://gapic-toolkit/hello.flac',
    'gs://bucket-name/hello.flac')

s.copy(v1_library / 'lib/google/cloud/speech/v1')

# PERMANENT: Remove methods replaced by partial gapics
s.replace(
    'lib/google/cloud/speech/v1/speech_client.rb',
    f'\\n\\n(\\s+#[^\\n]*\\n)*\\n*(\\s+)def\\s+streaming_recognize[^\\n]+\\n+(\\2\\s\\s[^\\n]+\\n+)*\\2end\\n',
    '\n')

# https://github.com/googleapis/gapic-generator/issues/2182
s.replace(
    'lib/google/cloud/speech/v1/credentials.rb',
    'SPEECH_KEYFILE\\n(\s+)SPEECH_CREDENTIALS\n',
    'SPEECH_CREDENTIALS\\n\\1SPEECH_KEYFILE\n')
s.replace(
    'lib/google/cloud/speech/v1/credentials.rb',
    'SPEECH_KEYFILE_JSON\\n(\s+)SPEECH_CREDENTIALS_JSON\n',
    'SPEECH_CREDENTIALS_JSON\\n\\1SPEECH_KEYFILE_JSON\n')

s.copy(v1_library / 'test/google/cloud/speech/v1')

# PERMANENT: Remove streaming test from generated tests
s.replace(
    'test/google/cloud/speech/v1/speech_client_test.rb',
    f'\\n(\\s+)describe \'streaming_recognize\' do\\n+(\\1\\s\\s[^\\n]+\\n+)*\\1end\\n',
    '\n')

# https://github.com/googleapis/gapic-generator/issues/2117
s.replace(
    'test/google/cloud/speech/v1/speech_client_test.rb',
    'CustomTestError', 'CustomTestError_v1')
s.replace(
    'test/google/cloud/speech/v1/speech_client_test.rb',
    'MockGrpcClientStub', 'MockGrpcClientStub_v1')
s.replace(
    'test/google/cloud/speech/v1/speech_client_test.rb',
    'MockSpeechCredentials', 'MockSpeechCredentials_v1')

# Copy base module from the v1 library so v1 is the default
s.copy(v1_library / 'lib/google/cloud/speech.rb')

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

# https://github.com/googleapis/gapic-generator/issues/2174
s.replace(
    'lib/google/cloud/speech.rb',
    'File\.join\(dir, "\.rb"\)',
    'dir + ".rb"')

# https://github.com/googleapis/gapic-generator/issues/2122
s.replace(
    'lib/google/cloud/speech.rb',
    'gs://gapic-toolkit/hello.flac',
    'gs://bucket-name/hello.flac')

# Copy other base files from v1
s.copy(v1_library / 'README.md')
s.copy(v1_library / 'LICENSE')
s.copy(v1_library / '.gitignore')
s.copy(v1_library / '.rubocop.yml')
s.copy(v1_library / '.yardopts')

# PERMANENT: Add migration guide to readme
s.replace(
    'README.md',
    '### Preview\n',
    dedent("""\
      ### Migration Guide

      The 0.30.0 release introduced breaking changes relative to the previous release,
      0.29.0. For more details and instructions to migrate your code, please visit the
      [migration
      guide](https://cloud.google.com/speech-to-text/docs/ruby-client-migration).

      ### Preview\n"""))

# Temporary until we get Ruby-specific tools into synthtool
def merge_gemspec(src, dest, path):
    regex = re.compile(r'^\s+gem.version\s*=\s*"[\d\.]+"$', flags=re.MULTILINE)
    match = regex.search(dest)
    if match:
        src = regex.sub(match.group(0), src, count=1)
    regex = re.compile(r'^\s+gem.homepage\s*=\s*"[^"]+"$', flags=re.MULTILINE)
    match = regex.search(dest)
    if match:
        src = regex.sub(match.group(0), src, count=1)
    return src

s.copy(v1_library / 'google-cloud-speech.gemspec', merge=merge_gemspec)

# PERMANENT: Add post-install message
s.replace(
    'google-cloud-speech.gemspec',
    'gem.platform(\s+)= Gem::Platform::RUBY',
    dedent("""\
      gem.post_install_message =
          "The 0.30.0 release introduced breaking changes relative to the "\\
          "previous release, 0.29.0. For more details and instructions to migrate "\\
          "your code, please visit the migration guide: "\\
          "https://cloud.google.com/speech-to-text/docs/ruby-client-migration."

        gem.platform\\1= Gem::Platform::RUBY"""))


v1p1beta1_library = gapic.ruby_library(
    'speech', 'v1p1beta1',
    artman_output_name='google-cloud-ruby/google-cloud-speech'
)

s.copy(v1p1beta1_library / 'acceptance')

# https://github.com/googleapis/gapic-generator/issues/2185
s.replace(
    'acceptance/google/cloud/speech/v1p1beta1/speech_smoke_test.rb',
    'describe "SpeechSmokeTest"',
    'describe "SpeechSmokeTest V1p1beta1"')
s.replace(
    'acceptance/google/cloud/speech/v1p1beta1/speech_smoke_test.rb',
    'speech_client = Google::Cloud::Speech\\.new',
    'speech_client = Google::Cloud::Speech.new version: :v1p1beta1')

s.copy(v1p1beta1_library / 'lib/google/cloud/speech/v1p1beta1.rb')

# PERMANENT: Install partial gapics
s.replace(
    'lib/google/cloud/speech/v1p1beta1.rb',
    'require "google/cloud/speech/v1p1beta1/speech_client"',
    'require "google/cloud/speech/v1p1beta1/speech_client"\nrequire "google/cloud/speech/v1p1beta1/helpers"')

# https://github.com/googleapis/gapic-generator/issues/2122
s.replace(
    'lib/google/cloud/speech/v1p1beta1.rb',
    'gs://gapic-toolkit/hello.flac',
    'gs://bucket-name/hello.flac')

s.copy(v1p1beta1_library / 'lib/google/cloud/speech/v1p1beta1')

# PERMANENT: Remove methods replaced by partial gapics
s.replace(
    'lib/google/cloud/speech/v1p1beta1/speech_client.rb',
    f'\\n\\n(\\s+#[^\\n]*\\n)*\\n*(\\s+)def\\s+streaming_recognize[^\\n]+\\n+(\\2\\s\\s[^\\n]+\\n+)*\\2end\\n',
    '\n')

# https://github.com/googleapis/gapic-generator/issues/2182
s.replace(
    'lib/google/cloud/speech/v1p1beta1/credentials.rb',
    'SPEECH_KEYFILE\\n(\s+)SPEECH_CREDENTIALS\n',
    'SPEECH_CREDENTIALS\\n\\1SPEECH_KEYFILE\n')
s.replace(
    'lib/google/cloud/speech/v1p1beta1/credentials.rb',
    'SPEECH_KEYFILE_JSON\\n(\s+)SPEECH_CREDENTIALS_JSON\n',
    'SPEECH_CREDENTIALS_JSON\\n\\1SPEECH_KEYFILE_JSON\n')

s.copy(v1p1beta1_library / 'test/google/cloud/speech/v1p1beta1')

# PERMANENT: Remove streaming test from generated tests
s.replace(
    'test/google/cloud/speech/v1p1beta1/speech_client_test.rb',
    f'\\n(\\s+)describe \'streaming_recognize\' do\\n+(\\1\\s\\s[^\\n]+\\n+)*\\1end\\n',
    '\n')

# https://github.com/googleapis/gapic-generator/issues/2117
s.replace(
    'test/google/cloud/speech/v1p1beta1/speech_client_test.rb',
    'CustomTestError', 'CustomTestError_v1p1beta1')
s.replace(
    'test/google/cloud/speech/v1p1beta1/speech_client_test.rb',
    'MockGrpcClientStub', 'MockGrpcClientStub_v1p1beta1')
s.replace(
    'test/google/cloud/speech/v1p1beta1/speech_client_test.rb',
    'MockSpeechCredentials', 'MockSpeechCredentials_v1p1beta1')
