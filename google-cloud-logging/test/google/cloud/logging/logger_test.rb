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

  def write_req_args severity, extra_labels: {}, log_name_override: nil,
                     trace: nil
    timestamp_grpc = Google::Protobuf::Timestamp.new seconds: timestamp.to_i,
                                                     nanos: timestamp.nsec
    entry = Google::Logging::V2::LogEntry.new(text_payload: "Danger Will Robinson!",
                                              severity: severity,
                                              timestamp: timestamp_grpc)
    entry.trace = trace if trace
    [
      [entry],
      log_name: "projects/test/logs/#{log_name_override || log_name}",
      resource: resource.to_grpc,
      labels: labels.merge(extra_labels),
      partial_success: nil,
      options: default_options
    ]
  end

  it "@labels instance variable is default to empty hash if not given" do
    logger = Google::Cloud::Logging::Logger.new logging, log_name, resource
    logger.labels.must_be_kind_of Hash
    logger.labels.must_be :empty?
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

  it "creates a DEFAULT log entry with #<<" do
    mock = Minitest::Mock.new
    mock.expect :write_log_entries, write_res, write_req_args(:DEFAULT)
    logging.service.mocked_logging = mock

    Time.stub :now, timestamp do
      logger << "Danger Will Robinson!"

      mock.verify
    end
  end

  it "closes and reopens the logger" do
    mock = Minitest::Mock.new
    logging.service.mocked_logging = mock

    # No mock expectation
    Time.stub :now, timestamp do
      logger.close
      logger.error "Danger Will Robinson!"
      mock.verify
    end

    mock.expect :write_log_entries, write_res, write_req_args(:ERROR)
    Time.stub :now, timestamp do
      logger.reopen
      logger.error "Danger Will Robinson!"
      mock.verify
    end
  end

  describe "#add_request_info" do
    let(:request_info) {
      Google::Cloud::Logging::Logger::RequestInfo.new "unique-identifier", nil
    }

    it "associates given info to current Thread ID" do
      logger.add_request_info info: request_info
      logger.request_info.must_equal request_info
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
          logger.add_request_info info: request_info
        end
        request_info_hash = logger.instance_variable_get :@request_info
        request_info_hash.size.must_equal 10_000
        request_info_hash[first_thread_id].must_be_nil
        request_info_hash[last_thread_id].must_equal request_info
      end
    end

    it "passes request info to log writes" do
      mock = Minitest::Mock.new
      trace_id = "my_trace_id"
      log_name = "my_app_log"
      args = write_req_args :ERROR, log_name_override: log_name,
                            extra_labels: { "traceId" => trace_id },
                            trace: "projects/#{project}/traces/#{trace_id}"
      mock.expect :write_log_entries, write_res, args
      logging.service.mocked_logging = mock

      info = Google::Cloud::Logging::Logger::RequestInfo.new trace_id, log_name
      logger.add_request_info info: info

      Time.stub :now, timestamp do
        Google::Cloud.env.stub :app_engine?, false do
          logger.error "Danger Will Robinson!"
          mock.verify
        end
      end
    end

    describe "with a custom static label" do
      let(:labels) {
        {
          "custom_label" => "just a string"
        }
      }

      let(:env) { { "HTTP_X_CUSTOM_HEADER" => "42" } }

      it "writes custom dynamic labels based on the request env" do
        mock = Minitest::Mock.new
        args = write_req_args :ERROR, extra_labels: {
                                        "custom_label" => "just a string"
                                      }

        mock.expect :write_log_entries, write_res, args
        logging.service.mocked_logging = mock

        logger.add_request_info env: env

        Time.stub :now, timestamp do
          Google::Cloud.env.stub :app_engine?, false do
            logger.error "Danger Will Robinson!"
            mock.verify
          end
        end
      end
    end

    describe "with a custom dynamic label function based on the request env" do
      let(:labels) {
        {
          "custom_header_value" => ->(env) {
            env.fetch("HTTP_X_CUSTOM_HEADER")
          }
        }
      }

      let(:env) { { "HTTP_X_CUSTOM_HEADER" => "42" } }

      it "executes the function and writes the result as a log label" do
        mock = Minitest::Mock.new
        args = write_req_args :ERROR, extra_labels: { "custom_header_value" => "42" }
        mock.expect :write_log_entries, write_res, args
        logging.service.mocked_logging = mock

        logger.add_request_info env: env

        Time.stub :now, timestamp do
          Google::Cloud.env.stub :app_engine?, false do
            logger.error "Danger Will Robinson!"
            mock.verify
          end
        end
      end
    end

    it "Also sets 'appengine.googleapis.com/trace_id' label on GAE" do
      mock = Minitest::Mock.new
      trace_id = "my_trace_id"
      log_name = "my_app_log"
      args = write_req_args :ERROR, log_name_override: log_name,
                            extra_labels: { "traceId" => trace_id,
                                            "appengine.googleapis.com/trace_id" => trace_id },
                            trace: "projects/#{project}/traces/#{trace_id}"
      mock.expect :write_log_entries, write_res, args
      logging.service.mocked_logging = mock

      info = Google::Cloud::Logging::Logger::RequestInfo.new trace_id, log_name
      logger.add_request_info info: info

      Time.stub :now, timestamp do
        Google::Cloud.env.stub :app_engine?, true do
          logger.error "Danger Will Robinson!"
          mock.verify
        end
      end
    end
  end

  it "recognizes formatter attribute even though it doesn't care" do
    logger.formatter.wont_be_nil
    formatter = ::Logger::Formatter.new
    formatter.datetime_format = "meow"
    logger.formatter = formatter
    logger.formatter.must_equal formatter
  end

  it "recognizes datetime_format attribute even though it doesn't care" do
    logger.datetime_format.must_equal ""
    logger.datetime_format = "meow"
    logger.datetime_format.must_equal "meow"
  end

  describe "log_name attribute" do
    it "is aliased as progname" do
      new_log_name = "another_web_app_log"
      logger.log_name.must_equal log_name
      logger.progname.must_equal log_name
      logger.progname = new_log_name
      logger.log_name.must_equal new_log_name
      logger.progname.must_equal new_log_name
    end

    it "is reflected in log writes" do
      mock = Minitest::Mock.new
      mock.expect :write_log_entries, write_res,
        write_req_args(:ERROR, log_name_override: "my_app_log")
      logging.service.mocked_logging = mock

      logger.progname = "my_app_log"
      Time.stub :now, timestamp do
        logger.error "Danger Will Robinson!"
        mock.verify
      end
    end
  end

  describe "level attribute" do
    it "is aliased as sev_threshold" do
      logger.level.must_equal ::Logger::DEBUG
      logger.sev_threshold.must_equal ::Logger::DEBUG
      logger.sev_threshold = ::Logger::ERROR
      logger.level.must_equal ::Logger::ERROR
      logger.sev_threshold.must_equal ::Logger::ERROR
    end

    it "controls log writes" do
      logger.level = ::Logger::ERROR
      mock = Minitest::Mock.new
      # No expectation
      logging.service.mocked_logging = mock

      Time.stub :now, timestamp do
        logger.debug "Danger Will Robinson!"
        mock.verify
      end
    end
  end

  describe "#silence" do
    it "correctly blocks out low level entries in block" do
      mocked_write_entry = Minitest::Mock.new
      mocked_write_entry.expect :call, nil, [::Logger::INFO, "Correct info message"]
      mocked_write_entry.expect :call, nil, [::Logger::FATAL, "Correct fatal message"]

      logger.level.must_equal ::Logger::DEBUG

      logger.stub :write_entry, mocked_write_entry do
        logger.info "Correct info message"
        logger.silence ::Logger::FATAL do |logger|
          logger.info "Wrong info message"
          logger.fatal "Correct fatal message"

          logger.level.must_equal ::Logger::FATAL
        end
      end

      logger.level.must_equal ::Logger::DEBUG

      mocked_write_entry.verify
    end
  end
end
