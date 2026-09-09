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

describe Google::Cloud::Bigquery::External::AvroSource do
  let(:source_uri) { "gs://my-bucket/path/to/*.avro" }
  let(:source_format) { "AVRO" }

  it "can be used for AVRO" do
    table = Google::Cloud::Bigquery::External::AvroSource.new.tap do |e|
      e.gapi.source_uris = [source_uri]
      e.gapi.source_format = source_format
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: [source_uri],
      source_format: source_format,
      avro_options: Google::Apis::BigqueryV2::AvroOptions.new
    )

    _(table).must_be_kind_of Google::Cloud::Bigquery::External::DataSource
    _(table.urls).must_equal [source_uri]
    _(table).must_be :avro?
    _(table.format).must_equal source_format

    _(table).wont_be :csv?
    _(table).wont_be :json?
    _(table).wont_be :parquet?
    _(table).wont_be :backup?
    _(table).wont_be :bigtable?
    _(table).wont_be :sheets?

    _(table.to_gapi.to_h).must_equal table_gapi.to_h
  end

  it "sets use_avro_logical_types" do
    table = Google::Cloud::Bigquery::External::AvroSource.new.tap do |e|
      e.gapi.source_uris = [source_uri]
      e.gapi.source_format = source_format
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: [source_uri],
      source_format: source_format,
      avro_options: Google::Apis::BigqueryV2::AvroOptions.new(
        use_avro_logical_types: true
      )
    )

    _(table.use_avro_logical_types).must_be :nil?

    table.use_avro_logical_types = true

    _(table.use_avro_logical_types).must_equal true

    _(table.to_gapi.to_h).must_equal table_gapi.to_h
  end
end
