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

require_relative "../detect_crop_hints"

class FakeAnnotator < Google::Cloud::Vision::V1::ImageAnnotator::Client
  def batch_annotate_images _request, _options
    Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(
      responses: [
        Google::Cloud::Vision::V1::AnnotateImageResponse.new(
          crop_hints_annotation: Google::Cloud::Vision::V1::CropHintsAnnotation.new(
            crop_hints: [
              Google::Cloud::Vision::V1::CropHint.new(
                bounding_poly: Google::Cloud::Vision::V1::BoundingPoly.new(
                  vertices: [Google::Cloud::Vision::V1::Vertex.new(x: 1234, y: 1234)]
                )
              )
            ]
          )
        )
      ]
    )
  end
end

describe "Detect Crop Hints" do
  # Returns full path to sample image included in repository for testing
  def image_path filename
    File.expand_path "../resources/#{filename}", __dir__
  end

  it "detect crop hints from local image file" do
    Google::Cloud::Vision::V1::ImageAnnotator::Client.stub :new, FakeAnnotator.new do
      assert_output(/1234, 1234/) do
        detect_crop_hints image_path: image_path("otter_crossing.jpg")
      end
    end
  end

  it "detect crop hints from image file in Google Cloud Storage" do
    Google::Cloud::Vision::V1::ImageAnnotator::Client.stub :new, FakeAnnotator.new do
      assert_output(/1234, 1234/) do
        detect_crop_hints_gcs image_path: "gs://my-bucket/image.png"
      end
    end
  end
end
