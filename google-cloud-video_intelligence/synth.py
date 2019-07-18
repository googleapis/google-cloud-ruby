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


logging.basicConfig(level=logging.DEBUG)

gapic = gcp.GAPICGenerator()

v1_library = gapic.ruby_library(
    'videointelligence', 'v1',
    artman_output_name='google-cloud-ruby/google-cloud-video_intelligence'
)
s.copy(v1_library / 'acceptance')
s.copy(v1_library / 'lib/google/cloud/video_intelligence/v1')
s.copy(v1_library / 'lib/google/cloud/video_intelligence/v1.rb')
s.copy(v1_library / 'lib/google/cloud/videointelligence/v1')
s.copy(v1_library / 'lib/google/cloud/video_intelligence.rb')
s.copy(v1_library / 'test/google/cloud/video_intelligence/v1')
s.copy(v1_library / 'README.md')
s.copy(v1_library / 'LICENSE')
s.copy(v1_library / '.gitignore')
s.copy(v1_library / '.yardopts')
s.copy(v1_library / 'google-cloud-video_intelligence.gemspec', merge=ruby.merge_gemspec)

v1beta1_library = gapic.ruby_library(
    'videointelligence', 'v1beta1',
    artman_output_name='google-cloud-ruby/google-cloud-video_intelligence'
)
s.copy(v1beta1_library / 'lib/google/cloud/video_intelligence/v1beta1')
s.copy(v1beta1_library / 'lib/google/cloud/video_intelligence/v1beta1.rb')
s.copy(v1beta1_library / 'lib/google/cloud/videointelligence/v1beta1')
s.copy(v1beta1_library / 'test/google/cloud/video_intelligence/v1beta1')

v1p1beta1_library = gapic.ruby_library(
    'videointelligence', 'v1p1beta1',
    artman_output_name='google-cloud-ruby/google-cloud-video_intelligence'
)
s.copy(v1p1beta1_library / 'lib/google/cloud/videointelligence/v1p1beta1')
s.copy(v1p1beta1_library / 'lib/google/cloud/video_intelligence/v1p1beta1')
s.copy(v1p1beta1_library / 'lib/google/cloud/video_intelligence/v1p1beta1.rb')
s.copy(v1p1beta1_library / 'acceptance/google/cloud/video_intelligence/v1p1beta1')
s.copy(v1p1beta1_library / 'test/google/cloud/video_intelligence/v1p1beta1')

v1p2beta1_library = gapic.ruby_library(
    'videointelligence', 'v1p2beta1',
    artman_output_name='google-cloud-ruby/google-cloud-video_intelligence'
)
s.copy(v1p2beta1_library / 'lib/google/cloud/videointelligence/v1p2beta1')
s.copy(v1p2beta1_library / 'lib/google/cloud/video_intelligence/v1p2beta1')
s.copy(v1p2beta1_library / 'lib/google/cloud/video_intelligence/v1p2beta1.rb')
s.copy(v1p2beta1_library / 'acceptance/google/cloud/video_intelligence/v1p2beta1')
s.copy(v1p2beta1_library / 'test/google/cloud/video_intelligence/v1p2beta1')

v1beta2_library = gapic.ruby_library(
    'videointelligence', 'v1beta2',
    artman_output_name='google-cloud-ruby/google-cloud-video_intelligence'
)
s.copy(v1beta2_library / 'lib/google/cloud/video_intelligence/v1beta2')
s.copy(v1beta2_library / 'lib/google/cloud/video_intelligence/v1beta2.rb')
s.copy(v1beta2_library / 'lib/google/cloud/videointelligence/v1beta2')
s.copy(v1beta2_library / 'test/google/cloud/video_intelligence/v1beta2')

# Copy common templates
templates = gcp.CommonTemplates().ruby_library()
s.copy(templates)

# Support for service_address
s.replace(
    [
        'lib/google/cloud/video_intelligence.rb',
        'lib/google/cloud/video_intelligence/v*.rb',
        'lib/google/cloud/video_intelligence/v*/*_client.rb'
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
        'lib/google/cloud/video_intelligence/v*.rb',
        'lib/google/cloud/video_intelligence/v*/*_client.rb'
    ],
    '\n(\\s+)metadata: nil,\n\\s+exception_transformer: nil,\n',
    '\n\\1metadata: nil,\n\\1service_address: nil,\n\\1service_port: nil,\n\\1exception_transformer: nil,\n'
)
s.replace(
    [
        'lib/google/cloud/video_intelligence/v*.rb',
        'lib/google/cloud/video_intelligence/v*/*_client.rb'
    ],
    ',\n(\\s+)lib_name: lib_name,\n\\s+lib_version: lib_version',
    ',\n\\1lib_name: lib_name,\n\\1service_address: service_address,\n\\1service_port: service_port,\n\\1lib_version: lib_version'
)
s.replace(
    'lib/google/cloud/video_intelligence/v*/*_client.rb',
    'service_path = self\\.class::SERVICE_ADDRESS',
    'service_path = service_address || self.class::SERVICE_ADDRESS'
)
s.replace(
    'lib/google/cloud/video_intelligence/v*/*_client.rb',
    'port = self\\.class::DEFAULT_SERVICE_PORT',
    'port = service_port || self.class::DEFAULT_SERVICE_PORT'
)
s.replace(
    'google-cloud-video_intelligence.gemspec',
    '\n  gem\\.add_dependency "google-gax", "~> 1\\.[\\d\\.]+"\n',
    '\n  gem.add_dependency "google-gax", "~> 1.7"\n')

# PERMANENT: API name for videointelligence
s.replace(
    [
      'README.md',
      'lib/google/cloud/video_intelligence.rb',
      'lib/google/cloud/video_intelligence/v1.rb',
      'lib/google/cloud/video_intelligence/v1beta1.rb',
      'lib/google/cloud/video_intelligence/v1p1beta1.rb',
      'lib/google/cloud/video_intelligence/v1p2beta1.rb',
      'lib/google/cloud/video_intelligence/v1beta2.rb'
    ],
    '/video-intelligence\\.googleapis\\.com', '/videointelligence.googleapis.com')

# https://github.com/googleapis/gapic-generator/issues/2232
s.replace(
    [
      'lib/google/cloud/video_intelligence/v1/video_intelligence_service_client.rb',
      'lib/google/cloud/video_intelligence/v1beta1/video_intelligence_service_client.rb',
      'lib/google/cloud/video_intelligence/v1p1beta1/video_intelligence_service_client.rb',
      'lib/google/cloud/video_intelligence/v1p2beta1/video_intelligence_service_client.rb',
      'lib/google/cloud/video_intelligence/v1beta2/video_intelligence_service_client.rb'
    ],
    '\n\n(\\s+)class OperationsClient < Google::Longrunning::OperationsClient',
    '\n\n\\1# @private\n\\1class OperationsClient < Google::Longrunning::OperationsClient')

# https://github.com/googleapis/gapic-generator/issues/2243
s.replace(
    'lib/google/cloud/video_intelligence/*/*_client.rb',
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
    'google-cloud-video_intelligence.gemspec',
    'gem.add_development_dependency "rubocop".*$',
    'gem.add_development_dependency "rubocop", "~> 0.64.0"'
)

s.replace(
    'google-cloud-video_intelligence.gemspec',
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
    'google-cloud-video_intelligence.gemspec',
    '\nGem::Specification.new do',
    'require File.expand_path("../lib/google/cloud/video_intelligence/version", __FILE__)\n\nGem::Specification.new do'
)
s.replace(
    'google-cloud-video_intelligence.gemspec',
    '(gem.version\s+=\s+).\d+.\d+.\d.*$',
    '\\1Google::Cloud::VideoIntelligence::VERSION'
)
for version in ['v1', 'v1beta1', 'v1beta2', 'v1p1beta1', 'v1p2beta1']:
    s.replace(
        f'lib/google/cloud/video_intelligence/{version}/*_client.rb',
        f'(require \".*credentials\"\n)\n',
        f'\\1require "google/cloud/video_intelligence/version"\n\n'
    )
    s.replace(
        f'lib/google/cloud/video_intelligence/{version}/*_client.rb',
        'Gem.loaded_specs\[.*\]\.version\.version',
        'Google::Cloud::VideoIntelligence::VERSION'
    )

# https://github.com/googleapis/gapic-generator/issues/2525
s.replace(
    'lib/google/cloud/video_intelligence/v*/**/*.rb',
    'Google::Cloud::Videointelligence',
    'Google::Cloud::VideoIntelligence')
s.replace(
    'lib/google/cloud/video_intelligence/v*/doc/google/cloud/videointelligence/**/*.rb',
    '\n    module Videointelligence\n',
    '\n    module VideoIntelligence\n'
)

# https://github.com/protocolbuffers/protobuf/issues/5584
s.replace(
    'lib/google/cloud/videointelligence/v*/*_pb.rb',
    '\nmodule Google::Cloud::VideoIntelligence::V(\\w+)\n',
    '\nmodule Google\n  module Cloud\n    module VideoIntelligence\n    end\n    Videointelligence = VideoIntelligence unless const_defined? :Videointelligence\n  end\nend\nmodule Google::Cloud::VideoIntelligence::V\\1\n',
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
    'https://googleapis.dev/ruby/google-cloud-video_intelligence/latest/file.AUTHENTICATION.html'
)
s.replace(
    'README.md',
    'github.io/google-cloud-ruby/#/docs/google-cloud-video_intelligence/latest/.*$',
    'dev/ruby/google-cloud-video_intelligence/latest'
)
