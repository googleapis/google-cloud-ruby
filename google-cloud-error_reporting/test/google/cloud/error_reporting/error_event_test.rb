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

    error_event.timestamp.must_equal timestamp
    error_event.message.must_equal "error message"
    error_event.service_context.must_be_kind_of(
      Google::Cloud::ErrorReporting::ErrorEvent::ServiceContext
    )
    error_event.error_context.must_be_kind_of(
      Google::Cloud::ErrorReporting::ErrorEvent::ErrorContext
    )
  end

  it "has underline objects even if GRPC object doesn't have them" do
    error_event_hash.clear

    error_event.service_context.wont_be :nil?
    error_event.error_context.wont_be :nil?
    error_event.message.must_be :empty?
    error_event.timestamp.must_be :nil?

    error_event.error_context.http_request_context.wont_be :nil?
    error_event.error_context.source_location.wont_be :nil?
  end

  it "to_grpc returns a different grpc object with same attributes" do
    new_error_event_grpc = error_event.to_grpc

    new_error_event_grpc.must_equal error_event_grpc
    assert !new_error_event_grpc.equal?(error_event_grpc)
  end

  describe ".from_exception" do
    exception_message = "A serious error from application"

    before do
      @exception = StandardError.new exception_message
    end

    it "includes exception message when backtrace isn't present" do
      error_event =
        Google::Cloud::ErrorReporting::ErrorEvent.from_exception @exception
      error_event.message.must_equal exception_message
    end

    it "includes exception message and backtrace if backtrace is available" do
      backtrace = "test/test_more.rb:123:`<testee_sub>'"
      @exception.set_backtrace([backtrace])

      error_event =
        Google::Cloud::ErrorReporting::ErrorEvent.from_exception @exception
      error_event.message.must_match exception_message
      error_event.message.must_match backtrace
    end

    it "builds an error_event with current info from exception" do
      backtrace = "test/test_more.rb:123:`testee_sub'"
      @exception.set_backtrace([backtrace])

      error_event =
        Google::Cloud::ErrorReporting::ErrorEvent.from_exception @exception
      error_event.message.must_match exception_message
      error_event.error_context.source_location.file_path.must_equal(
        "test/test_more.rb"
      )
      error_event.error_context.source_location.line_number.must_equal "123"
      error_event.error_context.source_location.function_name.must_equal(
        "testee_sub"
      )
    end
  end
end
