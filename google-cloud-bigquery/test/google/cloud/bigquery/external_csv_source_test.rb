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

describe Google::Cloud::Bigquery::External::CsvSource do
  it "can be used for CSV" do
    table = Google::Cloud::Bigquery::External::CsvSource.new.tap do |e|
      e.gapi.source_uris = ["gs://my-bucket/path/to/file.csv"]
      e.gapi.source_format = "CSV"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["gs://my-bucket/path/to/file.csv"],
      source_format: "CSV",
      csv_options: Google::Apis::BigqueryV2::CsvOptions.new
    )

    table.must_be_kind_of Google::Cloud::Bigquery::External::DataSource
    table.urls.must_equal ["gs://my-bucket/path/to/file.csv"]
    table.must_be :csv?
    table.format.must_equal "CSV"

    table.wont_be :json?
    table.wont_be :sheets?
    table.wont_be :avro?
    table.wont_be :backup?
    table.wont_be :bigtable?

    table.to_gapi.to_h.must_equal table_gapi.to_h
  end

  it "sets jagged_rows" do
    table = Google::Cloud::Bigquery::External::CsvSource.new.tap do |e|
      e.gapi.source_uris = ["gs://my-bucket/path/to/file.csv"]
      e.gapi.source_format = "CSV"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["gs://my-bucket/path/to/file.csv"],
      source_format: "CSV",
      csv_options: Google::Apis::BigqueryV2::CsvOptions.new(
        allow_jagged_rows: true
      )
    )

    table.jagged_rows.must_be :nil?

    table.jagged_rows = true

    table.jagged_rows.must_equal true

    table.to_gapi.to_h.must_equal table_gapi.to_h
  end

  it "sets quoted_newlines" do
    table = Google::Cloud::Bigquery::External::CsvSource.new.tap do |e|
      e.gapi.source_uris = ["gs://my-bucket/path/to/file.csv"]
      e.gapi.source_format = "CSV"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["gs://my-bucket/path/to/file.csv"],
      source_format: "CSV",
      csv_options: Google::Apis::BigqueryV2::CsvOptions.new(
        allow_quoted_newlines: true
      )
    )

    table.quoted_newlines.must_be :nil?

    table.quoted_newlines = true

    table.quoted_newlines.must_equal true

    table.to_gapi.to_h.must_equal table_gapi.to_h
  end

  it "sets encoding" do
    table = Google::Cloud::Bigquery::External::CsvSource.new.tap do |e|
      e.gapi.source_uris = ["gs://my-bucket/path/to/file.csv"]
      e.gapi.source_format = "CSV"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["gs://my-bucket/path/to/file.csv"],
      source_format: "CSV",
      csv_options: Google::Apis::BigqueryV2::CsvOptions.new(
        encoding: "UTF-8"
      )
    )

    table.encoding.must_be :nil?
    table.must_be :utf8? # default is UTF-8, even when encoding is not specifically set
    table.wont_be :iso8859_1?

    table.encoding = "ISO-8859-1"

    table.encoding.must_equal "ISO-8859-1"
    table.wont_be :utf8?
    table.must_be :iso8859_1?

    table.encoding = "UTF-8"

    table.encoding.must_equal "UTF-8"
    table.must_be :utf8?
    table.wont_be :iso8859_1?

    table.to_gapi.to_h.must_equal table_gapi.to_h
  end

  it "sets delimiter" do
    table = Google::Cloud::Bigquery::External::CsvSource.new.tap do |e|
      e.gapi.source_uris = ["gs://my-bucket/path/to/file.csv"]
      e.gapi.source_format = "CSV"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["gs://my-bucket/path/to/file.csv"],
      source_format: "CSV",
      csv_options: Google::Apis::BigqueryV2::CsvOptions.new(
        field_delimiter: "|"
      )
    )

    table.delimiter.must_be :nil?

    table.delimiter = "|"

    table.delimiter.must_equal "|"

    table.to_gapi.to_h.must_equal table_gapi.to_h
  end

  it "sets quote" do
    table = Google::Cloud::Bigquery::External::CsvSource.new.tap do |e|
      e.gapi.source_uris = ["gs://my-bucket/path/to/file.csv"]
      e.gapi.source_format = "CSV"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["gs://my-bucket/path/to/file.csv"],
      source_format: "CSV",
      csv_options: Google::Apis::BigqueryV2::CsvOptions.new(
        quote: "'"
      )
    )

    table.quote.must_be :nil?

    table.quote = "'"

    table.quote.must_equal "'"

    table.to_gapi.to_h.must_equal table_gapi.to_h
  end

  it "sets skip_leading_rows" do
    table = Google::Cloud::Bigquery::External::CsvSource.new.tap do |e|
      e.gapi.source_uris = ["gs://my-bucket/path/to/file.csv"]
      e.gapi.source_format = "CSV"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["gs://my-bucket/path/to/file.csv"],
      source_format: "CSV",
      csv_options: Google::Apis::BigqueryV2::CsvOptions.new(
        skip_leading_rows: true
      )
    )

    table.skip_leading_rows.must_be :nil?

    table.skip_leading_rows = true

    table.skip_leading_rows.must_equal true

    table.to_gapi.to_h.must_equal table_gapi.to_h
  end

  it "sets schema using block" do
    table = Google::Cloud::Bigquery::External::CsvSource.new.tap do |e|
      e.gapi.source_uris = ["gs://my-bucket/path/to/file.csv"]
      e.gapi.source_format = "CSV"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["gs://my-bucket/path/to/file.csv"],
      source_format: "CSV",
      schema: Google::Apis::BigqueryV2::TableSchema.new(fields: [
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "name",          type: "STRING", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "age",           type: "INTEGER", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "score",         type: "FLOAT", description: "A score from 0.0 to 10.0", fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "active",        type: "BOOLEAN", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "avatar",        type: "BYTES", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "started_at",    type: "TIMESTAMP", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "duration",      type: "TIME", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "target_end",    type: "DATETIME", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "birthday",      type: "DATE", description: nil, fields: [])
      ]),
      csv_options: Google::Apis::BigqueryV2::CsvOptions.new
    )

    table.schema.must_be_kind_of Google::Cloud::Bigquery::Schema
    table.schema.must_be :empty?

    table.schema do |s|
      s.string "name", mode: :required
      s.integer "age"
      s.float "score", description: "A score from 0.0 to 10.0"
      s.boolean "active"
      s.bytes "avatar"
      s.timestamp "started_at"
      s.time "duration"
      s.datetime "target_end"
      s.date "birthday"
    end

    table.schema.wont_be :empty?
    table.fields.must_equal table.schema.fields
    table.headers.must_equal table.schema.headers
    table.headers.must_equal [:name, :age, :score, :active, :avatar, :started_at, :duration, :target_end, :birthday]

    table.to_gapi.to_h.must_equal table_gapi.to_h
  end

  it "sets schema using object" do
    table = Google::Cloud::Bigquery::External::CsvSource.new.tap do |e|
      e.gapi.source_uris = ["gs://my-bucket/path/to/file.csv"]
      e.gapi.source_format = "CSV"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["gs://my-bucket/path/to/file.csv"],
      source_format: "CSV",
      schema: Google::Apis::BigqueryV2::TableSchema.new(fields: [
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "name",          type: "STRING", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "age",           type: "INTEGER", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "score",         type: "FLOAT", description: "A score from 0.0 to 10.0", fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "active",        type: "BOOLEAN", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "avatar",        type: "BYTES", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "started_at",    type: "TIMESTAMP", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "duration",      type: "TIME", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "target_end",    type: "DATETIME", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "birthday",      type: "DATE", description: nil, fields: [])
      ]),
      csv_options: Google::Apis::BigqueryV2::CsvOptions.new
    )

    table.schema.must_be_kind_of Google::Cloud::Bigquery::Schema
    table.schema.must_be :empty?

    # this object is usually created by calling bigquery.schema
    schema = Google::Cloud::Bigquery::Schema.from_gapi
    schema.string "name", mode: :required
    schema.integer "age"
    schema.float "score", description: "A score from 0.0 to 10.0"
    schema.boolean "active"
    schema.bytes "avatar"
    schema.timestamp "started_at"
    schema.time "duration"
    schema.datetime "target_end"
    schema.date "birthday"

    table.schema = schema

    table.schema.wont_be :empty?
    table.fields.must_equal table.schema.fields
    table.headers.must_equal table.schema.headers
    table.headers.must_equal [:name, :age, :score, :active, :avatar, :started_at, :duration, :target_end, :birthday]

    table.to_gapi.to_h.must_equal table_gapi.to_h
  end
end
