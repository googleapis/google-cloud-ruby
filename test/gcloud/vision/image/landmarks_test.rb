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
require "pathname"

describe Gcloud::Vision::Image, :landmarks, :mock_vision do
  let(:filepath) { "acceptance/data/landmark.jpg" }
  let(:image)    { vision.image filepath }

  it "detects multiple landmarks" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      landmark = requests.first
      landmark["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      landmark["features"].count.must_equal 1
      landmark["features"].first["type"].must_equal "LANDMARK_DETECTION"
      landmark["features"].first["maxResults"].must_equal 10
      [200, {"Content-Type" => "application/json"},
       landmarks_response_json]
    end

    landmarks = image.landmarks 10
    landmarks.count.must_equal 5
  end

  it "detects multiple landmarks without specifying a count" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      landmark = requests.first
      landmark["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      landmark["features"].count.must_equal 1
      landmark["features"].first["type"].must_equal "LANDMARK_DETECTION"
      landmark["features"].first["maxResults"].must_equal 10
      [200, {"Content-Type" => "application/json"},
       landmarks_response_json]
    end

    landmarks = image.landmarks
    landmarks.count.must_equal 5
  end

  it "detects a landmark" do
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

    landmark = image.landmark
    landmark.wont_be :nil?
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
        landmarkAnnotations: [landmark_annotation_response,
                          landmark_annotation_response,
                          landmark_annotation_response,
                          landmark_annotation_response,
                          landmark_annotation_response]
      }]
    }.to_json
  end
end
