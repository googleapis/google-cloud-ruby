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


require "google-cloud-logging"
require "google/cloud/logging/project"
require "google/cloud/config"
require "google/cloud/env"
require "stackdriver/core"

module Google
  module Cloud
    ##
    # # Stackdriver Logging
    #
    # The Stackdriver Logging service collects and stores logs from applications
    # and services on the Google Cloud Platform, giving you fine-grained,
    # programmatic control over your projects' logs. You can use the Stackdriver
    # Logging API to:
    #
    # * Read and filter log entries
    # * Export your log entries to Cloud Storage, BigQuery, or Cloud Pub/Sub
    # * Create logs-based metrics for use in Cloud Monitoring
    # * Write log entries
    #
    # For general information about Stackdriver Logging, read [Stackdriver
    # Logging Documentation](https://cloud.google.com/logging/docs/).
    #
    # See {file:OVERVIEW.md Stackdriver Logging Overview}.
    #
    module Logging
      ##
      # Creates a new object for connecting to the Stackdriver Logging service.
      # Each call creates a new connection.
      #
      # For more information on connecting to Google Cloud see the
      # {file:AUTHENTICATION.md Authentication Guide}.
      #
      # @param [String] project_id Project identifier for the Stackdriver
      #   Logging service you are connecting to. If not present, the default
      #   project for the credentials is used.
      # @param [String, Hash, Google::Auth::Credentials] credentials The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Logging::Credentials})
      # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      #   See [Using OAuth 2.0 to Access Google
      #   APIs](https://developers.google.com/identity/protocols/OAuth2).
      #
      #   The default scope is:
      #
      #   * `https://www.googleapis.com/auth/logging.admin`
      #
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      # @param [String] endpoint Override of the endpoint host name. Optional.
      #   If the param is nil, uses the default endpoint.
      # @param [String] project Alias for the `project_id` argument. Deprecated.
      # @param [String] keyfile Alias for the `credentials` argument.
      #   Deprecated.
      #
      # @return [Google::Cloud::Logging::Project]
      #
      # @example
      #   require "google/cloud/logging"
      #
      #   logging = Google::Cloud::Logging.new
      #
      #   entries = logging.entries
      #   entries.each do |e|
      #     puts "[#{e.timestamp}] #{e.log_name} #{e.payload.inspect}"
      #   end
      #
      def self.new project_id: nil,
                   credentials: nil,
                   scope: nil,
                   timeout: nil,
                   endpoint: nil,
                   project: nil,
                   keyfile: nil
        project_id    ||= (project || default_project_id)
        scope         ||= configure.scope
        timeout       ||= configure.timeout
        endpoint      ||= configure.endpoint
        credentials   ||= (keyfile || default_credentials(scope: scope))

        unless credentials.is_a? Google::Auth::Credentials
          credentials = Logging::Credentials.new credentials, scope: scope
        end

        if credentials.respond_to? :project_id
          project_id ||= credentials.project_id
        end
        project_id = project_id.to_s # Always cast to a string
        raise ArgumentError, "project_id is missing" if project_id.empty?

        service = Logging::Service.new project_id, credentials, host: endpoint, timeout: timeout
        Logging::Project.new service
      end

      ##
      # Configure the Google::Cloud::Logging::Middleware when used in a
      # Rack-based application.
      #
      # The following Stackdriver Logging configuration parameters are
      # supported:
      #
      # * `project_id` - (String) Project identifier for the Stackdriver
      #   Logging service you are connecting to. (The parameter `project` is
      #   considered deprecated, but may also be used.)
      # * `credentials` - (String, Hash, Google::Auth::Credentials) The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Logging::Credentials}) (The
      #   parameter `keyfile` is considered deprecated, but may also be used.)
      # * `scope` - (String, Array<String>) The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      # * `quota_project` - (String) The project ID for a project that can be
      #   used by client libraries for quota and billing purposes.
      # * `timeout` - (Integer) Default timeout to use in requests.
      # * `endpoint` - (String) Override of the endpoint host name, or `nil`
      #   to use the default endpoint.
      # * `log_name` - (String) Name of the application log file. Default:
      #   `"ruby_app_log"`
      # * `log_name_map` - (Hash) Map specific request routes to other log.
      #   Default: `{ "/_ah/health" => "ruby_health_check_log" }`
      # * `monitored_resource.type` (String) Resource type name. See [full
      #   list](https://cloud.google.com/logging/docs/api/v2/resource-list).
      #   Self discovered on GCP.
      # * `monitored_resource.labels` -(Hash) Resource labels. See [full
      #   list](https://cloud.google.com/logging/docs/api/v2/resource-list).
      #   Self discovered on GCP.
      # * `labels` - (Hash) User defined labels. A `Hash` of label names to
      #   string label values or callables/`Proc` which are functions of the
      #   Rack environment.
      # * `set_default_logger_on_rails_init` - (Boolean) Whether Google Cloud
      #   Logging Logger should be allowed to start background threads and open
      #   gRPC connections during Rails initialization. This should only be used
      #   with a non-forking web server. Web servers such as Puma and Unicorn
      #   should not set this, and instead set the Rails logger to a Google
      #   Cloud Logging Logger object on the worker process by calling
      #   {Railtie.set_default_logger} at the appropriate time, such as a
      #   post-fork hook.
      # * `on_error` - (Proc) A Proc to be run when an error is encountered
      #   on a background thread. The Proc must take the error object as the
      #   single argument. (See {AsyncWriter.on_error}.)
      #
      # See the [Configuration
      # Guide](https://googleapis.dev/ruby/stackdriver/latest/file.INSTRUMENTATION_CONFIGURATION.html)
      # for full configuration parameters.
      #
      # @return [Google::Cloud::Config] The configuration object
      #   the Google::Cloud::Logging module uses.
      #
      def self.configure
        yield Google::Cloud.configure.logging if block_given?

        Google::Cloud.configure.logging
      end

      ##
      # @private Default project.
      def self.default_project_id
        Google::Cloud.configure.logging.project_id ||
          Google::Cloud.configure.project_id ||
          Google::Cloud.env.project_id
      end

      ##
      # @private Default credentials.
      def self.default_credentials scope: nil
        Google::Cloud.configure.logging.credentials ||
          Google::Cloud.configure.credentials ||
          Logging::Credentials.default(scope: scope)
      end
    end
  end

  # @private
  Logging = Cloud::Logging unless const_defined? :Logging
end
