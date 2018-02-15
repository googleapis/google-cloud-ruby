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


require "error_reporting_helper"
require "google/cloud/error_reporting/v1beta1"


describe Google::Cloud::ErrorReporting do
  it "submits error event to Stackdriver Error Reporting service" do
    token = Time.now.to_i
    response = send_request "test_error_reporting", "token=#{token}"

    # TODO: Find a better way to verify response. Or even better, validate the
    # error event was indeed reported to ErrorReporting
    response.must_match /Test error from .*: #{token}/
  end
end
