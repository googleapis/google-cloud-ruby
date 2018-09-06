# Copyright 2016 Google LLC
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


require "google-cloud-trace"
require "google/cloud/trace/version"
require "google/cloud/trace/credentials"
require "google/cloud/trace/label_key"
require "google/cloud/trace/middleware"
require "google/cloud/trace/notifications"
require "google/cloud/trace/project"
require "google/cloud/trace/result_set"
require "google/cloud/trace/service"
require "google/cloud/trace/span"
require "google/cloud/trace/span_kind"
require "google/cloud/trace/time_sampler"
require "google/cloud/trace/trace_record"
require "google/cloud/trace/utils"
require "google/cloud/config"
require "google/cloud/env"
require "stackdriver/core"

module Google
  module Cloud
    ##
    # # Stackdriver Trace
    #
    # The Stackdriver Trace service collects and stores latency data from your
    # application and displays it in the Google Cloud Platform Console, giving
    # you detailed near-real-time insight into application performance.
    #
    # See {file:OVERVIEW.md Stackdriver Trace Overview}.
    #
    module Trace
      THREAD_KEY = :__stackdriver_trace_span__

      ##
      # Creates a new object for connecting to the Stackdriver Trace service.
      # Each call creates a new connection.
      #
      # For more information on connecting to Google Cloud see the
      # {file:AUTHENTICATION.md Authentication Guide}.
      #
      # @param [String] project_id Project identifier for the Stackdriver Trace
      #   service you are connecting to. If not present, the default project for
      #   the credentials is used.
      # @param [String, Hash, Google::Auth::Credentials] credentials The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Trace::Credentials})
      # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      #   See [Using OAuth 2.0 to Access Google
      #   APIs](https://developers.google.com/identity/protocols/OAuth2).
      #
      #   The default scope is:
      #
      #   * `https://www.googleapis.com/auth/cloud-platform`
      #
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      # @param [String] project Alias for the `project_id` argument. Deprecated.
      # @param [String] keyfile Alias for the `credentials` argument.
      #   Deprecated.
      #
      # @return [Google::Cloud::Trace::Project]
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
      def self.new project_id: nil, credentials: nil, scope: nil, timeout: nil,
                   client_config: nil, project: nil, keyfile: nil
        project_id ||= (project || default_project_id)
        project_id = project_id.to_s # Always cast to a string
        raise ArgumentError, "project_id is missing" if project_id.empty?

        scope ||= configure.scope
        timeout ||= configure.timeout
        client_config ||= configure.client_config

        credentials ||= (keyfile || default_credentials(scope: scope))
        unless credentials.is_a? Google::Auth::Credentials
          credentials = Trace::Credentials.new credentials, scope: scope
        end

        Trace::Project.new(
          Trace::Service.new(
            project_id, credentials, timeout: timeout,
                                     client_config: client_config
          )
        )
      end

      ##
      # Configure the Stackdriver Trace instrumentation Middleware.
      #
      # The following Stackdriver Trace configuration parameters are
      # supported:
      #
      # * `project_id` - (String) Project identifier for the Stackdriver
      #   Trace service you are connecting to. (The parameter `project` is
      #   considered deprecated, but may also be used.)
      # * `credentials` - (String, Hash, Google::Auth::Credentials) The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Trace::Credentials}) (The
      #   parameter `keyfile` is considered deprecated, but may also be used.)
      # * `scope` - (String, Array<String>) The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      # * `timeout` - (Integer) Default timeout to use in requests.
      # * `client_config` - (Hash) A hash of values to override the default
      #   behavior of the API client.
      # * `capture_stack` - (Boolean) Whether to capture stack traces for each
      #   span. Default: `false`
      # * `sampler` - (Proc) A sampler Proc makes the decision whether to record
      #   a trace for each request. Default: `Google::Cloud::Trace::TimeSampler`
      # * `span_id_generator` - (Proc) A generator Proc that generates the name
      #   String for new TraceRecord. Default: `random numbers`
      # * `notifications` - (Array) An array of ActiveSupport notification types
      #   to include in traces. Rails-only option. Default:
      #   `Google::Cloud::Trace::Railtie::DEFAULT_NOTIFICATIONS`
      # * `max_data_length` - (Integer) The maximum length of span properties
      #   recorded with ActiveSupport notification events. Rails-only option.
      #   Default:
      #   `Google::Cloud::Trace::Notifications::DEFAULT_MAX_DATA_LENGTH`
      #
      # See the {file:INSTRUMENTATION.md Configuration Guide} for full
      # configuration parameters.
      #
      # @return [Google::Cloud::Config] The configuration object
      #   the Google::Cloud::Trace module uses.
      #
      def self.configure
        yield Google::Cloud.configure.trace if block_given?

        Google::Cloud.configure.trace
      end

      ##
      # @private Default project.
      def self.default_project_id
        Google::Cloud.configure.trace.project_id ||
          Google::Cloud.configure.project_id ||
          Google::Cloud.env.project_id
      end

      ##
      # @private Default credentials.
      def self.default_credentials scope: nil
        Google::Cloud.configure.trace.credentials ||
          Google::Cloud.configure.credentials ||
          Trace::Credentials.default(scope: scope)
      end

      ##
      # Set the current trace span being measured for the current thread, or
      # the current trace if no span is currently open. This may be used with
      # web frameworks that assign a thread to each request, to track the
      # trace instrumentation state for the request being handled. You may use
      # {Google::Cloud::Trace.get} to retrieve the data.
      #
      # @param [Google::Cloud::Trace::TraceSpan,
      #     Google::Cloud::Trace::TraceRecord, nil] trace The current span
      #     being measured, the current trace object, or `nil` if none.
      #
      # @example
      #   require "google/cloud/trace"
      #
      #   trace_client = Google::Cloud::Trace.new
      #   trace = trace_client.new_trace
      #   Google::Cloud::Trace.set trace
      #
      #   # Later...
      #   Google::Cloud::Trace.get.create_span "my_span"
      #
      def self.set trace
        trace_context = trace ? trace.trace_context : nil
        Stackdriver::Core::TraceContext.set trace_context
        Thread.current[THREAD_KEY] = trace
      end

      ##
      # Retrieve the current trace span or trace object for the current thread.
      # This data should previously have been set using
      # {Google::Cloud::Trace.set}.
      #
      # @return [Google::Cloud::Trace::TraceSpan,
      #     Google::Cloud::Trace::TraceRecord, nil] The span or trace object,
      #     or `nil`.
      #
      # @example
      #   require "google/cloud/trace"
      #
      #   trace_client = Google::Cloud::Trace.new
      #   trace = trace_client.new_trace
      #   Google::Cloud::Trace.set trace
      #
      #   # Later...
      #   Google::Cloud::Trace.get.create_span "my_span"
      #
      def self.get
        Thread.current[THREAD_KEY]
      end

      ##
      # Open a new span for the current thread, instrumenting the given block.
      # The span is created within the current thread's trace context as set by
      # {Google::Cloud::Trace.set}. The context is updated so any further calls
      # within the block will create subspans. The new span is also yielded to
      # the block.
      #
      # Does nothing if there is no trace context for the current thread.
      #
      # @param [String] name Name of the span to create
      # @param [Google::Cloud::Trace::SpanKind] kind Kind of span to create.
      #     Optional.
      # @param [Hash{String => String}] labels Labels for the span
      #
      # @example
      #   require "google/cloud/trace"
      #
      #   trace_client = Google::Cloud::Trace.new
      #   trace = trace_client.new_trace
      #   Google::Cloud::Trace.set trace
      #
      #   Google::Cloud::Trace.in_span "my_span" do |span|
      #     span.labels["foo"] = "bar"
      #     # Do stuff...
      #
      #     Google::Cloud::Trace.in_span "my_subspan" do |subspan|
      #       subspan.labels["foo"] = "sub-bar"
      #       # Do other stuff...
      #     end
      #   end
      #
      def self.in_span name, kind: Google::Cloud::Trace::SpanKind::UNSPECIFIED,
                       labels: {}
        parent = get
        if parent
          parent.in_span name, kind: kind, labels: labels do |child|
            set child
            begin
              yield child
            ensure
              set parent
            end
          end
        else
          yield nil
        end
      end
    end
  end
end
