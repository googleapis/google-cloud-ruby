# Copyright 2017 Google LLC
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

require "bigquery_helper"
require "csv"

describe Google::Cloud::Bigquery::External, :bigquery do
  let(:dataset_id) { "#{prefix}_dataset" }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      d = bigquery.create_dataset dataset_id
    end
    d
  end
  let(:data) do
    [
      ["id", "name", "breed"],
      [4, "silvano", "the cat kind"],
      [5, "ryan", "golden retriever?"],
      [6, "stephen", "idkanycatbreeds"]
    ]
  end
  let(:data_csv) { CSV.generate { |csv| data.each { |row| csv << row } } }
  let(:data_io) { StringIO.new data_csv }
  let(:storage) { Google::Cloud.storage }
  let(:file) { bucket.file("pets.csv") || bucket.create_file(data_io, "pets.csv") }
  let(:control_char_data) do
    [
      ["id", "name", "breed"],
      [1, "foo\x01bar", "baz\x1Fqux"]
    ]
  end
  let(:control_char_data_csv) { CSV.generate { |csv| control_char_data.each { |row| csv << row } } }
  let(:control_char_data_io) { StringIO.new control_char_data_csv }
  let(:control_char_file) { bucket.file("pets_control_chars.csv") || bucket.create_file(control_char_data_io, "pets_control_chars.csv") }

  it "queries an external table (with autodetect)" do
    ext_table = dataset.external file.to_gs_url
    ext_table.autodetect = true
    ext_table.skip_leading_rows = 1

    data = dataset.query "SELECT * FROM pets", external: { pets: ext_table }
    _(data.count).must_equal 3
    _(data).must_equal [
      { id: 4, name: "silvano", breed: "the cat kind" },
      { id: 5, name: "ryan", breed: "golden retriever?" },
      { id: 6, name: "stephen", breed: "idkanycatbreeds" }
    ]
  end

  it "queries an external table (with schema)" do
    ext_table = dataset.external file.to_gs_url do |t|
      t.skip_leading_rows = 1
      t.schema do |s|
        s.integer   "id",    description: "id description",    mode: :required
        s.string    "name",  description: "name description",  mode: :required
        s.string    "breed", description: "breed description", mode: :required
      end
    end

    data = dataset.query "SELECT id, name, breed FROM pets", external: { pets: ext_table }
    _(data.count).must_equal 3
    _(data).must_equal [
      { id: 4, name: "silvano", breed: "the cat kind" },
      { id: 5, name: "ryan", breed: "golden retriever?" },
      { id: 6, name: "stephen", breed: "idkanycatbreeds" }
    ]
  end
  
  it "queries an external table with preserve_ascii_control_characters" do
    # First, test with preserve_ascii_control_characters = true
    ext_table_preserved = dataset.external control_char_file.to_gs_url do |t|
      t.skip_leading_rows = 1
      t.preserve_ascii_control_characters = true
      t.schema do |s|
        s.integer "id", mode: :required
        s.string "name", mode: :required
        s.string "breed", mode: :required
      end
    end

    data_preserved = dataset.query "SELECT id, name, breed FROM pets_control", external: { pets_control: ext_table_preserved }
    _(data_preserved.count).must_equal 1
    _(data_preserved.first[:id]).must_equal 1
    _(data_preserved.first[:name]).must_equal "foo\x01bar"
    _(data_preserved.first[:breed]).must_equal "baz\x1Fqux"

    # Second, test with preserve_ascii_control_characters = false
    ext_table_stripped = dataset.external control_char_file.to_gs_url do |t|
      t.skip_leading_rows = 1
      t.preserve_ascii_control_characters = false
      t.schema do |s|
        s.integer "id", mode: :required
        s.string "name", mode: :required
        s.string "breed", mode: :required
      end
    end

    data_stripped = dataset.query "SELECT id, name, breed FROM pets_control", external: { pets_control: ext_table_stripped }
    _(data_stripped.count).must_equal 1
    _(data_stripped.first[:id]).must_equal 1
    _(data_stripped.first[:name]).must_equal "foo bar" # each control char should be replaced with a space
    _(data_stripped.first[:breed]).must_equal "baz qux"
  end
end
