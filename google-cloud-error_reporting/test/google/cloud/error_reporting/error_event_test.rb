# Copyright 2017 Google LLC
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

describe Google::Cloud::ErrorReporting::ErrorEvent, :mock_error_reporting do
  let(:error_event_hash) { random_error_event_hash }
  let(:error_event_json) { error_event_hash.to_json }
  let(:error_event_grpc) {
    Google::Devtools::Clouderrorreporting::V1beta1::ReportedErrorEvent.decode_json error_event_json
  }
  let(:error_event) {
    Google::Cloud::ErrorReporting::ErrorEvent.from_grpc error_event_grpc
  }

  it "has attributes" do
    timestamp = Time.parse "2014-10-02T15:01:23.045123456Z"

    error_event.event_time.must_equal timestamp
    error_event.message.must_equal "error message"
    error_event.service_name.must_equal "default"
    error_event.service_version.must_equal "v1"
    error_event.user.must_equal "testerson"
    error_event.http_method.must_equal "GET"
    error_event.http_url.must_equal "http://test.local/foo?bar=baz"
    error_event.http_user_agent.must_equal "google-cloud/1.0.0"
    error_event.http_referrer.must_equal "http://test/local/referrer"
    error_event.http_status.must_equal 200
    error_event.http_remote_ip.must_equal "127.0.0.1"
    error_event.file_path.must_equal "/path/to/file.txt"
    error_event.line_number.must_equal 5
    error_event.function_name.must_equal "testee"
  end

  it "works even if GRPC object doesn't have them" do
    error_event_hash.clear

    error_event.message.must_be_empty
    error_event.event_time.must_be_nil
    error_event.service_name.must_be_nil
    error_event.service_version.must_be_nil
    error_event.user.must_be_nil
    error_event.http_method.must_be_nil
    error_event.http_url.must_be_nil
    error_event.http_user_agent.must_be_nil
    error_event.http_referrer.must_be_nil
    error_event.http_status.must_be_nil
    error_event.http_remote_ip.must_be_nil
    error_event.file_path.must_be_nil
    error_event.line_number.must_be_nil
    error_event.function_name.must_be_nil
  end

  describe "#to_grpc" do
    it "to_grpc returns a different grpc object with same attributes" do
      new_error_event_grpc = error_event.to_grpc

      new_error_event_grpc.must_equal error_event_grpc
      new_error_event_grpc.object_id.wont_equal error_event_grpc.object_id
    end
  end

  describe ".from_exception" do
    exception_message = "A serious error from application"
    let(:exception) { StandardError.new exception_message }

    it "includes exception message when backtrace isn't present" do
      error_event =
        Google::Cloud::ErrorReporting::ErrorEvent.from_exception exception
      error_event.message.must_equal exception_message
    end

    it "includes exception message when backtrace is an empty array" do
      exception.set_backtrace([])
      error_event =
        Google::Cloud::ErrorReporting::ErrorEvent.from_exception exception
      error_event.message.must_match exception_message
    end

    it "includes exception message and backtrace if backtrace is available" do
      backtrace = "test/test_more.rb:123:`<testee_sub>'"
      exception.set_backtrace([backtrace])

      error_event =
        Google::Cloud::ErrorReporting::ErrorEvent.from_exception exception
      error_event.message.must_match exception_message
      error_event.message.must_match backtrace
    end

    it "builds an error_event with current info from exception" do
      backtrace = "test/test_more.rb:123:`testee_sub'"
      exception.set_backtrace([backtrace])

      error_event =
        Google::Cloud::ErrorReporting::ErrorEvent.from_exception exception
      error_event.message.must_match exception_message
      error_event.file_path.must_equal(
        "test/test_more.rb"
      )
      error_event.line_number.must_equal 123
      error_event.function_name.must_equal(
        "testee_sub"
      )
    end
  end
end
