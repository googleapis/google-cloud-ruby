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

require "helper"

describe Gcloud::Logging::Project, :metrics, :mock_logging do
  it "lists metrics" do
    num_metrics = 3
    list_req = [Google::Logging::V2::ListLogMetricsRequest]
    list_res = Google::Logging::V2::ListLogMetricsResponse.decode_json(list_metrics_json(num_metrics))

    mock = Minitest::Mock.new
    mock.expect :list_log_metrics, list_res, list_req
    logging.service.metrics = mock

    metrics = logging.metrics

    mock.verify

    metrics.each { |m| m.must_be_kind_of Gcloud::Logging::Metric }
    metrics.size.must_equal num_metrics
  end

  it "lists metrics with find_metrics alias" do
    num_metrics = 3
    list_req = [Google::Logging::V2::ListLogMetricsRequest]
    list_res = Google::Logging::V2::ListLogMetricsResponse.decode_json(list_metrics_json(num_metrics))

    mock = Minitest::Mock.new
    mock.expect :list_log_metrics, list_res, list_req
    logging.service.metrics = mock

    metrics = logging.find_metrics

    mock.verify

    metrics.each { |m| m.must_be_kind_of Gcloud::Logging::Metric }
    metrics.size.must_equal num_metrics
  end

  it "paginates metrics" do
    first_list_req = Google::Logging::V2::ListLogMetricsRequest.new(project_name: project_path)
    first_list_res = Google::Logging::V2::ListLogMetricsResponse.decode_json(list_metrics_json(3, "next_page_token"))
    second_list_req = Google::Logging::V2::ListLogMetricsRequest.new(project_name: project_path, page_token: "next_page_token")
    second_list_res = Google::Logging::V2::ListLogMetricsResponse.decode_json(list_metrics_json(2))

    mock = Minitest::Mock.new
    mock.expect :list_log_metrics, first_list_res, [first_list_req]
    mock.expect :list_log_metrics, second_list_res, [second_list_req]
    logging.service.metrics = mock

    first_metrics = logging.metrics
    second_metrics = logging.metrics token: first_metrics.token

    mock.verify

    first_metrics.each { |m| m.must_be_kind_of Gcloud::Logging::Metric }
    first_metrics.count.must_equal 3
    first_metrics.token.wont_be :nil?
    first_metrics.token.must_equal "next_page_token"

    second_metrics.each { |m| m.must_be_kind_of Gcloud::Logging::Metric }
    second_metrics.count.must_equal 2
    second_metrics.token.must_be :nil?
  end

  it "paginates metrics with next? and next" do
    first_list_req = Google::Logging::V2::ListLogMetricsRequest.new(project_name: project_path)
    first_list_res = Google::Logging::V2::ListLogMetricsResponse.decode_json(list_metrics_json(3, "next_page_token"))
    second_list_req = Google::Logging::V2::ListLogMetricsRequest.new(project_name: project_path, page_token: "next_page_token")
    second_list_res = Google::Logging::V2::ListLogMetricsResponse.decode_json(list_metrics_json(2))

    mock = Minitest::Mock.new
    mock.expect :list_log_metrics, first_list_res, [first_list_req]
    mock.expect :list_log_metrics, second_list_res, [second_list_req]
    logging.service.metrics = mock

    first_metrics = logging.metrics
    second_metrics = first_metrics.next

    mock.verify

    first_metrics.each { |m| m.must_be_kind_of Gcloud::Logging::Metric }
    first_metrics.count.must_equal 3
    first_metrics.next?.must_equal true #must_be :next?

    second_metrics.each { |m| m.must_be_kind_of Gcloud::Logging::Metric }
    second_metrics.count.must_equal 2
    second_metrics.next?.must_equal false #wont_be :next?
  end

  it "paginates metrics with max set" do
    list_req = Google::Logging::V2::ListLogMetricsRequest.new(project_name: project_path, page_size: 3)
    list_res = Google::Logging::V2::ListLogMetricsResponse.decode_json(list_metrics_json(3, "next_page_token"))

    mock = Minitest::Mock.new
    mock.expect :list_log_metrics, list_res, [list_req]
    logging.service.metrics = mock

    metrics = logging.metrics max: 3

    mock.verify

    metrics.each { |m| m.must_be_kind_of Gcloud::Logging::Metric }
    metrics.count.must_equal 3
    metrics.token.wont_be :nil?
    metrics.token.must_equal "next_page_token"
  end

  it "paginates metrics without max set" do
    list_req = Google::Logging::V2::ListLogMetricsRequest.new(project_name: project_path)
    list_res = Google::Logging::V2::ListLogMetricsResponse.decode_json(list_metrics_json(3, "next_page_token"))

    mock = Minitest::Mock.new
    mock.expect :list_log_metrics, list_res, [list_req]
    logging.service.metrics = mock

    metrics = logging.metrics

    mock.verify

    metrics.each { |m| m.must_be_kind_of Gcloud::Logging::Metric }
    metrics.count.must_equal 3
    metrics.token.wont_be :nil?
    metrics.token.must_equal "next_page_token"
  end

  it "creates a metric" do
    new_metric_name = "new-metric-#{Time.now.to_i}"
    create_req = [Google::Logging::V2::CreateLogMetricRequest]
    create_res = Google::Logging::V2::LogMetric.decode_json(empty_metric_hash.merge("name" => new_metric_name).to_json)

    mock = Minitest::Mock.new
    mock.expect :create_log_metric, create_res, create_req
    logging.service.metrics = mock

    metric = logging.create_metric new_metric_name

    mock.verify

    metric.must_be_kind_of Gcloud::Logging::Metric
    metric.name.must_equal new_metric_name
    metric.description.must_be :empty?
    metric.filter.must_be :empty?
  end

  it "creates a metric with additional attributes" do
    new_metric_name = "new-metric-#{Time.now.to_i}"
    new_metric_description = "New Metric (#{Time.now.to_i})"
    new_metric_filter = "logName:syslog AND severity>=WARN"
    create_req = [Google::Logging::V2::CreateLogMetricRequest]
    create_res = Google::Logging::V2::LogMetric.decode_json(empty_metric_hash.merge("name" => new_metric_name,
                                                                                    "description" => new_metric_description,
                                                                                    "filter" => new_metric_filter).to_json)

    mock = Minitest::Mock.new
    mock.expect :create_log_metric, create_res, create_req
    logging.service.metrics = mock

    metric = logging.create_metric new_metric_name, description: new_metric_description,
      filter: new_metric_filter
    mock.verify

    metric.must_be_kind_of Gcloud::Logging::Metric
    metric.name.must_equal new_metric_name
    metric.description.must_equal new_metric_description
    metric.filter.must_equal new_metric_filter
  end

  it "gets a metric" do
    metric_name = "existing-metric-#{Time.now.to_i}"
    get_req = [Google::Logging::V2::GetLogMetricRequest]
    get_res = Google::Logging::V2::LogMetric.decode_json(random_metric_hash.merge("name" => metric_name).to_json)

    mock = Minitest::Mock.new
    mock.expect :get_log_metric, get_res, get_req
    logging.service.metrics = mock

    metric = logging.metric metric_name

    mock.verify

    metric.must_be_kind_of Gcloud::Logging::Metric
    metric.name.must_equal metric_name
  end

  it "returns nil when getting a metric that is not found" do
    metric_name = "not-found-metric-#{Time.now.to_i}"

    stub = Object.new
    def stub.get_log_metric *args
      raise GRPC::BadStatus.new 5, "not found"
    end
    logging.service.metrics = stub

    metric = logging.metric metric_name
    metric.must_be :nil?
  end

  def list_metrics_json count = 2, token = nil
    {
      metrics: count.times.map { random_metric_hash },
      next_page_token: token
    }.delete_if { |_, v| v.nil? }.to_json
  end

  def empty_metric_hash
    {
      "name"                => "",
      "description"         => "",
      "filter"              => ""
    }
  end
end
