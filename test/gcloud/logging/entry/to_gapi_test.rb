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

describe Gcloud::Logging::Entry, :to_gapi, :mock_logging do
  let(:entry) { Gcloud::Logging::Entry.new }

  it "returns the correct data" do
    entry.log_name = "projects/test/logs/testlog"

    entry.resource.type =        "webapp_server"
    entry.resource.labels =      { "env"         => "test",
                                   "valueType"   => "STRING",
                                   "description" => "The server is running in test" }

    entry.severity = "ERROR"
    entry.timestamp = Time.parse("2016-01-02T03:04:05Z")
    entry.insert_id = "insert123"
    entry.labels = { env: :test }
    entry.labels["fizz"] = "buzz"
    entry.payload = "payload"

    entry.http_request.method = "POST"
    entry.http_request.url = "http://test.local/fizz?buzz"
    entry.http_request.size = "456"
    entry.http_request.status = 201
    entry.http_request.response_size = "345"
    entry.http_request.user_agent = "gcloud-ruby/1.0.0"
    entry.http_request.remote_ip = "127.0.0.1"
    entry.http_request.referer = "http://test.local/referer"
    entry.http_request.cache_hit = true
    entry.http_request.validated = false

    entry.operation.id = "abc123"
    entry.operation.producer = "NewApp.NewClass#new_method"
    entry.operation.first = true
    entry.operation.last = false

    gapi = entry.to_gapi

    gapi["logName"].must_equal "projects/test/logs/testlog"

    gapi["resource"]["type"].must_equal        "webapp_server"
    gapi["resource"]["labels"].must_equal({ "env"         => "test",
                                                 "valueType"   => "STRING",
                                                 "description" => "The server is running in test" })

    gapi["severity"].must_equal "ERROR"
    gapi["timestamp"].must_equal "2016-01-02T03:04:05Z"
    gapi["insertId"].must_equal "insert123"
    gapi["labels"].must_equal(env: :test, "fizz" => "buzz")
    gapi["textPayload"].must_equal "payload"
    gapi["jsonPayload"].must_be :nil?
    gapi["protoPayload"].must_be :nil?

    gapi["httpRequest"]["requestMethod"].must_equal "POST"
    gapi["httpRequest"]["requestUrl"].must_equal "http://test.local/fizz?buzz"
    gapi["httpRequest"]["requestSize"].must_equal "456"
    gapi["httpRequest"]["status"].must_equal 201
    gapi["httpRequest"]["responseSize"].must_equal "345"
    gapi["httpRequest"]["userAgent"].must_equal "gcloud-ruby/1.0.0"
    gapi["httpRequest"]["remoteIp"].must_equal "127.0.0.1"
    gapi["httpRequest"]["referer"].must_equal "http://test.local/referer"
    gapi["httpRequest"]["cacheHit"].must_equal true
    gapi["httpRequest"]["validatedWithOriginServer"].must_equal false

    gapi["operation"]["id"].must_equal "abc123"
    gapi["operation"]["producer"].must_equal "NewApp.NewClass#new_method"
    gapi["operation"]["first"].must_equal true
    gapi["operation"]["last"].must_equal false
  end
end
