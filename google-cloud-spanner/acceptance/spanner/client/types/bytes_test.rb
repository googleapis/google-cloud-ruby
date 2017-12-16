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

require "spanner_helper"

describe "Spanner Client", :types, :bytes, :spanner do
  let(:db) { spanner_client }
  let(:table_name) { "stuffs" }

  it "writes and reads bytes" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, byte: StringIO.new("hello") }
    results = db.read table_name, [:id, :byte], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, byte: :BYTES })
    returned_value = results.rows.first[:byte]
    returned_value.must_be_kind_of StringIO
    returned_value.read.must_equal "hello"
  end

  it "writes and queries bytes" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, byte: StringIO.new("hello") }
    results = db.execute "SELECT id, byte FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, byte: :BYTES })
    returned_value = results.rows.first[:byte]
    returned_value.must_be_kind_of StringIO
    returned_value.read.must_equal "hello"
  end

  it "writes and reads random bytes" do
    id = SecureRandom.int64
    random_bytes = StringIO.new(SecureRandom.random_bytes(rand(1024..4096)))
    db.upsert table_name, { id: id, byte: random_bytes }
    results = db.read table_name, [:id, :byte], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, byte: :BYTES })
    returned_value = results.rows.first[:byte]
    returned_value.must_be_kind_of StringIO
    random_bytes.rewind
    returned_value.read.must_equal random_bytes.read
  end

  it "writes and queries random bytes" do
    id = SecureRandom.int64
    random_bytes = StringIO.new(SecureRandom.random_bytes(rand(1024..4096)))
    db.upsert table_name, { id: id, byte: random_bytes }
    results = db.execute "SELECT id, byte FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, byte: :BYTES })
    returned_value = results.rows.first[:byte]
    returned_value.must_be_kind_of StringIO
    random_bytes.rewind
    returned_value.read.must_equal random_bytes.read
  end

  it "writes and reads NULL bytes" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, byte: nil }
    results = db.read table_name, [:id, :byte], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, byte: :BYTES })
    returned_value = results.rows.first[:byte]
    returned_value.must_be :nil?
  end

  it "writes and queries NULL bytes" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, byte: nil }
    results = db.execute "SELECT id, byte FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, byte: :BYTES })
    returned_value = results.rows.first[:byte]
    returned_value.must_be :nil?
  end

  it "writes and reads array of bytes" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, bytes: [StringIO.new("howdy"), StringIO.new("hola"), StringIO.new("hello")] }
    results = db.read table_name, [:id, :bytes], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, bytes: [:BYTES] })
    returned_values = results.rows.first[:bytes]
    returned_values[0].must_be_kind_of StringIO
    returned_values[0].read.must_equal "howdy"
    returned_values[1].must_be_kind_of StringIO
    returned_values[1].read.must_equal "hola"
    returned_values[2].must_be_kind_of StringIO
    returned_values[2].read.must_equal "hello"
  end

  it "writes and queries array of bytes" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, bytes: [StringIO.new("howdy"), StringIO.new("hola"), StringIO.new("hello")] }
    results = db.execute "SELECT id, bytes FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, bytes: [:BYTES] })
    returned_values = results.rows.first[:bytes]
    returned_values[0].must_be_kind_of StringIO
    returned_values[0].read.must_equal "howdy"
    returned_values[1].must_be_kind_of StringIO
    returned_values[1].read.must_equal "hola"
    returned_values[2].must_be_kind_of StringIO
    returned_values[2].read.must_equal "hello"
  end

  it "writes and reads array of byte with NULL" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, bytes: [nil, StringIO.new("howdy"), StringIO.new("hola"), StringIO.new("hello")] }
    results = db.read table_name, [:id, :bytes], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, bytes: [:BYTES] })
    returned_values = results.rows.first[:bytes]
    returned_values[0].must_be :nil?
    returned_values[1].must_be_kind_of StringIO
    returned_values[1].read.must_equal "howdy"
    returned_values[2].must_be_kind_of StringIO
    returned_values[2].read.must_equal "hola"
    returned_values[3].must_be_kind_of StringIO
    returned_values[3].read.must_equal "hello"
  end

  it "writes and queries array of byte with NULL" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, bytes: [nil, StringIO.new("howdy"), StringIO.new("hola"), StringIO.new("hello")] }
    results = db.execute "SELECT id, bytes FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, bytes: [:BYTES] })
    returned_values = results.rows.first[:bytes]
    returned_values[0].must_be :nil?
    returned_values[1].must_be_kind_of StringIO
    returned_values[1].read.must_equal "howdy"
    returned_values[2].must_be_kind_of StringIO
    returned_values[2].read.must_equal "hola"
    returned_values[3].must_be_kind_of StringIO
    returned_values[3].read.must_equal "hello"
  end

  it "writes and reads empty array of byte" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, bytes: [] }
    results = db.read table_name, [:id, :bytes], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, bytes: [:BYTES] })
    results.rows.first[:bytes].must_equal []
  end

  it "writes and queries empty array of byte" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, bytes: [] }
    results = db.execute "SELECT id, bytes FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, bytes: [:BYTES] })
    results.rows.first[:bytes].must_equal []
  end

  it "writes and reads NULL array of byte" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, bytes: nil }
    results = db.read table_name, [:id, :bytes], keys: id

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, bytes: [:BYTES] })
    results.rows.first[:bytes].must_be :nil?
  end

  it "writes and queries NULL array of byte" do
    id = SecureRandom.int64
    db.upsert table_name, { id: id, bytes: nil }
    results = db.execute "SELECT id, bytes FROM #{table_name} WHERE id = @id", params: { id: id }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ id: :INT64, bytes: [:BYTES] })
    results.rows.first[:bytes].must_be :nil?
  end
end
