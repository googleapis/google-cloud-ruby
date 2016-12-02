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

describe Google::Cloud::Logging::Logger, :mock_logging do
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

  def write_req_args severity, extra_labels: {}, log_name_override: nil
    timestamp_grpc = Google::Protobuf::Timestamp.new seconds: timestamp.to_i,
                                                     nanos: timestamp.nsec
    entries = [Google::Logging::V2::LogEntry.new(text_payload: "Danger Will Robinson!",
                                                 severity: severity,
                                                 timestamp: timestamp_grpc)]
    [
      entries,
      log_name: "projects/test/logs/#{log_name_override || log_name}",
      resource: resource.to_grpc,
      labels: labels.merge(extra_labels),
      options: default_options
    ]
  end

  it "creates a DEBUG log entry with #debug" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, write_req_args(:DEBUG)
    logging.service.mocked_logging = mock

    Time.stub :now, timestamp do
      logger.debug "Danger Will Robinson!"

      mock.verify
    end
  end

  it "creates an INFO log entry with #info" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, write_req_args(:INFO)
    logging.service.mocked_logging = mock

    Time.stub :now, timestamp do
      logger.info "Danger Will Robinson!"

      mock.verify
    end
  end

  it "creates a WARNING log entry with #warn" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, write_req_args(:WARNING)
    logging.service.mocked_logging = mock

    Time.stub :now, timestamp do
      logger.warn "Danger Will Robinson!"

      mock.verify
    end
  end

  it "creates a ERROR log entry with #error" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, write_req_args(:ERROR)
    logging.service.mocked_logging = mock

    Time.stub :now, timestamp do
      logger.error "Danger Will Robinson!"

      mock.verify
    end
  end

  it "creates a CRITICAL log entry with #fatal" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, write_req_args(:CRITICAL)
    logging.service.mocked_logging = mock

    Time.stub :now, timestamp do
      logger.fatal "Danger Will Robinson!"

      mock.verify
    end
  end

  it "creates a DEFAULT log entry with #unknown" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, write_req_args(:DEFAULT)
    logging.service.mocked_logging = mock

    Time.stub :now, timestamp do
      logger.unknown "Danger Will Robinson!"

      mock.verify
    end
  end

  describe "#add_request_info" do
    let(:request_info) {
      Google::Cloud::Logging::Logger::RequestInfo.new "unique-identifier", nil
    }

    it "associates given info to current Thread ID" do
      logger.add_request_info request_info
      logger.request_info[Thread.current.object_id].must_equal request_info
    end

    it "doesn't record more than 10_000 RequestInfo records" do
      last_thread_id = first_thread_id = 1
      stubbed_thread_id = ->(){
        last_thread_id += 1
      }

      # Stubbing Thread.current breaks minitest APIs. So record result and
      # evaluate outside the block
      logger.stub :current_thread_id, stubbed_thread_id do
        10_001.times do
          logger.add_request_info request_info
        end
        logger.request_info.size.must_equal 10_000
        logger.request_info[first_thread_id].must_be_nil
        logger.request_info[last_thread_id].must_equal request_info
      end
    end

    it "passes request info to log writes" do
      mock = Minitest::Mock.new
      args = write_req_args :ERROR, log_name_override: "my_app_log",
                            extra_labels: { "traceId" => "my_trace_id" }
      mock.expect :write_log_entries, write_res, args
      logging.service.mocked_logging = mock

      info = Google::Cloud::Logging::Logger::RequestInfo.new \
        "my_trace_id", "my_app_log"
      logger.add_request_info info

      Time.stub :now, timestamp do
        logger.error "Danger Will Robinson!"
        mock.verify
      end
    end
  end
end
