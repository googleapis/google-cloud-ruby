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
require "gcloud/logging/resource"
require "gcloud/logging/sink"
require "gcloud/logging/metric"

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
      # Retrieves the list of monitored resources that are used by Google Cloud
      # Logging.
      #
      # @param [String] token A previously-returned page token representing part
      #   of the larger set of results to view.
      # @param [Integer] max Maximum number of resources to return.
      #
      # @return [Array<Gcloud::Logging::Resource>] (See
      #   {Gcloud::Logging::Resource::List})
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   resources = logging.resources
      #   resources.each do |resource|
      #     puts resource.name
      #   end
      #
      # @example With pagination: (See {Gcloud::Logging::Resource::List})
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   logging = gcloud.logging
      #   resources = logging.resources
      #   loop do
      #     resources.each do |resource|
      #       puts resource.name
      #     end
      #     break unless resources.next?
      #     resources = resources.next
      #   end
      #
      def resources token: nil, max: nil
        ensure_connection!
        resp = connection.list_resources token: token, max: max
        if resp.success?
          Resource::List.from_response resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :find_resources, :resources

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
