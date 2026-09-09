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
require "google/cloud/logging/version"
require "google/cloud/logging/v2"
require "uri"

module Google
  module Cloud
    module Logging
      ##
      # @private Represents the gRPC Logging service, including all the API
      # methods.
      class Service
        attr_accessor :project
        attr_accessor :credentials
        attr_accessor :timeout
        attr_accessor :host

        ##
        # Creates a new Service instance.
        def initialize project, credentials, timeout: nil, host: nil
          @project = project
          @credentials = credentials
          @timeout = timeout
          @host = host
        end

        def logging
          return mocked_logging if mocked_logging
          @logging ||=
            V2::LoggingService::Client.new do |config|
              config.credentials = credentials if credentials
              config.timeout = timeout if timeout
              config.endpoint = host if host
              config.lib_name = "gccl"
              config.lib_version = Google::Cloud::Logging::VERSION
              config.metadata = { "google-cloud-resource-prefix" => "projects/#{@project}" }
            end
        end
        attr_accessor :mocked_logging

        def sinks
          return mocked_sinks if mocked_sinks
          @sinks ||=
            V2::ConfigService::Client.new do |config|
              config.credentials = credentials if credentials
              config.timeout = timeout if timeout
              config.endpoint = host if host
              config.lib_name = "gccl"
              config.lib_version = Google::Cloud::Logging::VERSION
              config.metadata = { "google-cloud-resource-prefix" => "projects/#{@project}" }
            end
        end
        attr_accessor :mocked_sinks

        def metrics
          return mocked_metrics if mocked_metrics
          @metrics ||=
            V2::MetricsService::Client.new do |config|
              config.credentials = credentials if credentials
              config.timeout = timeout if timeout
              config.endpoint = host if host
              config.lib_name = "gccl"
              config.lib_version = Google::Cloud::Logging::VERSION
              config.metadata = { "google-cloud-resource-prefix" => "projects/#{@project}" }
            end
        end
        attr_accessor :mocked_metrics

        def list_entries resources: nil, filter: nil, order: nil, token: nil,
                         max: nil, projects: nil
          project_ids = Array(projects).map { |p| "projects/#{p}" }
          resource_names = Array(resources) + project_ids
          resource_names = ["projects/#{@project}"] if resource_names.empty?
          paged_enum = logging.list_log_entries resource_names: resource_names,
                                                filter:         filter,
                                                order_by:       order,
                                                page_size:      max,
                                                page_token:     token
          paged_enum.response
        end

        def write_entries entries, log_name: nil, resource: nil, labels: nil,
                          partial_success: nil
          # Fix log names so they are the full path
          entries = Array(entries).each do |entry|
            entry.log_name = log_path entry.log_name
          end
          resource = resource.to_grpc if resource
          labels = labels.to_h { |k, v| [String(k), String(v)] } if labels
          logging.write_log_entries entries:         entries,
                                    log_name:        log_path(log_name),
                                    resource:        resource,
                                    labels:          labels,
                                    partial_success: partial_success
        end

        def list_logs resource: nil, token: nil, max: nil
          parent = resource || "projects/#{@project}"
          logging.list_logs parent:     parent,
                            page_size:  max,
                            page_token: token
        end

        def delete_log name
          logging.delete_log log_name: log_path(name)
        end

        def list_resource_descriptors token: nil, max: nil
          paged_enum = logging.list_monitored_resource_descriptors page_size: max, page_token: token
          paged_enum.response
        end

        def list_sinks token: nil, max: nil
          paged_enum = sinks.list_sinks parent: project_path, page_size: max, page_token: token
          paged_enum.response
        end

        def create_sink name, destination, filter, unique_writer_identity: nil
          sink = Google::Cloud::Logging::V2::LogSink.new(
            {
              name: name, destination: destination, filter: filter
            }.compact
          )
          sinks.create_sink parent:                 project_path,
                            sink:                   sink,
                            unique_writer_identity: unique_writer_identity
        end

        def get_sink name
          sinks.get_sink sink_name: sink_path(name)
        end

        def update_sink name, destination, filter, unique_writer_identity: nil
          sink = Google::Cloud::Logging::V2::LogSink.new(
            {
              name: name, destination: destination, filter: filter
            }.compact
          )
          sinks.update_sink sink_name:              sink_path(name),
                            sink:                   sink,
                            unique_writer_identity: unique_writer_identity
        end

        def delete_sink name
          sinks.delete_sink sink_name: sink_path(name)
        end

        def list_metrics token: nil, max: nil
          paged_enum = metrics.list_log_metrics parent:     project_path,
                                                page_size:  max,
                                                page_token: token
          paged_enum.response
        end

        def create_metric name, filter, description
          metric = Google::Cloud::Logging::V2::LogMetric.new(
            { name: name, description: description,
              filter: filter }.compact
          )
          metrics.create_log_metric parent: project_path, metric: metric
        end

        def get_metric name
          metrics.get_log_metric metric_name: metric_path(name)
        end

        def update_metric name, description, filter
          metric = Google::Cloud::Logging::V2::LogMetric.new(
            { name: name, description: description,
              filter: filter }.compact
          )
          metrics.update_log_metric metric_name: metric_path(name), metric: metric
        end

        def delete_metric name
          metrics.delete_log_metric metric_name: metric_path(name)
        end

        def log_path log_name
          return nil if log_name.nil?
          return log_name if log_name.empty?
          return log_name if log_name.to_s.include? "/"
          "#{project_path}/logs/#{log_name}"
        end

        def inspect
          "#{self.class}(#{@project})"
        end

        protected

        def project_path
          "projects/#{@project}"
        end

        def sink_path sink_name
          return sink_name if sink_name.to_s.include? "/"
          "#{project_path}/sinks/#{sink_name}"
        end

        def metric_path metric_name
          return metric_name if metric_name.to_s.include? "/"
          "#{project_path}/metrics/#{metric_name}"
        end

        ##
        # @private Get a Google::Protobuf::Timestamp object from a Time object.
        def time_to_timestamp time
          return nil if time.nil?
          # Make sure we have a Time object
          return nil unless time.respond_to? :to_time
          time = time.to_time
          Google::Protobuf::Timestamp.new seconds: time.to_i, nanos: time.nsec
        end

        ##
        # @private Get a Time object from a Google::Protobuf::Timestamp object.
        def timestamp_to_time timestamp
          return nil if timestamp.nil?
          # Time.at takes microseconds, so convert nano seconds to microseconds
          Time.at timestamp.seconds, Rational(timestamp.nanos, 1000)
        end
      end
    end
  end
end
