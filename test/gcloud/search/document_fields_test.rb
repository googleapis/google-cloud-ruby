# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

##
# A field can have multiple values with same or different types; however, it
# cannot have multiple Timestamp or number values.
describe Gcloud::Search::Document, :fields, :mock_search do

  let(:index_id) { "my-index" }
  let(:index_hash) { { "indexId" => index_id, "projectId" => project } }
  let(:index) { Gcloud::Search::Index.from_raw index_hash, search.connection }
  let(:doc_id) { "my-doc" }
  let(:doc_rank) { 123456 }
  let(:doc_hash) { {"docId" => doc_id, "rank" => doc_rank, "fields" => random_fields_hash } }
  let(:document) { Gcloud::Search::Document.from_hash doc_hash }

  it "knows its field count" do
    document.fields.count.must_equal 4
  end

  it "adds a number to a field" do
    document.add "rating", 4.5

    document["rating"].count.must_equal 1
    field = document["rating"].first
    field.name.must_equal "rating"
    field.must_equal 4.5
    field.type.must_equal :number
  end

  it "adding multiple numbers to a field only keeps the last one" do
    document.add "rating", 4.5

    document["rating"].count.must_equal 1
    field = document["rating"].first
    field.name.must_equal "rating"
    field.must_equal 4.5
    field.type.must_equal :number

    document.add "rating", 99.9

    document["rating"].count.must_equal 1
    field = document["rating"].first
    field.name.must_equal "rating"
    field.must_equal 99.9
    field.type.must_equal :number
  end

  it "adds a DateTime to a field" do
    document.add "posted_at", DateTime.new(2001, 2, 3, 4, 5, 6, '+7')

    document["posted_at"].count.must_equal 1
    field = document["posted_at"].first
    field.name.must_equal "posted_at"
    field.must_be_kind_of DateTime
    field.to_s.must_equal "2001-02-03T04:05:06+07:00"
    field.type.must_equal :datetime
  end

  it "adding multiple DateTimes to a field only keeps the last one" do
    document.add "posted_at", DateTime.new(2001, 2, 3, 4, 5, 6, '+7')

    document["posted_at"].count.must_equal 1
    field = document["posted_at"].first
    field.name.must_equal "posted_at"
    field.must_be_kind_of DateTime
    field.to_s.must_equal "2001-02-03T04:05:06+07:00"
    field.type.must_equal :datetime

    document.add "posted_at", DateTime.new(2010, 1, 2, 3, 4, 5, '+6')

    document["posted_at"].count.must_equal 1
    field = document["posted_at"].first
    field.name.must_equal "posted_at"
    field.must_be_kind_of DateTime
    field.to_s.must_equal "2010-01-02T03:04:05+06:00"
    field.type.must_equal :datetime
  end

  it "adds a coordinate to a field with type geo set" do
    document.add "destination", "40.58, -111.65", type: :geo

    field = document["destination"].first
    field.must_equal "40.58, -111.65"
    field.type.must_equal :geo
  end

  it "adds a default string to a field" do
    document.add "serial_number", "abc123"

    field = document["serial_number"].first
    field.must_equal "abc123"
    field.type.must_equal :default
    field.lang.must_be :nil?
  end

  it "sets a new array of values in a field" do
    document.delete "body"
    document.add "body", "new body 1"
    document.add "body", "new body 2", type: :html, lang: "en"

    fields = document["body"]
    fields[0].name.must_equal "body"
    fields[0].value.must_equal "new body 1"
    fields[0].type.must_equal :default
    fields[0].lang.must_be :nil?
    fields[1].name.must_equal "body"
    fields[1].value.must_equal "new body 2"
    fields[1].type.must_equal :html
    fields[1].lang.must_equal "en"
  end

  it "returns a number field" do
    field = document["price"].first
    field.name.must_equal "price"
    field.must_equal 24.95
    field.type.must_equal :number
  end

  it "returns a timestamp field" do
    field = document["since"].first
    field.name.must_equal "since"
    field.must_be_kind_of DateTime
    field.to_s.must_equal "2015-10-02T15:00:00+00:00"
    field.type.must_equal :datetime
  end

  it "returns a geoValue field" do
    field = document["location"].first
    field.name.must_equal "location"
    field.must_equal "-33.857, 151.215"
    field.type.must_equal :geo
  end

  it "returns a string field with lang and type" do
    field = document["body"].first
    field.name.must_equal "body"
    field.must_equal "gcloud is a client library"
    field.type.must_equal :text
    field.lang.must_equal "en"
  end

  it "returns all values for a field with values" do
    values = document["body"]
    values.must_be_kind_of Gcloud::Search::FieldValues
    values.count.must_equal 3
    values[0].value.must_equal "gcloud is a client library"
    values[0].type.must_equal :text
    values[0].lang.must_equal "en"
    values[1].value.must_equal "<code>gcloud</code> is a client library"
    values[1].type.must_equal :html
    values[1].lang.must_equal "en"
    values[2].value.must_equal "<code>gcloud</code> estas kliento biblioteko"
    values[2].type.must_equal :html
    values[2].lang.must_equal "eo"
  end

  it "cannot manipulate field values directly" do
    values = document["body"]
    values.must_be_kind_of Gcloud::Search::FieldValues
    values.count.must_equal 3
    expect do
      values << "adding a new 4th value to the array isn't allowed"
    end.must_raise NoMethodError
  end

  it "deletes field by name" do
    document.names.must_include "price"
    document.delete "price"
    document.names.wont_include "price"
  end

  it "deletes field by name on fields" do
    document.fields.names.must_include "price"
    document.fields.delete "price"
    document.fields.names.wont_include "price"
  end

  it "deletes field value by field value object" do
    document["body"].count.must_equal 3
    document["body"].first.value.must_equal "gcloud is a client library"
    document["body"].delete document["body"].first.value
    document["body"].count.must_equal 2
  end

  it "deletes field value by field value object on fields" do
    document.fields["body"].count.must_equal 3
    document.fields["body"].first.value.must_equal "gcloud is a client library"
    document.fields["body"].delete document.fields["body"].first.value
    document.fields["body"].count.must_equal 2
  end

  it "deletes field value by raw value" do
    document["body"].count.must_equal 3
    document["body"].first.value.must_equal "gcloud is a client library"
    document["body"].delete "gcloud is a client library"
    document["body"].count.must_equal 2
  end

  it "deletes field value by raw value on fields" do
    document.fields["body"].count.must_equal 3
    document.fields["body"].first.value.must_equal "gcloud is a client library"
    document.fields["body"].delete "gcloud is a client library"
    document.fields["body"].count.must_equal 2
  end

  it "deletes field value by index" do
    document["body"].count.must_equal 3
    document["body"].delete_at 0
    document["body"].count.must_equal 2
  end

  it "deletes field value by index on fields" do
    document.fields["body"].count.must_equal 3
    document.fields["body"].delete_at 0
    document.fields["body"].count.must_equal 2
  end

  it "identifies the field names with names" do
    document.names.must_include "body"
    document.names.must_include "location"
    document.names.must_include "price"
    document.names.must_include "since"
  end

  it "empty fields are not returned with names" do
    document["rando_field"].add "rando value"
    document["rando_field"].delete_at 0

    document.names.wont_include "rando_field"
  end

  it "identifies the field names with fields.names" do
    document.fields.names.must_include "body"
    document.fields.names.must_include "location"
    document.fields.names.must_include "price"
    document.fields.names.must_include "since"
  end

  it "empty fields are not returned with fields.names" do
    document["rando_field"].add "rando value"
    document["rando_field"].delete_at 0

    document.fields.names.wont_include "rando_field"
  end

  it "iterates through all the fields with each" do
    all_names = []
    document.each do |name, values|
      all_names << name
    end
    all_names.must_include "body"
    all_names.must_include "location"
    all_names.must_include "price"
    all_names.must_include "since"
  end

  it "empty fields are not iterated on with each" do
    document["rando_field"].add "rando value"
    document["rando_field"].delete_at 0

    all_names = []
    document.each do |name, values|
      all_names << name
    end
    all_names.wont_include "rando_field"
  end

  it "iterates through all the fields with fields.each" do
    all_names = []
    document.fields.each do |name, values|
      all_names << name
    end
    all_names.must_include "body"
    all_names.must_include "location"
    all_names.must_include "price"
    all_names.must_include "since"
  end

  it "empty fields are not iterated on with fields.each" do
    document["rando_field"].add "rando value"
    document["rando_field"].delete_at 0

    all_names = []
    document.fields.each do |name, values|
      all_names << name
    end
    all_names.wont_include "rando_field"
  end
end
