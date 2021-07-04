# Copyright 2021 Google LLC
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

describe "Spanner Client", :params, :json, :spanner do
  let(:db) { spanner_client }
  let(:json_params) { { "venue" => "abc", "rating" => 10 } }
  let(:json_array_params) do
    3.times.map do |i|
      { "venue" => "abc-#{i}", "rating" => 10 + i }
    end
  end

  it "queries and returns a string parameter" do
    skip if emulator_enabled?

    results = db.execute_query "SELECT @value AS value", params: { value: json_params }, types: { value: :JSON }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal :JSON
    _(results.rows.first[:value]).must_equal json_params
  end

  it "queries and returns a NULL string parameter" do
    skip if emulator_enabled?

    results = db.execute_query "SELECT @value AS value", params: { value: nil }, types: { value: :JSON }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal :JSON
    _(results.rows.first[:value]).must_be :nil?
  end

  it "queries and returns an array of json parameters" do
    skip if emulator_enabled?

    results = db.execute_query "SELECT @value AS value", params: { value: json_array_params }, types: { value: [:JSON] }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal [:JSON]
    _(results.rows.first[:value]).must_equal json_array_params
  end

  it "queries and returns an array of json parameters with a nil value" do
    skip if emulator_enabled?

    params = [nil].concat(json_array_params)
    results = db.execute_query "SELECT @value AS value", params: { value: params }, types: { value: [:JSON] }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal [:JSON]
    _(results.rows.first[:value]).must_equal params
  end

  it "queries and returns an empty array of json parameters" do
    skip if emulator_enabled?

    results = db.execute_query "SELECT @value AS value", params: { value: [] }, types: { value: [:JSON] }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal [:JSON]
    _(results.rows.first[:value]).must_equal []
  end

  it "queries and returns a NULL array of json parameters" do
    skip if emulator_enabled?

    results = db.execute_query "SELECT @value AS value", params: { value: nil }, types: { value: [:JSON] }

    _(results).must_be_kind_of Google::Cloud::Spanner::Results
    _(results.fields[:value]).must_equal [:JSON]
    _(results.rows.first[:value]).must_be :nil?
  end
end
