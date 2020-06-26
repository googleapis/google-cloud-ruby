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

require_relative "../detect_faces"

describe "Detect Faces" do
  it "detect faces from local image file" do
    assert_output(/Surprise: VERY_UNLIKELY/) do
      detect_faces image_path: image_path("face_no_surprise.png")
    end
  end

  it "detect faces from image file in Google Cloud Storage" do
    assert_output(/Surprise: LIKELY/) do
      detect_faces image_path: gs_url("face_surprise.jpg")
    end
  end
end
