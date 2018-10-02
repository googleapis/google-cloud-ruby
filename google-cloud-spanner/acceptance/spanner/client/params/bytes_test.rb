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

describe "Spanner Client", :params, :bytes, :spanner do
  let(:db) { spanner_client }

  it "queries and returns a bytes parameter" do
    results = db.execute_query "SELECT @value AS value", params: { value: StringIO.new("hello world!") }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal :BYTES
    returned_value = results.rows.first[:value]
    returned_value.must_be_kind_of StringIO
    returned_value.read.must_equal "hello world!"
  end

  it "queries and returns a NULL bytes parameter" do
    results = db.execute_query "SELECT @value AS value", params: { value: nil }, types: { value: :BYTES }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal :BYTES
    results.rows.first[:value].must_be :nil?
  end

  it "queries and returns an array of bytes parameters" do
    results = db.execute_query "SELECT @value AS value", params: { value: [StringIO.new("foo"), StringIO.new("bar"), StringIO.new("baz")] }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal [:BYTES]
    bytes_array = results.rows.first[:value]
    bytes_array.size.must_equal 3
    bytes_array[0].read.must_equal "foo"
    bytes_array[1].read.must_equal "bar"
    bytes_array[2].read.must_equal "baz"
  end

  it "queries and returns an array of bytes parameters with a nil value" do
    results = db.execute_query "SELECT @value AS value", params: { value: [nil, StringIO.new("foo"), StringIO.new("bar"), StringIO.new("baz")] }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal [:BYTES]
    bytes_array = results.rows.first[:value]
    bytes_array.size.must_equal 4
    bytes_array[0].must_be :nil?
    bytes_array[1].read.must_equal "foo"
    bytes_array[2].read.must_equal "bar"
    bytes_array[3].read.must_equal "baz"
  end

  it "queries and returns an empty array of bytes parameters" do
    results = db.execute_query "SELECT @value AS value", params: { value: [] }, types: { value: [:BYTES] }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal [:BYTES]
    results.rows.first[:value].must_equal []
  end

  it "queries and returns a NULL array of bytes parameters" do
    results = db.execute_query "SELECT @value AS value", params: { value: nil }, types: { value: [:BYTES] }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal [:BYTES]
    results.rows.first[:value].must_be :nil?
  end
end
