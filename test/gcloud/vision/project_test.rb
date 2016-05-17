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

describe Gcloud::Vision::Project, :mock_vision do
  let(:filepath) { "acceptance/data/face.jpg" }
  let(:area_json) { {"minLatLng"=>{"latitude"=>37.4220041, "longitude"=>-122.0862462},
                     "maxLatLng"=>{"latitude"=>37.4320041, "longitude"=>-122.0762462}} }

  it "knows the project identifier" do
    vision.must_be_kind_of Gcloud::Vision::Project
    vision.project.must_equal project
  end

  it "builds an image from filepath input" do
    image = vision.image filepath

    image.wont_be :nil?
    image.must_be_kind_of Gcloud::Vision::Image
    image.must_be :content?
    image.wont_be :url?
  end

  it "allows different annotation options for different images" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 2
      requests.first["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      requests.first["features"].count.must_equal 2
      requests.first["features"].first["type"].must_equal "FACE_DETECTION"
      requests.first["features"].first["maxResults"].must_equal 10
      requests.first["features"].last["type"].must_equal "TEXT_DETECTION"
      requests.first["features"].last["maxResults"].must_equal 1
      requests.last["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      requests.last["features"].count.must_equal 2
      requests.last["features"].first["type"].must_equal "LANDMARK_DETECTION"
      requests.last["features"].first["maxResults"].must_equal 20
      requests.last["features"].last["type"].must_equal "SAFE_SEARCH_DETECTION"
      requests.last["features"].last["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       faces_response_json]
    end

    annotations = vision.annotate do |a|
      a.annotate filepath, faces: 10, text: true
      a.annotate filepath, landmarks: 20, safe_search: true
    end
    annotations.count.must_equal 2
    annotations.first.face.wont_be :nil?
    annotations.last.face.wont_be :nil?
  end

  it "runs full annotation with empty options" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      request = requests.first
      request["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      request["features"].count.must_equal 7
      request["features"][0]["type"].must_equal "FACE_DETECTION"
      request["features"][0]["maxResults"].must_equal 10
      request["features"][1]["type"].must_equal "LANDMARK_DETECTION"
      request["features"][1]["maxResults"].must_equal 10
      request["features"][2]["type"].must_equal "LOGO_DETECTION"
      request["features"][2]["maxResults"].must_equal 10
      request["features"][3]["type"].must_equal "LABEL_DETECTION"
      request["features"][3]["maxResults"].must_equal 10
      request["features"][4]["type"].must_equal "TEXT_DETECTION"
      request["features"][4]["maxResults"].must_equal 1
      request["features"][5]["type"].must_equal "SAFE_SEARCH_DETECTION"
      request["features"][5]["maxResults"].must_equal 1
      request["features"][6]["type"].must_equal "IMAGE_PROPERTIES"
      request["features"][6]["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       full_response_json]
    end

    annotation = vision.annotate filepath
    annotation.wont_be :nil?
    annotation.face.wont_be :nil?
    annotation.landmark.wont_be :nil?
    annotation.logo.wont_be :nil?
    annotation.labels.wont_be :nil?

    annotation.wont_be :nil?
    annotation.text.wont_be :nil?
    annotation.text.text.must_include "Google Cloud Client Library for Ruby"
    annotation.text.locale.must_equal "en"
    annotation.text.words.count.must_equal 28
    annotation.text.words[0].text.must_equal "Google"
    annotation.text.words[0].bounds.map(&:to_a).must_equal [[13, 8], [53, 8], [53, 23], [13, 23]]
    annotation.text.words[27].text.must_equal "Storage."
    annotation.text.words[27].bounds.map(&:to_a).must_equal [[304, 59], [351, 59], [351, 74], [304, 74]]

    annotation.safe_search.wont_be :nil?
    annotation.safe_search.wont_be :adult?
    annotation.safe_search.wont_be :spoof?
    annotation.safe_search.must_be :medical?
    annotation.safe_search.must_be :violence?

    annotation.properties.wont_be :nil?
    annotation.properties.colors.count.must_equal 10

    annotation.properties.colors[0].red.must_equal 145
    annotation.properties.colors[0].green.must_equal 193
    annotation.properties.colors[0].blue.must_equal 254
    annotation.properties.colors[0].alpha.must_equal 1.0
    annotation.properties.colors[0].rgb.must_equal "91c1fe"
    annotation.properties.colors[0].score.must_equal 0.65757853
    annotation.properties.colors[0].pixel_fraction.must_equal 0.16903226

    annotation.properties.colors[9].red.must_equal 156
    annotation.properties.colors[9].green.must_equal 214
    annotation.properties.colors[9].blue.must_equal 255
    annotation.properties.colors[9].alpha.must_equal 1.0
    annotation.properties.colors[9].rgb.must_equal "9cd6ff"
    annotation.properties.colors[9].score.must_equal 0.00096750073
    annotation.properties.colors[9].pixel_fraction.must_equal 0.00064516132
  end

  describe "ImageContext" do
    it "does not send when annotating file path" do
      mock_connection.post "/v1/images:annotate" do |env|
        requests = JSON.parse(env.body)["requests"]
        requests.count.must_equal 1
        request = requests.first
        request["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
        request["features"].count.must_equal 2
        request["features"].first["type"].must_equal "FACE_DETECTION"
        request["features"].first["maxResults"].must_equal 10
        request["features"].last["type"].must_equal "TEXT_DETECTION"
        request["features"].last["maxResults"].must_equal 1
        request["imageContext"].must_be :nil?
        [200, {"Content-Type" => "application/json"},
         context_response_json]
      end

      annotation = vision.annotate filepath, faces: 10, text: true
      annotation.wont_be :nil?
      annotation.face.wont_be :nil?
      annotation.text.wont_be :nil?
    end

    it "does not send when annotating an image without context" do
      mock_connection.post "/v1/images:annotate" do |env|
        requests = JSON.parse(env.body)["requests"]
        requests.count.must_equal 1
        request = requests.first
        request["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
        request["features"].count.must_equal 2
        request["features"].first["type"].must_equal "FACE_DETECTION"
        request["features"].first["maxResults"].must_equal 10
        request["features"].last["type"].must_equal "TEXT_DETECTION"
        request["features"].last["maxResults"].must_equal 1
        request["imageContext"].must_be :nil?
        [200, {"Content-Type" => "application/json"},
         context_response_json]
      end

      image = vision.image filepath
      annotation = vision.annotate image, faces: 10, text: true
      annotation.wont_be :nil?
      annotation.face.wont_be :nil?
      annotation.text.wont_be :nil?
    end

    it "sends when annotating an image with location in context" do
      mock_connection.post "/v1/images:annotate" do |env|
        requests = JSON.parse(env.body)["requests"]
        requests.count.must_equal 1
        request = requests.first
        request["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
        request["features"].count.must_equal 2
        request["features"].first["type"].must_equal "FACE_DETECTION"
        request["features"].first["maxResults"].must_equal 10
        request["features"].last["type"].must_equal "TEXT_DETECTION"
        request["features"].last["maxResults"].must_equal 1
        request["imageContext"].wont_be :nil?
        request["imageContext"]["latLongRect"].must_equal area_json
        request["imageContext"]["languageHints"].must_be :nil?
        [200, {"Content-Type" => "application/json"},
         context_response_json]
      end

      image = vision.image filepath
      image.context.area.min.longitude = -122.0862462
      image.context.area.min.latitude = 37.4220041
      image.context.area.max.longitude = -122.0762462
      image.context.area.max.latitude = 37.4320041
      annotation = vision.annotate image, faces: 10, text: true
      annotation.wont_be :nil?
      annotation.face.wont_be :nil?
      annotation.text.wont_be :nil?
    end

    it "sends when annotating an image with location hash in context" do
      mock_connection.post "/v1/images:annotate" do |env|
        requests = JSON.parse(env.body)["requests"]
        requests.count.must_equal 1
        request = requests.first
        request["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
        request["features"].count.must_equal 2
        request["features"].first["type"].must_equal "FACE_DETECTION"
        request["features"].first["maxResults"].must_equal 10
        request["features"].last["type"].must_equal "TEXT_DETECTION"
        request["features"].last["maxResults"].must_equal 1
        request["imageContext"].wont_be :nil?
        request["imageContext"]["latLongRect"].must_equal area_json
        request["imageContext"]["languageHints"].must_be :nil?
        [200, {"Content-Type" => "application/json"},
         context_response_json]
      end

      image = vision.image filepath
      image.context.area.min = { longitude: -122.0862462, latitude: 37.4220041 }
      image.context.area.max = { longitude: -122.0762462, latitude: 37.4320041 }
      annotation = vision.annotate image, faces: 10, text: true
      annotation.wont_be :nil?
      annotation.face.wont_be :nil?
      annotation.text.wont_be :nil?
    end

    it "sends when annotating an image with language hints in context" do
      mock_connection.post "/v1/images:annotate" do |env|
        requests = JSON.parse(env.body)["requests"]
        requests.count.must_equal 1
        request = requests.first
        request["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
        request["features"].count.must_equal 2
        request["features"].first["type"].must_equal "FACE_DETECTION"
        request["features"].first["maxResults"].must_equal 10
        request["features"].last["type"].must_equal "TEXT_DETECTION"
        request["features"].last["maxResults"].must_equal 1
        request["imageContext"].wont_be :nil?
        request["imageContext"]["latLongRect"].must_be :nil?
        request["imageContext"]["languageHints"].must_equal ["en", "es"]
        [200, {"Content-Type" => "application/json"},
         context_response_json]
      end

      image = vision.image filepath
      image.context.languages = ["en", "es"]
      annotation = vision.annotate image, faces: 10, text: true
      annotation.wont_be :nil?
      annotation.face.wont_be :nil?
      annotation.text.wont_be :nil?
    end

    it "sends when annotating an image with location and language hints in context" do
      mock_connection.post "/v1/images:annotate" do |env|
        requests = JSON.parse(env.body)["requests"]
        requests.count.must_equal 1
        request = requests.first
        request["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
        request["features"].count.must_equal 2
        request["features"].first["type"].must_equal "FACE_DETECTION"
        request["features"].first["maxResults"].must_equal 10
        request["features"].last["type"].must_equal "TEXT_DETECTION"
        request["features"].last["maxResults"].must_equal 1
        request["imageContext"].wont_be :nil?
        request["imageContext"]["latLongRect"].must_equal area_json
        request["imageContext"]["languageHints"].must_equal ["en", "es"]
        [200, {"Content-Type" => "application/json"},
         context_response_json]
      end

      image = vision.image filepath
      image.context.area.min = { longitude: -122.0862462, latitude: 37.4220041 }
      image.context.area.max = { longitude: -122.0762462, latitude: 37.4320041 }
      image.context.languages = ["en", "es"]
      annotation = vision.annotate image, faces: 10, text: true
      annotation.wont_be :nil?
      annotation.face.wont_be :nil?
      annotation.text.wont_be :nil?
    end
  end

  def faces_response_json
    {
      responses: [{
        faceAnnotations: [face_annotation_response]
      }, {
        faceAnnotations: [face_annotation_response]
      }]
    }.to_json
  end

  def full_response_json
    {
      responses: [{
        faceAnnotations: [face_annotation_response],
        landmarkAnnotations: [landmark_annotation_response],
        logoAnnotations: [logo_annotation_response],
        labelAnnotations: [label_annotation_response],
        textAnnotations: text_annotation_responses,
        safeSearchAnnotation: safe_search_annotation_response,
        imagePropertiesAnnotation: properties_annotation_response
      }]
    }.to_json
  end

  def context_response_json
    {
      responses: [{
        faceAnnotations: [face_annotation_response],
        textAnnotations: text_annotation_responses
      }]
    }.to_json
  end
end
