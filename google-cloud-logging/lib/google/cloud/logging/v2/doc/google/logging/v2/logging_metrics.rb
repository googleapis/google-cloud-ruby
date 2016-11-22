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
      #     Required. The client-assigned metric identifier.
      #     Examples: +"error_count"+, +"nginx/requests"+.
      #
      #     Metric identifiers are limited to 100 characters and can include
      #     only the following characters: +A-Z+, +a-z+, +0-9+, and the
      #     special characters +_-.,+!*',()%/+.  The forward-slash character
      #     (+/+) denotes a hierarchy of name pieces, and it cannot be the
      #     first character of the name.
      #
      #     The metric identifier in this field must not be
      #     {URL-encoded}[https://en.wikipedia.org/wiki/Percent-encoding].
      #     However, when the metric identifier appears as the +[METRIC_ID]+
      #     part of a +metric_name+ API parameter, then the metric identifier
      #     must be URL-encoded. Example:
      #     +"projects/my-project/metrics/nginx%2Frequests"+.
      # @!attribute [rw] description
      #   @return [String]
      #     Optional. A description of this metric, which is used in documentation.
      # @!attribute [rw] filter
      #   @return [String]
      #     Required. An {advanced logs filter}[https://cloud.google.com/logging/docs/view/advanced_filters].
      #     Example:
      #
      #         "resource.type=gae_app AND severity>=ERROR"
      #
      #     The maximum length of the filter is 20000 characters.
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
      #     Required. The name of the project containing the metrics:
      #
      #         "projects/[PROJECT_ID]"
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
      #     The resource name of the desired metric:
      #
      #         "projects/[PROJECT_ID]/metrics/[METRIC_ID]"
      class GetLogMetricRequest; end

      # The parameters to CreateLogMetric.
      # @!attribute [rw] parent
      #   @return [String]
      #     The resource name of the project in which to create the metric:
      #
      #         "projects/[PROJECT_ID]"
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
      #     The resource name of the metric to update:
      #
      #         "projects/[PROJECT_ID]/metrics/[METRIC_ID]"
      #
      #     The updated metric must be provided in the request and it's
      #     +name+ field must be the same as +[METRIC_ID]+ If the metric
      #     does not exist in +[PROJECT_ID]+, then a new metric is created.
      # @!attribute [rw] metric
      #   @return [Google::Logging::V2::LogMetric]
      #     The updated metric.
      class UpdateLogMetricRequest; end

      # The parameters to DeleteLogMetric.
      # @!attribute [rw] metric_name
      #   @return [String]
      #     The resource name of the metric to delete:
      #
      #         "projects/[PROJECT_ID]/metrics/[METRIC_ID]"
      class DeleteLogMetricRequest; end
    end
  end
end