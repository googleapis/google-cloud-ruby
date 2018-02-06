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

describe "ImageAnnotatorFeatureMethods" do
  it "detects faces using GCS" do
    image_annotator_client = Google::Cloud::Vision.new
    response = image_annotator_client.face_detection(
      "gs://gapic-toolkit/President_Barack_Obama.jpg"
    )
    assert(response.face_annotations.size >= 1)
  end

  it "detects text from a local image" do
    image_annotator_client = Google::Cloud::Vision.new
    response = image_annotator_client.text_detection("acceptance/data/text.png")
    assert(response.text_annotations.size >= 5)
    assert(
      response.full_text_annotation.text.include?(
        "Google Cloud Client Library for Ruby"
      )
    )
  end

  it "detects a landmark from a local image" do
    image_annotator_client = Google::Cloud::Vision.new
    response = image_annotator_client.landmark_detection(
      "acceptance/data/landmark.jpg"
    )
    assert(response.landmark_annotations.size >= 1)
    assert(
      response.landmark_annotations.map(&:description).include?(
        "Mount Rushmore"
      )
    )
  end

  it "detects a face from a local image" do
    image_annotator_client = Google::Cloud::Vision.new
    response = image_annotator_client.face_detection("acceptance/data/face.jpg")
    assert(response.face_annotations.size >= 1)
  end

  it "detects a logo from a local image" do
    image_annotator_client = Google::Cloud::Vision.new
    response = image_annotator_client.logo_detection("acceptance/data/logo.jpg")
    assert(response.logo_annotations.size >= 1)
    assert(
      response.logo_annotations.map(&:description).include?(
        "Google"
      )
    )
  end

  it "detects multiple features when none specified" do
    image_annotator_client = Google::Cloud::Vision.new
    response = image_annotator_client.annotate_image(
      "gs://gapic-toolkit/President_Barack_Obama.jpg"
    )
    assert(response.face_annotations.size >= 1)
    assert(response.label_annotations.size >= 1)
    assert(response.crop_hints_annotation.crop_hints.size >= 1)
  end

  it "detects multiple specified features" do
    image_annotator_client = Google::Cloud::Vision.new
    response = image_annotator_client.annotate_image(
      "gs://gapic-toolkit/President_Barack_Obama.jpg",
      features: [{ type: :FACE_DETECTION }, { type: :CROP_HINTS }]
    )
    assert(response.face_annotations.size >= 1)
    assert(response.crop_hints_annotation.crop_hints.size >= 1)

    # Label annotations were not requested, so should be empty
    assert(response.label_annotations.empty?)
  end
end
