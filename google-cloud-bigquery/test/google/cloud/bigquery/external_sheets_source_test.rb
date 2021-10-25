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

describe Google::Cloud::Bigquery::External::SheetsSource do
  it "can be used for GOOGLE_SHEETS" do
    table = Google::Cloud::Bigquery::External::SheetsSource.new.tap do |e|
      e.gapi.source_uris = ["https://docs.google.com/spreadsheets/d/1234567980"]
      e.gapi.source_format = "GOOGLE_SHEETS"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["https://docs.google.com/spreadsheets/d/1234567980"],
      source_format: "GOOGLE_SHEETS",
      google_sheets_options: Google::Apis::BigqueryV2::GoogleSheetsOptions.new
    )

    _(table).must_be_kind_of Google::Cloud::Bigquery::External::DataSource
    _(table.urls).must_equal ["https://docs.google.com/spreadsheets/d/1234567980"]
    _(table).must_be :sheets?
    _(table.format).must_equal "GOOGLE_SHEETS"

    _(table).wont_be :csv?
    _(table).wont_be :json?
    _(table).wont_be :avro?
    _(table).wont_be :backup?
    _(table).wont_be :bigtable?

    _(table.to_gapi.to_h).must_equal table_gapi.to_h
  end

  it "sets skip_leading_rows" do
    table = Google::Cloud::Bigquery::External::SheetsSource.new.tap do |e|
      e.gapi.source_uris = ["https://docs.google.com/spreadsheets/d/1234567980"]
      e.gapi.source_format = "GOOGLE_SHEETS"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["https://docs.google.com/spreadsheets/d/1234567980"],
      source_format: "GOOGLE_SHEETS",
      google_sheets_options: Google::Apis::BigqueryV2::GoogleSheetsOptions.new(
        skip_leading_rows: true
      )
    )

    _(table.skip_leading_rows).must_be :nil?

    table.skip_leading_rows = true

    _(table.skip_leading_rows).must_equal true

    _(table.to_gapi.to_h).must_equal table_gapi.to_h
  end

  it "sets range" do
    table = Google::Cloud::Bigquery::External::SheetsSource.new.tap do |e|
      e.gapi.source_uris = ["https://docs.google.com/spreadsheets/d/1234567980"]
      e.gapi.source_format = "GOOGLE_SHEETS"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["https://docs.google.com/spreadsheets/d/1234567980"],
      source_format: "GOOGLE_SHEETS",
      google_sheets_options: Google::Apis::BigqueryV2::GoogleSheetsOptions.new(
        range: "sheet1!A1:B20"
      )
    )

    _(table.range).must_be :nil?

    table.range = "sheet1!A1:B20"

    _(table.range).must_equal "sheet1!A1:B20"

    _(table.to_gapi.to_h).must_equal table_gapi.to_h
  end
end
