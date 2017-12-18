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
  it "raises if not given valid arguments" do
    expect { bigquery.external nil }.must_raise ArgumentError
  end

  it "creates a simple external table" do
    external = bigquery.external "gs://my-bucket/path/to/file.csv"
    external.must_be_kind_of Google::Cloud::Bigquery::External::CsvSource
    external.urls.must_equal ["gs://my-bucket/path/to/file.csv"]
    external.must_be :csv?
    external.format.must_equal "CSV"
  end

  describe "CSV" do
    it "determines CSV from one URL" do
      external = bigquery.external "gs://my-bucket/path/to/file.csv"
      external.must_be_kind_of Google::Cloud::Bigquery::External::CsvSource
      external.urls.must_equal ["gs://my-bucket/path/to/file.csv"]
      external.must_be :csv?
      external.format.must_equal "CSV"
    end

    it "determines CSV from multiple URL" do
      external = bigquery.external ["some url", "gs://my-bucket/path/to/file.csv"]
      external.must_be_kind_of Google::Cloud::Bigquery::External::CsvSource
      external.urls.must_equal ["some url", "gs://my-bucket/path/to/file.csv"]
      external.must_be :csv?
      external.format.must_equal "CSV"
    end

    it "determines CSV from the format (:csv)" do
      external = bigquery.external "some url", format: :csv
      external.must_be_kind_of Google::Cloud::Bigquery::External::CsvSource
      external.urls.must_equal ["some url"]
      external.must_be :csv?
      external.format.must_equal "CSV"
    end

    it "determines CSV from the format (csv)" do
      external = bigquery.external "some url", format: "csv"
      external.must_be_kind_of Google::Cloud::Bigquery::External::CsvSource
      external.urls.must_equal ["some url"]
      external.must_be :csv?
      external.format.must_equal "CSV"
    end

    it "determines CSV from the format (:CSV)" do
      external = bigquery.external "some url", format: :CSV
      external.must_be_kind_of Google::Cloud::Bigquery::External::CsvSource
      external.urls.must_equal ["some url"]
      external.must_be :csv?
      external.format.must_equal "CSV"
    end

    it "determines CSV from the format (CSV)" do
      external = bigquery.external "some url", format: "CSV"
      external.must_be_kind_of Google::Cloud::Bigquery::External::CsvSource
      external.urls.must_equal ["some url"]
      external.must_be :csv?
      external.format.must_equal "CSV"
    end
  end

  describe "JSON" do
    it "determines JSON from one URL" do
      external = bigquery.external "gs://my-bucket/path/to/file.json"
      external.must_be_kind_of Google::Cloud::Bigquery::External::JsonSource
      external.urls.must_equal ["gs://my-bucket/path/to/file.json"]
      external.must_be :json?
      external.format.must_equal "NEWLINE_DELIMITED_JSON"
    end

    it "determines JSON from multiple URL" do
      external = bigquery.external ["some url", "gs://my-bucket/path/to/file.json"]
      external.must_be_kind_of Google::Cloud::Bigquery::External::JsonSource
      external.urls.must_equal ["some url", "gs://my-bucket/path/to/file.json"]
      external.must_be :json?
      external.format.must_equal "NEWLINE_DELIMITED_JSON"
    end

    it "determines JSON from the format (:json)" do
      external = bigquery.external "some url", format: :json
      external.must_be_kind_of Google::Cloud::Bigquery::External::JsonSource
      external.urls.must_equal ["some url"]
      external.must_be :json?
      external.format.must_equal "NEWLINE_DELIMITED_JSON"
    end

    it "determines JSON from the format (json)" do
      external = bigquery.external "some url", format: "json"
      external.must_be_kind_of Google::Cloud::Bigquery::External::JsonSource
      external.urls.must_equal ["some url"]
      external.must_be :json?
      external.format.must_equal "NEWLINE_DELIMITED_JSON"
    end

    it "determines JSON from the format (:JSON)" do
      external = bigquery.external "some url", format: :JSON
      external.must_be_kind_of Google::Cloud::Bigquery::External::JsonSource
      external.urls.must_equal ["some url"]
      external.must_be :json?
      external.format.must_equal "NEWLINE_DELIMITED_JSON"
    end

    it "determines JSON from the format (JSON)" do
      external = bigquery.external "some url", format: "JSON"
      external.must_be_kind_of Google::Cloud::Bigquery::External::JsonSource
      external.urls.must_equal ["some url"]
      external.must_be :json?
      external.format.must_equal "NEWLINE_DELIMITED_JSON"
    end

    it "determines JSON from the format (:newline_delimited_json)" do
      external = bigquery.external "some url", format: :newline_delimited_json
      external.must_be_kind_of Google::Cloud::Bigquery::External::JsonSource
      external.urls.must_equal ["some url"]
      external.must_be :json?
      external.format.must_equal "NEWLINE_DELIMITED_JSON"
    end

    it "determines JSON from the format (newline_delimited_json)" do
      external = bigquery.external "some url", format: "newline_delimited_json"
      external.must_be_kind_of Google::Cloud::Bigquery::External::JsonSource
      external.urls.must_equal ["some url"]
      external.must_be :json?
      external.format.must_equal "NEWLINE_DELIMITED_JSON"
    end

    it "determines JSON from the format (:NEWLINE_DELIMITED_JSON)" do
      external = bigquery.external "some url", format: :NEWLINE_DELIMITED_JSON
      external.must_be_kind_of Google::Cloud::Bigquery::External::JsonSource
      external.urls.must_equal ["some url"]
      external.must_be :json?
      external.format.must_equal "NEWLINE_DELIMITED_JSON"
    end

    it "determines JSON from the format (NEWLINE_DELIMITED_JSON)" do
      external = bigquery.external "some url", format: "NEWLINE_DELIMITED_JSON"
      external.must_be_kind_of Google::Cloud::Bigquery::External::JsonSource
      external.urls.must_equal ["some url"]
      external.must_be :json?
      external.format.must_equal "NEWLINE_DELIMITED_JSON"
    end
  end

  describe "Google Sheets" do
    it "determines CSV from one URL" do
      external = bigquery.external "https://docs.google.com/spreadsheets/d/1234567980"
      external.must_be_kind_of Google::Cloud::Bigquery::External::SheetsSource
      external.urls.must_equal ["https://docs.google.com/spreadsheets/d/1234567980"]
      external.must_be :sheets?
      external.format.must_equal "GOOGLE_SHEETS"
    end

    it "determines CSV from multiple URL" do
      external = bigquery.external ["some url", "https://docs.google.com/spreadsheets/d/1234567980"]
      external.must_be_kind_of Google::Cloud::Bigquery::External::SheetsSource
      external.urls.must_equal ["some url", "https://docs.google.com/spreadsheets/d/1234567980"]
      external.must_be :sheets?
      external.format.must_equal "GOOGLE_SHEETS"
    end

    it "determines SHEETS from the format (:sheets)" do
      external = bigquery.external "some url", format: :sheets
      external.must_be_kind_of Google::Cloud::Bigquery::External::SheetsSource
      external.urls.must_equal ["some url"]
      external.must_be :sheets?
      external.format.must_equal "GOOGLE_SHEETS"
    end

    it "determines SHEETS from the format (sheets)" do
      external = bigquery.external "some url", format: "sheets"
      external.must_be_kind_of Google::Cloud::Bigquery::External::SheetsSource
      external.urls.must_equal ["some url"]
      external.must_be :sheets?
      external.format.must_equal "GOOGLE_SHEETS"
    end

    it "determines SHEETS from the format (:SHEETS)" do
      external = bigquery.external "some url", format: :SHEETS
      external.must_be_kind_of Google::Cloud::Bigquery::External::SheetsSource
      external.urls.must_equal ["some url"]
      external.must_be :sheets?
      external.format.must_equal "GOOGLE_SHEETS"
    end

    it "determines SHEETS from the format (SHEETS)" do
      external = bigquery.external "some url", format: "SHEETS"
      external.must_be_kind_of Google::Cloud::Bigquery::External::SheetsSource
      external.urls.must_equal ["some url"]
      external.must_be :sheets?
      external.format.must_equal "GOOGLE_SHEETS"
    end

    it "determines SHEETS from the format (:google_sheets)" do
      external = bigquery.external "some url", format: :google_sheets
      external.must_be_kind_of Google::Cloud::Bigquery::External::SheetsSource
      external.urls.must_equal ["some url"]
      external.must_be :sheets?
      external.format.must_equal "GOOGLE_SHEETS"
    end

    it "determines SHEETS from the format (google_sheets)" do
      external = bigquery.external "some url", format: "google_sheets"
      external.must_be_kind_of Google::Cloud::Bigquery::External::SheetsSource
      external.urls.must_equal ["some url"]
      external.must_be :sheets?
      external.format.must_equal "GOOGLE_SHEETS"
    end

    it "determines SHEETS from the format (:GOOGLE_SHEETS)" do
      external = bigquery.external "some url", format: :GOOGLE_SHEETS
      external.must_be_kind_of Google::Cloud::Bigquery::External::SheetsSource
      external.urls.must_equal ["some url"]
      external.must_be :sheets?
      external.format.must_equal "GOOGLE_SHEETS"
    end

    it "determines SHEETS from the format (GOOGLE_SHEETS)" do
      external = bigquery.external "some url", format: "GOOGLE_SHEETS"
      external.must_be_kind_of Google::Cloud::Bigquery::External::SheetsSource
      external.urls.must_equal ["some url"]
      external.must_be :sheets?
      external.format.must_equal "GOOGLE_SHEETS"
    end
  end

  describe "AVRO" do
    it "determines AVRO from one URL" do
      external = bigquery.external "gs://my-bucket/path/to/file.avro"
      external.must_be_kind_of Google::Cloud::Bigquery::External::DataSource
      external.urls.must_equal ["gs://my-bucket/path/to/file.avro"]
      external.must_be :avro?
      external.format.must_equal "AVRO"
    end

    it "determines AVRO from multiple URL" do
      external = bigquery.external ["some url", "gs://my-bucket/path/to/file.avro"]
      external.must_be_kind_of Google::Cloud::Bigquery::External::DataSource
      external.urls.must_equal ["some url", "gs://my-bucket/path/to/file.avro"]
      external.must_be :avro?
      external.format.must_equal "AVRO"
    end

    it "determines AVRO from the format (:avro)" do
      external = bigquery.external "some url", format: :avro
      external.must_be_kind_of Google::Cloud::Bigquery::External::DataSource
      external.urls.must_equal ["some url"]
      external.must_be :avro?
      external.format.must_equal "AVRO"
    end

    it "determines AVRO from the format (avro)" do
      external = bigquery.external "some url", format: "avro"
      external.must_be_kind_of Google::Cloud::Bigquery::External::DataSource
      external.urls.must_equal ["some url"]
      external.must_be :avro?
      external.format.must_equal "AVRO"
    end

    it "determines AVRO from the format (:AVRO)" do
      external = bigquery.external "some url", format: :AVRO
      external.must_be_kind_of Google::Cloud::Bigquery::External::DataSource
      external.urls.must_equal ["some url"]
      external.must_be :avro?
      external.format.must_equal "AVRO"
    end

    it "determines AVRO from the format (AVRO)" do
      external = bigquery.external "some url", format: "AVRO"
      external.must_be_kind_of Google::Cloud::Bigquery::External::DataSource
      external.urls.must_equal ["some url"]
      external.must_be :avro?
      external.format.must_equal "AVRO"
    end
  end

  describe "Datastore Backup" do
    it "determines BACKUP from one URL" do
      external = bigquery.external "gs://my-bucket/path/to/file.backup_info"
      external.must_be_kind_of Google::Cloud::Bigquery::External::DataSource
      external.urls.must_equal ["gs://my-bucket/path/to/file.backup_info"]
      external.must_be :backup?
      external.format.must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from multiple URL" do
      external = bigquery.external ["some url", "gs://my-bucket/path/to/file.backup_info"]
      external.must_be_kind_of Google::Cloud::Bigquery::External::DataSource
      external.urls.must_equal ["some url", "gs://my-bucket/path/to/file.backup_info"]
      external.must_be :backup?
      external.format.must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (:backup)" do
      external = bigquery.external "some url", format: :backup
      external.must_be_kind_of Google::Cloud::Bigquery::External::DataSource
      external.urls.must_equal ["some url"]
      external.must_be :backup?
      external.format.must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (backup)" do
      external = bigquery.external "some url", format: "backup"
      external.must_be_kind_of Google::Cloud::Bigquery::External::DataSource
      external.urls.must_equal ["some url"]
      external.must_be :backup?
      external.format.must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (:BACKUP)" do
      external = bigquery.external "some url", format: :BACKUP
      external.must_be_kind_of Google::Cloud::Bigquery::External::DataSource
      external.urls.must_equal ["some url"]
      external.must_be :backup?
      external.format.must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (BACKUP)" do
      external = bigquery.external "some url", format: "BACKUP"
      external.must_be_kind_of Google::Cloud::Bigquery::External::DataSource
      external.urls.must_equal ["some url"]
      external.must_be :backup?
      external.format.must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (:datastore)" do
      external = bigquery.external "some url", format: :datastore
      external.must_be_kind_of Google::Cloud::Bigquery::External::DataSource
      external.urls.must_equal ["some url"]
      external.must_be :backup?
      external.format.must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (datastore)" do
      external = bigquery.external "some url", format: "datastore"
      external.must_be_kind_of Google::Cloud::Bigquery::External::DataSource
      external.urls.must_equal ["some url"]
      external.must_be :backup?
      external.format.must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (:DATASTORE)" do
      external = bigquery.external "some url", format: :DATASTORE
      external.must_be_kind_of Google::Cloud::Bigquery::External::DataSource
      external.urls.must_equal ["some url"]
      external.must_be :backup?
      external.format.must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (DATASTORE)" do
      external = bigquery.external "some url", format: "DATASTORE"
      external.must_be_kind_of Google::Cloud::Bigquery::External::DataSource
      external.urls.must_equal ["some url"]
      external.must_be :backup?
      external.format.must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (:datastore_backup)" do
      external = bigquery.external "some url", format: :datastore_backup
      external.must_be_kind_of Google::Cloud::Bigquery::External::DataSource
      external.urls.must_equal ["some url"]
      external.must_be :backup?
      external.format.must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (datastore_backup)" do
      external = bigquery.external "some url", format: "datastore_backup"
      external.must_be_kind_of Google::Cloud::Bigquery::External::DataSource
      external.urls.must_equal ["some url"]
      external.must_be :backup?
      external.format.must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (:DATASTORE_BACKUP)" do
      external = bigquery.external "some url", format: :DATASTORE_BACKUP
      external.must_be_kind_of Google::Cloud::Bigquery::External::DataSource
      external.urls.must_equal ["some url"]
      external.must_be :backup?
      external.format.must_equal "DATASTORE_BACKUP"
    end

    it "determines BACKUP from the format (DATASTORE_BACKUP)" do
      external = bigquery.external "some url", format: "DATASTORE_BACKUP"
      external.must_be_kind_of Google::Cloud::Bigquery::External::DataSource
      external.urls.must_equal ["some url"]
      external.must_be :backup?
      external.format.must_equal "DATASTORE_BACKUP"
    end
  end

  describe "BIGTABLE" do
    it "determines BIGTABLE from one URL" do
      external = bigquery.external "https://googleapis.com/bigtable/projects/my-project/instances/my-instance/tables/my-table"
      external.must_be_kind_of Google::Cloud::Bigquery::External::BigtableSource
      external.urls.must_equal ["https://googleapis.com/bigtable/projects/my-project/instances/my-instance/tables/my-table"]
      external.must_be :bigtable?
      external.format.must_equal "BIGTABLE"
    end

    it "determines BIGTABLE from multiple URL" do
      external = bigquery.external ["some url", "https://googleapis.com/bigtable/projects/my-project/instances/my-instance/tables/my-table"]
      external.must_be_kind_of Google::Cloud::Bigquery::External::BigtableSource
      external.urls.must_equal ["some url", "https://googleapis.com/bigtable/projects/my-project/instances/my-instance/tables/my-table"]
      external.must_be :bigtable?
      external.format.must_equal "BIGTABLE"
    end

    it "determines BIGTABLE from the format (:bigtable)" do
      external = bigquery.external "some url", format: :bigtable
      external.must_be_kind_of Google::Cloud::Bigquery::External::BigtableSource
      external.urls.must_equal ["some url"]
      external.must_be :bigtable?
      external.format.must_equal "BIGTABLE"
    end

    it "determines BIGTABLE from the format (bigtable)" do
      external = bigquery.external "some url", format: "bigtable"
      external.must_be_kind_of Google::Cloud::Bigquery::External::BigtableSource
      external.urls.must_equal ["some url"]
      external.must_be :bigtable?
      external.format.must_equal "BIGTABLE"
    end

    it "determines BIGTABLE from the format (:BIGTABLE)" do
      external = bigquery.external "some url", format: :BIGTABLE
      external.must_be_kind_of Google::Cloud::Bigquery::External::BigtableSource
      external.urls.must_equal ["some url"]
      external.must_be :bigtable?
      external.format.must_equal "BIGTABLE"
    end

    it "determines BIGTABLE from the format (BIGTABLE)" do
      external = bigquery.external "some url", format: "BIGTABLE"
      external.must_be_kind_of Google::Cloud::Bigquery::External::BigtableSource
      external.urls.must_equal ["some url"]
      external.must_be :bigtable?
      external.format.must_equal "BIGTABLE"
    end
  end
end
