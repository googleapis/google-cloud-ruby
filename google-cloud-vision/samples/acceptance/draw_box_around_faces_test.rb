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

require "tempfile"

require_relative "../draw_box_around_faces"

describe "Draw box around faces sample" do
  it "box-in face" do
    output_image_file = Tempfile.new "cloud-vision-testing"
    assert File.size(output_image_file.path).zero?

    begin
      out, err = capture_io do
        draw_box_around_faces path_to_image_file:  image_path("face_no_surprise.png"),
                              path_to_output_file: output_image_file.path
      end

      assert_empty err
      assert_match(/Face bounds:/, out)
      assert_match(/\(\d+, \d+\)\n\(\d+, \d+\)\n\(\d+, \d+\)\n\(\d+, \d+\)\n/, out)
      assert File.size(output_image_file.path).positive?
    ensure
      output_image_file.close
      output_image_file.unlink
    end
  end
end
