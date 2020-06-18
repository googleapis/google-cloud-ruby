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
require_relative "../translate_list_language_names"

describe "translate_list_language_names", :translate do
  it "returns names" do
    out, _err, = capture_io do
      translate_list_language_names project_id: project_id
    end
    out_lines = out.split "\n"
    assert_includes out_lines, "af Afrikaans"
    assert_includes out_lines, "am Amharic"
    assert_includes out_lines, "ar Arabic"
    assert_includes out_lines, "az Azerbaijani"
    assert_includes out_lines, "be Belarusian"
  end
end
