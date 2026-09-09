# Copyright 2021 Google LLC
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

describe Google::Cloud::Bigquery::External::ParquetSource do
  let(:source_uri) { "gs://my-bucket/path/to/file.parquet" }
  let(:source_format) { "PARQUET" }

  it "can be used for PARQUET" do
    table = Google::Cloud::Bigquery::External::ParquetSource.new.tap do |e|
      e.gapi.source_uris = [source_uri]
      e.gapi.source_format = source_format
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: [source_uri],
      source_format: source_format,
      parquet_options: Google::Apis::BigqueryV2::ParquetOptions.new
    )

    _(table).must_be_kind_of Google::Cloud::Bigquery::External::DataSource
    _(table.urls).must_equal [source_uri]
    _(table).must_be :parquet?
    _(table.format).must_equal source_format

    _(table).wont_be :csv?
    _(table).wont_be :json?
    _(table).wont_be :avro?
    _(table).wont_be :backup?
    _(table).wont_be :bigtable?
    _(table).wont_be :sheets?

    _(table.to_gapi.to_h).must_equal table_gapi.to_h
  end

  it "sets enable_list_inference" do
    table = Google::Cloud::Bigquery::External::ParquetSource.new.tap do |e|
      e.gapi.source_uris = [source_uri]
      e.gapi.source_format = source_format
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: [source_uri],
      source_format: source_format,
      parquet_options: Google::Apis::BigqueryV2::ParquetOptions.new(
        enable_list_inference: true
      )
    )

    _(table.enable_list_inference).must_be :nil?

    table.enable_list_inference = true

    _(table.enable_list_inference).must_equal true

    _(table.to_gapi.to_h).must_equal table_gapi.to_h
  end

  it "sets enum_as_string" do
    table = Google::Cloud::Bigquery::External::ParquetSource.new.tap do |e|
      e.gapi.source_uris = [source_uri]
      e.gapi.source_format = source_format
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: [source_uri],
      source_format: source_format,
      parquet_options: Google::Apis::BigqueryV2::ParquetOptions.new(
        enum_as_string: true
      )
    )

    _(table.enum_as_string).must_be :nil?

    table.enum_as_string = true

    _(table.enum_as_string).must_equal true

    _(table.to_gapi.to_h).must_equal table_gapi.to_h
  end
end
