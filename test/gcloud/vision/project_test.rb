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
    analysis.wont_be :nil?
    analysis.face.wont_be :nil?
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
    analysis.wont_be :nil?
    analysis.landmark.wont_be :nil?
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

    analysis = vision.mark filepath, logos: 1
    analysis.wont_be :nil?
    analysis.logo.wont_be :nil?
  end

  it "detects logo detection using annotate alias" do
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

    analyses = vision.mark filepath, filepath, logos: 1
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

    analysis = vision.mark filepath, labels: 1
    analysis.wont_be :nil?
    analysis.label.wont_be :nil?
  end

  it "detects label detection using annotate alias" do
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

    analyses = vision.mark filepath, filepath, labels: 1
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

    analysis = vision.mark filepath, text: true
    analysis.wont_be :nil?
    analysis.text.wont_be :nil?
  end

  it "detects text detection using annotate alias" do
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

    analyses = vision.mark filepath, filepath, text: true
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

    analysis = vision.mark filepath, safe_search: true
    analysis.wont_be :nil?

    analysis.safe_search.wont_be :nil?
    analysis.safe_search.wont_be :adult?
    analysis.safe_search.wont_be :spoof?
    analysis.safe_search.must_be :medical?
    analysis.safe_search.must_be :violence?
  end

  it "detects safe_search detection using annotate alias" do
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

    analyses = vision.mark filepath, filepath, safe_search: true
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

  def text_annotation_responses
    [ text_annotation_response,
      {"description"=>"Google", "boundingPoly"=>{"vertices"=>[{"x"=>13, "y"=>8}, {"x"=>53, "y"=>8}, {"x"=>53, "y"=>23}, {"x"=>13, "y"=>23}]}},
      {"description"=>"Cloud", "boundingPoly"=>{"vertices"=>[{"x"=>59, "y"=>8}, {"x"=>89, "y"=>8}, {"x"=>89, "y"=>23}, {"x"=>59, "y"=>23}]}},
      {"description"=>"Client", "boundingPoly"=>{"vertices"=>[{"x"=>96, "y"=>8}, {"x"=>128, "y"=>8}, {"x"=>128, "y"=>23}, {"x"=>96, "y"=>23}]}},
      {"description"=>"Library", "boundingPoly"=>{"vertices"=>[{"x"=>132, "y"=>8}, {"x"=>170, "y"=>8}, {"x"=>170, "y"=>23}, {"x"=>132, "y"=>23}]}},
      {"description"=>"for", "boundingPoly"=>{"vertices"=>[{"x"=>175, "y"=>8}, {"x"=>191, "y"=>8}, {"x"=>191, "y"=>23}, {"x"=>175, "y"=>23}]}},
      {"description"=>"Ruby", "boundingPoly"=>{"vertices"=>[{"x"=>195, "y"=>8}, {"x"=>221, "y"=>8}, {"x"=>221, "y"=>23}, {"x"=>195, "y"=>23}]}},
      {"description"=>"an", "boundingPoly"=>{"vertices"=>[{"x"=>236, "y"=>8}, {"x"=>245, "y"=>8}, {"x"=>245, "y"=>23}, {"x"=>236, "y"=>23}]}},
      {"description"=>"idiomatic,", "boundingPoly"=>{"vertices"=>[{"x"=>250, "y"=>8}, {"x"=>307, "y"=>8}, {"x"=>307, "y"=>23}, {"x"=>250, "y"=>23}]}},
      {"description"=>"intuitive,", "boundingPoly"=>{"vertices"=>[{"x"=>311, "y"=>8}, {"x"=>360, "y"=>8}, {"x"=>360, "y"=>23}, {"x"=>311, "y"=>23}]}},
      {"description"=>"and", "boundingPoly"=>{"vertices"=>[{"x"=>363, "y"=>8}, {"x"=>385, "y"=>8}, {"x"=>385, "y"=>23}, {"x"=>363, "y"=>23}]}},
      {"description"=>"natural", "boundingPoly"=>{"vertices"=>[{"x"=>13, "y"=>33}, {"x"=>52, "y"=>33}, {"x"=>52, "y"=>49}, {"x"=>13, "y"=>49}]}},
      {"description"=>"way", "boundingPoly"=>{"vertices"=>[{"x"=>56, "y"=>33}, {"x"=>77, "y"=>33}, {"x"=>77, "y"=>49}, {"x"=>56, "y"=>49}]}},
      {"description"=>"for", "boundingPoly"=>{"vertices"=>[{"x"=>82, "y"=>33}, {"x"=>98, "y"=>33}, {"x"=>98, "y"=>49}, {"x"=>82, "y"=>49}]}},
      {"description"=>"Ruby", "boundingPoly"=>{"vertices"=>[{"x"=>102, "y"=>33}, {"x"=>130, "y"=>33}, {"x"=>130, "y"=>49}, {"x"=>102, "y"=>49}]}},
      {"description"=>"developers", "boundingPoly"=>{"vertices"=>[{"x"=>135, "y"=>33}, {"x"=>196, "y"=>33}, {"x"=>196, "y"=>49}, {"x"=>135, "y"=>49}]}},
      {"description"=>"to", "boundingPoly"=>{"vertices"=>[{"x"=>201, "y"=>33}, {"x"=>212, "y"=>33}, {"x"=>212, "y"=>49}, {"x"=>201, "y"=>49}]}},
      {"description"=>"integrate", "boundingPoly"=>{"vertices"=>[{"x"=>215, "y"=>33}, {"x"=>265, "y"=>33}, {"x"=>265, "y"=>49}, {"x"=>215, "y"=>49}]}},
      {"description"=>"with", "boundingPoly"=>{"vertices"=>[{"x"=>270, "y"=>33}, {"x"=>293, "y"=>33}, {"x"=>293, "y"=>49}, {"x"=>270, "y"=>49}]}},
      {"description"=>"Google", "boundingPoly"=>{"vertices"=>[{"x"=>299, "y"=>33}, {"x"=>339, "y"=>33}, {"x"=>339, "y"=>49}, {"x"=>299, "y"=>49}]}},
      {"description"=>"Cloud", "boundingPoly"=>{"vertices"=>[{"x"=>345, "y"=>33}, {"x"=>376, "y"=>33}, {"x"=>376, "y"=>49}, {"x"=>345, "y"=>49}]}},
      {"description"=>"Platform", "boundingPoly"=>{"vertices"=>[{"x"=>13, "y"=>59}, {"x"=>59, "y"=>59}, {"x"=>59, "y"=>74}, {"x"=>13, "y"=>74}]}},
      {"description"=>"services,", "boundingPoly"=>{"vertices"=>[{"x"=>67, "y"=>59}, {"x"=>117, "y"=>59}, {"x"=>117, "y"=>74}, {"x"=>67, "y"=>74}]}},
      {"description"=>"like", "boundingPoly"=>{"vertices"=>[{"x"=>121, "y"=>59}, {"x"=>138, "y"=>59}, {"x"=>138, "y"=>74}, {"x"=>121, "y"=>74}]}},
      {"description"=>"Cloud", "boundingPoly"=>{"vertices"=>[{"x"=>145, "y"=>59}, {"x"=>177, "y"=>59}, {"x"=>177, "y"=>74}, {"x"=>145, "y"=>74}]}},
      {"description"=>"Datastore", "boundingPoly"=>{"vertices"=>[{"x"=>181, "y"=>59}, {"x"=>236, "y"=>59}, {"x"=>236, "y"=>74}, {"x"=>181, "y"=>74}]}},
      {"description"=>"and", "boundingPoly"=>{"vertices"=>[{"x"=>242, "y"=>59}, {"x"=>260, "y"=>59}, {"x"=>260, "y"=>74}, {"x"=>242, "y"=>74}]}},
      {"description"=>"Cloud", "boundingPoly"=>{"vertices"=>[{"x"=>267, "y"=>59}, {"x"=>298, "y"=>59}, {"x"=>298, "y"=>74}, {"x"=>267, "y"=>74}]}},
      {"description"=>"Storage.", "boundingPoly"=>{"vertices"=>[{"x"=>304, "y"=>59}, {"x"=>351, "y"=>59}, {"x"=>351, "y"=>74}, {"x"=>304, "y"=>74}]}}
    ]
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
