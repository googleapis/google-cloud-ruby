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

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "ostruct"
require "json"
require "base64"
require "google/cloud/bigquery"
require "google/cloud/storage"

##
# Monkey-Patch Google API Client to support Mocks
module Google::Apis::Core::Hashable
  ##
  # Minitest Mock depends on === to match same-value objects.
  # By default, the Google API Client objects do not match with ===.
  # Therefore, we must add this capability.
  # This module seems like as good a place as any...
  def === other
    return(to_h === other.to_h) if other.respond_to? :to_h
    super
  end
end

class MockBigquery < Minitest::Spec
  let(:project) { bigquery.service.project }
  let(:credentials) { bigquery.service.credentials }
  let(:bigquery) { Google::Cloud::Bigquery::Project.new(Google::Cloud::Bigquery::Service.new("test-project", OpenStruct.new)) }

  # Register this spec type for when :mock_bigquery is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_bigquery
  end

  ##
  # Time in milliseconds as a string, per google/google-api-ruby-client#439
  def time_millis
    (::Time.now.to_f * 1000).floor.to_s
  end

  def random_dataset_gapi id = nil, name = nil, description = nil, default_expiration = nil, location = "US"
    json = random_dataset_hash(id, name, description, default_expiration, location).to_json
    Google::Apis::BigqueryV2::Dataset.from_json json
  end

  def random_dataset_hash id = nil, name = nil, description = nil, default_expiration = nil, location = "US"
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
      "location" => location
    }
  end

  def random_dataset_small_hash id = nil, name = nil
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

  def random_schema_hash
    {
      "fields" => [
        {
          "name" => "name",
          "type" => "STRING",
          "mode" => "REQUIRED"
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
        },
        {
          "name" => "avatar",
          "type" => "BYTES",
          "mode" => "NULLABLE"
        },
        {
          "name" => "started_at",
          "type" => "TIMESTAMP",
          "mode" => "NULLABLE"
        },
        {
          "name" => "duration",
          "type" => "TIME",
          "mode" => "NULLABLE"
        },
        {
          "name" => "target_end",
          "type" => "DATETIME",
          "mode" => "NULLABLE"
        },
        {
          "name" => "birthday",
          "type" => "DATE",
          "mode" => "NULLABLE"
        }
      ]
    }
  end

  def random_data_rows
    [
      {
        "f" => [
          { "v" => "Heidi" },
          { "v" => "36" },
          { "v" => "7.65" },
          { "v" => "true" },
          { "v" => "aW1hZ2UgZGF0YQ==" },
          { "v" => "1482670800.0" },
          { "v" => "04:00:00" },
          { "v" => "2017-01-01 00:00:00" },
          { "v" => "1968-10-20" }
        ]
      },
      {
        "f" => [
          { "v" => "Aaron" },
          { "v" => "42" },
          { "v" => "8.15" },
          { "v" => "false" },
          { "v" => nil },
          { "v" => nil },
          { "v" => "04:32:10.555555" },
          { "v" => nil },
          { "v" => nil }
        ]
      },
      {
        "f" => [
          { "v" => "Sally" },
          { "v" => nil },
          { "v" => nil },
          { "v" => nil },
          { "v" => nil },
          { "v" => nil },
          { "v" => nil },
          { "v" => nil },
          { "v" => nil }
        ]
      }
    ]
  end

  def random_table_gapi dataset, id = nil, name = nil, description = nil, project_id = nil
    json = random_table_hash(dataset, id, name, description, project_id).to_json
    Google::Apis::BigqueryV2::Table.from_json json
  end

  def random_table_hash dataset, id = nil, name = nil, description = nil, project_id = nil
    id ||= "my_table"
    name ||= "Table Name"

    {
      "kind" => "bigquery#table",
      "etag" => "etag123456789",
      "id" => "#{project}:#{dataset}.#{id}",
      "selfLink" => "http://googleapi/bigquery/v2/projects/#{project}/datasets/#{dataset}/tables/#{id}",
      "tableReference" => {
        "projectId" => (project_id || project),
        "datasetId" => dataset,
        "tableId" => id
      },
      "friendlyName" => name,
      "description" => description,
      "schema" => random_schema_hash,
      "numBytes" => "1000", # String per google/google-api-ruby-client#439
      "numRows" => "100",   # String per google/google-api-ruby-client#439
      "creationTime" => time_millis,
      "expirationTime" => time_millis,
      "lastModifiedTime" => time_millis,
      "type" => "TABLE",
      "location" => "US"
    }
  end

  def random_table_small_hash dataset, id = nil, name = nil
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

  def source_table_gapi
    Google::Apis::BigqueryV2::Table.from_json source_table_json
  end

  def source_table_json
    hash = random_table_hash "getting_replaced_dataset_id"
    hash["tableReference"] = {
      "projectId" => "source_project_id",
      "datasetId" => "source_dataset_id",
      "tableId"   => "source_table_id"
    }
    hash.to_json
  end

  def destination_table_gapi
    Google::Apis::BigqueryV2::Table.from_json destination_table_json
  end

  def destination_table_json
    hash = random_table_hash "getting_replaced_dataset_id"
    hash["tableReference"] = {
      "projectId" => "target_project_id",
      "datasetId" => "target_dataset_id",
      "tableId"   => "target_table_id"
    }
    hash.to_json
  end

  def random_view_gapi dataset, id = nil, name = nil, description = nil
    json = random_view_hash(dataset, id, name, description).to_json
    Google::Apis::BigqueryV2::Table.from_json json
  end

  def random_view_hash dataset, id = nil, name = nil, description = nil
    id ||= "my_view"
    name ||= "View Name"

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
      "schema" => random_schema_hash,
      "creationTime" => time_millis,
      "expirationTime" => time_millis,
      "lastModifiedTime" => time_millis,
      "type" => "VIEW",
      "view" => {
        "query" => "SELECT name, age, score, active FROM `external:publicdata.users`"
      },
      "location" => "US"
    }
  end

  def random_view_small_hash dataset, id = nil, name = nil
    id ||= "my_view"
    name ||= "View Name"

    {
      "kind" => "bigquery#table",
      "id" => "#{project}:#{dataset}.#{id}",
      "tableReference" => {
        "projectId" => project,
        "datasetId" => dataset,
        "tableId" => id
      },
      "friendlyName" => name,
      "type" => "VIEW"
    }
  end

  def random_job_hash id = "1234567890", state = "running"
    {
      "kind" => "bigquery#job",
      "etag" => "etag",
      "id" => "#{project}:#{id}",
      "selfLink" => "http://bigquery/projects/#{project}/jobs/#{id}",
      "jobReference" => {
        "projectId" => project,
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
      "selfLink" => "http://bigquery/projects/#{project}",
      "projectReference" => {
        "projectId" => string_id
      },
      "friendlyName" => name
    }
  end

  def find_job_gapi job_id
    Google::Apis::BigqueryV2::Job.from_json random_job_hash(job_id).to_json
  end

  def job_resp_gapi job_gapi, job_id: "job9876543210"
    job_gapi = job_gapi.dup
    job_gapi.job_reference = Google::Apis::BigqueryV2::JobReference.new(
      project_id: project,
      job_id: job_id
    )
    job_gapi
  end



  def query_job_resp_gapi query, job_id: job_id
    Google::Apis::BigqueryV2::Job.from_json query_job_resp_json(query, job_id: job_id)
  end

  def query_job_resp_json query, job_id: "job9876543210"
    hash = random_job_hash(job_id, "done")
    hash["configuration"]["query"] = {
      "query" => query,
      "destinationTable" => {
        "projectId" => project,
        "datasetId" => "target_dataset_id",
        "tableId"   => "target_table_id"
      },
      "tableDefinitions" => {},
      "createDisposition" => "CREATE_IF_NEEDED",
      "writeDisposition" => "WRITE_EMPTY",
      "defaultDataset" => {
        "datasetId" => "my_dataset",
        "projectId" => project
      },
      "priority" => "BATCH",
      "allowLargeResults" => true,
      "useQueryCache" => true,
      "flattenResults" => true,
      "useLegacySql" => false,
      "maximumBillingTier" => nil,
      "maximumBytesBilled" => nil
    }
    hash.to_json
  end

  def query_job_gapi query, parameter_mode: nil
    gapi = Google::Apis::BigqueryV2::Job.from_json query_job_json(query)
    gapi.configuration.query.parameter_mode = parameter_mode if parameter_mode
    gapi
  end

  def query_job_json query
    {
      "configuration" => {
        "query" => {
          "query" => query,
          "defaultDataset" => nil,
          "destinationTable" => nil,
          "createDisposition" => nil,
          "writeDisposition" => nil,
          "priority" => "INTERACTIVE",
          "allowLargeResults" => nil,
          "useQueryCache" => true,
          "flattenResults" => nil,
          "useLegacySql" => false,
          "maximumBillingTier" => nil,
          "maximumBytesBilled" => nil
        }
      }
    }.to_json
  end

  def query_request_gapi
    Google::Apis::BigqueryV2::QueryRequest.new(
      default_dataset: Google::Apis::BigqueryV2::DatasetReference.new(
        dataset_id: "my_dataset", project_id: "test-project"
      ),
      dry_run: nil,
      max_results: nil,
      query: "SELECT * FROM `some_project.some_dataset.users`",
      timeout_ms: 10000,
      use_query_cache: true,
      use_legacy_sql: false,
    )
  end

  def query_data_gapi token: "token1234567890"
    Google::Apis::BigqueryV2::QueryResponse.from_json query_data_hash(token: token).to_json
  end

  def query_data_hash token: "token1234567890"
    {
      "kind" => "bigquery#getQueryResultsResponse",
      "etag" => "etag1234567890",
      "jobReference" => {
        "projectId" => project,
        "jobId" => "job9876543210"
      },
      "schema" => random_schema_hash,
      "rows" => random_data_rows,
      "pageToken" => token,
      "totalRows" => 3,
      "totalBytesProcessed" => "456789", # String per google/google-api-ruby-client#439
      "jobComplete" => true,
      "cacheHit" => false
    }
  end

  def table_data_gapi token: "token1234567890"
    Google::Apis::BigqueryV2::TableDataList.from_json table_data_hash(token: token).to_json
  end

  def table_data_hash token: "token1234567890"
    {
      "kind" => "bigquery#tableDataList",
      "etag" => "etag1234567890",
      "rows" => random_data_rows,
      "pageToken" => token,
      "totalRows" => "3" # String per google/google-api-ruby-client#439
    }
  end

  def nil_table_data_gapi
    Google::Apis::BigqueryV2::TableDataList.from_json nil_table_data_json
  end

  def nil_table_data_json
    h = table_data_hash
    h.delete "rows"
    h.to_json
  end
end
