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

v1p1beta1 = gapic.ruby_library(
    'videointelligence', 'v1p1beta1',
    artman_output_name='google-cloud-ruby/google-cloud-video_intelligence'
)
s.copy(v1p1beta1 / 'lib/google/cloud/videointelligence/v1p1beta1')
s.copy(v1p1beta1 / 'lib/google/cloud/video_intelligence/v1_p1_beta1')
s.copy(v1p1beta1 / 'lib/google/cloud/video_intelligence/v1_p1_beta1.rb')
s.copy(v1p1beta1 / 'acceptance/google/cloud/video_intelligence/v1_p1_beta1')
s.copy(v1p1beta1 / 'test/google/cloud/video_intelligence/v1_p1_beta1')

v1p2beta1 = gapic.ruby_library(
    'videointelligence', 'v1p2beta1',
    artman_output_name='google-cloud-ruby/google-cloud-video_intelligence'
)
s.copy(v1p2beta1 / 'lib/google/cloud/videointelligence/v1p2beta1')
s.copy(v1p2beta1 / 'lib/google/cloud/video_intelligence/v1_p2_beta1')
s.copy(v1p2beta1 / 'lib/google/cloud/video_intelligence/v1_p2_beta1.rb')
s.copy(v1p2beta1 / 'acceptance/google/cloud/video_intelligence/v1_p2_beta1')
s.copy(v1p2beta1 / 'test/google/cloud/video_intelligence/v1_p2_beta1')

v1beta2_library = gapic.ruby_library(
    'videointelligence', 'v1beta2',
    artman_output_name='google-cloud-ruby/google-cloud-video_intelligence'
)
s.copy(v1beta2_library / 'lib/google/cloud/video_intelligence/v1beta2')
s.copy(v1beta2_library / 'lib/google/cloud/video_intelligence/v1beta2.rb')
s.copy(v1beta2_library / 'lib/google/cloud/videointelligence/v1beta2')
s.copy(v1beta2_library / 'test/google/cloud/video_intelligence/v1beta2')

# PERMANENT: API name for videointelligence
s.replace(
    [
      'README.md',
      'lib/google/cloud/video_intelligence.rb',
      'lib/google/cloud/video_intelligence/v1.rb',
      'lib/google/cloud/video_intelligence/v1beta1.rb',
      'lib/google/cloud/video_intelligence/v1_p1_beta1.rb',
      'lib/google/cloud/video_intelligence/v1_p2_beta1.rb',
      'lib/google/cloud/video_intelligence/v1beta2.rb'
    ],
    '/video-intelligence\\.googleapis\\.com', '/videointelligence.googleapis.com')

# https://github.com/googleapis/gapic-generator/issues/2232
s.replace(
    [
      'lib/google/cloud/video_intelligence/v1/video_intelligence_service_client.rb',
      'lib/google/cloud/video_intelligence/v1beta1/video_intelligence_service_client.rb',
      'lib/google/cloud/video_intelligence/v1_p1_beta1/video_intelligence_service_client.rb',
      'lib/google/cloud/video_intelligence/v1_p2_beta1/video_intelligence_service_client.rb',
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
    'gem.add_development_dependency "rubocop", "~> 0.59.2"'
)
