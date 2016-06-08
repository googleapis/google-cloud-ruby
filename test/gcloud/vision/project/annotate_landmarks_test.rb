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

describe Gcloud::Vision::Project, :annotate, :landmarks, :mock_vision do
  let(:filepath) { "acceptance/data/landmark.jpg" }

  it "detects landmark detection" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      landmark = requests.first
      landmark["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      landmark["features"].count.must_equal 1
      landmark["features"].first["type"].must_equal "LANDMARK_DETECTION"
      landmark["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       landmark_response_json]
    end

    annotation = vision.annotate filepath, landmarks: 1
    annotation.wont_be :nil?
    annotation.landmark.wont_be :nil?
  end

  it "detects landmark detection using mark alias" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      landmark = requests.first
      landmark["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      landmark["features"].count.must_equal 1
      landmark["features"].first["type"].must_equal "LANDMARK_DETECTION"
      landmark["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       landmark_response_json]
    end

    annotation = vision.mark filepath, landmarks: 1
    annotation.wont_be :nil?
    annotation.landmark.wont_be :nil?
  end

  it "detects landmark detection using detect alias" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      landmark = requests.first
      landmark["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      landmark["features"].count.must_equal 1
      landmark["features"].first["type"].must_equal "LANDMARK_DETECTION"
      landmark["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       landmark_response_json]
    end

    annotation = vision.detect filepath, landmarks: 1
    annotation.wont_be :nil?
    annotation.landmark.wont_be :nil?
  end

  it "detects landmark detection on multiple images" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 2
      requests.first["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      requests.first["features"].count.must_equal 1
      requests.first["features"].first["type"].must_equal "LANDMARK_DETECTION"
      requests.first["features"].first["maxResults"].must_equal 1
      requests.last["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      requests.last["features"].count.must_equal 1
      requests.last["features"].first["type"].must_equal "LANDMARK_DETECTION"
      requests.last["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       landmarks_response_json]
    end

    annotations = vision.annotate filepath, filepath, landmarks: 1
    annotations.count.must_equal 2
    annotations.first.landmark.wont_be :nil?
    annotations.last.landmark.wont_be :nil?
  end

  it "uses the default configuration" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      landmark = requests.first
      landmark["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      landmark["features"].count.must_equal 1
      landmark["features"].first["type"].must_equal "LANDMARK_DETECTION"
      landmark["features"].first["maxResults"].must_equal Gcloud::Vision.default_max_landmarks
      [200, {"Content-Type" => "application/json"},
       landmark_response_json]
    end

    annotation = vision.annotate filepath, landmarks: true
    annotation.wont_be :nil?
    annotation.landmark.wont_be :nil?
  end

  it "uses the default configuration when given a truthy value" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      landmark = requests.first
      landmark["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      landmark["features"].count.must_equal 1
      landmark["features"].first["type"].must_equal "LANDMARK_DETECTION"
      landmark["features"].first["maxResults"].must_equal Gcloud::Vision.default_max_landmarks
      [200, {"Content-Type" => "application/json"},
       landmark_response_json]
    end

    annotation = vision.annotate filepath, landmarks: "9999"
    annotation.wont_be :nil?
    annotation.landmark.wont_be :nil?
  end

  it "uses the updated configuration" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      landmark = requests.first
      landmark["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      landmark["features"].count.must_equal 1
      landmark["features"].first["type"].must_equal "LANDMARK_DETECTION"
      landmark["features"].first["maxResults"].must_equal 25
      [200, {"Content-Type" => "application/json"},
       landmark_response_json]
    end

    Gcloud::Vision.stub :default_max_landmarks, 25 do
      annotation = vision.annotate filepath, landmarks: true
      annotation.wont_be :nil?
      annotation.landmark.wont_be :nil?
    end
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
