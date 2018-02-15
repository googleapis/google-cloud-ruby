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


require "google/cloud/logging/metric/list"

module Google
  module Cloud
    module Logging
      ##
      # # Metric
      #
      # A logs-based [Google Cloud
      # Monitoring](https://cloud.google.com/monitoring/docs) metric. A metric
      # is a measured value that can be used to assess a system. The basis of a
      # logs-based metric is the collection of log entries that match a logs
      # filter.
      #
      # @see https://cloud.google.com/logging/docs/view/logs_based_metrics
      #   Logs-based Metrics
      # @see https://cloud.google.com/monitoring/docs Google Cloud Monitoring
      #
      # @example
      #   require "google/cloud/logging"
      #
      #   logging = Google::Cloud::Logging.new
      #   metric = logging.create_metric "errors", "severity>=ERROR"
      #
      class Metric
        ##
        # @private The gRPC Service object.
        attr_accessor :service

        ##
        # @private The gRPC Google::Logging::V2::LogMetric object.
        attr_accessor :grpc

        ##
        # @private Create an empty Metric object.
        def initialize
          @service = nil
          @grpc = Google::Logging::V2::LogMetric.new
        end

        ##
        # The client-assigned metric identifier. Metric identifiers are limited
        # to 1000 characters and can include only the following characters:
        # `A-Z`, `a-z`, `0-9`, and the special characters `_-.,+!*',()%/\`. The
        # forward-slash character (`/`) denotes a hierarchy of name pieces, and
        # it cannot be the first character of the name.
        def name
          grpc.name
        end

        ##
        # The description of this metric, which is used in documentation.
        def description
          grpc.description
        end

        ##
        # Updates the description of this metric, which is used in
        # documentation.
        def description= description
          grpc.description = description
        end

        ##
        # An [advanced logs
        # filter](https://cloud.google.com/logging/docs/view/advanced_filters).
        def filter
          grpc.filter
        end

        ##
        # Updates the [advanced logs
        # filter](https://cloud.google.com/logging/docs/view/advanced_filters).
        def filter= filter
          grpc.filter = filter
        end

        ##
        # Updates the logs-based metric.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #   metric = logging.metric "severe_errors"
        #   metric.filter = "logName:syslog AND severity>=ERROR"
        #   metric.save
        #
        def save
          ensure_service!
          @grpc = service.update_metric name, description, filter
          true
        end

        ##
        # Reloads the logs-based metric with current data from the Logging
        # service.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #   metric = logging.metric "severe_errors"
        #   metric.filter = "Unwanted value"
        #   metric.reload!
        #   metric.filter #=> "logName:syslog"
        #
        def reload!
          ensure_service!
          @grpc = service.get_metric name
          true
        end
        alias refresh! reload!

        ##
        # Permanently deletes the logs-based metric.
        #
        # @return [Boolean] Returns `true` if the metric was deleted.
        #
        # @example
        #   require "google/cloud/logging"
        #
        #   logging = Google::Cloud::Logging.new
        #   metric = logging.metric "severe_errors"
        #   metric.delete
        #
        def delete
          ensure_service!
          service.delete_metric name
          true
        end

        ##
        # @private New Metric from a gRPC object.
        def self.from_grpc grpc, service
          new.tap do |m|
            m.grpc = grpc
            m.service = service
          end
        end

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
