# Copyright 2016 Google Inc. All rights reserved.
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

require "helper"
require "pathname"

describe Google::Cloud::Vision::Image, :properties, :mock_vision do
  let(:filepath) { "../acceptance/data/face.jpg" }
  let(:image)    { vision.image filepath }

  it "detects properties" do
    feature = Google::Apis::VisionV1::Feature.new(type: "IMAGE_PROPERTIES", max_results: 1)
    req = Google::Apis::VisionV1::BatchAnnotateImagesRequest.new(
      requests: [
        Google::Apis::VisionV1::AnnotateImageRequest.new(
          image: Google::Apis::VisionV1::Image.new(content: File.read(filepath, mode: "rb")),
          features: [feature]
        )
      ]
    )
    mock = Minitest::Mock.new
    mock.expect :annotate_image, properties_response_gapi, [req]

    vision.service.mocked_service = mock
    properties = image.properties
    mock.verify

    properties.colors.count.must_equal 10

    properties.colors[0].red.must_equal 145
    properties.colors[0].green.must_equal 193
    properties.colors[0].blue.must_equal 254
    properties.colors[0].alpha.must_equal 1.0
    properties.colors[0].rgb.must_equal "91c1fe"
    properties.colors[0].score.must_equal 0.65757853
    properties.colors[0].pixel_fraction.must_equal 0.16903226

    properties.colors[9].red.must_equal 156
    properties.colors[9].green.must_equal 214
    properties.colors[9].blue.must_equal 255
    properties.colors[9].alpha.must_equal 1.0
    properties.colors[9].rgb.must_equal "9cd6ff"
    properties.colors[9].score.must_equal 0.00096750073
    properties.colors[9].pixel_fraction.must_equal 0.00064516132
  end

  def properties_response_gapi
    Google::Apis::VisionV1::BatchAnnotateImagesResponse.new(
      responses: [
        Google::Apis::VisionV1::AnnotateImageResponse.new(
          image_properties_annotation: properties_annotation_response
        )
      ]
    )
  end
end
