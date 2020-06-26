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

require_relative "../detect_safe_search"

describe "Detect Safe Search Properties" do
  it "detect safe search properties from local image file" do
    assert_output(/Violence: VERY_UNLIKELY/) do
      detect_safe_search image_path: image_path("otter_crossing.jpg")
    end
  end

  it "detect safe search properties from image file in Google Cloud Storage" do
    assert_output(/Violence: VERY_UNLIKELY/) do
      detect_safe_search_gcs image_path: gs_url("otter_crossing.jpg")
    end
  end
end
