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

require "google/cloud/storage"

require_relative "../detect_landmarks"

describe "Detect Landmarks" do
  it "detect landmarks from local image file" do
    assert_output(/Palace/) do
      detect_landmarks image_path: image_path("palace_of_fine_arts.jpg")
    end
  end

  it "detect landmarks from image file in Google Cloud Storage" do
    gcs_uri = "gs://cloud-samples-data/vision/palace_of_fine_arts.jpg"

    assert_output(/Palace/) do
      detect_landmarks_gcs image_path: gcs_uri
    end
  end
end
