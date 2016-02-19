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

describe Gcloud::Logging::Entry, :to_grpc, :mock_logging do
  let(:entry) { Gcloud::Logging::Entry.new }

  it "returns the correct data when empty" do
    entry.must_be :empty?

    grpc = entry.to_grpc

    grpc.log_name.must_be :empty?
    grpc.resource.must_be :nil?
    grpc.severity.must_equal :DEFAULT
    grpc.timestamp.must_be :nil?
    grpc.insert_id.must_be :empty?
    grpc.labels.to_h.must_be :empty?
    grpc.text_payload.must_be :empty?
    grpc.json_payload.must_be :nil?
    grpc.proto_payload.must_be :nil?
    grpc.http_request.must_be :nil?
    grpc.operation.must_be :nil?
  end

  it "returns the correct data when data is added" do
    entry.log_name = "projects/test/logs/testlog"

    entry.resource.type =        "webapp_server"
    entry.resource.labels =      { "env"         => "test",
                                   "valueType"   => "STRING",
                                   "description" => "The server is running in test" }

    entry.severity = :ERROR
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

    grpc = entry.to_grpc

    grpc.log_name.must_equal "projects/test/logs/testlog"

    grpc.resource.type.must_equal        "webapp_server"
    grpc.resource.labels.to_h.must_equal({ "description" => "The server is running in test",
                                           "env"         => "test",
                                           "valueType"   => "STRING" })

    grpc.severity.must_equal :ERROR
    grpc.timestamp.must_equal Google::Protobuf::Timestamp.new(seconds: Time.parse("2016-01-02T03:04:05Z").to_i)
    grpc.insert_id.must_equal "insert123"
    grpc.labels.to_h.must_equal("env" => "test", "fizz" => "buzz")
    grpc.text_payload.must_equal "payload"
    grpc.json_payload.must_be :nil?
    grpc.proto_payload.must_be :nil?

    grpc.http_request.request_method.must_equal "POST"
    grpc.http_request.request_url.must_equal "http://test.local/fizz?buzz"
    grpc.http_request.request_size.must_equal 456
    grpc.http_request.status.must_equal 201
    grpc.http_request.response_size.must_equal 345
    grpc.http_request.user_agent.must_equal "gcloud-ruby/1.0.0"
    grpc.http_request.remote_ip.must_equal "127.0.0.1"
    grpc.http_request.referer.must_equal "http://test.local/referer"
    grpc.http_request.cache_hit.must_equal true
    grpc.http_request.validated_with_origin_server.must_equal false

    grpc.operation.id.must_equal "abc123"
    grpc.operation.producer.must_equal "NewApp.NewClass#new_method"
    grpc.operation.first.must_equal true
    grpc.operation.last.must_equal false
  end
end
