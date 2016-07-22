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


require "gcloud/errors"
require "gcloud/gce"
require "gcloud/logging/service"
require "gcloud/logging/credentials"
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
    # Projects are top-level containers in Google Cloud Platform. They store
    # information about billing and authorized users, and they control access to
    # Stackdriver Logging resources. Each project has a friendly name and a
    # unique ID. Projects can be created only in the [Google Developers
    # Console](https://console.developers.google.com). See {Gcloud#logging}.
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   logging = gcloud.logging
    #   entries = logging.entries
    #
    # See Gcloud#logging
    class Project
      ##
      # @private The gRPC Service object.
      attr_accessor :service

      ##
      # @private Creates a new Connection instance.
      def initialize service
        @service = service
      end

      ##
      # The ID of the current project.
      #
      # @return [String] the Google Cloud project ID
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new "my-project", "/path/to/keyfile.json"
      #   logging = gcloud.logging
      #
      #   logging.project #=> "my-project"
      #
      def project
        service.project
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
      #   numbers from which to retrieve log entries. If `nil`, the ID of the
      #   receiving project instance will be used.
      # @param [String] filter An [advanced logs
      #   filter](https://cloud.google.com/logging/docs/view/advanced_filters).
      #   The filter is compared against all log entries in the projects
      #   specified by `projects`. Only entries that match the filter are
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
      #   entries.each do |e|
      #     puts "[#{e.timestamp}] #{e.log_name} #{e.payload.inspect}"
      #   end
      #
      # @example You can use a filter to narrow results to a single log.
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   entries = logging.entries filter: "log:syslog"
      #   entries.each do |e|
      #     puts "[#{e.timestamp}] #{e.payload.inspect}"
      #   end
      #
      # @example You can also order the results by timestamp.
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   entries = logging.entries order: "timestamp desc"
      #   entries.each do |e|
      #     puts "[#{e.timestamp}] #{e.log_name} #{e.payload.inspect}"
      #   end
      #
      # @example Retrieve all log entries: (See {Entry::List#all})
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   entries = logging.entries
      #
      #   entries.all do |e|
      #     puts "[#{e.timestamp}] #{e.log_name} #{e.payload.inspect}"
      #   end
      #
      def entries projects: nil, filter: nil, order: nil, token: nil, max: nil
        ensure_service!
        list_grpc = service.list_entries projects: projects, filter: filter,
                                         order: order, token: token, max: max
        Entry::List.from_grpc list_grpc, service, projects: projects, max: max,
                                                  filter: filter, order: order
      end
      alias_method :find_entries, :entries

      ##
      # Creates an new Entry instance that may be populated and written to the
      # Stackdriver Logging service. The {Entry#resource} attribute is
      # pre-populated with a new {Gcloud::Logging::Resource} instance.
      # Equivalent to calling `Gcloud::Logging::Entry.new`.
      #
      # @param [String] log_name The resource name of the log to which this log
      #   entry belongs. See also {Entry#log_name=}.
      # @param [Resource] resource The monitored resource associated with this
      #   log entry. See also {Entry#resource}.
      # @param [Time] timestamp The time the event described by the log entry
      #   occurred. If omitted, Stackdriver Logging will use the time the log
      #   entry is written. See also {Entry#timestamp}.
      # @param [Symbol] severity The severity level of the log entry. The
      #   default value is `DEFAULT`. See also {Entry#severity}.
      # @param [String] insert_id A unique ID for the log entry. If you provide
      #   this field, the logging service considers other log entries in the
      #   same log with the same ID as duplicates which can be removed. If
      #   omitted, Stackdriver Logging will generate a unique ID for this log
      #   entry. See also {Entry#insert_id}.
      # @param [Hash{Symbol,String => String}] labels A hash of user-defined
      #   `key:value` pairs that provide additional information about the log
      #   entry. See also {Entry#labels=}.
      # @param [String, Hash] payload The log entry payload, represented as
      #   either a string, a hash (JSON), or a hash (protocol buffer). See also
      #   {Entry#payload}.
      #
      # @return [Gcloud::Logging::Entry] a new Entry instance
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #
      #   entry = logging.entry severity: :INFO, payload: "Job started."
      #
      #   logging.write_entries entry
      #
      def entry log_name: nil, resource: nil, timestamp: nil, severity: nil,
                insert_id: nil, labels: nil, payload: nil
        e = Entry.new
        e.log_name = log_name if log_name
        e.resource = resource if resource
        e.timestamp = timestamp if timestamp
        e.severity = severity if severity
        e.insert_id = insert_id if insert_id
        e.labels = labels if labels
        e.payload = payload if payload
        e
      end
      alias_method :new_entry, :entry

      ##
      # Writes log entries to the Stackdriver Logging service.
      #
      # If you write a collection of log entries, you can provide the log name,
      # resource, and/or labels hash to be used for all of the entries, and omit
      # these values from the individual entries.
      #
      # @param [Gcloud::Logging::Entry, Array<Gcloud::Logging::Entry>] entries
      #   One or more entry objects to write. The log entries must have values
      #   for all required fields.
      # @param [String] log_name A default log ID for those log entries in
      #   `entries` that do not specify their own `log_name`. See also
      #   {Entry#log_name=}.
      # @param [Resource] resource A default monitored resource for those log
      #   entries in entries that do not specify their own resource. See also
      #   {Entry#resource}.
      # @param [Hash{Symbol,String => String}] labels User-defined `key:value`
      #   items that are added to the `labels` field of each log entry in
      #   `entries`, except when a log entry specifies its own `key:value` item
      #   with the same key. See also {Entry#labels=}.
      #
      # @return [Boolean] Returns `true` if the entries were written.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #
      #   entry = logging.entry payload: "Job started.", log_name: "my_app_log"
      #   entry.resource.type = "gae_app"
      #   entry.resource.labels[:module_id] = "1"
      #   entry.resource.labels[:version_id] = "20150925t173233"
      #
      #   logging.write_entries entry
      #
      # @example Optionally pass log name, resource, and labels for all entries.
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #
      #   entry1 = logging.entry payload: "Job started."
      #   entry2 = logging.entry payload: "Job completed."
      #
      #   labels = { job_size: "large", job_code: "red" }
      #   resource = logging.resource "gae_app",
      #                               "module_id" => "1",
      #                               "version_id" => "20150925t173233"
      #
      #   logging.write_entries [entry1, entry2],
      #                         log_name: "my_app_log",
      #                         resource: resource,
      #                         labels: labels
      #
      def write_entries entries, log_name: nil, resource: nil, labels: nil
        ensure_service!
        service.write_entries Array(entries).map(&:to_grpc),
                              log_name: log_name, resource: resource,
                              labels: labels
        true
      end

      ##
      # Creates a logger instance that is API-compatible with Ruby's standard
      # library [Logger](http://ruby-doc.org/stdlib/libdoc/logger/rdoc).
      #
      # @param [String] log_name A log resource name to be associated with the
      #   written log entries.
      # @param [Gcloud::Logging::Resource] resource The monitored resource to be
      #   associated with written log entries.
      # @param [Hash] labels A set of user-defined data to be associated with
      #   written log entries.
      #
      # @return [Gcloud::Logging::Logger] a Logger object that can be used in
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
      #   logger = logging.logger "my_app_log", resource, env: :production
      #   logger.info "Job started."
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
      #   logging.delete_log "my_app_log"
      #
      def delete_log name
        ensure_service!
        service.delete_log name
        true
      end

      ##
      # Retrieves the list of monitored resource descriptors that are used by
      # Stackdriver Logging.
      #
      # @see https://cloud.google.com/logging/docs/api/introduction_v2#monitored_resources
      #   Monitored Resources
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
      #   resource_descriptors.each do |rd|
      #     label_keys = rd.labels.map(&:key).join(", ")
      #     puts "#{rd.type} (#{label_keys})"
      #   end
      #
      # @example Pagination: (See {Gcloud::Logging::ResourceDescriptor::List})
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   resource_descriptors = logging.resource_descriptors
      #
      #   resource_descriptors.all do |rd|
      #     puts rd.type
      #   end
      #
      def resource_descriptors token: nil, max: nil
        ensure_service!
        list_grpc = service.list_resource_descriptors token: token, max: max
        ResourceDescriptor::List.from_grpc list_grpc, service, max
      end
      alias_method :find_resource_descriptors, :resource_descriptors

      ##
      # Creates a new monitored resource instance.
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
      #   sinks.each do |s|
      #     puts "#{s.name}: #{s.filter} -> #{s.destination}"
      #   end
      #
      # @example Retrieve all sinks: (See {Sink::List#all})
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   sinks = logging.sinks
      #
      #   sinks.all do |s|
      #     puts "#{s.name}: #{s.filter} -> #{s.destination}"
      #   end
      #
      def sinks token: nil, max: nil
        ensure_service!
        list_grpc = service.list_sinks token: token, max: max
        Sink::List.from_grpc list_grpc, service, max
      end
      alias_method :find_sinks, :sinks

      ##
      # Creates a new project sink. When you create a sink, only new log entries
      # that match the sink's filter are exported. Stackdriver Logging does not
      # send previously-ingested log entries to the sink's destination.
      #
      # Before creating the sink, ensure that you have granted
      # `cloud-logs@google.com` permission to write logs to the destination. See
      # [Permissions for writing exported
      # logs](https://cloud.google.com/logging/docs/export/configure_export#setting_product_name_short_permissions_for_writing_exported_logs).
      #
      # @see https://cloud.google.com/logging/docs/api/tasks/exporting-logs
      #   Exporting Logs With Sinks
      # @see https://cloud.google.com/logging/docs/api/introduction_v2#kinds_of_log_sinks
      #   Kinds of log sinks (API V2)
      # @see https://cloud.google.com/logging/docs/api/#sinks Sinks (API V1)
      # @see https://cloud.google.com/logging/docs/export/configure_export#setting_product_name_short_permissions_for_writing_exported_logs
      #   Permissions for writing exported logs
      #
      # @param [String] name The client-assigned sink identifier. Sink
      #   identifiers are limited to 1000 characters and can include only the
      #   following characters: `A-Z`, `a-z`, `0-9`, and the special characters
      #   `_-.`.
      # @param [String] destination The resource name of the export destination.
      #   See [About
      #   sinks](https://cloud.google.com/logging/docs/api/tasks/exporting-logs#about_sinks)
      #   for examples.
      # @param [String, nil] filter An [advanced logs
      #  filter](https://cloud.google.com/logging/docs/view/advanced_filters)
      #  that defines the log entries to be exported. The filter must be
      #  consistent with the log entry format designed by the `version`
      #  parameter, regardless of the format of the log entry that was
      #  originally written to Stackdriver Logging.
      # @param [Symbol] version The log entry version used when exporting log
      #   entries from this sink. This version does not have to correspond to
      #   the version of the log entry when it was written to Stackdriver
      #   Logging. Accepted values are `:unspecified`, `:v2`, and `:v1`. Version
      #   2 is currently the preferred format. An unspecified version format
      #   currently defaults to V2 in the service. The default value is
      #   `:unspecified`.
      #
      # @return [Gcloud::Logging::Sink] a project sink
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   storage = gcloud.storage
      #
      #   bucket = storage.create_bucket "my-logs-bucket"
      #
      #   # Grant owner permission to Stackdriver Logging service
      #   email = "cloud-logs@google.com"
      #   bucket.acl.add_owner "group-#{email}"
      #
      #   sink = logging.create_sink "my-sink",
      #                              "storage.googleapis.com/#{bucket.id}"
      #
      def create_sink name, destination, filter: nil, version: :unspecified
        version = Sink.resolve_version version
        ensure_service!
        grpc = service.create_sink name, destination, filter, version
        Sink.from_grpc grpc, service
      end
      alias_method :new_sink, :create_sink

      ##
      # Retrieves a sink by name.
      #
      # @param [String] sink_name Name of a sink.
      #
      # @return [Gcloud::Logging::Sink, nil] Returns `nil` if the sink does not
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
        ensure_service!
        grpc = service.get_sink sink_name
        Sink.from_grpc grpc, service
      rescue Gcloud::NotFoundError
        nil
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
      #   metrics.each do |m|
      #     puts "#{m.name}: #{m.filter}"
      #   end
      #
      # @example Retrieve all metrics: (See {Metric::List#all})
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   metrics = logging.metrics
      #
      #   metrics.all do |m|
      #     puts "#{m.name}: #{m.filter}"
      #   end
      #
      def metrics token: nil, max: nil
        ensure_service!
        grpc = service.list_metrics token: token, max: max
        Metric::List.from_grpc grpc, service, max
      end
      alias_method :find_metrics, :metrics

      ##
      # Creates a new logs-based metric for Google Cloud Monitoring.
      #
      # @see https://cloud.google.com/logging/docs/view/logs_based_metrics
      #   Logs-based Metrics
      # @see https://cloud.google.com/monitoring/docs Google Cloud Monitoring
      #
      # @param [String] name The client-assigned metric identifier. Metric
      #   identifiers are limited to 1000 characters and can include only the
      #   following characters: `A-Z`, `a-z`, `0-9`, and the special characters
      #   `_-.,+!*',()%/\`. The forward-slash character (`/`) denotes a
      #   hierarchy of name pieces, and it cannot be the first character of the
      #   name.
      # @param [String] filter An [advanced logs
      #   filter](https://cloud.google.com/logging/docs/view/advanced_filters).
      # @param [String, nil] description A description of this metric, which is
      #   used in documentation.
      #
      # @return [Gcloud::Logging::Metric]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   metric = logging.create_metric "errors", "severity>=ERROR"
      #
      def create_metric name, filter, description: nil
        ensure_service!
        grpc = service.create_metric name, filter, description
        Metric.from_grpc grpc, service
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
      #   metric = logging.metric "existing_metric"
      #
      # @example By default `nil` will be returned if the metric does not exist.
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   metric = logging.metric "non_existing_metric" #=> nil
      #
      def metric name
        ensure_service!
        grpc = service.get_metric name
        Metric.from_grpc grpc, service
      rescue Gcloud::NotFoundError
        nil
      end
      alias_method :get_metric, :metric
      alias_method :find_metric, :metric

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
