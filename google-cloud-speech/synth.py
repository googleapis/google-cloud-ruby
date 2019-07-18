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

# Copy common templates
templates = gcp.CommonTemplates().ruby_library()
s.copy(templates)

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

# Support for service_address
s.replace(
    [
        'lib/google/cloud/speech.rb',
        'lib/google/cloud/speech/v*.rb',
        'lib/google/cloud/speech/v*/*_client.rb'
    ],
    '\n(\\s+)#(\\s+)@param exception_transformer',
    '\n\\1#\\2@param service_address [String]\n' +
        '\\1#\\2  Override for the service hostname, or `nil` to leave as the default.\n' +
        '\\1#\\2@param service_port [Integer]\n' +
        '\\1#\\2  Override for the service port, or `nil` to leave as the default.\n' +
        '\\1#\\2@param exception_transformer'
)
s.replace(
    [
        'lib/google/cloud/speech/v*.rb',
        'lib/google/cloud/speech/v*/*_client.rb'
    ],
    '\n(\\s+)metadata: nil,\n\\s+exception_transformer: nil,\n',
    '\n\\1metadata: nil,\n\\1service_address: nil,\n\\1service_port: nil,\n\\1exception_transformer: nil,\n'
)
s.replace(
    [
        'lib/google/cloud/speech/v*.rb',
        'lib/google/cloud/speech/v*/*_client.rb'
    ],
    ',\n(\\s+)lib_name: lib_name,\n\\s+lib_version: lib_version',
    ',\n\\1lib_name: lib_name,\n\\1service_address: service_address,\n\\1service_port: service_port,\n\\1lib_version: lib_version'
)
s.replace(
    'lib/google/cloud/speech/v*/*_client.rb',
    'service_path = self\\.class::SERVICE_ADDRESS',
    'service_path = service_address || self.class::SERVICE_ADDRESS'
)
s.replace(
    'lib/google/cloud/speech/v*/*_client.rb',
    'port = self\\.class::DEFAULT_SERVICE_PORT',
    'port = service_port || self.class::DEFAULT_SERVICE_PORT'
)
s.replace(
    'google-cloud-speech.gemspec',
    '\n  gem\\.add_dependency "google-gax", "~> 1\\.[\\d\\.]+"\n',
    '\n  gem.add_dependency "google-gax", "~> 1.7"\n')

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

s.replace(
    'google-cloud-speech.gemspec',
    '"README.md", "LICENSE"',
    '"README.md", "AUTHENTICATION.md", "LICENSE"'
)
s.replace(
    '.yardopts',
    'README.md\n',
    'README.md\nAUTHENTICATION.md\nLICENSE\n'
)

# https://github.com/googleapis/gapic-generator/issues/2393
s.replace(
    'google-cloud-speech.gemspec',
    'gem.add_development_dependency "rubocop".*$',
    'gem.add_development_dependency "rubocop", "~> 0.64.0"'
)

# https://github.com/googleapis/google-cloud-ruby/issues/3058
s.replace(
    'google-cloud-speech.gemspec',
    '\nGem::Specification.new do',
    'require File.expand_path("../lib/google/cloud/speech/version", __FILE__)\n\nGem::Specification.new do'
)
s.replace(
    'google-cloud-speech.gemspec',
    '(gem.version\s+=\s+).\d+.\d+.\d.*$',
    '\\1Google::Cloud::Speech::VERSION'
)
for version in ['v1', 'v1p1beta1']:
    s.replace(
        f'lib/google/cloud/speech/{version}/*_client.rb',
        f'(require \".*credentials\"\n)\n',
        f'\\1require "google/cloud/speech/version"\n\n'
    )
    s.replace(
        f'lib/google/cloud/speech/{version}/*_client.rb',
        'Gem.loaded_specs\[.*\]\.version\.version',
        'Google::Cloud::Speech::VERSION'
    )

# Fix links for devsite migration
for file in ['lib/**/*.rb', '*.md']:
    s.replace(
        file,
        'https://googleapis.github.io/google-cloud-ruby/#/docs/google-cloud-logging/latest/google/cloud/logging/logger',
        'https://googleapis.dev/ruby/google-cloud-logging/latest'
    )
s.replace(
    '*.md',
    'https://googleapis.github.io/google-cloud-ruby/#/docs/.*/authentication',
    './AUTHENTICATION.md'
)
s.replace(
    'lib/**/*.rb',
    'https://googleapis.github.io/google-cloud-ruby/#/docs/.*/authentication',
    'https://googleapis.dev/ruby/google-cloud-speech/latest/file.AUTHENTICATION.html'
)
s.replace(
    'README.md',
    'github.io/google-cloud-ruby/#/docs/google-cloud-speech/latest/.*$',
    'dev/ruby/google-cloud-speech/latest'
)
