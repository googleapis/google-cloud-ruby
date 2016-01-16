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
  let(:entry) { Gcloud::Logging::Entry.from_gapi entry_hash }
  let(:entry_hash) { random_entry_hash }

  it "knows its attributes" do
    entry.log_name.must_equal             entry_hash["logName"]
    entry.resource.must_be_kind_of        Gcloud::Logging::Resource
    entry.timestamp.must_equal            Time.parse(entry_hash["timestamp"])
    entry.severity.must_equal             entry_hash["severity"]
    entry.insert_id.must_equal            entry_hash["insertId"]
    entry.labels.must_be_kind_of          Hash
    entry.labels["env"].must_equal        "production"
    entry.labels["foo"].must_equal        "bar"
    entry.payload.must_equal              "payload"
    entry.http_request.must_be_kind_of    Gcloud::Logging::Entry::HttpRequest
    entry.operation.must_be_kind_of       Gcloud::Logging::Entry::Operation
  end

  it "timestamp gives the correct time when a timestamp is present" do
    custom_timestamp = "2016-01-02T03:04:05.06Z"
    entry = Gcloud::Logging::Entry.from_gapi "timestamp" => custom_timestamp
    entry.timestamp.wont_be :nil?
    entry.timestamp.must_equal Time.parse(custom_timestamp)
  end

  it "timestamp gives nil when no timestamp is present" do
    entry.timestamp = nil
    entry.timestamp.must_be :nil?
  end

  it "labels will return a Hash even when missing from the Google API object" do
    entry = Gcloud::Logging::Entry.from_gapi "labels" => nil
    entry.labels.must_be_kind_of Hash
  end

  it "can have a JSON payload" do
    entry.payload = { "pay" => "load" }
    entry.payload.must_be_kind_of Hash
    entry.payload["pay"].must_equal "load"
  end

  it "can have a ProtoBuf payload" do
    proto = OpenStruct.new to_proto: { "id" => 1234, "@type" => "types.example.com/standard/id" }
    entry.payload = proto
    gapi = entry.to_gapi
    gapi["protoPayload"].must_be_kind_of Hash
    gapi["protoPayload"]["id"].must_equal 1234
    gapi["protoPayload"]["@type"].must_equal "types.example.com/standard/id"
  end

  it "has the correct resource attributes" do
    entry.resource.type.must_equal        entry_hash["resource"]["type"]
    entry.resource.name.must_equal        entry_hash["resource"]["displayName"]
    entry.resource.description.must_equal entry_hash["resource"]["description"]
    entry.resource.labels.must_equal      entry_hash["resource"]["labels"]
  end

  it "has a resource even if the Google API object doesn't have it" do
    custom_entry_hash = random_entry_hash
    custom_entry_hash.delete "resource"
    custom_entry = Gcloud::Logging::Entry.from_gapi custom_entry_hash

    custom_entry.resource.must_be_kind_of Gcloud::Logging::Resource
    custom_entry.resource.type.must_be :nil?
    custom_entry.resource.name.must_be :nil?
    custom_entry.resource.description.must_be :nil?
    custom_entry.resource.labels.must_be_kind_of Array
    custom_entry.resource.labels.must_be :empty?
  end

  it "has the correct http_request attributes" do
    entry.http_request.method.must_equal "GET"
    entry.http_request.url.must_equal "http://test.local/foo?bar=baz"
    entry.http_request.size.must_equal "123"
    entry.http_request.status.must_equal 200
    entry.http_request.response_size.must_equal "456"
    entry.http_request.user_agent.must_equal "gcloud-ruby/1.0.0"
    entry.http_request.remote_ip.must_equal "127.0.0.1"
    entry.http_request.referer.must_equal "http://test.local/referer"
    entry.http_request.cache_hit.must_equal false
    entry.http_request.validated.must_equal false
  end

  it "has an http_request even if the Google API object doesn't have it" do
    custom_entry_hash = random_entry_hash
    custom_entry_hash.delete "httpRequest"
    custom_entry = Gcloud::Logging::Entry.from_gapi custom_entry_hash

    custom_entry.http_request.must_be_kind_of Gcloud::Logging::Entry::HttpRequest
    custom_entry.http_request.method.must_be :nil?
    custom_entry.http_request.url.must_be :nil?
    custom_entry.http_request.size.must_be :nil?
    custom_entry.http_request.status.must_be :nil?
    custom_entry.http_request.response_size.must_be :nil?
    custom_entry.http_request.user_agent.must_be :nil?
    custom_entry.http_request.remote_ip.must_be :nil?
    custom_entry.http_request.referer.must_be :nil?
    custom_entry.http_request.cache_hit.must_be :nil?
    custom_entry.http_request.validated.must_be :nil?
  end

  it "has the correct operation attributes" do
    entry.operation.id.must_equal "xyz789"
    entry.operation.producer.must_equal "MyApp.MyClass#my_method"
    entry.operation.first.must_equal false
    entry.operation.last.must_equal false
  end

  it "has an operation even if the Google API object doesn't have it" do
    custom_entry_hash = random_entry_hash
    custom_entry_hash.delete "operation"
    custom_entry = Gcloud::Logging::Entry.from_gapi custom_entry_hash

    custom_entry.operation.must_be_kind_of Gcloud::Logging::Entry::Operation
    custom_entry.operation.id.must_be :nil?
    custom_entry.operation.producer.must_be :nil?
    custom_entry.operation.first.must_be :nil?
    custom_entry.operation.last.must_be :nil?
  end
end
