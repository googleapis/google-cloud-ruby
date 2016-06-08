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

describe Gcloud::Vision::Image, :safe_search, :mock_vision do
  let(:filepath) { "acceptance/data/face.jpg" }
  let(:image)    { vision.image filepath }

  it "detects safe_search" do
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

    safe_search = image.safe_search
    safe_search.wont_be :nil?
    safe_search.wont_be :adult?
    safe_search.wont_be :spoof?
    safe_search.must_be :medical?
    safe_search.must_be :violence?
  end

  def safe_search_response_json
    {
      responses: [{
        safeSearchAnnotation: safe_search_annotation_response
      }]
    }.to_json
  end
end
