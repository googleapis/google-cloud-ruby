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

require "bigquery_helper"
require "csv"

describe Google::Cloud::Bigquery::Table, :external, :bigquery do
  let(:dataset_id) { "#{prefix}_dataset" }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      d = bigquery.create_dataset dataset_id
    end
    d
  end
  let(:data) do
    [
      ["id", "name", "breed"],
      [4, "silvano", "the cat kind"],
      [5, "ryan", "golden retriever?"],
      [6, "stephen", "idkanycatbreeds"]
    ]
  end
  let(:data_csv) { CSV.generate { |csv| data.each { |row| csv << row } } }
  let(:data_io) { StringIO.new data_csv }
  let(:storage) { Google::Cloud.storage }
  let(:file) { bucket.file("pets.csv") || bucket.create_file(data_io, "pets.csv") }

  it "creates a table pointing to external CSV (with autodetect)" do
    external_data = dataset.external file.to_gs_url do |ext|
      _(ext).must_be_kind_of Google::Cloud::Bigquery::External::CsvSource
      ext.skip_leading_rows = 1
      ext.autodetect = true
    end

    table_id = "pets_#{SecureRandom.hex(4)}"
    table = dataset.create_table table_id do |tbl|
      tbl.external = external_data
    end

    _(table).must_be :external?
    _(table.external).wont_be :nil?
    _(table.external).must_be :frozen?
    _(table.external).must_be_kind_of Google::Cloud::Bigquery::External::CsvSource

    data = dataset.query "SELECT id, name, breed FROM #{table_id} ORDER BY id"
    _(data.count).must_equal 3
    _(data).must_equal [
      { id: 4, name: "silvano", breed: "the cat kind" },
      { id: 5, name: "ryan", breed: "golden retriever?" },
      { id: 6, name: "stephen", breed: "idkanycatbreeds" }
    ]
  end

  it "creates a table pointing to external CSV (with schema)" do
    external_data = dataset.external file.to_gs_url do |ext|
      _(ext).must_be_kind_of Google::Cloud::Bigquery::External::CsvSource
      ext.skip_leading_rows = 1
      ext.schema do |s|
        s.integer   "id",    description: "id description",    mode: :required
        s.string    "name",  description: "name description",  mode: :required
        s.string    "breed", description: "breed description", mode: :required
      end
    end

    table_id = "pets_#{SecureRandom.hex(4)}"
    table = dataset.create_table table_id do |tbl|
      tbl.external = external_data
    end

    _(table).must_be :external?
    _(table.external).wont_be :nil?
    _(table.external).must_be :frozen?
    _(table.external).must_be_kind_of Google::Cloud::Bigquery::External::CsvSource

    data = dataset.query "SELECT id, name, breed FROM #{table_id} ORDER BY id"
    _(data.count).must_equal 3
    _(data).must_equal [
      { id: 4, name: "silvano", breed: "the cat kind" },
      { id: 5, name: "ryan", breed: "golden retriever?" },
      { id: 6, name: "stephen", breed: "idkanycatbreeds" }
    ]
  end

  it "creates a table pointing to external hive partitioning parquet (with AUTO)" do
    gcs_uri = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/*"
    source_uri_prefix = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/"

    external_data = dataset.external gcs_uri, format: :parquet do |ext|
      ext.hive_partitioning_mode = :auto
      ext.hive_partitioning_require_partition_filter = true
      ext.hive_partitioning_source_uri_prefix = source_uri_prefix
    end

    _(external_data).must_be_kind_of Google::Cloud::Bigquery::External::DataSource
    _(external_data.format).must_equal "PARQUET"
    _(external_data.parquet?).must_equal true
    _(external_data.hive_partitioning?).must_equal true
    _(external_data.hive_partitioning_mode).must_equal "AUTO"
    _(external_data.hive_partitioning_require_partition_filter?).must_equal true
    _(external_data.hive_partitioning_source_uri_prefix).must_equal source_uri_prefix

    table_id = "hive_#{SecureRandom.hex(4)}"
    table = dataset.create_table table_id do |tbl|
      tbl.external = external_data
    end

    _(table).must_be :external?
    _(table.external).wont_be :nil?
    _(table.external).must_be :frozen?
    _(table.external).must_be_kind_of Google::Cloud::Bigquery::External::DataSource
    _(table.external.format).must_equal "PARQUET"
    _(table.external.parquet?).must_equal true
    _(table.external.hive_partitioning?).must_equal true
    _(table.external.hive_partitioning_mode).must_equal "AUTO"
    _(table.external.hive_partitioning_require_partition_filter?).must_equal true
    _(table.external.hive_partitioning_source_uri_prefix).must_equal source_uri_prefix

    data = dataset.query "SELECT * FROM #{table_id} WHERE dt = '2020-11-15' LIMIT 3"
    _(data.count).must_equal 3
    _(data.first[:name]).must_equal "Alabama"
  end
end
