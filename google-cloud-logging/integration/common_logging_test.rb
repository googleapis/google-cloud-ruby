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


require "logging_helper"
require "google/cloud/logging"

describe Google::Cloud::Logging do
  it "correctly setups logger" do
    response = nil
    keep_trying_till_true 120 do
      begin
        response = JSON.parse send_request("test_logger")
      rescue
        nil
      end
    end

    response["logger_class"].must_equal "Google::Cloud::Logging::Logger"
    response["writer_class"].must_equal "Google::Cloud::Logging::AsyncWriter"
  end

  it "submits logs on GAE" do
    token = Time.now.to_i
    send_request "test_logging", "token=#{token}"

    logs = []
    keep_trying_till_true 120 do
      stdout = Open3.capture3(
        "gcloud beta logging read \"logName=projects/#{gcloud_project_id}/logs/google-cloud-ruby_integration_test " \
        "AND textPayload:#{token}\" --limit 1 --format json"
      ).first
      logs = JSON.parse stdout
      logs.length == 1
    end

    logs.length.must_equal 1
  end
end


