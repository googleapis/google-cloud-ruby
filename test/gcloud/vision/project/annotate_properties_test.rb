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

describe Gcloud::Vision::Project, :annotate, :properties, :mock_vision do
  let(:filepath) { "acceptance/data/face.jpg" }

  it "detects properties detection" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      properties = requests.first
      properties["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      properties["features"].count.must_equal 1
      properties["features"].first["type"].must_equal "IMAGE_PROPERTIES"
      properties["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       properties_response_json]
    end

    annotation = vision.annotate filepath, properties: true
    annotation.wont_be :nil?

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

  it "detects properties detection using mark alias" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      properties = requests.first
      properties["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      properties["features"].count.must_equal 1
      properties["features"].first["type"].must_equal "IMAGE_PROPERTIES"
      properties["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       properties_response_json]
    end

    annotation = vision.mark filepath, properties: true
    annotation.wont_be :nil?

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

  it "detects properties detection using detect alias" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      properties = requests.first
      properties["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      properties["features"].count.must_equal 1
      properties["features"].first["type"].must_equal "IMAGE_PROPERTIES"
      properties["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       properties_response_json]
    end

    annotation = vision.detect filepath, properties: true
    annotation.wont_be :nil?

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

  it "detects properties detection on multiple images" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 2
      requests.first["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      requests.first["features"].count.must_equal 1
      requests.first["features"].first["type"].must_equal "IMAGE_PROPERTIES"
      requests.first["features"].first["maxResults"].must_equal 1
      requests.last["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      requests.last["features"].count.must_equal 1
      requests.last["features"].first["type"].must_equal "IMAGE_PROPERTIES"
      requests.last["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       propertiess_response_json]
    end

    annotations = vision.annotate filepath, filepath, properties: true
    annotations.count.must_equal 2

    annotations[0].properties.colors.count.must_equal 10

    annotations[0].properties.colors[0].red.must_equal 145
    annotations[0].properties.colors[0].green.must_equal 193
    annotations[0].properties.colors[0].blue.must_equal 254
    annotations[0].properties.colors[0].alpha.must_equal 1.0
    annotations[0].properties.colors[0].rgb.must_equal "91c1fe"
    annotations[0].properties.colors[0].score.must_equal 0.65757853
    annotations[0].properties.colors[0].pixel_fraction.must_equal 0.16903226

    annotations[0].properties.colors[9].red.must_equal 156
    annotations[0].properties.colors[9].green.must_equal 214
    annotations[0].properties.colors[9].blue.must_equal 255
    annotations[0].properties.colors[9].alpha.must_equal 1.0
    annotations[0].properties.colors[9].rgb.must_equal "9cd6ff"
    annotations[0].properties.colors[9].score.must_equal 0.00096750073
    annotations[0].properties.colors[9].pixel_fraction.must_equal 0.00064516132

    annotations[1].properties.colors.count.must_equal 10

    annotations[1].properties.colors[0].red.must_equal 145
    annotations[1].properties.colors[0].green.must_equal 193
    annotations[1].properties.colors[0].blue.must_equal 254
    annotations[1].properties.colors[0].alpha.must_equal 1.0
    annotations[1].properties.colors[0].rgb.must_equal "91c1fe"
    annotations[1].properties.colors[0].score.must_equal 0.65757853
    annotations[1].properties.colors[0].pixel_fraction.must_equal 0.16903226

    annotations[1].properties.colors[9].red.must_equal 156
    annotations[1].properties.colors[9].green.must_equal 214
    annotations[1].properties.colors[9].blue.must_equal 255
    annotations[1].properties.colors[9].alpha.must_equal 1.0
    annotations[1].properties.colors[9].rgb.must_equal "9cd6ff"
    annotations[1].properties.colors[9].score.must_equal 0.00096750073
    annotations[1].properties.colors[9].pixel_fraction.must_equal 0.00064516132
  end

  it "uses the default configuration when given a truthy value" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      properties = requests.first
      properties["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      properties["features"].count.must_equal 1
      properties["features"].first["type"].must_equal "IMAGE_PROPERTIES"
      properties["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       properties_response_json]
    end

    annotation = vision.annotate filepath, properties: "please"
    annotation.wont_be :nil?

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

  def properties_response_json
    {
      responses: [{
        imagePropertiesAnnotation: properties_annotation_response
      }]
    }.to_json
  end

  def propertiess_response_json
    {
      responses: [{
        imagePropertiesAnnotation: properties_annotation_response
      }, {
        imagePropertiesAnnotation: properties_annotation_response
      }]
    }.to_json
  end
end
