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
require_relative "../translate_text_with_model"

describe "translate_text_with_model", :translate do
  it "translates English to French" do
    out, _err = capture_io do
      translate_text_with_model project_id:    project_id,
                                language_code: "fr",
                                text:          "Alice and Bob are kind"
    end
    assert_match(/Original language: en translated to: fr/, out)
    assert_match(/Translated 'Alice and Bob are kind' to '"Alice et Bob sont gentils"'/, out)
  end
end
