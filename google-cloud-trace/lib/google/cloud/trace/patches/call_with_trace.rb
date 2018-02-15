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


require "google/cloud/trace"

module GRPC
  module Core
    ##
    # Stackdriver Trace instrumentation of GRPC by patching GRPC::Core::Call
    # class. Add more RPC information into the trace span created by upstream
    # patch from GRPC::ActiveCallWithTrace
    module CallWithTrace
      ##
      # @private Add request labels from the Call object and message.
      def self.add_request_labels call, message, labels
        label_keys = Google::Cloud::Trace::LabelKey

        message_size = message.to_s.bytesize.to_s

        set_label labels, label_keys::RPC_REQUEST_SIZE, message_size
        set_label labels, label_keys::RPC_HOST, call.peer.to_s
      end

      ##
      # @private Add response labels from gRPC response
      def self.add_response_labels response, labels
        label_keys = Google::Cloud::Trace::LabelKey

        response_size = response.message.to_s.bytesize.to_s
        status = status_code_to_label response.status.code

        set_label labels, label_keys::RPC_RESPONSE_SIZE, response_size
        set_label labels, label_keys::RPC_STATUS_CODE, status
      end

      ##
      # @private Helper method to set label
      def self.set_label labels, key, value
        labels[key] = value if value.is_a? ::String
      end

      ##
      # @private Reverse lookup from numeric status code to readable string.
      def self.status_code_to_label code
        @lookup ||= Hash[GRPC::Core::StatusCodes.constants.map do |c|
          [GRPC::Core::StatusCodes.const_get(c), c.to_s]
        end]

        @lookup[code]
      end

      ##
      # Override GRPC::Core::Call#run_batch method. Reuse the "gRPC request"
      # span created in ActiveCallWithTrace patch to add more information from
      # the request.
      def run_batch *args
        span = Google::Cloud::Trace.get
        # Make sure we're in a "gRPC request" span
        span = nil if span && span.name != GRPC::ActiveCallWithTrace::SPAN_NAME

        if span && !args.empty?
          message = args[0]
          CallWithTrace.add_request_labels self, message, span.labels
        end

        response = super

        CallWithTrace.add_response_labels response, span.labels if span

        response
      end
    end

    # Patch GRPC::Core::Call#run_batch method
    ::GRPC::Core::Call.send(:prepend, CallWithTrace)
  end
end
