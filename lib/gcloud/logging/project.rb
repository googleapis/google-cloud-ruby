# Copyright 2016 Google Inc. All rights reserved.
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


require "gcloud/gce"
require "gcloud/logging/connection"
require "gcloud/logging/credentials"
require "gcloud/logging/errors"
require "gcloud/logging/entry"
require "gcloud/logging/resource_descriptor"
require "gcloud/logging/sink"
require "gcloud/logging/metric"
require "gcloud/logging/logger"

module Gcloud
  module Logging
    ##
    # # Project
    #
    # Google Cloud Logging collects and stores logs from applications and
    # services on the Google Cloud Platform.
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   logging = gcloud.logging
    #   # ...
    #
    # See Gcloud#logging
    class Project
      ##
      # @private The Connection object.
      attr_accessor :connection

      ##
      # @private Creates a new Connection instance.
      def initialize project, credentials
        project = project.to_s # Always cast to a string
        fail ArgumentError, "project is missing" if project.empty?
        @connection = Connection.new project, credentials
      end

      # The Logging project connected to.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new "my-todo-project",
      #                       "/path/to/keyfile.json"
      #   logging = gcloud.logging
      #
      #   logging.project #=> "my-todo-project"
      #
      def project
        connection.project
      end

      ##
      # @private Default project.
      def self.default_project
        ENV["LOGGING_PROJECT"] ||
          ENV["GCLOUD_PROJECT"] ||
          ENV["GOOGLE_CLOUD_PROJECT"] ||
          Gcloud::GCE.project_id
      end

      ##
      # Lists log entries. Use this method to retrieve log entries from Cloud
      # Logging.
      #
      # @param [String, Array] projects One or more project IDs or project
      #   numbers from which to retrieve log entries.
      # @param [String] filter An [advanced logs
      #   filter](https://cloud.google.com/logging/docs/view/advanced_filters).
      #   The filter is compared against all log entries in the projects
      #   specified by projectIds. Only entries that match the filter are
      #   retrieved. An empty filter matches all log entries.
      # @param [String] order How the results should be sorted. Presently, the
      #   only permitted values are "timestamp" (default) and "timestamp desc".
      # @param [String] token A previously-returned page token representing part
      #   of the larger set of results to view.
      # @param [Integer] max Maximum number of entries to return.
      #
      # @return [Array<Gcloud::Logging::Entry>] (See
      #   {Gcloud::Logging::Entry::List})
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   entries = logging.entries
      #   entries.each do |entry|
      #     puts entry.name
      #   end
      #
      # @example With pagination: (See {Gcloud::Logging::Entry::List})
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   entries = logging.entries
      #   loop do
      #     entries.each do |entry|
      #       puts entry.name
      #     end
      #     break unless entries.next?
      #     entries = entries.next
      #   end
      #
      def entries projects: nil, filter: nil, order: nil, token: nil, max: nil
        ensure_connection!
        resp = connection.list_entries projects: projects, filter: filter,
                                       order: order, token: token, max: max
        if resp.success?
          Entry::List.from_response resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :find_entries, :entries

      ##
      # Creates an new Entry object to be populated.
      #
      # @return [Gcloud::Logging::Entry]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #
      #   new_entry = logging.entry.tap do |e|
      #     e.log_name = "syslog"
      #     e.resource.type = "cloudsql_database"
      #     e.timestamp = Time.now
      #     e.severity = "INFO"
      #     e.payload = "Export completed"
      #   end
      #
      #   logging.write_entries entry
      #
      def entry
        Entry.new
      end
      alias_method :new_entry, :entry

      ##
      # Lists log entries. Use this method to retrieve log entries from Cloud
      # Logging.
      #
      # @param [Gcloud::Logging::Entry, Array] entries One or more entry objects
      #   to write. The log entries must have values for all required fields.
      #
      # @return [Boolean] Returns `true` if the entries were written.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #
      #   new_entry = logging.entry.tap do |e|
      #     e.log_name = "syslog"
      #     e.resource.type = "cloudsql_database"
      #     e.timestamp = Time.now
      #     e.severity = "INFO"
      #     e.payload = "Export completed"
      #   end
      #
      #   logging.write_entries new_entry
      #
      # @example You can provide log name for all entries.
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #
      #   logging.write_entries [entry1, entry2], log_name: "syslog"
      #
      def write_entries entries, log_name: nil, resource: nil, labels: nil
        ensure_connection!
        resp = connection.write_entries Array(entries).map(&:to_gapi),
                                        log_name: log_name,
                                        resource: resource, labels: labels
        return true if resp.success?
        fail ApiError.from_response(resp)
      end

      ##
      # Lists log entries. Use this method to retrieve log entries from Cloud
      # Logging.
      #
      # @param [Gcloud::Logging::Entry, Array] entries One or more entry objects
      #   to write. The log entries must have values for all required fields.
      # @param [String] log_name A log resource name to be associated with the
      #   written log entries.
      # @param [Gcloud::Logging::Resource] resource The monitored resource to be
      #   associated with written log entries.
      # @param [Hash] labels A set of user-defined data to be associated with
      #   written log entries.
      #
      # @return [Gcloud::Logging::Logger] Logger object that can be used in
      #   place of a ruby standard library logger object.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #
      #   resource = logging.resource "gae_app",
      #                               module_id: "1",
      #                               version_id: "20150925t173233"
      #
      #   logger = logging.logger "syslog", resource, env: :production
      #
      def logger log_name, resource, labels = {}
        Logger.new self, log_name, resource, labels
      end

      ##
      # Deletes a log and all its log entries. The log will reappear if it
      # receives new entries.
      #
      # @param [String] name The name of the log, which may be the full path
      #   including the project ID (`projects/<project-id>/logs/<log-id>`), or
      #   just the short name (`<log-id>`), in which case the beginning of the
      #   path will be automatically prepended, using the ID of the current
      #   project.
      #
      # @return [Boolean] Returns `true` if the log and all its log entries were
      #   deleted.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   logging.delete_log "my-log"
      #
      def delete_log name
        ensure_connection!
        resp = connection.delete_log name
        if resp.success?
          true
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Retrieves the list of monitored resource descriptors that are used by
      # Google Cloud Logging.
      #
      # @param [String] token A previously-returned page token representing part
      #   of the larger set of results to view.
      # @param [Integer] max Maximum number of resource descriptors to return.
      #
      # @return [Array<Gcloud::Logging::ResourceDescriptor>] (See
      #   {Gcloud::Logging::ResourceDescriptor::List})
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   resource_descriptors = logging.resource_descriptors
      #   resource_descriptors.each do |resource_descriptor|
      #     puts resource_descriptor.name
      #   end
      #
      # @example Pagination: (See {Gcloud::Logging::ResourceDescriptor::List})
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   resource_descriptors = logging.resource_descriptors
      #   loop do
      #     resource_descriptors.each do |resource_descriptor|
      #       puts resource_descriptor.name
      #     end
      #     break unless resource_descriptors.next?
      #     resource_descriptors = resource_descriptors.next
      #   end
      #
      def resource_descriptors token: nil, max: nil
        ensure_connection!
        resp = connection.list_resource_descriptors token: token, max: max
        if resp.success?
          ResourceDescriptor::List.from_response resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :find_resource_descriptors, :resource_descriptors

      ##
      # Creates a new Resource object.
      #
      # @return [Gcloud::Logging::Resource]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #
      #   resource = logging.resource "gae_app",
      #                               "module_id" => "1",
      #                               "version_id" => "20150925t173233"
      #
      def resource type, labels = {}
        Resource.new.tap do |r|
          r.type = type
          r.labels = labels
        end
      end
      alias_method :new_resource, :resource

      ##
      # Retrieves the list of sinks belonging to the project.
      #
      # @param [String] token A previously-returned page token representing part
      #   of the larger set of results to view.
      # @param [Integer] max Maximum number of sinks to return.
      #
      # @return [Array<Gcloud::Logging::Sink>] (See
      #   {Gcloud::Logging::Sink::List})
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   sinks = logging.sinks
      #   sinks.each do |sink|
      #     puts sink.name
      #   end
      #
      # @example With pagination: (See {Gcloud::Logging::Sink::List})
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   sinks = logging.sinks
      #   loop do
      #     sinks.each do |sink|
      #       puts sink.name
      #     end
      #     break unless sinks.next?
      #     sinks = sinks.next
      #   end
      #
      def sinks token: nil, max: nil
        ensure_connection!
        resp = connection.list_sinks token: token, max: max
        if resp.success?
          Sink::List.from_response resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :find_sinks, :sinks

      ##
      # Creates a new sink.
      #
      # @param [String] name The client-assigned sink identifier. Sink
      #   identifiers are limited to 1000 characters and can include only the
      #   following characters: `A-Z`, `a-z`, `0-9`, and the special characters
      #   `_-.`.
      # @param [String] destination The export destination. See [Exporting Logs
      #   With
      #   Sinks](https://cloud.google.com/logging/docs/api/tasks/exporting-logs).
      # @param [String] filter An [advanced logs
      #  filter](https://cloud.google.com/logging/docs/view/advanced_filters)
      #  that defines the log entries to be exported. The filter must be
      #  consistent with the log entry format designed by the `version`
      #  parameter, regardless of the format of the log entry that was
      #  originally written to Cloud Logging.
      # @param [Symbol] version The log entry version used when exporting log
      #   entries from this sink. This version does not have to correspond to
      #   the version of the log entry when it was written to Cloud Logging.
      #   Accepted values are `:unspecified`, `:v2`, and `:v1`.
      #
      # @return [Gcloud::Logging::Sink]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   sink = logging.create_sink "my-sink"
      #
      def create_sink name, destination: nil, filter: nil, version: :unspecified
        version = Sink::VERSIONS[version] if Sink::VERSIONS[version]
        ensure_connection!
        resp = connection.create_sink name, destination, filter, version
        if resp.success?
          Sink.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :new_sink, :create_sink

      ##
      # Retrieves sink by name.
      #
      # @param [String] name Name of a sink.
      #
      # @return [Gcloud::Logging::Sink, nil] Returns `nil` if sink does not
      #   exist.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   sink = logging.sink "existing-sink"
      #
      # @example By default `nil` will be returned if the sink does not exist.
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   sink = logging.sink "non-existing-sink" #=> nil
      #
      def sink sink_name
        ensure_connection!
        resp = connection.get_sink sink_name
        return Sink.from_gapi(resp.data, connection) if resp.success?
        return nil if resp.status == 404
        fail ApiError.from_response(resp)
      end
      alias_method :get_sink, :sink
      alias_method :find_sink, :sink

      ##
      # Retrieves the list of metrics belonging to the project.
      #
      # @param [String] token A previously-returned page token representing part
      #   of the larger set of results to view.
      # @param [Integer] max Maximum number of metrics to return.
      #
      # @return [Array<Gcloud::Logging::Metric>] (See
      #   {Gcloud::Logging::Metric::List})
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   metrics = logging.metrics
      #   metrics.each do |metric|
      #     puts metric.name
      #   end
      #
      # @example With pagination: (See {Gcloud::Logging::Metric::List})
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   metrics = logging.metrics
      #   loop do
      #     metrics.each do |metric|
      #       puts metric.name
      #     end
      #     break unless metrics.next?
      #     metrics = metrics.next
      #   end
      #
      def metrics token: nil, max: nil
        ensure_connection!
        resp = connection.list_metrics token: token, max: max
        if resp.success?
          Metric::List.from_response resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :find_metrics, :metrics

      ##
      # Creates a new metric.
      #
      # @param [String] name The client-assigned metric identifier. Metric
      #   identifiers are limited to 1000 characters and can include only the
      #   following characters: `A-Z`, `a-z`, `0-9`, and the special characters
      #   `_-.,+!*',()%/\`. The forward-slash character (`/`) denotes a
      #   hierarchy of name pieces, and it cannot be the first character of the
      #   name.
      # @param [String] description A description of this metric, which is used
      #   in documentation.
      # @param [String] filter An [advanced logs
      #   filter](https://cloud.google.com/logging/docs/view/advanced_filters).
      #
      # @return [Gcloud::Logging::Metric]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   metric = logging.create_metric "my-metric"
      #
      def create_metric name, description: nil, filter: nil
        ensure_connection!
        resp = connection.create_metric name, description, filter
        if resp.success?
          Metric.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :new_metric, :create_metric

      ##
      # Retrieves metric by name.
      #
      # @param [String] name Name of a metric.
      #
      # @return [Gcloud::Logging::Metric, nil] Returns `nil` if metric does not
      #   exist.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   metric = logging.metric "existing-metric"
      #
      # @example By default `nil` will be returned if the metric does not exist.
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   metric = logging.metric "non-existing-metric" #=> nil
      #
      def metric name
        ensure_connection!
        resp = connection.get_metric name
        return Metric.from_gapi(resp.data, connection) if resp.success?
        return nil if resp.status == 404
        fail ApiError.from_response(resp)
      end
      alias_method :get_metric, :metric
      alias_method :find_metric, :metric

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless connection
      end
    end
  end
end
