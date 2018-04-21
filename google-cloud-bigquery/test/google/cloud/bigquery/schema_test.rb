# Copyright 2018 Google LLC
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

require "helper"

describe Google::Cloud::Bigquery::Schema, :mock_bigquery do
  let(:schema_hash) do
    {
      "fields" => [
        {
          "name" => "name",
          "type" => "STRING",
          "mode" => "REQUIRED"
        },
        {
          "name" => "age",
          "type" => "INTEGER",
          "mode" => "NULLABLE"
        },
        {
          "name" => "score",
          "type" => "FLOAT",
          "mode" => "NULLABLE"
        },
        {
          "name" => "active",
          "type" => "BOOLEAN",
          "mode" => "NULLABLE"
        },
        {
          "name" => "avatar",
          "type" => "BYTES",
          "mode" => "NULLABLE"
        },
        {
          "name" => "started_at",
          "type" => "TIMESTAMP",
          "mode" => "NULLABLE"
        },
        {
          "name" => "duration",
          "type" => "TIME",
          "mode" => "NULLABLE"
        },
        {
          "name" => "target_end",
          "type" => "DATETIME",
          "mode" => "NULLABLE"
        },
        {
          "name" => "birthday",
          "type" => "DATE",
          "mode" => "NULLABLE"
        },
        {
          "name" => "alts",
          "type" => "RECORD",
          "mode" => "REPEATED",
          "fields" => [
            {
              "name" => "age",
              "type" => "INT64"
            },
            {
              "name" => "score",
              "type" => "FLOAT64"
            },
            {
              "name" => "active",
              "type" => "BOOL"
            },
            {
              "name" => "alt",
              "type" => "STRUCT",
              "fields" => [
                {
                  "name" => "name",
                  "type" => "STRING"
                }
              ]
            }
          ]
        }
      ]
    }
  end
  let(:schema_json) { schema_hash.to_json }
  let(:schema_gapi) { Google::Apis::BigqueryV2::TableSchema.from_json schema_json }
  let(:schema) { Google::Cloud::Bigquery::Schema.from_gapi schema_gapi }
  let(:empty_schema) { Google::Cloud::Bigquery::Schema.from_gapi }

  it "has basic values" do
    schema.must_be_kind_of Google::Cloud::Bigquery::Schema
    schema.fields.wont_be :empty?
    schema.fields.map(&:name).must_equal ["name", "age", "score", "active", "avatar", "started_at", "duration", "target_end", "birthday", "alts"]
  end

  it "can access fields with a symbol" do
    schema.field(:name).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:name).name.must_equal "name"
    schema.field(:name).type.must_equal "STRING"
    schema.field(:name).mode.must_equal "REQUIRED"
    schema.field(:name).must_be :string?
    schema.field(:name).must_be :required?

    schema.field(:age).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:age).name.must_equal "age"
    schema.field(:age).type.must_equal "INTEGER"
    schema.field(:age).mode.must_equal "NULLABLE"
    schema.field(:age).must_be :integer?
    schema.field(:age).must_be :nullable?

    schema.field(:score).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:score).name.must_equal "score"
    schema.field(:score).type.must_equal "FLOAT"
    schema.field(:score).mode.must_equal "NULLABLE"
    schema.field(:score).must_be :float?
    schema.field(:score).must_be :nullable?

    schema.field(:active).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:active).name.must_equal "active"
    schema.field(:active).type.must_equal "BOOLEAN"
    schema.field(:active).mode.must_equal "NULLABLE"
    schema.field(:active).must_be :boolean?
    schema.field(:active).must_be :nullable?

    schema.field(:avatar).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:avatar).name.must_equal "avatar"
    schema.field(:avatar).type.must_equal "BYTES"
    schema.field(:avatar).mode.must_equal "NULLABLE"
    schema.field(:avatar).must_be :bytes?
    schema.field(:avatar).must_be :nullable?

    schema.field(:started_at).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:started_at).name.must_equal "started_at"
    schema.field(:started_at).type.must_equal "TIMESTAMP"
    schema.field(:started_at).mode.must_equal "NULLABLE"
    schema.field(:started_at).must_be :timestamp?
    schema.field(:started_at).must_be :nullable?

    schema.field(:duration).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:duration).name.must_equal "duration"
    schema.field(:duration).type.must_equal "TIME"
    schema.field(:duration).mode.must_equal "NULLABLE"
    schema.field(:duration).must_be :time?
    schema.field(:duration).must_be :nullable?

    schema.field(:target_end).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:target_end).name.must_equal "target_end"
    schema.field(:target_end).type.must_equal "DATETIME"
    schema.field(:target_end).mode.must_equal "NULLABLE"
    schema.field(:target_end).must_be :datetime?
    schema.field(:target_end).must_be :nullable?

    schema.field(:birthday).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:birthday).name.must_equal "birthday"
    schema.field(:birthday).type.must_equal "DATE"
    schema.field(:birthday).mode.must_equal "NULLABLE"
    schema.field(:birthday).must_be :date?
    schema.field(:birthday).must_be :nullable?

    schema.field(:alts).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:alts).name.must_equal "alts"
    schema.field(:alts).type.must_equal "RECORD"
    schema.field(:alts).mode.must_equal "REPEATED"
    schema.field(:alts).must_be :record?
    schema.field(:alts).must_be :repeated?

    schema.field(:alts).field(:age).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:alts).field(:age).name.must_equal "age"
    schema.field(:alts).field(:age).type.must_equal "INT64"
    schema.field(:alts).field(:age).mode.must_be :nil?
    schema.field(:alts).field(:age).must_be :integer?

    schema.field(:alts).field(:score).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:alts).field(:score).name.must_equal "score"
    schema.field(:alts).field(:score).type.must_equal "FLOAT64"
    schema.field(:alts).field(:score).mode.must_be :nil?
    schema.field(:alts).field(:score).must_be :float?

    schema.field(:alts).field(:active).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:alts).field(:active).name.must_equal "active"
    schema.field(:alts).field(:active).type.must_equal "BOOL"
    schema.field(:alts).field(:active).mode.must_be :nil?
    schema.field(:alts).field(:active).must_be :boolean?

    schema.field(:alts).field(:alt).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:alts).field(:alt).name.must_equal "alt"
    schema.field(:alts).field(:alt).type.must_equal "STRUCT"
    schema.field(:alts).field(:alt).mode.must_be :nil?
    schema.field(:alts).field(:alt).must_be :record?

    schema.field(:alts).field(:alt).field(:name).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:alts).field(:alt).field(:name).name.must_equal "name"
    schema.field(:alts).field(:alt).field(:name).type.must_equal "STRING"
    schema.field(:alts).field(:alt).field(:name).mode.must_be :nil?
    schema.field(:alts).field(:alt).field(:name).must_be :string?
  end

  it "can access fields with a string" do
    schema.field("name").must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field("name").name.must_equal "name"
    schema.field("name").type.must_equal "STRING"
    schema.field("name").mode.must_equal "REQUIRED"
    schema.field("name").must_be :string?
    schema.field("name").must_be :required?

    schema.field("age").must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field("age").name.must_equal "age"
    schema.field("age").type.must_equal "INTEGER"
    schema.field("age").mode.must_equal "NULLABLE"
    schema.field("age").must_be :integer?
    schema.field("age").must_be :nullable?

    schema.field("score").must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field("score").name.must_equal "score"
    schema.field("score").type.must_equal "FLOAT"
    schema.field("score").mode.must_equal "NULLABLE"
    schema.field("score").must_be :float?
    schema.field("score").must_be :nullable?

    schema.field("active").must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field("active").name.must_equal "active"
    schema.field("active").type.must_equal "BOOLEAN"
    schema.field("active").mode.must_equal "NULLABLE"
    schema.field("active").must_be :boolean?
    schema.field("active").must_be :nullable?

    schema.field("avatar").must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field("avatar").name.must_equal "avatar"
    schema.field("avatar").type.must_equal "BYTES"
    schema.field("avatar").mode.must_equal "NULLABLE"
    schema.field("avatar").must_be :bytes?
    schema.field("avatar").must_be :nullable?

    schema.field("started_at").must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field("started_at").name.must_equal "started_at"
    schema.field("started_at").type.must_equal "TIMESTAMP"
    schema.field("started_at").mode.must_equal "NULLABLE"
    schema.field("started_at").must_be :timestamp?
    schema.field("started_at").must_be :nullable?

    schema.field("duration").must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field("duration").name.must_equal "duration"
    schema.field("duration").type.must_equal "TIME"
    schema.field("duration").mode.must_equal "NULLABLE"
    schema.field("duration").must_be :time?
    schema.field("duration").must_be :nullable?

    schema.field("target_end").must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field("target_end").name.must_equal "target_end"
    schema.field("target_end").type.must_equal "DATETIME"
    schema.field("target_end").mode.must_equal "NULLABLE"
    schema.field("target_end").must_be :datetime?
    schema.field("target_end").must_be :nullable?

    schema.field("birthday").must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field("birthday").name.must_equal "birthday"
    schema.field("birthday").type.must_equal "DATE"
    schema.field("birthday").mode.must_equal "NULLABLE"
    schema.field("birthday").must_be :date?
    schema.field("birthday").must_be :nullable?

    schema.field("alts").must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field("alts").name.must_equal "alts"
    schema.field("alts").type.must_equal "RECORD"
    schema.field("alts").mode.must_equal "REPEATED"
    schema.field("alts").must_be :record?
    schema.field("alts").must_be :repeated?

    schema.field("alts").field("age").must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field("alts").field("age").name.must_equal "age"
    schema.field("alts").field("age").type.must_equal "INT64"
    schema.field("alts").field("age").mode.must_be :nil?
    schema.field("alts").field("age").must_be :integer?

    schema.field("alts").field("score").must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field("alts").field("score").name.must_equal "score"
    schema.field("alts").field("score").type.must_equal "FLOAT64"
    schema.field("alts").field("score").mode.must_be :nil?
    schema.field("alts").field("score").must_be :float?

    schema.field("alts").field("active").must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field("alts").field("active").name.must_equal "active"
    schema.field("alts").field("active").type.must_equal "BOOL"
    schema.field("alts").field("active").mode.must_be :nil?
    schema.field("alts").field("active").must_be :boolean?

    schema.field("alts").field("alt").must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field("alts").field("alt").name.must_equal "alt"
    schema.field("alts").field("alt").type.must_equal "STRUCT"
    schema.field("alts").field("alt").mode.must_be :nil?
    schema.field("alts").field("alt").must_be :record?

    schema.field("alts").field("alt").field("name").must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field("alts").field("alt").field("name").name.must_equal "name"
    schema.field("alts").field("alt").field("name").type.must_equal "STRING"
    schema.field("alts").field("alt").field("name").mode.must_be :nil?
    schema.field("alts").field("alt").field("name").must_be :string?
  end

  it "can load the schema from a File" do
    schema.load File.open("acceptance/data/schema.json")

    schema.wont_be :empty?
    schema.fields.map(&:name).must_equal %w[id breed name dob features]

    fields = schema.fields
    fields.each do |f|
      f.name.wont_be :nil?
      f.type.wont_be :nil?
      f.description.wont_be :nil?
      f.mode.wont_be :nil?

      next unless f.name == "features"
      f.fields.wont_be :empty?
      f.fields.each do |c|
        c.name.wont_be :nil?
        c.type.wont_be :nil?
        c.description.wont_be :nil?
        c.mode.wont_be :nil?
      end
    end
  end

  it "can load the schema from a JSON string" do
    schema.load File.read("acceptance/data/schema.json")

    schema.wont_be :empty?
    schema.fields.map(&:name).must_equal %w[id breed name dob features]

    fields = schema.fields
    fields.each do |f|
      f.name.wont_be :nil?
      f.type.wont_be :nil?
      f.description.wont_be :nil?
      f.mode.wont_be :nil?

      next unless f.name == "features"
      f.fields.wont_be :empty?
      f.fields.each do |c|
        c.name.wont_be :nil?
        c.type.wont_be :nil?
        c.description.wont_be :nil?
        c.mode.wont_be :nil?
      end
    end
  end

  it "can load the schema from an Array of Hashes" do
    json = JSON.parse(File.read("acceptance/data/schema.json"))
    schema.load json

    schema.wont_be :empty?
    schema.fields.map(&:name).must_equal %w[id breed name dob features]

    fields = schema.fields
    fields.each do |f|
      f.name.wont_be :nil?
      f.type.wont_be :nil?
      f.description.wont_be :nil?
      f.mode.wont_be :nil?

      next unless f.name == "features"
      f.fields.wont_be :empty?
      f.fields.each do |c|
        c.name.wont_be :nil?
        c.type.wont_be :nil?
        c.description.wont_be :nil?
        c.mode.wont_be :nil?
      end
    end
  end

  it "can dump the schema as JSON to a File" do
    begin
      file = Tempfile.new("schema-test")
      schema.dump file
      file.close

      json = JSON.parse(File.read(file.path))
      json.length.must_equal 10

      json.each do |f|
        f["name"].wont_be :nil?
        f["type"].wont_be :nil?
        f["mode"].wont_be :nil?
      end
    ensure
      if file
        file.close
        file.delete
      end
    end
  end

  it "can dump the schema as JSON to a filename" do
    begin
      file = Tempfile.new("schema-test")
      file.close
      schema.dump file.path

      json = JSON.parse(File.read(file.path))
      json.length.must_equal 10

      json.each do |f|
        f["name"].wont_be :nil?
        f["type"].wont_be :nil?
        f["mode"].wont_be :nil?
      end
    ensure
      if file
        file.close
        file.delete
      end
    end
  end
end
