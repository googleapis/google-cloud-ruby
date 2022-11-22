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

describe Google::Cloud::Bigquery::External::DataSource do
  it "can be used for DATASTORE_BACKUP" do
    table = Google::Cloud::Bigquery::External::DataSource.new.tap do |e|
      e.gapi.source_uris = ["gs://my-bucket/path/to/file.backup_info"]
      e.gapi.source_format = "DATASTORE_BACKUP"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["gs://my-bucket/path/to/file.backup_info"],
      source_format: "DATASTORE_BACKUP"
    )

    _(table).must_be_kind_of Google::Cloud::Bigquery::External::DataSource
    _(table.urls).must_equal ["gs://my-bucket/path/to/file.backup_info"]
    _(table).must_be :backup?
    _(table.format).must_equal "DATASTORE_BACKUP"

    _(table).wont_be :csv?
    _(table).wont_be :json?
    _(table).wont_be :sheets?
    _(table).wont_be :avro?
    _(table).wont_be :bigtable?

    _(table.to_gapi.to_h).must_equal table_gapi.to_h
  end

  it "sets autodetect" do
    table = Google::Cloud::Bigquery::External::DataSource.new.tap do |e|
      e.gapi.source_uris = ["gs://my-bucket/path/to/*.avro"]
      e.gapi.source_format = "AVRO"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["gs://my-bucket/path/to/*.avro"],
      source_format: "AVRO",
      autodetect: true
    )

    _(table.autodetect).must_be :nil?

    table.autodetect = true

    _(table.autodetect).must_equal true

    _(table.to_gapi.to_h).must_equal table_gapi.to_h
  end

  it "sets compression" do
    table = Google::Cloud::Bigquery::External::DataSource.new.tap do |e|
      e.gapi.source_uris = ["gs://my-bucket/path/to/*.avro"]
      e.gapi.source_format = "AVRO"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["gs://my-bucket/path/to/*.avro"],
      source_format: "AVRO",
      compression: "GZIP"
    )

    _(table.compression).must_be :nil?

    table.compression = "GZIP"

    _(table.compression).must_equal "GZIP"

    _(table.to_gapi.to_h).must_equal table_gapi.to_h
  end

  it "sets ignore_unknown" do
    table = Google::Cloud::Bigquery::External::DataSource.new.tap do |e|
      e.gapi.source_uris = ["gs://my-bucket/path/to/*.avro"]
      e.gapi.source_format = "AVRO"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["gs://my-bucket/path/to/*.avro"],
      source_format: "AVRO",
      ignore_unknown_values: true
    )

    _(table.ignore_unknown).must_be :nil?

    table.ignore_unknown = true

    _(table.ignore_unknown).must_equal true

    _(table.to_gapi.to_h).must_equal table_gapi.to_h
  end

  it "sets max_bad_records" do
    table = Google::Cloud::Bigquery::External::DataSource.new.tap do |e|
      e.gapi.source_uris = ["gs://my-bucket/path/to/*.avro"]
      e.gapi.source_format = "AVRO"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["gs://my-bucket/path/to/*.avro"],
      source_format: "AVRO",
      max_bad_records: 10
    )

    _(table.max_bad_records).must_be :nil?

    table.max_bad_records = 10

    _(table.max_bad_records).must_equal 10

    _(table.to_gapi.to_h).must_equal table_gapi.to_h
  end
end
