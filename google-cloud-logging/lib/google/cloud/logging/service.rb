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


require "google/cloud/errors"
require "google/cloud/logging/v2"
require "google/gax/errors"

module Google
  module Cloud
    module Logging
      ##
      # @private Represents the gRPC Logging service, including all the API
      # methods.
      class Service
        attr_accessor :project, :credentials, :host, :timeout, :client_config

        ##
        # Creates a new Service instance.
        def initialize project, credentials, host: nil, timeout: nil,
                       client_config: nil
          @project = project
          @credentials = credentials
          @host = host || V2::LoggingServiceV2Api::SERVICE_ADDRESS
          @timeout = timeout
          @client_config = client_config || {}
        end

        def channel
          require "grpc"
          GRPC::Core::Channel.new host, nil, chan_creds
        end

        def chan_creds
          require "grpc"
          return credentials if insecure?
          GRPC::Core::ChannelCredentials.new.compose \
            GRPC::Core::CallCredentials.new credentials.client.updater_proc
        end

        def logging
          return mocked_logging if mocked_logging
          @logging ||= \
            V2::LoggingServiceV2Api.new(
              service_path: host,
              channel: channel,
              timeout: timeout,
              client_config: client_config,
              app_name: "gcloud-ruby",
              app_version: Google::Cloud::Logging::VERSION)
        end
        attr_accessor :mocked_logging

        def sinks
          return mocked_sinks if mocked_sinks
          @sinks ||= \
            V2::ConfigServiceV2Api.new(
              service_path: host,
              channel: channel,
              timeout: timeout,
              client_config: client_config,
              app_name: "gcloud-ruby",
              app_version: Google::Cloud::Logging::VERSION)
        end
        attr_accessor :mocked_sinks

        def metrics
          return mocked_metrics if mocked_metrics
          @metrics ||= \
            V2::MetricsServiceV2Api.new(
              service_path: host,
              channel: channel,
              timeout: timeout,
              client_config: client_config,
              app_name: "gcloud-ruby",
              app_version: Google::Cloud::Logging::VERSION)
        end
        attr_accessor :mocked_metrics

        def insecure?
          credentials == :this_channel_is_insecure
        end

        def list_entries projects: nil, filter: nil, order: nil, token: nil,
                         max: nil

          project_ids = Array(projects || @project)
          call_opts = default_options
          if token
            call_opts = Google::Gax::CallOptions.new(kwargs: default_headers,
                                                     page_token: token)
          end

          execute do
            paged_enum = logging.list_log_entries project_ids,
                                                  filter: filter,
                                                  order_by: order,
                                                  page_size: max,
                                                  options: call_opts
            paged_enum.page.response
          end
        end

        def write_entries entries, log_name: nil, resource: nil, labels: nil
          # Fix log names so they are the full path
          entries = Array(entries).each do |entry|
            entry.log_name = log_path(entry.log_name)
          end
          resource = resource.to_grpc if resource
          labels = Hash[labels.map { |k, v| [String(k), String(v)] }] if labels

          execute do
            logging.write_log_entries entries,
                                      log_name: log_path(log_name),
                                      resource: resource, labels: labels,
                                      options: default_options
          end
        end

        def delete_log name
          execute do
            logging.delete_log log_path(name), options: default_options
          end
        end

        def list_resource_descriptors token: nil, max: nil
          call_opts = default_options
          if token
            call_opts = Google::Gax::CallOptions.new(kwargs: default_headers,
                                                     page_token: token)
          end

          execute do
            logging.list_monitored_resource_descriptors \
              page_size: max, options: call_opts
          end
        end

        def list_sinks token: nil, max: nil
          call_opts = default_options
          if token
            call_opts = Google::Gax::CallOptions.new(kwargs: default_headers,
                                                     page_token: token)
          end

          execute do
            paged_enum = sinks.list_sinks \
              project_path, page_size: max, options: call_opts
            paged_enum.page.response
          end
        end

        def create_sink name, destination, filter, version
          sink = Google::Logging::V2::LogSink.new({
            name: name, destination: destination, filter: filter,
            output_version_format: version }.delete_if { |_, v| v.nil? })

          execute do
            sinks.create_sink project_path, sink, options: default_options
          end
        end

        def get_sink name
          execute { sinks.get_sink sink_path(name), options: default_options }
        end

        def update_sink name, destination, filter, version
          sink = Google::Logging::V2::LogSink.new({
            name: name, destination: destination, filter: filter,
            output_version_format: version }.delete_if { |_, v| v.nil? })

          execute do
            sinks.update_sink sink_path(name), sink, options: default_options
          end
        end

        def delete_sink name
          execute do
            sinks.delete_sink sink_path(name), options: default_options
          end
        end

        def list_metrics token: nil, max: nil
          call_opts = default_options
          if token
            call_opts = Google::Gax::CallOptions.new(kwargs: default_headers,
                                                     page_token: token)
          end

          execute do
            paged_enum = metrics.list_log_metrics \
              project_path, page_size: max, options: call_opts
            paged_enum.page.response
          end
        end

        def create_metric name, filter, description
          metric = Google::Logging::V2::LogMetric.new({
            name: name, description: description,
            filter: filter }.delete_if { |_, v| v.nil? })

          execute do
            metrics.create_log_metric project_path, metric,
                                      options: default_options
          end
        end

        def get_metric name
          execute do
            metrics.get_log_metric metric_path(name), options: default_options
          end
        end

        def update_metric name, description, filter
          metric = Google::Logging::V2::LogMetric.new({
            name: name, description: description,
            filter: filter }.delete_if { |_, v| v.nil? })

          execute do
            metrics.update_log_metric metric_path(name), metric,
                                      options: default_options
          end
        end

        def delete_metric name
          execute do
            metrics.delete_log_metric metric_path(name),
                                      options: default_options
          end
        end

        def inspect
          "#{self.class}(#{@project})"
        end

        protected

        def project_path
          "projects/#{@project}"
        end

        def log_path log_name
          return nil if log_name.nil?
          return log_name if log_name.empty?
          return log_name if log_name.to_s.include? "/"
          "#{project_path}/logs/#{log_name}"
        end

        def sink_path sink_name
          return sink_name if sink_name.to_s.include? "/"
          "#{project_path}/sinks/#{sink_name}"
        end

        def metric_path metric_name
          return metric_name if metric_name.to_s.include? "/"
          "#{project_path}/metrics/#{metric_name}"
        end

        def default_headers
          { "google-cloud-resource-prefix" => "projects/#{@project}" }
        end

        def default_options
          Google::Gax::CallOptions.new kwargs: default_headers
        end

        def execute
          yield
        rescue Google::Gax::GaxError => e
          # GaxError wraps BadStatus, but exposes it as #cause
          raise Google::Cloud::Error.from_error(e.cause)
        end
      end
    end
  end
end
