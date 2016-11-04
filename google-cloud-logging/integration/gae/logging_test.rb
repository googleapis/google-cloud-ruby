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


require "minitest/autorun"
require "minitest/rg"
require "minitest/focus"
require "net/http"
require "open3"
require "json"
require "google/cloud/logging"
require_relative "../../../integration/helper"

describe Google::Cloud::Logging do
  let(:project_uri) { ENV["TEST_GOOGLE_CLOUD_PROJECT_URI"] }

  it "submits logs on GAE with sinatra" do
    token = Time.now.to_i
    logging_uri = URI(project_uri + "/test_logging")
    logging_uri.query="token=#{token}"
    Net::HTTP.get logging_uri

    stdout = Open3.capture3("gcloud config list project").first
    project_id = stdout.scan(/project = (.*)/).first.first

    logs = []
    keep_trying_till_true do
      stdout = Open3.capture3(
        "gcloud beta logging read \"logName=projects/#{project_id}/logs/google-cloud-ruby_integration_test " \
        "AND textPayload:#{token}\" --limit 1 --format json"
      ).first
      logs = JSON.parse(stdout)
      logs.length == 1
    end

    logs.length.must_equal 1
  end
end
