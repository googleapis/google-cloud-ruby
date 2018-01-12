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
  ##
  # Stackdriver Trace instrumentation of GRPC by patching GRPC::ActiveCall
  # class. Intercept each GRPC request and create a Trace span with basic
  # request information.
  module ActiveCallWithTrace
    SPAN_NAME = "gRPC request".freeze

    ##
    # Override GRPC::ActiveCall#request_response method. Wrap the original
    # method with a trace span that will get submitted with the overall request
    # trace span tree.
    def request_response *args
      Google::Cloud::Trace.in_span SPAN_NAME do |span|
        if span && !args.empty?
          grpc_request = args[0]
          label_key = Google::Cloud::Trace::LabelKey::RPC_REQUEST_TYPE
          span.labels[label_key] = grpc_request.class.name.gsub(/^.*::/, "")
        end

        super
      end
    end
  end

  # Patch GRPC::ActiveCall#request_response method
  ::GRPC::ActiveCall.send(:prepend, ActiveCallWithTrace)
end
