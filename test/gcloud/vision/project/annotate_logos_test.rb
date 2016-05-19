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

describe Gcloud::Vision::Project, :annotate, :logos, :mock_vision do
  let(:filepath) { "acceptance/data/logo.jpg" }

  it "detects logo detection" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      logo = requests.first
      logo["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      logo["features"].count.must_equal 1
      logo["features"].first["type"].must_equal "LOGO_DETECTION"
      logo["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       logo_response_json]
    end

    annotation = vision.annotate filepath, logos: 1
    annotation.wont_be :nil?
    annotation.logo.wont_be :nil?
  end

  it "detects logo detection using mark alias" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      logo = requests.first
      logo["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      logo["features"].count.must_equal 1
      logo["features"].first["type"].must_equal "LOGO_DETECTION"
      logo["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       logo_response_json]
    end

    annotation = vision.mark filepath, logos: 1
    annotation.wont_be :nil?
    annotation.logo.wont_be :nil?
  end

  it "detects logo detection using detect alias" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      logo = requests.first
      logo["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      logo["features"].count.must_equal 1
      logo["features"].first["type"].must_equal "LOGO_DETECTION"
      logo["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       logo_response_json]
    end

    annotation = vision.detect filepath, logos: 1
    annotation.wont_be :nil?
    annotation.logo.wont_be :nil?
  end

  it "detects logo detection on multiple images" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 2
      requests.first["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      requests.first["features"].count.must_equal 1
      requests.first["features"].first["type"].must_equal "LOGO_DETECTION"
      requests.first["features"].first["maxResults"].must_equal 1
      requests.last["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      requests.last["features"].count.must_equal 1
      requests.last["features"].first["type"].must_equal "LOGO_DETECTION"
      requests.last["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       logos_response_json]
    end

    annotations = vision.annotate filepath, filepath, logos: 1
    annotations.count.must_equal 2
    annotations.first.logo.wont_be :nil?
    annotations.last.logo.wont_be :nil?
  end

  it "uses the default configuration" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      logo = requests.first
      logo["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      logo["features"].count.must_equal 1
      logo["features"].first["type"].must_equal "LOGO_DETECTION"
      logo["features"].first["maxResults"].must_equal Gcloud::Vision.default_max_logos
      [200, {"Content-Type" => "application/json"},
       logo_response_json]
    end

    annotation = vision.annotate filepath, logos: true
    annotation.wont_be :nil?
    annotation.logo.wont_be :nil?
  end

  it "uses the default configuration when given a truthy value" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      logo = requests.first
      logo["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      logo["features"].count.must_equal 1
      logo["features"].first["type"].must_equal "LOGO_DETECTION"
      logo["features"].first["maxResults"].must_equal Gcloud::Vision.default_max_logos
      [200, {"Content-Type" => "application/json"},
       logo_response_json]
    end

    annotation = vision.annotate filepath, logos: "9999"
    annotation.wont_be :nil?
    annotation.logo.wont_be :nil?
  end

  it "uses the updated configuration" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      logo = requests.first
      logo["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      logo["features"].count.must_equal 1
      logo["features"].first["type"].must_equal "LOGO_DETECTION"
      logo["features"].first["maxResults"].must_equal 25
      [200, {"Content-Type" => "application/json"},
       logo_response_json]
    end

    Gcloud::Vision.stub :default_max_logos, 25 do
      annotation = vision.annotate filepath, logos: true
      annotation.wont_be :nil?
      annotation.logo.wont_be :nil?
    end
  end

  def logo_response_json
    {
      responses: [{
        logoAnnotations: [logo_annotation_response]
      }]
    }.to_json
  end

  def logos_response_json
    {
      responses: [{
        logoAnnotations: [logo_annotation_response]
      }, {
        logoAnnotations: [logo_annotation_response]
      }]
    }.to_json
  end

end
