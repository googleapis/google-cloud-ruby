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

describe "Spanner Client", :types, :date, :spanner do
  let :db do
    { gsql: spanner_client, pg: spanner_pg_client }
  end
  let :date_query do
    { gsql: "SELECT id, date FROM #{table_name} WHERE id = @value",
      pg: "SELECT id, date FROM #{table_name} WHERE id = $1" }
  end
  let :dates_query do
    { gsql: "SELECT id, dates FROM #{table_name} WHERE id = @value",
      pg: "SELECT id, dates FROM #{table_name} WHERE id = $1" }
  end
  let(:table_name) { "stuffs" }

  dialects = [:gsql]
  dialects.push :pg unless emulator_enabled?

  dialects.each do |dialect|
    it "writes and reads date #{dialect}" do
      id = SecureRandom.int64
      db[dialect].upsert table_name, { id: id, date: Date.parse("2017-01-01") }
      results = db[dialect].read table_name, [:id, :date], keys: id

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal({ id: :INT64, date: :DATE })
      _(results.rows.first.to_h).must_equal({ id: id, date: Date.parse("2017-01-01") })
    end

    it "writes and queries date #{dialect}" do
      id = SecureRandom.int64
      db[dialect].upsert table_name, { id: id, date: Date.parse("2017-01-01") }
      results = db[dialect].execute_query date_query[dialect], params: make_params(dialect, id)

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal({ id: :INT64, date: :DATE })
      _(results.rows.first.to_h).must_equal({ id: id, date: Date.parse("2017-01-01") })
    end

    it "writes and reads NULL date #{dialect}" do
      id = SecureRandom.int64
      db[dialect].upsert table_name, { id: id, date: nil }
      results = db[dialect].read table_name, [:id, :date], keys: id

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal({ id: :INT64, date: :DATE })
      _(results.rows.first.to_h).must_equal({ id: id, date: nil })
    end

    it "writes and queries NULL date #{dialect}" do
      id = SecureRandom.int64
      db[dialect].upsert table_name, { id: id, date: nil }
      results = db[dialect].execute_query date_query[dialect], params: make_params(dialect, id)

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal({ id: :INT64, date: :DATE })
      _(results.rows.first.to_h).must_equal({ id: id, date: nil })
    end

    it "writes and reads array of date #{dialect}" do
      id = SecureRandom.int64
      db[dialect].upsert table_name,
                         { id: id,
                           dates: [Date.parse("2016-12-30"), Date.parse("2016-12-31"), Date.parse("2017-01-01")] }
      results = db[dialect].read table_name, [:id, :dates], keys: id

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal({ id: :INT64, dates: [:DATE] })
      _(results.rows.first.to_h).must_equal({ id: id,
                                              dates: [Date.parse("2016-12-30"),
                                                      Date.parse("2016-12-31"),
                                                      Date.parse("2017-01-01")] })
    end

    it "writes and queries array of date #{dialect}" do
      id = SecureRandom.int64
      db[dialect].upsert table_name,
                         { id: id,
                           dates: [Date.parse("2016-12-30"), Date.parse("2016-12-31"), Date.parse("2017-01-01")] }
      results = db[dialect].execute_query dates_query[dialect], params: make_params(dialect, id)

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal({ id: :INT64, dates: [:DATE] })
      _(results.rows.first.to_h).must_equal({ id: id,
                                              dates: [Date.parse("2016-12-30"),
                                                      Date.parse("2016-12-31"),
                                                      Date.parse("2017-01-01")] })
    end

    it "writes and reads array of date with NULL #{dialect}" do
      id = SecureRandom.int64
      db[dialect].upsert table_name,
                         { id: id,
                           dates: [nil, Date.parse("2016-12-30"), Date.parse("2016-12-31"), Date.parse("2017-01-01")] }
      results = db[dialect].read table_name, [:id, :dates], keys: id

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal({ id: :INT64, dates: [:DATE] })
      _(results.rows.first.to_h).must_equal({ id: id,
                                              dates: [nil,
                                                      Date.parse("2016-12-30"),
                                                      Date.parse("2016-12-31"),
                                                      Date.parse("2017-01-01")] })
    end

    it "writes and queries array of date with NULL #{dialect}" do
      id = SecureRandom.int64
      db[dialect].upsert table_name,
                         { id: id,
                           dates: [nil, Date.parse("2016-12-30"), Date.parse("2016-12-31"), Date.parse("2017-01-01")] }
      results = db[dialect].execute_query dates_query[dialect], params: make_params(dialect, id)

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal({ id: :INT64, dates: [:DATE] })
      _(results.rows.first.to_h).must_equal({ id: id,
                                              dates: [nil,
                                                      Date.parse("2016-12-30"),
                                                      Date.parse("2016-12-31"),
                                                      Date.parse("2017-01-01")] })
    end

    it "writes and reads empty array of date #{dialect}" do
      id = SecureRandom.int64
      db[dialect].upsert table_name, { id: id, dates: [] }
      results = db[dialect].read table_name, [:id, :dates], keys: id

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal({ id: :INT64, dates: [:DATE] })
      _(results.rows.first.to_h).must_equal({ id: id, dates: [] })
    end

    it "writes and queries empty array of date #{dialect}" do
      id = SecureRandom.int64
      db[dialect].upsert table_name, { id: id, dates: [] }
      results = db[dialect].execute_query dates_query[dialect], params: make_params(dialect, id)

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal({ id: :INT64, dates: [:DATE] })
      _(results.rows.first.to_h).must_equal({ id: id, dates: [] })
    end

    it "writes and reads NULL array of date #{dialect}" do
      id = SecureRandom.int64
      db[dialect].upsert table_name, { id: id, dates: nil }
      results = db[dialect].read table_name, [:id, :dates], keys: id

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal({ id: :INT64, dates: [:DATE] })
      _(results.rows.first.to_h).must_equal({ id: id, dates: nil })
    end

    it "writes and queries NULL array of date #{dialect}" do
      id = SecureRandom.int64
      db[dialect].upsert table_name, { id: id, dates: nil }
      results = db[dialect].execute_query dates_query[dialect], params: make_params(dialect, id)

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal({ id: :INT64, dates: [:DATE] })
      _(results.rows.first.to_h).must_equal({ id: id, dates: nil })
    end
  end
end
