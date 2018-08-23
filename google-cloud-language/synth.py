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

v1_library = gapic.ruby_library(
    'language', 'v1',
    artman_output_name='google-cloud-ruby/google-cloud-language'
)
s.copy(v1_library / 'acceptance')
s.copy(v1_library / 'lib/google/cloud/language/v1')
s.copy(v1_library / 'lib/google/cloud/language/v1.rb')
s.copy(v1_library / 'lib/google/cloud/language/v1')
s.copy(v1_library / 'lib/google/cloud/language.rb')
s.copy(v1_library / 'test/google/cloud/language/v1')
s.copy(v1_library / 'Rakefile')
s.copy(v1_library / 'README.md')
s.copy(v1_library / 'LICENSE')
s.copy(v1_library / '.gitignore')
s.copy(v1_library / '.rubocop.yml')
s.copy(v1_library / '.yardopts')
s.copy(v1_library / 'google-cloud-language.gemspec', merge=merge_gemspec)

v1beta2_library = gapic.ruby_library(
    'language', 'v1beta2',
    artman_output_name='google-cloud-ruby/google-cloud-language'
)
s.copy(v1beta2_library / 'lib/google/cloud/language/v1beta2')
s.copy(v1beta2_library / 'lib/google/cloud/language/v1beta2.rb')
s.copy(v1beta2_library / 'lib/google/cloud/language/v1beta2')
s.copy(v1beta2_library / 'test/google/cloud/language/v1beta2')

# https://github.com/googleapis/gapic-generator/issues/2196
s.replace(
    [
      'README.md',
      'lib/google/cloud/language.rb',
      'lib/google/cloud/language/v1.rb',
      'lib/google/cloud/language/v1beta2.rb',
      'lib/google/cloud/language/v1/doc/overview.rb',
      'lib/google/cloud/language/v1beta2/doc/overview.rb'
    ],
    '\\[Product Documentation\\]: https://cloud\\.google\\.com/language\n',
    '[Product Documentation]: https://cloud.google.com/natural-language\n')

# https://github.com/googleapis/gapic-generator/issues/2211
s.replace(
    'Rakefile',
    'namespace :ci do\n  desc "Run the CI build, with acceptance tests\\."\n  task :acceptance do',
    dedent("""\
      namespace :ci do
        desc "Run the CI build, with smoke tests."
        task :smoke_test do
          Rake::Task["ci"].invoke
          header "google-cloud-language smoke_test", "*"
          sh "bundle exec rake smoke_test -v"
        end
        desc "Run the CI build, with acceptance tests."
        task :acceptance do"""))

# https://github.com/googleapis/gapic-generator/issues/2243
s.replace(
    'lib/google/cloud/language/*/*_client.rb',
    '(\n\\s+class \\w+Client\n)(\\s+)(attr_reader :\\w+_stub)',
    '\\1\\2# @private\n\\2\\3')
