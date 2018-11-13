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

describe "Spanner Client", :read, :spanner do
  let(:db) { spanner_client }
  let(:table_name) { "stuffs" }
  let(:table_index) { "IsStuffsIdPrime" }

  before do
    db.delete table_name # remove all data
    db.insert table_name, [
      { id: 1, bool: false },
      { id: 2, bool: false },
      { id: 3, bool: true },
      { id: 4, bool: false },
      { id: 5, bool: true },
      { id: 6, bool: false },
      { id: 7, bool: true },
      { id: 8, bool: false },
      { id: 9, bool: false },
      { id: 10, bool: false },
      { id: 11, bool: true },
      { id: 12, bool: false }
    ]
  end

  after do
    db.delete table_name # remove all data
  end

  it "reads all by default" do
    db.read(table_name, [:id]).rows.map(&:to_h).must_equal [{ id: 1 }, { id: 2 }, { id: 3 }, { id: 4 }, { id: 5 }, { id: 6 }, { id: 7 }, { id: 8 }, { id: 9 }, { id: 10 }, { id: 11 }, { id: 12 }]
    db.read(table_name, [:id], limit: 5).rows.map(&:to_h).must_equal [{ id: 1 }, { id: 2 }, { id: 3 }, { id: 4 }, { id: 5 }]

    db.read(table_name, [:id, :bool], index: table_index).rows.map(&:to_h).must_equal [{ id: 1, bool: false }, { id: 2, bool: false }, { id: 4, bool: false }, { id: 6, bool: false }, { id: 8, bool: false }, { id: 9, bool: false }, { id: 10, bool: false }, { id: 12, bool: false }, { id: 3, bool: true }, { id: 5, bool: true }, { id: 7, bool: true }, { id: 11, bool: true }]
    db.read(table_name, [:id, :bool], index: table_index, limit: 5).rows.map(&:to_h).must_equal [{ id: 1, bool: false }, { id: 2, bool: false }, { id: 4, bool: false }, { id: 6, bool: false }, { id: 8, bool: false }]
  end

  it "empty read works" do
    random_id = SecureRandom.int64
    db.delete table_name, random_id
    # [START spanner_test_empty_read]
    # [START spanner_test_single_key_dne_read]
    db.read(table_name, [:id], keys: random_id).rows.map(&:to_h).must_equal []
    # [END spanner_test_empty_read]
    # [END spanner_test_single_key_dne_read]

    db.delete table_name, 9997..9999
    db.read(table_name, [:id], keys: 9997..9999).rows.map(&:to_h).must_equal []

    # [START spanner_test_empty_read_index]
    # [START spanner_test_single_key_index_read]
    db.read(table_name, [:id, :bool], index: table_index, keys: [[false, 3]]).rows.map(&:to_h).must_equal []
    # [END spanner_test_empty_read_index]
    # [END spanner_test_single_key_index_read]
  end

  it "reads with a list of keys" do
    # [START spanner_test_single_key_read]
    # [START spanner_test_single_key_dne_index_read]
    # [START spanner_test_read_set_point_keys]
    # [START spanner_test_read_set_point_keys_index]
    db.read(table_name, [:id], keys: 1).rows.map(&:to_h).must_equal [{ id: 1 }]
    # [END spanner_test_single_key_read]
    # [END spanner_test_single_key_dne_index_read]
    db.read(table_name, [:id], keys: [1]).rows.map(&:to_h).must_equal [{ id: 1 }]
    db.read(table_name, [:id], keys: [3, 4, 5]).rows.map(&:to_h).must_equal [{ id: 3 }, { id: 4 }, { id: 5 }]
    db.read(table_name, [:id], keys: [3, 5, 7, 11]).rows.map(&:to_h).must_equal [{ id: 3 }, { id: 5 }, { id: 7 }, { id: 11 }]

    db.read(table_name, [:id], keys: [3, 5, 7, 11], limit: 2).rows.map(&:to_h).must_equal [{ id: 3 }, { id: 5 }]
    # [END spanner_test_read_set_point_keys]
    # [END spanner_test_read_set_point_keys_index]
  end

  it "reads with range key sets" do
    db.read(table_name, [:id], keys: 3..5).rows.map(&:to_h).must_equal [{ id: 3 }, { id: 4 }, { id: 5 }]
    db.read(table_name, [:id], keys: 3...5).rows.map(&:to_h).must_equal [{ id: 3 }, { id: 4 }]
    db.read(table_name, [:id], keys: db.range(3, 5, exclude_begin: true)).rows.map(&:to_h).must_equal [{ id: 4 }, { id: 5 }]
    db.read(table_name, [:id], keys: db.range(3, 5, exclude_begin: true, exclude_end: true)).rows.map(&:to_h).must_equal [{ id: 4 }]
    db.read(table_name, [:id], keys: [7]..[]).rows.map(&:to_h).must_equal [{ id: 7 }, { id: 8 }, { id: 9 }, { id: 10 }, { id: 11 }, { id: 12 }]
    db.read(table_name, [:id], keys: db.range([7], [], exclude_begin: true)).rows.map(&:to_h).must_equal [{ id: 8 }, { id: 9 }, { id: 10 }, { id: 11 }, { id: 12 }]
    db.read(table_name, [:id], keys: []..[5]).rows.map(&:to_h).must_equal [{ id: 1 }, { id: 2 }, { id: 3 }, { id: 4 }, { id: 5 }]
    db.read(table_name, [:id], keys: []...[5]).rows.map(&:to_h).must_equal [{ id: 1 }, { id: 2 }, { id: 3 }, { id: 4 }]
  end

  it "reads with range key sets and limit" do
    # [START spanner_test_range_reads_single_key]
    # [START spanner_test_read_with_limit]
    # [START spanner_test_read_with_limit_index]
    db.read(table_name, [:id], keys: 3..9, limit: 2).rows.map(&:to_h).must_equal [{ id: 3 }, { id: 4 }]
    db.read(table_name, [:id], keys: 3...9, limit: 2).rows.map(&:to_h).must_equal [{ id: 3 }, { id: 4 }]
    db.read(table_name, [:id], keys: db.range(3, 9, exclude_begin: true), limit: 2).rows.map(&:to_h).must_equal [{ id: 4 }, { id: 5 }]
    db.read(table_name, [:id], keys: db.range(3, 9, exclude_begin: true, exclude_end: true), limit: 2).rows.map(&:to_h).must_equal [{ id: 4 }, { id: 5 }]
    db.read(table_name, [:id], keys: [3]..[], limit: 2).rows.map(&:to_h).must_equal [{ id: 3}, { id: 4}]
    db.read(table_name, [:id], keys: db.range([3], [], exclude_begin: true), limit: 2).rows.map(&:to_h).must_equal [{ id: 4 }, { id: 5 }]
    db.read(table_name, [:id], keys: []..[9], limit: 2).rows.map(&:to_h).must_equal [{ id: 1 }, { id: 2 }]
    db.read(table_name, [:id], keys: []...[9], limit: 2).rows.map(&:to_h).must_equal [{ id: 1 }, { id: 2 }]
    # [END spanner_test_range_reads_single_key]
    # [END spanner_test_read_with_limit]
    # [END spanner_test_read_with_limit_index]
  end

  it "reads from index with a list of composite keys" do
    db.read(table_name, [:id, :bool], index: table_index, keys: [[false, 1]]).rows.map(&:to_h).must_equal [{ id: 1, bool: false }]
    # Provide 3 keys, but only get 2 results...
    db.read(table_name, [:id, :bool], index: table_index, keys: [[true, 3], [true, 4], [true, 5]]).rows.map(&:to_h).must_equal [{ id: 3, bool: true }, { id: 5, bool: true }]
    db.read(table_name, [:id, :bool], index: table_index, keys: [[true, 3], [true, 5], [true, 7], [true, 11]]).rows.map(&:to_h).must_equal [{ id: 3, bool: true }, { id: 5, bool: true }, { id: 7, bool: true }, { id: 11, bool: true }]

    db.read(table_name, [:id, :bool], index: table_index, keys: [[false, 1], [false, 2], [false, 3], [false, 4], [false, 5], [false, 6]], limit: 3).rows.map(&:to_h).must_equal [{ id: 1, bool: false }, { id: 2, bool: false }, { id: 4, bool: false }]
  end

  it "reads from index with range key sets" do
    db.read(table_name, [:id, :bool], index: table_index, keys: [true, 3]..[true, 7]).rows.map(&:to_h).must_equal [{ id: 3, bool: true }, { id: 5, bool: true }, { id: 7, bool: true }]
    db.read(table_name, [:id, :bool], index: table_index, keys: [true, 3]...[true, 7]).rows.map(&:to_h).must_equal [{ id: 3, bool: true }, { id: 5, bool: true }]
    db.read(table_name, [:id, :bool], index: table_index, keys: db.range([true, 3], [true, 7], exclude_begin: true)).rows.map(&:to_h).must_equal [{ id: 5, bool: true }, { id: 7, bool: true }]
    db.read(table_name, [:id, :bool], index: table_index, keys: db.range([true, 3], [true, 7], exclude_begin: true, exclude_end: true)).rows.map(&:to_h).must_equal [{ id: 5, bool: true }]
    db.read(table_name, [:id, :bool], index: table_index, keys: [true, 7]..[]).rows.map(&:to_h).must_equal [{ id: 7, bool: true }, { id: 11, bool: true }]
    db.read(table_name, [:id, :bool], index: table_index, keys: db.range([true, 7], [], exclude_begin: true)).rows.map(&:to_h).must_equal [{ id: 11, bool: true }]
    db.read(table_name, [:id, :bool], index: table_index, keys: [true]..[true, 7]).rows.map(&:to_h).must_equal [{ id: 3, bool: true }, { id: 5, bool: true }, { id: 7, bool: true }]
    db.read(table_name, [:id, :bool], index: table_index, keys: [true]...[true, 7]).rows.map(&:to_h).must_equal [{ id: 3, bool: true }, { id: 5, bool: true }]
  end

  it "reads from index with range key sets and limit" do
    # [START spanner_test_range_reads_index]
    db.read(table_name, [:id, :bool], index: table_index, keys: [true, 3]..[true, 11], limit: 2).rows.map(&:to_h).must_equal [{ id: 3, bool: true }, { id: 5, bool: true }]
    db.read(table_name, [:id, :bool], index: table_index, keys: [true, 3]...[true, 11], limit: 2).rows.map(&:to_h).must_equal [{ id: 3, bool: true }, { id: 5, bool: true }]
    db.read(table_name, [:id, :bool], index: table_index, keys: db.range([true, 3], [true, 7], exclude_begin: true), limit: 2).rows.map(&:to_h).must_equal [{ id: 5, bool: true }, { id: 7, bool: true }]
    db.read(table_name, [:id, :bool], index: table_index, keys: db.range([true, 3], [true, 7], exclude_begin: true, exclude_end: true), limit: 2).rows.map(&:to_h).must_equal [{ id: 5, bool: true }]
    db.read(table_name, [:id, :bool], index: table_index, keys: [true, 5]..[], limit: 2).rows.map(&:to_h).must_equal [{ id: 5, bool: true }, { id: 7, bool: true }]
    db.read(table_name, [:id, :bool], index: table_index, keys: db.range([true, 5], [], exclude_begin: true), limit: 2).rows.map(&:to_h).must_equal [{ id: 7, bool: true }, { id: 11, bool: true }]
    db.read(table_name, [:id, :bool], index: table_index, keys: [true]..[true, 11], limit: 2).rows.map(&:to_h).must_equal [{ id: 3, bool: true }, { id: 5, bool: true }]
    db.read(table_name, [:id, :bool], index: table_index, keys: [true]...[true, 11], limit: 2).rows.map(&:to_h).must_equal [{ id: 3, bool: true }, { id: 5, bool: true }]
    # [END spanner_test_range_reads_index]
  end
end
