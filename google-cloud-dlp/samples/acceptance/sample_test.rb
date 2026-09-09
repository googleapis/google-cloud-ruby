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

require "minitest/autorun"
require_relative "../sample"

describe "DLP sample" do
  before do
    @project = ENV["GOOGLE_CLOUD_PROJECT"]
  end

  it "can inspect name in string" do
    out, err = capture_io do
      inspect_string project_id: @project, content: "Robert Frost"
    end

    assert_empty err
    assert_match(
      "Quote:      Robert Frost\n" \
      "Info type:  PERSON_NAME\n" \
      "Likelihood: LIKELY\n", out
    )
  end

  it "can limit max findings of inspect string results" do
    out, err = capture_io do
      inspect_string(
        project_id:   @project,
        content:      "Robert Frost is the name of poet Robert Frost",
        max_findings: 1
      )
    end
    assert_empty err
    assert_match(
      "Quote:      Robert Frost\n" \
      "Info type:  PERSON_NAME\n" \
      "Likelihood: LIKELY\n", out
    )
  end

  it "can inspect name in file" do
    out, err = capture_io do
      inspect_file project_id: @project, filename: "acceptance/data/test.txt"
    end
    assert_empty err
    assert_match(
      "Quote:      Robert Frost\n" \
      "Info type:  PERSON_NAME\n" \
      "Likelihood: LIKELY\n", out
    )
  end
end
