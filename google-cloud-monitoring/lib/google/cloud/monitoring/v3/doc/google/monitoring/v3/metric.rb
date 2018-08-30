# Copyright 2018 Google LLC
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


module Google
  module Monitoring
    module V3
      # A single data point in a time series.
      # @!attribute [rw] interval
      #   @return [Google::Monitoring::V3::TimeInterval]
      #     The time interval to which the data point applies.  For +GAUGE+ metrics,
      #     only the end time of the interval is used.  For +DELTA+ metrics, the start
      #     and end time should specify a non-zero interval, with subsequent points
      #     specifying contiguous and non-overlapping intervals.  For +CUMULATIVE+
      #     metrics, the start and end time should specify a non-zero interval, with
      #     subsequent points specifying the same start time and increasing end times,
      #     until an event resets the cumulative value to zero and sets a new start
      #     time for the following points.
      # @!attribute [rw] value
      #   @return [Google::Monitoring::V3::TypedValue]
      #     The value of the data point.
      class Point; end

      # A collection of data points that describes the time-varying values
      # of a metric. A time series is identified by a combination of a
      # fully-specified monitored resource and a fully-specified metric.
      # This type is used for both listing and creating time series.
      # @!attribute [rw] metric
      #   @return [Google::Api::Metric]
      #     The associated metric. A fully-specified metric used to identify the time
      #     series.
      # @!attribute [rw] resource
      #   @return [Google::Api::MonitoredResource]
      #     The associated monitored resource.  Custom metrics can use only certain
      #     monitored resource types in their time series data.
      # @!attribute [rw] metadata
      #   @return [Google::Api::MonitoredResourceMetadata]
      #     Output only. The associated monitored resource metadata. When reading a
      #     a timeseries, this field will include metadata labels that are explicitly
      #     named in the reduction. When creating a timeseries, this field is ignored.
      # @!attribute [rw] metric_kind
      #   @return [Google::Api::MetricDescriptor::MetricKind]
      #     The metric kind of the time series. When listing time series, this metric
      #     kind might be different from the metric kind of the associated metric if
      #     this time series is an alignment or reduction of other time series.
      #
      #     When creating a time series, this field is optional. If present, it must be
      #     the same as the metric kind of the associated metric. If the associated
      #     metric's descriptor must be auto-created, then this field specifies the
      #     metric kind of the new descriptor and must be either +GAUGE+ (the default)
      #     or +CUMULATIVE+.
      # @!attribute [rw] value_type
      #   @return [Google::Api::MetricDescriptor::ValueType]
      #     The value type of the time series. When listing time series, this value
      #     type might be different from the value type of the associated metric if
      #     this time series is an alignment or reduction of other time series.
      #
      #     When creating a time series, this field is optional. If present, it must be
      #     the same as the type of the data in the +points+ field.
      # @!attribute [rw] points
      #   @return [Array<Google::Monitoring::V3::Point>]
      #     The data points of this time series. When listing time series, points are
      #     returned in reverse time order.
      #
      #     When creating a time series, this field must contain exactly one point and
      #     the point's type must be the same as the value type of the associated
      #     metric. If the associated metric's descriptor must be auto-created, then
      #     the value type of the descriptor is determined by the point's type, which
      #     must be +BOOL+, +INT64+, +DOUBLE+, or +DISTRIBUTION+.
      class TimeSeries; end
    end
  end
end