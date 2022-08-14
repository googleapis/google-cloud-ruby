# Copyright 2017 Google LLC
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

describe Google::Cloud::Bigquery::Table, :reference, :update, :mock_bigquery do
  let(:dataset_id) { "my_dataset" }
  let(:table_id) { "my_table" }
  let(:table_name) { "My Table" }
  let(:description) { "This is my table" }
  let(:labels) { { "foo" => "bar" } }
  let(:table_gapi) { random_table_gapi dataset_id, table_id, table_name, description }
  let(:table) {Google::Cloud::Bigquery::Table.new_reference project, dataset_id, table_id, bigquery.service }


  let(:schema) { table.schema.dup }
  let(:etag) { "etag123456789" }

  it "updates its name" do
    new_table_name = "My Updated Table"

    mock = Minitest::Mock.new
    table_hash = random_table_hash dataset_id, table_id, new_table_name, description
    request_table_gapi = Google::Apis::BigqueryV2::Table.new friendly_name: "My Updated Table", etag: etag
    mock.expect :get_table, return_table(table_hash), [project, dataset_id, table_id]
    mock.expect :patch_table, return_table(table_hash),
      [project, dataset_id, table_id, request_table_gapi], options: {header: {"If-Match" => etag}}
    mock.expect :get_table, return_table(table_hash), [project, dataset_id, table_id]

    table.service.mocked_service = mock

    table.name = new_table_name

    _(table.name).must_equal new_table_name
    mock.verify
  end

  it "updates its description" do
    new_description = "This is my updated table"

    mock = Minitest::Mock.new
    table_hash = random_table_hash dataset_id, table_id, table_name, new_description
    request_table_gapi = Google::Apis::BigqueryV2::Table.new description: "This is my updated table", etag: etag
    mock.expect :get_table, return_table(table_hash), [project, dataset_id, table_id]
    mock.expect :patch_table, return_table(table_hash),
      [project, dataset_id, table_id, request_table_gapi], options: {header: {"If-Match" => etag}}
    mock.expect :get_table, return_table(table_hash), [project, dataset_id, table_id]
    table.service.mocked_service = mock

    table.description = new_description

    _(table.description).must_equal new_description
    mock.verify
  end

  it "updates time partitioning type" do
    type = "DAY"

    mock = Minitest::Mock.new
    table_hash = random_table_hash dataset_id, table_id, table_name, description
    table_hash["timePartitioning"] = {
        "type"  => type
    }
    partitioning = Google::Apis::BigqueryV2::TimePartitioning.new type: type
    request_table_gapi = Google::Apis::BigqueryV2::Table.new time_partitioning: partitioning, etag: etag
    mock.expect :get_table, return_table(table_hash), [project, dataset_id, table_id]
    mock.expect :patch_table, return_table(table_hash),
      [project, dataset_id, table_id, request_table_gapi], options: {header: {"If-Match" => etag}}
    mock.expect :get_table, return_table(table_hash), [project, dataset_id, table_id]
    table.service.mocked_service = mock

    table.time_partitioning_type = type

    _(table.time_partitioning_type).must_equal type
    mock.verify
  end

  it "updates time partitioning field" do
    field = "dob"

    mock = Minitest::Mock.new
    table_hash = random_table_hash dataset_id, table_id, table_name, description
    table_hash["timePartitioning"] = {
        "field"  => field
    }
    partitioning = Google::Apis::BigqueryV2::TimePartitioning.new field: field
    request_table_gapi = Google::Apis::BigqueryV2::Table.new time_partitioning: partitioning, etag: etag
    mock.expect :get_table, return_table(table_hash), [project, dataset_id, table_id]
    mock.expect :patch_table, return_table(table_hash),
                [project, dataset_id, table_id, request_table_gapi], options: {header: {"If-Match" => etag}}
    mock.expect :get_table, return_table(table_hash), [project, dataset_id, table_id]
    table.service.mocked_service = mock

    table.time_partitioning_field = field

    _(table.time_partitioning_field).must_equal field
    mock.verify
  end

  it "updates time partitioning expiration" do
    expiration = 86_400
    expiration_ms = expiration * 1_000

    mock = Minitest::Mock.new
    table_hash = random_table_hash dataset_id, table_id, table_name, description
    table_hash["timePartitioning"] = {
        "expirationMs" => expiration_ms
    }
    partitioning = Google::Apis::BigqueryV2::TimePartitioning.new expiration_ms: expiration_ms
    request_table_gapi = Google::Apis::BigqueryV2::Table.new time_partitioning: partitioning, etag: etag
    mock.expect :get_table, return_table(table_hash), [project, dataset_id, table_id]
    mock.expect :patch_table, return_table(table_hash),
      [project, dataset_id, table_id, request_table_gapi], options: {header: {"If-Match" => etag}}
    mock.expect :get_table, return_table(table_hash), [project, dataset_id, table_id]
    table.service.mocked_service = mock

    table.time_partitioning_expiration = expiration

    _(table.time_partitioning_expiration).must_equal expiration

    mock.verify
  end

  it "updates clustering fields" do
    clustering_fields = ["a"]

    mock = Minitest::Mock.new
    table_hash = random_table_hash dataset_id, table_id, table_name, description
    table_hash_clustering = table_hash.dup
    table_hash_clustering["clustering"] = {
        "fields" => clustering_fields
    }
    clustering = Google::Apis::BigqueryV2::Clustering.new fields: clustering_fields
    request_table_gapi = Google::Apis::BigqueryV2::Table.new clustering: clustering, etag: etag
    mock.expect :get_table, return_table(table_hash), [project, dataset_id, table_id]
    mock.expect :patch_table, return_table(table_hash_clustering),
      [project, dataset_id, table_id, request_table_gapi], options: {header: {"If-Match" => etag}}
    mock.expect :get_table, return_table(table_hash_clustering), [project, dataset_id, table_id]
    table.service.mocked_service = mock

    table.clustering_fields = clustering_fields

    _(table.clustering_fields).must_equal clustering_fields

    mock.verify
  end

  it "updates existing clustering fields" do
    clustering_fields = ["a"]
    new_clustering_fields = ["a"]

    mock = Minitest::Mock.new
    table_hash = random_table_hash dataset_id, table_id, table_name, description
    table_hash["clustering"] = {
        "fields" => clustering_fields
    }
    table_hash_clustering = table_hash.dup
    table_hash_clustering["clustering"] = {
        "fields" => new_clustering_fields
    }
    clustering = Google::Apis::BigqueryV2::Clustering.new fields: new_clustering_fields
    request_table_gapi = Google::Apis::BigqueryV2::Table.new clustering: clustering, etag: etag
    mock.expect :get_table, return_table(table_hash), [project, dataset_id, table_id]
    mock.expect :patch_table, return_table(table_hash_clustering),
      [project, dataset_id, table_id, request_table_gapi], options: {header: {"If-Match" => etag}}
    mock.expect :get_table, return_table(table_hash_clustering), [project, dataset_id, table_id]
    table.service.mocked_service = mock

    table.clustering_fields = new_clustering_fields

    _(table.clustering_fields).must_equal new_clustering_fields

    mock.verify
  end

  it "updates existing clustering to nil" do
    clustering_fields = ["a"]

    mock = Minitest::Mock.new
    table_hash = random_table_hash dataset_id, table_id, table_name, description
    table_hash["clustering"] = {
        "fields" => clustering_fields
    }
    table_hash_clustering = table_hash.dup
    table_hash_clustering["clustering"] = nil
    request_table_gapi = Google::Apis::BigqueryV2::Table.new clustering: nil, etag: etag
    mock.expect :get_table, return_table(table_hash), [project, dataset_id, table_id]
    mock.expect :patch_table, return_table(table_hash_clustering),
      [project, dataset_id, table_id, request_table_gapi], options: {header: {"If-Match" => etag}}
    mock.expect :get_table, return_table(table_hash_clustering), [project, dataset_id, table_id]
    table.service.mocked_service = mock

    table.clustering_fields = nil

    _(table.clustering_fields).must_be :nil?
    mock.verify
  end

  it "updates its labels" do
    new_labels = { "bar" => "baz" }

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    table_hash = random_table_hash dataset_id, table_id, table_name, description
    table_hash["labels"] = new_labels
    request_table_gapi = Google::Apis::BigqueryV2::Table.new labels: new_labels, etag: etag
    mock.expect :get_table, return_table(table_hash), [project, dataset_id, table_id]
    mock.expect :patch_table, return_table(table_hash),
      [project, dataset_id, table_id, request_table_gapi], options: {header: {"If-Match" => etag}}
    mock.expect :get_table, return_table(table_hash), [project, dataset_id, table_id]
    table.service.mocked_service = mock

    table.labels = new_labels

    _(table.labels).must_equal new_labels
    mock.verify
  end

  def return_table table_hash
    Google::Apis::BigqueryV2::Table.from_json(table_hash.to_json)
  end
end
