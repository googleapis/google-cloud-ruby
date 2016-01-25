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

describe Gcloud::Logging::Project, :write_entries, :mock_logging do
  it "writes a single entry" do
    entry = logging.entry.tap do |e|
      e.log_name = "testlog"
    end

    mock_connection.post "/v2beta1/entries:write" do |env|
      entries_json = JSON.parse env.body
      entries_json["logName"].must_be :nil?
      entries_json["resource"].must_be :nil?
      entries_json["labels"].must_be :nil?
      entries_json["entries"].must_equal [entry.to_gapi]
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    logging.write_entries entry
  end

  it "writes multiple entries" do
    entry1 = logging.entry.tap do |e|
      e.log_name = "testlog"
    end
    entry2 = logging.entry.tap do |e|
      e.log_name = "otherlog"
    end

    mock_connection.post "/v2beta1/entries:write" do |env|
      entries_json = JSON.parse env.body
      entries_json["logName"].must_be :nil?
      entries_json["resource"].must_be :nil?
      entries_json["labels"].must_be :nil?
      entries_json["entries"].must_equal [entry1.to_gapi, entry2.to_gapi]
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    logging.write_entries [entry1, entry2]
  end

  it "writes entries with log_name" do
    entry = logging.entry.tap do |e|
      e.timestamp = Time.now
    end

    mock_connection.post "/v2beta1/entries:write" do |env|
      entries_json = JSON.parse env.body
      entries_json["logName"].must_equal "projects/test/logs/testlog"
      entries_json["resource"].must_be :nil?
      entries_json["labels"].must_be :nil?
      entries_json["entries"].must_equal [entry.to_gapi]
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    logging.write_entries entry, log_name: "testlog"
  end

  it "writes entries with resource" do
    entry = logging.entry.tap do |e|
      e.timestamp = Time.now
    end
    resource = Gcloud::Logging::Resource.new.tap do |r|
      r.type = "web_app_server"
    end

    mock_connection.post "/v2beta1/entries:write" do |env|
      entries_json = JSON.parse env.body
      entries_json["logName"].must_be :nil?
      entries_json["resource"].must_equal resource.to_gapi
      entries_json["labels"].must_be :nil?
      entries_json["entries"].must_equal [entry.to_gapi]
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    logging.write_entries entry, resource: resource
  end

  it "writes entries with labels" do
    entry = logging.entry.tap do |e|
      e.timestamp = Time.now
    end

    mock_connection.post "/v2beta1/entries:write" do |env|
      entries_json = JSON.parse env.body
      entries_json["logName"].must_be :nil?
      entries_json["resource"].must_be :nil?
      entries_json["labels"].must_equal("env" => "production")
      entries_json["entries"].must_equal [entry.to_gapi]
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    logging.write_entries entry, labels: {env: :production}
  end
end
