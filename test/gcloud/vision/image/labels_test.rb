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

describe Gcloud::Vision::Image, :labels, :mock_vision do
  let(:filepath) { "acceptance/data/landmark.jpg" }
  let(:image)    { vision.image filepath }

  it "detects multiple labels" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      label = requests.first
      label["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      label["features"].count.must_equal 1
      label["features"].first["type"].must_equal "LABEL_DETECTION"
      label["features"].first["maxResults"].must_equal 10
      [200, {"Content-Type" => "application/json"},
       labels_response_json]
    end

    labels = image.labels 10
    labels.count.must_equal 5
  end

  it "detects multiple labels without specifying a count" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      label = requests.first
      label["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      label["features"].count.must_equal 1
      label["features"].first["type"].must_equal "LABEL_DETECTION"
      label["features"].first["maxResults"].must_equal 100
      [200, {"Content-Type" => "application/json"},
       labels_response_json]
    end

    labels = image.labels
    labels.count.must_equal 5
  end

  it "detects a label" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      label = requests.first
      label["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      label["features"].count.must_equal 1
      label["features"].first["type"].must_equal "LABEL_DETECTION"
      label["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       label_response_json]
    end

    label = image.label
    label.wont_be :nil?
  end

  def label_response_json
    {
      responses: [{
        labelAnnotations: [label_annotation_response]
      }]
    }.to_json
  end

  def labels_response_json
    {
      responses: [{
        labelAnnotations: [label_annotation_response,
                          label_annotation_response,
                          label_annotation_response,
                          label_annotation_response,
                          label_annotation_response]
      }]
    }.to_json
  end
end
