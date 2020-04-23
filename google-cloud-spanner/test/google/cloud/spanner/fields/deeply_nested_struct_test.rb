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

describe Google::Cloud::Spanner::Fields, :deeply_nested_struct do
  let(:fields_hash) { { id: :INT64, name: :STRING, active: :BOOL, age: :INT64, score: :FLOAT64, updated_at: :TIMESTAMP, birthday: :DATE, avatar: :BYTES, project_ids: [:INT64] } }
  let(:fields) { Google::Cloud::Spanner::Fields.new fields_hash }

  it "creates with an array of fields" do
    data = fields.struct id: 1, name: "Charlie", active: true, age: 29, score: 0.9,
                         updated_at: Time.parse("2017-01-02T03:04:05.060000000Z"),
                         birthday: Date.parse("1950-01-01"), avatar: StringIO.new("image"),
                         project_ids: [1, 2, 3]

    _(data).must_be_kind_of Google::Cloud::Spanner::Data

    _(data.fields).wont_be :nil?
    _(data.fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(data.fields.keys.count).must_equal 9
    _(data.fields.to_h).must_equal({ id: :INT64, name: :STRING, active: :BOOL, age: :INT64,
                                 score: :FLOAT64, updated_at: :TIMESTAMP, birthday: :DATE,
                                 avatar: :BYTES, project_ids: [:INT64] })

    _(data.fields.to_s).wont_be :empty?
    _(data.fields.inspect).must_match /Google::Cloud::Spanner::Fields/

    _(data.keys).must_equal [:id, :name, :active, :age, :score, :updated_at, :birthday, :avatar, :project_ids]
    data_values = data.values
    _(data_values[0]).must_equal 1
    _(data_values[1]).must_equal "Charlie"
    _(data_values[2]).must_equal true
    _(data_values[3]).must_equal 29
    _(data_values[4]).must_equal 0.9
    _(data_values[5]).must_equal Time.parse("2017-01-02T03:04:05.060000000Z")
    _(data_values[6]).must_equal Date.parse("1950-01-01")
    _(data_values[7]).must_be_kind_of StringIO
    _(data_values[7].read).must_equal "image"
    _(data_values[8]).must_equal [1, 2, 3]

    _(data[:id]).must_equal 1
    _(data[:name]).must_equal "Charlie"
    _(data[:active]).must_equal true
    _(data[:age]).must_equal 29
    _(data[:score]).must_equal 0.9
    _(data[:updated_at]).must_equal Time.parse("2017-01-02T03:04:05.060000000Z")
    _(data[:birthday]).must_equal Date.parse("1950-01-01")
    _(data[:avatar]).must_be_kind_of StringIO
    _(data[:avatar].read).must_equal "image"
    _(data[:project_ids]).must_equal [1, 2, 3]

    _(data[0]).must_equal 1
    _(data[1]).must_equal "Charlie"
    _(data[2]).must_equal true
    _(data[3]).must_equal 29
    _(data[4]).must_equal 0.9
    _(data[5]).must_equal Time.parse("2017-01-02T03:04:05.060000000Z")
    _(data[6]).must_equal Date.parse("1950-01-01")
    _(data[7]).must_be_kind_of StringIO
    _(data[7].read).must_equal "image"
    _(data[8]).must_equal [1, 2, 3]

    data_hash = data.to_h
    _(data_hash[:id]).must_equal 1
    _(data_hash[:name]).must_equal "Charlie"
    _(data_hash[:active]).must_equal true
    _(data_hash[:age]).must_equal 29
    _(data_hash[:score]).must_equal 0.9
    _(data_hash[:updated_at]).must_equal Time.parse("2017-01-02T03:04:05.060000000Z")
    _(data_hash[:birthday]).must_equal Date.parse("1950-01-01")
    _(data_hash[:avatar]).must_be_kind_of StringIO
    _(data_hash[:avatar].read).must_equal "image"
    _(data_hash[:project_ids]).must_equal [1, 2, 3]

    data_array = data.to_a
    _(data_array[0]).must_equal 1
    _(data_array[1]).must_equal "Charlie"
    _(data_array[2]).must_equal true
    _(data_array[3]).must_equal 29
    _(data_array[4]).must_equal 0.9
    _(data_array[5]).must_equal Time.parse("2017-01-02T03:04:05.060000000Z")
    _(data_array[6]).must_equal Date.parse("1950-01-01")
    _(data_array[7]).must_be_kind_of StringIO
    _(data_array[7].read).must_equal "image"
    _(data_array[8]).must_equal [1, 2, 3]

    _(data.to_s).wont_be :empty?
    _(data.inspect).must_match /Google::Cloud::Spanner::Data/
  end
end
