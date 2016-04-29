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

describe Gcloud::Vision::Image, :faces, :mock_vision do
  let(:filepath) { "acceptance/data/face.jpg" }
  let(:image)    { vision.image filepath }

  it "detects multiple faces" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      face = requests.first
      face["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      face["features"].count.must_equal 1
      face["features"].first["type"].must_equal "FACE_DETECTION"
      face["features"].first["maxResults"].must_equal 10
      [200, {"Content-Type" => "application/json"},
       faces_response_json]
    end

    faces = image.faces 10
    faces.count.must_equal 5
  end

  it "detects a face" do
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

    face = image.face
    face.wont_be :nil?
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
        faceAnnotations: [face_annotation_response,
                          face_annotation_response,
                          face_annotation_response,
                          face_annotation_response,
                          face_annotation_response]
      }]
    }.to_json
  end
end
