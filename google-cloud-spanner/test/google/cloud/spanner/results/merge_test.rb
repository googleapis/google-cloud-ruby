# Copyright 2016 Google LLC
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

describe Google::Cloud::Spanner::Results, :merge, :mock_spanner do
  it "merges Strings" do
    results_hashes = [
      { metadata: { row_type: { fields: [{ name: "f1", type: { code: :STRING } }] } },
        values: [{ string_value: "abc" }],
        chunked_value: true },
      { values: [{ string_value: "def" }],
        chunked_value: true },
      { values: [{ string_value: "ghi" }] }
    ]
    results_enum = results_hashes.map { |hash| Google::Cloud::Spanner::V1::PartialResultSet.new hash }.to_enum
    results = Google::Cloud::Spanner::Results.from_enum results_enum, spanner.service

    _(results).must_be_kind_of Google::Cloud::Spanner::Results

    _(results.fields).wont_be :nil?
    _(results.fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(results.fields.keys.count).must_equal 1
    _(results.fields[:f1]).must_equal :STRING

    rows = results.rows.to_a # grab them all from the enumerator
    _(rows.count).must_equal 1
    row = rows.first
    _(row).must_be_kind_of Google::Cloud::Spanner::Data
    _(row[:f1]).must_equal "abcdefghi"
  end

  it "merges String Arrays" do
    results_hashes = [
      { metadata: { row_type: { fields: [{ name: "f1", type: { code: :ARRAY, array_element_type: { code: :STRING }}}] }},
        values: [{ list_value: { values: [{ string_value: "abc" }, { string_value: "d" }] }}],
        chunked_value: true },
      { values: [{ list_value: { values: [{ string_value: "ef" }, { string_value: "gh" }] }}],
        chunked_value: true },
      { values: [{ list_value: { values: [{ string_value: "i" }, { string_value: "jkl" }] }}]}
    ]
    results_enum = results_hashes.map { |hash| Google::Cloud::Spanner::V1::PartialResultSet.new hash }.to_enum
    results = Google::Cloud::Spanner::Results.from_enum results_enum, spanner.service

    _(results).must_be_kind_of Google::Cloud::Spanner::Results

    _(results.fields).wont_be :nil?
    _(results.fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(results.fields.keys.count).must_equal 1
    _(results.fields[:f1]).must_equal [:STRING]

    rows = results.rows.to_a # grab them all from the enumerator
    _(rows.count).must_equal 1
    row = rows.first
    _(row).must_be_kind_of Google::Cloud::Spanner::Data
    _(row[:f1]).must_equal ["abc", "def", "ghi", "jkl"]
  end

  it "merges String Arrays With Nulls" do
    results_hashes = [
      { metadata: { row_type: { fields: [{ name: "f1", type: { code: :ARRAY, array_element_type: { code: :STRING }}}] }},
        values: [{ list_value: { values: [{ string_value: "abc" }, { string_value: "def" }] }}],
        chunked_value: true },
      { values: [{ list_value: { values: [{ null_value: "NULL_VALUE" }, { string_value: "ghi" }] }}],
        chunked_value: true },
      { values: [{ list_value: { values: [{ null_value: "NULL_VALUE" }, { string_value: "jkl" }] }}]}
    ]
    results_enum = results_hashes.map { |hash| Google::Cloud::Spanner::V1::PartialResultSet.new hash }.to_enum
    results = Google::Cloud::Spanner::Results.from_enum results_enum, spanner.service

    _(results).must_be_kind_of Google::Cloud::Spanner::Results

    _(results.fields).wont_be :nil?
    _(results.fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(results.fields.keys.count).must_equal 1
    _(results.fields[:f1]).must_equal [:STRING]

    rows = results.rows.to_a # grab them all from the enumerator
    _(rows.count).must_equal 1
    row = rows.first
    _(row).must_be_kind_of Google::Cloud::Spanner::Data
    _(row[:f1]).must_equal ["abc", "def", nil, "ghi", nil, "jkl"]
  end

  it "merges String Arrays With Empty Strings" do
    results_hashes = [
      { metadata: { row_type: { fields: [{ name: "f1", type: { code: :ARRAY, array_element_type: { code: :STRING }}}] }},
        values: [{ list_value: { values: [{ string_value: "abc" }, { string_value: "def" }] }}],
        chunked_value: true },
      { values: [{ list_value: { values: [{ string_value: "" }, { string_value: "ghi" }] }}],
        chunked_value: true },
      { values: [{ list_value: { values: [{ string_value: "" }, { string_value: "jkl" }] }}]}
    ]
    results_enum = results_hashes.map { |hash| Google::Cloud::Spanner::V1::PartialResultSet.new hash }.to_enum
    results = Google::Cloud::Spanner::Results.from_enum results_enum, spanner.service

    _(results).must_be_kind_of Google::Cloud::Spanner::Results

    _(results.fields).wont_be :nil?
    _(results.fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(results.fields.keys.count).must_equal 1
    _(results.fields[:f1]).must_equal [:STRING]

    rows = results.rows.to_a # grab them all from the enumerator
    _(rows.count).must_equal 1
    row = rows.first
    _(row).must_be_kind_of Google::Cloud::Spanner::Data
    _(row[:f1]).must_equal ["abc", "def", "ghi", "jkl"]
  end

  it "merges String Arrays With One Large String" do
    results_hashes = [
      { metadata: { row_type: { fields: [{ name: "f1", type: { code: :ARRAY, array_element_type: { code: :STRING }}}] }},
        values: [{ list_value: { values: [{ string_value: "abc" }] }}],
        chunked_value: true },
      { values: [{ list_value: { values: [{ string_value: "def" }] }}],
        chunked_value: true },
      { values: [{ list_value: { values: [{ string_value: "ghi" }] }}]}
    ]
    results_enum = results_hashes.map { |hash| Google::Cloud::Spanner::V1::PartialResultSet.new hash }.to_enum
    results = Google::Cloud::Spanner::Results.from_enum results_enum, spanner.service

    _(results).must_be_kind_of Google::Cloud::Spanner::Results

    _(results.fields).wont_be :nil?
    _(results.fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(results.fields.keys.count).must_equal 1
    _(results.fields[:f1]).must_equal [:STRING]

    rows = results.rows.to_a # grab them all from the enumerator
    _(rows.count).must_equal 1
    row = rows.first
    _(row).must_be_kind_of Google::Cloud::Spanner::Data
    _(row[:f1]).must_equal ["abcdefghi"]
  end

  it "merges INT64 Arrays" do
    results_hashes = [
      { metadata: { row_type: { fields: [{ name: "f1", type: { code: :ARRAY, array_element_type: { code: :INT64 }}}] }},
        values: [{ list_value: { values: [{ string_value: "1" }, { string_value: "2" }] }}],
        chunked_value: true },
      { values: [{ list_value: { values: [{ string_value: "3" }, { string_value: "4" }] }}],
        chunked_value: true },
      { values: [{ list_value: { values: [{ null_value: "NULL_VALUE" }, { string_value: "5" }] }}]}
    ]
    results_enum = results_hashes.map { |hash| Google::Cloud::Spanner::V1::PartialResultSet.new hash }.to_enum
    results = Google::Cloud::Spanner::Results.from_enum results_enum, spanner.service

    _(results).must_be_kind_of Google::Cloud::Spanner::Results

    _(results.fields).wont_be :nil?
    _(results.fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(results.fields.keys.count).must_equal 1
    _(results.fields[:f1]).must_equal [:INT64]

    rows = results.rows.to_a # grab them all from the enumerator
    _(rows.count).must_equal 1
    row = rows.first
    _(row).must_be_kind_of Google::Cloud::Spanner::Data
    _(row[:f1]).must_equal [1, 23, 4, nil, 5]
  end

  it "merges FLOAT64 Arrays" do
    results_hashes = [
      { metadata: { row_type: { fields: [{ name: "f1", type: { code: :ARRAY, array_element_type: { code: :FLOAT64 }}}] }},
        values: [{ list_value: { values: [{ number_value: 1.0 }, { number_value: 2.0 }] }}],
        chunked_value: true },
      { values: [{ list_value: { values: [{ string_value: "Infinity" }, { string_value: "-Infinity" }, { string_value: "NaN" }] }}],
        chunked_value: true },
      { values: [{ list_value: { values: [{ null_value: "NULL_VALUE" }, { number_value: 3.0 }] }}]}
    ]
    results_enum = results_hashes.map { |hash| Google::Cloud::Spanner::V1::PartialResultSet.new hash }.to_enum
    results = Google::Cloud::Spanner::Results.from_enum results_enum, spanner.service

    _(results).must_be_kind_of Google::Cloud::Spanner::Results

    _(results.fields).wont_be :nil?
    _(results.fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(results.fields.keys.count).must_equal 1
    _(results.fields[:f1]).must_equal [:FLOAT64]

    rows = results.rows.to_a # grab them all from the enumerator
    _(rows.count).must_equal 1
    row = rows.first
    _(row).must_be_kind_of Google::Cloud::Spanner::Data
    _(row[:f1]).must_equal [1.0, 2.0, Float::INFINITY, -Float::INFINITY, Float::NAN, nil, 3.0]
  end

  it "merges Multiple Row Chunks/Non Chunks Interleaved" do
    results_hashes = [
      { metadata: { row_type: { fields: [{ name: "f1", type: { code: :STRING } }] } },
        values: [{ string_value: "a" }],
        chunked_value: true },
      { values: [{ string_value: "b" }, { string_value: "c" }] },
      { values: [{ string_value: "d" }, { string_value: "e" }],
        chunked_value: true },
      { values: [{ string_value: "f" }] }
    ]
    results_enum = results_hashes.map { |hash| Google::Cloud::Spanner::V1::PartialResultSet.new hash }.to_enum
    results = Google::Cloud::Spanner::Results.from_enum results_enum, spanner.service

    _(results).must_be_kind_of Google::Cloud::Spanner::Results

    _(results.fields).wont_be :nil?
    _(results.fields).must_be_kind_of Google::Cloud::Spanner::Fields
    _(results.fields.keys.count).must_equal 1
    _(results.fields[:f1]).must_equal :STRING

    rows = results.rows.to_a # grab them all from the enumerator
    _(rows.count).must_equal 4
    _(rows.map(&:to_h)).must_equal [{ f1: "ab" }, { f1: "c" }, { f1: "d" }, { f1: "ef" }]
  end
end
