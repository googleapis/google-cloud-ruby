# Copyright 2017 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a extract of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Bigquery::Project, :query, :external, :mock_bigquery do
  let(:query) { "SELECT name, age, score, active, create_date, update_timestamp FROM my_csv" }
  let(:job_id) { "job_9876543210" }

  let(:dataset_id) { "my_dataset" }
  let(:dataset_gapi) { random_dataset_gapi dataset_id }
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi, bigquery.service }

  it "queries with external data" do
    job_gapi = query_job_gapi query, location: nil
    job_gapi.configuration.query.table_definitions = {
      "my_csv" => Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
        source_uris: ["gs://my-bucket/path/to/file.csv"],
        source_format: "CSV",
        csv_options: Google::Apis::BigqueryV2::CsvOptions.new()
      )
    }

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]
    mock.expect :get_job_query_results,
                query_data_gapi,
                [project, job_id], location: "US", max_results: 0, page_token: nil, start_index: nil, timeout_ms: nil
    mock.expect :list_table_data,
                table_data_gapi.to_json,
                [project, "target_dataset_id", "target_table_id"], max_results: nil, page_token: nil, start_index: nil, options: {skip_deserialization: true}

    external_csv = bigquery.external "gs://my-bucket/path/to/file.csv"
    data = bigquery.query query, external: { my_csv: external_csv }
    mock.verify

    _(data.class).must_equal Google::Cloud::Bigquery::Data
    assert_valid_data data
  end

  def assert_valid_data data
    _(data.count).must_equal 3
    _(data[0]).must_be_kind_of Hash
    _(data[0][:name]).must_equal "Heidi"
    _(data[0][:age]).must_equal 36
    _(data[0][:score]).must_equal 7.65
    _(data[0][:active]).must_equal true
    _(data[1]).must_be_kind_of Hash
    _(data[1][:name]).must_equal "Aaron"
    _(data[1][:age]).must_equal 42
    _(data[1][:score]).must_equal 8.15
    _(data[1][:active]).must_equal false
    _(data[2]).must_be_kind_of Hash
    _(data[2][:name]).must_equal "Sally"
    _(data[2][:age]).must_be :nil?
    _(data[2][:score]).must_be :nil?
    _(data[2][:active]).must_be :nil?
  end
end
