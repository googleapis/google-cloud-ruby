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

describe "Spanner Client", :params, :timestamp, :spanner do
  let(:db) { spanner_client }
  let(:timestamp_value) { Time.now }

  it "queries and returns a timestamp parameter" do
    results = db.execute_query "SELECT @value AS value", params: { value: timestamp_value }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal :TIMESTAMP
    _(results.rows.first[:value]).must_equal timestamp_value
  end

  it "queries and returns a NULL timestamp parameter" do
    results = db.execute_query "SELECT @value AS value", params: { value: nil }, types: { value: :TIMESTAMP }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal :TIMESTAMP
    _(results.rows.first[:value]).must_be :nil?
  end

  it "queries and returns an array of timestamp parameters" do
    results = db.execute_query "SELECT @value AS value",
                               params: { value: [(timestamp_value - 180.0), timestamp_value,
                                                 (timestamp_value - 240.0)] }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal [:TIMESTAMP]
    _(results.rows.first[:value]).must_equal [(timestamp_value - 180.0), timestamp_value, (timestamp_value - 240.0)]
  end

  it "queries and returns an array of timestamp parameters with a nil value" do
    results = db.execute_query "SELECT @value AS value",
                               params: { value: [nil, (timestamp_value - 180.0), timestamp_value,
                                                 (timestamp_value - 240.0)] }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal [:TIMESTAMP]
    _(results.rows.first[:value]).must_equal [nil, (timestamp_value - 180.0), timestamp_value,
                                              (timestamp_value - 240.0)]
  end

  it "queries and returns an empty array of timestamp parameters" do
    results = db.execute_query "SELECT @value AS value", params: { value: [] }, types: { value: [:TIMESTAMP] }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal [:TIMESTAMP]
    _(results.rows.first[:value]).must_equal []
  end

  it "queries and returns an NULL array of timestamp parameters" do
    results = db.execute_query "SELECT @value AS value", params: { value: nil }, types: { value: [:TIMESTAMP] }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal [:TIMESTAMP]
    _(results.rows.first[:value]).must_be :nil?
  end

  describe "using DateTime" do
    let(:datetime_value) { timestamp_value.to_datetime }

    it "queries and returns a timestamp parameter" do
      results = db.execute_query "SELECT @value AS value", params: { value: datetime_value }

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields[:value]).must_equal :TIMESTAMP
      _(results.rows.first[:value]).must_equal timestamp_value
    end

    it "queries and returns an array of timestamp parameters" do
      results = db.execute_query "SELECT @value AS value",
                                 params: { value: [(datetime_value - 1), datetime_value, (datetime_value + 1)] }

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields[:value]).must_equal [:TIMESTAMP]
      _(results.rows.first[:value]).must_equal [(timestamp_value - 86_400), timestamp_value, (timestamp_value + 86_400)]
    end

    it "queries and returns an array of timestamp parameters with a nil value" do
      results = db.execute_query "SELECT @value AS value",
                                 params: { value: [nil, (datetime_value - 1), datetime_value, (datetime_value + 1)] }

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields[:value]).must_equal [:TIMESTAMP]
      _(results.rows.first[:value]).must_equal [nil, (timestamp_value - 86_400), timestamp_value,
                                                (timestamp_value + 86_400)]
    end
  end
end
