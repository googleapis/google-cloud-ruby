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

    analysis = vision.mark filepath, faces: 1
  end

  it "detects face detection using annotate alias" do
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

    analysis = vision.annotate filepath, faces: 1
    analysis.wont_be :nil?
    analysis.face.wont_be :nil?
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

    analyses = vision.mark filepath, filepath, faces: 1
    analyses.count.must_equal 2
    analyses.first.face.wont_be :nil?
    analyses.last.face.wont_be :nil?
  end

  it "detects landmark detection" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      landmark = requests.first
      landmark["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      landmark["features"].count.must_equal 1
      landmark["features"].first["type"].must_equal "LANDMARK_DETECTION"
      landmark["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       landmark_response_json]
    end

    analysis = vision.mark filepath, landmarks: 1
  end

  it "detects landmark detection using annotate alias" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      landmark = requests.first
      landmark["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      landmark["features"].count.must_equal 1
      landmark["features"].first["type"].must_equal "LANDMARK_DETECTION"
      landmark["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       landmark_response_json]
    end

    analysis = vision.annotate filepath, landmarks: 1
    analysis.wont_be :nil?
    analysis.landmark.wont_be :nil?
  end

  it "detects landmark detection on multiple images" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 2
      requests.first["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      requests.first["features"].count.must_equal 1
      requests.first["features"].first["type"].must_equal "LANDMARK_DETECTION"
      requests.first["features"].first["maxResults"].must_equal 1
      requests.last["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      requests.last["features"].count.must_equal 1
      requests.last["features"].first["type"].must_equal "LANDMARK_DETECTION"
      requests.last["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       landmarks_response_json]
    end

    analyses = vision.mark filepath, filepath, landmarks: 1
    analyses.count.must_equal 2
    analyses.first.landmark.wont_be :nil?
    analyses.last.landmark.wont_be :nil?
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

  def landmark_response_json
    {
      responses: [{
        landmarkAnnotations: [landmark_annotation_response]
      }]
    }.to_json
  end

  def landmarks_response_json
    {
      responses: [{
        landmarkAnnotations: [landmark_annotation_response]
      }, {
        landmarkAnnotations: [landmark_annotation_response]
      }]
    }.to_json
  end
end
