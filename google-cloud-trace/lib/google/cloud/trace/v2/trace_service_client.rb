# Copyright 2018 Google LLC
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
#
# EDITING INSTRUCTIONS
# This file was generated from the file
# https://github.com/googleapis/googleapis/blob/master/google/devtools/cloudtrace/v2/tracing.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/devtools/cloudtrace/v2/tracing_pb"
require "google/cloud/trace/v2/credentials"

module Google
  module Cloud
    module Trace
      module V2
        # This file describes an API for collecting and viewing traces and spans
        # within a trace.  A Trace is a collection of spans corresponding to a single
        # operation or set of operations for an application. A span is an individual
        # timed event which forms a node of the trace tree. A single trace may
        # contain span(s) from multiple services.
        #
        # @!attribute [r] trace_service_stub
        #   @return [Google::Devtools::Cloudtrace::V2::TraceService::Stub]
        class TraceServiceClient
          # @private
          attr_reader :trace_service_stub

          # The default address of the service.
          SERVICE_ADDRESS = "cloudtrace.googleapis.com".freeze

          # The default port of the service.
          DEFAULT_SERVICE_PORT = 443

          # The default set of gRPC interceptors.
          GRPC_INTERCEPTORS = []

          DEFAULT_TIMEOUT = 30

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/trace.append"
          ].freeze


          PROJECT_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}"
          )

          private_constant :PROJECT_PATH_TEMPLATE

          SPAN_PATH_TEMPLATE = Google::Gax::PathTemplate.new(
            "projects/{project}/traces/{trace}/spans/{span}"
          )

          private_constant :SPAN_PATH_TEMPLATE

          # Returns a fully-qualified project resource name string.
          # @param project [String]
          # @return [String]
          def self.project_path project
            PROJECT_PATH_TEMPLATE.render(
              :"project" => project
            )
          end

          # Returns a fully-qualified span resource name string.
          # @param project [String]
          # @param trace [String]
          # @param span [String]
          # @return [String]
          def self.span_path project, trace, span
            SPAN_PATH_TEMPLATE.render(
              :"project" => project,
              :"trace" => trace,
              :"span" => span
            )
          end

          # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel, GRPC::Core::ChannelCredentials, Proc]
          #   Provides the means for authenticating requests made by the client. This parameter can
          #   be many types.
          #   A `Google::Auth::Credentials` uses a the properties of its represented keyfile for
          #   authenticating requests made by this client.
          #   A `String` will be treated as the path to the keyfile to be used for the construction of
          #   credentials for this client.
          #   A `Hash` will be treated as the contents of a keyfile to be used for the construction of
          #   credentials for this client.
          #   A `GRPC::Core::Channel` will be used to make calls through.
          #   A `GRPC::Core::ChannelCredentials` for the setting up the RPC client. The channel credentials
          #   should already be composed with a `GRPC::Core::CallCredentials` object.
          #   A `Proc` will be used as an updater_proc for the Grpc channel. The proc transforms the
          #   metadata for requests, generally, to give OAuth credentials.
          # @param scopes [Array<String>]
          #   The OAuth scopes for this service. This parameter is ignored if
          #   an updater_proc is supplied.
          # @param client_config [Hash]
          #   A Hash for call options for each method. See
          #   Google::Gax#construct_settings for the structure of
          #   this data. Falls back to the default config if not specified
          #   or the specified config is missing data points.
          # @param timeout [Numeric]
          #   The default timeout, in seconds, for calls made through this client.
          # @param metadata [Hash]
          #   Default metadata to be sent with each request. This can be overridden on a per call basis.
          # @param exception_transformer [Proc]
          #   An optional proc that intercepts any exceptions raised during an API call to inject
          #   custom error handling.
          def initialize \
              credentials: nil,
              scopes: ALL_SCOPES,
              client_config: {},
              timeout: DEFAULT_TIMEOUT,
              metadata: nil,
              exception_transformer: nil,
              lib_name: nil,
              lib_version: ""
            # These require statements are intentionally placed here to initialize
            # the gRPC module only when it's required.
            # See https://github.com/googleapis/toolkit/issues/446
            require "google/gax/grpc"
            require "google/devtools/cloudtrace/v2/tracing_services_pb"

            credentials ||= Google::Cloud::Trace::V2::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Trace::V2::Credentials.new(credentials).updater_proc
            end
            if credentials.is_a?(GRPC::Core::Channel)
              channel = credentials
            end
            if credentials.is_a?(GRPC::Core::ChannelCredentials)
              chan_creds = credentials
            end
            if credentials.is_a?(Proc)
              updater_proc = credentials
            end
            if credentials.is_a?(Google::Auth::Credentials)
              updater_proc = credentials.updater_proc
            end

            package_version = Gem.loaded_specs['google-cloud-trace'].version.version

            google_api_client = "gl-ruby/#{RUBY_VERSION}"
            google_api_client << " #{lib_name}/#{lib_version}" if lib_name
            google_api_client << " gapic/#{package_version} gax/#{Google::Gax::VERSION}"
            google_api_client << " grpc/#{GRPC::VERSION}"
            google_api_client.freeze

            headers = { :"x-goog-api-client" => google_api_client }
            headers.merge!(metadata) unless metadata.nil?
            client_config_file = Pathname.new(__dir__).join(
              "trace_service_client_config.json"
            )
            defaults = client_config_file.open do |f|
              Google::Gax.construct_settings(
                "google.devtools.cloudtrace.v2.TraceService",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                errors: Google::Gax::Grpc::API_ERRORS,
                metadata: headers
              )
            end

            # Allow overriding the service path/port in subclasses.
            service_path = self.class::SERVICE_ADDRESS
            port = self.class::DEFAULT_SERVICE_PORT
            interceptors = self.class::GRPC_INTERCEPTORS
            @trace_service_stub = Google::Gax::Grpc.create_stub(
              service_path,
              port,
              chan_creds: chan_creds,
              channel: channel,
              updater_proc: updater_proc,
              scopes: scopes,
              interceptors: interceptors,
              &Google::Devtools::Cloudtrace::V2::TraceService::Stub.method(:new)
            )

            @batch_write_spans = Google::Gax.create_api_call(
              @trace_service_stub.method(:batch_write_spans),
              defaults["batch_write_spans"],
              exception_transformer: exception_transformer
            )
            @create_span = Google::Gax.create_api_call(
              @trace_service_stub.method(:create_span),
              defaults["create_span"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Sends new spans to new or existing traces. You cannot update
          # existing spans.
          #
          # @param name [String]
          #   Required. The name of the project where the spans belong. The format is
          #   +projects/[PROJECT_ID]+.
          # @param spans [Array<Google::Devtools::Cloudtrace::V2::Span | Hash>]
          #   A list of new spans. The span names must not match existing
          #   spans, or the results are undefined.
          #   A hash of the same form as `Google::Devtools::Cloudtrace::V2::Span`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result []
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/trace"
          #
          #   trace_service_client = Google::Cloud::Trace.new(version: :v2)
          #   formatted_name = Google::Cloud::Trace::V2::TraceServiceClient.project_path("[PROJECT]")
          #
          #   # TODO: Initialize +spans+:
          #   spans = []
          #   trace_service_client.batch_write_spans(formatted_name, spans)

          def batch_write_spans \
              name,
              spans,
              options: nil,
              &block
            req = {
              name: name,
              spans: spans
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Devtools::Cloudtrace::V2::BatchWriteSpansRequest)
            @batch_write_spans.call(req, options, &block)
            nil
          end

          # Creates a new span.
          #
          # @param name [String]
          #   The resource name of the span in the following format:
          #
          #       projects/[PROJECT_ID]/traces/[TRACE_ID]/spans/[SPAN_ID]
          #
          #   [TRACE_ID] is a unique identifier for a trace within a project;
          #   it is a 32-character hexadecimal encoding of a 16-byte array.
          #
          #   [SPAN_ID] is a unique identifier for a span within a trace; it
          #   is a 16-character hexadecimal encoding of an 8-byte array.
          # @param span_id [String]
          #   The [SPAN_ID] portion of the span's resource name.
          # @param display_name [Google::Devtools::Cloudtrace::V2::TruncatableString | Hash]
          #   A description of the span's operation (up to 128 bytes).
          #   Stackdriver Trace displays the description in the
          #   Google Cloud Platform Console.
          #   For example, the display name can be a qualified method name or a file name
          #   and a line number where the operation is called. A best practice is to use
          #   the same display name within an application and at the same call point.
          #   This makes it easier to correlate spans in different traces.
          #   A hash of the same form as `Google::Devtools::Cloudtrace::V2::TruncatableString`
          #   can also be provided.
          # @param start_time [Google::Protobuf::Timestamp | Hash]
          #   The start time of the span. On the client side, this is the time kept by
          #   the local machine where the span execution starts. On the server side, this
          #   is the time when the server's application handler starts running.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param end_time [Google::Protobuf::Timestamp | Hash]
          #   The end time of the span. On the client side, this is the time kept by
          #   the local machine where the span execution ends. On the server side, this
          #   is the time when the server application handler stops running.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param parent_span_id [String]
          #   The [SPAN_ID] of this span's parent span. If this is a root span,
          #   then this field must be empty.
          # @param attributes [Google::Devtools::Cloudtrace::V2::Span::Attributes | Hash]
          #   A set of attributes on the span. You can have up to 32 attributes per
          #   span.
          #   A hash of the same form as `Google::Devtools::Cloudtrace::V2::Span::Attributes`
          #   can also be provided.
          # @param stack_trace [Google::Devtools::Cloudtrace::V2::StackTrace | Hash]
          #   Stack trace captured at the start of the span.
          #   A hash of the same form as `Google::Devtools::Cloudtrace::V2::StackTrace`
          #   can also be provided.
          # @param time_events [Google::Devtools::Cloudtrace::V2::Span::TimeEvents | Hash]
          #   A set of time events. You can have up to 32 annotations and 128 message
          #   events per span.
          #   A hash of the same form as `Google::Devtools::Cloudtrace::V2::Span::TimeEvents`
          #   can also be provided.
          # @param links [Google::Devtools::Cloudtrace::V2::Span::Links | Hash]
          #   Links associated with the span. You can have up to 128 links per Span.
          #   A hash of the same form as `Google::Devtools::Cloudtrace::V2::Span::Links`
          #   can also be provided.
          # @param status [Google::Rpc::Status | Hash]
          #   An optional final status for this span.
          #   A hash of the same form as `Google::Rpc::Status`
          #   can also be provided.
          # @param same_process_as_parent_span [Google::Protobuf::BoolValue | Hash]
          #   (Optional) Set this parameter to indicate whether this span is in
          #   the same process as its parent. If you do not set this parameter,
          #   Stackdriver Trace is unable to take advantage of this helpful
          #   information.
          #   A hash of the same form as `Google::Protobuf::BoolValue`
          #   can also be provided.
          # @param child_span_count [Google::Protobuf::Int32Value | Hash]
          #   An optional number of child spans that were generated while this span
          #   was active. If set, allows implementation to detect missing child spans.
          #   A hash of the same form as `Google::Protobuf::Int32Value`
          #   can also be provided.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Devtools::Cloudtrace::V2::Span]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Devtools::Cloudtrace::V2::Span]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/trace"
          #
          #   trace_service_client = Google::Cloud::Trace.new(version: :v2)
          #   formatted_name = Google::Cloud::Trace::V2::TraceServiceClient.span_path("[PROJECT]", "[TRACE]", "[SPAN]")
          #
          #   # TODO: Initialize +span_id+:
          #   span_id = ''
          #
          #   # TODO: Initialize +display_name+:
          #   display_name = {}
          #
          #   # TODO: Initialize +start_time+:
          #   start_time = {}
          #
          #   # TODO: Initialize +end_time+:
          #   end_time = {}
          #   response = trace_service_client.create_span(formatted_name, span_id, display_name, start_time, end_time)

          def create_span \
              name,
              span_id,
              display_name,
              start_time,
              end_time,
              parent_span_id: nil,
              attributes: nil,
              stack_trace: nil,
              time_events: nil,
              links: nil,
              status: nil,
              same_process_as_parent_span: nil,
              child_span_count: nil,
              options: nil,
              &block
            req = {
              name: name,
              span_id: span_id,
              display_name: display_name,
              start_time: start_time,
              end_time: end_time,
              parent_span_id: parent_span_id,
              attributes: attributes,
              stack_trace: stack_trace,
              time_events: time_events,
              links: links,
              status: status,
              same_process_as_parent_span: same_process_as_parent_span,
              child_span_count: child_span_count
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Devtools::Cloudtrace::V2::Span)
            @create_span.call(req, options, &block)
          end
        end
      end
    end
  end
end
