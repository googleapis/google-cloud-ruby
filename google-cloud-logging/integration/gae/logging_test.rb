# Copyright 2016 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "logging_helper"
require "google/cloud/logging"

describe Google::Cloud::Logging do
  it "Uses monitored resource with 'gae_app' type" do
    response = nil
    keep_trying_till_true 120 do
      begin
        response = JSON.parse send_request("test_logger")
      rescue
        nil
      end
    end

    response["monitored_resource"]["type"].must_equal "gae_app"
    response["monitored_resource"]["labels"]["module_id"].wont_be_nil
    response["monitored_resource"]["labels"]["version_id"].wont_be_nil
  end

  it "injects trace_id into each log entry" do
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

    logs[0]["labels"]["traceId"].wont_be_nil
  end
end
