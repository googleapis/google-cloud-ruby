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


require "google/logging/v2/logging_services"
require "google/logging/v2/logging_config_services"
require "google/logging/v2/logging_metrics_services"

module Gcloud
  module Logging
    ##
    # @private Represents the gRPC Logging service, including all the API
    # methods.
    class Service
      attr_accessor :project, :host, :creds

      ##
      # Creates a new Service instance.
      def initialize project, credentials
        @project = project
        @host = "logging.googleapis.com"
        updater_proc = credentials.client.updater_proc
        ssl_creds = GRPC::Core::ChannelCredentials.new
        call_creds = GRPC::Core::CallCredentials.new updater_proc
        @creds = ssl_creds.compose call_creds
      end

      def logging
        @logging ||= Google::Logging::V2::LoggingServiceV2::Stub.new host, creds
      end
      attr_writer :logging

      def sinks
        @sinks ||= Google::Logging::V2::ConfigServiceV2::Stub.new host, creds
      end
      attr_writer :sinks

      def metrics
        @metrics ||= Google::Logging::V2::MetricsServiceV2::Stub.new host, creds
      end
      attr_writer :metrics

      protected

      def project_path
        "projects/#{@project}"
      end

      def log_path log_name
        return nil if log_name.nil?
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
    end
  end
end
