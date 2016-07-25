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
require "logger"

describe Google::Cloud::Logging::Logger, :add, :mock_logging do
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
  let(:severity) { :DEBUG }
  let(:write_req) do
    Google::Logging::V2::WriteLogEntriesRequest.new(
      log_name: "projects/test/logs/web_app_log",
      resource: resource.to_grpc,
      labels: labels,
      entries: [Google::Logging::V2::LogEntry.new(
        text_payload: "Danger Will Robinson!", severity: severity
      )]
    )
  end
  let(:write_res) { Google::Logging::V2::WriteLogEntriesResponse.new }

  before do
    @mock = Minitest::Mock.new
    @mock.expect :write_log_entries, write_res, [write_req]
    logging.service.mocked_logging = @mock
  end

  after do
    @mock.verify
  end

  describe :debug do
    it "creates a log entry using :debug" do
      logger.add :debug, "Danger Will Robinson!"
    end

    it "creates a log entry using 'debug'" do
      logger.add "debug", "Danger Will Robinson!"
    end

    it "creates a log entry using Logger::DEBUG" do
      logger.add ::Logger::DEBUG, "Danger Will Robinson!"
    end
  end

  describe :info do
    let(:severity) { :INFO }

    it "creates a log entry using :info" do
      logger.add :info, "Danger Will Robinson!"
    end

    it "creates a log entry using 'info'" do
      logger.add "info", "Danger Will Robinson!"
    end

    it "creates a log entry using Logger::INFO" do
      logger.add ::Logger::INFO, "Danger Will Robinson!"
    end
  end

  describe :warn do
    let(:severity) { :WARNING }

    it "creates a log entry using :warn" do
      logger.add :warn, "Danger Will Robinson!"
    end

    it "creates a log entry using 'warn'" do
      logger.add "warn", "Danger Will Robinson!"
    end

    it "creates a log entry using Logger::WARN" do
      logger.add ::Logger::WARN, "Danger Will Robinson!"
    end
  end

  describe :error do
    let(:severity) { :ERROR }

    it "creates a log entry using :error" do
      logger.add :error, "Danger Will Robinson!"
    end

    it "creates a log entry using 'error'" do
      logger.add "error", "Danger Will Robinson!"
    end

    it "creates a log entry using Logger::ERROR" do
      logger.add ::Logger::ERROR, "Danger Will Robinson!"
    end
  end

  describe :fatal do
    let(:severity) { :CRITICAL }

    it "creates a log entry using :fatal" do
      logger.add :fatal, "Danger Will Robinson!"
    end

    it "creates a log entry using 'fatal'" do
      logger.add "fatal", "Danger Will Robinson!"
    end

    it "creates a log entry using Logger::FATAL" do
      logger.add ::Logger::FATAL, "Danger Will Robinson!"
    end
  end

  describe :unknown do
    let(:severity) { :DEFAULT }

    it "creates a log entry using :unknown" do
      logger.add :unknown, "Danger Will Robinson!"
    end

    it "creates a log entry using 'unknown'" do
      logger.add "unknown", "Danger Will Robinson!"
    end

    it "creates a log entry using Logger::UNKNOWN" do
      logger.add ::Logger::UNKNOWN, "Danger Will Robinson!"
    end
  end
end
