# Copyright 2016 Google LLC
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
require "logger"

describe Google::Cloud::Logging::Logger, :debug, :mock_logging do
  let(:log_name) { "web_app_log" }
  let(:resource) do
    Google::Cloud::Logging::Resource.new.tap do |r|
      r.type = "gce_instance"
      r.labels["zone"] = "global"
      r.labels["instance_id"] = "abc123"
    end
  end
  let(:labels) { { "env" => "production" } }
  let(:logger) { Google::Cloud::Logging::Logger.new logging, log_name, resource, labels }
  let(:write_res) { Google::Logging::V2::WriteLogEntriesResponse.new }
  let(:timestamp) { Time.parse "2016-10-02T15:01:23.045123456Z" }

  def write_req_args severity
    timestamp_grpc = Google::Protobuf::Timestamp.new seconds: timestamp.to_i,
                                                     nanos: timestamp.nsec
    entries = [Google::Logging::V2::LogEntry.new(text_payload: "Danger Will Robinson!",
                                                 severity: severity,
                                                 timestamp: timestamp_grpc)]
    [entries, log_name: "projects/test/logs/web_app_log", resource: resource.to_grpc, labels: labels, partial_success: nil, options: default_options]
  end

  before do
    logger.level = ::Logger::DEBUG
  end

  it "knows its log level using helper methods" do
    logger.must_be :debug?
    logger.must_be :info?
    logger.must_be :warn?
    logger.must_be :error?
    logger.must_be :fatal?
  end

  it "creates a log entry with #debug" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, write_req_args(:DEBUG)
    logging.service.mocked_logging = mock

    Time.stub :now, timestamp do
      logger.debug "Danger Will Robinson!"

      mock.verify
    end
  end

  it "creates a log entry with #info" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, write_req_args(:INFO)
    logging.service.mocked_logging = mock

    Time.stub :now, timestamp do
      logger.info "Danger Will Robinson!"

      mock.verify
    end
  end

  it "creates a log entry with #warn" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, write_req_args(:WARNING)
    logging.service.mocked_logging = mock

    Time.stub :now, timestamp do
      logger.warn "Danger Will Robinson!"

      mock.verify
    end
  end

  it "creates a log entry with #error" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, write_req_args(:ERROR)
    logging.service.mocked_logging = mock

    Time.stub :now, timestamp do
      logger.error "Danger Will Robinson!"

      mock.verify
    end
  end

  it "creates a log entry with #fatal" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, write_req_args(:CRITICAL)
    logging.service.mocked_logging = mock

    Time.stub :now, timestamp do
      logger.fatal "Danger Will Robinson!"

      mock.verify
    end
  end

  it "creates a log entry with #unknown" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, write_req_args(:DEFAULT)
    logging.service.mocked_logging = mock

    Time.stub :now, timestamp do
      logger.unknown "Danger Will Robinson!"

      mock.verify
    end
  end

  it "creates a log entry with #debug with a block" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, write_req_args(:DEBUG)
    logging.service.mocked_logging = mock

    Time.stub :now, timestamp do
      logger.debug { "Danger Will Robinson!" }

      mock.verify
    end
  end

  it "creates a log entry with #info with a block" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, write_req_args(:INFO)
    logging.service.mocked_logging = mock

    Time.stub :now, timestamp do
      logger.info { "Danger Will Robinson!" }

      mock.verify
    end
  end

  it "creates a log entry with #warn with a block" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, write_req_args(:WARNING)
    logging.service.mocked_logging = mock

    Time.stub :now, timestamp do
      logger.warn { "Danger Will Robinson!" }

      mock.verify
    end
  end

  it "creates a log entry with #error with a block" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, write_req_args(:ERROR)
    logging.service.mocked_logging = mock

    Time.stub :now, timestamp do
      logger.error { "Danger Will Robinson!" }

      mock.verify
    end
  end

  it "creates a log entry with #fatal with a block" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, write_req_args(:CRITICAL)
    logging.service.mocked_logging = mock

    Time.stub :now, timestamp do
      logger.fatal { "Danger Will Robinson!" }

      mock.verify
    end
  end

  it "creates a log entry with #unknown with a block" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, write_req_args(:DEFAULT)
    logging.service.mocked_logging = mock

    Time.stub :now, timestamp do
      logger.unknown { "Danger Will Robinson!" }

      mock.verify
    end
  end
end
