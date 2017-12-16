# Copyright 2014 Google LLC
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


require "google/cloud/errors"
require "google/cloud/trace/version"
require "google/cloud/trace/v1"
require "google/gax/errors"

module Google
  module Cloud
    module Trace
      ##
      # Represents the connection to Trace, and exposes the API calls.
      #
      # @private
      #
      class Service
        ##
        # @private
        attr_accessor :project

        ##
        # @private
        attr_accessor :credentials

        ##
        # @private
        attr_accessor :timeout

        ##
        # @private
        attr_accessor :client_config

        ##
        # Creates a new Service instance.
        def initialize project, credentials, timeout: nil, client_config: nil
          @project = project
          @credentials = credentials
          @timeout = timeout
          @client_config = client_config || {}
        end

        def lowlevel_client
          return mocked_lowlevel_client if mocked_lowlevel_client

          @lowlevel_client ||= \
            begin
              require "grpc"
              require "google/cloud/trace/patches/active_call_with_trace"
              require "google/cloud/trace/patches/call_with_trace"

              V1::TraceServiceClient.new(
                credentials: credentials,
                timeout: timeout,
                client_config: client_config,
                lib_name: "gccl",
                lib_version: Google::Cloud::Trace::VERSION)
            end
        end
        attr_accessor :mocked_lowlevel_client

        ##
        # Sends new traces to Stackdriver Trace or updates existing traces.
        def patch_traces traces
          traces = Array(traces)
          traces_proto = Google::Devtools::Cloudtrace::V1::Traces.new
          traces.each do |trace|
            traces_proto.traces.push trace.to_grpc
          end
          execute do
            lowlevel_client.patch_traces @project, traces_proto
          end
          traces
        end

        ##
        # Returns a trace given its ID
        def get_trace trace_id
          trace_proto = execute do
            lowlevel_client.get_trace @project, trace_id
          end
          Google::Cloud::Trace::TraceRecord.from_grpc trace_proto
        end

        ##
        # Searches for traces matching the given criteria.
        #
        # rubocop:disable Metrics/MethodLength
        def list_traces project_id, start_time, end_time,
                        filter: nil,
                        order_by: nil,
                        view: nil,
                        page_size: nil,
                        page_token: nil
          if page_token
            call_opts = Google::Gax::CallOptions.new page_token: page_token
          else
            call_opts = Google::Gax::CallOptions.new
          end
          start_proto = Google::Cloud::Trace::Utils.time_to_grpc start_time
          end_proto = Google::Cloud::Trace::Utils.time_to_grpc end_time
          paged_enum = execute do
            lowlevel_client.list_traces project_id,
                                        view: view,
                                        page_size: page_size,
                                        start_time: start_proto,
                                        end_time: end_proto,
                                        filter: filter,
                                        order_by: order_by,
                                        options: call_opts
          end
          Google::Cloud::Trace::ResultSet.from_gax_page \
            self, project_id,
            paged_enum.page, start_time, end_time,
            filter: filter,
            order_by: order_by,
            view: view,
            page_size: page_size,
            page_token: page_token
        end

        # @private
        def inspect
          "#{self.class}(#{@project})"
        end

        protected

        def execute
          yield
        rescue Google::Gax::GaxError => e
          # GaxError wraps BadStatus, but exposes it as #cause
          raise Google::Cloud::Error.from_error(e.cause)
        end
      end
    end
  end
end
