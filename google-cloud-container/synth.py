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
    'container', 'v1', config_path='/google/container/artman_container.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-container'
)
s.copy(v1_library / 'acceptance')
s.copy(v1_library / 'lib')
s.copy(v1_library / 'test')
s.copy(v1_library / 'Rakefile')
s.copy(v1_library / 'README.md')
s.copy(v1_library / 'LICENSE')
s.copy(v1_library / '.gitignore')
s.copy(v1_library / '.rubocop.yml')
s.copy(v1_library / '.yardopts')
s.copy(v1_library / 'google-cloud-container.gemspec', merge=merge_gemspec)

# https://github.com/googleapis/gapic-generator/issues/2196
s.replace(
    [
      'README.md',
      'lib/google/cloud/container.rb',
      'lib/google/cloud/container/v1.rb',
      'lib/google/cloud/container/v1/doc/overview.rb'
    ],
    '\\[Product Documentation\\]: https://cloud\\.google\\.com/container\n',
    '[Product Documentation]: https://cloud.google.com/kubernetes-engine\n')

# https://github.com/googleapis/gapic-generator/issues/2211
s.replace(
    'Rakefile',
    'namespace :ci do\n  desc "Run the CI build, with acceptance tests\\."\n  task :acceptance do',
    dedent("""\
      namespace :ci do
        desc "Run the CI build, with smoke tests."
        task :smoke_test do
          Rake::Task["ci"].invoke
          header "google-cloud-container smoke_test", "*"
          sh "bundle exec rake smoke_test -v"
        end
        desc "Run the CI build, with acceptance tests."
        task :acceptance do"""))
