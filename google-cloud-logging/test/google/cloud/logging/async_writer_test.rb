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
require "logger"

describe Google::Cloud::Logging::AsyncWriter, :mock_logging do
  let(:log_name) { "web_app_log" }
  let(:resource) do
    Google::Cloud::Logging::Resource.new.tap do |r|
      r.type = "gce_instance"
      r.labels["zone"] = "global"
      r.labels["instance_id"] = "abc123"
    end
  end
  let(:labels1) { { "env" => "production" } }
  let(:labels2) { { "env" => "staging" } }
  let(:write_res) { Google::Cloud::Logging::V2::WriteLogEntriesResponse.new }
  let(:async_writer) { Google::Cloud::Logging::AsyncWriter.new logging, partial_success: true }

  def entries payload, labels = labels1
    Array(payload).map { |str|
      logging.entry(
        insert_id: "insert_#{str}_id",
        log_name: log_name,
        resource: resource,
        severity: :INFO,
        labels: labels,
        payload: str
      )
    }
  end

  def write_req_args payload, labels = labels1
    full_log_name = "projects/test/logs/#{log_name}"
    entries = Array(payload).map do |str|
      Google::Cloud::Logging::V2::LogEntry.new(
        insert_id: "insert_#{str}_id",
        text_payload: str,
        severity: :INFO,
        resource: resource.to_grpc,
        log_name: full_log_name,
        labels: labels
      )
    end
    {
      entries: entries, log_name: nil, resource: nil, labels: nil, partial_success: true
    }
  end

  it "does not raise error on empty entries" do
    mock = Minitest::Mock.new
    logging.service.mocked_logging = mock

    async_writer.write_entries []
    status = async_writer.stop! 1
    _(status).must_equal :waited

    mock.verify
  end

  it "does not raise error if stop! called before write_entries" do
    mock = Minitest::Mock.new
    logging.service.mocked_logging = mock

    status = async_writer.stop! 1
    _(status).must_equal :new

    mock.verify
  end

  it "writes a single entry" do
    mock = Minitest::Mock.new
    logging.service.mocked_logging = mock

    mock.expect :write_log_entries, write_res, **write_req_args("payload1")

    async_writer.write_entries(
      entries("payload1"),
      log_name: log_name,
      resource: resource,
      labels: labels1
    )
    status = async_writer.stop! 1
    _(status).must_equal :waited

    mock.verify
  end

  it "combines related entries" do
    mock = Minitest::Mock.new
    logging.service.mocked_logging = mock

    mock.expect :write_log_entries, write_res, **write_req_args(["payload1", "payload2"], labels1)

    async_writer.write_entries(
      entries("payload1"),
      log_name: log_name,
      resource: resource,
      labels: labels1
    )
    async_writer.write_entries(
      entries("payload2"),
      log_name: log_name,
      resource: resource,
      labels: labels1
    )
    status = async_writer.stop! 1
    _(status).must_equal :waited

    mock.verify
  end

  it "combines unrelated entries into a single request" do
    mock = Minitest::Mock.new
    logging.service.mocked_logging = mock

    payload1_request = write_req_args(["payload1"], labels1)
    payload2_request = write_req_args("payload2", labels2)
    combined_request = payload1_request.dup.tap do |req|
      req[:entries].concat payload2_request[:entries]
    end

    mock.expect :write_log_entries, write_res, **combined_request

    async_writer.write_entries(
      entries("payload1", labels1),
      log_name: log_name,
      resource: resource,
      labels: labels1
    )
    async_writer.write_entries(
      entries("payload2", labels2),
      log_name: log_name,
      resource: resource,
      labels: labels2
    )
    async_writer.stop

    wait_result = wait_until_true {
      async_writer.instance_variable_get(:@batch).nil?
    }

    _(wait_result).must_equal :completed

    async_writer.wait! 1

    mock.verify
  end
end
