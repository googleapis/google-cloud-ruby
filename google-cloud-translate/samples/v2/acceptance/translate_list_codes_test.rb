# Copyright 2020 Google LLC
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

require_relative "helper"
require_relative "../translate_list_codes"

describe "translate_list_codes", :translate do
  it "returns codes" do
    out, _err, = capture_io do
      translate_list_codes project_id: project_id
    end
    out_lines = out.split "\n"
    assert_includes out_lines, "af"
    assert_includes out_lines, "am"
    assert_includes out_lines, "ar"
    assert_includes out_lines, "az"
    assert_includes out_lines, "be"
  end
end
