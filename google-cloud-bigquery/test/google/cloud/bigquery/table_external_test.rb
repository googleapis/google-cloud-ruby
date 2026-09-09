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
require "json"
require "uri"

describe Google::Cloud::Bigquery::Table, :external, :mock_bigquery do
  let(:dataset_id) { "my_dataset" }
  let(:table_id) { "my_table" }
  let(:table_name) { "My Table" }
  let(:description) { "This is my table" }
  let(:labels) { { "foo" => "bar" } }
  let(:table_hash) { random_table_hash dataset_id, table_id, table_name, description }
  let(:table_gapi) do
    gapi = Google::Apis::BigqueryV2::Table.from_json table_hash.to_json
    gapi.external_data_configuration = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["gs://my-bucket/path/to/file.csv"],
      source_format: "CSV",
      autodetect: true,
      csv_options: Google::Apis::BigqueryV2::CsvOptions.new(
        skip_leading_rows: 1
      )
    )
    gapi
  end
  let(:table) { Google::Cloud::Bigquery::Table.from_gapi table_gapi, bigquery.service }
  let(:etag) { "etag123456789" }

  it "can have a permanent external data source" do
    _(table.external).must_be_kind_of Google::Cloud::Bigquery::External::CsvSource
    _(table.external.urls).must_equal ["gs://my-bucket/path/to/file.csv"]
    _(table.external.format).must_equal "CSV"
    _(table.external.autodetect).must_equal true
    _(table.external.skip_leading_rows).must_equal 1
    _(table.external.schema).must_be :empty?
    _(table.external).must_be :frozen?
  end

  it "can update the permanent external data source" do
    request_table_gapi = Google::Apis::BigqueryV2::Table.new(
      etag: etag,
      external_data_configuration: Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
        source_format: "NEWLINE_DELIMITED_JSON",
        source_uris: ["gs://my-bucket/path/to/file.json"],
        schema: Google::Apis::BigqueryV2::TableSchema.new(
          fields: [
            Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "id", type: "INTEGER", description: "id description", fields: []),
            Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "name", type: "STRING", description: "name description", fields: []),
            Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "breed", type: "STRING", description: "breed description", fields: [])
          ]
        )
      )
    )
    response_table_gapi = table_gapi.dup
    response_table_gapi.external_data_configuration = request_table_gapi.external_data_configuration

    mock = Minitest::Mock.new
    mock.expect :patch_table, table_gapi,
      [project, dataset_id, table_id, request_table_gapi], options: {header: {"If-Match" => etag}}
    table.service.mocked_service = mock

    table.external = bigquery.external "gs://my-bucket/path/to/file.json" do |json|
      json.schema do |s|
        s.integer   "id",    description: "id description",    mode: :required
        s.string    "name",  description: "name description",  mode: :required
        s.string    "breed", description: "breed description", mode: :required
      end
    end

    mock.verify

    _(table.external).must_be_kind_of Google::Cloud::Bigquery::External::JsonSource
    _(table.external.urls).must_equal ["gs://my-bucket/path/to/file.json"]
    _(table.external.format).must_equal "NEWLINE_DELIMITED_JSON"
    _(table.external.autodetect).must_be :nil?
    _(table.external.schema).wont_be :empty?
    _(table.external.schema).must_be_kind_of Google::Cloud::Bigquery::Schema
    _(table.external.schema).must_be :frozen?
    _(table.external).must_be :frozen?
  end

  describe "hive partioning options" do
    let(:source_uri_prefix) { "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/" }
    let(:table_gapi) do
      gapi = Google::Apis::BigqueryV2::Table.from_json table_hash.to_json
      gapi.external_data_configuration = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
        source_uris: ["gs://my-bucket/path/*"],
        source_format: "PARQUET",
        hive_partitioning_options: Google::Apis::BigqueryV2::HivePartitioningOptions.new(
          mode: "AUTO",
          require_partition_filter: true,
          source_uri_prefix: source_uri_prefix
        )
      )
      gapi
    end
    let(:table) { Google::Cloud::Bigquery::Table.from_gapi table_gapi, bigquery.service }

    it "can have a permanent external data source" do
      _(table.external).must_be_kind_of Google::Cloud::Bigquery::External::DataSource
      _(table.external).must_be :frozen?
      _(table.external.urls).must_equal ["gs://my-bucket/path/*"]
      _(table.external.format).must_equal "PARQUET"
      _(table.external.parquet?).must_equal true
      _(table.external.hive_partitioning?).must_equal true
      _(table.external.hive_partitioning_mode).must_equal "AUTO"
      _(table.external.hive_partitioning_require_partition_filter?).must_equal true
      _(table.external.hive_partitioning_source_uri_prefix).must_equal source_uri_prefix
    end
  end
end
