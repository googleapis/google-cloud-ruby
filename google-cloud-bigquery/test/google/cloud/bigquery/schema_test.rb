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

  let(:kittens_schema_json) do
    <<-JSON
    [
        {"name":"id","type":"INTEGER","mode":"REQUIRED","description":"id description"},
        {"name":"breed","type":"STRING","mode":"REQUIRED","description":"breed description"},
        {"name":"name","type":"STRING","mode":"REQUIRED","description":"name description"},
        {"name":"dob","type":"TIMESTAMP","mode":"NULLABLE","description":"dob description"},
        {"name":"features","type":"RECORD","mode":"REPEATED","description":"features description",
         "fields":[{"name":"feature","type":"STRING","mode":"REQUIRED","description":"feature description"}]}
    ]
    JSON
  end

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
    io = StringIO.new(kittens_schema_json)
    schema.load io

    schema.wont_be :empty?
    schema.fields.map(&:name).must_equal %w[id breed name dob features]

    schema.field(:id).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:id).name.must_equal "id"
    schema.field(:id).type.must_equal "INTEGER"
    schema.field(:id).description.must_equal "id description"
    schema.field(:id).mode.must_equal "REQUIRED"
    schema.field(:id).must_be :integer?
    schema.field(:id).must_be :required?

    schema.field(:breed).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:breed).name.must_equal "breed"
    schema.field(:breed).type.must_equal "STRING"
    schema.field(:breed).description.must_equal "breed description"
    schema.field(:breed).mode.must_equal "REQUIRED"
    schema.field(:breed).must_be :string?
    schema.field(:breed).must_be :required?

    schema.field(:name).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:name).name.must_equal "name"
    schema.field(:name).type.must_equal "STRING"
    schema.field(:name).description.must_equal "name description"
    schema.field(:name).mode.must_equal "REQUIRED"
    schema.field(:name).must_be :string?
    schema.field(:name).must_be :required?

    schema.field(:dob).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:dob).name.must_equal "dob"
    schema.field(:dob).type.must_equal "TIMESTAMP"
    schema.field(:dob).description.must_equal "dob description"
    schema.field(:dob).mode.must_equal "NULLABLE"
    schema.field(:dob).must_be :timestamp?

    schema.field(:features).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:features).name.must_equal "features"
    schema.field(:features).type.must_equal "RECORD"
    schema.field(:features).description.must_equal "features description"
    schema.field(:features).mode.must_equal "REPEATED"
    schema.field(:features).must_be :record?
    schema.field(:features).must_be :repeated?

    features = schema.field(:features)
    features.fields.map(&:name).must_equal %w[feature]

    features.field(:feature).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    features.field(:feature).name.must_equal "feature"
    features.field(:feature).type.must_equal "STRING"
    features.field(:feature).description.must_equal "feature description"
    features.field(:feature).mode.must_equal "REQUIRED"
    features.field(:feature).must_be :string?
    features.field(:feature).must_be :required?
  end

  it "can load the schema from a JSON string" do
    schema.load kittens_schema_json

    schema.wont_be :empty?
    schema.fields.map(&:name).must_equal %w[id breed name dob features]

    schema.field(:id).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:id).name.must_equal "id"
    schema.field(:id).type.must_equal "INTEGER"
    schema.field(:id).description.must_equal "id description"
    schema.field(:id).mode.must_equal "REQUIRED"
    schema.field(:id).must_be :integer?
    schema.field(:id).must_be :required?

    schema.field(:breed).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:breed).name.must_equal "breed"
    schema.field(:breed).type.must_equal "STRING"
    schema.field(:breed).description.must_equal "breed description"
    schema.field(:breed).mode.must_equal "REQUIRED"
    schema.field(:breed).must_be :string?
    schema.field(:breed).must_be :required?

    schema.field(:name).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:name).name.must_equal "name"
    schema.field(:name).type.must_equal "STRING"
    schema.field(:name).description.must_equal "name description"
    schema.field(:name).mode.must_equal "REQUIRED"
    schema.field(:name).must_be :string?
    schema.field(:name).must_be :required?

    schema.field(:dob).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:dob).name.must_equal "dob"
    schema.field(:dob).type.must_equal "TIMESTAMP"
    schema.field(:dob).description.must_equal "dob description"
    schema.field(:dob).mode.must_equal "NULLABLE"
    schema.field(:dob).must_be :timestamp?

    schema.field(:features).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:features).name.must_equal "features"
    schema.field(:features).type.must_equal "RECORD"
    schema.field(:features).description.must_equal "features description"
    schema.field(:features).mode.must_equal "REPEATED"
    schema.field(:features).must_be :record?
    schema.field(:features).must_be :repeated?

    features = schema.field(:features)
    features.fields.map(&:name).must_equal %w[feature]

    features.field(:feature).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    features.field(:feature).name.must_equal "feature"
    features.field(:feature).type.must_equal "STRING"
    features.field(:feature).description.must_equal "feature description"
    features.field(:feature).mode.must_equal "REQUIRED"
    features.field(:feature).must_be :string?
    features.field(:feature).must_be :required?
  end

  it "can load the schema from an Array of Hashes" do
    json = JSON.parse(kittens_schema_json)
    schema.load json

    schema.wont_be :empty?
    schema.fields.map(&:name).must_equal %w[id breed name dob features]

    schema.field(:id).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:id).name.must_equal "id"
    schema.field(:id).type.must_equal "INTEGER"
    schema.field(:id).description.must_equal "id description"
    schema.field(:id).mode.must_equal "REQUIRED"
    schema.field(:id).must_be :integer?
    schema.field(:id).must_be :required?

    schema.field(:breed).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:breed).name.must_equal "breed"
    schema.field(:breed).type.must_equal "STRING"
    schema.field(:breed).description.must_equal "breed description"
    schema.field(:breed).mode.must_equal "REQUIRED"
    schema.field(:breed).must_be :string?
    schema.field(:breed).must_be :required?

    schema.field(:name).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:name).name.must_equal "name"
    schema.field(:name).type.must_equal "STRING"
    schema.field(:name).description.must_equal "name description"
    schema.field(:name).mode.must_equal "REQUIRED"
    schema.field(:name).must_be :string?
    schema.field(:name).must_be :required?

    schema.field(:dob).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:dob).name.must_equal "dob"
    schema.field(:dob).type.must_equal "TIMESTAMP"
    schema.field(:dob).description.must_equal "dob description"
    schema.field(:dob).mode.must_equal "NULLABLE"
    schema.field(:dob).must_be :timestamp?

    schema.field(:features).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    schema.field(:features).name.must_equal "features"
    schema.field(:features).type.must_equal "RECORD"
    schema.field(:features).description.must_equal "features description"
    schema.field(:features).mode.must_equal "REPEATED"
    schema.field(:features).must_be :record?
    schema.field(:features).must_be :repeated?

    features = schema.field(:features)
    features.fields.map(&:name).must_equal %w[feature]

    features.field(:feature).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    features.field(:feature).name.must_equal "feature"
    features.field(:feature).type.must_equal "STRING"
    features.field(:feature).description.must_equal "feature description"
    features.field(:feature).mode.must_equal "REQUIRED"
    features.field(:feature).must_be :string?
    features.field(:feature).must_be :required?
  end

  it "can dump the schema as JSON to a File" do
    begin
      file = Tempfile.new("schema-test")
      schema.dump file
      file.close

      json = JSON.parse(File.read(file.path))
    ensure
      if file
        file.close
        file.delete
      end
    end
    json.length.must_equal 10

    name = json.find { |record| record["name"] == "name" }
    name["type"].must_equal "STRING"
    name["mode"].must_equal "REQUIRED"

    age = json.find { |record| record["name"] == "age" }
    age["type"].must_equal "INTEGER"
    age["mode"].must_equal "NULLABLE"

    score = json.find { |record| record["name"] == "score" }
    score["type"].must_equal "FLOAT"
    score["mode"].must_equal "NULLABLE"

    active = json.find { |record| record["name"] == "active" }
    active["type"].must_equal "BOOLEAN"
    active["mode"].must_equal "NULLABLE"

    avatar = json.find { |record| record["name"] == "avatar" }
    avatar["type"].must_equal "BYTES"
    avatar["mode"].must_equal "NULLABLE"

    started_at = json.find { |record| record["name"] == "started_at" }
    started_at["type"].must_equal "TIMESTAMP"
    started_at["mode"].must_equal "NULLABLE"

    duration = json.find { |record| record["name"] == "duration" }
    duration["type"].must_equal "TIME"
    duration["mode"].must_equal "NULLABLE"

    target_end = json.find { |record| record["name"] == "target_end" }
    target_end["type"].must_equal "DATETIME"
    target_end["mode"].must_equal "NULLABLE"

    birthday = json.find { |record| record["name"] == "birthday" }
    birthday["type"].must_equal "DATE"
    birthday["mode"].must_equal "NULLABLE"

    alts = json.find { |record| record["name"] == "alts" }
    alts["type"].must_equal "RECORD"
    alts["mode"].must_equal "REPEATED"

    age = alts["fields"].find { |record| record["name"] == "age"}
    age["type"].must_equal "INT64"
    age["mode"].must_be :nil?

    score = alts["fields"].find { |record| record["name"] == "score"}
    score["type"].must_equal "FLOAT64"
    score["mode"].must_be :nil?

    active = alts["fields"].find { |record| record["name"] == "active"}
    active["type"].must_equal "BOOL"
    active["mode"].must_be :nil?

    alt = alts["fields"].find { |record| record["name"] == "alt"}
    alt["type"].must_equal "STRUCT"
    alt["mode"].must_be :nil?

    name = alt["fields"].find { |record| record["name"] == "name"}
    name["type"].must_equal "STRING"
    name["mode"].must_be :nil?
  end

  it "can dump the schema as JSON to a filename" do
    begin
      file = Tempfile.new("schema-test")
      file.close
      schema.dump file.path

      json = JSON.parse(File.read(file.path))
    ensure
      if file
        file.close
        file.delete
      end
    end
    json.length.must_equal 10

    name = json.find { |record| record["name"] == "name" }
    name["type"].must_equal "STRING"
    name["mode"].must_equal "REQUIRED"

    age = json.find { |record| record["name"] == "age" }
    age["type"].must_equal "INTEGER"
    age["mode"].must_equal "NULLABLE"

    score = json.find { |record| record["name"] == "score" }
    score["type"].must_equal "FLOAT"
    score["mode"].must_equal "NULLABLE"

    active = json.find { |record| record["name"] == "active" }
    active["type"].must_equal "BOOLEAN"
    active["mode"].must_equal "NULLABLE"

    avatar = json.find { |record| record["name"] == "avatar" }
    avatar["type"].must_equal "BYTES"
    avatar["mode"].must_equal "NULLABLE"

    started_at = json.find { |record| record["name"] == "started_at" }
    started_at["type"].must_equal "TIMESTAMP"
    started_at["mode"].must_equal "NULLABLE"

    duration = json.find { |record| record["name"] == "duration" }
    duration["type"].must_equal "TIME"
    duration["mode"].must_equal "NULLABLE"

    target_end = json.find { |record| record["name"] == "target_end" }
    target_end["type"].must_equal "DATETIME"
    target_end["mode"].must_equal "NULLABLE"

    birthday = json.find { |record| record["name"] == "birthday" }
    birthday["type"].must_equal "DATE"
    birthday["mode"].must_equal "NULLABLE"

    alts = json.find { |record| record["name"] == "alts" }
    alts["type"].must_equal "RECORD"
    alts["mode"].must_equal "REPEATED"

    age = alts["fields"].find { |record| record["name"] == "age"}
    age["type"].must_equal "INT64"
    age["mode"].must_be :nil?

    score = alts["fields"].find { |record| record["name"] == "score"}
    score["type"].must_equal "FLOAT64"
    score["mode"].must_be :nil?

    active = alts["fields"].find { |record| record["name"] == "active"}
    active["type"].must_equal "BOOL"
    active["mode"].must_be :nil?

    alt = alts["fields"].find { |record| record["name"] == "alt"}
    alt["type"].must_equal "STRUCT"
    alt["mode"].must_be :nil?

    name = alt["fields"].find { |record| record["name"] == "name"}
    name["type"].must_equal "STRING"
    name["mode"].must_be :nil?
  end

  it "can load a schema with the class method" do
    io = StringIO.new(kittens_schema_json)
    schema = Google::Cloud::Bigquery::Schema.load io

    schema.wont_be :empty?
    schema.fields.map(&:name).must_equal %w[id breed name dob features]
  end

  it "can dump a schema with the class method" do
    begin
      file = Tempfile.new("schema-test")
      Google::Cloud::Bigquery::Schema.dump schema, file
      file.close

      json = JSON.parse(File.read(file.path))
    ensure
      if file
        file.close
        file.delete
      end
    end
    json.length.must_equal 10

    fields = json.map { |record| record["name"] }
    fields.wont_be :empty?
    fields.must_equal %w[name age score active avatar started_at duration target_end birthday alts]
  end
end
