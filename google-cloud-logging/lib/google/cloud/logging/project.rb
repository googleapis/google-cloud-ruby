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


require "google/cloud/errors"
require "google/cloud/logging/service"
require "google/cloud/logging/credentials"
require "google/cloud/logging/log/list"
require "google/cloud/logging/entry"
require "google/cloud/logging/resource_descriptor"
require "google/cloud/logging/sink"
require "google/cloud/logging/metric"
require "google/cloud/logging/async_writer"
require "google/cloud/logging/logger"
require "google/cloud/logging/middleware"

module Google
  module Cloud
    module Logging
      ##
      # # Project
      #
      # Projects are top-level containers in Google Cloud Platform. They store
      # information about billing and authorized users, and they control access
      # to Stackdriver Logging resources. Each project has a friendly name and a
      # unique ID. Projects can be created only in the [Google Developers
      # Console](https://console.developers.google.com). See
      # {Google::Cloud#logging}.
      #
      # @example
      #   require "google/cloud/logging"
      #
      #   logging = Google::Cloud::Logging.new
      #   entries = logging.entries
      #
      # See Google::Cloud#logging
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
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new(
        #     project_id: "my-project",
        #     credentials: "/path/to/keyfile.json"
        #   )
        #
        #   logging.project_id #=> "my-project"
        #
        def project_id
          service.project
        end
        alias project project_id

        ##
        # Lists log entries. Use this method to retrieve log entries from Cloud
        # Logging.
        #
        # @param [String, Array<String>] resources One or more cloud resources
        #   from which to retrieve log entries. If both `resources` and
        #   `projects` are `nil`, the ID of the receiving project instance will
        #   be used. Examples: `"projects/my-project-1A"`,
        #   `"projects/1234567890"`.
        # @param [String] filter An [advanced logs
        #   filter](https://cloud.google.com/logging/docs/view/advanced_filters).
        #   The filter is compared against all log entries in the projects
        #   specified by `projects`. Only entries that match the filter are
        #   retrieved. An empty filter matches all log entries.
        # @param [String] order How the results should be sorted. Presently, the
        #   only permitted values are "timestamp" (default) and "timestamp
        #   desc".
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of entries to return.
        # @param [String, Array<String>] projects One or more project IDs or
        #   project numbers from which to retrieve log entries. Each value will
        #   be formatted as a project resource name and added to any values
        #   passed to `resources`. If both `resources` and `projects` are `nil`,
        #   the ID of the receiving project instance will be used. This is
        #   deprecated in favor of `resources`.
        #
        # @return [Array<Google::Cloud::Logging::Entry>] (See
        #   {Google::Cloud::Logging::Entry::List})
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #   entries = logging.entries
        #   entries.each do |e|
        #     puts "[#{e.timestamp}] #{e.log_name} #{e.payload.inspect}"
        #   end
        #
        # @example You can use a filter to narrow results to a single log.
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #   entries = logging.entries filter: "logName:syslog"
        #   entries.each do |e|
        #     puts "[#{e.timestamp}] #{e.payload.inspect}"
        #   end
        #
        # @example You can also order the results by timestamp.
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #   entries = logging.entries order: "timestamp desc"
        #   entries.each do |e|
        #     puts "[#{e.timestamp}] #{e.log_name} #{e.payload.inspect}"
        #   end
        #
        # @example Retrieve all log entries: (See {Entry::List#all})
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #   entries = logging.entries
        #
        #   entries.all do |e|
        #     puts "[#{e.timestamp}] #{e.log_name} #{e.payload.inspect}"
        #   end
        #
        def entries resources: nil, filter: nil, order: nil, token: nil,
                    max: nil, projects: nil
          ensure_service!
          list_grpc = service.list_entries resources: resources, filter: filter,
                                           order: order, token: token, max: max,
                                           projects: projects
          Entry::List.from_grpc list_grpc, service,
                                resources: resources, max: max,
                                filter: filter, order: order,
                                projects: projects
        end
        alias find_entries entries

        ##
        # Creates an new Entry instance that may be populated and written to the
        # Stackdriver Logging service. The {Entry#resource} attribute is
        # pre-populated with a new {Google::Cloud::Logging::Resource} instance.
        # Equivalent to calling `Google::Cloud::Logging::Entry.new`.
        #
        # @param [String] log_name The resource name of the log to which this
        #   log entry belongs. See also {Entry#log_name=}.
        # @param [Resource] resource The monitored resource associated with this
        #   log entry. See also {Entry#resource}.
        # @param [Time] timestamp The time the event described by the log entry
        #   occurred. If omitted, Stackdriver Logging will use the time the log
        #   entry is written. See also {Entry#timestamp}.
        # @param [Symbol] severity The severity level of the log entry. The
        #   default value is `DEFAULT`. See also {Entry#severity}.
        # @param [String] insert_id A unique ID for the log entry. If you
        #   provide this field, the logging service considers other log entries
        #   in the same log with the same ID as duplicates which can be removed.
        #   If omitted, Stackdriver Logging will generate a unique ID for this
        #   log entry. See also {Entry#insert_id}.
        # @param [Hash{Symbol,String => String}] labels A hash of user-defined
        #   `key:value` pairs that provide additional information about the log
        #   entry. See also {Entry#labels=}.
        # @param [String, Hash] payload The log entry payload, represented as
        #   either a string, a hash (JSON), or a hash (protocol buffer). See
        #   also {Entry#payload}.
        #
        # @return [Google::Cloud::Logging::Entry] a new Entry instance
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #
        #   entry = logging.entry severity: :INFO, payload: "Job started."
        #
        #   logging.write_entries entry
        #
        # @example Provide a hash to write a JSON payload to the log:
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #
        #   payload = { "stats" => { "a" => 8, "b" => 12.5} }
        #   entry = logging.entry severity: :INFO, payload: payload
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
        alias new_entry entry

        ##
        # Writes log entries to the Stackdriver Logging service.
        #
        # If you write a collection of log entries, you can provide the log
        # name, resource, and/or labels hash to be used for all of the entries,
        # and omit these values from the individual entries.
        #
        # @param [Google::Cloud::Logging::Entry,
        #   Array<Google::Cloud::Logging::Entry>] entries One or more entry
        #   objects to write. The log entries must have values for all required
        #   fields.
        # @param [String] log_name A default log ID for those log entries in
        #   `entries` that do not specify their own `log_name`. See also
        #   {Entry#log_name=}.
        # @param [Resource] resource A default monitored resource for those log
        #   entries in entries that do not specify their own resource. See also
        #   {Entry#resource}.
        # @param [Hash{Symbol,String => String}] labels User-defined `key:value`
        #   items that are added to the `labels` field of each log entry in
        #   `entries`, except when a log entry specifies its own `key:value`
        #   item with the same key. See also {Entry#labels=}.
        # @param [Boolean] partial_success Whether valid entries should be
        #   written even if some other entries fail due to INVALID_ARGUMENT or
        #   PERMISSION_DENIED errors when communicating to the Stackdriver
        #   Logging API.
        #
        # @return [Boolean] Returns `true` if the entries were written.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #
        #   entry = logging.entry payload: "Job started.",
        #                         log_name: "my_app_log"
        #   entry.resource.type = "gae_app"
        #   entry.resource.labels[:module_id] = "1"
        #   entry.resource.labels[:version_id] = "20150925t173233"
        #
        #   logging.write_entries entry
        #
        # @example Provide a hash to write a JSON payload to the log:
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #
        #   payload = { "stats" => { "a" => 8, "b" => 12.5} }
        #
        #   entry = logging.entry payload: payload,
        #                         log_name: "my_app_log"
        #   entry.resource.type = "gae_app"
        #   entry.resource.labels[:module_id] = "1"
        #   entry.resource.labels[:version_id] = "20150925t173233"
        #
        #   logging.write_entries entry
        #
        #
        # @example Optionally pass log name, resource, and labels for entries.
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
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
        #                         labels: labels,
        #                         partial_success: true
        #
        def write_entries entries, log_name: nil, resource: nil, labels: nil,
                          partial_success: nil
          ensure_service!
          service.write_entries Array(entries).map(&:to_grpc),
                                log_name: log_name, resource: resource,
                                labels: labels, partial_success: partial_success
          true
        end

        ##
        # Creates an object that batches and transmits log entries
        # asynchronously.
        #
        # Use this object to transmit log entries efficiently. It keeps a queue
        # of log entries, and runs a background thread that transmits them to
        # the logging service in batches. Generally, adding to the queue will
        # not block.
        #
        # This object is thread-safe; it may accept write requests from
        # multiple threads simultaneously, and will serialize them when
        # executing in the background thread.
        #
        # @param [Integer] max_queue_size The maximum number of log entries
        #   that may be queued before write requests will begin to block.
        #   This provides back pressure in case the transmitting thread cannot
        #   keep up with requests.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #
        #   async = logging.async_writer
        #
        #   entry1 = logging.entry payload: "Job started."
        #   entry2 = logging.entry payload: "Job completed."
        #
        #   labels = { job_size: "large", job_code: "red" }
        #   resource = logging.resource "gae_app",
        #                               "module_id" => "1",
        #                               "version_id" => "20150925t173233"
        #
        #   async.write_entries [entry1, entry2],
        #                       log_name: "my_app_log",
        #                       resource: resource,
        #                       labels: labels
        #
        def async_writer max_queue_size: AsyncWriter::DEFAULT_MAX_QUEUE_SIZE
          AsyncWriter.new self, max_queue_size
        end

        ##
        # Returns a shared AsyncWriter for this Project. If this method is
        # called multiple times, it will return the same object.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #
        #   async = logging.shared_async_writer
        #
        #   entry1 = logging.entry payload: "Job started."
        #   entry2 = logging.entry payload: "Job completed."
        #
        #   labels = { job_size: "large", job_code: "red" }
        #   resource = logging.resource "gae_app",
        #                               "module_id" => "1",
        #                               "version_id" => "20150925t173233"
        #
        #   async.write_entries [entry1, entry2],
        #                       log_name: "my_app_log",
        #                       resource: resource,
        #                       labels: labels
        #
        def shared_async_writer
          @shared_async_writer ||= async_writer
        end

        ##
        # Creates a logger instance that is API-compatible with Ruby's standard
        # library [Logger](http://ruby-doc.org/stdlib/libdoc/logger/rdoc).
        #
        # The logger will create a new AsyncWriter object to transmit log
        # entries on a background thread.
        #
        # @param [String] log_name A log resource name to be associated with the
        #   written log entries.
        # @param [Google::Cloud::Logging::Resource] resource The monitored
        #   resource to be associated with written log entries.
        # @param [Hash] labels A set of user-defined data to be associated with
        #   written log entries. Values can be strings or Procs which are
        #   functions of the request environment.
        #
        # @return [Google::Cloud::Logging::Logger] a Logger object that can be
        #   used in place of a ruby standard library logger object.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #
        #   resource = logging.resource "gae_app",
        #                               module_id: "1",
        #                               version_id: "20150925t173233"
        #
        #   logger = logging.logger "my_app_log", resource, env: :production
        #   logger.info "Job started."
        #
        # @example Provide a hash to write a JSON payload to the log:
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #
        #   resource = logging.resource "gae_app",
        #                               module_id: "1",
        #                               version_id: "20150925t173233"
        #
        #   logger = logging.logger "my_app_log", resource, env: :production
        #
        #   payload = { "stats" => { "a" => 8, "b" => 12.5} }
        #   logger.info payload
        #
        def logger log_name, resource, labels = {}
          Logger.new shared_async_writer, log_name, resource, labels
        end

        ##
        # Lists log names. Use this method to retrieve log names from Cloud
        # Logging.
        #
        # @param [String] resource The cloud resource from which to retrieve log
        #   names. Optional. If `nil`, the ID of the receiving project instance
        #   will be used. Examples: `"projects/my-project-1A"`,
        #   `"projects/1234567890"`.
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of log names to return.
        #
        # @return [Array<String>] A list of log names. For example,
        #   `projects/my-project/syslog` or
        #   `organizations/123/cloudresourcemanager.googleapis.com%2Factivity`.
        #   (See {Google::Cloud::Logging::Log::List})
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #   logs = logging.logs
        #   logs.each { |l| puts l }
        #
        # @example Retrieve all log names: (See {Log::List#all})
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #   logs = logging.logs
        #
        #   logs.all { |l| puts l }
        #
        def logs resource: nil, token: nil, max: nil
          ensure_service!
          list_grpc = service.list_logs resource: resource, token: token,
                                        max: max
          Log::List.from_grpc list_grpc, service, resource: resource, max: max
        end
        alias find_logs logs
        alias log_names logs
        alias find_log_names logs

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
        # @return [Boolean] Returns `true` if the log and all its log entries
        #   were deleted.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
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
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of resource descriptors to return.
        #
        # @return [Array<Google::Cloud::Logging::ResourceDescriptor>] (See
        #   {Google::Cloud::Logging::ResourceDescriptor::List})
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #   resource_descriptors = logging.resource_descriptors
        #   resource_descriptors.each do |rd|
        #     label_keys = rd.labels.map(&:key).join(", ")
        #     puts "#{rd.type} (#{label_keys})"
        #   end
        #
        # @example Pagination:
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
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
        alias find_resource_descriptors resource_descriptors

        ##
        # Creates a new monitored resource instance.
        #
        # @param [String] type The type of resource, as represented by a
        #   {ResourceDescriptor}.
        # @param [Hash] labels A set of labels that can be used to describe
        #   instances of this monitored resource type.
        #
        # @return [Google::Cloud::Logging::Resource]
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
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
        alias new_resource resource

        ##
        # Retrieves the list of sinks belonging to the project.
        #
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of sinks to return.
        #
        # @return [Array<Google::Cloud::Logging::Sink>] (See
        #   {Google::Cloud::Logging::Sink::List})
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #   sinks = logging.sinks
        #   sinks.each do |s|
        #     puts "#{s.name}: #{s.filter} -> #{s.destination}"
        #   end
        #
        # @example Retrieve all sinks: (See {Sink::List#all})
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
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
        alias find_sinks sinks

        # rubocop:disable Metrics/LineLength
        # overload is too long...

        ##
        # Creates a new project sink. When you create a sink, only new log
        # entries that match the sink's filter are exported. Stackdriver Logging
        # does not send previously-ingested log entries to the sink's
        # destination.
        #
        # Before creating the sink, ensure that you have granted
        # `cloud-logs@google.com` permission to write logs to the destination.
        # See [Permissions for writing exported
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
        # @overload create_sink(name, destination, filter: nil, unique_writer_identity: nil)
        #   @param [String] name The client-assigned sink identifier. Sink
        #     identifiers are limited to 1000 characters and can include only
        #     the following characters: `A-Z`, `a-z`, `0-9`, and the special
        #     characters `_-.`.
        #   @param [String] destination The resource name of the export
        #     destination. See [About
        #     sinks](https://cloud.google.com/logging/docs/api/tasks/exporting-logs#about_sinks)
        #     for examples.
        #   @param [String, nil] filter An [advanced logs
        #    filter](https://cloud.google.com/logging/docs/view/advanced_filters)
        #    that defines the log entries to be exported. The filter must be
        #    consistent with the log entry format designed by the `version`
        #    parameter, regardless of the format of the log entry that was
        #    originally written to Stackdriver Logging.
        #   @param [Boolean] unique_writer_identity Whether the sink will have a
        #      dedicated service account returned in the sink's
        #      `writer_identity`. Set this field to be true to export logs from
        #      one project to a different project. This field is ignored for
        #      non-project sinks (e.g. organization sinks) because those sinks
        #      are required to have dedicated service accounts. Optional.
        #
        # @return [Google::Cloud::Logging::Sink] a project sink
        #
        # @example
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.create_bucket "my-logs-bucket"
        #
        #   # Grant owner permission to Stackdriver Logging service
        #   email = "cloud-logs@google.com"
        #   bucket.acl.add_owner "group-#{email}"
        #
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #
        #   sink = logging.create_sink "my-sink",
        #                              "storage.googleapis.com/#{bucket.id}"
        #
        def create_sink name, destination, filter: nil,
                        unique_writer_identity: nil,
                        start_at: nil, end_at: nil, version: nil
          ensure_service!

          if start_at
            warn "[DEPRECATION] start_at is deprecated and will be ignored."
          end
          if end_at
            warn "[DEPRECATION] end_at is deprecated and will be ignored."
          end
          if version
            warn "[DEPRECATION] version is deprecated and will be ignored."
          end

          grpc = service.create_sink \
            name, destination, filter,
            unique_writer_identity: unique_writer_identity
          Sink.from_grpc grpc, service
        end
        alias new_sink create_sink

        # rubocop:enable Metrics/LineLength

        ##
        # Retrieves a sink by name.
        #
        # @param [String] sink_name Name of a sink.
        #
        # @return [Google::Cloud::Logging::Sink, nil] Returns `nil` if the sink
        #   does not exist.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #   sink = logging.sink "existing-sink"
        #
        # @example By default `nil` will be returned if the sink does not exist.
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #   sink = logging.sink "non-existing-sink" # nil
        #
        def sink sink_name
          ensure_service!
          grpc = service.get_sink sink_name
          Sink.from_grpc grpc, service
        rescue Google::Cloud::NotFoundError
          nil
        end
        alias get_sink sink
        alias find_sink sink

        ##
        # Retrieves the list of metrics belonging to the project.
        #
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of metrics to return.
        #
        # @return [Array<Google::Cloud::Logging::Metric>] (See
        #   {Google::Cloud::Logging::Metric::List})
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #   metrics = logging.metrics
        #   metrics.each do |m|
        #     puts "#{m.name}: #{m.filter}"
        #   end
        #
        # @example Retrieve all metrics: (See {Metric::List#all})
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
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
        alias find_metrics metrics

        ##
        # Creates a new logs-based metric for Google Cloud Monitoring.
        #
        # @see https://cloud.google.com/logging/docs/view/logs_based_metrics
        #   Logs-based Metrics
        # @see https://cloud.google.com/monitoring/docs Google Cloud Monitoring
        #
        # @param [String] name The client-assigned metric identifier. Metric
        #   identifiers are limited to 1000 characters and can include only the
        #   following characters: `A-Z`, `a-z`, `0-9`, and the special
        #   characters `_-.,+!*',()%/\`. The forward-slash character (`/`)
        #   denotes a hierarchy of name pieces, and it cannot be the first
        #   character of the name.
        # @param [String] filter An [advanced logs
        #   filter](https://cloud.google.com/logging/docs/view/advanced_filters).
        # @param [String, nil] description A description of this metric, which
        #   is used in documentation.
        #
        # @return [Google::Cloud::Logging::Metric]
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #   metric = logging.create_metric "errors", "severity>=ERROR"
        #
        def create_metric name, filter, description: nil
          ensure_service!
          grpc = service.create_metric name, filter, description
          Metric.from_grpc grpc, service
        end
        alias new_metric create_metric

        ##
        # Retrieves metric by name.
        #
        # @param [String] name Name of a metric.
        #
        # @return [Google::Cloud::Logging::Metric, nil] Returns `nil` if metric
        #   does not exist.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #   metric = logging.metric "existing_metric"
        #
        # @example By default `nil` will be returned if metric does not exist.
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #   metric = logging.metric "non_existing_metric" # nil
        #
        def metric name
          ensure_service!
          grpc = service.get_metric name
          Metric.from_grpc grpc, service
        rescue Google::Cloud::NotFoundError
          nil
        end
        alias get_metric metric
        alias find_metric metric

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end
      end
    end
  end
end
