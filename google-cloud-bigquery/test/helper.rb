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

require "simplecov"

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
  let(:service) do
    Google::Cloud::Bigquery::Service.new("test-project", OpenStruct.new).tap do |s|
      s.define_singleton_method :generate_id do
        "9876543210"
      end
    end
  end
  let(:bigquery) { Google::Cloud::Bigquery::Project.new service }

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
      "location" => location,
      "labels" => { "foo" => "bar" },
      "tags" => [
        {
          "tagKey" => "2424242256/environment",
          "tagValue" => "production"
        },
        {
          "tagKey" => "2424242256/cost_center",
          "tagValue" => "sales"
        }
      ]
    }
  end

  def random_dataset_partial_hash id = nil, name = nil
    id ||= "my_dataset"
    name ||= "My Dataset"

    {
      "kind" => "bigquery#dataset",
      "id" => "#{project}:#{id}",
      "datasetReference" => {
        "datasetId" => id,
        "projectId" => project
      },
      "friendlyName" => name,
      "location": "US"
    }
  end

  def list_datasets_gapi count = 2, token = nil
    datasets = count.times.map { random_dataset_partial_hash }
    hash = {"kind"=>"bigquery#datasetList", "datasets"=>datasets}
    hash["nextPageToken"] = token unless token.nil?
    Google::Apis::BigqueryV2::DatasetList.from_json hash.to_json
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
          "name" => "pi",
          "type" => "NUMERIC",
          "mode" => "NULLABLE"
        },
        {
          "name" => "my_bignumeric",
          "type" => "BIGNUMERIC",
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
        },
        {
          "name" => "home",
          "type" => "GEOGRAPHY",
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
          { "v" => "3.141592654" },
          { "v" => "3.141592654" },
          { "v" => "true" },
          { "v" => "aW1hZ2UgZGF0YQ==" },
          { "v" => "1482670800.0" },
          { "v" => "04:00:00" },
          { "v" => "2017-01-01 00:00:00" },
          { "v" => "1968-10-20" },
          { "v" => "POINT(-122.335503 47.625536)" }
        ]
      },
      {
        "f" => [
          { "v" => "Aaron" },
          { "v" => "42" },
          { "v" => "8.15" },
          { "v" => nil },
          { "v" => nil },
          { "v" => "false" },
          { "v" => nil },
          { "v" => nil },
          { "v" => "04:32:10.555555" },
          { "v" => nil },
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

    base = random_table_partial_hash dataset, id, name, project_id
    base.merge({
      "etag" => "etag123456789",
      "selfLink" => "http://googleapi/bigquery/v2/projects/#{project}/datasets/#{dataset}/tables/#{id}",
      "description" => description,
      "schema" => random_schema_hash,
      "numBytes" => "1000", # String per google/google-api-ruby-client#439
      "numRows" => "100",   # String per google/google-api-ruby-client#439
      "creationTime" => time_millis,
      "expirationTime" => time_millis,
      "lastModifiedTime" => time_millis,
      "location" => "US",
      "labels" => { "foo" => "bar" },
      "streamingBuffer" => {
        "estimatedBytes" => "2000", # String per google/google-api-ruby-client
        "estimatedRows" => "200", # String per google/google-api-ruby-client
        "oldestEntryTime" => time_millis
      },
      "requirePartitionFilter" => true
    })
  end

  def random_table_partial_hash dataset, id = nil, name = nil, project_id = nil, type: "TABLE"
    id ||= "my_table"
    name ||= "Table Name"

    {
      "kind" => "bigquery#table",
      "id" => "#{project}:#{dataset}.#{id}",
      "tableReference" => {
        "projectId" => (project_id || project),
        "datasetId" => dataset,
        "tableId" => id
      },
      "friendlyName" => name,
      "type" => type
    }
  end

  def list_tables_gapi count = 2, token = nil, total = nil
    tables = count.times.map { random_table_partial_hash(dataset_id) }
    hash = {"kind" => "bigquery#tableList", "tables" => tables,
            "totalItems" => (total || count)}
    hash["nextPageToken"] = token unless token.nil?
    Google::Apis::BigqueryV2::TableList.from_json hash.to_json
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

  def source_table_partial_gapi
    Google::Apis::BigqueryV2::Table.from_json source_table_partial_json
  end

  def source_table_partial_json
    hash = random_table_partial_hash "getting_replaced_dataset_id"
    hash["tableReference"] = {
      "projectId" => "source_project_id",
      "datasetId" => "source_dataset_id",
      "tableId"   => "source_table_id"
    }
    hash.to_json
  end

  def destination_table_partial_gapi
    Google::Apis::BigqueryV2::Table.from_json destination_table_partial_json
  end

  def destination_table_partial_json
    hash = random_table_partial_hash "getting_replaced_dataset_id"
    hash["tableReference"] = {
      "projectId" => "target_project_id",
      "datasetId" => "target_dataset_id",
      "tableId"   => "target_table_id"
    }
    hash.to_json
  end

  def copy_job_gapi source, target, job_id: "job_9876543210", location: "US"
    Google::Apis::BigqueryV2::Job.from_json copy_job_json(source, target, job_id, location: location)
  end

  def copy_job_json source, target, job_id, location: "US"
    hash = {
      "jobReference" => {
        "projectId" => project,
        "jobId" => job_id
      },
      "configuration" => {
        "copy" => {
          "sourceTable" => {
            "projectId" => source.project_id,
            "datasetId" => source.dataset_id,
            "tableId" => source.table_id
          },
          "destinationTable" => {
            "projectId" => target.project_id,
            "datasetId" => target.dataset_id,
            "tableId" => target.table_id
          },
          "createDisposition" => nil,
          "writeDisposition" => nil,
          "operationType" => nil
        },
        "dryRun" => nil
      }
    }
    hash["jobReference"]["location"] = location if location
    hash.to_json
  end

  def random_snapshot_gapi dataset, id = nil, name = nil, description = nil
    json = random_snapshot_hash(dataset, id, name, description).to_json
    Google::Apis::BigqueryV2::Table.from_json json
  end

  def random_snapshot_hash dataset, id = nil, name = nil, description = nil
    id ||= "my_snapshot"
    name ||= "Snapshot Name"

    base = random_table_partial_hash dataset, id, name, type: "SNAPSHOT"
    base.merge({
      "etag" => "etag123456789",
      "selfLink" => "http://googleapi/bigquery/v2/projects/#{project}/datasets/#{dataset}/tables/#{id}",
      "description" => description,
      "schema" => random_schema_hash,
      "creationTime" => time_millis,
      "expirationTime" => time_millis,
      "lastModifiedTime" => time_millis,
      "snapshotDefinition" => {
        "snapshotTime" => DateTime.now,
        "baseTableReference" => Google::Apis::BigqueryV2::TableReference.new
      },
      "location" => "US"
    })
  end

  def random_clone_gapi dataset, id = nil, name = nil, description = nil
    json = random_clone_hash(dataset, id, name, description).to_json
    Google::Apis::BigqueryV2::Table.from_json json
  end

  def random_clone_hash dataset, id = nil, name = nil, description = nil
    id ||= "my_clone"
    name ||= "Clone Name"

    base = random_table_partial_hash dataset, id, name, type: "TABLE"
    base.merge({
      "etag" => "etag123456789",
      "selfLink" => "http://googleapi/bigquery/v2/projects/#{project}/datasets/#{dataset}/tables/#{id}",
      "description" => description,
      "schema" => random_schema_hash,
      "creationTime" => time_millis,
      "expirationTime" => time_millis,
      "lastModifiedTime" => time_millis,
      "cloneDefinition" => {
        "cloneTime" => DateTime.now,
        "baseTableReference" => Google::Apis::BigqueryV2::TableReference.new
      },
      "location" => "US"
    })
  end

  def random_view_gapi dataset, id = nil, name = nil, description = nil
    json = random_view_hash(dataset, id, name, description).to_json
    Google::Apis::BigqueryV2::Table.from_json json
  end

  def random_view_hash dataset, id = nil, name = nil, description = nil
    id ||= "my_view"
    name ||= "View Name"

    base = random_table_partial_hash dataset, id, name, type: "VIEW"
    base.merge({
      "etag" => "etag123456789",
      "selfLink" => "http://googleapi/bigquery/v2/projects/#{project}/datasets/#{dataset}/tables/#{id}",
      "description" => description,
      "schema" => random_schema_hash,
      "creationTime" => time_millis,
      "expirationTime" => time_millis,
      "lastModifiedTime" => time_millis,
      "view" => {
        "query" => "SELECT name, age, score, active FROM `external.publicdata.users`"
      },
      "location" => "US"
    })
  end

  def random_materialized_view_hash dataset, id = nil, name = nil, description = nil
    id ||= "my_materialized_view"
    name ||= "Materialized View Name"

    base = random_table_partial_hash dataset, id, name, type: "MATERIALIZED_VIEW"
    base.merge({
      "etag" => "etag123456789",
      "selfLink" => "http://googleapi/bigquery/v2/projects/#{project}/datasets/#{dataset}/tables/#{id}",
      "description" => description,
      "schema" => random_schema_hash,
      "creationTime" => time_millis,
      "expirationTime" => time_millis,
      "lastModifiedTime" => time_millis,
      "materializedView" => {
        "enableRefresh" => true,
        "lastRefreshTime" => time_millis,
        "query" => "SELECT name, age, score, active FROM `external.publicdata.users`",
        "refreshIntervalMs" => 3_600_000
      },
      "location" => "US"
    })
  end

  def source_model_json
    hash = random_model_full_hash "getting_replaced_dataset_id", "source_model_id"
    hash["tableReference"] = {
      "projectId" => "source_project_id",
      "datasetId" => "source_dataset_id",
      "modelId"   => "source_model_id"
    }
    hash.to_json
  end

  def random_model_full_hash dataset, id, name: nil, description: nil, kms_key: nil
    hash = random_model_partial_hash dataset, id

    name ||= "Model Name"
    description ||= "Model description"

    hash.merge!({
      etag: "etag123456789",
      friendlyName: name,
      description: description,
      expirationTime: time_millis,
      location: "US",
      featureColumns: [{name: "f1", type: {typeKind: "STRING"}}],
      labelColumns: [{name: "predicted_label", type: {typeKind: "FLOAT64"}}],
      trainingRuns: [{
        evaluationMetrics: {
          regressionMetrics: {
            meanAbsoluteError: 0.58,
            meanSquaredError: 0.628,
            meanSquaredLogError: 0.035,
            medianAbsoluteError: 0.04,
            rSquared: 0.225
          }
        },
        results: [{
          durationMs: 2531,
          index: 0,
          learnRate: 0.4,
          trainingLoss: 0.628
        }],
        startTime: Time.now.utc.iso8601,
        trainingOptions: {
          earlyStop: true,
          l1Regularization: 0,
          l2Regularization: 0,
          learnRate: 0.4,
          learnRateStrategy: "CONSTANT",
          lossType: "MEAN_SQUARED_LOSS",
          maxIterations: 1,
          minRelativeProgress: 0.01,
          optimizationStrategy: "BATCH_GRADIENT_DESCENT",
          warmStart: false
        }
      }]
    })

    if kms_key
      hash[:encryptionConfiguration] = {
        kmsKeyName: kms_key
      }
    end

    hash
  end

  def random_model_partial_hash dataset, id
    # modelReference, modelType, creationTime, lastModifiedTime and labels.
    {
      modelReference: {
        projectId: project,
        datasetId: dataset,
        modelId: id
      },
      modelType: "KMEANS",
      creationTime: time_millis,
      lastModifiedTime: time_millis,
      labels: { foo: "bar" }
    }
  end

  def list_models_gapi_json dataset_id, count = 2, token = nil
    models = count.times.map { random_model_partial_hash(dataset_id, "model_#{rand(1000)}") }
    hash = { "models" => models }
    hash["nextPageToken"] = token unless token.nil?
    hash.to_json
  end

  def random_routine_hash dataset,
                          id = nil,
                          project_id: nil,
                          etag: "etag123456789",
                          description: "This is my routine", 
                          creation_time: time_millis,
                          last_modified_time: time_millis,
                          determinism_level: nil
    id ||= "my_routine"

    h = {
      kind: "bigquery#routine",
      id: "#{project}:#{dataset}.#{id}",
      selfLink: "http://googleapi/bigquery/v2/projects/#{project}/datasets/#{dataset}/routines/#{id}",
      routineReference: {
        projectId: (project_id || project),
        datasetId: dataset,
        routineId: id
      },
      routineType: "SCALAR_FUNCTION",
      language: "SQL",
      arguments: [
        { 
          name: "arr",
          argumentKind: "FIXED_TYPE",
          mode: "IN",
          dataType: { 
            typeKind: "ARRAY",
            arrayElementType: { 
              typeKind: "STRUCT",
              structType: {
                fields: [
                  {
                    name: "my-struct-name",
                    type: {
                      typeKind: "STRING"
                    }
                  },
                  {
                    name: "my-struct-val",
                    type: {
                      typeKind: "INT64"
                    }
                  }
                ]
              }
            }
          }
        },
        { 
          name: "out",
          argumentKind: "ANY_TYPE",
          mode: "OUT",
          dataType: { typeKind: "STRING" }
        }
      ],
      returnType: { typeKind: "INT64" },
      importedLibraries: ["gs://cloud-samples-data/bigquery/udfs/max-value.js"],
      definitionBody: "x * 3",
      description: description
    }
    h[:determinismLevel] = determinism_level if determinism_level
    h[:etag] = etag if etag
    h[:creationTime] = creation_time if creation_time
    h[:lastModifiedTime] = last_modified_time if last_modified_time
    h
  end

  def random_routine_partial_hash dataset, id
    # List representation: etag, routineReference, routineType, creationTime, lastModifiedTime and language.
    { 
      etag: "etag123456789",
      routineReference: {
        projectId: project,
        datasetId: dataset,
        routineId: id
      },
      routineType: "SCALAR_FUNCTION",
      creationTime: time_millis,
      lastModifiedTime: time_millis,
      language: "SQL"
    }
  end

  def list_routines_gapi dataset, count = 2, token = nil
    routines = count.times.map { |i| random_routine_partial_hash dataset, "my_routine_#{i}" }
    hash = { "kind"=>"bigquery#routineList", "routines" => routines }
    hash["nextPageToken"] = token unless token.nil?
    Google::Apis::BigqueryV2::ListRoutinesResponse.from_json hash.to_json
  end

  def random_routine_gapi dataset, id = nil, project_id: nil, description: nil
    json = random_routine_hash(dataset, id, project_id: project_id, description: description).to_json
    Google::Apis::BigqueryV2::Routine.from_json json
  end

  def random_job_hash id = "job_9876543210", state = "running", location: "US", transaction_id: nil, session_id: nil
    hash = {
      "kind" => "bigquery#job",
      "etag" => "etag",
      "id" => "#{project}:#{id}",
      "selfLink" => "http://bigquery/projects/#{project}/jobs/#{id}",
      "jobReference" => {
        "projectId" => project,
        "jobId" => id,
        "location" => location
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
        "endTime" => time_millis,
        "numChildJobs" => 2,
        "parentJobId" => "2222222222",
        "reservationUsage": [
          {
            "name" => "unreserved",
            "slotMs" => 12345
          }
        ],
        "scriptStatistics": {
          "evaluationKind" => "EXPRESSION",
          "stackFrames" => [
            {
              "startLine": 5,
              "startColumn": 29,
              "endLine": 9,
              "endColumn": 14,
              "text": "QUERY TEXT"
            }
          ],
        }
      },
      "user_email" => "user@example.com"
    }
    hash["jobReference"]["location"] = location if location
    hash["statistics"]["transactionInfo"] = { "transactionId": transaction_id } if transaction_id
    hash["statistics"]["sessionInfo"] = { "sessionId": session_id } if session_id
    hash
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

  def find_job_gapi job_id, location: nil
    Google::Apis::BigqueryV2::Job.from_json random_job_hash(job_id, location: location).to_json
  end

  def job_resp_gapi job_gapi, job_id: "job_9876543210", location: "US"
    job_gapi = job_gapi.dup
    job_gapi.job_reference = job_reference_gapi project, job_id, location: location
    job_gapi
  end

  def job_reference_gapi project, job_id, location: "US"
    job_ref = Google::Apis::BigqueryV2::JobReference.new(
      project_id: project,
      job_id: job_id
    )
    job_ref.location = location if location
    job_ref
  end

  def query_job_resp_gapi query,
                          job_id: nil,
                          target_routine: false,
                          target_table: false,
                          statement_type: "SELECT",
                          num_dml_affected_rows: nil,
                          ddl_operation_performed: nil,
                          deleted_row_count: nil,
                          inserted_row_count: nil,
                          updated_row_count: nil,
                          session_id: nil
    gapi = Google::Apis::BigqueryV2::Job.from_json query_job_resp_json(query, job_id: job_id, session_id: session_id)
    gapi.statistics.query = statistics_query_gapi target_routine: target_routine,
                                                  target_table: target_table,
                                                  statement_type: statement_type,
                                                  num_dml_affected_rows: num_dml_affected_rows,
                                                  ddl_operation_performed: ddl_operation_performed,
                                                  deleted_row_count: deleted_row_count,
                                                  inserted_row_count: inserted_row_count,
                                                  updated_row_count: updated_row_count
    gapi
  end

  def query_job_resp_json query, job_id: "job_9876543210", location: "US", session_id: nil
    hash = random_job_hash job_id, "done", location: location
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
    hash["statistics"]["sessionInfo"] = { "sessionId": session_id } if session_id
    hash.to_json
  end

  def statistics_query_gapi target_routine: false,
                            target_table: false,
                            statement_type: nil,
                            num_dml_affected_rows: nil,
                            ddl_operation_performed: nil,
                            deleted_row_count: nil,
                            inserted_row_count: nil,
                            updated_row_count: nil
    ddl_target_routine = if target_routine
      Google::Apis::BigqueryV2::RoutineReference.new(
        project_id: "target_project_id",
        dataset_id: "target_dataset_id",
        routine_id: "target_routine_id"
      )
    end
    ddl_target_table = if target_table
      Google::Apis::BigqueryV2::TableReference.new(
        project_id: "target_project_id",
        dataset_id: "target_dataset_id",
        table_id: "target_table_id"
      )
    end
    dml_stats = if deleted_row_count || inserted_row_count || updated_row_count
      Google::Apis::BigqueryV2::DmlStatistics.new(
        deleted_row_count: deleted_row_count,
        inserted_row_count: inserted_row_count,
        updated_row_count: updated_row_count
      )
    end
    Google::Apis::BigqueryV2::JobStatistics2.new(
      billing_tier: 1,
      cache_hit: true,
      ddl_operation_performed: ddl_operation_performed,
      ddl_target_routine: ddl_target_routine,
      ddl_target_table: ddl_target_table,
      dml_stats: dml_stats,
      num_dml_affected_rows: num_dml_affected_rows,
      query_plan: [
        Google::Apis::BigqueryV2::ExplainQueryStage.new(
          compute_ratio_avg: 1.0,
          compute_ratio_max: 1.0,
          id: 1,
          name: "Stage 1",
          read_ratio_avg: 0.2710832227382326,
          read_ratio_max: 0.2710832227382326,
          records_read: 164656,
          records_written: 1,
          status: "COMPLETE",
          steps: [
            Google::Apis::BigqueryV2::ExplainQueryStep.new(
              kind: "READ",
              substeps: [
                "word",
                "FROM bigquery-public-data:samples.shakespeare"
              ]
            )
          ],
          wait_ratio_avg: 0.007876711656047392,
          wait_ratio_max: 0.007876711656047392,
          write_ratio_avg: 0.05389444608201358,
          write_ratio_max: 0.05389444608201358
        )
      ],
      statement_type: statement_type,
      total_bytes_processed: 123456
    )
  end

  def failed_query_job_resp_gapi query, job_id: nil, reason: "accessDenied", location: "US"
    Google::Apis::BigqueryV2::Job.from_json failed_query_job_resp_json(query, job_id: job_id, reason: reason, location: location)
  end

  def failed_query_job_resp_json query, job_id: "job_9876543210", reason: "accessDenied", location: "US"
    hash = JSON.parse query_job_resp_json(query, job_id: job_id)
    hash["jobReference"]["location"] = location
    hash["status"] = {
      "state" => "done",
      "errorResult" => {
        "reason" => reason,
        "location" => "string",
        "debugInfo" => "string",
        "message" => "string"
      },
      "errors" => [
        {
          "reason" => reason,
          "location" => "string",
          "debugInfo" => "string",
          "message" => "string"
        }
      ]
    }
    hash.to_json
  end

  def query_job_gapi query, parameter_mode: nil, dataset: nil, job_id: "job_9876543210", location: "US", dry_run: nil, create_session: nil, session_id: nil
    gapi = Google::Apis::BigqueryV2::Job.from_json query_job_json(query, job_id: job_id, location: location, dry_run: dry_run, create_session: create_session, session_id: session_id)
    gapi.configuration.query.parameter_mode = parameter_mode if parameter_mode
    gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      dataset_id: dataset, project_id: project
    ) if dataset
    gapi
  end

  def query_job_json query, job_id: "job_9876543210", location: "US", dry_run: nil, create_session: nil, session_id: nil
    hash = {
      "jobReference" => {
        "projectId" => project,
        "jobId" => job_id
      },
      "configuration" => {
        "query" => {
          "query" => query,
          "defaultDataset" => nil,
          "destinationTable" => nil,
          "createDisposition" => nil,
          "createSession" => create_session,
          "writeDisposition" => nil,
          "priority" => "INTERACTIVE",
          "allowLargeResults" => nil,
          "useQueryCache" => true,
          "flattenResults" => nil,
          "useLegacySql" => false,
          "maximumBillingTier" => nil,
          "maximumBytesBilled" => nil,
          "userDefinedFunctionResources" => []
        },
        "dryRun" => dry_run
      }
    }
    hash["jobReference"]["location"] = location if location
    hash["configuration"]["query"]["connectionProperties"] = [{key: "session_id", value: session_id}] if session_id
    hash.to_json
  end

  def extract_job_gapi source, extract_file, job_id: "job_9876543210", location: "US"
    Google::Apis::BigqueryV2::Job.from_json extract_job_json(source, extract_file, job_id, location: location)
  end

  def extract_job_json source, extract_file, job_id, location: "US"
    extract_file = extract_file.respond_to?(:to_gs_url) ? extract_file.to_gs_url : extract_file
    hash = {
      "jobReference" => {
        "projectId" => project,
        "jobId" => job_id
      },
      "configuration" => {
        "extract" => {
          "destinationUris" => [extract_file],
          "printHeader" => nil,
          "compression" => nil,
          "fieldDelimiter" => nil,
          "destinationFormat" => nil
        },
        "dryRun" => nil
      }
    }
    hash["jobReference"]["location"] = location if location
    if source.is_a? Google::Cloud::Bigquery::Table
      hash["configuration"]["extract"]["sourceTable"] = {
        "projectId" => source.project_id,
        "datasetId" => source.dataset_id,
        "tableId" => source.table_id
      }
    elsif source.is_a? Google::Cloud::Bigquery::Model
      hash["configuration"]["extract"]["sourceModel"] = {
        "projectId" => source.project_id,
        "datasetId" => source.dataset_id,
        "modelId" => source.model_id
      }
    else
      raise ArgumentError, "unsupported type for source: #{source}"
    end
    hash.to_json
  end

  def udfs_gapi_inline
    Google::Apis::BigqueryV2::UserDefinedFunctionResource.new(
      inline_code: "return x+1;"
    )
  end

  def udfs_gapi_uri
    Google::Apis::BigqueryV2::UserDefinedFunctionResource.new(
      resource_uri: "gs://my-bucket/my-lib.js"
    )
  end

  def udfs_gapi_array
    [
      udfs_gapi_inline,
      udfs_gapi_uri
    ]
  end

  def query_request_gapi
    Google::Apis::BigqueryV2::QueryRequest.new(
      default_dataset: Google::Apis::BigqueryV2::DatasetReference.new(
        dataset_id: "my_dataset", project_id: "test-project"
      ),
      dry_run: nil,
      max_results: nil,
      query: "SELECT * FROM `some_project.some_dataset.users`",
      timeout_ms: 10_000,
      use_query_cache: true,
      use_legacy_sql: false,
    )
  end

  def query_data_gapi token: "token1234567890"
    Google::Apis::BigqueryV2::QueryResponse.from_json query_data_hash(token: token).to_json
  end

  def query_data_hash token: "token1234567890", location: "US"
    {
      "kind" => "bigquery#getQueryResultsResponse",
      "etag" => "etag1234567890",
      "jobReference" => {
        "projectId" => project,
        "jobId" => "job_9876543210",
        "location" => location
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

  def load_job_gapi table_reference,
                    source_format = "NEWLINE_DELIMITED_JSON",
                    job_id: "job_9876543210",
                    location: "US"
    Google::Apis::BigqueryV2::Job.new(
      job_reference: job_reference_gapi(project, job_id, location: location),
      configuration: Google::Apis::BigqueryV2::JobConfiguration.new(
        load: Google::Apis::BigqueryV2::JobConfigurationLoad.new(
          destination_table: table_reference,
          source_format: source_format
        ),
        dry_run: nil
      )
    )
  end

  def load_job_csv_options_gapi table_reference, job_id: "job_9876543210"
    Google::Apis::BigqueryV2::Job.new(
      job_reference: job_reference_gapi(project, job_id),
      configuration: Google::Apis::BigqueryV2::JobConfiguration.new(
        load: Google::Apis::BigqueryV2::JobConfigurationLoad.new(
          destination_table: table_reference,
          source_format: "CSV",
          allow_jagged_rows: true,
          allow_quoted_newlines: true,
          encoding: "ISO-8859-1",
          field_delimiter: "\t",
          ignore_unknown_values: true,
          max_bad_records: 42,
          quote: "'",
          skip_leading_rows: 1,
          autodetect: true,
          null_marker: "\N"
        ),
        dry_run: nil
      )
    )
  end

  def load_job_url_gapi table_reference,
                        urls,
                        job_id: "job_9876543210",
                        location: "US",
                        hive_partitioning_options: nil,
                        parquet_options: nil
    load = Google::Apis::BigqueryV2::JobConfigurationLoad.new(
      destination_table: table_reference,
      source_uris: [urls].flatten
    )
    load.hive_partitioning_options = hive_partitioning_options if hive_partitioning_options
    load.parquet_options = parquet_options if parquet_options
    Google::Apis::BigqueryV2::Job.new(
      job_reference: job_reference_gapi(project, job_id, location: location),
      configuration: Google::Apis::BigqueryV2::JobConfiguration.new(
        load: load,
        dry_run: nil
      )
    )
  end

  def load_job_resp_gapi table,
                         load_url,
                         job_id: "job_9876543210",
                         location: "US",
                         labels: nil,
                         source_format: nil,
                         hive_partitioning_options: nil,
                         parquet_options: nil
    hash = random_job_hash job_id, location: location
    hash["configuration"]["load"] = {
      "sourceFormat" => source_format,
      "sourceUris" => [load_url],
      "destinationTable" => {
        "projectId" => table.project_id,
        "datasetId" => table.dataset_id,
        "tableId" => table.table_id
      }
    }
    resp = Google::Apis::BigqueryV2::Job.from_json hash.to_json
    resp.status = status "done"
    resp.configuration.labels = labels if labels
    resp.configuration.load.hive_partitioning_options = hive_partitioning_options if hive_partitioning_options
    resp.configuration.load.parquet_options = parquet_options if parquet_options
    resp
  end

  def status state = "running"
    Google::Apis::BigqueryV2::JobStatus.new state: state
  end

  def temp_csv
    Tempfile.open ["import", ".csv"] do |tmpfile|
      tmpfile.puts "id,name"
      1000.times do |x|
        tmpfile.puts "#{x},#{SecureRandom.urlsafe_base64(rand(8..16))}"
      end
      yield tmpfile
    end
  end

  def temp_json
    Tempfile.open ["import", ".json"] do |tmpfile|
      h = {}
      1000.times { |x| h["key-#{x}"] = {name: SecureRandom.urlsafe_base64(rand(8..16)) } }
      tmpfile.write h.to_json
      yield tmpfile
    end
  end

  def encryption_gapi key_name
    Google::Apis::BigqueryV2::EncryptionConfiguration.new kms_key_name: key_name
  end

  def policy_gapi etag: "CAE=", version: 1, bindings: []
    Google::Apis::BigqueryV2::Policy.new etag: etag, version: version, bindings: bindings
  end

  def formatted_table_path dataset_id, table_id
    "projects/#{project}/datasets/#{dataset_id}/tables/#{table_id}"
  end

  def table_metadata_view_type_for str
    return nil if str.nil?
    { "unspecified" => "TABLE_METADATA_VIEW_UNSPECIFIED",
      "basic" => "BASIC",
      "storage" => "STORAGE_STATS",
      "full" => "FULL"
    }[str.to_s.downcase]
  end

  def verify_table_metadata table, view
    if view == "basic"
      assert_nil(table.bytes_count)
      assert_nil(table.rows_count)
      assert_nil(table.modified_at)
    else
      refute_nil table.bytes_count, "Transient stats should not be nil"
      refute_nil table.rows_count, "Transient stats should not be nil"
      refute_nil table.modified_at, "Transient stats should not be nil"
    end
  end

  def patch_table_args selected_fields: nil,
                       view: nil,
                       fields: nil,
                       quota_user: nil,
                       user_ip: nil,
                       options: nil
    {
      view: table_metadata_view_type_for(view)
    }
  end
end
