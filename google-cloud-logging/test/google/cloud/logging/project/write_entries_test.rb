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

describe Google::Cloud::Logging::Project, :write_entries, :mock_logging do
  it "writes a single entry" do
    entry = logging.entry.tap do |e|
      e.log_name = "projects/test/logs/testlog"
    end

    write_res = Google::Logging::V2::WriteLogEntriesResponse.new

    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, [[entry.to_grpc], log_name: nil, resource: nil, labels: nil, partial_success: nil, options: default_options]
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

    write_res = Google::Logging::V2::WriteLogEntriesResponse.new

    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, [[entry1.to_grpc, entry2.to_grpc], log_name: nil, resource: nil, labels: nil, partial_success: nil, options: default_options]
    logging.service.mocked_logging = mock

    logging.write_entries [entry1, entry2]

    mock.verify
  end

  it "writes entries with log_name" do
    entry = logging.entry.tap do |e|
      e.timestamp = Time.now
    end

    write_res = Google::Logging::V2::WriteLogEntriesResponse.new

    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, [[entry.to_grpc], log_name: "projects/test/logs/testlog", resource: nil, labels: nil, partial_success: nil, options: default_options]
    logging.service.mocked_logging = mock

    logging.write_entries entry, log_name: "testlog"

    mock.verify
  end

  it "writes entries with resource" do
    entry = logging.entry.tap do |e|
      e.timestamp = Time.now
    end
    resource = Google::Cloud::Logging::Resource.new.tap do |r|
      r.type = "web_app_server"
    end

    write_res = Google::Logging::V2::WriteLogEntriesResponse.new

    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, [[entry.to_grpc], log_name: nil, resource: resource.to_grpc, labels: nil, partial_success: nil, options: default_options]
    logging.service.mocked_logging = mock

    logging.write_entries entry, resource: resource

    mock.verify
  end

  it "writes entries with labels" do
    entry = logging.entry.tap do |e|
      e.timestamp = Time.now
    end

    write_res = Google::Logging::V2::WriteLogEntriesResponse.new

    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, [[entry.to_grpc], log_name: nil, resource: nil, labels: { "env" => "production" }, partial_success: nil, options: default_options]
    logging.service.mocked_logging = mock

    logging.write_entries entry, labels: {env: :production}

    mock.verify
  end

  it "writes entries with partial success" do
    entry = logging.entry.tap do |e|
      e.timestamp = Time.now
    end

    write_res = Google::Logging::V2::WriteLogEntriesResponse.new

    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, [[entry.to_grpc], log_name: nil, resource: nil, labels: nil, partial_success: true, options: default_options]
    logging.service.mocked_logging = mock

    logging.write_entries entry, partial_success: true

    mock.verify
  end
end
