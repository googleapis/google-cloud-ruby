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

# Temporary: omit the snippets directory.
# Snippets are currently not working correctly for Ruby DIREGAPICs.
# When that gets fixed, remove this line.
FileUtils.rm_rf File.join(OwlBot.staging_dir, "snippets")

# b/498709248: Temporary escape to braces spanning multiple lines & reserved Ruby keywords.
# To be removed when fixed in the generator or in the source proto file.
brace_detector = /\A(?<pre>[^`]*(?:`[^`]*`[^`]*)*[^`\\])?\{(?<post>(?!::)[^\s].*)\z/m

OwlBot.modifier path: %r{^proto_docs/google/cloud/compute/[\w/]+\.rb$} do |content|
  content.gsub!(/(?<!`)@pattern(?!`)/, '`@pattern`')
  content.gsub!(/(?<!`)@required(?!`)/, '`@required`')
  lines = content.split("\n", -1)
  lines.map! do |line|
    while (m = brace_detector.match line)
      line = "#{m[:pre]}\\\\{#{m[:post]}"
    end
    line
  end
  lines.join("\n")
end

OwlBot.move_files
