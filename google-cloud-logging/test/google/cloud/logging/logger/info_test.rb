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

describe Google::Cloud::Logging::Logger, :info, :mock_logging do
  let(:log_name) { "web_app_log" }
  let(:resource) do
    Google::Cloud::Logging::Resource.new.tap do |r|
      r.type = "gce_instance"
      r.labels["zone"] = "global"
      r.labels["instance_id"] = "abc123"
    end
  end
  let(:labels) { { "env" => "production" } }
  let(:insert_id) { "abc-123" }
  let(:logger) { Google::Cloud::Logging::Logger.new logging, log_name, resource, labels }
  let(:write_res) { Google::Cloud::Logging::V2::WriteLogEntriesResponse.new }
  let(:timestamp) { Time.parse "2016-10-02T15:01:23.045123456Z" }

  def write_req_args severity
    timestamp_grpc = Google::Protobuf::Timestamp.new seconds: timestamp.to_i,
                                                     nanos: timestamp.nsec
    entries = [Google::Cloud::Logging::V2::LogEntry.new(insert_id: insert_id,
                                                 text_payload: "Danger Will Robinson!",
                                                 severity: severity,
                                                 timestamp: timestamp_grpc)]
    {
      entries: entries,
      log_name: "projects/test/logs/web_app_log",
      resource: resource.to_grpc,
      labels: labels,
      partial_success: nil
    }
  end

  def apply_stubs
    Time.stub :now, timestamp do
      Google::Cloud::Logging::Entry.stub :insert_id, insert_id do
        yield
      end
    end
  end

  before do
    logger.level = ::Logger::INFO
  end

  it "knows its log level using helper methods" do
    _(logger).wont_be :debug?
    _(logger).must_be :info?
    _(logger).must_be :warn?
    _(logger).must_be :error?
    _(logger).must_be :fatal?
  end

  it "does not create a log entry with #debug" do
    logger.debug "Danger Will Robinson!"
  end

  it "creates a log entry with #info" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, **write_req_args(:INFO)
    logging.service.mocked_logging = mock

    apply_stubs do
      logger.info "Danger Will Robinson!"

      mock.verify
    end
  end

  it "creates a log entry with #warn" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, **write_req_args(:WARNING)
    logging.service.mocked_logging = mock

    apply_stubs do
      logger.warn "Danger Will Robinson!"

      mock.verify
    end
  end

  it "creates a log entry with #error" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, **write_req_args(:ERROR)
    logging.service.mocked_logging = mock

    apply_stubs do
      logger.error "Danger Will Robinson!"

      mock.verify
    end
  end

  it "creates a log entry with #fatal" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, **write_req_args(:CRITICAL)
    logging.service.mocked_logging = mock

    apply_stubs do
      logger.fatal "Danger Will Robinson!"

      mock.verify
    end
  end

  it "creates a log entry with #unknown" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, **write_req_args(:DEFAULT)
    logging.service.mocked_logging = mock

    apply_stubs do
      logger.unknown "Danger Will Robinson!"

      mock.verify
    end
  end

  it "does not create a log entry with #debug with a block" do
    logger.debug { "Danger Will Robinson!" }
  end

  it "creates a log entry with #info with a block" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, **write_req_args(:INFO)
    logging.service.mocked_logging = mock

    apply_stubs do
      logger.info { "Danger Will Robinson!" }

      mock.verify
    end
  end

  it "creates a log entry with #warn with a block" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, **write_req_args(:WARNING)
    logging.service.mocked_logging = mock

    apply_stubs do
      logger.warn { "Danger Will Robinson!" }

      mock.verify
    end
  end

  it "creates a log entry with #error with a block" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, **write_req_args(:ERROR)
    logging.service.mocked_logging = mock

    apply_stubs do
      logger.error { "Danger Will Robinson!" }

      mock.verify
    end
  end

  it "creates a log entry with #fatal with a block" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, **write_req_args(:CRITICAL)
    logging.service.mocked_logging = mock

    apply_stubs do
      logger.fatal { "Danger Will Robinson!" }

      mock.verify
    end
  end

  it "creates a log entry with #unknown with a block" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, **write_req_args(:DEFAULT)
    logging.service.mocked_logging = mock

    apply_stubs do
      logger.unknown { "Danger Will Robinson!" }

      mock.verify
    end
  end
end
