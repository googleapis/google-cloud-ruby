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
require "google/cloud/core/grpc_backoff"
require "google/logging/v2/logging_services_pb"
require "google/logging/v2/logging_config_services_pb"
require "google/logging/v2/logging_metrics_services_pb"

module Google
  module Cloud
    module Logging
      ##
      # @private Represents the gRPC Logging service, including all the API
      # methods.
      class Service
        attr_accessor :project, :credentials, :host, :retries, :timeout

        ##
        # Creates a new Service instance.
        def initialize project, credentials, host: nil, retries: nil,
                       timeout: nil
          @project = project
          @credentials = credentials
          @host = host || "logging.googleapis.com"
          @retries = retries
          @timeout = timeout
        end

        def creds
          GRPC::Core::ChannelCredentials.new.compose \
            GRPC::Core::CallCredentials.new credentials.client.updater_proc
        end

        def logging
          return mocked_logging if mocked_logging
          @logging ||= Google::Logging::V2::LoggingServiceV2::Stub.new(
            host, creds, timeout: timeout)
        end
        attr_accessor :mocked_logging

        def sinks
          return mocked_sinks if mocked_sinks
          @sinks ||= Google::Logging::V2::ConfigServiceV2::Stub.new(
            host, creds, timeout: timeout)
        end
        attr_accessor :mocked_sinks

        def metrics
          return mocked_metrics if mocked_metrics
          @metrics ||= Google::Logging::V2::MetricsServiceV2::Stub.new(
            host, creds, timeout: timeout)
        end
        attr_accessor :mocked_metrics

        def list_entries projects: nil, filter: nil, order: nil, token: nil,
                         max: nil
          list_params = { project_ids: Array(projects || @project),
                          filter: filter,
                          order_by: order,
                          page_token: token,
                          page_size: max
                        }.delete_if { |_, v| v.nil? }

          list_req = Google::Logging::V2::ListLogEntriesRequest.new(list_params)

          execute { logging.list_log_entries list_req }
        end

        def write_entries entries, log_name: nil, resource: nil, labels: nil
          # Fix log names so they are the full path
          entries = Array(entries).each do |entry|
            entry.log_name = log_path(entry.log_name)
          end
          resource = resource.to_grpc if resource
          labels = Hash[labels.map { |k, v| [String(k), String(v)] }] if labels

          write_params = { entries: entries,
                           log_name: log_path(log_name),
                           resource: resource, labels: labels
                         }.delete_if { |_, v| v.nil? }

          write_req = Google::Logging::V2::WriteLogEntriesRequest.new(
            write_params)

          execute { logging.write_log_entries write_req }
        end

        def delete_log name
          delete_req = Google::Logging::V2::DeleteLogRequest.new(
            log_name: log_path(name)
          )

          execute { logging.delete_log delete_req }
        end

        def list_resource_descriptors token: nil, max: nil
          list_params = { page_token: token,
                          page_size: max
                        }.delete_if { |_, v| v.nil? }

          list_req = \
            Google::Logging::V2::ListMonitoredResourceDescriptorsRequest.new(
              list_params)

          execute { logging.list_monitored_resource_descriptors list_req }
        end

        def list_sinks token: nil, max: nil
          list_params = { parent: project_path,
                          page_token: token,
                          page_size: max
                        }.delete_if { |_, v| v.nil? }

          list_req = Google::Logging::V2::ListSinksRequest.new(list_params)

          execute { sinks.list_sinks list_req }
        end

        def create_sink name, destination, filter, version
          sink_params = {
            name: name, destination: destination,
            filter: filter, output_version_format: version
          }.delete_if { |_, v| v.nil? }

          create_req = Google::Logging::V2::CreateSinkRequest.new(
            parent: project_path,
            sink: Google::Logging::V2::LogSink.new(sink_params)
          )

          execute { sinks.create_sink create_req }
        end

        def get_sink name
          get_req = Google::Logging::V2::GetSinkRequest.new(
            sink_name: sink_path(name)
          )

          execute { sinks.get_sink get_req }
        end

        def update_sink name, destination, filter, version
          sink_params = {
            name: name, destination: destination,
            filter: filter, output_version_format: version
          }.delete_if { |_, v| v.nil? }

          update_req = Google::Logging::V2::UpdateSinkRequest.new(
            sink_name: sink_path(name),
            sink: Google::Logging::V2::LogSink.new(sink_params)
          )

          execute { sinks.update_sink update_req }
        end

        def delete_sink name
          delete_req = Google::Logging::V2::DeleteSinkRequest.new(
            sink_name: sink_path(name)
          )

          execute { sinks.delete_sink delete_req }
        end

        def list_metrics token: nil, max: nil
          list_params = { parent: project_path,
                          page_token: token,
                          page_size: max
                        }.delete_if { |_, v| v.nil? }

          list_req = Google::Logging::V2::ListLogMetricsRequest.new(list_params)

          execute { metrics.list_log_metrics list_req }
        end

        def create_metric name, filter, description
          metric_params = {
            name: name,
            description: description,
            filter: filter
          }.delete_if { |_, v| v.nil? }

          create_req = Google::Logging::V2::CreateLogMetricRequest.new(
            parent: project_path,
            metric: Google::Logging::V2::LogMetric.new(metric_params)
          )

          execute { metrics.create_log_metric create_req }
        end

        def get_metric name
          get_req = Google::Logging::V2::GetLogMetricRequest.new(
            metric_name: metric_path(name)
          )

          execute { metrics.get_log_metric get_req }
        end

        def update_metric name, description, filter
          metric_params = {
            name: name,
            description: description,
            filter: filter
          }.delete_if { |_, v| v.nil? }

          update_req = Google::Logging::V2::UpdateLogMetricRequest.new(
            metric_name: metric_path(name),
            metric: Google::Logging::V2::LogMetric.new(metric_params)
          )

          execute { metrics.update_log_metric update_req }
        end

        def delete_metric name
          delete_req = Google::Logging::V2::DeleteLogMetricRequest.new(
            metric_name: metric_path(name)
          )

          execute { metrics.delete_log_metric delete_req }
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

        def execute
          Google::Cloud::Core::GrpcBackoff.new(retries: retries).execute do
            yield
          end
        rescue GRPC::BadStatus => e
          raise Google::Cloud::Error.from_error(e)
        end
      end
    end
  end
end
