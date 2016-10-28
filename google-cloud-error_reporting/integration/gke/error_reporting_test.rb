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
require "google/cloud/error_reporting/v1beta1"

describe Google::Cloud::ErrorReporting do
  let(:gke_pod_name) { ENV["TEST_GKE_POD_NAME"] }

  it "submits error event to Stackdriver Error Reporting service" do
    error_token = Time.now.to_i
    error_reporting_uri = URI("http://localhost:8080/test_error_reporting")
    error_reporting_uri.query="token=#{error_token}"

    response = Open3.capture3("kubectl exec #{gke_pod_name} -- " \
               "curl #{error_reporting_uri.to_s}").first

    # TODO: Find a better way to verify response. Or even better, validate the
    # error event was indeed reported to ErrorReporting
    response.must_match error_token.to_s
  end
end
