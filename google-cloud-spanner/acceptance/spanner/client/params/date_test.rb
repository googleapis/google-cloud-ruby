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

describe "Spanner Client", :params, :date, :spanner do
  let :db do
    { gsql: spanner_client, pg: spanner_pg_client }
  end
  let :date_query do
    { gsql: "SELECT @value AS value",
      pg: "SELECT $1 AS value" }
  end
  let(:date_value) { Date.today }

  dialects = [:gsql]
  dialects.push :pg unless emulator_enabled?

  dialects.each do |dialect|
    it "queries and returns a date parameter for #{dialect}" do
      results = db[dialect].execute_query date_query[dialect],
                                          params: make_params(dialect, date_value)

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields[:value]).must_equal :DATE
      _(results.rows.first[:value]).must_equal date_value
    end

    it "queries and returns a NULL date parameter for #{dialect}" do
      results = db[dialect].execute_query date_query[dialect],
                                          params: make_params(dialect, nil),
                                          types: make_params(dialect, :DATE)

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields[:value]).must_equal :DATE
      _(results.rows.first[:value]).must_be :nil?
    end

    it "queries and returns an array of date parameters for #{dialect}" do
      results = db[dialect].execute_query date_query[dialect],
                                          params: make_params(dialect, [(date_value - 1), date_value, (date_value + 1)])

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields[:value]).must_equal [:DATE]
      _(results.rows.first[:value]).must_equal [(date_value - 1), date_value, (date_value + 1)]
    end

    it "queries and returns an array of date parameters with a nil value for #{dialect}" do
      results = db[dialect].execute_query date_query[dialect],
                                          params: make_params(dialect,
                                                              [nil, (date_value - 1), date_value, (date_value + 1)])

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields[:value]).must_equal [:DATE]
      _(results.rows.first[:value]).must_equal [nil, (date_value - 1), date_value, (date_value + 1)]
    end

    it "queries and returns an empty array of date parameters for #{dialect}" do
      results = db[dialect].execute_query date_query[dialect],
                                          params: make_params(dialect, []),
                                          types: make_params(dialect, [:DATE])

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields[:value]).must_equal [:DATE]
      _(results.rows.first[:value]).must_equal []
    end

    it "queries and returns a NULL array of date parameters for #{dialect}" do
      results = db[dialect].execute_query date_query[dialect],
                                          params: make_params(dialect, nil),
                                          types: make_params(dialect, [:DATE])

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields[:value]).must_equal [:DATE]
      _(results.rows.first[:value]).must_be :nil?
    end
  end
end
