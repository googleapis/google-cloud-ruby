# Copyright 2015 Google LLC
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

describe Google::Cloud::Bigquery::Table, :copy_job, :updater, :mock_bigquery do
  let(:source_dataset) { "source_dataset" }
  let(:source_table_id) { "source_table_id" }
  let(:source_table_name) { "Source Table" }
  let(:source_description) { "This is the source table" }
  let(:source_table_gapi) { random_table_gapi source_dataset,
                                              source_table_id,
                                              source_table_name,
                                              source_description }
  let(:source_table) { Google::Cloud::Bigquery::Table.from_gapi source_table_gapi,
                                                         bigquery.service }
  let(:target_dataset) { "target_dataset" }
  let(:target_table_id) { "target_table_id" }
  let(:target_table_name) { "Target Table" }
  let(:target_description) { "This is the target table" }
  let(:target_table_gapi) { random_table_gapi target_dataset,
                                              target_table_id,
                                              target_table_name,
                                              target_description }
  let(:target_table) { Google::Cloud::Bigquery::Table.from_gapi target_table_gapi,
                                                         bigquery.service }
  let(:target_table_other_proj_gapi) { random_table_gapi target_dataset,
                                              target_table_id,
                                              target_table_name,
                                              target_description,
                                              "target-project" }
  let(:target_table_other_proj) { Google::Cloud::Bigquery::Table.from_gapi target_table_other_proj_gapi,
                                                         bigquery.service }
  let(:labels) { { "foo" => "bar" } }
  let(:kms_key) { "path/to/encryption_key_name" }
  let(:region) { "asia-northeast1" }

  it "sets a provided job_id prefix in the updater" do
    generated_id = "9876543210"
    prefix = "my_test_job_prefix_"
    job_id = prefix + generated_id

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = copy_job_gapi(source_table, target_table, job_id: job_id)

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = source_table.copy_job target_table, prefix: prefix do |j|
      j.job_id.must_equal job_id
    end

    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
    job.job_id.must_equal job_id
  end

  it "can copy itself with create disposition" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = copy_job_gapi(source_table, target_table)
    job_gapi.configuration.copy.create_disposition = "CREATE_NEVER"
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = source_table.copy_job target_table do |j|
      j.create = "CREATE_NEVER"
    end
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
  end

  it "can copy itself with create disposition symbol" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = copy_job_gapi(source_table, target_table)
    job_gapi.configuration.copy.create_disposition = "CREATE_NEVER"
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = source_table.copy_job target_table do |j|
      j.create = :never
    end
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
  end


  it "can copy itself with write disposition" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = copy_job_gapi(source_table, target_table)
    job_gapi.configuration.copy.write_disposition = "WRITE_TRUNCATE"
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = source_table.copy_job target_table do |j|
      j.write = "WRITE_TRUNCATE"
    end
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
  end

  it "can copy itself with write disposition symbol" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = copy_job_gapi(source_table, target_table)
    job_gapi.configuration.copy.write_disposition = "WRITE_TRUNCATE"
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = source_table.copy_job target_table do |j|
      j.write = :truncate
    end
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
  end

  it "can copy itself with the job labels option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = copy_job_gapi(source_table, target_table)
    job_gapi.configuration.labels = labels
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = source_table.copy_job target_table do |j|
      j.labels = labels
    end
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
    job.labels.must_equal labels
  end

  it "can copy itself with the encryption option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = copy_job_gapi(source_table, target_table)
    job_gapi.configuration.copy.destination_encryption_configuration = encryption_gapi(kms_key)

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    encrypt_config = bigquery.encryption kms_key: kms_key

    job = source_table.copy_job target_table do |j|
      j.encryption = encrypt_config
    end
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
    job.encryption.must_be_kind_of Google::Cloud::Bigquery::EncryptionConfiguration
    job.encryption.kms_key.must_equal kms_key
  end

  it "can copy itself with the location option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = copy_job_gapi(source_table, target_table)
    job_gapi.job_reference.location = region

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = source_table.copy_job target_table do |j|
      j.location = region
    end
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
    job.location.must_equal region
  end
end
