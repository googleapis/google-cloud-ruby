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

require_relative "helper"
require_relative "../quickstart.rb"

describe "quickstart", :monitoring do
  it "writes time series data that can be read back" do
    start_secs = (Time.now - 2).to_i
    out, _err = capture_io do
      quickstart project_id: project_id, metric_label: random_id
    end
    end_secs = (Time.now + 2).to_i
    assert_match(/Successfully wrote time series/, out)

    filter = 'metric.type = "custom.googleapis.com/my_metric" AND ' \
             "metric.labels.my_key = #{random_id.inspect}"
    start_time = Google::Protobuf::Timestamp.new seconds: start_secs
    end_time = Google::Protobuf::Timestamp.new seconds: end_secs
    interval = Google::Cloud::Monitoring::V3::TimeInterval.new start_time: start_time, end_time: end_time
    view = Google::Cloud::Monitoring::V3::ListTimeSeriesRequest::TimeSeriesView::FULL

    received_time_series = retry_block 3 do
      response = client.list_time_series name:     project_path,
                                         filter:   filter,
                                         interval: interval,
                                         view:     view
      response = response.to_a
      raise "Time series not returned" if response.empty?
      response.first
    end

    assert_equal 1, received_time_series.points.size
    assert_equal 3.14, received_time_series.points.first.value.double_value
    assert_equal random_id, received_time_series.metric.labels["my_key"]
  end
end
