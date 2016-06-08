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

describe Gcloud::Vision::Image, :text, :mock_vision do
  let(:filepath) { "acceptance/data/text.png" }
  let(:image)    { vision.image filepath }

  it "detects text" do
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

    text = image.text
    text.wont_be :nil?
    text.text.must_include "Google Cloud Client Library for Ruby"
    text.locale.must_equal "en"
    text.words.count.must_equal 28
    text.words[0].text.must_equal "Google"
    text.words[0].bounds.map(&:to_a).must_equal [[13, 8], [53, 8], [53, 23], [13, 23]]
    text.words[27].text.must_equal "Storage."
    text.words[27].bounds.map(&:to_a).must_equal [[304, 59], [351, 59], [351, 74], [304, 74]]
  end

  def text_response_json
    {
      responses: [{
        textAnnotations: text_annotation_responses
      }]
    }.to_json
  end
end
