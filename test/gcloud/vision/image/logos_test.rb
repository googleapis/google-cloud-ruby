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

describe Gcloud::Vision::Image, :logos, :mock_vision do
  let(:filepath) { "acceptance/data/logo.jpg" }
  let(:image)    { vision.image filepath }

  it "detects multiple logos" do
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      logo = requests.first
      logo["image"]["content"].must_equal Base64.encode64(File.read(filepath, mode: "rb"))
      logo["features"].count.must_equal 1
      logo["features"].first["type"].must_equal "LOGO_DETECTION"
      logo["features"].first["maxResults"].must_equal 10
      [200, {"Content-Type" => "application/json"},
       logos_response_json]
    end

    logos = image.logos 10
    logos.count.must_equal 5
  end

  it "detects a logo" do
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

    logo = image.logo
    logo.wont_be :nil?
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
        logoAnnotations: [logo_annotation_response,
                          logo_annotation_response,
                          logo_annotation_response,
                          logo_annotation_response,
                          logo_annotation_response]
      }]
    }.to_json
  end
end
