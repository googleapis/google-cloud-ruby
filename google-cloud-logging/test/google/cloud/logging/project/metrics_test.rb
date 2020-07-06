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

require "helper"

describe Google::Cloud::Logging::Project, :metrics, :mock_logging do
  it "lists metrics" do
    num_metrics = 3
    list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogMetricsResponse.new(list_metrics_hash(num_metrics)))

    mock = Minitest::Mock.new
    mock.expect :list_log_metrics, list_res, [parent: project_path, page_size: nil, page_token: nil]
    logging.service.mocked_metrics = mock

    metrics = logging.metrics

    mock.verify

    metrics.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::Metric }
    _(metrics.size).must_equal num_metrics
  end

  it "lists metrics with find_metrics alias" do
    num_metrics = 3
    list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogMetricsResponse.new(list_metrics_hash(num_metrics)))

    mock = Minitest::Mock.new
    mock.expect :list_log_metrics, list_res, [parent: project_path, page_size: nil, page_token: nil]
    logging.service.mocked_metrics = mock

    metrics = logging.find_metrics

    mock.verify

    metrics.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::Metric }
    _(metrics.size).must_equal num_metrics
  end

  it "paginates metrics" do
    first_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogMetricsResponse.new(list_metrics_hash(3, "next_page_token")))
    second_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogMetricsResponse.new(list_metrics_hash(2)))

    mock = Minitest::Mock.new
    mock.expect :list_log_metrics, first_list_res, [parent: project_path, page_size: nil, page_token: nil]
    mock.expect :list_log_metrics, second_list_res, [parent: project_path, page_size: nil, page_token: "next_page_token"]
    logging.service.mocked_metrics = mock

    first_metrics = logging.metrics
    second_metrics = logging.metrics token: first_metrics.token

    mock.verify

    first_metrics.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::Metric }
    _(first_metrics.count).must_equal 3
    _(first_metrics.token).wont_be :nil?
    _(first_metrics.token).must_equal "next_page_token"

    second_metrics.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::Metric }
    _(second_metrics.count).must_equal 2
    _(second_metrics.token).must_be :nil?
  end

  it "paginates metrics with next? and next" do
    first_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogMetricsResponse.new(list_metrics_hash(3, "next_page_token")))
    second_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogMetricsResponse.new(list_metrics_hash(2)))

    mock = Minitest::Mock.new
    mock.expect :list_log_metrics, first_list_res, [parent: project_path, page_size: nil, page_token: nil]
    mock.expect :list_log_metrics, second_list_res, [parent: project_path, page_size: nil, page_token: "next_page_token"]
    logging.service.mocked_metrics = mock

    first_metrics = logging.metrics
    second_metrics = first_metrics.next

    mock.verify

    first_metrics.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::Metric }
    _(first_metrics.count).must_equal 3
    _(first_metrics.next?).must_equal true #must_be :next?

    second_metrics.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::Metric }
    _(second_metrics.count).must_equal 2
    _(second_metrics.next?).must_equal false #wont_be :next?
  end

  it "paginates metrics with next? and next and max set" do
    first_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogMetricsResponse.new(list_metrics_hash(3, "next_page_token")))
    second_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogMetricsResponse.new(list_metrics_hash(2, "second_page_token")))

    mock = Minitest::Mock.new
    mock.expect :list_log_metrics, first_list_res, [parent: project_path, page_size: 3, page_token: nil]
    mock.expect :list_log_metrics, second_list_res, [parent: project_path, page_size: 3, page_token: "next_page_token"]
    logging.service.mocked_metrics = mock

    first_metrics = logging.metrics max: 3
    second_metrics = first_metrics.next

    mock.verify

    first_metrics.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::Metric }
    _(first_metrics.count).must_equal 3
    _(first_metrics.next?).must_equal true
    _(first_metrics.token).must_equal "next_page_token"

    # ensure the correct values are propogated to the ivars
    _(first_metrics.instance_variable_get(:@max)).must_equal 3

    second_metrics.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::Metric }
    _(second_metrics.count).must_equal 2
    _(second_metrics.next?).must_equal true
    _(second_metrics.token).must_equal "second_page_token"

    # ensure the correct values are propogated to the ivars
    _(second_metrics.instance_variable_get(:@max)).must_equal 3
  end

  it "paginates metrics with all" do
    first_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogMetricsResponse.new(list_metrics_hash(3, "next_page_token")))
    second_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogMetricsResponse.new(list_metrics_hash(2)))

    mock = Minitest::Mock.new
    mock.expect :list_log_metrics, first_list_res, [parent: project_path, page_size: nil, page_token: nil]
    mock.expect :list_log_metrics, second_list_res, [parent: project_path, page_size: nil, page_token: "next_page_token"]
    logging.service.mocked_metrics = mock

    all_metrics = logging.metrics.all.to_a

    mock.verify

    all_metrics.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::Metric }
    _(all_metrics.count).must_equal 5
  end

  it "paginates metrics with all and max set" do
    first_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogMetricsResponse.new(list_metrics_hash(3, "next_page_token")))
    second_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogMetricsResponse.new(list_metrics_hash(2)))

    mock = Minitest::Mock.new
    mock.expect :list_log_metrics, first_list_res, [parent: project_path, page_size: 3, page_token: nil]
    mock.expect :list_log_metrics, second_list_res, [parent: project_path, page_size: 3, page_token: "next_page_token"]
    logging.service.mocked_metrics = mock

    all_metrics = logging.metrics(max: 3).all.to_a

    mock.verify

    all_metrics.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::Metric }
    _(all_metrics.count).must_equal 5
  end

  it "iterates metrics with all using Enumerator" do
    first_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogMetricsResponse.new(list_metrics_hash(3, "next_page_token")))
    second_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogMetricsResponse.new(list_metrics_hash(3, "second_page_token")))

    mock = Minitest::Mock.new
    mock.expect :list_log_metrics, first_list_res, [parent: project_path, page_size: nil, page_token: nil]
    mock.expect :list_log_metrics, second_list_res, [parent: project_path, page_size: nil, page_token: "next_page_token"]
    logging.service.mocked_metrics = mock

    all_metrics = logging.metrics.all.take(5)

    mock.verify

    all_metrics.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::Metric }
    _(all_metrics.count).must_equal 5
  end

  it "iterates metrics with all request_limit set" do
    first_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogMetricsResponse.new(list_metrics_hash(3, "next_page_token")))
    second_list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogMetricsResponse.new(list_metrics_hash(3, "second_page_token")))

    mock = Minitest::Mock.new
    mock.expect :list_log_metrics, first_list_res, [parent: project_path, page_size: nil, page_token: nil]
    mock.expect :list_log_metrics, second_list_res, [parent: project_path, page_size: nil, page_token: "next_page_token"]
    logging.service.mocked_metrics = mock

    all_metrics = logging.metrics.all(request_limit: 1).to_a

    mock.verify

    all_metrics.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::Metric }
    _(all_metrics.count).must_equal 6
  end

  it "paginates metrics with max set" do
    list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogMetricsResponse.new(list_metrics_hash(3, "next_page_token")))

    mock = Minitest::Mock.new
    mock.expect :list_log_metrics, list_res, [parent: project_path, page_size: 3, page_token: nil]
    logging.service.mocked_metrics = mock

    metrics = logging.metrics max: 3

    mock.verify

    metrics.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::Metric }
    _(metrics.count).must_equal 3
    _(metrics.token).wont_be :nil?
    _(metrics.token).must_equal "next_page_token"
  end

  it "paginates metrics without max set" do
    list_res = OpenStruct.new(response: Google::Cloud::Logging::V2::ListLogMetricsResponse.new(list_metrics_hash(3, "next_page_token")))

    mock = Minitest::Mock.new
    mock.expect :list_log_metrics, list_res, [parent: project_path, page_size: nil, page_token: nil]
    logging.service.mocked_metrics = mock

    metrics = logging.metrics

    mock.verify

    metrics.each { |m| _(m).must_be_kind_of Google::Cloud::Logging::Metric }
    _(metrics.count).must_equal 3
    _(metrics.token).wont_be :nil?
    _(metrics.token).must_equal "next_page_token"
  end

  it "creates a metric" do
    new_metric_name = "new-metric-#{Time.now.to_i}"
    new_metric_filter = "logName:syslog AND severity>=WARN"
    new_metric = Google::Cloud::Logging::V2::LogMetric.new(
        name: new_metric_name,
        filter: new_metric_filter
      )
    create_res = Google::Cloud::Logging::V2::LogMetric.new(empty_metric_hash.merge(name: new_metric_name,
                                                                            filter: new_metric_filter))

    mock = Minitest::Mock.new
    mock.expect :create_log_metric, create_res, [parent: "projects/test", metric: new_metric]
    logging.service.mocked_metrics = mock

    metric = logging.create_metric new_metric_name, new_metric_filter

    mock.verify

    _(metric).must_be_kind_of Google::Cloud::Logging::Metric
    _(metric.name).must_equal new_metric_name
    _(metric.filter).must_equal new_metric_filter
    _(metric.description).must_be :empty?

  end

  it "creates a metric with description" do
    new_metric_name = "new-metric-#{Time.now.to_i}"
    new_metric_filter = "logName:syslog AND severity>=WARN"
    new_metric_description = "New Metric (#{Time.now.to_i})"
    new_metric = Google::Cloud::Logging::V2::LogMetric.new(
      name: new_metric_name,
      description: new_metric_description,
      filter: new_metric_filter
    )
    create_res = Google::Cloud::Logging::V2::LogMetric.new(empty_metric_hash.merge(name: new_metric_name,
                                                                            description: new_metric_description,
                                                                            filter: new_metric_filter))

    mock = Minitest::Mock.new
    mock.expect :create_log_metric, create_res, [parent: "projects/test", metric: new_metric]
    logging.service.mocked_metrics = mock

    metric = logging.create_metric new_metric_name, new_metric_filter, description: new_metric_description
    mock.verify

    _(metric).must_be_kind_of Google::Cloud::Logging::Metric
    _(metric.name).must_equal new_metric_name
    _(metric.filter).must_equal new_metric_filter
    _(metric.description).must_equal new_metric_description
  end

  it "gets a metric" do
    metric_name = "existing-metric-#{Time.now.to_i}"
    get_res = Google::Cloud::Logging::V2::LogMetric.new(random_metric_hash.merge(name: metric_name))

    mock = Minitest::Mock.new
    mock.expect :get_log_metric, get_res, [metric_name: "projects/test/metrics/#{metric_name}"]
    logging.service.mocked_metrics = mock

    metric = logging.metric metric_name

    mock.verify

    _(metric).must_be_kind_of Google::Cloud::Logging::Metric
    _(metric.name).must_equal metric_name
  end

  it "returns nil when getting a metric that is not found" do
    metric_name = "not-found-metric-#{Time.now.to_i}"

    stub = Object.new
    def stub.get_log_metric *args
      error = Google::Cloud::NotFoundError.new "not found"
      error.instance_variable_set :@cause, GRPC::BadStatus.new(5, "not found")
      raise error
    end
    logging.service.mocked_metrics = stub

    metric = logging.metric metric_name
    _(metric).must_be :nil?
  end

  def list_metrics_hash count = 2, token = nil
    {
      metrics: count.times.map { random_metric_hash },
      next_page_token: token
    }.delete_if { |_, v| v.nil? }
  end

  def empty_metric_hash
    {
      name:        "",
      description: "",
      filter:      ""
    }
  end
end
