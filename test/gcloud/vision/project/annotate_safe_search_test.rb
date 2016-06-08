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

describe Gcloud::Vision::Project, :annotate, :safe_search, :mock_vision do
  let(:filepath) { "acceptance/data/face.jpg" }

  it "detects safe_search detection" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      safe_search = requests.first
      safe_search["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      safe_search["features"].count.must_equal 1
      safe_search["features"].first["type"].must_equal "SAFE_SEARCH_DETECTION"
      safe_search["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       safe_search_response_json]
    end

    annotation = vision.annotate filepath, safe_search: true
    annotation.wont_be :nil?

    annotation.safe_search.wont_be :nil?
    annotation.safe_search.wont_be :adult?
    annotation.safe_search.wont_be :spoof?
    annotation.safe_search.must_be :medical?
    annotation.safe_search.must_be :violence?
  end

  it "detects safe_search detection using mark alias" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      safe_search = requests.first
      safe_search["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      safe_search["features"].count.must_equal 1
      safe_search["features"].first["type"].must_equal "SAFE_SEARCH_DETECTION"
      safe_search["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       safe_search_response_json]
    end

    annotation = vision.mark filepath, safe_search: true
    annotation.wont_be :nil?

    annotation.safe_search.wont_be :nil?
    annotation.safe_search.wont_be :adult?
    annotation.safe_search.wont_be :spoof?
    annotation.safe_search.must_be :medical?
    annotation.safe_search.must_be :violence?
  end

  it "detects safe_search detection using detect alias" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      safe_search = requests.first
      safe_search["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      safe_search["features"].count.must_equal 1
      safe_search["features"].first["type"].must_equal "SAFE_SEARCH_DETECTION"
      safe_search["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       safe_search_response_json]
    end

    annotation = vision.detect filepath, safe_search: true
    annotation.wont_be :nil?

    annotation.safe_search.wont_be :nil?
    annotation.safe_search.wont_be :adult?
    annotation.safe_search.wont_be :spoof?
    annotation.safe_search.must_be :medical?
    annotation.safe_search.must_be :violence?
  end

  it "detects safe_search detection on multiple images" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 2
      requests.first["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      requests.first["features"].count.must_equal 1
      requests.first["features"].first["type"].must_equal "SAFE_SEARCH_DETECTION"
      requests.first["features"].first["maxResults"].must_equal 1
      requests.last["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      requests.last["features"].count.must_equal 1
      requests.last["features"].first["type"].must_equal "SAFE_SEARCH_DETECTION"
      requests.last["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       safe_searchs_response_json]
    end

    annotations = vision.annotate filepath, filepath, safe_search: true
    annotations.count.must_equal 2

    annotations.first.safe_search.wont_be :nil?
    annotations.first.safe_search.wont_be :adult?
    annotations.first.safe_search.wont_be :spoof?
    annotations.first.safe_search.must_be :medical?
    annotations.first.safe_search.must_be :violence?

    annotations.last.safe_search.wont_be :nil?
    annotations.last.safe_search.wont_be :adult?
    annotations.last.safe_search.wont_be :spoof?
    annotations.last.safe_search.must_be :medical?
    annotations.last.safe_search.must_be :violence?
  end

  it "uses the default configuration when given a truthy value" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      safe_search = requests.first
      safe_search["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      safe_search["features"].count.must_equal 1
      safe_search["features"].first["type"].must_equal "SAFE_SEARCH_DETECTION"
      safe_search["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       safe_search_response_json]
    end

    annotation = vision.annotate filepath, safe_search: "yep"
    annotation.wont_be :nil?

    annotation.safe_search.wont_be :nil?
    annotation.safe_search.wont_be :adult?
    annotation.safe_search.wont_be :spoof?
    annotation.safe_search.must_be :medical?
    annotation.safe_search.must_be :violence?
  end

  def safe_search_response_json
    {
      responses: [{
        safeSearchAnnotation: safe_search_annotation_response
      }]
    }.to_json
  end

  def safe_searchs_response_json
    {
      responses: [{
        safeSearchAnnotation: safe_search_annotation_response
      }, {
        safeSearchAnnotation: safe_search_annotation_response
      }]
    }.to_json
  end
end
