# Copyright 2018 Google LLC
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

describe Google::Cloud::Bigquery::Project, :copy_job, :mock_bigquery do
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
  let(:region) { "asia-northeast1" }

  it "can copy" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = copy_job_gapi(source_table, target_table, location: nil)
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.copy_job source_table, target_table
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
  end

  it "can copy to a table identified by a string" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = copy_job_gapi(source_table, target_table_other_proj, location: nil)
    mock.expect :insert_job, job_gapi, ["test-project", job_gapi]

    job = bigquery.copy_job source_table, "target-project:target_dataset.target_table_id"
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
  end

  it "can copy to a dataset ID and table name string only" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    new_target_table = Google::Cloud::Bigquery::Table.from_gapi(
      random_table_gapi(source_dataset,
                        "new_target_table_id",
                        target_table_name,
                        target_description),
      bigquery.service
    )

    job_gapi = copy_job_gapi(source_table, new_target_table, location: nil)
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.copy_job source_table, "source_dataset.new_target_table_id"
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
  end

  it "can copy a table with create disposition" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = copy_job_gapi(source_table, target_table, location: nil)
    job_gapi.configuration.copy.create_disposition = "CREATE_NEVER"
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.copy_job source_table, target_table, create: "CREATE_NEVER"
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
  end

  it "can copy a table with create disposition symbol" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = copy_job_gapi(source_table, target_table, location: nil)
    job_gapi.configuration.copy.create_disposition = "CREATE_NEVER"
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.copy_job source_table, target_table, create: :never
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
  end


  it "can copy a table with write disposition" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = copy_job_gapi(source_table, target_table, location: nil)
    job_gapi.configuration.copy.write_disposition = "WRITE_TRUNCATE"
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.copy_job source_table, target_table, write: "WRITE_TRUNCATE"
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
  end

  it "can copy a table with write disposition symbol" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = copy_job_gapi(source_table, target_table, location: nil)
    job_gapi.configuration.copy.write_disposition = "WRITE_TRUNCATE"
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.copy_job source_table, target_table, write: :truncate
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
  end

  it "can copy a table with job_id option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_id = "my_test_job_id"
    job_gapi = copy_job_gapi(source_table, target_table, job_id: job_id, location: nil)

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.copy_job source_table, target_table, job_id: job_id
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
    job.job_id.must_equal job_id
  end

  it "can copy a table with prefix option" do
    generated_id = "9876543210"
    prefix = "my_test_job_prefix_"
    job_id = prefix + generated_id

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = copy_job_gapi(source_table, target_table, job_id: job_id, location: nil)

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.copy_job source_table, target_table, prefix: prefix
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
    job.job_id.must_equal job_id
  end

  it "can copy a table with job_id option if both job_id and prefix options are provided" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_id = "my_test_job_id"
    job_gapi = copy_job_gapi(source_table, target_table, job_id: job_id, location: nil)

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.copy_job source_table, target_table, job_id: job_id, prefix: "IGNORED"
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
    job.job_id.must_equal job_id
  end

  it "can copy a table with the job labels option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = copy_job_gapi(source_table, target_table, location: nil)
    job_gapi.configuration.labels = labels
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.copy_job source_table, target_table, labels: labels
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
    job.labels.must_equal labels
  end

  it "can copy a table with the location option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = copy_job_gapi(source_table, target_table, location: region)
    job_gapi.job_reference.location = region

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.copy_job source_table, target_table do |j|
      j.location = region
    end
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::CopyJob
    job.location.must_equal region
  end
end
