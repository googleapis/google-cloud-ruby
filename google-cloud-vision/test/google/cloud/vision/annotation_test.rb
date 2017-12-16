# Copyright 2017 Google LLC
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

describe Google::Cloud::Vision::Annotation, :mock_vision do
  let(:filepath) { "acceptance/data/face.jpg" }
  let(:annotation_keys) { [:faces, :landmarks, :logos, :labels, :text, :safe_search, :properties, :crop_hints, :web] }
  let(:entity_keys) { [:mid, :locale, :description, :score, :confidence, :topicality, :bounds, :locations, :properties] }

  it "returns a deep hash copy of itself" do
    req = [
      Google::Cloud::Vision::V1::AnnotateImageRequest.new(
        image: Google::Cloud::Vision::V1::Image.new(content: File.read(filepath, mode: "rb")),
        features: [
          Google::Cloud::Vision::V1::Feature.new(type: :FACE_DETECTION, max_results: 100),
          Google::Cloud::Vision::V1::Feature.new(type: :LANDMARK_DETECTION, max_results: 100),
          Google::Cloud::Vision::V1::Feature.new(type: :LOGO_DETECTION, max_results: 100),
          Google::Cloud::Vision::V1::Feature.new(type: :LABEL_DETECTION, max_results: 100),
          Google::Cloud::Vision::V1::Feature.new(type: :TEXT_DETECTION, max_results: 1),
          Google::Cloud::Vision::V1::Feature.new(type: :DOCUMENT_TEXT_DETECTION, max_results: 1),
          Google::Cloud::Vision::V1::Feature.new(type: :SAFE_SEARCH_DETECTION, max_results: 1),
          Google::Cloud::Vision::V1::Feature.new(type: :IMAGE_PROPERTIES, max_results: 1),
          Google::Cloud::Vision::V1::Feature.new(type: :CROP_HINTS, max_results: 100),
          Google::Cloud::Vision::V1::Feature.new(type: :WEB_DETECTION, max_results: 100)
        ]
      )
    ]
    mock = Minitest::Mock.new
    mock.expect :batch_annotate_images, full_response_grpc, [req, options: default_options]

    vision.service.mocked_service = mock
    annotation = vision.annotate filepath
    mock.verify

    hash = annotation.to_h
    hash.keys.must_equal annotation_keys

    hash[:faces].wont_be :nil?
    hash[:faces].must_be_kind_of Array
    hash[:faces][0].must_be_kind_of Hash
    hash[:faces][0].keys.must_equal [:angles, :bounds, :features, :likelihood]

    hash[:landmarks].wont_be :nil?
    hash[:landmarks].must_be_kind_of Array
    hash[:landmarks][0].must_be_kind_of Hash
    hash[:landmarks][0].keys.must_equal entity_keys

    hash[:logos].wont_be :nil?
    hash[:logos].must_be_kind_of Array
    hash[:logos][0].must_be_kind_of Hash
    hash[:logos][0].keys.must_equal entity_keys

    hash[:labels].wont_be :nil?
    hash[:labels].must_be_kind_of Array
    hash[:labels][0].must_be_kind_of Hash
    hash[:labels][0].keys.must_equal entity_keys

    hash[:text].wont_be :nil?
    hash[:text].must_be_kind_of Hash
    hash[:text].keys.must_equal [:text, :locale, :bounds, :words, :pages]

    hash[:safe_search].wont_be :nil?
    hash[:safe_search].must_be_kind_of Hash
    hash[:safe_search].keys.must_equal [:adult, :spoof, :medical, :violence]

    hash[:properties].wont_be :nil?
    hash[:properties].must_be_kind_of Hash
    hash[:properties].keys.must_equal [:colors]

    hash[:crop_hints].wont_be :nil?
    hash[:crop_hints].must_be_kind_of Array
    hash[:crop_hints][0].must_be_kind_of Hash
    hash[:crop_hints][0].keys.must_equal [:bounds, :confidence, :importance_fraction]

    hash[:web].wont_be :nil?
    hash[:web].must_be_kind_of Hash
    hash[:web].keys.must_equal [:entities, :full_matching_images, :partial_matching_images, :pages_with_matching_images]
  end
end
