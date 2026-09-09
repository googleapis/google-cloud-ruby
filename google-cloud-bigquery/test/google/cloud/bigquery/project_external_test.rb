# Copyright 2017 Google LLC
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

describe Google::Cloud::Bigquery::Project, :external, :mock_bigquery do
  let(:source_uri_prefix) { "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/" }
  it "raises if not given valid arguments" do
    expect { bigquery.external nil }.must_raise ArgumentError
  end

  it "creates a simple external table" do
    external = bigquery.external "gs://my-bucket/path/to/file.csv"
    _(external).must_be_instance_of Google::Cloud::Bigquery::External::CsvSource
    _(external.urls).must_equal ["gs://my-bucket/path/to/file.csv"]
    _(external).must_be :csv?
    _(external.format).must_equal "CSV"
  end

  it "creates an external data source with hive partitioning options" do
    external_data = bigquery.external "gs://my-bucket/path/*", format: :parquet do |ext|
      ext.hive_partitioning_mode = :auto
      ext.hive_partitioning_require_partition_filter = true
      ext.hive_partitioning_source_uri_prefix = source_uri_prefix
    end

    _(external_data).must_be_instance_of Google::Cloud::Bigquery::External::ParquetSource
    _(external_data.format).must_equal "PARQUET"
    _(external_data.parquet?).must_equal true
    _(external_data.hive_partitioning_mode).must_equal "AUTO"
    _(external_data.hive_partitioning_require_partition_filter?).must_equal true
    _(external_data.hive_partitioning_source_uri_prefix).must_equal source_uri_prefix
  end

  describe "CSV" do
    it "determines CSV from one URL" do
      external = bigquery.external "gs://my-bucket/path/to/file.csv"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::CsvSource
      _(external.urls).must_equal ["gs://my-bucket/path/to/file.csv"]
      _(external).must_be :csv?
      _(external.format).must_equal "CSV"
    end

    it "determines CSV from multiple URL" do
      external = bigquery.external ["some url", "gs://my-bucket/path/to/file.csv"]
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::CsvSource
      _(external.urls).must_equal ["some url", "gs://my-bucket/path/to/file.csv"]
      _(external).must_be :csv?
      _(external.format).must_equal "CSV"
    end

    it "determines CSV from the format (:csv)" do
      external = bigquery.external "some url", format: :csv
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::CsvSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :csv?
      _(external.format).must_equal "CSV"
    end

    it "determines CSV from the format (csv)" do
      external = bigquery.external "some url", format: "csv"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::CsvSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :csv?
      _(external.format).must_equal "CSV"
    end

    it "determines CSV from the format (:CSV)" do
      external = bigquery.external "some url", format: :CSV
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::CsvSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :csv?
      _(external.format).must_equal "CSV"
    end

    it "determines CSV from the format (CSV)" do
      external = bigquery.external "some url", format: "CSV"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::CsvSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :csv?
      _(external.format).must_equal "CSV"
    end
  end

  describe "JSON" do
    it "determines JSON from one URL" do
      external = bigquery.external "gs://my-bucket/path/to/file.json"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::JsonSource
      _(external.urls).must_equal ["gs://my-bucket/path/to/file.json"]
      _(external).must_be :json?
      _(external.format).must_equal "NEWLINE_DELIMITED_JSON"
    end

    it "determines JSON from multiple URL" do
      external = bigquery.external ["some url", "gs://my-bucket/path/to/file.json"]
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::JsonSource
      _(external.urls).must_equal ["some url", "gs://my-bucket/path/to/file.json"]
      _(external).must_be :json?
      _(external.format).must_equal "NEWLINE_DELIMITED_JSON"
    end

    it "determines JSON from the format (:json)" do
      external = bigquery.external "some url", format: :json
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::JsonSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :json?
      _(external.format).must_equal "NEWLINE_DELIMITED_JSON"
    end

    it "determines JSON from the format (json)" do
      external = bigquery.external "some url", format: "json"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::JsonSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :json?
      _(external.format).must_equal "NEWLINE_DELIMITED_JSON"
    end

    it "determines JSON from the format (:JSON)" do
      external = bigquery.external "some url", format: :JSON
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::JsonSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :json?
      _(external.format).must_equal "NEWLINE_DELIMITED_JSON"
    end

    it "determines JSON from the format (JSON)" do
      external = bigquery.external "some url", format: "JSON"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::JsonSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :json?
      _(external.format).must_equal "NEWLINE_DELIMITED_JSON"
    end

    it "determines JSON from the format (:newline_delimited_json)" do
      external = bigquery.external "some url", format: :newline_delimited_json
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::JsonSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :json?
      _(external.format).must_equal "NEWLINE_DELIMITED_JSON"
    end

    it "determines JSON from the format (newline_delimited_json)" do
      external = bigquery.external "some url", format: "newline_delimited_json"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::JsonSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :json?
      _(external.format).must_equal "NEWLINE_DELIMITED_JSON"
    end

    it "determines JSON from the format (:NEWLINE_DELIMITED_JSON)" do
      external = bigquery.external "some url", format: :NEWLINE_DELIMITED_JSON
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::JsonSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :json?
      _(external.format).must_equal "NEWLINE_DELIMITED_JSON"
    end

    it "determines JSON from the format (NEWLINE_DELIMITED_JSON)" do
      external = bigquery.external "some url", format: "NEWLINE_DELIMITED_JSON"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::JsonSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :json?
      _(external.format).must_equal "NEWLINE_DELIMITED_JSON"
    end
  end

  describe "Google Sheets" do
    it "determines CSV from one URL" do
      external = bigquery.external "https://docs.google.com/spreadsheets/d/1234567980"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::SheetsSource
      _(external.urls).must_equal ["https://docs.google.com/spreadsheets/d/1234567980"]
      _(external).must_be :sheets?
      _(external.format).must_equal "GOOGLE_SHEETS"
    end

    it "determines CSV from multiple URL" do
      external = bigquery.external ["some url", "https://docs.google.com/spreadsheets/d/1234567980"]
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::SheetsSource
      _(external.urls).must_equal ["some url", "https://docs.google.com/spreadsheets/d/1234567980"]
      _(external).must_be :sheets?
      _(external.format).must_equal "GOOGLE_SHEETS"
    end

    it "determines SHEETS from the format (:sheets)" do
      external = bigquery.external "some url", format: :sheets
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::SheetsSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :sheets?
      _(external.format).must_equal "GOOGLE_SHEETS"
    end

    it "determines SHEETS from the format (sheets)" do
      external = bigquery.external "some url", format: "sheets"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::SheetsSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :sheets?
      _(external.format).must_equal "GOOGLE_SHEETS"
    end

    it "determines SHEETS from the format (:SHEETS)" do
      external = bigquery.external "some url", format: :SHEETS
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::SheetsSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :sheets?
      _(external.format).must_equal "GOOGLE_SHEETS"
    end

    it "determines SHEETS from the format (SHEETS)" do
      external = bigquery.external "some url", format: "SHEETS"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::SheetsSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :sheets?
      _(external.format).must_equal "GOOGLE_SHEETS"
    end

    it "determines SHEETS from the format (:google_sheets)" do
      external = bigquery.external "some url", format: :google_sheets
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::SheetsSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :sheets?
      _(external.format).must_equal "GOOGLE_SHEETS"
    end

    it "determines SHEETS from the format (google_sheets)" do
      external = bigquery.external "some url", format: "google_sheets"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::SheetsSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :sheets?
      _(external.format).must_equal "GOOGLE_SHEETS"
    end

    it "determines SHEETS from the format (:GOOGLE_SHEETS)" do
      external = bigquery.external "some url", format: :GOOGLE_SHEETS
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::SheetsSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :sheets?
      _(external.format).must_equal "GOOGLE_SHEETS"
    end

    it "determines SHEETS from the format (GOOGLE_SHEETS)" do
      external = bigquery.external "some url", format: "GOOGLE_SHEETS"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::SheetsSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :sheets?
      _(external.format).must_equal "GOOGLE_SHEETS"
    end
  end

  describe "AVRO" do
    it "determines AVRO from one URL" do
      external = bigquery.external "gs://my-bucket/path/to/*.avro"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::AvroSource
      _(external.urls).must_equal ["gs://my-bucket/path/to/*.avro"]
      _(external).must_be :avro?
      _(external.format).must_equal "AVRO"
    end

    it "determines AVRO from multiple URL" do
      external = bigquery.external ["some url", "gs://my-bucket/path/to/*.avro"]
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::AvroSource
      _(external.urls).must_equal ["some url", "gs://my-bucket/path/to/*.avro"]
      _(external).must_be :avro?
      _(external.format).must_equal "AVRO"
    end

    it "determines AVRO from the format (:avro)" do
      external = bigquery.external "some url", format: :avro
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::AvroSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :avro?
      _(external.format).must_equal "AVRO"
    end

    it "determines AVRO from the format (avro)" do
      external = bigquery.external "some url", format: "avro"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::AvroSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :avro?
      _(external.format).must_equal "AVRO"
    end

    it "determines AVRO from the format (:AVRO)" do
      external = bigquery.external "some url", format: :AVRO
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::AvroSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :avro?
      _(external.format).must_equal "AVRO"
    end

    it "determines AVRO from the format (AVRO)" do
      external = bigquery.external "some url", format: "AVRO"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::AvroSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :avro?
      _(external.format).must_equal "AVRO"
    end
  end

  describe "Datastore Backup" do
    it "determines BACKUP from one URL" do
      external = bigquery.external "gs://my-bucket/path/to/file.backup_info"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::DataSource
      _(external.urls).must_equal ["gs://my-bucket/path/to/file.backup_info"]
      _(external).must_be :backup?
      _(external.format).must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from multiple URL" do
      external = bigquery.external ["some url", "gs://my-bucket/path/to/file.backup_info"]
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::DataSource
      _(external.urls).must_equal ["some url", "gs://my-bucket/path/to/file.backup_info"]
      _(external).must_be :backup?
      _(external.format).must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (:backup)" do
      external = bigquery.external "some url", format: :backup
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::DataSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :backup?
      _(external.format).must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (backup)" do
      external = bigquery.external "some url", format: "backup"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::DataSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :backup?
      _(external.format).must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (:BACKUP)" do
      external = bigquery.external "some url", format: :BACKUP
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::DataSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :backup?
      _(external.format).must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (BACKUP)" do
      external = bigquery.external "some url", format: "BACKUP"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::DataSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :backup?
      _(external.format).must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (:datastore)" do
      external = bigquery.external "some url", format: :datastore
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::DataSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :backup?
      _(external.format).must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (datastore)" do
      external = bigquery.external "some url", format: "datastore"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::DataSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :backup?
      _(external.format).must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (:DATASTORE)" do
      external = bigquery.external "some url", format: :DATASTORE
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::DataSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :backup?
      _(external.format).must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (DATASTORE)" do
      external = bigquery.external "some url", format: "DATASTORE"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::DataSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :backup?
      _(external.format).must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (:datastore_backup)" do
      external = bigquery.external "some url", format: :datastore_backup
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::DataSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :backup?
      _(external.format).must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (datastore_backup)" do
      external = bigquery.external "some url", format: "datastore_backup"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::DataSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :backup?
      _(external.format).must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (:DATASTORE_BACKUP)" do
      external = bigquery.external "some url", format: :DATASTORE_BACKUP
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::DataSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :backup?
      _(external.format).must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (DATASTORE_BACKUP)" do
      external = bigquery.external "some url", format: "DATASTORE_BACKUP"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::DataSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :backup?
      _(external.format).must_equal "DATASTORE_BACKUP"
    end
  end

  describe "BIGTABLE" do
    it "determines BIGTABLE from one URL" do
      external = bigquery.external "https://googleapis.com/bigtable/projects/my-project/instances/my-instance/tables/my-table"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::BigtableSource
      _(external.urls).must_equal ["https://googleapis.com/bigtable/projects/my-project/instances/my-instance/tables/my-table"]
      _(external).must_be :bigtable?
      _(external.format).must_equal "BIGTABLE"
    end

    it "determines BIGTABLE from multiple URL" do
      external = bigquery.external ["some url", "https://googleapis.com/bigtable/projects/my-project/instances/my-instance/tables/my-table"]
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::BigtableSource
      _(external.urls).must_equal ["some url", "https://googleapis.com/bigtable/projects/my-project/instances/my-instance/tables/my-table"]
      _(external).must_be :bigtable?
      _(external.format).must_equal "BIGTABLE"
    end

    it "determines BIGTABLE from the format (:bigtable)" do
      external = bigquery.external "some url", format: :bigtable
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::BigtableSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :bigtable?
      _(external.format).must_equal "BIGTABLE"
    end

    it "determines BIGTABLE from the format (bigtable)" do
      external = bigquery.external "some url", format: "bigtable"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::BigtableSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :bigtable?
      _(external.format).must_equal "BIGTABLE"
    end

    it "determines BIGTABLE from the format (:BIGTABLE)" do
      external = bigquery.external "some url", format: :BIGTABLE
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::BigtableSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :bigtable?
      _(external.format).must_equal "BIGTABLE"
    end

    it "determines BIGTABLE from the format (BIGTABLE)" do
      external = bigquery.external "some url", format: "BIGTABLE"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::BigtableSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :bigtable?
      _(external.format).must_equal "BIGTABLE"
    end
  end

  describe "ORC" do
    it "determines ORC from the format (:orc)" do
      external = bigquery.external "some url", format: :orc
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::DataSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :orc?
      _(external.format).must_equal "ORC"
    end

    it "determines ORC from the format (orc)" do
      external = bigquery.external "some url", format: "orc"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::DataSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :orc?
      _(external.format).must_equal "ORC"
    end

    it "determines ORC from the format (:ORC)" do
      external = bigquery.external "some url", format: :ORC
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::DataSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :orc?
      _(external.format).must_equal "ORC"
    end

    it "determines ORC from the format (ORC)" do
      external = bigquery.external "some url", format: "ORC"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::DataSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :orc?
      _(external.format).must_equal "ORC"
    end
  end

  describe "PARQUET" do
    it "determines PARQUET from one URL" do
      external = bigquery.external "gs://my-bucket/path/to/file.parquet"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::ParquetSource
      _(external.urls).must_equal ["gs://my-bucket/path/to/file.parquet"]
      _(external).must_be :parquet?
      _(external.format).must_equal "PARQUET"
    end

    it "determines PARQUET from multiple URL" do
      external = bigquery.external ["some url", "gs://my-bucket/path/to/file.parquet"]
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::ParquetSource
      _(external.urls).must_equal ["some url", "gs://my-bucket/path/to/file.parquet"]
      _(external).must_be :parquet?
      _(external.format).must_equal "PARQUET"
    end

    it "determines PARQUET from the format (:parquet)" do
      external = bigquery.external "some url", format: :parquet
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::ParquetSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :parquet?
      _(external.format).must_equal "PARQUET"
    end

    it "determines PARQUET from the format (parquet)" do
      external = bigquery.external "some url", format: "parquet"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::ParquetSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :parquet?
      _(external.format).must_equal "PARQUET"
    end

    it "determines PARQUET from the format (:PARQUET)" do
      external = bigquery.external "some url", format: :PARQUET
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::ParquetSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :parquet?
      _(external.format).must_equal "PARQUET"
    end

    it "determines PARQUET from the format (PARQUET)" do
      external = bigquery.external "some url", format: "PARQUET"
      _(external).must_be_instance_of Google::Cloud::Bigquery::External::ParquetSource
      _(external.urls).must_equal ["some url"]
      _(external).must_be :parquet?
      _(external.format).must_equal "PARQUET"
    end
  end
end
