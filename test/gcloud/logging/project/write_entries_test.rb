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
      e.log_name = "projects/test/logs/testlog"
    end

    write_req = Google::Logging::V2::WriteLogEntriesRequest.new(
      entries: [entry.to_grpc]
    )
    write_res = Google::Logging::V2::WriteLogEntriesResponse.new

    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, [write_req]
    logging.service.mocked_logging = mock

    logging.write_entries entry

    mock.verify
  end

  it "writes multiple entries" do
    entry1 = logging.entry.tap do |e|
      e.log_name = "projects/test/logs/testlog"
    end
    entry2 = logging.entry.tap do |e|
      e.log_name = "projects/test/logs/otherlog"
    end

    write_req = Google::Logging::V2::WriteLogEntriesRequest.new(
      entries: [entry1.to_grpc, entry2.to_grpc]
    )
    write_res = Google::Logging::V2::WriteLogEntriesResponse.new

    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, [write_req]
    logging.service.mocked_logging = mock

    logging.write_entries [entry1, entry2]

    mock.verify
  end

  it "writes entries with log_name" do
    entry = logging.entry.tap do |e|
      e.timestamp = Time.now
    end

    write_req = Google::Logging::V2::WriteLogEntriesRequest.new(
      entries: [entry.to_grpc],
      log_name: "projects/test/logs/testlog"
    )
    write_res = Google::Logging::V2::WriteLogEntriesResponse.new

    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, [write_req]
    logging.service.mocked_logging = mock

    logging.write_entries entry, log_name: "testlog"

    mock.verify
  end

  it "writes entries with resource" do
    entry = logging.entry.tap do |e|
      e.timestamp = Time.now
    end
    resource = Gcloud::Logging::Resource.new.tap do |r|
      r.type = "web_app_server"
    end

    write_req = Google::Logging::V2::WriteLogEntriesRequest.new(
      entries: [entry.to_grpc],
      resource: resource.to_grpc
    )
    write_res = Google::Logging::V2::WriteLogEntriesResponse.new

    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, [write_req]
    logging.service.mocked_logging = mock

    logging.write_entries entry, resource: resource

    mock.verify
  end

  it "writes entries with labels" do
    entry = logging.entry.tap do |e|
      e.timestamp = Time.now
    end

    write_req = Google::Logging::V2::WriteLogEntriesRequest.new(
      entries: [entry.to_grpc],
      labels: { "env" => "production" }
    )
    write_res = Google::Logging::V2::WriteLogEntriesResponse.new

    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, [write_req]
    logging.service.mocked_logging = mock

    logging.write_entries entry, labels: {env: :production}

    mock.verify
  end
end
