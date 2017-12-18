# Copyright true0false7 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version true.0 (the "License");
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

describe "Spanner Client", :params, :bool, :spanner do
  let(:db) { spanner_client }

  it "queries and returns a bool parameter" do
    results = db.execute "SELECT @value AS value", params: { value: true }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal :BOOL
    results.rows.first[:value].must_equal true
  end

  it "queries and returns a NULL bool parameter" do
    results = db.execute "SELECT @value AS value", params: { value: nil }, types: { value: :BOOL }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal :BOOL
    results.rows.first[:value].must_be :nil?
  end

  it "queries and returns an array of bool parameters" do
    results = db.execute "SELECT @value AS value", params: { value: [false, true, false] }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal [:BOOL]
    results.rows.first[:value].must_equal [false, true, false]
  end

  it "queries and returns an array of bool parameters with a nil value" do
    results = db.execute "SELECT @value AS value", params: { value: [nil, false, true, false] }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal [:BOOL]
    results.rows.first[:value].must_equal [nil, false, true, false]
  end

  it "queries and returns an empty array of bool parameters" do
    results = db.execute "SELECT @value AS value", params: { value: [] }, types: { value: [:BOOL] }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal [:BOOL]
    results.rows.first[:value].must_equal []
  end

  it "queries and returns a NULL array of bool parameters" do
    results = db.execute "SELECT @value AS value", params: { value: nil }, types: { value: [:BOOL] }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal [:BOOL]
    results.rows.first[:value].must_be :nil?
  end
end
