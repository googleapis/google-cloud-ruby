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
  let(:write_res) { Google::Logging::V2::WriteLogEntriesResponse.new }
  let(:timestamp) { Time.parse "2016-10-02T15:01:23.045123456Z" }

  def write_req_args
    timestamp_grpc = Google::Protobuf::Timestamp.new seconds: timestamp.to_i,
                                                     nanos: timestamp.nsec

    entries = [Google::Logging::V2::LogEntry.new(text_payload: "Danger Will Robinson!",
                                                 severity: severity,
                                                 timestamp: timestamp_grpc)]
    [entries, log_name: "projects/test/logs/web_app_log", resource: resource.to_grpc, labels: labels, partial_success: nil, options: default_options]
  end

  before do
    @mock = Minitest::Mock.new
    @mock.expect :write_log_entries, write_res, write_req_args
    logging.service.mocked_logging = @mock
  end

  after do
    @mock.verify
  end

  describe :debug do
    it "creates a log entry using :debug" do
      Time.stub :now, timestamp do
        logger.add :debug, "Danger Will Robinson!"
      end
    end

    it "creates a log entry using 'debug'" do
      Time.stub :now, timestamp do
        logger.add "debug", "Danger Will Robinson!"
      end
    end

    it "creates a log entry using Logger::DEBUG" do
      Time.stub :now, timestamp do
        logger.add ::Logger::DEBUG, "Danger Will Robinson!"
      end
    end

    it "creates a log entry using :debug with a block" do
      Time.stub :now, timestamp do
        logger.add :debug do
          "Danger Will Robinson!"
        end
      end
    end

    it "creates a log entry using 'debug' with a block" do
      Time.stub :now, timestamp do
        logger.add "debug" do
          "Danger Will Robinson!"
        end
      end
    end

    it "creates a log entry using Logger::DEBUG with a block" do
      Time.stub :now, timestamp do
        logger.add ::Logger::DEBUG do
          "Danger Will Robinson!"
        end
      end
    end
  end

  describe :info do
    let(:severity) { :INFO }

    it "creates a log entry using :info" do
      Time.stub :now, timestamp do
        logger.add :info, "Danger Will Robinson!"
      end
    end

    it "creates a log entry using 'info'" do
      Time.stub :now, timestamp do
        logger.add "info", "Danger Will Robinson!"
      end
    end

    it "creates a log entry using Logger::INFO" do
      Time.stub :now, timestamp do
        logger.add ::Logger::INFO, "Danger Will Robinson!"
      end
    end

    it "creates a log entry using :info with a block" do
      Time.stub :now, timestamp do
        logger.add :info do
          "Danger Will Robinson!"
        end
      end
    end

    it "creates a log entry using 'info' with a block" do
      Time.stub :now, timestamp do
        logger.add "info" do
          "Danger Will Robinson!"
        end
      end
    end

    it "creates a log entry using Logger::INFO with a block" do
      Time.stub :now, timestamp do
        logger.add ::Logger::INFO do
          "Danger Will Robinson!"
        end
      end
    end
  end

  describe :warn do
    let(:severity) { :WARNING }

    it "creates a log entry using :warn" do
      Time.stub :now, timestamp do
        logger.add :warn, "Danger Will Robinson!"
      end
    end

    it "creates a log entry using 'warn'" do
      Time.stub :now, timestamp do
        logger.add "warn", "Danger Will Robinson!"
      end
    end

    it "creates a log entry using Logger::WARN" do
      Time.stub :now, timestamp do
        logger.add ::Logger::WARN, "Danger Will Robinson!"
      end
    end

    it "creates a log entry using :warn with a block" do
      Time.stub :now, timestamp do
        logger.add :warn do
          "Danger Will Robinson!"
        end
      end
    end

    it "creates a log entry using 'warn' with a block" do
      Time.stub :now, timestamp do
        logger.add "warn" do
          "Danger Will Robinson!"
        end
      end
    end

    it "creates a log entry using Logger::WARN with a block" do
      Time.stub :now, timestamp do
        logger.add ::Logger::WARN do
          "Danger Will Robinson!"
        end
      end
    end
  end

  describe :error do
    let(:severity) { :ERROR }

    it "creates a log entry using :error" do
      Time.stub :now, timestamp do
        logger.add :error, "Danger Will Robinson!"
      end
    end

    it "creates a log entry using 'error'" do
      Time.stub :now, timestamp do
        logger.add "error", "Danger Will Robinson!"
      end
    end

    it "creates a log entry using Logger::ERROR" do
      Time.stub :now, timestamp do
        logger.add ::Logger::ERROR, "Danger Will Robinson!"
      end
    end

    it "creates a log entry using :error with a block" do
      Time.stub :now, timestamp do
        logger.add :error do
          "Danger Will Robinson!"
        end
      end
    end

    it "creates a log entry using 'error' with a block" do
      Time.stub :now, timestamp do
        logger.add "error" do
          "Danger Will Robinson!"
        end
      end
    end

    it "creates a log entry using Logger::ERROR with a block" do
      Time.stub :now, timestamp do
        logger.add ::Logger::ERROR do
          "Danger Will Robinson!"
        end
      end
    end
  end

  describe :fatal do
    let(:severity) { :CRITICAL }

    it "creates a log entry using :fatal" do
      Time.stub :now, timestamp do
        logger.add :fatal, "Danger Will Robinson!"
      end
    end

    it "creates a log entry using 'fatal'" do
      Time.stub :now, timestamp do
        logger.add "fatal", "Danger Will Robinson!"
      end
    end

    it "creates a log entry using Logger::FATAL" do
      Time.stub :now, timestamp do
        logger.add ::Logger::FATAL, "Danger Will Robinson!"
      end
    end

    it "creates a log entry using :fatal with a block" do
      Time.stub :now, timestamp do
        logger.add :fatal do
          "Danger Will Robinson!"
        end
      end
    end

    it "creates a log entry using 'fatal' with a block" do
      Time.stub :now, timestamp do
        logger.add "fatal" do
          "Danger Will Robinson!"
        end
      end
    end

    it "creates a log entry using Logger::FATAL with a block" do
      Time.stub :now, timestamp do
        logger.add ::Logger::FATAL do
          "Danger Will Robinson!"
        end
      end
    end
  end

  describe :unknown do
    let(:severity) { :DEFAULT }

    it "creates a log entry using :unknown" do
      Time.stub :now, timestamp do
        logger.add :unknown, "Danger Will Robinson!"
      end
    end

    it "creates a log entry using 'unknown'" do
      Time.stub :now, timestamp do
        logger.add "unknown", "Danger Will Robinson!"
      end
    end

    it "creates a log entry using Logger::UNKNOWN" do
      Time.stub :now, timestamp do
        logger.add ::Logger::UNKNOWN, "Danger Will Robinson!"
      end
    end

    it "creates a log entry using :unknown with a block" do
      Time.stub :now, timestamp do
        logger.add :unknown do
          "Danger Will Robinson!"
        end
      end
    end

    it "creates a log entry using 'unknown' with a block" do
      Time.stub :now, timestamp do
        logger.add "unknown" do
          "Danger Will Robinson!"
        end
      end
    end

    it "creates a log entry using Logger::UNKNOWN with a block" do
      Time.stub :now, timestamp do
        logger.add ::Logger::UNKNOWN do
          "Danger Will Robinson!"
        end
      end
    end
  end
end
