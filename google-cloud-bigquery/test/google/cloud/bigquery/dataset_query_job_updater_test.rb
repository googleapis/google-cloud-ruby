# Copyright 2015 Google LLC
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

describe Google::Cloud::Bigquery::Dataset, :query_job, :updater, :mock_bigquery do
  let(:query) { "SELECT name, age, score, active FROM `some_project.some_dataset.users`" }
  let(:dataset_id) { "my_dataset" }
  let(:dataset_gapi) { random_dataset_gapi dataset_id }
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi,
                                                      bigquery.service }
  let(:table_id) { "my_table" }
  let(:table_gapi) { random_table_gapi dataset_id, table_id }
  let(:table) { Google::Cloud::Bigquery::Table.from_gapi table_gapi,
                                                  bigquery.service }
  let(:labels) { { "foo" => "bar" } }
  let(:udfs) { [ "return x+1;", "gs://my-bucket/my-lib.js" ] }
  let(:kms_key) { "path/to/encryption_key_name" }

  it "queries the data with table options" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi(query)
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      project_id: project,
      dataset_id: dataset_id
    )
    job_gapi.configuration.query.destination_table = Google::Apis::BigqueryV2::TableReference.new(
      project_id: project,
      dataset_id: dataset_id,
      table_id:   table_id
    )
    job_gapi.configuration.query.create_disposition = "CREATE_NEVER"
    job_gapi.configuration.query.write_disposition = "WRITE_TRUNCATE"
    job_gapi.configuration.query.allow_large_results = true
    job_gapi.configuration.query.flatten_results = false
    job_gapi.configuration.query.maximum_bytes_billed = 12345678901234
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = dataset.query_job query do |j|
      j.table = table
      j.create = :never
      j.write = :truncate
      j.large_results = true
      j.flatten = false
      j.maximum_bytes_billed = 12345678901234
    end
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
  end

  it "queries the data with the job labels option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi query
    job_gapi.configuration.labels = labels
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      project_id: project,
      dataset_id: dataset_id
    )
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = dataset.query_job query do |j|
      j.labels = labels
    end
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
    job.labels.must_equal labels
  end

  it "queries the data with an array for the udfs option" do
    mock = Minitest::Mock.new
    dataset.service.mocked_service = mock

    job_gapi = query_job_gapi query
    job_gapi.configuration.query.user_defined_function_resources = udfs_gapi_array
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      project_id: project,
      dataset_id: dataset_id
    )
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = dataset.query_job query do |j|
      j.udfs = udfs
    end
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
    job.udfs.must_equal udfs
  end

  it "queries the data with a string for the udfs option" do
    mock = Minitest::Mock.new
    dataset.service.mocked_service = mock

    job_gapi = query_job_gapi query
    job_gapi.configuration.query.user_defined_function_resources = [udfs_gapi_uri]
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      project_id: project,
      dataset_id: dataset_id
    )
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = dataset.query_job query do |j|
      j.udfs = "gs://my-bucket/my-lib.js"
    end
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
    job.udfs.must_equal ["gs://my-bucket/my-lib.js"]
  end

  it "queries the data with the encryption option" do
    mock = Minitest::Mock.new
    dataset.service.mocked_service = mock

    job_gapi = query_job_gapi query
    job_gapi.configuration.query.destination_encryption_configuration = encryption_gapi(kms_key)
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
        project_id: project,
        dataset_id: dataset_id
    )
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    encrypt_config = bigquery.encryption kms_key: kms_key

    job = dataset.query_job query do |j|
      j.encryption = encrypt_config
    end
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::QueryJob
    job.encryption.must_be_kind_of Google::Cloud::Bigquery::EncryptionConfiguration
    job.encryption.kms_key.must_equal kms_key
  end
end
