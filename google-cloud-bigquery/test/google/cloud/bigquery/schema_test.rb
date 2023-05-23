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
          "name" => "pi",
          "type" => "NUMERIC",
          "mode" => "NULLABLE"
        },
        {
          "name" => "my_bignumeric",
          "type" => "BIGNUMERIC",
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
        },
        {
          "name" => "home",
          "type" => "GEOGRAPHY",
          "mode" => "NULLABLE"
        }
      ]
    }
  end
  let(:schema_json) { schema_hash.to_json }
  let(:schema_gapi) { Google::Apis::BigqueryV2::TableSchema.from_json schema_json }
  let(:schema) { Google::Cloud::Bigquery::Schema.from_gapi schema_gapi }
  let(:empty_schema) { Google::Cloud::Bigquery::Schema.from_gapi }

  let(:kittens_schema_json) do
    <<~JSON
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
    _(schema).must_be_kind_of Google::Cloud::Bigquery::Schema
    _(schema.fields).wont_be :empty?
    _(schema.fields.map(&:name)).must_equal ["name", "age", "score", "pi", "my_bignumeric", "active", "avatar", "started_at", "duration", "target_end", "birthday", "alts", "home"]
  end

  it "can access fields with a symbol" do
    _(schema.field(:name)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:name).name).must_equal "name"
    _(schema.field(:name).type).must_equal "STRING"
    _(schema.field(:name).mode).must_equal "REQUIRED"
    _(schema.field(:name)).must_be :string?
    _(schema.field(:name)).must_be :required?
    _(schema.field(:name).policy_tags).must_be :nil?

    _(schema.field(:age)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:age).name).must_equal "age"
    _(schema.field(:age).type).must_equal "INTEGER"
    _(schema.field(:age).mode).must_equal "NULLABLE"
    _(schema.field(:age)).must_be :integer?
    _(schema.field(:age)).must_be :nullable?

    _(schema.field(:score)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:score).name).must_equal "score"
    _(schema.field(:score).type).must_equal "FLOAT"
    _(schema.field(:score).mode).must_equal "NULLABLE"
    _(schema.field(:score)).must_be :float?
    _(schema.field(:score)).must_be :nullable?

    _(schema.field(:pi)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:pi).name).must_equal "pi"
    _(schema.field(:pi).type).must_equal "NUMERIC"
    _(schema.field(:pi).mode).must_equal "NULLABLE"
    _(schema.field(:pi)).must_be :numeric?
    _(schema.field(:pi)).must_be :nullable?

    _(schema.field(:my_bignumeric)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:my_bignumeric).name).must_equal "my_bignumeric"
    _(schema.field(:my_bignumeric).type).must_equal "BIGNUMERIC"
    _(schema.field(:my_bignumeric).mode).must_equal "NULLABLE"
    _(schema.field(:my_bignumeric)).must_be :bignumeric?
    _(schema.field(:my_bignumeric)).must_be :nullable?

    _(schema.field(:active)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:active).name).must_equal "active"
    _(schema.field(:active).type).must_equal "BOOLEAN"
    _(schema.field(:active).mode).must_equal "NULLABLE"
    _(schema.field(:active)).must_be :boolean?
    _(schema.field(:active)).must_be :nullable?

    _(schema.field(:avatar)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:avatar).name).must_equal "avatar"
    _(schema.field(:avatar).type).must_equal "BYTES"
    _(schema.field(:avatar).mode).must_equal "NULLABLE"
    _(schema.field(:avatar)).must_be :bytes?
    _(schema.field(:avatar)).must_be :nullable?

    _(schema.field(:started_at)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:started_at).name).must_equal "started_at"
    _(schema.field(:started_at).type).must_equal "TIMESTAMP"
    _(schema.field(:started_at).mode).must_equal "NULLABLE"
    _(schema.field(:started_at)).must_be :timestamp?
    _(schema.field(:started_at)).must_be :nullable?

    _(schema.field(:duration)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:duration).name).must_equal "duration"
    _(schema.field(:duration).type).must_equal "TIME"
    _(schema.field(:duration).mode).must_equal "NULLABLE"
    _(schema.field(:duration)).must_be :time?
    _(schema.field(:duration)).must_be :nullable?

    _(schema.field(:target_end)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:target_end).name).must_equal "target_end"
    _(schema.field(:target_end).type).must_equal "DATETIME"
    _(schema.field(:target_end).mode).must_equal "NULLABLE"
    _(schema.field(:target_end)).must_be :datetime?
    _(schema.field(:target_end)).must_be :nullable?

    _(schema.field(:birthday)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:birthday).name).must_equal "birthday"
    _(schema.field(:birthday).type).must_equal "DATE"
    _(schema.field(:birthday).mode).must_equal "NULLABLE"
    _(schema.field(:birthday)).must_be :date?
    _(schema.field(:birthday)).must_be :nullable?

    _(schema.field(:alts)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:alts).name).must_equal "alts"
    _(schema.field(:alts).type).must_equal "RECORD"
    _(schema.field(:alts).mode).must_equal "REPEATED"
    _(schema.field(:alts)).must_be :record?
    _(schema.field(:alts)).must_be :repeated?

    _(schema.field(:alts).field(:age)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:alts).field(:age).name).must_equal "age"
    _(schema.field(:alts).field(:age).type).must_equal "INT64"
    _(schema.field(:alts).field(:age).mode).must_be :nil?
    _(schema.field(:alts).field(:age)).must_be :integer?

    _(schema.field(:alts).field(:score)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:alts).field(:score).name).must_equal "score"
    _(schema.field(:alts).field(:score).type).must_equal "FLOAT64"
    _(schema.field(:alts).field(:score).mode).must_be :nil?
    _(schema.field(:alts).field(:score)).must_be :float?

    _(schema.field(:alts).field(:active)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:alts).field(:active).name).must_equal "active"
    _(schema.field(:alts).field(:active).type).must_equal "BOOL"
    _(schema.field(:alts).field(:active).mode).must_be :nil?
    _(schema.field(:alts).field(:active)).must_be :boolean?

    _(schema.field(:alts).field(:alt)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:alts).field(:alt).name).must_equal "alt"
    _(schema.field(:alts).field(:alt).type).must_equal "STRUCT"
    _(schema.field(:alts).field(:alt).mode).must_be :nil?
    _(schema.field(:alts).field(:alt)).must_be :record?

    _(schema.field(:alts).field(:alt).field(:name)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:alts).field(:alt).field(:name).name).must_equal "name"
    _(schema.field(:alts).field(:alt).field(:name).type).must_equal "STRING"
    _(schema.field(:alts).field(:alt).field(:name).mode).must_be :nil?
    _(schema.field(:alts).field(:alt).field(:name)).must_be :string?

    _(schema.field(:home)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:home).name).must_equal "home"
    _(schema.field(:home).type).must_equal "GEOGRAPHY"
    _(schema.field(:home).mode).must_equal "NULLABLE"
    _(schema.field(:home)).must_be :geography?
    _(schema.field(:home)).must_be :nullable?
  end

  it "can access fields with a string" do
    _(schema.field("name")).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field("name").name).must_equal "name"
    _(schema.field("name").type).must_equal "STRING"
    _(schema.field("name").mode).must_equal "REQUIRED"
    _(schema.field("name")).must_be :string?
    _(schema.field("name")).must_be :required?

    _(schema.field("age")).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field("age").name).must_equal "age"
    _(schema.field("age").type).must_equal "INTEGER"
    _(schema.field("age").mode).must_equal "NULLABLE"
    _(schema.field("age")).must_be :integer?
    _(schema.field("age")).must_be :nullable?

    _(schema.field("score")).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field("score").name).must_equal "score"
    _(schema.field("score").type).must_equal "FLOAT"
    _(schema.field("score").mode).must_equal "NULLABLE"
    _(schema.field("score")).must_be :float?
    _(schema.field("score")).must_be :nullable?

    _(schema.field("pi")).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field("pi").name).must_equal "pi"
    _(schema.field("pi").type).must_equal "NUMERIC"
    _(schema.field("pi").mode).must_equal "NULLABLE"
    _(schema.field("pi")).must_be :numeric?
    _(schema.field("pi")).must_be :nullable?

    _(schema.field("my_bignumeric")).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field("my_bignumeric").name).must_equal "my_bignumeric"
    _(schema.field("my_bignumeric").type).must_equal "BIGNUMERIC"
    _(schema.field("my_bignumeric").mode).must_equal "NULLABLE"
    _(schema.field("my_bignumeric")).must_be :bignumeric?
    _(schema.field("my_bignumeric")).must_be :nullable?

    _(schema.field("active")).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field("active").name).must_equal "active"
    _(schema.field("active").type).must_equal "BOOLEAN"
    _(schema.field("active").mode).must_equal "NULLABLE"
    _(schema.field("active")).must_be :boolean?
    _(schema.field("active")).must_be :nullable?

    _(schema.field("avatar")).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field("avatar").name).must_equal "avatar"
    _(schema.field("avatar").type).must_equal "BYTES"
    _(schema.field("avatar").mode).must_equal "NULLABLE"
    _(schema.field("avatar")).must_be :bytes?
    _(schema.field("avatar")).must_be :nullable?

    _(schema.field("started_at")).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field("started_at").name).must_equal "started_at"
    _(schema.field("started_at").type).must_equal "TIMESTAMP"
    _(schema.field("started_at").mode).must_equal "NULLABLE"
    _(schema.field("started_at")).must_be :timestamp?
    _(schema.field("started_at")).must_be :nullable?

    _(schema.field("duration")).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field("duration").name).must_equal "duration"
    _(schema.field("duration").type).must_equal "TIME"
    _(schema.field("duration").mode).must_equal "NULLABLE"
    _(schema.field("duration")).must_be :time?
    _(schema.field("duration")).must_be :nullable?

    _(schema.field("target_end")).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field("target_end").name).must_equal "target_end"
    _(schema.field("target_end").type).must_equal "DATETIME"
    _(schema.field("target_end").mode).must_equal "NULLABLE"
    _(schema.field("target_end")).must_be :datetime?
    _(schema.field("target_end")).must_be :nullable?

    _(schema.field("birthday")).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field("birthday").name).must_equal "birthday"
    _(schema.field("birthday").type).must_equal "DATE"
    _(schema.field("birthday").mode).must_equal "NULLABLE"
    _(schema.field("birthday")).must_be :date?
    _(schema.field("birthday")).must_be :nullable?

    _(schema.field("alts")).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field("alts").name).must_equal "alts"
    _(schema.field("alts").type).must_equal "RECORD"
    _(schema.field("alts").mode).must_equal "REPEATED"
    _(schema.field("alts")).must_be :record?
    _(schema.field("alts")).must_be :repeated?

    _(schema.field("alts").field("age")).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field("alts").field("age").name).must_equal "age"
    _(schema.field("alts").field("age").type).must_equal "INT64"
    _(schema.field("alts").field("age").mode).must_be :nil?
    _(schema.field("alts").field("age")).must_be :integer?

    _(schema.field("alts").field("score")).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field("alts").field("score").name).must_equal "score"
    _(schema.field("alts").field("score").type).must_equal "FLOAT64"
    _(schema.field("alts").field("score").mode).must_be :nil?
    _(schema.field("alts").field("score")).must_be :float?

    _(schema.field("alts").field("active")).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field("alts").field("active").name).must_equal "active"
    _(schema.field("alts").field("active").type).must_equal "BOOL"
    _(schema.field("alts").field("active").mode).must_be :nil?
    _(schema.field("alts").field("active")).must_be :boolean?

    _(schema.field("alts").field("alt")).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field("alts").field("alt").name).must_equal "alt"
    _(schema.field("alts").field("alt").type).must_equal "STRUCT"
    _(schema.field("alts").field("alt").mode).must_be :nil?
    _(schema.field("alts").field("alt")).must_be :record?

    _(schema.field("alts").field("alt").field("name")).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field("alts").field("alt").field("name").name).must_equal "name"
    _(schema.field("alts").field("alt").field("name").type).must_equal "STRING"
    _(schema.field("alts").field("alt").field("name").mode).must_be :nil?
    _(schema.field("alts").field("alt").field("name")).must_be :string?

    _(schema.field("home")).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field("home").name).must_equal "home"
    _(schema.field("home").type).must_equal "GEOGRAPHY"
    _(schema.field("home").mode).must_equal "NULLABLE"
    _(schema.field("home")).must_be :geography?
    _(schema.field("home")).must_be :nullable?
  end

  it "can load the schema from a File" do
    io = StringIO.new(kittens_schema_json)
    schema.load io

    _(schema).wont_be :empty?
    _(schema.fields.map(&:name)).must_equal %w[id breed name dob features]

    _(schema.field(:id)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:id).name).must_equal "id"
    _(schema.field(:id).type).must_equal "INTEGER"
    _(schema.field(:id).description).must_equal "id description"
    _(schema.field(:id).mode).must_equal "REQUIRED"
    _(schema.field(:id)).must_be :integer?
    _(schema.field(:id)).must_be :required?

    _(schema.field(:breed)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:breed).name).must_equal "breed"
    _(schema.field(:breed).type).must_equal "STRING"
    _(schema.field(:breed).description).must_equal "breed description"
    _(schema.field(:breed).mode).must_equal "REQUIRED"
    _(schema.field(:breed)).must_be :string?
    _(schema.field(:breed)).must_be :required?

    _(schema.field(:name)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:name).name).must_equal "name"
    _(schema.field(:name).type).must_equal "STRING"
    _(schema.field(:name).description).must_equal "name description"
    _(schema.field(:name).mode).must_equal "REQUIRED"
    _(schema.field(:name)).must_be :string?
    _(schema.field(:name)).must_be :required?

    _(schema.field(:dob)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:dob).name).must_equal "dob"
    _(schema.field(:dob).type).must_equal "TIMESTAMP"
    _(schema.field(:dob).description).must_equal "dob description"
    _(schema.field(:dob).mode).must_equal "NULLABLE"
    _(schema.field(:dob)).must_be :timestamp?

    _(schema.field(:features)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:features).name).must_equal "features"
    _(schema.field(:features).type).must_equal "RECORD"
    _(schema.field(:features).description).must_equal "features description"
    _(schema.field(:features).mode).must_equal "REPEATED"
    _(schema.field(:features)).must_be :record?
    _(schema.field(:features)).must_be :repeated?

    features = schema.field(:features)
    _(features.fields.map(&:name)).must_equal %w[feature]

    _(features.field(:feature)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(features.field(:feature).name).must_equal "feature"
    _(features.field(:feature).type).must_equal "STRING"
    _(features.field(:feature).description).must_equal "feature description"
    _(features.field(:feature).mode).must_equal "REQUIRED"
    _(features.field(:feature)).must_be :string?
    _(features.field(:feature)).must_be :required?
  end

  it "can load the schema from a JSON string" do
    schema.load kittens_schema_json

    _(schema).wont_be :empty?
    _(schema.fields.map(&:name)).must_equal %w[id breed name dob features]

    _(schema.field(:id)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:id).name).must_equal "id"
    _(schema.field(:id).type).must_equal "INTEGER"
    _(schema.field(:id).description).must_equal "id description"
    _(schema.field(:id).mode).must_equal "REQUIRED"
    _(schema.field(:id)).must_be :integer?
    _(schema.field(:id)).must_be :required?

    _(schema.field(:breed)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:breed).name).must_equal "breed"
    _(schema.field(:breed).type).must_equal "STRING"
    _(schema.field(:breed).description).must_equal "breed description"
    _(schema.field(:breed).mode).must_equal "REQUIRED"
    _(schema.field(:breed)).must_be :string?
    _(schema.field(:breed)).must_be :required?

    _(schema.field(:name)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:name).name).must_equal "name"
    _(schema.field(:name).type).must_equal "STRING"
    _(schema.field(:name).description).must_equal "name description"
    _(schema.field(:name).mode).must_equal "REQUIRED"
    _(schema.field(:name)).must_be :string?
    _(schema.field(:name)).must_be :required?

    _(schema.field(:dob)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:dob).name).must_equal "dob"
    _(schema.field(:dob).type).must_equal "TIMESTAMP"
    _(schema.field(:dob).description).must_equal "dob description"
    _(schema.field(:dob).mode).must_equal "NULLABLE"
    _(schema.field(:dob)).must_be :timestamp?

    _(schema.field(:features)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:features).name).must_equal "features"
    _(schema.field(:features).type).must_equal "RECORD"
    _(schema.field(:features).description).must_equal "features description"
    _(schema.field(:features).mode).must_equal "REPEATED"
    _(schema.field(:features)).must_be :record?
    _(schema.field(:features)).must_be :repeated?

    features = schema.field(:features)
    _(features.fields.map(&:name)).must_equal %w[feature]

    _(features.field(:feature)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(features.field(:feature).name).must_equal "feature"
    _(features.field(:feature).type).must_equal "STRING"
    _(features.field(:feature).description).must_equal "feature description"
    _(features.field(:feature).mode).must_equal "REQUIRED"
    _(features.field(:feature)).must_be :string?
    _(features.field(:feature)).must_be :required?
  end

  it "can load the schema from an Array of Hashes" do
    json = JSON.parse(kittens_schema_json)
    schema.load json

    _(schema).wont_be :empty?
    _(schema.fields.map(&:name)).must_equal %w[id breed name dob features]

    _(schema.field(:id)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:id).name).must_equal "id"
    _(schema.field(:id).type).must_equal "INTEGER"
    _(schema.field(:id).description).must_equal "id description"
    _(schema.field(:id).mode).must_equal "REQUIRED"
    _(schema.field(:id)).must_be :integer?
    _(schema.field(:id)).must_be :required?

    _(schema.field(:breed)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:breed).name).must_equal "breed"
    _(schema.field(:breed).type).must_equal "STRING"
    _(schema.field(:breed).description).must_equal "breed description"
    _(schema.field(:breed).mode).must_equal "REQUIRED"
    _(schema.field(:breed)).must_be :string?
    _(schema.field(:breed)).must_be :required?

    _(schema.field(:name)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:name).name).must_equal "name"
    _(schema.field(:name).type).must_equal "STRING"
    _(schema.field(:name).description).must_equal "name description"
    _(schema.field(:name).mode).must_equal "REQUIRED"
    _(schema.field(:name)).must_be :string?
    _(schema.field(:name)).must_be :required?

    _(schema.field(:dob)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:dob).name).must_equal "dob"
    _(schema.field(:dob).type).must_equal "TIMESTAMP"
    _(schema.field(:dob).description).must_equal "dob description"
    _(schema.field(:dob).mode).must_equal "NULLABLE"
    _(schema.field(:dob)).must_be :timestamp?

    _(schema.field(:features)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(schema.field(:features).name).must_equal "features"
    _(schema.field(:features).type).must_equal "RECORD"
    _(schema.field(:features).description).must_equal "features description"
    _(schema.field(:features).mode).must_equal "REPEATED"
    _(schema.field(:features)).must_be :record?
    _(schema.field(:features)).must_be :repeated?

    features = schema.field(:features)
    _(features.fields.map(&:name)).must_equal %w[feature]

    _(features.field(:feature)).must_be_kind_of Google::Cloud::Bigquery::Schema::Field
    _(features.field(:feature).name).must_equal "feature"
    _(features.field(:feature).type).must_equal "STRING"
    _(features.field(:feature).description).must_equal "feature description"
    _(features.field(:feature).mode).must_equal "REQUIRED"
    _(features.field(:feature)).must_be :string?
    _(features.field(:feature)).must_be :required?
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
    _(json.length).must_equal 13

    name = json.find { |record| record["name"] == "name" }
    _(name["type"]).must_equal "STRING"
    _(name["mode"]).must_equal "REQUIRED"

    age = json.find { |record| record["name"] == "age" }
    _(age["type"]).must_equal "INTEGER"
    _(age["mode"]).must_equal "NULLABLE"

    score = json.find { |record| record["name"] == "score" }
    _(score["type"]).must_equal "FLOAT"
    _(score["mode"]).must_equal "NULLABLE"

    score = json.find { |record| record["name"] == "pi" }
    _(score["type"]).must_equal "NUMERIC"
    _(score["mode"]).must_equal "NULLABLE"

    score = json.find { |record| record["name"] == "my_bignumeric" }
    _(score["type"]).must_equal "BIGNUMERIC"
    _(score["mode"]).must_equal "NULLABLE"

    active = json.find { |record| record["name"] == "active" }
    _(active["type"]).must_equal "BOOLEAN"
    _(active["mode"]).must_equal "NULLABLE"

    avatar = json.find { |record| record["name"] == "avatar" }
    _(avatar["type"]).must_equal "BYTES"
    _(avatar["mode"]).must_equal "NULLABLE"

    started_at = json.find { |record| record["name"] == "started_at" }
    _(started_at["type"]).must_equal "TIMESTAMP"
    _(started_at["mode"]).must_equal "NULLABLE"

    duration = json.find { |record| record["name"] == "duration" }
    _(duration["type"]).must_equal "TIME"
    _(duration["mode"]).must_equal "NULLABLE"

    target_end = json.find { |record| record["name"] == "target_end" }
    _(target_end["type"]).must_equal "DATETIME"
    _(target_end["mode"]).must_equal "NULLABLE"

    birthday = json.find { |record| record["name"] == "birthday" }
    _(birthday["type"]).must_equal "DATE"
    _(birthday["mode"]).must_equal "NULLABLE"

    alts = json.find { |record| record["name"] == "alts" }
    _(alts["type"]).must_equal "RECORD"
    _(alts["mode"]).must_equal "REPEATED"

    age = alts["fields"].find { |record| record["name"] == "age"}
    _(age["type"]).must_equal "INT64"
    _(age["mode"]).must_be :nil?

    score = alts["fields"].find { |record| record["name"] == "score"}
    _(score["type"]).must_equal "FLOAT64"
    _(score["mode"]).must_be :nil?

    active = alts["fields"].find { |record| record["name"] == "active"}
    _(active["type"]).must_equal "BOOL"
    _(active["mode"]).must_be :nil?

    alt = alts["fields"].find { |record| record["name"] == "alt"}
    _(alt["type"]).must_equal "STRUCT"
    _(alt["mode"]).must_be :nil?

    name = alt["fields"].find { |record| record["name"] == "name"}
    _(name["type"]).must_equal "STRING"
    _(name["mode"]).must_be :nil?

    home = json.find { |record| record["name"] == "home" }
    _(home["type"]).must_equal "GEOGRAPHY"
    _(home["mode"]).must_equal "NULLABLE"
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
    _(json.length).must_equal 13

    name = json.find { |record| record["name"] == "name" }
    _(name["type"]).must_equal "STRING"
    _(name["mode"]).must_equal "REQUIRED"

    age = json.find { |record| record["name"] == "age" }
    _(age["type"]).must_equal "INTEGER"
    _(age["mode"]).must_equal "NULLABLE"

    score = json.find { |record| record["name"] == "score" }
    _(score["type"]).must_equal "FLOAT"
    _(score["mode"]).must_equal "NULLABLE"

    score = json.find { |record| record["name"] == "pi" }
    _(score["type"]).must_equal "NUMERIC"
    _(score["mode"]).must_equal "NULLABLE"

    score = json.find { |record| record["name"] == "my_bignumeric" }
    _(score["type"]).must_equal "BIGNUMERIC"
    _(score["mode"]).must_equal "NULLABLE"

    active = json.find { |record| record["name"] == "active" }
    _(active["type"]).must_equal "BOOLEAN"
    _(active["mode"]).must_equal "NULLABLE"

    avatar = json.find { |record| record["name"] == "avatar" }
    _(avatar["type"]).must_equal "BYTES"
    _(avatar["mode"]).must_equal "NULLABLE"

    started_at = json.find { |record| record["name"] == "started_at" }
    _(started_at["type"]).must_equal "TIMESTAMP"
    _(started_at["mode"]).must_equal "NULLABLE"

    duration = json.find { |record| record["name"] == "duration" }
    _(duration["type"]).must_equal "TIME"
    _(duration["mode"]).must_equal "NULLABLE"

    target_end = json.find { |record| record["name"] == "target_end" }
    _(target_end["type"]).must_equal "DATETIME"
    _(target_end["mode"]).must_equal "NULLABLE"

    birthday = json.find { |record| record["name"] == "birthday" }
    _(birthday["type"]).must_equal "DATE"
    _(birthday["mode"]).must_equal "NULLABLE"

    alts = json.find { |record| record["name"] == "alts" }
    _(alts["type"]).must_equal "RECORD"
    _(alts["mode"]).must_equal "REPEATED"

    age = alts["fields"].find { |record| record["name"] == "age"}
    _(age["type"]).must_equal "INT64"
    _(age["mode"]).must_be :nil?

    score = alts["fields"].find { |record| record["name"] == "score"}
    _(score["type"]).must_equal "FLOAT64"
    _(score["mode"]).must_be :nil?

    active = alts["fields"].find { |record| record["name"] == "active"}
    _(active["type"]).must_equal "BOOL"
    _(active["mode"]).must_be :nil?

    alt = alts["fields"].find { |record| record["name"] == "alt"}
    _(alt["type"]).must_equal "STRUCT"
    _(alt["mode"]).must_be :nil?

    name = alt["fields"].find { |record| record["name"] == "name"}
    _(name["type"]).must_equal "STRING"
    _(name["mode"]).must_be :nil?

    home = json.find { |record| record["name"] == "home" }
    _(home["type"]).must_equal "GEOGRAPHY"
    _(home["mode"]).must_equal "NULLABLE"
  end

  it "can load a schema with the class method" do
    io = StringIO.new(kittens_schema_json)
    schema = Google::Cloud::Bigquery::Schema.load io

    _(schema).wont_be :empty?
    _(schema.fields.map(&:name)).must_equal %w[id breed name dob features]
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
    _(json.length).must_equal 13

    fields = json.map { |record| record["name"] }
    _(fields).wont_be :empty?
    _(fields).must_equal %w[name age score pi my_bignumeric active avatar started_at duration target_end birthday alts home]
  end
end
