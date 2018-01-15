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
    # * [Read and filter log entries](#listing-log-entries)
    # * [Export your log entries](#exporting-log-entries) to Cloud Storage,
    #   BigQuery, or Cloud Pub/Sub
    # * [Create logs-based metrics](#creating-logs-based-metrics) for use in
    #   Cloud Monitoring
    # * [Write log entries](#writing-log-entries)
    #
    # For general information about Stackdriver Logging, read [Stackdriver
    # Logging Documentation](https://cloud.google.com/logging/docs/).
    #
    # The goal of google-cloud is to provide an API that is comfortable to
    # Rubyists. Your authentication credentials are detected automatically in
    # Google Cloud Platform environments such as Google Compute Engine, Google
    # App Engine and Google Kubernetes Engine. In other environments you can
    # configure authentication easily, either directly in your code or via
    # environment variables. Read more about the options for connecting in the
    # [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # If you just want to write your application's logs to the Stackdriver
    # Logging service, you may find it easiest to use the [Stackdriver Logging
    # Instrumentation](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/instrumentation)
    # or the [Ruby Logger
    # implementation](#creating-a-ruby-logger-implementation) provided by this
    # library. Otherwise, read on to learn more about the Logging API.
    #
    # ## Listing log entries
    #
    # Stackdriver Logging gathers log entries from many services, including
    # Google App Engine and Google Compute Engine. (See the [List of Log
    # Types](https://cloud.google.com/logging/docs/view/logs_index).) In
    # addition, you can write your own log entries to the service.
    #
    # {Google::Cloud::Logging::Project#entries} returns the
    # {Google::Cloud::Logging::Entry} records belonging to your project:
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    # entries = logging.entries
    # entries.each do |e|
    #   puts "[#{e.timestamp}] #{e.log_name} #{e.payload.inspect}"
    # end
    # ```
    #
    # You can narrow the results to a single log using an [advanced logs
    # filter](https://cloud.google.com/logging/docs/view/advanced_filters). A
    # log is a named collection of entries. Logs can be produced by Google Cloud
    # Platform services, by third-party services, or by your applications. For
    # example, the log `compute.googleapis.com/activity_log` is produced by
    # Google Compute Engine. Logs are simply referenced by name in google-cloud.
    # There is no `Log` type in google-cloud or `Log` resource in the
    # Stackdriver Logging API.
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    # entries = logging.entries filter: "logName:syslog"
    # entries.each do |e|
    #   puts "[#{e.timestamp}] #{e.payload.inspect}"
    # end
    # ```
    #
    # You can also order the log entries by `timestamp`.
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    # entries = logging.entries order: "timestamp desc"
    # entries.each do |e|
    #   puts "[#{e.timestamp}] #{e.log_name}"
    # end
    # ```
    #
    # ## Exporting log entries
    #
    # Stackdriver Logging lets you export log entries to destinations including
    # Google Cloud Storage buckets (for long term log storage), Google BigQuery
    # datasets (for log analysis), and Google Pub/Sub (for streaming to other
    # applications).
    #
    # ### Creating sinks
    #
    # A {Google::Cloud::Logging::Sink} is an object that lets you to specify a
    # set of log entries to export.
    #
    # In addition to the name of the sink and the export destination,
    # {Google::Cloud::Logging::Project#create_sink} accepts an [advanced logs
    # filter](https://cloud.google.com/logging/docs/view/advanced_filters) to
    # narrow the collection.
    #
    # Before creating the sink, ensure that you have granted
    # `cloud-logs@google.com` permission to write logs to the destination. See
    # [Exporting Logs
    # (V2)](https://cloud.google.com/logging/docs/export/configure_export_v2).
    #
    # ```ruby
    # require "google/cloud/storage"
    # require "google/cloud/logging"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.create_bucket "my-logs-bucket"
    #
    # # Grant owner permission to Stackdriver Logging service
    # email = "cloud-logs@google.com"
    # bucket.acl.add_owner "group-#{email}"
    #
    # logging = Google::Cloud::Logging.new
    #
    # sink = logging.create_sink "my-sink",
    #                            "storage.googleapis.com/#{bucket.id}"
    # ```
    #
    # When you create a sink, only new log entries are exported. Stackdriver
    # Logging does not send previously-ingested log entries to the sink's
    # destination.
    #
    # ### Listing sinks
    #
    # You can also list the sinks belonging to your project with
    # {Google::Cloud::Logging::Project#sinks}.
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    # sinks = logging.sinks
    # sinks.each do |s|
    #   puts "#{s.name}: #{s.filter} -> #{s.destination}"
    # end
    # ```
    #
    # ## Creating logs-based metrics
    #
    # You can use log entries in your project as the basis for [Google Cloud
    # Monitoring](https://cloud.google.com/monitoring/docs) metrics. These
    # metrics can then be used to produce Cloud Monitoring reports and alerts.
    #
    # ### Creating metrics
    #
    # A metric is a measured value that can be used to assess a system. Use
    # {Google::Cloud::Logging::Project#create_metric} to configure a
    # {Google::Cloud::Logging::Metric} based on a collection of log entries
    # matching an [advanced logs
    # filter](https://cloud.google.com/logging/docs/view/advanced_filters).
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    # metric = logging.create_metric "errors", "severity>=ERROR"
    # ```
    #
    # ### Listing metrics
    #
    # You can also list the metrics belonging to your project with
    # {Google::Cloud::Logging::Project#metrics}.
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    # metrics = logging.metrics
    # metrics.each do |m|
    #   puts "#{m.name}: #{m.filter}"
    # end
    # ```
    #
    # ## Writing log entries
    #
    # An {Google::Cloud::Logging::Entry} is composed of metadata and a payload.
    # The payload is traditionally a message string, but in Stackdriver Logging
    # it can also be a JSON or protocol buffer object. A single log can have
    # entries with different payload types. In addition to the payload, your
    # argument(s) to {Google::Cloud::Logging::Project#write_entries} must also
    # contain a log name and a resource.
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    #
    # entry = logging.entry
    # entry.payload = "Job started."
    # entry.log_name = "my_app_log"
    # entry.resource.type = "gae_app"
    # entry.resource.labels[:module_id] = "1"
    # entry.resource.labels[:version_id] = "20150925t173233"
    #
    # logging.write_entries entry
    # ```
    #
    # To write a JSON payload to the log, simply pass a hash argument:
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    #
    # entry = logging.entry
    # entry.payload = { "stats" => { "a" => 8, "b" => 12.5} }
    # entry.log_name = "my_app_log"
    # entry.resource.type = "gae_app"
    # entry.resource.labels[:module_id] = "1"
    # entry.resource.labels[:version_id] = "20150925t173233"
    #
    # logging.write_entries entry
    # ```
    #
    # If you write a collection of log entries, you can provide the log name,
    # resource, and/or labels hash to be used for all of the entries, and omit
    # these values from the individual entries.
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    #
    # entry1 = logging.entry
    # entry1.payload = "Job started."
    # entry2 = logging.entry
    # entry2.payload = "Job completed."
    # labels = { job_size: "large", job_code: "red" }
    #
    # resource = logging.resource "gae_app",
    #                             "module_id" => "1",
    #                             "version_id" => "20150925t173233"
    #
    # logging.write_entries [entry1, entry2],
    #                       log_name: "my_app_log",
    #                       resource: resource,
    #                       labels: labels
    # ```
    #
    # Normally, writing log entries is done synchronously; the call to
    # {Google::Cloud::Logging::Project#write_entries} will block until it has
    # either completed transmitting the data or encountered an error. To "fire
    # and forget" without blocking, use {Google::Cloud::Logging::AsyncWriter};
    # it spins up a background thread that writes log entries in batches. Calls
    # to {Google::Cloud::Logging::AsyncWriter#write_entries} simply add entries
    # to its work queue and return immediately.
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    # async = logging.async_writer
    #
    # entry1 = logging.entry
    # entry1.payload = "Job started."
    # entry2 = logging.entry
    # entry2.payload = "Job completed."
    # labels = { job_size: "large", job_code: "red" }
    #
    # resource = logging.resource "gae_app",
    #                             "module_id" => "1",
    #                             "version_id" => "20150925t173233"
    #
    # async.write_entries [entry1, entry2],
    #                     log_name: "my_app_log",
    #                     resource: resource,
    #                     labels: labels,
    #                     partial_success: true
    # ```
    #
    # ### Creating a Ruby Logger implementation
    #
    # If your environment requires a logger instance that is API-compatible with
    # Ruby's standard library
    # [Logger](http://ruby-doc.org/stdlib/libdoc/logger/rdoc), you can use
    # {Google::Cloud::Logging::Project#logger} to create one.
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    #
    # resource = logging.resource "gae_app",
    #                             module_id: "1",
    #                             version_id: "20150925t173233"
    #
    # logger = logging.logger "my_app_log", resource, env: :production
    # logger.info "Job started."
    # ```
    #
    # By default, the logger instance writes log entries asynchronously in a
    # background thread using an {Google::Cloud::Logging::AsyncWriter}. If you
    # want to customize or disable asynchronous writing, you may call the
    # Logger constructor directly.
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new
    #
    # resource = logging.resource "gae_app",
    #                             module_id: "1",
    #                             version_id: "20150925t173233"
    #
    # logger = Google::Cloud::Logging::Logger.new logging,
    #                                             "my_app_log",
    #                                             resource,
    #                                             {env: :production}
    # logger.info "Log entry written synchronously."
    # ```
    #
    # ## Configuring timeout
    #
    # You can configure the request `timeout` value in seconds.
    #
    # ```ruby
    # require "google/cloud/logging"
    #
    # logging = Google::Cloud::Logging.new timeout: 120
    # ```
    #
    module Logging
      ##
      # Creates a new object for connecting to the Stackdriver Logging service.
      # Each call creates a new connection.
      #
      # For more information on connecting to Google Cloud see the
      # [Authentication
      # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
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
      # @param [Hash] client_config A hash of values to override the default
      #   behavior of the API client. Optional.
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
          credentials = Logging::Credentials.new credentials, scope: scope
        end

        Logging::Project.new(
          Logging::Service.new(
            project_id, credentials, timeout: timeout,
                                     client_config: client_config
          )
        )
      end

      ##
      # Reload logging configuration from defaults. For testing.
      # @private
      #
      def self.reload_configuration!
        default_creds = Google::Cloud.credentials_from_env(
          "LOGGING_CREDENTIALS", "LOGGING_CREDENTIALS_JSON",
          "LOGGING_KEYFILE", "LOGGING_KEYFILE_JSON"
        )

        Google::Cloud.configure.delete! :logging
        Google::Cloud.configure.add_config! :logging do |config|
          config.add_field! :project_id, ENV["LOGGING_PROJECT"], match: String
          config.add_alias! :project, :project_id
          config.add_field! :credentials, default_creds,
                            match: [String, Hash, Google::Auth::Credentials]
          config.add_alias! :keyfile, :credentials
          config.add_field! :scope, nil, match: [String, Array]
          config.add_field! :timeout, nil, match: Integer
          config.add_field! :client_config, nil, match: Hash
          config.add_field! :log_name, nil, match: String
          config.add_field! :log_name_map, nil, match: Hash
          config.add_field! :labels, nil, match: Hash
          config.add_config! :monitored_resource do |mrconfig|
            mrconfig.add_field! :type, nil, match: String
            mrconfig.add_field! :labels, nil, match: Hash
          end
        end
      end

      reload_configuration! unless Google::Cloud.configure.subconfig? :logging

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
      # * `timeout` - (Integer) Default timeout to use in requests.
      # * `client_config` - (Hash) A hash of values to override the default
      #   behavior of the API client.
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
      #
      # See the [Configuration
      # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/stackdriver/guides/instrumentation_configuration)
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
end
