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
# https://github.com/googleapis/googleapis/blob/master/google/devtools/cloudtrace/v1/trace.proto,
# and updates to that file get reflected here through a refresh process.
# For the short term, the refresh process will only be runnable by Google
# engineers.


require "json"
require "pathname"

require "google/gax"

require "google/devtools/cloudtrace/v1/trace_pb"
require "google/cloud/trace/v1/credentials"

module Google
  module Cloud
    module Trace
      module V1
        # This file describes an API for collecting and viewing traces and spans
        # within a trace.  A Trace is a collection of spans corresponding to a single
        # operation or set of operations for an application. A span is an individual
        # timed event which forms a node of the trace tree. Spans for a single trace
        # may span multiple services.
        #
        # @!attribute [r] trace_service_stub
        #   @return [Google::Devtools::Cloudtrace::V1::TraceService::Stub]
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

          PAGE_DESCRIPTORS = {
            "list_traces" => Google::Gax::PageDescriptor.new(
              "page_token",
              "next_page_token",
              "traces")
          }.freeze

          private_constant :PAGE_DESCRIPTORS

          # The scopes needed to make gRPC calls to all of the methods defined in
          # this service.
          ALL_SCOPES = [
            "https://www.googleapis.com/auth/cloud-platform",
            "https://www.googleapis.com/auth/trace.append",
            "https://www.googleapis.com/auth/trace.readonly"
          ].freeze


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
            require "google/devtools/cloudtrace/v1/trace_services_pb"

            credentials ||= Google::Cloud::Trace::V1::Credentials.default

            if credentials.is_a?(String) || credentials.is_a?(Hash)
              updater_proc = Google::Cloud::Trace::V1::Credentials.new(credentials).updater_proc
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
                "google.devtools.cloudtrace.v1.TraceService",
                JSON.parse(f.read),
                client_config,
                Google::Gax::Grpc::STATUS_CODE_NAMES,
                timeout,
                page_descriptors: PAGE_DESCRIPTORS,
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
              &Google::Devtools::Cloudtrace::V1::TraceService::Stub.method(:new)
            )

            @patch_traces = Google::Gax.create_api_call(
              @trace_service_stub.method(:patch_traces),
              defaults["patch_traces"],
              exception_transformer: exception_transformer
            )
            @get_trace = Google::Gax.create_api_call(
              @trace_service_stub.method(:get_trace),
              defaults["get_trace"],
              exception_transformer: exception_transformer
            )
            @list_traces = Google::Gax.create_api_call(
              @trace_service_stub.method(:list_traces),
              defaults["list_traces"],
              exception_transformer: exception_transformer
            )
          end

          # Service calls

          # Sends new traces to Stackdriver Trace or updates existing traces. If the ID
          # of a trace that you send matches that of an existing trace, any fields
          # in the existing trace and its spans are overwritten by the provided values,
          # and any new fields provided are merged with the existing trace data. If the
          # ID does not match, a new trace is created.
          #
          # @param project_id [String]
          #   ID of the Cloud project where the trace data is stored.
          # @param traces [Google::Devtools::Cloudtrace::V1::Traces | Hash]
          #   The body of the message.
          #   A hash of the same form as `Google::Devtools::Cloudtrace::V1::Traces`
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
          #   trace_service_client = Google::Cloud::Trace.new(version: :v1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `traces`:
          #   traces = {}
          #   trace_service_client.patch_traces(project_id, traces)

          def patch_traces \
              project_id,
              traces,
              options: nil,
              &block
            req = {
              project_id: project_id,
              traces: traces
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Devtools::Cloudtrace::V1::PatchTracesRequest)
            @patch_traces.call(req, options, &block)
            nil
          end

          # Gets a single trace by its ID.
          #
          # @param project_id [String]
          #   ID of the Cloud project where the trace data is stored.
          # @param trace_id [String]
          #   ID of the trace to return.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Devtools::Cloudtrace::V1::Trace]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Devtools::Cloudtrace::V1::Trace]
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/trace"
          #
          #   trace_service_client = Google::Cloud::Trace.new(version: :v1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # TODO: Initialize `trace_id`:
          #   trace_id = ''
          #   response = trace_service_client.get_trace(project_id, trace_id)

          def get_trace \
              project_id,
              trace_id,
              options: nil,
              &block
            req = {
              project_id: project_id,
              trace_id: trace_id
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Devtools::Cloudtrace::V1::GetTraceRequest)
            @get_trace.call(req, options, &block)
          end

          # Returns of a list of traces that match the specified filter conditions.
          #
          # @param project_id [String]
          #   ID of the Cloud project where the trace data is stored.
          # @param view [Google::Devtools::Cloudtrace::V1::ListTracesRequest::ViewType]
          #   Type of data returned for traces in the list. Optional. Default is
          #   `MINIMAL`.
          # @param page_size [Integer]
          #   Maximum number of traces to return. If not specified or <= 0, the
          #   implementation selects a reasonable value.  The implementation may
          #   return fewer traces than the requested page size. Optional.
          # @param start_time [Google::Protobuf::Timestamp | Hash]
          #   Start of the time interval (inclusive) during which the trace data was
          #   collected from the application.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param end_time [Google::Protobuf::Timestamp | Hash]
          #   End of the time interval (inclusive) during which the trace data was
          #   collected from the application.
          #   A hash of the same form as `Google::Protobuf::Timestamp`
          #   can also be provided.
          # @param filter [String]
          #   An optional filter against labels for the request.
          #
          #   By default, searches use prefix matching. To specify exact match, prepend
          #   a plus symbol (`+`) to the search term.
          #   Multiple terms are ANDed. Syntax:
          #
          #   * `root:NAME_PREFIX` or `NAME_PREFIX`: Return traces where any root
          #     span starts with `NAME_PREFIX`.
          #   * `+root:NAME` or `+NAME`: Return traces where any root span's name is
          #     exactly `NAME`.
          #   * `span:NAME_PREFIX`: Return traces where any span starts with
          #     `NAME_PREFIX`.
          #   * `+span:NAME`: Return traces where any span's name is exactly
          #     `NAME`.
          #   * `latency:DURATION`: Return traces whose overall latency is
          #     greater or equal to than `DURATION`. Accepted units are nanoseconds
          #     (`ns`), milliseconds (`ms`), and seconds (`s`). Default is `ms`. For
          #     example, `latency:24ms` returns traces whose overall latency
          #     is greater than or equal to 24 milliseconds.
          #   * `label:LABEL_KEY`: Return all traces containing the specified
          #     label key (exact match, case-sensitive) regardless of the key:value
          #     pair's value (including empty values).
          #   * `LABEL_KEY:VALUE_PREFIX`: Return all traces containing the specified
          #     label key (exact match, case-sensitive) whose value starts with
          #     `VALUE_PREFIX`. Both a key and a value must be specified.
          #   * `+LABEL_KEY:VALUE`: Return all traces containing a key:value pair
          #     exactly matching the specified text. Both a key and a value must be
          #     specified.
          #   * `method:VALUE`: Equivalent to `/http/method:VALUE`.
          #   * `url:VALUE`: Equivalent to `/http/url:VALUE`.
          # @param order_by [String]
          #   Field used to sort the returned traces. Optional.
          #   Can be one of the following:
          #
          #   * `trace_id`
          #   * `name` (`name` field of root span in the trace)
          #   * `duration` (difference between `end_time` and `start_time` fields of
          #     the root span)
          #   * `start` (`start_time` field of the root span)
          #
          #   Descending order can be specified by appending `desc` to the sort field
          #   (for example, `name desc`).
          #
          #   Only one sort field is permitted.
          # @param options [Google::Gax::CallOptions]
          #   Overrides the default settings for this call, e.g, timeout,
          #   retries, etc.
          # @yield [result, operation] Access the result along with the RPC operation
          # @yieldparam result [Google::Gax::PagedEnumerable<Google::Devtools::Cloudtrace::V1::Trace>]
          # @yieldparam operation [GRPC::ActiveCall::Operation]
          # @return [Google::Gax::PagedEnumerable<Google::Devtools::Cloudtrace::V1::Trace>]
          #   An enumerable of Google::Devtools::Cloudtrace::V1::Trace instances.
          #   See Google::Gax::PagedEnumerable documentation for other
          #   operations such as per-page iteration or access to the response
          #   object.
          # @raise [Google::Gax::GaxError] if the RPC is aborted.
          # @example
          #   require "google/cloud/trace"
          #
          #   trace_service_client = Google::Cloud::Trace.new(version: :v1)
          #
          #   # TODO: Initialize `project_id`:
          #   project_id = ''
          #
          #   # Iterate over all results.
          #   trace_service_client.list_traces(project_id).each do |element|
          #     # Process element.
          #   end
          #
          #   # Or iterate over results one page at a time.
          #   trace_service_client.list_traces(project_id).each_page do |page|
          #     # Process each page at a time.
          #     page.each do |element|
          #       # Process element.
          #     end
          #   end

          def list_traces \
              project_id,
              view: nil,
              page_size: nil,
              start_time: nil,
              end_time: nil,
              filter: nil,
              order_by: nil,
              options: nil,
              &block
            req = {
              project_id: project_id,
              view: view,
              page_size: page_size,
              start_time: start_time,
              end_time: end_time,
              filter: filter,
              order_by: order_by
            }.delete_if { |_, v| v.nil? }
            req = Google::Gax::to_proto(req, Google::Devtools::Cloudtrace::V1::ListTracesRequest)
            @list_traces.call(req, options, &block)
          end
        end
      end
    end
  end
end
