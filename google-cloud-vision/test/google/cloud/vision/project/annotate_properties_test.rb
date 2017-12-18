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

describe Google::Cloud::Vision::Project, :annotate, :properties, :mock_vision do
  let(:filepath) { "acceptance/data/face.jpg" }

  it "detects properties detection" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :IMAGE_PROPERTIES, max_results: 1)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, properties_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    annotation = vision.annotate filepath, properties: true
    mock.verify

    annotation.wont_be :nil?

    annotation.properties.colors.count.must_equal 10

    annotation.properties.colors[0].red.must_equal 145
    annotation.properties.colors[0].green.must_equal 193
    annotation.properties.colors[0].blue.must_equal 254
    annotation.properties.colors[0].alpha.must_equal 1.0
    annotation.properties.colors[0].rgb.must_equal "91c1fe"
    annotation.properties.colors[0].score.must_be_close_to 0.65757853
    annotation.properties.colors[0].pixel_fraction.must_be_close_to 0.16903226

    annotation.properties.colors[9].red.must_equal 156
    annotation.properties.colors[9].green.must_equal 214
    annotation.properties.colors[9].blue.must_equal 255
    annotation.properties.colors[9].alpha.must_equal 1.0
    annotation.properties.colors[9].rgb.must_equal "9cd6ff"
    annotation.properties.colors[9].score.must_be_close_to 0.00096750073
    annotation.properties.colors[9].pixel_fraction.must_be_close_to 0.00064516132
  end

  it "detects properties detection using mark alias" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :IMAGE_PROPERTIES, max_results: 1)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, properties_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    annotation = vision.mark filepath, properties: true
    mock.verify

    annotation.wont_be :nil?

    annotation.properties.colors.count.must_equal 10

    annotation.properties.colors[0].red.must_equal 145
    annotation.properties.colors[0].green.must_equal 193
    annotation.properties.colors[0].blue.must_equal 254
    annotation.properties.colors[0].alpha.must_equal 1.0
    annotation.properties.colors[0].rgb.must_equal "91c1fe"
    annotation.properties.colors[0].score.must_be_close_to 0.65757853
    annotation.properties.colors[0].pixel_fraction.must_be_close_to 0.16903226

    annotation.properties.colors[9].red.must_equal 156
    annotation.properties.colors[9].green.must_equal 214
    annotation.properties.colors[9].blue.must_equal 255
    annotation.properties.colors[9].alpha.must_equal 1.0
    annotation.properties.colors[9].rgb.must_equal "9cd6ff"
    annotation.properties.colors[9].score.must_be_close_to 0.00096750073
    annotation.properties.colors[9].pixel_fraction.must_be_close_to 0.00064516132
  end

  it "detects properties detection using detect alias" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :IMAGE_PROPERTIES, max_results: 1)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, properties_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    annotation = vision.detect filepath, properties: true
    mock.verify

    annotation.wont_be :nil?

    annotation.properties.colors.count.must_equal 10

    annotation.properties.colors[0].red.must_equal 145
    annotation.properties.colors[0].green.must_equal 193
    annotation.properties.colors[0].blue.must_equal 254
    annotation.properties.colors[0].alpha.must_equal 1.0
    annotation.properties.colors[0].rgb.must_equal "91c1fe"
    annotation.properties.colors[0].score.must_be_close_to 0.65757853
    annotation.properties.colors[0].pixel_fraction.must_be_close_to 0.16903226

    annotation.properties.colors[9].red.must_equal 156
    annotation.properties.colors[9].green.must_equal 214
    annotation.properties.colors[9].blue.must_equal 255
    annotation.properties.colors[9].alpha.must_equal 1.0
    annotation.properties.colors[9].rgb.must_equal "9cd6ff"
    annotation.properties.colors[9].score.must_be_close_to 0.00096750073
    annotation.properties.colors[9].pixel_fraction.must_be_close_to 0.00064516132
  end

  it "detects properties detection on multiple images" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :IMAGE_PROPERTIES, max_results: 1)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      ),
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, plural_properties_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    annotations = vision.annotate filepath, filepath, properties: true
    mock.verify

    annotations.count.must_equal 2

    annotations[0].properties.colors.count.must_equal 10

    annotations[0].properties.colors[0].red.must_equal 145
    annotations[0].properties.colors[0].green.must_equal 193
    annotations[0].properties.colors[0].blue.must_equal 254
    annotations[0].properties.colors[0].alpha.must_equal 1.0
    annotations[0].properties.colors[0].rgb.must_equal "91c1fe"
    annotations[0].properties.colors[0].score.must_be_close_to 0.65757853
    annotations[0].properties.colors[0].pixel_fraction.must_be_close_to 0.16903226

    annotations[0].properties.colors[9].red.must_equal 156
    annotations[0].properties.colors[9].green.must_equal 214
    annotations[0].properties.colors[9].blue.must_equal 255
    annotations[0].properties.colors[9].alpha.must_equal 1.0
    annotations[0].properties.colors[9].rgb.must_equal "9cd6ff"
    annotations[0].properties.colors[9].score.must_be_close_to 0.00096750073
    annotations[0].properties.colors[9].pixel_fraction.must_be_close_to 0.00064516132

    annotations[1].properties.colors.count.must_equal 10

    annotations[1].properties.colors[0].red.must_equal 145
    annotations[1].properties.colors[0].green.must_equal 193
    annotations[1].properties.colors[0].blue.must_equal 254
    annotations[1].properties.colors[0].alpha.must_equal 1.0
    annotations[1].properties.colors[0].rgb.must_equal "91c1fe"
    annotations[1].properties.colors[0].score.must_be_close_to 0.65757853
    annotations[1].properties.colors[0].pixel_fraction.must_be_close_to 0.16903226

    annotations[1].properties.colors[9].red.must_equal 156
    annotations[1].properties.colors[9].green.must_equal 214
    annotations[1].properties.colors[9].blue.must_equal 255
    annotations[1].properties.colors[9].alpha.must_equal 1.0
    annotations[1].properties.colors[9].rgb.must_equal "9cd6ff"
    annotations[1].properties.colors[9].score.must_be_close_to 0.00096750073
    annotations[1].properties.colors[9].pixel_fraction.must_be_close_to 0.00064516132
  end

  it "uses the default configuration when given a truthy value" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :IMAGE_PROPERTIES, max_results: 1)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, properties_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    annotation = vision.annotate filepath, properties: "please"
    mock.verify

    annotation.wont_be :nil?

    annotation.properties.colors.count.must_equal 10

    annotation.properties.colors[0].red.must_equal 145
    annotation.properties.colors[0].green.must_equal 193
    annotation.properties.colors[0].blue.must_equal 254
    annotation.properties.colors[0].alpha.must_equal 1.0
    annotation.properties.colors[0].rgb.must_equal "91c1fe"
    annotation.properties.colors[0].score.must_be_close_to 0.65757853
    annotation.properties.colors[0].pixel_fraction.must_be_close_to 0.16903226

    annotation.properties.colors[9].red.must_equal 156
    annotation.properties.colors[9].green.must_equal 214
    annotation.properties.colors[9].blue.must_equal 255
    annotation.properties.colors[9].alpha.must_equal 1.0
    annotation.properties.colors[9].rgb.must_equal "9cd6ff"
    annotation.properties.colors[9].score.must_be_close_to 0.00096750073
    annotation.properties.colors[9].pixel_fraction.must_be_close_to 0.00064516132
  end

  def properties_response_grpc
    Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(
      responses: [
        Google::Cloud::Vision::V1::AnnotateImageResponse.new(
          image_properties_annotation: properties_annotation_response
        )
      ]
    )
  end

  def plural_properties_response_grpc
    Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(
      responses: [
        Google::Cloud::Vision::V1::AnnotateImageResponse.new(
          image_properties_annotation: properties_annotation_response
        ),
        Google::Cloud::Vision::V1::AnnotateImageResponse.new(
          image_properties_annotation: properties_annotation_response
        )
      ]
    )
  end
end
