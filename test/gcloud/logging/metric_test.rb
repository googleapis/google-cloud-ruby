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

describe Gcloud::Logging::Metric, :mock_logging do
  let(:metric) { Gcloud::Logging::Metric.from_gapi metric_hash, logging.connection }
  let(:metric_hash) { random_metric_hash }

  it "knows its attributes" do
    metric.name.must_equal        metric_hash["name"]
    metric.description.must_equal metric_hash["description"]
    metric.filter.must_equal      metric_hash["filter"]
  end

  it "can save itself" do
    new_metric_description = "New Metric Description"
    new_metric_filter = "logName:syslog AND severity>=WARN"

    mock_connection.put "/v2beta1/projects/#{project}/metrics/#{metric.name}" do |env|
      metric_json = JSON.parse env.body
      metric_json["name"].must_equal metric.name
      metric_json["description"].must_equal new_metric_description
      metric_json["filter"].must_equal new_metric_filter

      [200, {"Content-Type"=>"application/json"},
       metric_json.to_json]
    end

    metric.description = new_metric_description
    metric.filter = new_metric_filter
    metric.save

    metric.must_be_kind_of Gcloud::Logging::Metric
    metric.description.must_equal new_metric_description
    metric.filter.must_equal new_metric_filter
  end

  it "can refresh itself" do
    mock_connection.get "/v2beta1/projects/#{project}/metrics/#{metric.name}" do |env|
      [200, {"Content-Type"=>"application/json"}, random_metric_hash.to_json]
    end

    metric.refresh!
  end

  it "can delete itself" do
    mock_connection.delete "/v2beta1/projects/#{project}/metrics/#{metric.name}" do |env|
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    metric.delete
  end
end
