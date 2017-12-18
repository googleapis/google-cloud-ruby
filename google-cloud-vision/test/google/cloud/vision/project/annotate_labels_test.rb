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

describe Google::Cloud::Vision::Project, :annotate, :labels, :mock_vision do
  let(:filepath) { "acceptance/data/landmark.jpg" }

  it "detects label detection" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :LABEL_DETECTION, max_results: 1)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, label_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    annotation = vision.annotate filepath, labels: 1
    mock.verify

    annotation.wont_be :nil?
    annotation.label.wont_be :nil?
  end

  it "detects label detection using mark alias" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :LABEL_DETECTION, max_results: 1)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, label_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    annotation = vision.mark filepath, labels: 1
    mock.verify

    annotation.wont_be :nil?
    annotation.label.wont_be :nil?
  end

  it "detects label detection using detect alias" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :LABEL_DETECTION, max_results: 1)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, label_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    annotation = vision.detect filepath, labels: 1
    mock.verify

    annotation.wont_be :nil?
    annotation.label.wont_be :nil?
  end

  it "detects label detection on multiple images" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :LABEL_DETECTION, max_results: 1)
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
    mock.expect :batch_annotate_images, labels_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    annotations = vision.annotate filepath, filepath, labels: 1
    mock.verify

    annotations.count.must_equal 2
    annotations.first.label.wont_be :nil?
    annotations.last.label.wont_be :nil?
  end

  it "uses the default configuration" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :LABEL_DETECTION, max_results: Google::Cloud::Vision.default_max_labels)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, label_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    annotation = vision.annotate filepath, labels: true
    mock.verify

    annotation.wont_be :nil?
    annotation.label.wont_be :nil?
  end

  it "uses the default configuration when given a truthy value" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :LABEL_DETECTION, max_results: Google::Cloud::Vision.default_max_labels)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, label_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    annotation = vision.annotate filepath, labels: "9999"
    mock.verify

    annotation.wont_be :nil?
    annotation.label.wont_be :nil?
  end

  it "uses the updated configuration" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :LABEL_DETECTION, max_results: 25)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, label_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    Google::Cloud::Vision.stub :default_max_labels, 25 do
      annotation = vision.annotate filepath, labels: "9999"
      annotation.wont_be :nil?
      annotation.label.wont_be :nil?
    end
    mock.verify
  end

  def label_response_grpc
    Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(
      responses: [
        Google::Cloud::Vision::V1::AnnotateImageResponse.new(
          label_annotations: [
            label_annotation_response
          ]
        )
      ]
    )
  end

  def labels_response_grpc
    Google::Cloud::Vision::V1::BatchAnnotateImagesResponse.new(
      responses: [
        Google::Cloud::Vision::V1::AnnotateImageResponse.new(
          label_annotations: [
            label_annotation_response
          ]
        ),
        Google::Cloud::Vision::V1::AnnotateImageResponse.new(
          label_annotations: [
            label_annotation_response
          ]
        )
      ]
    )
  end

end
