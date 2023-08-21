# frozen_string_literal: true

# Copyright 2021 Google LLC
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

desc "List built versions"

flag :latest_only
flag :single_line

include :exec, e: true

def run
  data = {}
  capture(["gsutil", "ls", "gs://docs-staging-v2"]).split("\n").each do |url|
    if url =~ %r{^gs://docs-staging-v2/docfx-ruby-(.+)-v(\d+\.\d+\.\d+)\.tar\.gz$}
      (data[Regexp.last_match[1]] ||= []) << Gem::Version.new(Regexp.last_match[2])
    end
  end
  data.transform_values!(&:sort)
  data.transform_values! { |versions| [versions.last] } if latest_only
  output = []
  data.keys.sort.each do |gem_name|
    data[gem_name].each do |gem_version|
      output << "#{gem_name}:#{gem_version}"
    end
  end
  if single_line
    puts output.join " "
  else
    output.each { |line| puts line }
  end
end
