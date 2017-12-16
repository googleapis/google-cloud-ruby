# Copyright 2017 Google LLC
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

require "bigquery_helper"
require "csv"

describe Google::Cloud::Bigquery::Table, :external, :bigquery do
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
  let(:bucket) { Google::Cloud.storage.bucket("#{prefix}_external") || Google::Cloud.storage.create_bucket("#{prefix}_external") }
  let(:file) { bucket.file("pets.csv") || bucket.create_file(data_io, "pets.csv") }

  after do
    bucket.files.all.map(&:delete)
    bucket.delete
  end

  it "creates a table pointing to external data (with autodetect)" do
    csv_table = dataset.external file.to_gs_url do |csv|
      csv.skip_leading_rows = 1
      csv.autodetect = true
    end

    table_id = "pets_#{SecureRandom.hex(4)}"
    table = dataset.create_table table_id do |tbl|
      tbl.external = csv_table
    end

    table.must_be :external?
    table.external.wont_be :nil?
    table.external.must_be :frozen?
    table.external.must_be_kind_of Google::Cloud::Bigquery::External::CsvSource

    data = dataset.query "SELECT id, name, breed FROM #{table_id} ORDER BY id"
    data.count.must_equal 3
    data.must_equal [
      { id: 4, name: "silvano", breed: "the cat kind" },
      { id: 5, name: "ryan", breed: "golden retriever?" },
      { id: 6, name: "stephen", breed: "idkanycatbreeds" }
    ]
  end

  it "creates a table pointing to external data (with schema)" do
    csv_table = dataset.external file.to_gs_url do |csv|
      csv.skip_leading_rows = 1
      csv.schema do |s|
        s.integer   "id",    description: "id description",    mode: :required
        s.string    "name",  description: "name description",  mode: :required
        s.string    "breed", description: "breed description", mode: :required
      end
    end

    table_id = "pets_#{SecureRandom.hex(4)}"
    table = dataset.create_table table_id do |tbl|
      tbl.external = csv_table
    end

    table.must_be :external?
    table.external.wont_be :nil?
    table.external.must_be :frozen?
    table.external.must_be_kind_of Google::Cloud::Bigquery::External::CsvSource

    data = dataset.query "SELECT id, name, breed FROM #{table_id} ORDER BY id"
    data.count.must_equal 3
    data.must_equal [
      { id: 4, name: "silvano", breed: "the cat kind" },
      { id: 5, name: "ryan", breed: "golden retriever?" },
      { id: 6, name: "stephen", breed: "idkanycatbreeds" }
    ]
  end
end
