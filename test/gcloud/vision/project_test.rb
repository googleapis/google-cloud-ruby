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

    analysis = vision.annotate filepath, faces: 1
    analysis.wont_be :nil?
    analysis.face.wont_be :nil?
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

    analysis = vision.mark filepath, faces: 1
    analysis.wont_be :nil?
    analysis.face.wont_be :nil?
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

    analysis = vision.detect filepath, faces: 1
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

    analyses = vision.annotate filepath, filepath, faces: 1
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

    analysis = vision.annotate filepath, landmarks: 1
    analysis.wont_be :nil?
    analysis.landmark.wont_be :nil?
  end

  it "detects landmark detection using mark alias" do
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
    analysis.wont_be :nil?
    analysis.landmark.wont_be :nil?
  end

  it "detects landmark detection using detect alias" do
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

    analysis = vision.detect filepath, landmarks: 1
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

    analyses = vision.annotate filepath, filepath, landmarks: 1
    analyses.count.must_equal 2
    analyses.first.landmark.wont_be :nil?
    analyses.last.landmark.wont_be :nil?
  end

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

    analysis = vision.annotate filepath, logos: 1
    analysis.wont_be :nil?
    analysis.logo.wont_be :nil?
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

    analysis = vision.mark filepath, logos: 1
    analysis.wont_be :nil?
    analysis.logo.wont_be :nil?
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

    analysis = vision.detect filepath, logos: 1
    analysis.wont_be :nil?
    analysis.logo.wont_be :nil?
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

    analyses = vision.annotate filepath, filepath, logos: 1
    analyses.count.must_equal 2
    analyses.first.logo.wont_be :nil?
    analyses.last.logo.wont_be :nil?
  end

  it "detects label detection" do
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

    analysis = vision.annotate filepath, labels: 1
    analysis.wont_be :nil?
    analysis.label.wont_be :nil?
  end

  it "detects label detection using mark alias" do
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

    analysis = vision.mark filepath, labels: 1
    analysis.wont_be :nil?
    analysis.label.wont_be :nil?
  end

  it "detects label detection using detect alias" do
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

    analysis = vision.detect filepath, labels: 1
    analysis.wont_be :nil?
    analysis.label.wont_be :nil?
  end

  it "detects label detection on multiple images" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 2
      requests.first["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      requests.first["features"].count.must_equal 1
      requests.first["features"].first["type"].must_equal "LABEL_DETECTION"
      requests.first["features"].first["maxResults"].must_equal 1
      requests.last["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      requests.last["features"].count.must_equal 1
      requests.last["features"].first["type"].must_equal "LABEL_DETECTION"
      requests.last["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       labels_response_json]
    end

    analyses = vision.annotate filepath, filepath, labels: 1
    analyses.count.must_equal 2
    analyses.first.label.wont_be :nil?
    analyses.last.label.wont_be :nil?
  end

  it "detects text detection" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      text = requests.first
      text["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      text["features"].count.must_equal 1
      text["features"].first["type"].must_equal "TEXT_DETECTION"
      text["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       text_response_json]
    end

    analysis = vision.annotate filepath, text: true
    analysis.wont_be :nil?
    analysis.text.wont_be :nil?
    analysis.text.text.must_include "Google Cloud Client Library for Ruby"
    analysis.text.locale.must_equal "en"
    analysis.text.words.count.must_equal 28
    analysis.text.words[0].text.must_equal "Google"
    analysis.text.words[0].bounds.map(&:to_a).must_equal [[13, 8], [53, 8], [53, 23], [13, 23]]
    analysis.text.words[27].text.must_equal "Storage."
    analysis.text.words[27].bounds.map(&:to_a).must_equal [[304, 59], [351, 59], [351, 74], [304, 74]]
  end

  it "detects text detection using mark alias" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      text = requests.first
      text["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      text["features"].count.must_equal 1
      text["features"].first["type"].must_equal "TEXT_DETECTION"
      text["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       text_response_json]
    end

    analysis = vision.mark filepath, text: true
    analysis.wont_be :nil?
    analysis.text.wont_be :nil?
  end

  it "detects text detection using detect alias" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      text = requests.first
      text["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      text["features"].count.must_equal 1
      text["features"].first["type"].must_equal "TEXT_DETECTION"
      text["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       text_response_json]
    end

    analysis = vision.detect filepath, text: true
    analysis.wont_be :nil?
    analysis.text.wont_be :nil?
  end

  it "detects text detection on multiple images" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 2
      requests.first["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      requests.first["features"].count.must_equal 1
      requests.first["features"].first["type"].must_equal "TEXT_DETECTION"
      requests.first["features"].first["maxResults"].must_equal 1
      requests.last["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      requests.last["features"].count.must_equal 1
      requests.last["features"].first["type"].must_equal "TEXT_DETECTION"
      requests.last["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       texts_response_json]
    end

    analyses = vision.annotate filepath, filepath, text: true
    analyses.count.must_equal 2
    analyses.first.text.wont_be :nil?
    analyses.last.text.wont_be :nil?
  end

  it "detects safe_search detection" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      safe_search = requests.first
      safe_search["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      safe_search["features"].count.must_equal 1
      safe_search["features"].first["type"].must_equal "SAFE_SEARCH_DETECTION"
      safe_search["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       safe_search_response_json]
    end

    analysis = vision.annotate filepath, safe_search: true
    analysis.wont_be :nil?

    analysis.safe_search.wont_be :nil?
    analysis.safe_search.wont_be :adult?
    analysis.safe_search.wont_be :spoof?
    analysis.safe_search.must_be :medical?
    analysis.safe_search.must_be :violence?
  end

  it "detects safe_search detection using mark alias" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      safe_search = requests.first
      safe_search["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      safe_search["features"].count.must_equal 1
      safe_search["features"].first["type"].must_equal "SAFE_SEARCH_DETECTION"
      safe_search["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       safe_search_response_json]
    end

    analysis = vision.mark filepath, safe_search: true
    analysis.wont_be :nil?

    analysis.safe_search.wont_be :nil?
    analysis.safe_search.wont_be :adult?
    analysis.safe_search.wont_be :spoof?
    analysis.safe_search.must_be :medical?
    analysis.safe_search.must_be :violence?
  end

  it "detects safe_search detection using detect alias" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      safe_search = requests.first
      safe_search["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      safe_search["features"].count.must_equal 1
      safe_search["features"].first["type"].must_equal "SAFE_SEARCH_DETECTION"
      safe_search["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       safe_search_response_json]
    end

    analysis = vision.detect filepath, safe_search: true
    analysis.wont_be :nil?

    analysis.safe_search.wont_be :nil?
    analysis.safe_search.wont_be :adult?
    analysis.safe_search.wont_be :spoof?
    analysis.safe_search.must_be :medical?
    analysis.safe_search.must_be :violence?
  end

  it "detects safe_search detection on multiple images" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 2
      requests.first["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      requests.first["features"].count.must_equal 1
      requests.first["features"].first["type"].must_equal "SAFE_SEARCH_DETECTION"
      requests.first["features"].first["maxResults"].must_equal 1
      requests.last["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      requests.last["features"].count.must_equal 1
      requests.last["features"].first["type"].must_equal "SAFE_SEARCH_DETECTION"
      requests.last["features"].first["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       safe_searchs_response_json]
    end

    analyses = vision.annotate filepath, filepath, safe_search: true
    analyses.count.must_equal 2

    analyses.first.safe_search.wont_be :nil?
    analyses.first.safe_search.wont_be :adult?
    analyses.first.safe_search.wont_be :spoof?
    analyses.first.safe_search.must_be :medical?
    analyses.first.safe_search.must_be :violence?

    analyses.last.safe_search.wont_be :nil?
    analyses.last.safe_search.wont_be :adult?
    analyses.last.safe_search.wont_be :spoof?
    analyses.last.safe_search.must_be :medical?
    analyses.last.safe_search.must_be :violence?
  end

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

    analysis = vision.annotate filepath, properties: true
    analysis.wont_be :nil?

    analysis.properties.colors.count.must_equal 10

    analysis.properties.colors[0].red.must_equal 145
    analysis.properties.colors[0].green.must_equal 193
    analysis.properties.colors[0].blue.must_equal 254
    analysis.properties.colors[0].alpha.must_equal 1.0
    analysis.properties.colors[0].rgb.must_equal "91c1fe"
    analysis.properties.colors[0].score.must_equal 0.65757853
    analysis.properties.colors[0].pixel_fraction.must_equal 0.16903226

    analysis.properties.colors[9].red.must_equal 156
    analysis.properties.colors[9].green.must_equal 214
    analysis.properties.colors[9].blue.must_equal 255
    analysis.properties.colors[9].alpha.must_equal 1.0
    analysis.properties.colors[9].rgb.must_equal "9cd6ff"
    analysis.properties.colors[9].score.must_equal 0.00096750073
    analysis.properties.colors[9].pixel_fraction.must_equal 0.00064516132
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

    analysis = vision.mark filepath, properties: true
    analysis.wont_be :nil?

    analysis.properties.colors.count.must_equal 10

    analysis.properties.colors[0].red.must_equal 145
    analysis.properties.colors[0].green.must_equal 193
    analysis.properties.colors[0].blue.must_equal 254
    analysis.properties.colors[0].alpha.must_equal 1.0
    analysis.properties.colors[0].rgb.must_equal "91c1fe"
    analysis.properties.colors[0].score.must_equal 0.65757853
    analysis.properties.colors[0].pixel_fraction.must_equal 0.16903226

    analysis.properties.colors[9].red.must_equal 156
    analysis.properties.colors[9].green.must_equal 214
    analysis.properties.colors[9].blue.must_equal 255
    analysis.properties.colors[9].alpha.must_equal 1.0
    analysis.properties.colors[9].rgb.must_equal "9cd6ff"
    analysis.properties.colors[9].score.must_equal 0.00096750073
    analysis.properties.colors[9].pixel_fraction.must_equal 0.00064516132
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

    analysis = vision.detect filepath, properties: true
    analysis.wont_be :nil?

    analysis.properties.colors.count.must_equal 10

    analysis.properties.colors[0].red.must_equal 145
    analysis.properties.colors[0].green.must_equal 193
    analysis.properties.colors[0].blue.must_equal 254
    analysis.properties.colors[0].alpha.must_equal 1.0
    analysis.properties.colors[0].rgb.must_equal "91c1fe"
    analysis.properties.colors[0].score.must_equal 0.65757853
    analysis.properties.colors[0].pixel_fraction.must_equal 0.16903226

    analysis.properties.colors[9].red.must_equal 156
    analysis.properties.colors[9].green.must_equal 214
    analysis.properties.colors[9].blue.must_equal 255
    analysis.properties.colors[9].alpha.must_equal 1.0
    analysis.properties.colors[9].rgb.must_equal "9cd6ff"
    analysis.properties.colors[9].score.must_equal 0.00096750073
    analysis.properties.colors[9].pixel_fraction.must_equal 0.00064516132
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

    analyses = vision.annotate filepath, filepath, properties: true
    analyses.count.must_equal 2

    analyses[0].properties.colors.count.must_equal 10

    analyses[0].properties.colors[0].red.must_equal 145
    analyses[0].properties.colors[0].green.must_equal 193
    analyses[0].properties.colors[0].blue.must_equal 254
    analyses[0].properties.colors[0].alpha.must_equal 1.0
    analyses[0].properties.colors[0].rgb.must_equal "91c1fe"
    analyses[0].properties.colors[0].score.must_equal 0.65757853
    analyses[0].properties.colors[0].pixel_fraction.must_equal 0.16903226

    analyses[0].properties.colors[9].red.must_equal 156
    analyses[0].properties.colors[9].green.must_equal 214
    analyses[0].properties.colors[9].blue.must_equal 255
    analyses[0].properties.colors[9].alpha.must_equal 1.0
    analyses[0].properties.colors[9].rgb.must_equal "9cd6ff"
    analyses[0].properties.colors[9].score.must_equal 0.00096750073
    analyses[0].properties.colors[9].pixel_fraction.must_equal 0.00064516132

    analyses[1].properties.colors.count.must_equal 10

    analyses[1].properties.colors[0].red.must_equal 145
    analyses[1].properties.colors[0].green.must_equal 193
    analyses[1].properties.colors[0].blue.must_equal 254
    analyses[1].properties.colors[0].alpha.must_equal 1.0
    analyses[1].properties.colors[0].rgb.must_equal "91c1fe"
    analyses[1].properties.colors[0].score.must_equal 0.65757853
    analyses[1].properties.colors[0].pixel_fraction.must_equal 0.16903226

    analyses[1].properties.colors[9].red.must_equal 156
    analyses[1].properties.colors[9].green.must_equal 214
    analyses[1].properties.colors[9].blue.must_equal 255
    analyses[1].properties.colors[9].alpha.must_equal 1.0
    analyses[1].properties.colors[9].rgb.must_equal "9cd6ff"
    analyses[1].properties.colors[9].score.must_equal 0.00096750073
    analyses[1].properties.colors[9].pixel_fraction.must_equal 0.00064516132
  end

  it "allows different annotation options for different images" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 2
      requests.first["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      requests.first["features"].count.must_equal 2
      requests.first["features"].first["type"].must_equal "FACE_DETECTION"
      requests.first["features"].first["maxResults"].must_equal 10
      requests.first["features"].last["type"].must_equal "TEXT_DETECTION"
      requests.first["features"].last["maxResults"].must_equal 1
      requests.last["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      requests.last["features"].count.must_equal 2
      requests.last["features"].first["type"].must_equal "LANDMARK_DETECTION"
      requests.last["features"].first["maxResults"].must_equal 20
      requests.last["features"].last["type"].must_equal "SAFE_SEARCH_DETECTION"
      requests.last["features"].last["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       faces_response_json]
    end

    analyses = vision.annotate do |a|
      a.annotate filepath, faces: 10, text: true
      a.annotate filepath, landmarks: 20, safe_search: true
    end
    analyses.count.must_equal 2
    analyses.first.face.wont_be :nil?
    analyses.last.face.wont_be :nil?
  end

  it "runs full analysis with empty options" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      request = requests.first
      request["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      request["features"].count.must_equal 7
      request["features"][0]["type"].must_equal "FACE_DETECTION"
      request["features"][0]["maxResults"].must_equal 10
      request["features"][1]["type"].must_equal "LANDMARK_DETECTION"
      request["features"][1]["maxResults"].must_equal 10
      request["features"][2]["type"].must_equal "LOGO_DETECTION"
      request["features"][2]["maxResults"].must_equal 10
      request["features"][3]["type"].must_equal "LABEL_DETECTION"
      request["features"][3]["maxResults"].must_equal 10
      request["features"][4]["type"].must_equal "TEXT_DETECTION"
      request["features"][4]["maxResults"].must_equal 1
      request["features"][5]["type"].must_equal "SAFE_SEARCH_DETECTION"
      request["features"][5]["maxResults"].must_equal 1
      request["features"][6]["type"].must_equal "IMAGE_PROPERTIES"
      request["features"][6]["maxResults"].must_equal 1
      [200, {"Content-Type" => "application/json"},
       full_response_json]
    end

    analysis = vision.annotate filepath
    analysis.wont_be :nil?
    analysis.face.wont_be :nil?
    analysis.landmark.wont_be :nil?
    analysis.logo.wont_be :nil?
    analysis.labels.wont_be :nil?

    analysis.wont_be :nil?
    analysis.text.wont_be :nil?
    analysis.text.text.must_include "Google Cloud Client Library for Ruby"
    analysis.text.locale.must_equal "en"
    analysis.text.words.count.must_equal 28
    analysis.text.words[0].text.must_equal "Google"
    analysis.text.words[0].bounds.map(&:to_a).must_equal [[13, 8], [53, 8], [53, 23], [13, 23]]
    analysis.text.words[27].text.must_equal "Storage."
    analysis.text.words[27].bounds.map(&:to_a).must_equal [[304, 59], [351, 59], [351, 74], [304, 74]]

    analysis.safe_search.wont_be :nil?
    analysis.safe_search.wont_be :adult?
    analysis.safe_search.wont_be :spoof?
    analysis.safe_search.must_be :medical?
    analysis.safe_search.must_be :violence?

    analysis.properties.wont_be :nil?
    analysis.properties.colors.count.must_equal 10

    analysis.properties.colors[0].red.must_equal 145
    analysis.properties.colors[0].green.must_equal 193
    analysis.properties.colors[0].blue.must_equal 254
    analysis.properties.colors[0].alpha.must_equal 1.0
    analysis.properties.colors[0].rgb.must_equal "91c1fe"
    analysis.properties.colors[0].score.must_equal 0.65757853
    analysis.properties.colors[0].pixel_fraction.must_equal 0.16903226

    analysis.properties.colors[9].red.must_equal 156
    analysis.properties.colors[9].green.must_equal 214
    analysis.properties.colors[9].blue.must_equal 255
    analysis.properties.colors[9].alpha.must_equal 1.0
    analysis.properties.colors[9].rgb.must_equal "9cd6ff"
    analysis.properties.colors[9].score.must_equal 0.00096750073
    analysis.properties.colors[9].pixel_fraction.must_equal 0.00064516132
  end

  describe "ImageContext" do
    it "does not send when annotating file path" do
      mock_connection.post "/v1/images:annotate" do |env|
        requests = JSON.parse(env.body)["requests"]
        requests.count.must_equal 1
        request = requests.first
        request["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
        request["features"].count.must_equal 2
        request["features"].first["type"].must_equal "FACE_DETECTION"
        request["features"].first["maxResults"].must_equal 10
        request["features"].last["type"].must_equal "TEXT_DETECTION"
        request["features"].last["maxResults"].must_equal 1
        request["imageContext"].must_be :nil?
        [200, {"Content-Type" => "application/json"},
         context_response_json]
      end

      analysis = vision.annotate filepath, faces: 10, text: true
      analysis.wont_be :nil?
      analysis.face.wont_be :nil?
      analysis.text.wont_be :nil?
    end

    it "does not send when annotating an image without context" do
      mock_connection.post "/v1/images:annotate" do |env|
        requests = JSON.parse(env.body)["requests"]
        requests.count.must_equal 1
        request = requests.first
        request["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
        request["features"].count.must_equal 2
        request["features"].first["type"].must_equal "FACE_DETECTION"
        request["features"].first["maxResults"].must_equal 10
        request["features"].last["type"].must_equal "TEXT_DETECTION"
        request["features"].last["maxResults"].must_equal 1
        request["imageContext"].must_be :nil?
        [200, {"Content-Type" => "application/json"},
         context_response_json]
      end

      image = vision.image filepath
      analysis = vision.annotate image, faces: 10, text: true
      analysis.wont_be :nil?
      analysis.face.wont_be :nil?
      analysis.text.wont_be :nil?
    end

    it "sends when annotating an image with location in context" do
      mock_connection.post "/v1/images:annotate" do |env|
        requests = JSON.parse(env.body)["requests"]
        requests.count.must_equal 1
        request = requests.first
        request["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
        request["features"].count.must_equal 2
        request["features"].first["type"].must_equal "FACE_DETECTION"
        request["features"].first["maxResults"].must_equal 10
        request["features"].last["type"].must_equal "TEXT_DETECTION"
        request["features"].last["maxResults"].must_equal 1
        request["imageContext"].wont_be :nil?
        request["imageContext"]["latLongRect"].must_equal({ "longitude" => -122.0862462, "latitude" => 37.4220041 })
        request["imageContext"]["languageHints"].must_be :nil?
        [200, {"Content-Type" => "application/json"},
         context_response_json]
      end

      image = vision.image filepath
      image.context.location.longitude = -122.0862462
      image.context.location.latitude = 37.4220041
      analysis = vision.annotate image, faces: 10, text: true
      analysis.wont_be :nil?
      analysis.face.wont_be :nil?
      analysis.text.wont_be :nil?
    end

    it "sends when annotating an image with location hash in context" do
      mock_connection.post "/v1/images:annotate" do |env|
        requests = JSON.parse(env.body)["requests"]
        requests.count.must_equal 1
        request = requests.first
        request["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
        request["features"].count.must_equal 2
        request["features"].first["type"].must_equal "FACE_DETECTION"
        request["features"].first["maxResults"].must_equal 10
        request["features"].last["type"].must_equal "TEXT_DETECTION"
        request["features"].last["maxResults"].must_equal 1
        request["imageContext"].wont_be :nil?
        request["imageContext"]["latLongRect"].must_equal({ "longitude" => -122.0862462, "latitude" => 37.4220041 })
        request["imageContext"]["languageHints"].must_be :nil?
        [200, {"Content-Type" => "application/json"},
         context_response_json]
      end

      image = vision.image filepath
      image.context.location = { longitude: -122.0862462, latitude: 37.4220041 }
      analysis = vision.annotate image, faces: 10, text: true
      analysis.wont_be :nil?
      analysis.face.wont_be :nil?
      analysis.text.wont_be :nil?
    end

    it "sends when annotating an image with language hints in context" do
      mock_connection.post "/v1/images:annotate" do |env|
        requests = JSON.parse(env.body)["requests"]
        requests.count.must_equal 1
        request = requests.first
        request["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
        request["features"].count.must_equal 2
        request["features"].first["type"].must_equal "FACE_DETECTION"
        request["features"].first["maxResults"].must_equal 10
        request["features"].last["type"].must_equal "TEXT_DETECTION"
        request["features"].last["maxResults"].must_equal 1
        request["imageContext"].wont_be :nil?
        request["imageContext"]["latLongRect"].must_be :nil?
        request["imageContext"]["languageHints"].must_equal ["en", "es"]
        [200, {"Content-Type" => "application/json"},
         context_response_json]
      end

      image = vision.image filepath
      image.context.languages = ["en", "es"]
      analysis = vision.annotate image, faces: 10, text: true
      analysis.wont_be :nil?
      analysis.face.wont_be :nil?
      analysis.text.wont_be :nil?
    end

    it "sends when annotating an image with location and language hints in context" do
      mock_connection.post "/v1/images:annotate" do |env|
        requests = JSON.parse(env.body)["requests"]
        requests.count.must_equal 1
        request = requests.first
        request["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
        request["features"].count.must_equal 2
        request["features"].first["type"].must_equal "FACE_DETECTION"
        request["features"].first["maxResults"].must_equal 10
        request["features"].last["type"].must_equal "TEXT_DETECTION"
        request["features"].last["maxResults"].must_equal 1
        request["imageContext"].wont_be :nil?
        request["imageContext"]["latLongRect"].must_equal({ "longitude" => -122.0862462, "latitude" => 37.4220041 })
        request["imageContext"]["languageHints"].must_equal ["en", "es"]
        [200, {"Content-Type" => "application/json"},
         context_response_json]
      end

      image = vision.image filepath
      image.context.location = { longitude: -122.0862462, latitude: 37.4220041 }
      image.context.languages = ["en", "es"]
      analysis = vision.annotate image, faces: 10, text: true
      analysis.wont_be :nil?
      analysis.face.wont_be :nil?
      analysis.text.wont_be :nil?
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
        labelAnnotations: [label_annotation_response]
      }, {
        labelAnnotations: [label_annotation_response]
      }]
    }.to_json
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

  def full_response_json
    {
      responses: [{
        faceAnnotations: [face_annotation_response],
        landmarkAnnotations: [landmark_annotation_response],
        logoAnnotations: [logo_annotation_response],
        labelAnnotations: [label_annotation_response],
        textAnnotations: text_annotation_responses,
        safeSearchAnnotation: safe_search_annotation_response,
        imagePropertiesAnnotation: properties_annotation_response
      }]
    }.to_json
  end

  def context_response_json
    {
      responses: [{
        faceAnnotations: [face_annotation_response],
        textAnnotations: text_annotation_responses
      }]
    }.to_json
  end
end
