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

describe Google::Cloud::Vision::Project, :annotate, :text, :mock_vision do
  let(:filepath) { "acceptance/data/text.png" }

  it "detects text detection" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :TEXT_DETECTION, max_results: 1)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, text_response_grpc, [req]

    vision.service.mocked_service = mock
    annotation = vision.annotate filepath, text: true
    mock.verify

    annotation.wont_be :nil?
    annotation.text.wont_be :nil?
    annotation.text.text.must_include "Google Cloud Client for Ruby"
    annotation.text.locale.must_equal "en"
    annotation.text.words.count.must_equal 28
    annotation.text.words[0].text.must_equal "Google"
    annotation.text.words[0].bounds.map(&:to_a).must_equal [[13, 8], [53, 8], [53, 23], [13, 23]]
    annotation.text.words[27].text.must_equal "Storage."
    annotation.text.words[27].bounds.map(&:to_a).must_equal [[304, 59], [351, 59], [351, 74], [304, 74]]
  end

  it "detects text detection using mark alias" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :TEXT_DETECTION, max_results: 1)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, text_response_grpc, [req]

    vision.service.mocked_service = mock
    annotation = vision.mark filepath, text: true
    mock.verify

    annotation.wont_be :nil?
    annotation.text.wont_be :nil?
  end

  it "detects text detection using detect alias" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :TEXT_DETECTION, max_results: 1)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, text_response_grpc, [req]

    vision.service.mocked_service = mock
    annotation = vision.detect filepath, text: true
    mock.verify

    annotation.wont_be :nil?
    annotation.text.wont_be :nil?
  end

  it "detects text detection on multiple images" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :TEXT_DETECTION, max_results: 1)
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
    mock.expect :batch_annotate_images, texts_response_grpc, [req]

    vision.service.mocked_service = mock
    annotations = vision.annotate filepath, filepath, text: true
    mock.verify

    annotations.count.must_equal 2
    annotations.first.text.wont_be :nil?
    annotations.last.text.wont_be :nil?
  end

  it "uses the default configuration when given a truthy value" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :TEXT_DETECTION, max_results: 1)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, text_response_grpc, [req]

    vision.service.mocked_service = mock
    annotation = vision.annotate filepath, text: "totes"
    mock.verify

    annotation.wont_be :nil?
    annotation.text.wont_be :nil?
    annotation.text.text.must_include "Google Cloud Client for Ruby"
    annotation.text.locale.must_equal "en"
    annotation.text.words.count.must_equal 28
    annotation.text.words[0].text.must_equal "Google"
    annotation.text.words[0].bounds.map(&:to_a).must_equal [[13, 8], [53, 8], [53, 23], [13, 23]]
    annotation.text.words[27].text.must_equal "Storage."
    annotation.text.words[27].bounds.map(&:to_a).must_equal [[304, 59], [351, 59], [351, 74], [304, 74]]
  end

  def text_response_grpc
    Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(
      responses: [
        Google::Cloud::Vision::V1::AnnotateImageResponse.new(
          text_annotations: text_annotation_responses
        )
      ]
    )
  end

  def texts_response_grpc
    Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(
      responses: [
        Google::Cloud::Vision::V1::AnnotateImageResponse.new(
          text_annotations: text_annotation_responses
        ),
        Google::Cloud::Vision::V1::AnnotateImageResponse.new(
          text_annotations: text_annotation_responses
        )
      ]
    )
  end
end
