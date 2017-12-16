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
require "grpc"
require "google/cloud/trace/patches/active_call_with_trace"
require "ostruct"

class MockActiveCall
  prepend GRPC::ActiveCallWithTrace

  attr_accessor :run_batch_count

  def initialize
    @request_response_count = 0
  end

  def request_response *args
    @request_response_count += 1
    "test-response"
  end
end

describe GRPC::ActiveCallWithTrace do
  let (:active_call_with_trace) { MockActiveCall.new }

  describe "#request_response" do
    it "calls super even if a span is not set" do
      Google::Cloud::Trace.stub :get, nil do
        active_call_with_trace.request_response("test").must_equal "test-response"
      end
    end

    it "sets labels" do
      stubbed_span = OpenStruct.new labels: {}
      stubbed_span.define_singleton_method :in_span do |_, _, &b|
        b.call self
      end

      Google::Cloud::Trace.stub :get, stubbed_span do
        active_call_with_trace.request_response("test").must_equal "test-response"
      end

      stubbed_span.labels[Google::Cloud::Trace::LabelKey::RPC_REQUEST_TYPE].must_equal "String"
    end
  end
end
