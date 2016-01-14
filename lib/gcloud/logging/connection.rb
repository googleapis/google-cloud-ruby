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


require "gcloud/version"
require "google/api_client"

module Gcloud
  module Logging
    ##
    # @private Represents the connection to Logging,
    # as well as expose the API calls.
    class Connection
      API_VERSION = "v2beta1"

      attr_accessor :project
      attr_accessor :credentials

      ##
      # Creates a new Connection instance.
      def initialize project, credentials
        @project = project
        @credentials = credentials
        @client = Google::APIClient.new application_name:    "gcloud-ruby",
                                        application_version: Gcloud::VERSION
        @client.authorization = @credentials.client
        @logging = @client.discovered_api "logging", API_VERSION
      end

      def delete_log name
        @client.execute(
          api_method: @logging.projects.logs.delete,
          parameters: { logName: log_path(name) }
        )
      end

      def list_resources token: nil, max: nil
        params = { pageToken: token,
                   maxResults: max
                 }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @logging.monitored_resource_descriptors.list,
          parameters: params
        )
      end

      def list_sinks token: nil, max: nil
        params = { projectName: project_path,
                   pageToken: token,
                   maxResults: max
                 }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @logging.projects.sinks.list,
          parameters: params
        )
      end

      def create_sink name, destination, filter, version
        params = { projectName: project_path }
        new_sink_object = {
          name: name, destination: destination,
          filter: filter, outputVersionFormat: version
        }

        @client.execute(
          api_method: @logging.projects.sinks.create,
          parameters: params,
          body_object: new_sink_object
        )
      end

      def get_sink name
        @client.execute(
          api_method: @logging.projects.sinks.get,
          parameters: { sinkName: sink_path(name) }
        )
      end

      def update_sink name, destination, filter, version
        params = { sinkName: sink_path(name) }
        updated_sink_object = {
          name: name, destination: destination,
          filter: filter, outputVersionFormat: version
        }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @logging.projects.sinks.update,
          parameters: params,
          body_object: updated_sink_object
        )
      end

      def delete_sink name
        @client.execute(
          api_method: @logging.projects.sinks.delete,
          parameters: { sinkName: sink_path(name) }
        )
      end

      def list_metrics token: nil, max: nil
        params = { projectName: project_path,
                   pageToken: token,
                   maxResults: max
                 }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @logging.projects.metrics.list,
          parameters: params
        )
      end

      def create_metric name, description, filter
        params = { projectName: project_path }
        new_metric_object = {
          name: name, description: description, filter: filter
        }

        @client.execute(
          api_method: @logging.projects.metrics.create,
          parameters: params,
          body_object: new_metric_object
        )
      end

      def get_metric name
        @client.execute(
          api_method: @logging.projects.metrics.get,
          parameters: { metricName: metric_path(name) }
        )
      end

      def update_metric name, description, filter
        params = { metricName: metric_path(name) }
        updated_metric_object = {
          name: name, description: description, filter: filter
        }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @logging.projects.metrics.update,
          parameters: params,
          body_object: updated_metric_object
        )
      end

      def delete_metric name
        @client.execute(
          api_method: @logging.projects.metrics.delete,
          parameters: { metricName: metric_path(name) }
        )
      end

      protected

      def project_path
        "projects/#{@project}"
      end

      def log_path log_name
        return log_name if log_name.to_s.include? "/"
        "#{project_path}/logs/#{log_name}"
      end

      def sink_path sink_name
        "#{project_path}/sinks/#{sink_name}"
      end

      def metric_path metric_name
        "#{project_path}/metrics/#{metric_name}"
      end
    end
  end
end
