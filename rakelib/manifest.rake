# Copyright 2014 Google Inc. All rights reserved.
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

desc "Update the Manifest file."
task :manifest do
  `rake git:manifest`
  new_manifest = []
  File.open("Manifest.txt").each do |line|
    new_manifest << line unless line =~ /^regression*/
  end
  File.write "Manifest.txt", new_manifest.join
end
