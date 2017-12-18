# Copyright 2017 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a extract of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::BigQuery::Dataset, :query_job, :external, :mock_bigquery do
  let(:query) { "SELECT name, age, score, active, create_date, update_timestamp FROM my_csv" }
  let(:job_id) { "job_9876543210" }

  let(:dataset_id) { "my_dataset" }
  let(:dataset_gapi) { random_dataset_gapi dataset_id }
  let(:dataset) { Google::Cloud::BigQuery::Dataset.from_gapi dataset_gapi, bigquery.service }

  it "queries with external data" do
    job_gapi = query_job_gapi query
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(dataset_id: dataset_id, project_id: project)
    job_gapi.configuration.query.table_definitions = {
      "my_csv" => Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
        source_uris: ["gs://my-bucket/path/to/file.csv"],
        source_format: "CSV",
        csv_options: Google::Apis::BigqueryV2::CsvOptions.new()
      )
    }

    mock = Minitest::Mock.new
    dataset.service.mocked_service = mock

    mock.expect :insert_job, query_job_resp_gapi(query, job_id: job_id), [project, job_gapi]

    external_csv = dataset.external "gs://my-bucket/path/to/file.csv"
    job = dataset.query_job query, external: { my_csv: external_csv }
    mock.verify

    job.must_be_kind_of Google::Cloud::BigQuery::QueryJob
  end
end
