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

describe Gcloud::Vision::Project, :annotate, :text, :mock_vision do
  let(:filepath) { "acceptance/data/text.png" }

  it "detects text detection" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      text = requests.first
      text["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      text["features"].count.must_equal 1
      text["features"].first["type"].must_equal "TEXT_DETECTION"
      text["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       text_response_json]
    end

    annotation = vision.annotate filepath, text: true
    annotation.wont_be :nil?
    annotation.text.wont_be :nil?
    annotation.text.text.must_include "Google Cloud Client Library for Ruby"
    annotation.text.locale.must_equal "en"
    annotation.text.words.count.must_equal 28
    annotation.text.words[0].text.must_equal "Google"
    annotation.text.words[0].bounds.map(&:to_a).must_equal [[13, 8], [53, 8], [53, 23], [13, 23]]
    annotation.text.words[27].text.must_equal "Storage."
    annotation.text.words[27].bounds.map(&:to_a).must_equal [[304, 59], [351, 59], [351, 74], [304, 74]]
  end

  it "detects text detection using mark alias" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      text = requests.first
      text["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      text["features"].count.must_equal 1
      text["features"].first["type"].must_equal "TEXT_DETECTION"
      text["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       text_response_json]
    end

    annotation = vision.mark filepath, text: true
    annotation.wont_be :nil?
    annotation.text.wont_be :nil?
  end

  it "detects text detection using detect alias" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      text = requests.first
      text["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      text["features"].count.must_equal 1
      text["features"].first["type"].must_equal "TEXT_DETECTION"
      text["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       text_response_json]
    end

    annotation = vision.detect filepath, text: true
    annotation.wont_be :nil?
    annotation.text.wont_be :nil?
  end

  it "detects text detection on multiple images" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 2
      requests.first["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      requests.first["features"].count.must_equal 1
      requests.first["features"].first["type"].must_equal "TEXT_DETECTION"
      requests.first["features"].first["maxResults"].must_equal 1
      requests.last["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      requests.last["features"].count.must_equal 1
      requests.last["features"].first["type"].must_equal "TEXT_DETECTION"
      requests.last["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       texts_response_json]
    end

    annotations = vision.annotate filepath, filepath, text: true
    annotations.count.must_equal 2
    annotations.first.text.wont_be :nil?
    annotations.last.text.wont_be :nil?
  end

  it "uses the default configuration when given a truthy value" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      text = requests.first
      text["image"]["content"].must_equal Base64.strict_encode64(File.read(filepath, mode: "rb"))
      text["features"].count.must_equal 1
      text["features"].first["type"].must_equal "TEXT_DETECTION"
      text["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       text_response_json]
    end

    annotation = vision.annotate filepath, text: "totes"
    annotation.wont_be :nil?
    annotation.text.wont_be :nil?
    annotation.text.text.must_include "Google Cloud Client Library for Ruby"
    annotation.text.locale.must_equal "en"
    annotation.text.words.count.must_equal 28
    annotation.text.words[0].text.must_equal "Google"
    annotation.text.words[0].bounds.map(&:to_a).must_equal [[13, 8], [53, 8], [53, 23], [13, 23]]
    annotation.text.words[27].text.must_equal "Storage."
    annotation.text.words[27].bounds.map(&:to_a).must_equal [[304, 59], [351, 59], [351, 74], [304, 74]]
  end

  def text_response_json
    {
      responses: [{
        textAnnotations: text_annotation_responses
      }]
    }.to_json
  end

  def texts_response_json
    {
      responses: [{
        textAnnotations: text_annotation_responses
      }, {
        textAnnotations: text_annotation_responses
      }]
    }.to_json
  end
end
