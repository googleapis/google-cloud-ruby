# Copyright 2017 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a extract of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Bigquery::External::BigtableTable do
  it "can be used for BIGTABLE" do
    table = Google::Cloud::Bigquery::External::BigtableTable.new.tap do |e|
      e.gapi.source_uris = ["https://googleapis.com/bigtable/projects/my-project/instances/my-instance/tables/my-table"]
      e.gapi.source_format = "BIGTABLE"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["https://googleapis.com/bigtable/projects/my-project/instances/my-instance/tables/my-table"],
      source_format: "BIGTABLE",
      bigtable_options: Google::Apis::BigqueryV2::BigtableOptions.new(
        column_families: []
      )
    )

    table.must_be_kind_of Google::Cloud::Bigquery::External::Table
    table.urls.must_equal ["https://googleapis.com/bigtable/projects/my-project/instances/my-instance/tables/my-table"]
    table.must_be :bigtable?
    table.format.must_equal "BIGTABLE"

    table.wont_be :csv?
    table.wont_be :json?
    table.wont_be :sheets?
    table.wont_be :avro?
    table.wont_be :backup?

    table.to_gapi.to_h.must_equal table_gapi.to_h
  end

  it "sets rowkey_as_string" do
    table = Google::Cloud::Bigquery::External::BigtableTable.new.tap do |e|
      e.gapi.source_uris = ["https://googleapis.com/bigtable/projects/my-project/instances/my-instance/tables/my-table"]
      e.gapi.source_format = "BIGTABLE"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["https://googleapis.com/bigtable/projects/my-project/instances/my-instance/tables/my-table"],
      source_format: "BIGTABLE",
      bigtable_options: Google::Apis::BigqueryV2::BigtableOptions.new(
        read_rowkey_as_string: true,
        column_families: []
      )
    )

    table.rowkey_as_string.must_be :nil?

    table.rowkey_as_string = true

    table.rowkey_as_string.must_equal true

    table.to_gapi.to_h.must_equal table_gapi.to_h
  end

  it "adds column families using block" do
    table = Google::Cloud::Bigquery::External::BigtableTable.new.tap do |e|
      e.gapi.source_uris = ["https://googleapis.com/bigtable/projects/my-project/instances/my-instance/tables/my-table"]
      e.gapi.source_format = "BIGTABLE"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["https://googleapis.com/bigtable/projects/my-project/instances/my-instance/tables/my-table"],
      source_format: "BIGTABLE",
      bigtable_options: Google::Apis::BigqueryV2::BigtableOptions.new(
        column_families: [
          Google::Apis::BigqueryV2::BigtableColumnFamily.new(
          family_id: "user",
          columns: [
            Google::Apis::BigqueryV2::BigtableColumn.new(qualifier_string: "name", type: "STRING"),
            Google::Apis::BigqueryV2::BigtableColumn.new(qualifier_string: "age", type: "INTEGER"),
            Google::Apis::BigqueryV2::BigtableColumn.new(qualifier_string: "score", type: "FLOAT"),
            Google::Apis::BigqueryV2::BigtableColumn.new(qualifier_string: "active", type: "BOOLEAN"),
            Google::Apis::BigqueryV2::BigtableColumn.new(qualifier_string: "avatar", type: "BYTES")
          ])
        ]
      )
    )

    table.families.must_be :empty?

    table.add_family "user" do |u|
      u.add_string  "name"
      u.add_integer "age"
      u.add_float   "score"
      u.add_boolean "active"
      u.add_bytes   "avatar"
    end

    table.families.wont_be :empty?
    table.families.count.must_equal 1
    table.families[0].must_be_kind_of Google::Cloud::Bigquery::External::BigtableTable::ColumnFamily
    table.families[0].family_id.must_equal "user"
    table.families[0].columns.count.must_equal 5
    table.families[0].columns[0].must_be_kind_of Google::Cloud::Bigquery::External::BigtableTable::Column
    table.families[0].columns[0].qualifier.must_equal "name"
    table.families[0].columns[0].type.must_equal "STRING"
    table.families[0].columns[1].must_be_kind_of Google::Cloud::Bigquery::External::BigtableTable::Column
    table.families[0].columns[1].qualifier.must_equal "age"
    table.families[0].columns[1].type.must_equal "INTEGER"
    table.families[0].columns[2].must_be_kind_of Google::Cloud::Bigquery::External::BigtableTable::Column
    table.families[0].columns[2].qualifier.must_equal "score"
    table.families[0].columns[2].type.must_equal "FLOAT"
    table.families[0].columns[3].must_be_kind_of Google::Cloud::Bigquery::External::BigtableTable::Column
    table.families[0].columns[3].qualifier.must_equal "active"
    table.families[0].columns[3].type.must_equal "BOOLEAN"
    table.families[0].columns[4].must_be_kind_of Google::Cloud::Bigquery::External::BigtableTable::Column
    table.families[0].columns[4].qualifier.must_equal "avatar"
    table.families[0].columns[4].type.must_equal "BYTES"

    table.to_gapi.to_h.must_equal table_gapi.to_h
  end

  it "adds column families inline" do
    table = Google::Cloud::Bigquery::External::BigtableTable.new.tap do |e|
      e.gapi.source_uris = ["https://googleapis.com/bigtable/projects/my-project/instances/my-instance/tables/my-table"]
      e.gapi.source_format = "BIGTABLE"
    end
    table_gapi = Google::Apis::BigqueryV2::ExternalDataConfiguration.new(
      source_uris: ["https://googleapis.com/bigtable/projects/my-project/instances/my-instance/tables/my-table"],
      source_format: "BIGTABLE",
      bigtable_options: Google::Apis::BigqueryV2::BigtableOptions.new(
        column_families: [
          Google::Apis::BigqueryV2::BigtableColumnFamily.new(
          family_id: "user",
          columns: [
            Google::Apis::BigqueryV2::BigtableColumn.new(qualifier_string: "name", type: "STRING"),
            Google::Apis::BigqueryV2::BigtableColumn.new(qualifier_string: "age", type: "INTEGER"),
            Google::Apis::BigqueryV2::BigtableColumn.new(qualifier_string: "score", type: "FLOAT"),
            Google::Apis::BigqueryV2::BigtableColumn.new(qualifier_string: "active", type: "BOOLEAN"),
            Google::Apis::BigqueryV2::BigtableColumn.new(qualifier_string: "avatar", type: "BYTES")
          ])
        ]
      )
    )

    table.families.must_be :empty?

    family = table.add_family "user"
    family.add_string  "name"
    family.add_integer "age"
    family.add_float   "score"
    family.add_boolean "active"
    family.add_bytes   "avatar"

    table.families.wont_be :empty?
    table.families.count.must_equal 1
    table.families[0].must_be_kind_of Google::Cloud::Bigquery::External::BigtableTable::ColumnFamily
    table.families[0].family_id.must_equal "user"
    table.families[0].columns.count.must_equal 5
    table.families[0].columns[0].must_be_kind_of Google::Cloud::Bigquery::External::BigtableTable::Column
    table.families[0].columns[0].qualifier.must_equal "name"
    table.families[0].columns[0].type.must_equal "STRING"
    table.families[0].columns[1].must_be_kind_of Google::Cloud::Bigquery::External::BigtableTable::Column
    table.families[0].columns[1].qualifier.must_equal "age"
    table.families[0].columns[1].type.must_equal "INTEGER"
    table.families[0].columns[2].must_be_kind_of Google::Cloud::Bigquery::External::BigtableTable::Column
    table.families[0].columns[2].qualifier.must_equal "score"
    table.families[0].columns[2].type.must_equal "FLOAT"
    table.families[0].columns[3].must_be_kind_of Google::Cloud::Bigquery::External::BigtableTable::Column
    table.families[0].columns[3].qualifier.must_equal "active"
    table.families[0].columns[3].type.must_equal "BOOLEAN"
    table.families[0].columns[4].must_be_kind_of Google::Cloud::Bigquery::External::BigtableTable::Column
    table.families[0].columns[4].qualifier.must_equal "avatar"
    table.families[0].columns[4].type.must_equal "BYTES"

    table.to_gapi.to_h.must_equal table_gapi.to_h
  end
end
