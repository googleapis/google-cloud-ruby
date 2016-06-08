# Copyright 2014 Google Inc. All rights reserved.
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
require "json"
require "uri"

describe "Gcloud Vision Backoff", :mock_vision do
  let(:filepath) { "acceptance/data/face.jpg" }

  it "annotates an image with backoff" do
    2.times do
      mock_connection.post "/v1/images:annotate" do |env|
        requests = JSON.parse(env.body)["requests"]
        requests.count.must_equal 1
        requests.first["features"].count.must_equal 1
        requests.first["features"].first["type"].must_equal "FACE_DETECTION"
        requests.first["features"].first["maxResults"].must_equal 10
        [500, {"Content-Type" => "application/json"}, nil]
      end
    end
    mock_connection.post "/v1/images:annotate" do |env|
      requests = JSON.parse(env.body)["requests"]
      requests.count.must_equal 1
      requests.first["features"].count.must_equal 1
      requests.first["features"].first["type"].must_equal "FACE_DETECTION"
      requests.first["features"].first["maxResults"].must_equal 10
      [200, {"Content-Type" => "application/json"},
       faces_response_json]
    end

    assert_backoff_sleep 1, 2 do
      annotation = vision.annotate filepath, faces: 10
      annotation.face.wont_be :nil?
    end
  end

  def faces_response_json
    {
      responses: [{
        faceAnnotations: [face_annotation_response]
      }]
    }.to_json
  end

  def assert_backoff_sleep *args
    mock = Minitest::Mock.new
    args.each { |intv| mock.expect :sleep, nil, [intv] }
    callback = ->(retries) { mock.sleep retries }
    backoff = Gcloud::Backoff.new backoff: callback

    Gcloud::Backoff.stub :new, backoff do
      yield
    end

    mock.verify
  end
end
