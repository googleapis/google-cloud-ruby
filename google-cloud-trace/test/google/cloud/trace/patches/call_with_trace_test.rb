# Copyright 2017 Google LLC
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
require "grpc"
require "google/cloud/trace/patches/call_with_trace"
require "ostruct"

class MockGRPCCall
  prepend GRPC::Core::CallWithTrace

  attr_accessor :run_batch_count

  def initialize
    @run_batch_count = 0
  end

  def run_batch *args
    @run_batch_count += 1
    OpenStruct.new message: "test-grpc-response-message",
                   status: OpenStruct.new(code: 0)
  end

  def peer
    "test-host.googleapi.com"
  end
end

describe GRPC::Core::CallWithTrace do
  let (:call_with_trace) { MockGRPCCall.new }

  describe "#run_batch" do
    it "doesn't interfere orignal #run_patch if there are no parent span" do
      Google::Cloud::Trace.stub :get, nil do
        call_with_trace.run_batch
      end

      call_with_trace.run_batch_count.must_equal 1
    end

    it "calls add_request_labels with first message" do
      add_labels_called = false

      stubbed_add_labels = ->(_, message, _) do
        message.must_equal "grpc-test-message"
        add_labels_called = true
      end
      stubbed_span = OpenStruct.new(labels: {}, name: GRPC::ActiveCallWithTrace::SPAN_NAME)
      stubbed_span.define_singleton_method :in_span do |_, _, &b|
        b.call self
      end

      Google::Cloud::Trace.stub :get, stubbed_span do
        GRPC::Core::CallWithTrace.stub :add_request_labels, stubbed_add_labels do
          GRPC::Core::CallWithTrace.stub :add_response_labels, nil do
            call_with_trace.run_batch "grpc-test-message"
          end
        end
      end

      add_labels_called.must_equal true
    end

    it "addes all the labels" do
      stubbed_span = OpenStruct.new(labels: {}, name: "gRPC request")
      stubbed_span.define_singleton_method :in_span do |_, _, &b|
        b.call self
      end

      Google::Cloud::Trace.stub :get, stubbed_span do
        call_with_trace.run_batch "grpc-test-message"
      end

      label_keys = Google::Cloud::Trace::LabelKey
      stubbed_span.labels[label_keys::RPC_REQUEST_SIZE].must_equal "grpc-test-message".bytesize.to_s
      stubbed_span.labels[label_keys::RPC_HOST].must_equal "test-host.googleapi.com"
      stubbed_span.labels[label_keys::RPC_RESPONSE_SIZE].must_equal "test-grpc-response-message".bytesize.to_s
      stubbed_span.labels[label_keys::RPC_STATUS_CODE].must_equal "OK"
    end
  end

  describe ".status_code_to_label" do
    it "returns correct label" do
      GRPC::Core::CallWithTrace.status_code_to_label(0).must_equal "OK"
      GRPC::Core::CallWithTrace.status_code_to_label(7).must_equal "PERMISSION_DENIED"
    end
  end
end
