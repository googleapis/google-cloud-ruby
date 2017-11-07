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

require "google/cloud/bigquery"
require "google/cloud/storage"

module Google
  module Cloud
    module Bigquery
      def self.stub_new
        define_singleton_method :new do |*args|
          yield *args
        end
      end
      # Create default unmocked methods that will raise if ever called
      def self.new *args
        raise "This code example is not yet mocked"
      end
    end
    module Storage
      def self.stub_new
        define_singleton_method :new do |*args|
          yield *args
        end
      end
      # Create default unmocked methods that will raise if ever called
      def self.new *args
        raise "This code example is not yet mocked"
      end
    end
  end
end

def mock_bigquery
  Google::Cloud::Bigquery.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    bigquery = Google::Cloud::Bigquery::Project.new(Google::Cloud::Bigquery::Service.new("my-project-id", credentials))

    bigquery.service.mocked_service = Minitest::Mock.new
    yield bigquery.service.mocked_service
    bigquery
  end
end
def mock_storage
  Google::Cloud::Storage.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    storage = Google::Cloud::Storage::Project.new(Google::Cloud::Storage::Service.new("my-project-id", credentials))

    storage.service.mocked_service = Minitest::Mock.new
    yield storage.service.mocked_service
    storage
  end
end

YARD::Doctest.configure do |doctest|
  # Skip aliases
  doctest.skip "Google::Cloud::Bigquery::Dataset#refresh!"
  doctest.skip "Google::Cloud::Bigquery::Job#refresh!"
  doctest.skip "Google::Cloud::Bigquery::QueryJob#query_results"


  # Google::Cloud#bigquery@The default scope can be overridden with the `scope` option:
  doctest.before "Google::Cloud#bigquery" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :list_table_data, table_data_gapi.to_json, ["my-project-id", "my_dataset", "my_table", Hash]
    end
  end

  doctest.before "Google::Cloud.bigquery" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :list_table_data, table_data_gapi.to_json, ["my-project-id", "my_dataset", "my_table", Hash]
    end
  end

  doctest.before "Google::Cloud::Bigquery.new" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :list_table_data, table_data_gapi.to_json, ["my-project-id", "my_dataset", "my_table", Hash]
    end
  end

  # Google::Cloud::Bigquery::Data#all@Iterating each rows by passing a block:
  # Google::Cloud::Bigquery::Data#all@Limit the number of API calls made:
  # Google::Cloud::Bigquery::Data#all@Using the enumerator by not passing a block:
  # Google::Cloud::Bigquery::Data#next
  # Google::Cloud::Bigquery::Data#next?
  doctest.before "Google::Cloud::Bigquery::Data" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :list_table_data, table_data_gapi(token: nil).to_json, ["my-project-id", "my_dataset", "my_table", Hash]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Dataset" do
    mock_bigquery do |mock|
      mock.expect :insert_dataset, dataset_full_gapi, ["my-project-id", Google::Apis::BigqueryV2::Dataset]
    end
  end

  # Google::Cloud::Bigquery::Dataset#access@Manage the access rules by passing a block:
  doctest.before "Google::Cloud::Bigquery::Dataset#access" do
    mock_bigquery do |mock|
      def other_dataset_view_object
        "foo"
      end
      mock.expect :insert_dataset, dataset_full_gapi, ["my-project-id", Google::Apis::BigqueryV2::Dataset]
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :patch_dataset, dataset_full_gapi, ["my-project-id", "my_dataset", Google::Apis::BigqueryV2::Dataset, Hash]
    end
  end

  # Google::Cloud::Bigquery::Dataset#create_table@Or the table's schema can be configured with the block.
  # Google::Cloud::Bigquery::Dataset#create_table@The table's schema fields can be passed as an argument.
  # Google::Cloud::Bigquery::Dataset#create_table@You can also pass name and description options.
  # Google::Cloud::Bigquery::Dataset#create_table@You can define the schema using a nested block.
  doctest.before "Google::Cloud::Bigquery::Dataset#create_table" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :insert_table, table_full_gapi, ["my-project-id", "my_dataset", Google::Apis::BigqueryV2::Table]
    end
  end

  # Google::Cloud::Bigquery::Dataset#create_view@A name and description can be provided:
  doctest.before "Google::Cloud::Bigquery::Dataset#create_view" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :insert_table, table_full_gapi, ["my-project-id", "my_dataset", Google::Apis::BigqueryV2::Table]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Dataset#delete" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :delete_dataset, nil, ["my-project-id", "my_dataset", Hash]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Dataset#exists?" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
    end
  end

  # Google::Cloud::Bigquery::Dataset#query@Query using named query parameters:
  # Google::Cloud::Bigquery::Dataset#query@Query using positional query parameters:
  # Google::Cloud::Bigquery::Dataset#query@Query using standard SQL:
  doctest.before "Google::Cloud::Bigquery::Dataset#query" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
      mock.expect :get_job_query_results, query_data_gapi(token: nil), ["my-project-id", "1234567890", Hash]
      mock.expect :list_table_data, table_data_gapi(token: nil).to_json, ["my-project-id", "target_dataset_id", "target_table_id", Hash]
    end
  end

  # Google::Cloud::Bigquery::Dataset#query_job@Query using named query parameters:
  # Google::Cloud::Bigquery::Dataset#query_job@Query using positional query parameters:
  # Google::Cloud::Bigquery::Dataset#query_job@Query using standard SQL:
  doctest.before "Google::Cloud::Bigquery::Dataset#query_job" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
      mock.expect :get_job, query_job_gapi, ["my-project-id", "1234567890"]
      mock.expect :get_job_query_results, query_data_gapi, ["my-project-id", "1234567890", Hash]
      mock.expect :list_table_data, table_data_gapi(token: nil).to_json, ["my-project-id", "target_dataset_id", "target_table_id", Hash]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Dataset#table" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
    end
  end

  # Google::Cloud::Bigquery::Dataset#tables@Retrieve all tables: (See {Table::List#all})
  doctest.before "Google::Cloud::Bigquery::Dataset#tables" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :list_tables, list_tables_gapi, ["my-project-id", "my_dataset", Hash]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Dataset#labels" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :patch_dataset, dataset_full_gapi, ["my-project-id", "my_dataset", Google::Apis::BigqueryV2::Dataset, Hash]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Dataset#load" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Dataset#load_job@Upload a file directly:" do
    skip "This creates a File object, which is difficult to mock with doctest."
  end

  doctest.before "Google::Cloud::Bigquery::Dataset#load_job@Pass a google-cloud-storage `File` instance:" do
    mock_storage do |mock|
      mock.expect :get_bucket,  OpenStruct.new(name: "my-bucket"), ["my-bucket", Hash]
      mock.expect :get_object,  OpenStruct.new(bucket: "my-bucket", name: "path/to/audio.raw"), ["my-bucket", "file-name.csv", Hash]
    end
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Dataset#load@Upload a file directly:" do
    skip "This creates a File object, which is difficult to mock with doctest."
  end

  doctest.before "Google::Cloud::Bigquery::Dataset#load@Pass a google-cloud-storage `File` instance:" do
    mock_storage do |mock|
      mock.expect :get_bucket,  OpenStruct.new(name: "my-bucket"), ["my-bucket", Hash]
      mock.expect :get_object,  OpenStruct.new(bucket: "my-bucket", name: "path/to/audio.raw"), ["my-bucket", "file-name.csv", Hash]
    end
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Dataset#insert" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :insert_all_table_data,
                  Google::Apis::BigqueryV2::InsertAllTableDataResponse.new(insert_errors: []),
                  ["my-project-id", "my_dataset", "my_table", Google::Apis::BigqueryV2::InsertAllTableDataRequest]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Dataset#reference?" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Dataset#reload!" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Dataset#resource?" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Dataset#resource_full?" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Dataset#resource_partial?" do
    mock_bigquery do |mock|
      mock.expect :list_datasets, list_datasets_gapi, ["my-project-id", Hash]
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Dataset::Access" do
    mock_bigquery do |mock|
      def other_dataset_view_object
        "foo"
      end
      mock.expect :insert_dataset, dataset_full_gapi, ["my-project-id", Google::Apis::BigqueryV2::Dataset]
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_other_dataset"] # for view methods
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_view"] # for view methods
      mock.expect :patch_dataset, dataset_full_gapi, ["my-project-id", "my_dataset", Google::Apis::BigqueryV2::Dataset, Hash]
    end
  end

  # Google::Cloud::Bigquery::Dataset::List#all@Iterating each result by passing a block:
  # Google::Cloud::Bigquery::Dataset::List#all@Limit the number of API calls made:
  # Google::Cloud::Bigquery::Dataset::List#all@Using the enumerator by not passing a block:
  # Google::Cloud::Bigquery::Dataset::List#next
  # Google::Cloud::Bigquery::Dataset::List#next?
  doctest.before "Google::Cloud::Bigquery::Dataset::List" do
    mock_bigquery do |mock|
      mock.expect :list_datasets, list_datasets_gapi, ["my-project-id", Hash]
    end
  end

  doctest.before "Google::Cloud::Bigquery::CopyJob" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_destination_table"]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
    end
  end

  doctest.before "Google::Cloud::Bigquery::ExtractJob" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
    end
  end

  doctest.before "Google::Cloud::Bigquery::InsertResponse" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :insert_all_table_data,
                  Google::Apis::BigqueryV2::InsertAllTableDataResponse.new(insert_errors: []),
                  ["my-project-id", "my_dataset", "my_table", Google::Apis::BigqueryV2::InsertAllTableDataRequest]
    end
  end

  # Google::Cloud::Bigquery::Job
  # Google::Cloud::Bigquery::Job#wait_until_done!
  doctest.before "Google::Cloud::Bigquery::Job" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
      mock.expect :get_job_query_results, query_data_gapi, ["my-project-id", "1234567890", Hash]
      mock.expect :list_table_data, table_data_gapi(token: nil).to_json, ["my-project-id", "target_dataset_id", "target_table_id", Hash]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Job#cancel" do
    mock_bigquery do |mock|
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
      mock.expect :cancel_job, OpenStruct.new(job: query_job_gapi), ["my-project-id", "1234567890"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Job#rerun!" do
    mock_bigquery do |mock|
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Job#reload!" do
    mock_bigquery do |mock|
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
      mock.expect :get_job, query_job_gapi, ["my-project-id", "1234567890"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::LoadJob" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
    end
  end

  doctest.before "Google::Cloud::Bigquery::QueryJob" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
      mock.expect :get_job_query_results, query_data_gapi, ["my-project-id", "1234567890", Hash]
      mock.expect :list_table_data, table_data_gapi(token: nil).to_json, ["my-project-id", "target_dataset_id", "target_table_id", Hash]
    end
  end

  # Google::Cloud::Bigquery::Job::List#all@Iterating each job by passing a block:
  # Google::Cloud::Bigquery::Job::List#all@Limit the number of API calls made:
  # Google::Cloud::Bigquery::Job::List#all@Using the enumerator by not passing a block:
  # Google::Cloud::Bigquery::Job::List#next
  # Google::Cloud::Bigquery::Job::List#next?
  doctest.before "Google::Cloud::Bigquery::Job::List" do
    mock_bigquery do |mock|
      mock.expect :list_jobs, list_jobs_gapi, ["my-project-id", Hash]
    end
  end

  # Google::Cloud::Bigquery::Project#dataset
  # Google::Cloud::Bigquery::Project#job
  # Google::Cloud::Bigquery::Project#project
  doctest.before "Google::Cloud::Bigquery::Project" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :get_job, query_job_gapi, ["my-project-id", "my_job"]
    end
  end

  # Google::Cloud::Bigquery::Project#create_dataset
  # Google::Cloud::Bigquery::Project#create_dataset@A name and description can be provided:
  # Google::Cloud::Bigquery::Project#create_dataset@Access rules can be provided with the `access` option:
  # Google::Cloud::Bigquery::Project#create_dataset@Or, configure access with a block: (See {Dataset::Access})
  doctest.before "Google::Cloud::Bigquery::Project#create_dataset" do
    mock_bigquery do |mock|
      mock.expect :insert_dataset, dataset_full_gapi, ["my-project-id", Google::Apis::BigqueryV2::Dataset]
    end
  end

  # Google::Cloud::Bigquery::Project#datasets@Retrieve all datasets: (See {Dataset::List#all})
  # Google::Cloud::Bigquery::Project#datasets@Retrieve hidden datasets with the `all` optional arg:
  doctest.before "Google::Cloud::Bigquery::Project#datasets" do
    mock_bigquery do |mock|
      mock.expect :list_datasets, list_datasets_gapi, ["my-project-id", Hash]
    end
  end

  # Google::Cloud::Bigquery::Project#jobs@Retrieve all jobs: (See {Job::List#all})
  # Google::Cloud::Bigquery::Project#jobs@Retrieve only running jobs using the `filter` optional arg:
  doctest.before "Google::Cloud::Bigquery::Project#jobs" do
    mock_bigquery do |mock|
      mock.expect :list_jobs, list_jobs_gapi, ["my-project-id", Hash]
    end
  end

  # Google::Cloud::Bigquery::Project#projects@Retrieve all projects: (See {Project::List#all})
  doctest.before "Google::Cloud::Bigquery::Project#projects" do
    skip "This creates new Service objects, and we can't easily stub them out."
  end

  # Google::Cloud::Bigquery::Project#time
  # Google::Cloud::Bigquery::Project#time@Create Time with fractional seconds:
  doctest.before "Google::Cloud::Bigquery::Project#time" do
    mock_bigquery do |mock|
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
      mock.expect :get_job_query_results, query_data_gapi(token: nil), ["my-project-id", "1234567890", Hash]
      mock.expect :list_table_data, table_data_gapi(token: nil).to_json, ["my-project-id", "target_dataset_id", "target_table_id", Hash]
    end
  end

  # Google::Cloud::Bigquery::Project#query@Query using named query parameters:
  # Google::Cloud::Bigquery::Project#query@Query using positional query parameters:
  # Google::Cloud::Bigquery::Project#query@Query using standard SQL:
  # Google::Cloud::Bigquery::Project#query@Retrieve all rows: (See {Data#all})
  doctest.before "Google::Cloud::Bigquery::Project#query" do
    mock_bigquery do |mock|
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
      mock.expect :get_job_query_results, query_data_gapi(token: nil), ["my-project-id", "1234567890", Hash]
      mock.expect :list_table_data, table_data_gapi(token: nil).to_json, ["my-project-id", "target_dataset_id", "target_table_id", Hash]
    end
  end

  # Google::Cloud::Bigquery::Project#query_job@Query using named query parameters:
  # Google::Cloud::Bigquery::Project#query_job@Query using positional query parameters:
  # Google::Cloud::Bigquery::Project#query_job@Query using standard SQL:
  doctest.before "Google::Cloud::Bigquery::Project#query_job" do
    mock_bigquery do |mock|
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
      mock.expect :get_job, query_job_gapi, ["my-project-id", "1234567890"]
      mock.expect :get_job_query_results, query_data_gapi, ["my-project-id", "1234567890", Hash]
      mock.expect :list_table_data, table_data_gapi(token: nil).to_json, ["my-project-id", "target_dataset_id", "target_table_id", Hash]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Project#schema" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
    end
  end

  # Google::Cloud::Bigquery::Project::List#all@Iterating each result by passing a block:
  # Google::Cloud::Bigquery::Project::List#all@Limit the number of API calls made:
  # Google::Cloud::Bigquery::Project::List#all@Using the enumerator by not passing a block:
  # Google::Cloud::Bigquery::Project::List#next
  # Google::Cloud::Bigquery::Project::List#next?
  doctest.before "Google::Cloud::Bigquery::Project::List" do
    mock_bigquery do |mock|
      mock.expect :list_projects, list_projects_gapi, [Hash]
    end
  end

  # Google::Cloud::Bigquery::QueryJob#data
  doctest.before "Google::Cloud::Bigquery::QueryJob" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
      mock.expect :get_job_query_results, query_data_gapi(token: nil), ["my-project-id", "1234567890", Hash]
      mock.expect :list_table_data, table_data_gapi(token: nil).to_json, ["my-project-id", "target_dataset_id", "target_table_id", Hash]
    end
  end

  # Google::Cloud::Bigquery::Schema#record
  doctest.before "Google::Cloud::Bigquery::Schema" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :insert_table, table_full_gapi, ["my-project-id", "my_dataset", Google::Apis::BigqueryV2::Table]
      mock.expect :patch_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table", Google::Apis::BigqueryV2::Table, Hash]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Schema#field" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Schema::Field" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Schema::Field#record" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :insert_table, table_full_gapi, ["my-project-id", "my_dataset", Google::Apis::BigqueryV2::Table]
      mock.expect :patch_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table", Google::Apis::BigqueryV2::Table, Hash]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Table" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :insert_table, table_full_gapi, ["my-project-id", "my_dataset", Google::Apis::BigqueryV2::Table]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :list_table_data, table_data_gapi(token: nil).to_json, ["my-project-id", "my_dataset", "my_table", Hash]
      mock.expect :insert_all_table_data,
                  Google::Apis::BigqueryV2::InsertAllTableDataResponse.new(insert_errors: []),
                  ["my-project-id", "my_dataset", "my_table", Google::Apis::BigqueryV2::InsertAllTableDataRequest]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Table#copy" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_destination_table"]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
    end
  end

  # Google::Cloud::Bigquery::Table#copy_job@Passing a string identifier for the destination table:
  doctest.before "Google::Cloud::Bigquery::Table#copy_job" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_destination_table"]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
    end
  end

  # Google::Cloud::Bigquery::Table#data@Paginate rows of data: (See {Data#next})
  # Google::Cloud::Bigquery::Table#data@Retrieve all rows of data: (See {Data#all})
  doctest.before "Google::Cloud::Bigquery::Table#data" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :list_table_data, table_data_gapi(token: nil).to_json, ["my-project-id", "my_dataset", "my_table", Hash]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Table#delete" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :delete_table, nil, ["my-project-id", "my_dataset", "my_table"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Table#exists?" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Table#extract" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Table#insert" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :insert_all_table_data,
                  Google::Apis::BigqueryV2::InsertAllTableDataResponse.new(insert_errors: []),
                  ["my-project-id", "my_dataset", "my_table", Google::Apis::BigqueryV2::InsertAllTableDataRequest]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Table#labels=" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :patch_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table", Google::Apis::BigqueryV2::Table, Hash]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Table#load" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Table#load_job@Upload a file directly:" do
    skip "This creates a File object, which is difficult to mock with doctest."
  end

  doctest.before "Google::Cloud::Bigquery::Table#load_job@Pass a google-cloud-storage `File` instance:" do
    mock_storage do |mock|
      mock.expect :get_bucket,  OpenStruct.new(name: "my-bucket"), ["my-bucket", Hash]
      mock.expect :get_object,  OpenStruct.new(bucket: "my-bucket", name: "path/to/audio.raw"), ["my-bucket", "file-name.csv", Hash]
    end
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Table#load@Upload a file directly:" do
    skip "This creates a File object, which is difficult to mock with doctest."
  end

  doctest.before "Google::Cloud::Bigquery::Table#load@Pass a google-cloud-storage `File` instance:" do
    mock_storage do |mock|
      mock.expect :get_bucket,  OpenStruct.new(name: "my-bucket"), ["my-bucket", Hash]
      mock.expect :get_object,  OpenStruct.new(bucket: "my-bucket", name: "path/to/audio.raw"), ["my-bucket", "file-name.csv", Hash]
    end
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Table#query_id" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
      mock.expect :get_job_query_results, query_data_gapi(token: nil), ["my-project-id", "1234567890", Hash]
      mock.expect :list_table_data, table_data_gapi(token: nil).to_json, ["my-project-id", "target_dataset_id", "target_table_id", Hash]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Table#schema" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :insert_table, table_full_gapi, ["my-project-id", "my_dataset", Google::Apis::BigqueryV2::Table]
      mock.expect :patch_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table", Google::Apis::BigqueryV2::Table, Hash]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Table#reference?" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Table#reload!" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Table#resource?" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Table#resource_full?" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Table#resource_partial?" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :list_tables, list_tables_gapi, ["my-project-id", "my_dataset", Hash]
      mock.expect :get_table, table_full_gapi, ["my-project-id", "my_dataset", "my_table"]
    end
  end

  # Google::Cloud::Bigquery::Table::List#all@Iterating each result by passing a block:
  # Google::Cloud::Bigquery::Table::List#all@Limit the number of API requests made:
  # Google::Cloud::Bigquery::Table::List#all@Using the enumerator by not passing a block:
  # Google::Cloud::Bigquery::Table::List#next
  # Google::Cloud::Bigquery::Table::List#next?
  doctest.before "Google::Cloud::Bigquery::Table::List" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :list_tables, list_tables_gapi, ["my-project-id", "my_dataset", Hash]
    end
  end

  # Google::Cloud::Bigquery::Table::Updater#boolean
  # Google::Cloud::Bigquery::Table::Updater#float
  # Google::Cloud::Bigquery::Table::Updater#integer
  # Google::Cloud::Bigquery::Table::Updater#record
  # Google::Cloud::Bigquery::Table::Updater#schema
  # Google::Cloud::Bigquery::Table::Updater#string
  # Google::Cloud::Bigquery::Table::Updater#timestamp
  doctest.before "Google::Cloud::Bigquery::Table::Updater" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :insert_table, table_full_gapi, ["my-project-id", "my_dataset", Google::Apis::BigqueryV2::Table]
    end
  end

  # Google::Cloud::Bigquery::Time
  # Google::Cloud::Bigquery::Time@Create Time with fractional seconds:
  doctest.before "Google::Cloud::Bigquery::Time" do
    mock_bigquery do |mock|
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
      mock.expect :get_job_query_results, query_data_gapi(token: nil), ["my-project-id", "1234567890", Hash]
      mock.expect :list_table_data, table_data_gapi(token: nil).to_json, ["my-project-id", "target_dataset_id", "target_table_id", Hash]
    end
  end

  doctest.before "Google::Cloud::Bigquery::View" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :insert_table, view_full_gapi, ["my-project-id", "my_dataset", Google::Apis::BigqueryV2::Table]
      mock.expect :get_table, view_full_gapi, ["my-project-id", "my_dataset", "my_view"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::View#labels=" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, view_full_gapi, ["my-project-id", "my_dataset", "my_view"]
      mock.expect :patch_table, view_full_gapi, ["my-project-id", "my_dataset", "my_view", Google::Apis::BigqueryV2::Table, Hash]
      mock.expect :get_table, view_full_gapi, ["my-project-id", "my_dataset", "my_view"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::View#data" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, view_full_gapi, ["my-project-id", "my_dataset", "my_view"]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
      mock.expect :get_job_query_results, query_data_gapi(token: nil), ["my-project-id", "1234567890", Hash]
      mock.expect :list_table_data, table_data_gapi(token: nil).to_json, ["my-project-id", "target_dataset_id", "target_table_id", Hash]
    end
  end

  doctest.before "Google::Cloud::Bigquery::View#delete" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, view_full_gapi, ["my-project-id", "my_dataset", "my_view"]
      mock.expect :delete_table, nil, ["my-project-id", "my_dataset", "my_view"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::View#query=" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, view_full_gapi, ["my-project-id", "my_dataset", "my_view"]
      mock.expect :patch_table, view_full_gapi, ["my-project-id", "my_dataset", "my_view", Google::Apis::BigqueryV2::Table, Hash]
      mock.expect :get_table, view_full_gapi, ["my-project-id", "my_dataset", "my_view"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::View#set_query" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, view_full_gapi, ["my-project-id", "my_dataset", "my_view"]
      mock.expect :patch_table, view_full_gapi, ["my-project-id", "my_dataset", "my_view", Google::Apis::BigqueryV2::Table, Hash]
      mock.expect :get_table, view_full_gapi, ["my-project-id", "my_dataset", "my_view"]
    end
  end

  doctest.before "Google::Cloud::Bigquery::View#query_id" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :get_table, view_full_gapi, ["my-project-id", "my_dataset", "my_view"]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
      mock.expect :get_job_query_results, query_data_gapi(token: nil), ["my-project-id", "1234567890", Hash]
      mock.expect :list_table_data, table_data_gapi(token: nil).to_json, ["my-project-id", "target_dataset_id", "target_table_id", Hash]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Project#external" do
    mock_bigquery do |mock|
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
      mock.expect :get_job_query_results, query_data_gapi(token: nil), ["my-project-id", "1234567890", Hash]
      mock.expect :list_table_data, table_data_gapi(token: nil).to_json, ["my-project-id", "target_dataset_id", "target_table_id", Hash]
    end
  end

  doctest.before "Google::Cloud::Bigquery::Dataset#external" do
    mock_bigquery do |mock|
      mock.expect :get_dataset, dataset_full_gapi, ["my-project-id", "my_dataset"]
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
      mock.expect :get_job_query_results, query_data_gapi(token: nil), ["my-project-id", "1234567890", Hash]
      mock.expect :list_table_data, table_data_gapi(token: nil).to_json, ["my-project-id", "target_dataset_id", "target_table_id", Hash]
    end
  end

  doctest.before "Google::Cloud::Bigquery::External" do
    mock_bigquery do |mock|
      mock.expect :insert_job, query_job_gapi, ["my-project-id", Google::Apis::BigqueryV2::Job]
      mock.expect :get_job_query_results, query_data_gapi(token: nil), ["my-project-id", "1234567890", Hash]
      mock.expect :list_table_data, table_data_gapi(token: nil).to_json, ["my-project-id", "target_dataset_id", "target_table_id", Hash]
    end
  end
end

# Fixture helpers

def dataset_full_gapi project = "my-project-id"
  Google::Apis::BigqueryV2::Dataset.from_json random_dataset_hash(project).to_json
end

def random_dataset_hash project = "my-project-id", id = nil, name = nil, description = nil, default_expiration = nil, location = "US"
  id ||= "my_dataset"
  name ||= "My Dataset"
  description ||= "This is my dataset"
  default_expiration ||= "100" # String per google/google-api-ruby-client#439

  {
    "kind" => "bigquery#dataset",
    "etag" => "etag123456789",
    "id" => "id",
    "selfLink" => "http://googleapi/bigquery/v2/projects/#{project}/datasets/#{id}",
    "datasetReference" => {
      "datasetId" => id,
      "projectId" => project
    },
    "friendlyName" => name,
    "description" => description,
    "defaultTableExpirationMs" => default_expiration,
    "access" => [],
    "creationTime" => time_millis,
    "lastModifiedTime" => time_millis,
    "location" => location,
    "labels" => { "department" => "shipping" }
  }
end

def random_dataset_small_hash project = "my-project-id", id = nil, name = nil
  id ||= "my_dataset"
  name ||= "My Dataset"

  {
    "kind" => "bigquery#dataset",
    "id" => "#{project}:#{id}",
    "datasetReference" => {
      "datasetId" => id,
      "projectId" => project
    },
    "friendlyName" => name
  }
end

def list_datasets_gapi count = 2, token = nil
  datasets = count.times.map { random_dataset_small_hash }
  hash = {"kind"=>"bigquery#datasetList", "datasets"=>datasets}
  hash["nextPageToken"] = token unless token.nil?
  Google::Apis::BigqueryV2::DatasetList.from_json hash.to_json
end

def table_full_gapi
  Google::Apis::BigqueryV2::Table.from_json table_full_hash.to_json
end

def table_full_hash project = "my-project-id", dataset = "my_dataset", id = nil, name = nil, description = nil
  id ||= "my_table"
  name ||= "Table Name"

  {
    "kind" => "bigquery#table",
    "etag" => "etag123456789",
    "id" => "#{project}:#{dataset}.#{id}",
    "selfLink" => "http://googleapi/bigquery/v2/projects/#{project}/datasets/#{dataset}/tables/#{id}",
    "tableReference" => {
      "projectId" => project,
      "datasetId" => dataset,
      "tableId" => id
    },
    "friendlyName" => name,
    "description" => description,
    "schema" => {
      "fields" => [
        {
          "name" => "name",
          "type" => "STRING",
          "mode" => "REQUIRED"
        },
        {
          "name" => "age",
          "type" => "INTEGER"
        },
        {
          "name" => "score",
          "type" => "FLOAT",
          "description" => "A score from 0.0 to 10.0"
        },
        {
          "name" => "active",
          "type" => "BOOLEAN"
        }
      ]
    },
    "numBytes" => "1000", # String per google/google-api-ruby-client#439
    "numRows" => "100",   # String per google/google-api-ruby-client#439
    "creationTime" => time_millis,
    "expirationTime" => time_millis,
    "lastModifiedTime" => time_millis,
    "type" => "TABLE",
    "location" => "US",
    "labels" => { "department" => "shipping" }
  }
end

def random_table_small_hash project = "my-project-id", dataset = "my_dataset", id = nil, name = nil
  id ||= "my_table"
  name ||= "Table Name"

  {
    "kind" => "bigquery#table",
    "id" => "#{project}:#{dataset}.#{id}",
    "tableReference" => {
      "projectId" => project,
      "datasetId" => dataset,
      "tableId" => id
    },
    "friendlyName" => name,
    "type" => "TABLE"
  }
end

def view_full_gapi
  Google::Apis::BigqueryV2::Table.from_json view_full_hash.to_json
end

def view_full_hash project = "my-project-id", dataset = "my_dataset", id = nil, name = nil, description = nil
  id ||= "my_view"
  name ||= "View Name"

  hash = table_full_hash project, dataset, id, name, description
  hash["type"] = "VIEW"
  hash["view"] = { "query" => "SELECT name, age, score, active FROM `external.publicdata.users`" }
  hash
end

def table_data_gapi token: "token1234567890"
  Google::Apis::BigqueryV2::TableDataList.from_json table_data_hash(token: token).to_json
end

def list_tables_gapi project = "my-project-id", dataset = "my_dataset", count = 2, token = nil, total = nil
  tables = count.times.map { random_table_small_hash(dataset) }
  hash = {"kind" => "bigquery#tableList", "tables" => tables,
          "totalItems" => (total || count)}
  hash["nextPageToken"] = token unless token.nil?
  Google::Apis::BigqueryV2::TableList.from_json hash.to_json
end

def table_data_hash token: "token1234567890"
  {
    "kind" => "bigquery#tableDataList",
    "etag" => "etag1234567890",
    "rows" => [
      { "f" => [{ "v" => "Heidi" },
                { "v" => "36" },
                { "v" => "7.65" },
                { "v" => "true" }]
      }, {
      "f" => [{ "v" => "Aaron" },
              { "v" => "42" },
              { "v" => "8.15" },
              { "v" => "false" }]
      }, {
      "f" => [{ "v" => "Sally" },
              { "v" => nil },
              { "v" => nil },
              { "v" => nil }]
      }
    ],
    "pageToken" => token,
    "totalRows" => "3" # String per google/google-api-ruby-client#439
  }
end

def query_data_gapi token: "token1234567890"
  Google::Apis::BigqueryV2::QueryResponse.from_json query_data_hash(token: token).to_json
end

def query_data_hash token: "token1234567890"
  {
    "kind" => "bigquery#getQueryResultsResponse",
    "etag" => "etag1234567890",
    "jobReference" => {
      "projectId" => "my-project-id",
      "jobId" => "job9876543210"
    },
    "schema" => {
      "fields" => [
        {
          "name" => "name",
          "type" => "STRING",
          "mode" => "NULLABLE"
        },
        {
          "name" => "age",
          "type" => "INTEGER",
          "mode" => "NULLABLE"
        },
        {
          "name" => "score",
          "type" => "FLOAT",
          "mode" => "NULLABLE"
        },
        {
          "name" => "active",
          "type" => "BOOLEAN",
          "mode" => "NULLABLE"
        }
      ]
    },
    "rows" => [
      {
        "f" => [
          { "v" => "Heidi" },
          { "v" => "36" },
          { "v" => "7.65" },
          { "v" => "true" }
        ]
      },
      {
        "f" => [
          { "v" => "Aaron" },
          { "v" => "42" },
          { "v" => "8.15" },
          { "v" => "false" }
        ]
      },
      {
        "f" => [
          { "v" => "Sally" },
          { "v" => nil },
          { "v" => nil },
          { "v" => nil }
        ]
      }
    ],
    "pageToken" => token,
    "totalRows" => 3,
    "totalBytesProcessed" => "456789", # String per google/google-api-ruby-client#439
    "jobComplete" => true,
    "cacheHit" => false
  }
end

def query_job_gapi
  Google::Apis::BigqueryV2::Job.from_json query_job_hash.to_json
end

def query_job_hash
  hash = random_job_hash
  hash["configuration"]["query"] = {
    "query" => "SELECT name, age, score, active FROM `users`",
    "destinationTable" => {
      "projectId" => "target_project_id",
      "datasetId" => "target_dataset_id",
      "tableId"   => "target_table_id"
    },
    "tableDefinitions" => {},
    "createDisposition" => "CREATE_IF_NEEDED",
    "writeDisposition" => "WRITE_EMPTY",
    "defaultDataset" => {
      "datasetId" => "my_dataset",
      "projectId" => "my-project-id"
    },
    "priority" => "BATCH",
    "allowLargeResults" => true,
    "useQueryCache" => true,
    "flattenResults" => true,
    "useLegacySql" => nil
  }
  hash["statistics"]["query"] = {
    "cacheHit" => false,
    "totalBytesProcessed" => 123456,
    "queryPlan" => [
      {
        "steps" => [
          {
            "substeps" => [
              "select"
            ]
          }
        ]
      }
    ]
  }
  hash
end

def random_job_hash id = "1234567890", state = "done"
  {
    "kind" => "bigquery#job",
    "etag" => "etag",
    "id" => "my-project-id:#{id}",
    "selfLink" => "http://bigquery/projects/my-project-id/jobs/#{id}",
    "jobReference" => {
      "projectId" => "my-project-id",
      "jobId" => id
    },
    "configuration" => {
      # config call goes here
      "dryRun" => false
    },
    "status" => {
      "state" => state
    },
    "statistics" => {
      "creationTime" => time_millis,
      "startTime" => time_millis,
      "endTime" => time_millis
    },
    "user_email" => "user@example.com"
  }
end

def list_jobs_gapi count = 2, token = nil
  hash = {
    "kind" => "bigquery#jobList",
    "etag" => "etag",
    "jobs" => count.times.map { random_job_hash }
  }
  hash["nextPageToken"] = token unless token.nil?

  Google::Apis::BigqueryV2::JobList.from_json hash.to_json
end

def random_project_hash numeric_id = 1234567890, name = "project-name",
                        assigned_id = "project-id-12345"
  string_id = assigned_id || numeric_id.to_s
  {
    "kind" => "bigquery#project",
    "etag" => "etag",
    "id" => string_id,
    # TODO: remove `to_s` from next line after migrating to
    # google-api-client 0.10 (See google/google-api-ruby-client#439)
    "numericId" => numeric_id.to_s,
    "selfLink" => "http://bigquery/projects/#{string_id}",
    "projectReference" => {
      "projectId" => string_id
    },
    "friendlyName" => name
  }
end

def list_projects_gapi count = 2, token = nil
  hash = {
    "kind" => "bigquery#projectList",
    "etag" => "etag",
    "projects" => count.times.map { random_project_hash },
    "totalItems" => count
  }
  hash["nextPageToken"] = token unless token.nil?

  Google::Apis::BigqueryV2::ProjectList.from_json hash.to_json
end

def time_millis
  (Time.now.to_f * 1000).floor.to_s
end
