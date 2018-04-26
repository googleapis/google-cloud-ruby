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

require "helper"

describe Google::Cloud::Spanner::Fields, :struct do
  let(:fields_unnamed_array) { [:INT64, :STRING, :BOOL, :INT64, :FLOAT64, :TIMESTAMP, :DATE, :BYTES, [:INT64]] }
  let(:fields_named_array) { [[:id, :INT64], [:name, :STRING], [:active, :BOOL], [:age, :INT64], [:score, :FLOAT64], [:updated_at, :TIMESTAMP], [:birthday, :DATE], [:avatar, :BYTES], [:project_ids, [:INT64]]] }
  let(:fields_named_hash) { { id: :INT64, name: :STRING, active: :BOOL, age: :INT64, score: :FLOAT64, updated_at: :TIMESTAMP, birthday: :DATE, avatar: :BYTES, project_ids: [:INT64] } }
  let(:fields_unnamed_hash) { { 0 => :INT64, 1 => :STRING, 2 => :BOOL, 3 => :INT64, 4 => :FLOAT64, 5 => :TIMESTAMP, 6 => :DATE, 7 => :BYTES, 8 => [:INT64] } }
  let(:data_array) { [1, "Charlie", true, 29, 0.9, Time.parse("2017-01-02T03:04:05.060000000Z"), Date.parse("1950-01-01"), StringIO.new("image"), [1, 2, 3]] }
  let(:data_named_hash) { { id: 1, name: "Charlie", active: true, age: 29, score: 0.9, updated_at: Time.parse("2017-01-02T03:04:05.060000000Z"), birthday: Date.parse("1950-01-01"), avatar: StringIO.new("image"), project_ids: [1, 2, 3] } }
  let(:data_unnamed_hash) { { 0 => 1, 1 => "Charlie", 2 => true, 3 => 29, 4 => 0.9, 5 => Time.parse("2017-01-02T03:04:05.060000000Z"), 6 => Date.parse("1950-01-01"), 7 => StringIO.new("image"), 8 => [1, 2, 3] } }

  it "creates with an unnamed array of fields and an array of values" do
    fields = Google::Cloud::Spanner::Fields.new fields_unnamed_array

    data = fields.struct data_array

    assert_unnamed_struct data
  end

  it "creates with an named array of fields and an array of values" do
    fields = Google::Cloud::Spanner::Fields.new fields_named_array

    data = fields.struct data_array

    assert_named_struct data
  end

  it "creates with an unnamed array of fields and a named hash of values" do
    skip "Cannot create with an unnamed array of fields and a named hash of values, " \
         "because the value hash keys have names and don't match the fields."
    fields = Google::Cloud::Spanner::Fields.new fields_unnamed_array

    data = fields.struct data_named_hash

    assert_unnamed_struct data
  end

  it "creates with an unnamed array of fields and an unnamed hash of values" do
    fields = Google::Cloud::Spanner::Fields.new fields_unnamed_array

    data = fields.struct data_unnamed_hash

    assert_unnamed_struct data
  end

  it "creates with a named array of fields and a named hash of values" do
    fields = Google::Cloud::Spanner::Fields.new fields_named_array

    data = fields.struct data_named_hash

    assert_named_struct data
  end

  it "creates with a named array of fields and an unnamed hash of values" do
    fields = Google::Cloud::Spanner::Fields.new fields_named_array

    data = fields.struct data_unnamed_hash

    assert_named_struct data
  end

  it "creates with a named hash of fields and an array of values" do
    fields = Google::Cloud::Spanner::Fields.new fields_named_hash

    data = fields.struct data_array

    assert_named_struct data
  end

  it "creates with an unnamed hash of fields and an array of values" do
    fields = Google::Cloud::Spanner::Fields.new fields_unnamed_hash

    data = fields.struct data_array

    assert_unnamed_struct data
  end

  it "creates with a named hash of fields and a named hash of values" do
    fields = Google::Cloud::Spanner::Fields.new fields_named_hash

    data = fields.struct data_named_hash

    assert_named_struct data
  end

  it "creates with a named hash of fields and an unnamed hash of values" do
    fields = Google::Cloud::Spanner::Fields.new fields_named_hash

    data = fields.struct data_unnamed_hash

    assert_named_struct data
  end

  it "creates with an unnamed hash of fields and a named hash of values" do
    skip "Cannot create with an unnamed hash of fields and a named hash of values, " \
         "because the value hash keys have names and don't match the fields hash keys."
    fields = Google::Cloud::Spanner::Fields.new fields_unnamed_hash

    data = fields.struct data_named_hash

    assert_unnamed_struct data
  end

  it "creates with an unnamed hash of fields and an unnamed hash of values" do
    fields = Google::Cloud::Spanner::Fields.new fields_unnamed_hash

    data = fields.struct data_unnamed_hash

    assert_unnamed_struct data
  end

  def assert_unnamed_struct data
    data.must_be_kind_of Google::Cloud::Spanner::Data

    data.fields.wont_be :nil?
    data.fields.must_be_kind_of Google::Cloud::Spanner::Fields
    data.fields.keys.count.must_equal 9
    data.fields.to_a.must_equal fields_unnamed_array
    data.fields.to_h.must_equal fields_unnamed_hash

    data.fields.to_s.wont_be :empty?
    data.fields.inspect.must_match /Google::Cloud::Spanner::Fields/

    data.keys.must_equal [0, 1, 2, 3, 4, 5, 6, 7, 8]
    data_values = data.values
    data_values[0].must_equal 1
    data_values[1].must_equal "Charlie"
    data_values[2].must_equal true
    data_values[3].must_equal 29
    data_values[4].must_equal 0.9
    data_values[5].must_equal Time.parse("2017-01-02T03:04:05.060000000Z")
    data_values[6].must_equal Date.parse("1950-01-01")
    data_values[7].must_be_kind_of StringIO
    data_values[7].read.must_equal "image"
    data_values[8].must_equal [1, 2, 3]

    data[0].must_equal 1
    data[1].must_equal "Charlie"
    data[2].must_equal true
    data[3].must_equal 29
    data[4].must_equal 0.9
    data[5].must_equal Time.parse("2017-01-02T03:04:05.060000000Z")
    data[6].must_equal Date.parse("1950-01-01")
    data[7].must_be_kind_of StringIO
    data[7].read.must_equal "image"
    data[8].must_equal [1, 2, 3]

    data_hash = data.to_h
    data_hash[0].must_equal 1
    data_hash[1].must_equal "Charlie"
    data_hash[2].must_equal true
    data_hash[3].must_equal 29
    data_hash[4].must_equal 0.9
    data_hash[5].must_equal Time.parse("2017-01-02T03:04:05.060000000Z")
    data_hash[6].must_equal Date.parse("1950-01-01")
    data_hash[7].must_be_kind_of StringIO
    data_hash[7].read.must_equal "image"
    data_hash[8].must_equal [1, 2, 3]

    data_array = data.to_a
    data_array[0].must_equal 1
    data_array[1].must_equal "Charlie"
    data_array[2].must_equal true
    data_array[3].must_equal 29
    data_array[4].must_equal 0.9
    data_array[5].must_equal Time.parse("2017-01-02T03:04:05.060000000Z")
    data_array[6].must_equal Date.parse("1950-01-01")
    data_array[7].must_be_kind_of StringIO
    data_array[7].read.must_equal "image"
    data_array[8].must_equal [1, 2, 3]

    data.to_s.wont_be :empty?
    data.inspect.must_match /Google::Cloud::Spanner::Data/
  end

  def assert_named_struct data
    data.must_be_kind_of Google::Cloud::Spanner::Data

    data.fields.wont_be :nil?
    data.fields.must_be_kind_of Google::Cloud::Spanner::Fields
    data.fields.keys.count.must_equal 9
    data.fields.to_a.must_equal fields_unnamed_array
    data.fields.to_h.must_equal fields_named_hash

    data.fields.to_s.wont_be :empty?
    data.fields.inspect.must_match /Google::Cloud::Spanner::Fields/

    data.keys.must_equal [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]
    data_values = data.values
    data_values[0].must_equal 1
    data_values[1].must_equal "Charlie"
    data_values[2].must_equal true
    data_values[3].must_equal 29
    data_values[4].must_equal 0.9
    data_values[5].must_equal Time.parse("2017-01-02T03:04:05.060000000Z")
    data_values[6].must_equal Date.parse("1950-01-01")
    data_values[7].must_be_kind_of StringIO
    data_values[7].read.must_equal "image"
    data_values[8].must_equal [1, 2, 3]

    data[:id].must_equal 1
    data[:name].must_equal "Charlie"
    data[:active].must_equal true
    data[:age].must_equal 29
    data[:score].must_equal 0.9
    data[:updated_at].must_equal Time.parse("2017-01-02T03:04:05.060000000Z")
    data[:birthday].must_equal Date.parse("1950-01-01")
    data[:avatar].must_be_kind_of StringIO
    data[:avatar].read.must_equal "image"
    data[:project_ids].must_equal [1, 2, 3]

    data[0].must_equal 1
    data[1].must_equal "Charlie"
    data[2].must_equal true
    data[3].must_equal 29
    data[4].must_equal 0.9
    data[5].must_equal Time.parse("2017-01-02T03:04:05.060000000Z")
    data[6].must_equal Date.parse("1950-01-01")
    data[7].must_be_kind_of StringIO
    data[7].read.must_equal "image"
    data[8].must_equal [1, 2, 3]

    data_hash = data.to_h
    data_hash[:id].must_equal 1
    data_hash[:name].must_equal "Charlie"
    data_hash[:active].must_equal true
    data_hash[:age].must_equal 29
    data_hash[:score].must_equal 0.9
    data_hash[:updated_at].must_equal Time.parse("2017-01-02T03:04:05.060000000Z")
    data_hash[:birthday].must_equal Date.parse("1950-01-01")
    data_hash[:avatar].must_be_kind_of StringIO
    data_hash[:avatar].read.must_equal "image"
    data_hash[:project_ids].must_equal [1, 2, 3]

    data_array = data.to_a
    data_array[0].must_equal 1
    data_array[1].must_equal "Charlie"
    data_array[2].must_equal true
    data_array[3].must_equal 29
    data_array[4].must_equal 0.9
    data_array[5].must_equal Time.parse("2017-01-02T03:04:05.060000000Z")
    data_array[6].must_equal Date.parse("1950-01-01")
    data_array[7].must_be_kind_of StringIO
    data_array[7].read.must_equal "image"
    data_array[8].must_equal [1, 2, 3]

    data.to_s.wont_be :empty?
    data.inspect.must_match /Google::Cloud::Spanner::Data/
  end
end
