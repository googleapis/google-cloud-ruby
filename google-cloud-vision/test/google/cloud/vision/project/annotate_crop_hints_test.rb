# Copyright 2016 Google LLC
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

describe Google::Cloud::Vision::Project, :annotate, :crop_hints, :mock_vision do
  let(:filepath) { "acceptance/data/face.jpg" }

  it "detects crop hints" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :CROP_HINTS, max_results: 1)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, crop_hints_annotation_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    annotation = vision.annotate filepath, crop_hints: 1
    mock.verify

    crop_hints = annotation.crop_hints
    crop_hints.count.must_equal 1
    crop_hint = crop_hints.first
    crop_hint.bounds.count.must_equal 4
    crop_hint.bounds[0].must_be_kind_of Google::Cloud::Vision::Annotation::Vertex
    crop_hint.bounds.map(&:to_a).must_equal [[1, 0], [295, 0], [295, 301], [1, 301]]
    crop_hint.confidence.must_equal 1.0
    crop_hint.importance_fraction.must_equal 1.0399999618530273
  end

  it "detects crop hints using mark alias" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :CROP_HINTS, max_results: 1)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, crop_hints_annotation_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    annotation = vision.mark filepath, crop_hints: 1
    mock.verify

    annotation.wont_be :nil?
    annotation.crop_hints.wont_be :nil?
  end

  it "detects crop hints using detect alias" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :CROP_HINTS, max_results: 1)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, crop_hints_annotation_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    annotation = vision.detect filepath, crop_hints: 1
    mock.verify

    annotation.wont_be :nil?
    annotation.crop_hints.wont_be :nil?
  end

  it "uses the default configuration when given a truthy value" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :CROP_HINTS, max_results: Google::Cloud::Vision.default_max_crop_hints)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, crop_hints_annotation_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    annotation = vision.annotate filepath, crop_hints: "9999"
    mock.verify

    crop_hints = annotation.crop_hints
    crop_hints.count.must_equal 1
    crop_hint = crop_hints.first
    crop_hint.bounds.count.must_equal 4
    crop_hint.bounds[0].must_be_kind_of Google::Cloud::Vision::Annotation::Vertex
    crop_hint.bounds.map(&:to_a).must_equal [[1, 0], [295, 0], [295, 301], [1, 301]]
    crop_hint.confidence.must_equal 1.0
    crop_hint.importance_fraction.must_equal 1.0399999618530273
  end
end
