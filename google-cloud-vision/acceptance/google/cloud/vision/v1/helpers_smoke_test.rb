# Copyright 2018 Google LLC
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

require "minitest/autorun"
require "minitest/spec"

require "google/cloud/vision"
require "google/cloud/vision/v1/image_annotator_client"

describe Google::Cloud::Vision::V1::ImageAnnotatorClient do
  let(:gs_image) { "gs://gapic-toolkit/President_Barack_Obama.jpg" }
  let(:image_annotator_client) { Google::Cloud::Vision::ImageAnnotator.new(version: :v1) }
  let(:options) do
    {
      images: [], 
      image: "gs://gapic-toolkit/President_Barack_Obama.jpg",
      max_results: 10,
      async: false,
      mime_type: nil,
      batch_size: 10,
      destination: nil,
      image_context: {}
    }
  end

  it "can successfully make face_detection requests" do
    response = image_annotator_client.face_detection image: gs_image
    refute_empty(response.responses)
  end
  
  it "can successfully make landmark_detection requests" do
    response = image_annotator_client.landmark_detection image: gs_image
    refute_empty(response.responses)
  end
  
  it "can successfully make logo_detection requests" do
    response = image_annotator_client.logo_detection image: gs_image
    refute_empty(response.responses)
  end
  
  it "can successfully make label_detection requests" do
    response = image_annotator_client.label_detection image: gs_image
    refute_empty(response.responses)
  end
  
  it "can successfully make text_detection requests" do
    response = image_annotator_client.text_detection image: gs_image
    refute_empty(response.responses)
  end
  
  it "can successfully make document_text_detection requests" do
    response = image_annotator_client.document_text_detection image: gs_image
    refute_empty(response.responses)
  end
  
  it "can successfully make safe_search_detection requests" do
    response = image_annotator_client.safe_search_detection image: gs_image
    refute_empty(response.responses)
  end
  
  it "can successfully make image_properties_detection requests" do
    response = image_annotator_client.image_properties_detection image: gs_image
    refute_empty(response.responses)
  end
  
  it "can successfully make web_detection requests" do
    response = image_annotator_client.web_detection image: gs_image
    refute_empty(response.responses)
  end
  
  it "can successfully make product_search_detection requests" do
    response = image_annotator_client.product_search_detection image: gs_image
    refute_empty(response.responses)
  end
  
  it "can successfully make object_localization_detection requests" do
    response = image_annotator_client.object_localization_detection image: gs_image
    refute_empty(response.responses)
  end
  
  it "can successfully make crop_hints_detection requests" do
    response = image_annotator_client.crop_hints_detection image: gs_image
    refute_empty(response.responses)
  end
  
  it "can successfully make label_detection requests and verify response" do
    response = image_annotator_client.label_detection **options
    labels = response.responses.map do |response|
      response.label_annotations.map { |label| label.description }
    end.flatten
    assert_includes(labels, "suit")
  end

  it "can successfully make face_detection requests and verify response" do
    response = image_annotator_client.face_detection **options
    labels = response.responses.map do |response|
      response.face_annotations.map { |annotation| annotation.joy_likelihood }
    end.flatten
    assert_includes(labels, :VERY_LIKELY)
  end
end
