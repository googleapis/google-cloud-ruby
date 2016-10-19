# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Google
  module Logging
    module V2
      # Describes a logs-based metric.  The value of the metric is the
      # number of log entries that match a logs filter.
      # @!attribute [rw] name
      #   @return [String]
      #     Required. The client-assigned metric identifier. Example:
      #     +"severe_errors"+.  Metric identifiers are limited to 100
      #     characters and can include only the following characters: +A-Z+,
      #     +a-z+, +0-9+, and the special characters +_-.,+!*',()%/+.  The
      #     forward-slash character (+/+) denotes a hierarchy of name pieces,
      #     and it cannot be the first character of the name.  The '%' character
      #     is used to URL encode unsafe and reserved characters and must be
      #     followed by two hexadecimal digits according to RFC 1738.
      # @!attribute [rw] description
      #   @return [String]
      #     Optional. A description of this metric, which is used in documentation.
      # @!attribute [rw] filter
      #   @return [String]
      #     Required. An {advanced logs filter}[https://cloud.google.com/logging/docs/view/advanced_filters].
      #     Example: +"resource.type=gae_app AND severity>=ERROR"+.
      # @!attribute [rw] version
      #   @return [Google::Logging::V2::LogMetric::ApiVersion]
      #     Output only. The API version that created or updated this metric.
      #     The version also dictates the syntax of the filter expression. When a value
      #     for this field is missing, the default value of V2 should be assumed.
      class LogMetric
        # Stackdriver Logging API version.
        module ApiVersion
          # Stackdriver Logging API v2.
          V2 = 0

          # Stackdriver Logging API v1.
          V1 = 1
        end
      end

      # The parameters to ListLogMetrics.
      # @!attribute [rw] parent
      #   @return [String]
      #     Required. The resource name containing the metrics.
      #     Example: +"projects/my-project-id"+.
      # @!attribute [rw] page_token
      #   @return [String]
      #     Optional. If present, then retrieve the next batch of results from the
      #     preceding call to this method.  +pageToken+ must be the value of
      #     +nextPageToken+ from the previous response.  The values of other method
      #     parameters should be identical to those in the previous call.
      # @!attribute [rw] page_size
      #   @return [Integer]
      #     Optional. The maximum number of results to return from this request.
      #     Non-positive values are ignored.  The presence of +nextPageToken+ in the
      #     response indicates that more results might be available.
      class ListLogMetricsRequest; end

      # Result returned from ListLogMetrics.
      # @!attribute [rw] metrics
      #   @return [Array<Google::Logging::V2::LogMetric>]
      #     A list of logs-based metrics.
      # @!attribute [rw] next_page_token
      #   @return [String]
      #     If there might be more results than appear in this response, then
      #     +nextPageToken+ is included.  To get the next set of results, call this
      #     method again using the value of +nextPageToken+ as +pageToken+.
      class ListLogMetricsResponse; end

      # The parameters to GetLogMetric.
      # @!attribute [rw] metric_name
      #   @return [String]
      #     The resource name of the desired metric.
      #     Example: +"projects/my-project-id/metrics/my-metric-id"+.
      class GetLogMetricRequest; end

      # The parameters to CreateLogMetric.
      # @!attribute [rw] parent
      #   @return [String]
      #     The resource name of the project in which to create the metric.
      #     Example: +"projects/my-project-id"+.
      #
      #     The new metric must be provided in the request.
      # @!attribute [rw] metric
      #   @return [Google::Logging::V2::LogMetric]
      #     The new logs-based metric, which must not have an identifier that
      #     already exists.
      class CreateLogMetricRequest; end

      # The parameters to UpdateLogMetric.
      # @!attribute [rw] metric_name
      #   @return [String]
      #     The resource name of the metric to update.
      #     Example: +"projects/my-project-id/metrics/my-metric-id"+.
      #
      #     The updated metric must be provided in the request and have the
      #     same identifier that is specified in +metricName+.
      #     If the metric does not exist, it is created.
      # @!attribute [rw] metric
      #   @return [Google::Logging::V2::LogMetric]
      #     The updated metric, whose name must be the same as the
      #     metric identifier in +metricName+. If +metricName+ does not
      #     exist, then a new metric is created.
      class UpdateLogMetricRequest; end

      # The parameters to DeleteLogMetric.
      # @!attribute [rw] metric_name
      #   @return [String]
      #     The resource name of the metric to delete.
      #     Example: +"projects/my-project-id/metrics/my-metric-id"+.
      class DeleteLogMetricRequest; end
    end
  end
end