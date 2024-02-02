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
require "json"
require "uri"

describe Google::Cloud::Bigquery::Table, :mock_bigquery do
  let(:dataset) { "my_dataset" }
  let(:table_id) { "my_table" }
  let(:table_name) { "My Table" }
  let(:description) { "This is my table" }
  let(:etag) { "etag123456789" }
  let(:location_code) { "US" }
  let(:labels) { { "foo" => "bar" } }
  let(:kms_key) { "path/to/encryption_key_name" }
  let(:gapi_encrypt_config) { Google::Apis::BigqueryV2::EncryptionConfiguration.new kms_key_name: kms_key }
  let(:gapi_encrypt_config) { Google::Apis::BigqueryV2::EncryptionConfiguration.new kms_key_name: kms_key }
  let(:api_url) { "http://googleapi/bigquery/v2/projects/#{project}/datasets/#{dataset}/tables/#{table_id}" }
  let(:table_hash) { random_table_hash dataset, table_id, table_name, description }
  let(:table_gapi) { Google::Apis::BigqueryV2::Table.from_json(table_hash.to_json).tap { |t| t.encryption_configuration = gapi_encrypt_config } }
  let(:table) { Google::Cloud::Bigquery::Table.from_gapi table_gapi, bigquery.service }
  let(:clone_table) { Google::Cloud::Bigquery::Table.from_gapi random_clone_gapi(dataset), bigquery.service }
  let(:snapshot_table) { Google::Cloud::Bigquery::Table.from_gapi random_snapshot_gapi(dataset), bigquery.service }

  it "knows its attributes" do
    _(table.table_id).must_equal table_id
    _(table.dataset_id).must_equal dataset
    _(table.project_id).must_equal project
    _(table.table_ref).must_be_kind_of Google::Apis::BigqueryV2::TableReference
    _(table.table_ref.table_id).must_equal table_id
    _(table.table_ref.dataset_id).must_equal dataset
    _(table.table_ref.project_id).must_equal project

    _(table.name).must_equal table_name
    _(table.description).must_equal description
    _(table.etag).must_equal etag
    _(table.api_url).must_equal api_url
    _(table.bytes_count).must_equal 1000
    _(table.rows_count).must_equal 100
    _(table.query_standard_sql?).must_be :nil?
    _(table.query_legacy_sql?).must_be :nil?
    _(table.query_udfs).must_be :nil?
    _(table.table?).must_equal true
    _(table.view?).must_equal false
    _(table.materialized_view?).must_equal false
    _(table.enable_refresh?).must_be :nil?
    _(table.last_refresh_time).must_be :nil?
    _(table.refresh_interval_ms).must_be :nil?
    _(table.location).must_equal location_code
    _(table.labels).must_equal labels
    _(table.labels).must_be :frozen?
    _(table.require_partition_filter).must_equal true
    _(table.encryption).must_be_kind_of Google::Cloud::Bigquery::EncryptionConfiguration
    _(table.encryption.kms_key).must_equal kms_key
    _(table.encryption).must_be :frozen?
  end

  it "knows its fully-qualified ID" do
    _(table.id).must_equal "#{project}:#{dataset}.#{table_id}"
  end

  it "knows its fully-qualified query ID" do
    standard_id = "`#{project}.#{dataset}.#{table_id}`"
    legacy_id = "[#{project}:#{dataset}.#{table_id}]"

    _(table.query_id).must_equal standard_id
    _(table.query_id(standard_sql: true)).must_equal standard_id
    _(table.query_id(standard_sql: false)).must_equal legacy_id
    _(table.query_id(legacy_sql: true)).must_equal legacy_id
    _(table.query_id(legacy_sql: false)).must_equal standard_id
  end

  it "knows its creation and modification and expiration times" do
    now = ::Time.now
    table_hash["creationTime"] = time_millis
    table_hash["lastModifiedTime"] = time_millis
    table_hash["expirationTime"] = time_millis


    _(table.created_at).must_be_close_to now, 1
    _(table.modified_at).must_be_close_to now, 1
    _(table.expires_at).must_be_close_to now, 1
  end

  it "can have an empty expiration times" do
    table_hash["expirationTime"] = nil

    _(table.expires_at).must_be :nil?
  end

  it "knows schema, fields, and headers" do
    _(table.schema).must_be_kind_of Google::Cloud::Bigquery::Schema
    _(table.schema).must_be :frozen?
    _(table.fields.map(&:name)).must_equal table.schema.fields.map(&:name)
    _(table.headers).must_equal [:name, :age, :score, :pi, :my_bignumeric, :active, 
                                 :avatar, :started_at, :duration, :target_end, 
                                 :birthday, :home, :address]
    _(table.param_types).must_equal({ name: :STRING, age: :INTEGER, score: :FLOAT, pi: :NUMERIC, 
                                      my_bignumeric: :BIGNUMERIC, active: :BOOLEAN, avatar: :BYTES, 
                                      started_at: :TIMESTAMP, duration: :TIME, target_end: :DATETIME, 
                                      birthday: :DATE, home: :GEOGRAPHY, address: :JSON })
  end

  it "knows its streaming buffer attributes" do
    _(table.buffer_bytes).must_equal 2000
    _(table.buffer_rows).must_equal 200
    _(table.buffer_oldest_at).must_be_close_to ::Time.now, 1
  end

  it "can test its existence" do
    _(table.exists?).must_equal true
  end

  it "can test its existence with force to load resource" do
    mock = Minitest::Mock.new
    mock.expect :get_table, table_gapi, [table.project_id, table.dataset_id, table.table_id], **patch_table_args
    table.service.mocked_service = mock

    _(table.exists?(force: true)).must_equal true

    mock.verify
  end

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_table, nil,
      [project, dataset, table_id]
    table.service.mocked_service = mock

    _(table.delete).must_equal true

    _(table.exists?).must_equal false

    mock.verify
  end

  it "know if its a snapshot" do
    _(snapshot_table.snapshot?).must_equal true
  end

  it "know if its a clone" do
    _(clone_table.clone?).must_equal true
  end

  it "know snapshot definition if its a snapshot" do
    _(snapshot_table.snapshot_definition).must_be_kind_of Google::Apis::BigqueryV2::SnapshotDefinition
  end

  it "knows clone definition if its a clone" do
    _(clone_table.clone_definition).must_be_kind_of Google::Apis::BigqueryV2::CloneDefinition
  end
end
