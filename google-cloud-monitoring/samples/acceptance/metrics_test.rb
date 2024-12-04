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
require_relative "../metrics"

describe "metrics", :monitoring do
  let(:metric_type) { "custom.googleapis.com/my_metric_#{random_id}" }
  let(:metric_name) { client.metric_descriptor_path project: project_id, metric_descriptor: metric_type }

  describe "create_metric_descriptor" do
    after do
      client.delete_metric_descriptor name: metric_name
    rescue StandardError => e
      warn "Unexpectedly failed to delete newly created metric: #{e}"
    end

    it "creates a metric descriptor" do
      out, _err = capture_io do
        create_metric_descriptor project_id: project_id, metric_type: metric_type
      end
      assert_match(/Created #{metric_name}/, out)
    end
  end

  describe "delete_metric_descriptor" do
    it "deletes a metric descriptor" do
      descriptor = Google::Api::MetricDescriptor.new(
        type:        metric_type,
        metric_kind: Google::Api::MetricDescriptor::MetricKind::GAUGE,
        value_type:  Google::Api::MetricDescriptor::ValueType::DOUBLE,
        description: "This is a simple example of a custom metric."
      )
      client.create_metric_descriptor name: project_path, metric_descriptor: descriptor

      out, _err = capture_io do
        retry_block 3 do
          delete_metric_descriptor project_id: project_id, metric_type: metric_type
        end
      end
      assert_match(/Deleted metric descriptor #{metric_name}/, out)
    end
  end

  describe "list_metric_descriptors" do
    it "includes a standard metric in the list of all metric descriptors" do
      out, _err = capture_io do
        list_metric_descriptors project_id: project_id
      end
      assert_match %r{logging.googleapis.com/byte_count}, out
    end
  end

  describe "get_metric_descriptor" do
    it "gets a standard metric descriptor" do
      type = "logging.googleapis.com/byte_count"
      out, _err = capture_io do
        get_metric_descriptor project_id: project_id, metric_type: type
      end
      assert_match(/Total bytes of log entries/, out)
    end
  end

  describe "list_monitored_resources" do
    it "includes gce_instance in the list" do
      out, _err = capture_io do
        list_monitored_resources project_id: project_id
      end
      assert_match(/gce_instance/, out)
    end
  end

  describe "get_monitored_resource_descriptor" do
    it "gets the gce_instance descriptor" do
      out, _err = capture_io do
        get_monitored_resource_descriptor project_id: project_id, resource_type: "gce_instance"
      end
      assert_match(/VM Instance/, out)
    end
  end

  describe "write_time_series" do
    after do
      client.delete_metric_descriptor name: metric_name
    end

    it "writes time series data that can be read back" do
      start_secs = (Time.now - 2).to_i
      out, _err = capture_io do
        retry_block 3 do
          write_time_series project_id: project_id, metric_type: metric_type
        end
      end
      end_secs = (Time.now + 2).to_i
      assert_match(/Time series created/, out)

      filter = "metric.type = \"#{metric_type}\""
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
      assert_equal metric_type, received_time_series.metric.type
    end
  end

  describe "list_time_series" do
    it "runs without issue" do
      # The actual data returned is unknowable, but we can verify that the
      # call is made without incident.
      capture_io do
        list_time_series project_id: project_id
      end
    end
  end

  describe "list_time_series_header" do
    it "runs without issue" do
      # The actual data returned is unknowable, but we can verify that the
      # call is made without incident.
      capture_io do
        list_time_series_header project_id: project_id
      end
    end
  end

  describe "list_time_series_aggregate" do
    it "runs without issue" do
      # The actual data returned is unknowable, but we can verify that the
      # call is made without incident.
      capture_io do
        list_time_series_aggregate project_id: project_id
      end
    end
  end

  describe "list_time_series_reduce" do
    it "runs without issue" do
      # The actual data returned is unknowable, but we can verify that the
      # call is made without incident.
      capture_io do
        list_time_series_reduce project_id: project_id
      end
    end
  end
end
