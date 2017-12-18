# Copyright 2014 Google LLC
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


require "google/cloud/env"

module Google
  module Cloud
    module Trace
      ##
      # # Project
      #
      # Projects are top-level containers in Google Cloud Platform. They store
      # information about billing and authorized users, and they control access
      # to Stackdriver Trace resources. Each project has a friendly name and a
      # unique ID. Projects can be created only in the [Google Developers
      # Console](https://console.developers.google.com).
      #
      # This class is a client to make API calls for the project's trace data.
      # Create an instance using {Google::Cloud::Trace.new} or
      # {Google::Cloud#trace}. You may then use the `get_trace` method to
      # retrieve a trace by ID, `list_traces` to query for a set of traces,
      # and `patch_traces` to update trace data. You may also use `new_trace`
      # as a convenience constructor to build a
      # {Google::Cloud::Trace::TraceRecord} object.
      #
      # @example
      #   require "google/cloud/trace"
      #
      #   trace_client = Google::Cloud::Trace.new
      #   traces = trace_client.list_traces Time.now - 3600, Time.now
      #
      class Project
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private Creates a new Project instance.
        def initialize service
          @service = service
        end

        ##
        # The ID of the current project.
        #
        # @return [String] the Google Cloud project ID
        #
        # @example
        #   require "google/cloud/trace"
        #
        #   trace_client = Google::Cloud::Trace.new(
        #     project_id: "my-project",
        #     credentials: "/path/to/keyfile.json"
        #   )
        #
        #   trace_client.project_id #=> "my-project"
        #
        def project_id
          service.project
        end
        alias_method :project, :project_id

        ##
        # Create a new empty trace record for this project. Uses the current
        # thread's TraceContext by default; otherwise you may provide a
        # specific TraceContext.
        #
        # @param [Stackdriver::Core::TraceContext, nil] trace_context The
        #     context within which to locate this trace (i.e. sets the trace ID
        #     and the context parent span, if present.) If the context is set
        #     explicitly to `nil`, a new trace with a new trace ID is created.
        #     If no context is provided, the current thread's context is used.
        # @return [Google::Cloud::Trace::TraceRecord] The new trace.
        #
        # @example
        #   require "google/cloud/trace"
        #
        #   trace_client = Google::Cloud::Trace.new(
        #     project_id: "my-project",
        #     credentials: "/path/to/keyfile.json"
        #   )
        #
        #   trace = trace_client.new_trace
        #
        def new_trace trace_context: :DEFAULT
          if trace_context == :DEFAULT
            trace_context = Stackdriver::Core::TraceContext.get
          end
          Google::Cloud::Trace::TraceRecord.new project, trace_context
        end

        ##
        # Sends new traces to Stackdriver Trace or updates existing traces.
        # If the ID of a trace that you send matches that of an existing trace,
        # any fields in the existing trace and its spans are overwritten by the
        # provided values, and any new fields provided are merged with the
        # existing trace data. If the ID does not match, a new trace is created.
        #
        # @param [Google::Cloud::Trace::TraceRecord,
        #     Array{Google::Cloud::Trace::TraceRecord}] traces Either a single
        #     trace object or an array of trace objects.
        # @return [Array{Google::Cloud::Trace::TraceRecord}] The traces written.
        #
        # @example
        #   require "google/cloud/trace"
        #
        #   trace_client = Google::Cloud::Trace.new
        #
        #   trace = trace_client.new_trace
        #   trace.in_span "root_span" do
        #     # Do stuff...
        #   end
        #
        #   trace_client.patch_traces trace
        #
        def patch_traces traces
          ensure_service!
          service.patch_traces traces
        end

        ##
        # Gets a single trace by its ID.
        #
        # @param [String] trace_id The ID of the trace to fetch.
        # @return [Google::Cloud::Trace::TraceRecord, nil] The trace object, or
        #     `nil` if there is no accessible trace with the given ID.
        #
        # @example
        #   require "google/cloud/trace"
        #
        #   trace_client = Google::Cloud::Trace.new
        #
        #   trace = trace_client.get_trace "1234567890abcdef1234567890abcdef"
        #
        def get_trace trace_id
          ensure_service!
          service.get_trace trace_id
        end

        ##
        # Returns of a list of traces that match the specified conditions.
        # You must provide a time interval. You may optionally provide a
        # filter, an ordering, a view type.
        # Results are paginated, and you may specify a page size. The result
        # will come with a token you can pass back to retrieve the next page.
        #
        # @param [Time] start_time The start of the time interval (inclusive).
        # @param [Time] end_time The end of the time interval (inclusive).
        # @param [String] filter An optional filter.
        # @param [String] order_by The optional sort order for returned traces.
        #     May be `trace_id`, `name`, `duration`, or `start`. Any sort order
        #     may also be reversed by appending `desc`; for example use
        #     `start desc` to order traces from newest to oldest.
        # @param [Symbol] view The optional type of view. Valid values are
        #     `:MINIMAL`, `:ROOTSPAN`, and `:COMPLETE`. Default is `:MINIMAL`.
        # @param [Integer] page_size The size of each page to return. Optional;
        #     if omitted, the service will select a reasonable page size.
        # @param [String] page_token A token indicating the page to return.
        #     Each page of results includes proper token for specifying the
        #     following page.
        # @return [Google::Cloud::Trace::ResultSet] A page of results.
        #
        # @example
        #   require "google/cloud/trace"
        #
        #   trace_client = Google::Cloud::Trace.new
        #
        #   traces = trace_client.list_traces Time.now - 3600, Time.now
        #   traces.each do |trace|
        #     puts "Retrieved trace ID: #{trace.trace_id}"
        #   end
        #
        def list_traces start_time, end_time,
                        filter: nil,
                        order_by: nil,
                        view: nil,
                        page_size: nil,
                        page_token: nil
          ensure_service!
          service.list_traces project, start_time, end_time,
                              filter: filter,
                              order_by: order_by,
                              view: view,
                              page_size: page_size,
                              page_token: page_token
        end

        ##
        # @private Default project.
        def self.default_project_id
          ENV["TRACE_PROJECT"] ||
            ENV["GOOGLE_CLOUD_PROJECT"] ||
            ENV["GCLOUD_PROJECT"] ||
            Google::Cloud.env.project_id
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          fail "Must have active connection to service" unless service
        end
      end
    end
  end
end
