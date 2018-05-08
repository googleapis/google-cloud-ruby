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

describe Google::Cloud::Bigquery::External::JsonSource do
  it "can be used for JSON" do
    table = Google::Cloud::Bigquery::External::JsonSource.new.tap do |e|
      e.gapi.source_uris = ["gs://my-bucket/path/to/file.json"]
      e.gapi.source_format = "NEWLINE_DELIMITED_JSON"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["gs://my-bucket/path/to/file.json"],
      source_format: "NEWLINE_DELIMITED_JSON"
    )

    table.must_be_kind_of Google::Cloud::Bigquery::External::DataSource
    table.urls.must_equal ["gs://my-bucket/path/to/file.json"]
    table.must_be :json?
    table.format.must_equal "NEWLINE_DELIMITED_JSON"

    table.wont_be :csv?
    table.wont_be :sheets?
    table.wont_be :avro?
    table.wont_be :backup?
    table.wont_be :bigtable?

    table.to_gapi.to_h.must_equal table_gapi.to_h
  end

  it "sets schema using block" do
    table = Google::Cloud::Bigquery::External::JsonSource.new.tap do |e|
      e.gapi.source_uris = ["gs://my-bucket/path/to/file.json"]
      e.gapi.source_format = "NEWLINE_DELIMITED_JSON"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["gs://my-bucket/path/to/file.json"],
      source_format: "NEWLINE_DELIMITED_JSON",
      schema: Google::Apis::BigqueryV2::TableSchema.new(fields: [
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "name",          type: "STRING", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "age",           type: "INTEGER", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "score",         type: "FLOAT", description: "A score from 0.0 to 10.0", fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "pi",            type: "NUMERIC", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "active",        type: "BOOLEAN", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "avatar",        type: "BYTES", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "started_at",    type: "TIMESTAMP", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "duration",      type: "TIME", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "target_end",    type: "DATETIME", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "birthday",      type: "DATE", description: nil, fields: [])
      ])
    )

    table.schema.must_be_kind_of Google::Cloud::Bigquery::Schema
    table.schema.must_be :empty?

    table.schema do |s|
      s.string "name", mode: :required
      s.integer "age"
      s.float "score", description: "A score from 0.0 to 10.0"
      s.numeric "pi"
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
    table.headers.must_equal [:name, :age, :score, :pi, :active, :avatar, :started_at, :duration, :target_end, :birthday]

    table.to_gapi.to_h.must_equal table_gapi.to_h
  end

  it "sets schema using object" do
    table = Google::Cloud::Bigquery::External::JsonSource.new.tap do |e|
      e.gapi.source_uris = ["gs://my-bucket/path/to/file.json"]
      e.gapi.source_format = "NEWLINE_DELIMITED_JSON"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["gs://my-bucket/path/to/file.json"],
      source_format: "NEWLINE_DELIMITED_JSON",
      schema: Google::Apis::BigqueryV2::TableSchema.new(fields: [
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "REQUIRED", name: "name",          type: "STRING", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "age",           type: "INTEGER", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "score",         type: "FLOAT", description: "A score from 0.0 to 10.0", fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "pi",            type: "NUMERIC", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "active",        type: "BOOLEAN", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "avatar",        type: "BYTES", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "started_at",    type: "TIMESTAMP", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "duration",      type: "TIME", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "target_end",    type: "DATETIME", description: nil, fields: []),
        Google::Apis::BigqueryV2::TableFieldSchema.new(mode: "NULLABLE", name: "birthday",      type: "DATE", description: nil, fields: [])
      ])
    )

    table.schema.must_be_kind_of Google::Cloud::Bigquery::Schema
    table.schema.must_be :empty?

    # this object is usually created by calling bigquery.schema
    schema = Google::Cloud::Bigquery::Schema.from_gapi
    schema.string "name", mode: :required
    schema.integer "age"
    schema.float "score", description: "A score from 0.0 to 10.0"
    schema.numeric "pi"
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
    table.headers.must_equal [:name, :age, :score, :pi, :active, :avatar, :started_at, :duration, :target_end, :birthday]

    table.to_gapi.to_h.must_equal table_gapi.to_h
  end
end
