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

require "google/cloud/vision/v1"

class ImageAnnotatorHelpersSmokeTest < Minitest::Test
  def gs_image
    "gs://gcloud-ruby-acceptance-public-read/obama-happy.jpg"
  end

  def image_annotator_client
    Google::Cloud::Vision::V1::ImageAnnotator::Client.new
  end

  def options
    {
      images: [],
      image: gs_image,
      max_results: 10,
      async: false,
      mime_type: nil,
      batch_size: 10,
      destination: nil,
      image_context: {}
    }
  end

  def test_crop_hints_detection_request
    response = image_annotator_client.crop_hints_detection image: gs_image
    refute_empty response.responses
  end

  def test_document_text_detection_request
    response = image_annotator_client.document_text_detection image: gs_image
    refute_empty response.responses
  end

  def test_face_detection_request
    response = image_annotator_client.face_detection image: gs_image
    refute_empty response.responses
  end

  def test_image_properties_detection_request
    response = image_annotator_client.image_properties_detection image: gs_image
    refute_empty response.responses
  end

  def test_label_detection_request
    response = image_annotator_client.label_detection image: gs_image
    refute_empty response.responses
  end

  def test_landmark_detection_request
    response = image_annotator_client.landmark_detection image: gs_image
    refute_empty response.responses
  end

  def test_logo_detection_request
    response = image_annotator_client.logo_detection image: gs_image
    refute_empty response.responses
  end

  def test_object_localization_detection_request
    response = image_annotator_client.object_localization_detection image: gs_image
    refute_empty response.responses
  end

  def test_product_search_detection_request
    response = image_annotator_client.product_search_detection image: gs_image
    refute_empty response.responses
  end

  def test_safe_search_detection_request
    response = image_annotator_client.safe_search_detection image: gs_image
    refute_empty response.responses
  end

  def test_text_detection_request
    response = image_annotator_client.text_detection image: gs_image
    refute_empty response.responses
  end

  def test_web_detection_request
    response = image_annotator_client.web_detection image: gs_image
    refute_empty response.responses
  end

  def test_label_detection_response
    response = image_annotator_client.label_detection(**options)
    labels = response.responses.map do |response|
      response.label_annotations.map(&:description)
    end.flatten
    refute_empty labels
  end

  def test_face_detection_response
    response = image_annotator_client.face_detection(**options)
    labels = response.responses.map do |response|
      response.face_annotations.map(&:joy_likelihood)
    end.flatten
    assert_includes(labels, :VERY_LIKELY)
  end
end
