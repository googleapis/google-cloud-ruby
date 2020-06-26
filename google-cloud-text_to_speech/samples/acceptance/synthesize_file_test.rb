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
require "securerandom"
require_relative "../synthesize_file"

describe "Synthesize File" do
  it "synthesizes text file" do
    output_file = "output_#{SecureRandom.hex}.mp3"
    out, err = capture_io do
      synthesize_text_file text_file: "resources/hello.txt", output_file: output_file
    end

    assert_empty err
    assert_match(/Audio content written to file/, out)

    output_filepath = File.expand_path "../#{output_file}", __dir__
    assert File.exist?(output_filepath)
    assert File.size(output_filepath).positive?

    File.delete output_filepath
    refute File.exist?(output_filepath)
  end

  it "synthesizes ssml file" do
    output_file = "output_#{SecureRandom.hex}.mp3"
    out, err = capture_io do
      synthesize_ssml_file ssml_file: "resources/hello.ssml", output_file: output_file
    end

    assert_empty err
    assert_match(/Audio content written to file/, out)

    output_filepath = File.expand_path "../#{output_file}", __dir__
    assert File.exist?(output_filepath)
    assert File.size(output_filepath).positive?

    File.delete output_filepath
    refute File.exist?(output_filepath)
  end
end
