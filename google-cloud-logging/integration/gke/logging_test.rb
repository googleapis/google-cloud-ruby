# Copyright 2016 Google LLC
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
  it "Uses monitored resource with 'container' type" do
    response = nil
    keep_trying_till_true 120 do
      begin
        response = JSON.parse send_request("test_logger")
      rescue
        nil
      end
    end

    response["monitored_resource"]["type"].must_equal "container"
    response["monitored_resource"]["labels"]["cluster_name"].wont_be_nil
    response["monitored_resource"]["labels"]["namespace_id"].wont_be_nil
  end
end
