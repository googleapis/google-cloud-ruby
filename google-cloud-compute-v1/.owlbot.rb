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

OwlBot.move_files
