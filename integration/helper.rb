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


require "fileutils"
require "open3"
require "net/http"

##
# Keep trying a block of code until the code of block yield a true statement or
# raise error after timeout
def keep_trying_till_true timeout = 30
  t_begin = Time.now
  delay = 10
  loop do
    if yield
      break
    elsif (Time.now - t_begin) > timeout
      fail "Timeout after trying for #{timeout} seconds"
    else
      sleep delay
    end
    delay += 1
  end
end

##
# Verify the given uri can be accessed successfully.
def verify_uri_acessibility uri
  res = Net::HTTP.get_response URI(uri)
  res.is_a? Net::HTTPSuccess
end

##
# Get GCP project id from Gcloud SDK
def gcloud_project_id
  stdout = Open3.capture3("gcloud config list project").first
  stdout.scan(/project = (.*)/).first.first
end

##
# Helper method to send a HTTP request to test app hosted from GCP environments.
#
# If TEST_GKE_POD_NAME environment variable is set, then we assume we're testing
# against an app hosted in GKE. Then the HTTP requestion will be made from
# inside the GKE VM instance by using "kubectl exec". If TEST_GKE_POD_NAME is
# not set, then we assume it's GAE environment, and we can make an HTTP request
# the normal way.
#
# The base URL can be provided through TEST_GOOGLE_CLOUD_PROJECT_URI environment
# variable. Otherwise default to "http://localhost:8080"
#
# return the response body
#
def send_request path, query_params = nil
  base_url = ENV["TEST_GOOGLE_CLOUD_PROJECT_URI"] || "http://localhost:8080"
  uri = URI.join(base_url, path)
  uri.query= query_params if query_params

  gke_pod_name = ENV["TEST_GKE_POD_NAME"]

  if gke_pod_name
    Open3.capture3("kubectl exec #{gke_pod_name} -- curl #{uri.to_s}").first
  else
    response = Net::HTTP.get_response uri
    response.body
  end
end
