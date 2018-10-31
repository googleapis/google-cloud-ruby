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
import synthtool.languages.ruby as ruby
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
s.copy(v1_library / 'lib/google/cloud/speech/v1.rb')
s.copy(v1_library / 'lib/google/cloud/speech/v1')
s.copy(v1_library / 'test/google/cloud/speech/v1')
s.copy(v1_library / 'lib/google/cloud/speech.rb')
s.copy(v1_library / 'README.md')
s.copy(v1_library / 'LICENSE')
s.copy(v1_library / '.gitignore')
s.copy(v1_library / '.yardopts')
s.copy(v1_library / 'google-cloud-speech.gemspec', merge=ruby.merge_gemspec)

v1p1beta1_library = gapic.ruby_library(
    'speech', 'v1p1beta1',
    artman_output_name='google-cloud-ruby/google-cloud-speech'
)
s.copy(v1p1beta1_library / 'acceptance')
s.copy(v1p1beta1_library / 'lib/google/cloud/speech/v1p1beta1.rb')
s.copy(v1p1beta1_library / 'lib/google/cloud/speech/v1p1beta1')
s.copy(v1p1beta1_library / 'test/google/cloud/speech/v1p1beta1')

# PERMANENT: Install partial gapics
s.replace(
    'lib/google/cloud/speech/v1.rb',
    'require "google/cloud/speech/v1/speech_client"',
    'require "google/cloud/speech/v1/speech_client"\nrequire "google/cloud/speech/v1/helpers"')
s.replace(
    'lib/google/cloud/speech/v1p1beta1.rb',
    'require "google/cloud/speech/v1p1beta1/speech_client"',
    'require "google/cloud/speech/v1p1beta1/speech_client"\nrequire "google/cloud/speech/v1p1beta1/helpers"')

# PERMANENT: Remove methods replaced by partial gapics
ruby.delete_method(
    [
      'lib/google/cloud/speech/v1/speech_client.rb',
      'lib/google/cloud/speech/v1p1beta1/speech_client.rb'
    ],
    'streaming_recognize')

# PERMANENT: Remove streaming test from generated tests
s.replace(
    [
      'test/google/cloud/speech/v1/speech_client_test.rb',
      'test/google/cloud/speech/v1p1beta1/speech_client_test.rb'
    ],
    f'\\n(\\s+)describe \'streaming_recognize\' do\\n+(\\1\\s\\s[^\\n]+\\n+)*\\1end\\n',
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

# https://github.com/googleapis/gapic-generator/issues/2122
s.replace(
    [
      'lib/google/cloud/speech.rb',
      'lib/google/cloud/speech/v1.rb',
      'lib/google/cloud/speech/v1p1beta1.rb'
    ],
    'gs://gapic-toolkit/hello.flac',
    'gs://bucket-name/hello.flac')

# https://github.com/googleapis/gapic-generator/issues/2232
s.replace(
    [
      'lib/google/cloud/speech/v1/speech_client.rb',
      'lib/google/cloud/speech/v1p1beta1/speech_client.rb'
    ],
    '\n\n(\\s+)class OperationsClient < Google::Longrunning::OperationsClient',
    '\n\n\\1# @private\n\\1class OperationsClient < Google::Longrunning::OperationsClient')

# https://github.com/googleapis/gapic-generator/issues/2243
s.replace(
    'lib/google/cloud/speech/*/*_client.rb',
    '(\n\\s+class \\w+Client\n)(\\s+)(attr_reader :\\w+_stub)',
    '\\1\\2# @private\n\\2\\3')

# https://github.com/googleapis/gapic-generator/issues/2279
s.replace(
    'lib/**/*.rb',
    '\\A(((#[^\n]*)?\n)*# (Copyright \\d+|Generated by the protocol buffer compiler)[^\n]+\n(#[^\n]*\n)*\n)([^\n])',
    '\\1\n\\6')

# https://github.com/googleapis/gapic-generator/issues/2323
s.replace(
    [
        'lib/**/*.rb',
        'README.md'
    ],
    'https://github\\.com/GoogleCloudPlatform/google-cloud-ruby',
    'https://github.com/googleapis/google-cloud-ruby'
)
s.replace(
    [
        'lib/**/*.rb',
        'README.md'
    ],
    'https://googlecloudplatform\\.github\\.io/google-cloud-ruby',
    'https://googleapis.github.io/google-cloud-ruby'
)

# https://github.com/googleapis/gapic-generator/issues/2393
s.replace(
    'google-cloud-speech.gemspec',
    'gem.add_development_dependency "rubocop".*$',
    'gem.add_development_dependency "rubocop", "~> 0.59.2"'
)
