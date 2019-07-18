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
from textwrap import dedent
from os.path import join
from subprocess import call

logging.basicConfig(level=logging.DEBUG)

gapic = gcp.GAPICGenerator()

v1_library = gapic.ruby_library(
    'vision', 'v1', artman_output_name='google-cloud-ruby/google-cloud-vision'
)

s.copy(v1_library / 'lib')
s.copy(v1_library / 'acceptance')
s.copy(v1_library / 'test')
s.copy(v1_library / 'README.md')
s.copy(v1_library / 'LICENSE')
s.copy(v1_library / '.gitignore')
s.copy(v1_library / '.yardopts')
s.copy(v1_library / 'google-cloud-vision.gemspec', merge=ruby.merge_gemspec)

v1p3beta1 = gapic.ruby_library(
    'vision', 'v1p3beta1',
    artman_output_name='google-cloud-ruby/google-cloud-vision'
)
s.copy(v1p3beta1 / 'lib/google/cloud/vision/v1p3beta1')
s.copy(v1p3beta1 / 'lib/google/cloud/vision/v1p3beta1.rb')
s.copy(v1p3beta1 / 'acceptance/google/cloud/vision/v1p3beta1')
s.copy(v1p3beta1 / 'test/google/cloud/vision/v1p3beta1')

# Copy common templates
templates = gcp.CommonTemplates().ruby_library()
s.copy(templates)

# Support for service_address
s.replace(
    [
        'lib/google/cloud/vision.rb',
        'lib/google/cloud/vision/v*.rb',
        'lib/google/cloud/vision/v*/*_client.rb'
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
        'lib/google/cloud/vision/v*.rb',
        'lib/google/cloud/vision/v*/*_client.rb'
    ],
    '\n(\\s+)metadata: nil,\n\\s+exception_transformer: nil,\n',
    '\n\\1metadata: nil,\n\\1service_address: nil,\n\\1service_port: nil,\n\\1exception_transformer: nil,\n'
)
s.replace(
    [
        'lib/google/cloud/vision/v*.rb',
        'lib/google/cloud/vision/v*/*_client.rb'
    ],
    ',\n(\\s+)lib_name: lib_name,\n\\s+lib_version: lib_version',
    ',\n\\1lib_name: lib_name,\n\\1service_address: service_address,\n\\1service_port: service_port,\n\\1lib_version: lib_version'
)
s.replace(
    'lib/google/cloud/vision/v*/*_client.rb',
    'service_path = self\\.class::SERVICE_ADDRESS',
    'service_path = service_address || self.class::SERVICE_ADDRESS'
)
s.replace(
    'lib/google/cloud/vision/v*/*_client.rb',
    'port = self\\.class::DEFAULT_SERVICE_PORT',
    'port = service_port || self.class::DEFAULT_SERVICE_PORT'
)
s.replace(
    'google-cloud-vision.gemspec',
    '\n  gem\\.add_dependency "google-gax", "~> 1\\.[\\d\\.]+"\n',
    '\n  gem.add_dependency "google-gax", "~> 1.7"\n')

# PERMANENT: Add migration guide to docs
s.replace(
    'lib/google/cloud/vision.rb',
    '# ### Preview',
    dedent("""\
      # ### Migration Guide
          #
          # The 0.32.0 release introduced breaking changes relative to the previous
          # release, 0.31.0. For more details and instructions to migrate your code,
          # please visit the [migration
          # guide](https://cloud.google.com/vision/docs/ruby-client-migration).
          #
          # ### Preview"""))

# PERMANENT: Add migration guide to readme
s.replace(
    'README.md',
    '### Preview\n',
    dedent("""\
      ### Migration Guide

      The 0.32.0 release introduced breaking changes relative to the previous release,
      0.31.0. For more details and instructions to migrate your code, please visit the
      [migration
      guide](https://cloud.google.com/vision/docs/ruby-client-migration).

      ### Preview\n"""))

# PERMANENT: Add post-install message
s.replace(
    'google-cloud-vision.gemspec',
    'gem.platform(\s+)= Gem::Platform::RUBY',
    dedent("""\
      gem.post_install_message =
          "The 0.32.0 release introduced breaking changes relative to the "\\
          "previous release, 0.31.0. For more details and instructions to migrate "\\
          "your code, please visit the migration guide: "\\
          "https://cloud.google.com/vision/docs/ruby-client-migration."

        gem.platform\\1= Gem::Platform::RUBY"""))

for version in ['v1', 'v1p3beta1']:

    # https://github.com/googleapis/gapic-generator/issues/2232
    s.replace(
        [
            f'lib/google/cloud/vision/{version}/image_annotator_client.rb',
            f'lib/google/cloud/vision/{version}/product_search_client.rb'
        ],
        '\n\n(\\s+)class OperationsClient < Google::Longrunning::OperationsClient',
        '\n\n\\1# @private\n\\1class OperationsClient < Google::Longrunning::OperationsClient')

    # https://github.com/googleapis/gapic-generator/issues/2243
    s.replace(
        f'lib/google/cloud/vision/{version}/*_client.rb',
        '(\n\\s+class \\w+Client\n)(\\s+)(attr_reader :\\w+_stub)',
        '\\1\\2# @private\n\\2\\3')

    # Require helper methods
    s.replace(
        f'lib/google/cloud/vision/{version}.rb',
        f'require "google/cloud/vision/{version}/image_annotator_client"',
        '\n'.join([
            f'require "google/cloud/vision/{version}/image_annotator_client"',
            f'require "google/cloud/vision/{version}/helpers"',
        ])
    )

# https://github.com/googleapis/gapic-generator/issues/2279
s.replace(
    'lib/**/*.rb',
    '\\A(((#[^\n]*)?\n)*# (Copyright \\d+|Generated by the protocol buffer compiler)[^\n]+\n(#[^\n]*\n)*\n)([^\n])',
    '\\1\n\\6')

# https://github.com/googleapis/gapic-generator/issues/2323
s.replace(
    ['lib/**/*.rb', 'README.md'],
    'https://github\\.com/GoogleCloudPlatform/google-cloud-ruby',
    'https://github.com/googleapis/google-cloud-ruby'
)
s.replace(
    ['lib/**/*.rb', 'README.md'],
    'https://googlecloudplatform\\.github\\.io/google-cloud-ruby',
    'https://googleapis.github.io/google-cloud-ruby'
)
s.replace(
    'google-cloud-vision.gemspec',
    'gem.add_development_dependency "rubocop".*$',
    'gem.add_development_dependency "rubocop", "~> 0.64.0"'
)

s.replace(
    'google-cloud-vision.gemspec',
    '"README.md", "LICENSE"',
    '"README.md", "AUTHENTICATION.md", "LICENSE"'
)
s.replace(
    '.yardopts',
    'README.md\n',
    'README.md\nAUTHENTICATION.md\nLICENSE\n'
)

# https://github.com/googleapis/google-cloud-ruby/issues/3058
s.replace(
    'google-cloud-vision.gemspec',
    '\nGem::Specification.new do',
    'require File.expand_path("../lib/google/cloud/vision/version", __FILE__)\n\nGem::Specification.new do'
)
s.replace(
    'google-cloud-vision.gemspec',
    '(gem.version\s+=\s+).\d+.\d+.\d.*$',
    '\\1Google::Cloud::Vision::VERSION'
)
for version in ['v1', 'v1p3beta1']:
    s.replace(
        f'lib/google/cloud/vision/{version}/*_client.rb',
        f'(require \".*credentials\"\n)\n',
        f'\\1require "google/cloud/vision/version"\n\n'
    )
    s.replace(
        f'lib/google/cloud/vision/{version}/*_client.rb',
        'Gem.loaded_specs\[.*\]\.version\.version',
        'Google::Cloud::Vision::VERSION'
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
    'https://googleapis.dev/ruby/google-cloud-vision/latest/file.AUTHENTICATION.html'
)
s.replace(
    'README.md',
    'github.io/google-cloud-ruby/#/docs/google-cloud-vision/latest/.*$',
    'dev/ruby/google-cloud-vision/latest'
)

# Generate the helper methods
call('bundle update && bundle exec rake generate_partials', shell=True)
