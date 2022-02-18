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

describe "Spanner Client", :params, :float64, :spanner do
  let(:db) { spanner_client }

  it "queries and returns a float64 parameter" do
    results = db.execute_query "SELECT @value AS value", params: { value: 12.0 }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal :FLOAT64
    _(results.rows.first[:value]).must_equal 12.0
  end

  it "queries and returns a float64 parameter (Infinity)" do
    results = db.execute_query "SELECT @value AS value", params: { value: Float::INFINITY }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal :FLOAT64
    _(results.rows.first[:value]).must_equal Float::INFINITY
  end

  it "queries and returns a float64 parameter (-Infinity)" do
    results = db.execute_query "SELECT @value AS value", params: { value: -Float::INFINITY }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal :FLOAT64
    _(results.rows.first[:value]).must_equal(-Float::INFINITY)
  end

  it "queries and returns a float64 parameter (-NaN)" do
    results = db.execute_query "SELECT @value AS value", params: { value: Float::NAN }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal :FLOAT64
    returned_value = results.rows.first[:value]
    _(returned_value).must_be_kind_of Float
    _(returned_value).must_be :nan?
  end

  it "queries and returns a NULL float64 parameter" do
    results = db.execute_query "SELECT @value AS value", params: { value: nil }, types: { value: :FLOAT64 }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal :FLOAT64
    _(results.rows.first[:value]).must_be :nil?
  end

  it "queries and returns an array of float64 parameters" do
    results = db.execute_query "SELECT @value AS value", params: { value: [1.0, 2.2, 3.5] }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal [:FLOAT64]
    _(results.rows.first[:value]).must_equal [1.0, 2.2, 3.5]
  end

  it "queries and returns an array of special float64 parameters" do
    results = db.execute_query "SELECT @value AS value",
                               params: { value: [Float::INFINITY, -Float::INFINITY, -Float::NAN] }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal [:FLOAT64]
    float_array = results.rows.first[:value]
    _(float_array.size).must_equal 3
    _(float_array[0]).must_equal Float::INFINITY
    _(float_array[1]).must_equal(-Float::INFINITY)
    _(float_array[2]).must_be :nan?
  end

  it "queries and returns an array of float64 parameters with a nil value" do
    results = db.execute_query "SELECT @value AS value", params: { value: [nil, 1.0, 2.2, 3.5] }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal [:FLOAT64]
    _(results.rows.first[:value]).must_equal [nil, 1.0, 2.2, 3.5]
  end

  it "queries and returns an empty array of float64 parameters" do
    results = db.execute_query "SELECT @value AS value", params: { value: [] }, types: { value: [:FLOAT64] }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal [:FLOAT64]
    _(results.rows.first[:value]).must_equal []
  end

  it "queries and returns a NULL array of float64 parameters" do
    results = db.execute_query "SELECT @value AS value", params: { value: nil }, types: { value: [:FLOAT64] }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal [:FLOAT64]
    _(results.rows.first[:value]).must_be :nil?
  end
end
