# Copyright 2016 Google LLC
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

describe Google::Cloud::Spanner::Results, :merge, :mock_spanner do
  it "merges Strings" do
    results_hashes = [
      { metadata: { rowType: { fields: [{ name: "f1", type: { code: "STRING" } }] } },
        values: [{ stringValue: "abc" }],
        chunkedValue: true },
      { values: [{ stringValue: "def" }],
        chunkedValue: true },
      { values: [{ stringValue: "ghi" }] }
    ]
    results_enum = results_hashes.map { |hash| Google::Spanner::V1::PartialResultSet.decode_json hash.to_json }.to_enum
    results = Google::Cloud::Spanner::Results.from_enum results_enum, spanner.service

    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.fields.wont_be :nil?
    results.fields.must_be_kind_of Google::Cloud::Spanner::Fields
    results.fields.keys.count.must_equal 1
    results.fields[:f1].must_equal :STRING

    rows = results.rows.to_a # grab them all from the enumerator
    rows.count.must_equal 1
    row = rows.first
    row.must_be_kind_of Google::Cloud::Spanner::Data
    row[:f1].must_equal "abcdefghi"
  end

  it "merges String Arrays" do
    results_hashes = [
      { metadata: { rowType: { fields: [{ name: "f1", type: { code: "ARRAY", arrayElementType: { code: "STRING" }}}] }},
        values: [{ listValue: { values: [{ stringValue: "abc" }, { stringValue: "d" }] }}],
        chunkedValue: true },
      { values: [{ listValue: { values: [{ stringValue: "ef" }, { stringValue: "gh" }] }}],
        chunkedValue: true },
      { values: [{ listValue: { values: [{ stringValue: "i" }, { stringValue: "jkl" }] }}]}
    ]
    results_enum = results_hashes.map { |hash| Google::Spanner::V1::PartialResultSet.decode_json hash.to_json }.to_enum
    results = Google::Cloud::Spanner::Results.from_enum results_enum, spanner.service

    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.fields.wont_be :nil?
    results.fields.must_be_kind_of Google::Cloud::Spanner::Fields
    results.fields.keys.count.must_equal 1
    results.fields[:f1].must_equal [:STRING]

    rows = results.rows.to_a # grab them all from the enumerator
    rows.count.must_equal 1
    row = rows.first
    row.must_be_kind_of Google::Cloud::Spanner::Data
    row[:f1].must_equal ["abc", "def", "ghi", "jkl"]
  end

  it "merges String Arrays With Nulls" do
    results_hashes = [
      { metadata: { rowType: { fields: [{ name: "f1", type: { code: "ARRAY", arrayElementType: { code: "STRING" }}}] }},
        values: [{ listValue: { values: [{ stringValue: "abc" }, { stringValue: "def" }] }}],
        chunkedValue: true },
      { values: [{ listValue: { values: [{ nullValue: "NULL_VALUE" }, { stringValue: "ghi" }] }}],
        chunkedValue: true },
      { values: [{ listValue: { values: [{ nullValue: "NULL_VALUE" }, { stringValue: "jkl" }] }}]}
    ]
    results_enum = results_hashes.map { |hash| Google::Spanner::V1::PartialResultSet.decode_json hash.to_json }.to_enum
    results = Google::Cloud::Spanner::Results.from_enum results_enum, spanner.service

    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.fields.wont_be :nil?
    results.fields.must_be_kind_of Google::Cloud::Spanner::Fields
    results.fields.keys.count.must_equal 1
    results.fields[:f1].must_equal [:STRING]

    rows = results.rows.to_a # grab them all from the enumerator
    rows.count.must_equal 1
    row = rows.first
    row.must_be_kind_of Google::Cloud::Spanner::Data
    row[:f1].must_equal ["abc", "def", nil, "ghi", nil, "jkl"]
  end

  it "merges String Arrays With Empty Strings" do
    results_hashes = [
      { metadata: { rowType: { fields: [{ name: "f1", type: { code: "ARRAY", arrayElementType: { code: "STRING" }}}] }},
        values: [{ listValue: { values: [{ stringValue: "abc" }, { stringValue: "def" }] }}],
        chunkedValue: true },
      { values: [{ listValue: { values: [{ stringValue: "" }, { stringValue: "ghi" }] }}],
        chunkedValue: true },
      { values: [{ listValue: { values: [{ stringValue: "" }, { stringValue: "jkl" }] }}]}
    ]
    results_enum = results_hashes.map { |hash| Google::Spanner::V1::PartialResultSet.decode_json hash.to_json }.to_enum
    results = Google::Cloud::Spanner::Results.from_enum results_enum, spanner.service

    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.fields.wont_be :nil?
    results.fields.must_be_kind_of Google::Cloud::Spanner::Fields
    results.fields.keys.count.must_equal 1
    results.fields[:f1].must_equal [:STRING]

    rows = results.rows.to_a # grab them all from the enumerator
    rows.count.must_equal 1
    row = rows.first
    row.must_be_kind_of Google::Cloud::Spanner::Data
    row[:f1].must_equal ["abc", "def", "ghi", "jkl"]
  end

  it "merges String Arrays With One Large String" do
    results_hashes = [
      { metadata: { rowType: { fields: [{ name: "f1", type: { code: "ARRAY", arrayElementType: { code: "STRING" }}}] }},
        values: [{ listValue: { values: [{ stringValue: "abc" }] }}],
        chunkedValue: true },
      { values: [{ listValue: { values: [{ stringValue: "def" }] }}],
        chunkedValue: true },
      { values: [{ listValue: { values: [{ stringValue: "ghi" }] }}]}
    ]
    results_enum = results_hashes.map { |hash| Google::Spanner::V1::PartialResultSet.decode_json hash.to_json }.to_enum
    results = Google::Cloud::Spanner::Results.from_enum results_enum, spanner.service

    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.fields.wont_be :nil?
    results.fields.must_be_kind_of Google::Cloud::Spanner::Fields
    results.fields.keys.count.must_equal 1
    results.fields[:f1].must_equal [:STRING]

    rows = results.rows.to_a # grab them all from the enumerator
    rows.count.must_equal 1
    row = rows.first
    row.must_be_kind_of Google::Cloud::Spanner::Data
    row[:f1].must_equal ["abcdefghi"]
  end

  it "merges INT64 Arrays" do
    results_hashes = [
      { metadata: { rowType: { fields: [{ name: "f1", type: { code: "ARRAY", arrayElementType: { code: "INT64" }}}] }},
        values: [{ listValue: { values: [{ stringValue: "1" }, { stringValue: "2" }] }}],
        chunkedValue: true },
      { values: [{ listValue: { values: [{ stringValue: "3" }, { stringValue: "4" }] }}],
        chunkedValue: true },
      { values: [{ listValue: { values: [{ nullValue: "NULL_VALUE" }, { stringValue: "5" }] }}]}
    ]
    results_enum = results_hashes.map { |hash| Google::Spanner::V1::PartialResultSet.decode_json hash.to_json }.to_enum
    results = Google::Cloud::Spanner::Results.from_enum results_enum, spanner.service

    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.fields.wont_be :nil?
    results.fields.must_be_kind_of Google::Cloud::Spanner::Fields
    results.fields.keys.count.must_equal 1
    results.fields[:f1].must_equal [:INT64]

    rows = results.rows.to_a # grab them all from the enumerator
    rows.count.must_equal 1
    row = rows.first
    row.must_be_kind_of Google::Cloud::Spanner::Data
    row[:f1].must_equal [1, 23, 4, nil, 5]
  end

  it "merges FLOAT64 Arrays" do
    results_hashes = [
      { metadata: { rowType: { fields: [{ name: "f1", type: { code: "ARRAY", arrayElementType: { code: "FLOAT64" }}}] }},
        values: [{ listValue: { values: [{ numberValue: 1.0 }, { numberValue: 2.0 }] }}],
        chunkedValue: true },
      { values: [{ listValue: { values: [{ stringValue: "Infinity" }, { stringValue: "-Infinity" }, { stringValue: "NaN" }] }}],
        chunkedValue: true },
      { values: [{ listValue: { values: [{ nullValue: "NULL_VALUE" }, { numberValue: 3.0 }] }}]}
    ]
    results_enum = results_hashes.map { |hash| Google::Spanner::V1::PartialResultSet.decode_json hash.to_json }.to_enum
    results = Google::Cloud::Spanner::Results.from_enum results_enum, spanner.service

    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.fields.wont_be :nil?
    results.fields.must_be_kind_of Google::Cloud::Spanner::Fields
    results.fields.keys.count.must_equal 1
    results.fields[:f1].must_equal [:FLOAT64]

    rows = results.rows.to_a # grab them all from the enumerator
    rows.count.must_equal 1
    row = rows.first
    row.must_be_kind_of Google::Cloud::Spanner::Data
    row[:f1].must_equal [1.0, 2.0, Float::INFINITY, -Float::INFINITY, Float::NAN, nil, 3.0]
  end

  it "merges Multiple Row Chunks/Non Chunks Interleaved" do
    results_hashes = [
      { metadata: { rowType: { fields: [{ name: "f1", type: { code: "STRING" } }] } },
        values: [{ stringValue: "a" }],
        chunkedValue: true },
      { values: [{ stringValue: "b" }, { stringValue: "c" }] },
      { values: [{ stringValue: "d" }, { stringValue: "e" }],
        chunkedValue: true },
      { values: [{ stringValue: "f" }] }
    ]
    results_enum = results_hashes.map { |hash| Google::Spanner::V1::PartialResultSet.decode_json hash.to_json }.to_enum
    results = Google::Cloud::Spanner::Results.from_enum results_enum, spanner.service

    results.must_be_kind_of Google::Cloud::Spanner::Results

    results.fields.wont_be :nil?
    results.fields.must_be_kind_of Google::Cloud::Spanner::Fields
    results.fields.keys.count.must_equal 1
    results.fields[:f1].must_equal :STRING

    rows = results.rows.to_a # grab them all from the enumerator
    rows.count.must_equal 4
    rows.map(&:to_h).must_equal [{ f1: "ab" }, { f1: "c" }, { f1: "d" }, { f1: "ef" }]
  end
end
