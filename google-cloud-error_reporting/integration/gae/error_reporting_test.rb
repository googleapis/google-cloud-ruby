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
require "google/cloud/error_reporting/v1beta1"


describe Google::Cloud::ErrorReporting do
  let(:project_uri) { ENV['TEST_GOOGLE_CLOUD_PROJECT_URI'] }

  it "submits error event to Stackdriver Error Reporting service" do
    error_token = Time.now.to_i
    error_reporting_uri = URI(project_uri + "/test_error_reporting")
    error_reporting_uri.query="token=#{error_token}"
    response = Net::HTTP.get_response error_reporting_uri

    # TODO: Find a better way to verify response. Or even better, validate the
    # error event was indeed reported to ErrorReporting
    response.code.must_equal "500"
    response.body.must_match error_token.to_s
  end
end
