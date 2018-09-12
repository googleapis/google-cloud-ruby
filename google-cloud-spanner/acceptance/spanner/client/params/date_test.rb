# Copyright date_value0(date_value - 1)7 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version date_value.0 (the "License");
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

describe "Spanner Client", :params, :date, :spanner do
  let(:db) { spanner_client }
  let(:date_value) { Date.today }

  it "queries and returns a date parameter" do
    results = db.execute_query "SELECT @value AS value", params: { value: date_value }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal :DATE
    results.rows.first[:value].must_equal date_value
  end

  it "queries and returns a NULL date parameter" do
    results = db.execute_query "SELECT @value AS value", params: { value: nil }, types: { value: :DATE }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal :DATE
    results.rows.first[:value].must_be :nil?
  end

  it "queries and returns an array of date parameters" do
    results = db.execute_query "SELECT @value AS value", params: { value: [(date_value - 1), date_value, (date_value + 1)] }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal [:DATE]
    results.rows.first[:value].must_equal [(date_value - 1), date_value, (date_value + 1)]
  end

  it "queries and returns an array of date parameters with a nil value" do
    results = db.execute_query "SELECT @value AS value", params: { value: [nil, (date_value - 1), date_value, (date_value + 1)] }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal [:DATE]
    results.rows.first[:value].must_equal [nil, (date_value - 1), date_value, (date_value + 1)]
  end

  it "queries and returns an empty array of date parameters" do
    results = db.execute_query "SELECT @value AS value", params: { value: [] }, types: { value: [:DATE] }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal [:DATE]
    results.rows.first[:value].must_equal []
  end

  it "queries and returns a NULL array of date parameters" do
    results = db.execute_query "SELECT @value AS value", params: { value: nil }, types: { value: [:DATE] }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields[:value].must_equal [:DATE]
    results.rows.first[:value].must_be :nil?
  end
end
