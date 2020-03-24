# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "simplecov"
require "minitest/autorun"
require "minitest/spec"

require "google/cloud/vision/v1p3beta1"

class ImageAnnotatorHelpersSmokeTest < Minitest::Test
  def test_batch_annotate_images
    client = Google::Cloud::Vision::V1p3beta1::ImageAnnotator::Client.new
    request = {
      image: {
        source: {
          gcs_image_uri: "gs://cloud-samples-data/vision/face_detection/celebrity_recognition/sergey.jpg"
        }
      },
      features: [
        {
          type: :FACE_DETECTION
        }
      ]
    }
    response = client.batch_annotate_images requests: [request]
    assert_equal 1, response.responses.size
    assert_equal 1, response.responses.first.face_annotations.size
  end
end
