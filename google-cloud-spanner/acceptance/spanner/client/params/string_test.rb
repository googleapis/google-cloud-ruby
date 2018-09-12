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

describe "Spanner Client", :params, :string, :spanner do
  let(:db) { spanner_client }

  it "queries and returns a string parameter" do
    results = db.execute_query "SELECT @value AS value", params: { value: "hello" }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal :STRING
    results.rows.first[:value].must_equal "hello"
  end

  it "queries and returns a NULL string parameter" do
    results = db.execute_query "SELECT @value AS value", params: { value: nil }, types: { value: :STRING }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal :STRING
    results.rows.first[:value].must_be :nil?
  end

  it "queries and returns an array of string parameters" do
    results = db.execute_query "SELECT @value AS value", params: { value: ["foo", "bar", "baz"] }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal [:STRING]
    results.rows.first[:value].must_equal ["foo", "bar", "baz"]
  end

  it "queries and returns an array of string parameters with a nil value" do
    results = db.execute_query "SELECT @value AS value", params: { value: [nil, "foo", "bar", "baz"] }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal [:STRING]
    results.rows.first[:value].must_equal [nil, "foo", "bar", "baz"]
  end

  it "queries and returns an empty array of string parameters" do
    results = db.execute_query "SELECT @value AS value", params: { value: [] }, types: { value: [:STRING] }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal [:STRING]
    results.rows.first[:value].must_equal []
  end

  it "queries and returns a NULL array of string parameters" do
    results = db.execute_query "SELECT @value AS value", params: { value: nil }, types: { value: [:STRING] }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal [:STRING]
    results.rows.first[:value].must_be :nil?
  end
end
