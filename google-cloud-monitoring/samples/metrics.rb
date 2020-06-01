# Copyright 2020 Google LLC
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

require "google/cloud/monitoring"

def create_metric_descriptor project_id:, metric_type:
  # [START monitoring_create_metric]
  # Your Google Cloud Platform project ID
  # project_id = "YOUR_PROJECT_ID"

  # Example metric type
  # metric_type = "custom.googleapis.com/my_metric"

  client = Google::Cloud::Monitoring.metric_service
  project_name = client.project_path project: project_id

  descriptor = Google::Api::MetricDescriptor.new(
    type:        metric_type,
    metric_kind: Google::Api::MetricDescriptor::MetricKind::GAUGE,
    value_type:  Google::Api::MetricDescriptor::ValueType::DOUBLE,
    description: "This is a simple example of a custom metric."
  )

  result = client.create_metric_descriptor name:              project_name,
                                           metric_descriptor: descriptor
  p "Created #{result.name}"
  p result
  # [END monitoring_create_metric]
end

def delete_metric_descriptor project_id:, metric_type:
  # [START monitoring_delete_metric]
  # Your Google Cloud Platform project ID
  # project_id = "YOUR_PROJECT_ID"

  # Example metric type
  # metric_type = "custom.googleapis.com/my_metric"

  client = Google::Cloud::Monitoring.metric_service
  metric_name = client.metric_descriptor_path project:           project_id,
                                              metric_descriptor: metric_type

  client.delete_metric_descriptor name: metric_name
  p "Deleted metric descriptor #{metric_name}."
  # [END monitoring_delete_metric]
end

def write_time_series project_id:, metric_type:
  # [START monitoring_write_timeseries]
  # Your Google Cloud Platform project ID
  # project_id = "YOUR_PROJECT_ID"

  # Example metric type
  # metric_type = "custom.googleapis.com/my_metric"

  client = Google::Cloud::Monitoring.metric_service
  project_name = client.project_path project: project_id

  series = Google::Cloud::Monitoring::V3::TimeSeries.new
  series.metric = Google::Api::Metric.new type: metric_type

  resource = Google::Api::MonitoredResource.new type: "global"
  resource.labels["project_id"] = project_id
  series.resource = resource

  point = Google::Cloud::Monitoring::V3::Point.new
  point.value = Google::Cloud::Monitoring::V3::TypedValue.new double_value: 3.14
  now = Time.now
  end_time = Google::Protobuf::Timestamp.new seconds: now.to_i, nanos: now.nsec
  point.interval = Google::Cloud::Monitoring::V3::TimeInterval.new end_time: end_time
  series.points << point

  client.create_time_series name: project_name, time_series: [series]
  p "Time series created."
  # [END monitoring_write_timeseries]
end

def list_time_series project_id:
  # [START monitoring_read_timeseries_simple]
  # Your Google Cloud Platform project ID
  # project_id = "YOUR_PROJECT_ID"

  client = Google::Cloud::Monitoring.metric_service
  project_name = client.project_path project: project_id

  interval = Google::Cloud::Monitoring::V3::TimeInterval.new
  now = Time.now
  interval.end_time = Google::Protobuf::Timestamp.new seconds: now.to_i,
                                                      nanos:   now.nsec
  interval.start_time = Google::Protobuf::Timestamp.new seconds: now.to_i - 1200,
                                                        nanos:   now.nsec
  filter = 'metric.type = "compute.googleapis.com/instance/cpu/utilization"'
  view = Google::Cloud::Monitoring::V3::ListTimeSeriesRequest::TimeSeriesView::FULL

  results = client.list_time_series name:     project_name,
                                    filter:   filter,
                                    interval: interval,
                                    view:     view
  results.each do |result|
    p result
  end
  # [END monitoring_read_timeseries_simple]
end

def list_time_series_header project_id:
  # [START monitoring_read_timeseries_fields]
  # Your Google Cloud Platform project ID
  # project_id = "YOUR_PROJECT_ID"

  client = Google::Cloud::Monitoring.metric_service
  project_name = client.project_path project: project_id

  interval = Google::Cloud::Monitoring::V3::TimeInterval.new
  now = Time.now
  interval.end_time = Google::Protobuf::Timestamp.new seconds: now.to_i,
                                                      nanos:   now.nsec
  interval.start_time = Google::Protobuf::Timestamp.new seconds: now.to_i - 1200,
                                                        nanos:   now.nsec
  filter = 'metric.type = "compute.googleapis.com/instance/cpu/utilization"'
  view = Google::Cloud::Monitoring::V3::ListTimeSeriesRequest::TimeSeriesView::HEADERS

  results = client.list_time_series name:     project_name,
                                    filter:   filter,
                                    interval: interval,
                                    view:     view
  results.each do |result|
    p result
  end
  # [END monitoring_read_timeseries_fields]
end

def list_time_series_aggregate project_id:
  # [START monitoring_read_timeseries_align]
  # Your Google Cloud Platform project ID
  # project_id = "YOUR_PROJECT_ID"

  client = Google::Cloud::Monitoring.metric_service
  project_name = client.project_path project: project_id

  interval = Google::Cloud::Monitoring::V3::TimeInterval.new
  now = Time.now
  interval.end_time = Google::Protobuf::Timestamp.new seconds: now.to_i,
                                                      nanos:   now.nsec
  interval.start_time = Google::Protobuf::Timestamp.new seconds: now.to_i - 1200,
                                                        nanos:   now.nsec
  filter = 'metric.type = "compute.googleapis.com/instance/cpu/utilization"'
  view = Google::Cloud::Monitoring::V3::ListTimeSeriesRequest::TimeSeriesView::FULL
  aggregation = Google::Cloud::Monitoring::V3::Aggregation.new(
    alignment_period:   { seconds: 1200 },
    per_series_aligner: Google::Cloud::Monitoring::V3::Aggregation::Aligner::ALIGN_MEAN
  )

  results = client.list_time_series name:        project_name,
                                    filter:      filter,
                                    interval:    interval,
                                    view:        view,
                                    aggregation: aggregation
  results.each do |result|
    p result
  end

  # [END monitoring_read_timeseries_align]
end

def list_time_series_reduce project_id:
  # [START monitoring_read_timeseries_reduce]
  # Your Google Cloud Platform project ID
  # project_id = "YOUR_PROJECT_ID"

  client = Google::Cloud::Monitoring.metric_service
  project_name = client.project_path project: project_id

  interval = Google::Cloud::Monitoring::V3::TimeInterval.new
  now = Time.now
  interval.end_time = Google::Protobuf::Timestamp.new seconds: now.to_i,
                                                      nanos:   now.nsec
  interval.start_time = Google::Protobuf::Timestamp.new seconds: now.to_i - 1200,
                                                        nanos:   now.nsec
  filter = 'metric.type = "compute.googleapis.com/instance/cpu/utilization"'
  view = Google::Cloud::Monitoring::V3::ListTimeSeriesRequest::TimeSeriesView::FULL
  aggregation = Google::Cloud::Monitoring::V3::Aggregation.new(
    alignment_period:     { seconds: 1200 },
    per_series_aligner:   Google::Cloud::Monitoring::V3::Aggregation::Aligner::ALIGN_MEAN,
    cross_series_reducer: Google::Cloud::Monitoring::V3::Aggregation::Reducer::REDUCE_MEAN,
    group_by_fields:      ["resource.zone"]
  )

  results = client.list_time_series name:        project_name,
                                    filter:      filter,
                                    interval:    interval,
                                    view:        view,
                                    aggregation: aggregation
  results.each do |result|
    p result
  end

  # [END monitoring_read_timeseries_reduce]
end

def list_metric_descriptors project_id:
  # [START monitoring_list_descriptors]
  # Your Google Cloud Platform project ID
  # project_id = "YOUR_PROJECT_ID"

  client = Google::Cloud::Monitoring.metric_service
  project_name = client.project_path project: project_id

  results = client.list_metric_descriptors name: project_name
  results.each do |descriptor|
    p descriptor.type
  end
  # [END monitoring_list_descriptors]
end

def list_monitored_resources project_id:
  # [START monitoring_list_resources]
  # Your Google Cloud Platform project ID
  # project_id = "YOUR_PROJECT_ID"

  client = Google::Cloud::Monitoring.metric_service
  project_name = client.project_path project: project_id

  results = client.list_monitored_resource_descriptors name: project_name
  results.each do |descriptor|
    p descriptor.type
  end
  # [END monitoring_list_resources]
end

def get_monitored_resource_descriptor project_id:, resource_type:
  # [START monitoring_get_resource]
  # Your Google Cloud Platform project ID
  # project_id = "YOUR_PROJECT_ID"

  # The resource type
  # resource_type = "gce_instance"

  client = Google::Cloud::Monitoring.metric_service
  resource_path = client.monitored_resource_descriptor_path(
    project:                       project_id,
    monitored_resource_descriptor: resource_type
  )

  result = client.get_monitored_resource_descriptor name: resource_path
  p result
  # [END monitoring_get_resource]
end

def get_metric_descriptor project_id:, metric_type:
  # [START monitoring_get_descriptor]
  # Your Google Cloud Platform project ID
  # project_id = "YOUR_PROJECT_ID"

  # Example metric type
  # metric_type = "custom.googleapis.com/my_metric"

  client = Google::Cloud::Monitoring.metric_service
  metric_name = client.metric_descriptor_path project:           project_id,
                                              metric_descriptor: metric_type

  descriptor = client.get_metric_descriptor name: metric_name
  p descriptor
  # [END monitoring_get_descriptor]
end

if $PROGRAM_NAME == __FILE__
  case ARGV.shift
  when "create_metric_descriptor"
    create_metric_descriptor project_id: ARGV.shift, metric_type: ARGV.shift
  when "delete_metric_descriptor"
    delete_metric_descriptor project_id: ARGV.shift, metric_type: ARGV.shift
  when "write_time_series"
    write_time_series project_id: ARGV.shift
  when "list_time_series"
    list_time_series project_id: ARGV.shift
  when "list_time_series_header"
    list_time_series_header project_id: ARGV.shift
  when "list_time_series_aggregate"
    list_time_series_aggregate project_id: ARGV.shift
  when "list_time_series_reduce"
    list_time_series_reduce project_id: ARGV.shift
  when "list_metric_descriptors"
    list_metric_descriptors project_id: ARGV.shift
  when "list_monitored_resources"
    list_monitored_resources project_id: ARGV.shift
  when "get_monitored_resource_descriptor"
    get_monitored_resource_descriptor project_id: ARGV.shift, resource_type: ARGV.shift
  when "get_metric_descriptor"
    get_metric_descriptor project_id: ARGV.shift, metric_type: ARGV.shift
  else
    puts <<~USAGE
      Usage: bundle exec ruby metrics.rb [command] [arguments]

      Commands:
        create_metric_descriptor                     <project_id> <metric_type>
        delete_metric_descriptor                     <project_id> <metric_type>
        write_time_series                            <project_id>
        list_time_series                             <project_id>
        list_time_series_header                      <project_id>
        list_time_series_aggregate                   <project_id>
        list_time_series_reduce                      <project_id>
        list_metric_descriptors                      <project_id>
        list_monitored_resources                     <project_id>
        get_monitored_resource_descriptor            <project_id> <resource_type>
        get_metric_descriptor                        <project_id> <metric_type>
    USAGE
  end
end
