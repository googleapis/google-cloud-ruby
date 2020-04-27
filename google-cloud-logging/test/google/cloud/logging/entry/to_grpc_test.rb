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

require "helper"

describe Google::Cloud::Logging::Entry, :to_grpc, :mock_logging do
  let(:default_insert_id) { "abc-123" }
  let :entry do
    Google::Cloud::Logging::Entry.stub :insert_id, default_insert_id do
      Google::Cloud::Logging::Entry.new
    end
  end

  it "returns the correct data when empty" do
    _(entry).must_be :empty?
    # empty even though insert_id has a value
    _(entry.insert_id).must_equal default_insert_id

    grpc = entry.to_grpc

    _(grpc.log_name).must_be :empty?
    _(grpc.resource).must_be :nil?
    _(grpc.severity).must_equal :DEFAULT
    _(grpc.timestamp).must_be :nil?
    _(grpc.insert_id).must_equal default_insert_id
    _(Google::Cloud::Logging::Convert.map_to_hash(grpc.labels)).must_be :empty?
    _(grpc.text_payload).must_be :empty?
    _(grpc.json_payload).must_be :nil?
    _(grpc.proto_payload).must_be :nil?
    _(grpc.http_request).must_be :nil?
    _(grpc.operation).must_be :nil?
    _(grpc.trace).must_be :empty?
    _(grpc.source_location).must_be :nil?
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
    entry.http_request.user_agent = "google-cloud/1.0.0"
    entry.http_request.remote_ip = "127.0.0.1"
    entry.http_request.referer = "http://test.local/referer"
    entry.http_request.cache_hit = true
    entry.http_request.validated = false

    entry.operation.id = "abc123"
    entry.operation.producer = "NewApp.NewClass#new_method"
    entry.operation.first = true
    entry.operation.last = false

    entry.trace = "projects/my-projectid/traces/06796866738c859f2f19b7cfb3214824"

    entry.source_location.file = "my_app/my_class.rb"
    entry.source_location.line = 123
    entry.source_location.function = "#my_method"

    grpc = entry.to_grpc

    _(grpc.log_name).must_equal "projects/test/logs/testlog"

    _(grpc.resource.type).must_equal        "webapp_server"
    _(Google::Cloud::Logging::Convert.map_to_hash(grpc.resource.labels)).must_equal({ "description" => "The server is running in test",
                                                                     "env"         => "test",
                                                                     "valueType"   => "STRING" })

    _(grpc.severity).must_equal :ERROR
    _(grpc.timestamp).must_equal Google::Protobuf::Timestamp.new(seconds: Time.parse("2016-01-02T03:04:05Z").to_i)
    _(grpc.insert_id).must_equal "insert123"
    _(Google::Cloud::Logging::Convert.map_to_hash(grpc.labels)).must_equal("env" => "test", "fizz" => "buzz")
    _(grpc.text_payload).must_equal "payload"
    _(grpc.json_payload).must_be :nil?
    _(grpc.proto_payload).must_be :nil?

    _(grpc.http_request.request_method).must_equal "POST"
    _(grpc.http_request.request_url).must_equal "http://test.local/fizz?buzz"
    _(grpc.http_request.request_size).must_equal 456
    _(grpc.http_request.status).must_equal 201
    _(grpc.http_request.response_size).must_equal 345
    _(grpc.http_request.user_agent).must_equal "google-cloud/1.0.0"
    _(grpc.http_request.remote_ip).must_equal "127.0.0.1"
    _(grpc.http_request.referer).must_equal "http://test.local/referer"
    _(grpc.http_request.cache_hit).must_equal true
    _(grpc.http_request.cache_validated_with_origin_server).must_equal false

    _(grpc.operation.id).must_equal "abc123"
    _(grpc.operation.producer).must_equal "NewApp.NewClass#new_method"
    _(grpc.operation.first).must_equal true
    _(grpc.operation.last).must_equal false

    _(grpc.trace).must_equal "projects/my-projectid/traces/06796866738c859f2f19b7cfb3214824"

    _(grpc.source_location.file).must_equal "my_app/my_class.rb"
    _(grpc.source_location.line).must_equal 123
    _(grpc.source_location.function).must_equal "#my_method"
  end
end
