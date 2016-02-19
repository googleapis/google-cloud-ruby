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

describe Gcloud::Logging::Entry, :mock_logging do
  let(:entry_hash) { random_entry_hash }
  let(:entry_json) { entry_hash.to_json }
  let(:entry_grpc) { Google::Logging::V2::LogEntry.decode_json entry_json }
  let(:entry) { Gcloud::Logging::Entry.from_grpc entry_grpc }

  it "knows its attributes" do
    entry.log_name.must_equal             entry_hash["log_name"]
    entry.resource.must_be_kind_of        Gcloud::Logging::Resource
    entry.timestamp.to_i.must_equal       Time.parse("2014-10-02T15:01:23.045123456Z").to_i
    entry.severity.must_equal             entry_hash["severity"]
    entry.insert_id.must_equal            entry_hash["insert_id"]
    entry.labels.must_be_kind_of          Hash
    entry.labels["env"].must_equal        "production"
    entry.labels["foo"].must_equal        "bar"
    entry.payload.must_equal              "payload"
    entry.http_request.must_be_kind_of    Gcloud::Logging::Entry::HttpRequest
    entry.operation.must_be_kind_of       Gcloud::Logging::Entry::Operation
  end

  it "timestamp gives the correct time when a timestamp is present" do
    custom_timestamp = Time.parse "2016-01-02T03:04:05.06Z"
    entry_grpc.timestamp.seconds = custom_timestamp.to_i
    entry_grpc.timestamp.nanos = custom_timestamp.nsec
    entry = Gcloud::Logging::Entry.from_grpc entry_grpc
    entry.timestamp.wont_be :nil?
    entry.timestamp.must_equal custom_timestamp
  end

  it "timestamp returns nil when not present" do
    entry_hash["timestamp"] = nil
    entry.timestamp.must_be :nil?
  end

  it "timestamp gives nil when no timestamp is present" do
    entry.timestamp = nil
    entry.timestamp.must_be :nil?
  end

  it "labels will return a Hash even when missing from the Google API object" do
    entry_hash["labels"] = nil
    entry.labels.must_be_kind_of Hash
    entry.labels.must_be :empty?
  end

  it "can have a JSON payload" do
    entry.payload = { "pay" => "load" }
    entry.payload.must_be_kind_of Hash
    entry.payload["pay"].must_equal "load"
  end

  it "can have a ProtoBuf payload" do
    skip
    proto = OpenStruct.new to_proto: { "id" => 1234, "@type" => "types.example.com/standard/id" }
    entry.payload = proto
    grpc = entry.to_grpc
    grpc.proto_payload.must_be_kind_of Hash
    grpc.proto_payload["id"].must_equal 1234
    grpc.proto_payload["@type"].must_equal "types.example.com/standard/id"
  end

  it "has the correct resource attributes" do
    entry.resource.type.must_equal        entry_hash["resource"]["type"]
    entry.resource.labels.must_equal      entry_hash["resource"]["labels"]
  end

  it "has a resource even if the Google API object doesn't have it" do
    entry_hash.delete "resource"

    entry.resource.wont_be :nil?
    entry.resource.must_be_kind_of Gcloud::Logging::Resource
    entry.resource.type.must_be :nil?
    entry.resource.labels.must_be_kind_of Hash
    entry.resource.labels.must_be :empty?
  end

  it "has the correct http_request attributes" do
    entry.http_request.method.must_equal "GET"
    entry.http_request.url.must_equal "http://test.local/foo?bar=baz"
    entry.http_request.size.must_equal 123
    entry.http_request.status.must_equal 200
    entry.http_request.response_size.must_equal 456
    entry.http_request.user_agent.must_equal "gcloud-ruby/1.0.0"
    entry.http_request.remote_ip.must_equal "127.0.0.1"
    entry.http_request.referer.must_equal "http://test.local/referer"
    entry.http_request.cache_hit.must_equal false
    entry.http_request.validated.must_equal false
  end

  it "has an http_request even if the Google API object doesn't have it" do
    entry_hash.delete "http_request"

    entry.http_request.wont_be :nil?
    entry.http_request.must_be_kind_of Gcloud::Logging::Entry::HttpRequest
    entry.http_request.method.must_be :nil?
    entry.http_request.url.must_be :nil?
    entry.http_request.size.must_be :nil?
    entry.http_request.status.must_be :nil?
    entry.http_request.response_size.must_be :nil?
    entry.http_request.user_agent.must_be :nil?
    entry.http_request.remote_ip.must_be :nil?
    entry.http_request.referer.must_be :nil?
    entry.http_request.cache_hit.must_be :nil?
    entry.http_request.validated.must_be :nil?
  end

  it "has the correct operation attributes" do
    entry.operation.id.must_equal "xyz789"
    entry.operation.producer.must_equal "MyApp.MyClass#my_method"
    entry.operation.first.must_equal false
    entry.operation.last.must_equal false
  end

  it "has an operation even if the Google API object doesn't have it" do
    entry_hash.delete "operation"

    entry.operation.wont_be :nil?
    entry.operation.must_be_kind_of Gcloud::Logging::Entry::Operation
    entry.operation.id.must_be :nil?
    entry.operation.producer.must_be :nil?
    entry.operation.first.must_be :nil?
    entry.operation.last.must_be :nil?
  end
end
