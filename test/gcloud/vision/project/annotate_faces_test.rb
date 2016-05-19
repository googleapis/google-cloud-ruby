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

describe Gcloud::Vision::Project, :annotate, :faces, :mock_vision do
  let(:filepath) { "acceptance/data/face.jpg" }

  it "detects face detection" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      face = requests.first
      face["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      face["features"].count.must_equal 1
      face["features"].first["type"].must_equal "FACE_DETECTION"
      face["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       face_response_json]
    end

    annotation = vision.annotate filepath, faces: 1
    annotation.wont_be :nil?
    annotation.face.wont_be :nil?
  end

  it "detects face detection using mark alias" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      face = requests.first
      face["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      face["features"].count.must_equal 1
      face["features"].first["type"].must_equal "FACE_DETECTION"
      face["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       face_response_json]
    end

    annotation = vision.mark filepath, faces: 1
    annotation.wont_be :nil?
    annotation.face.wont_be :nil?
  end

  it "detects face detection using detect alias" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      face = requests.first
      face["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      face["features"].count.must_equal 1
      face["features"].first["type"].must_equal "FACE_DETECTION"
      face["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       face_response_json]
    end

    annotation = vision.detect filepath, faces: 1
    annotation.wont_be :nil?
    annotation.face.wont_be :nil?
  end

  it "detects face detection on multiple images" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 2
      requests.first["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      requests.first["features"].count.must_equal 1
      requests.first["features"].first["type"].must_equal "FACE_DETECTION"
      requests.first["features"].first["maxResults"].must_equal 1
      requests.last["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      requests.last["features"].count.must_equal 1
      requests.last["features"].first["type"].must_equal "FACE_DETECTION"
      requests.last["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       faces_response_json]
    end

    annotations = vision.annotate filepath, filepath, faces: 1
    annotations.count.must_equal 2
    annotations.first.face.wont_be :nil?
    annotations.last.face.wont_be :nil?
  end

  it "uses the default configuration" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      requests.last["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      requests.last["features"].count.must_equal 1
      requests.last["features"].first["type"].must_equal "FACE_DETECTION"
      requests.last["features"].first["maxResults"].must_equal Gcloud::Vision.default_max_faces
      [200, {"Content-Type" => "application/json"},
       face_response_json]
    end

    annotation = vision.annotate filepath, faces: true
    annotation.face.wont_be :nil?
  end

  it "uses the default configuration when given a truthy value" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      requests.last["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      requests.last["features"].count.must_equal 1
      requests.last["features"].first["type"].must_equal "FACE_DETECTION"
      requests.last["features"].first["maxResults"].must_equal Gcloud::Vision.default_max_faces
      [200, {"Content-Type" => "application/json"},
       face_response_json]
    end

    annotation = vision.annotate filepath, faces: "9999"
    annotation.face.wont_be :nil?
  end

  it "uses the updated configuration" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      requests.last["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      requests.last["features"].count.must_equal 1
      requests.last["features"].first["type"].must_equal "FACE_DETECTION"
      requests.last["features"].first["maxResults"].must_equal 25
      [200, {"Content-Type" => "application/json"},
       face_response_json]
    end

    Gcloud::Vision.stub :default_max_faces, 25 do
      annotation = vision.annotate filepath, faces: true
      annotation.face.wont_be :nil?
    end
  end

  def face_response_json
    {
      responses: [{
        faceAnnotations: [face_annotation_response]
      }]
    }.to_json
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
end
