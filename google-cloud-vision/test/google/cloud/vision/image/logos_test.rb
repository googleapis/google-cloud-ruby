# Copyright 2016 Google LLC
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

require "helper"
require "pathname"

describe Google::Cloud::Vision::Image, :logos, :mock_vision do
  let(:filepath) { "acceptance/data/logo.jpg" }
  let(:image)    { vision.image filepath }

  it "detects multiple logos" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :LOGO_DETECTION, max_results: 10)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, logos_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    logos = image.logos 10
    mock.verify

    logos.count.must_equal 5
  end

  it "detects multiple logos without specifying a count" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :LOGO_DETECTION, max_results: 100)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, logos_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    logos = image.logos
    mock.verify

    logos.count.must_equal 5
  end

  it "detects a logo" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :LOGO_DETECTION, max_results: 1)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, logo_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    logo = image.logo
    mock.verify

    logo.wont_be :nil?
  end

  def logo_response_grpc
    Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(
      responses: [
        Google::Cloud::Vision::V1::AnnotateImageResponse.new(
          logo_annotations: [
            logo_annotation_response
          ]
        )
      ]
    )
  end

  def logos_response_grpc
    Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(
      responses: [
        Google::Cloud::Vision::V1::AnnotateImageResponse.new(
          logo_annotations: [
            logo_annotation_response,
            logo_annotation_response,
            logo_annotation_response,
            logo_annotation_response,
            logo_annotation_response
          ]
        )
      ]
    )
  end
end
