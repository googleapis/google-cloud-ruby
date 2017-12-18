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

describe Google::Cloud::Vision::Image, :crop_hints, :mock_vision do
  let(:filepath) { "acceptance/data/face.jpg" }
  let(:image)    { vision.image filepath }

  it "detects multiple crop hints" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :CROP_HINTS, max_results: 10)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, crop_hints_annotation_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock

    crop_hints = image.crop_hints 10
    mock.verify

    crop_hints.count.must_equal 1
    crop_hint = crop_hints.first
    crop_hint.bounds.count.must_equal 4
    crop_hint.bounds[0].must_be_kind_of Google::Cloud::Vision::Annotation::Vertex
    crop_hint.bounds.map(&:to_a).must_equal [[1, 0], [295, 0], [295, 301], [1, 301]]
    crop_hint.confidence.must_equal 1.0
    crop_hint.importance_fraction.must_equal 1.0399999618530273
  end

  it "detects multiple crop hints without specifying a count" do
    feature = Google::Cloud::Vision::V1::Feature.new(type: :CROP_HINTS, max_results: 100)
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [feature]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, crop_hints_annotation_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock

    crop_hints = image.crop_hints
    mock.verify

    crop_hints.count.must_equal 1
    crop_hint = crop_hints.first
    crop_hint.bounds.count.must_equal 4
    crop_hint.bounds[0].must_be_kind_of Google::Cloud::Vision::Annotation::Vertex
    crop_hint.bounds.map(&:to_a).must_equal [[1, 0], [295, 0], [295, 301], [1, 301]]
    crop_hint.confidence.must_equal 1.0
    crop_hint.importance_fraction.must_equal 1.0399999618530273
  end
end
