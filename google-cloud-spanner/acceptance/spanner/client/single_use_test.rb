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

describe "Spanner Client", :single_use, :spanner do
  let :db do
    { gsql: spanner_client, pg: spanner_pg_client }
  end
  let :columns do
    [:account_id, :username, :friends, :active, :reputation, :avatar]
  end
  let :fields_hash do
    { account_id: :INT64, username: :STRING, friends: [:INT64], active: :BOOL, reputation: :FLOAT64, avatar: :BYTES }
  end

  before do
    setup_timestamp_gsql = db[:gsql].commit do |c|
      c.delete "accounts"
      c.insert "accounts", default_account_rows
    end
    unless emulator_enabled?
      setup_timestamp_pg = db[:pg].commit do |c|
        c.delete "accounts"
        c.insert "accounts", default_pg_account_rows
      end
    end
    @setup_timestamp = { gsql: setup_timestamp_gsql, pg: setup_timestamp_pg }
    @default_rows = { gsql: default_account_rows, pg: default_pg_account_rows }
  end

  after do
    db[:gsql].delete "accounts"
    db[:pg].delete "accounts" unless emulator_enabled?
  end

  dialects = [:gsql]
  dialects.push :pg unless emulator_enabled?

  dialects.each do |dialect|
    it "runs a query with strong option for #{dialect}" do
      results = db[dialect].execute_sql "SELECT * FROM accounts ORDER BY account_id ASC", single_use: { strong: true }

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal fields_hash
      results.rows.zip(@default_rows[dialect]).each do |expected, actual|
        assert_accounts_equal expected, actual
      end

      _(results.timestamp).wont_be :nil?
      _(results.timestamp).must_be_close_to @setup_timestamp[dialect], 3 # within 3 seconds?
    end

    it "runs a read with strong option for #{dialect}" do
      results = db[dialect].read "accounts", columns, single_use: { strong: true }

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal fields_hash
      results.rows.zip(@default_rows[dialect]).each do |expected, actual|
        assert_accounts_equal expected, actual
      end

      _(results.timestamp).wont_be :nil?
      _(results.timestamp).must_be_close_to @setup_timestamp[dialect], 3 # within 3 seconds?
    end

    it "runs a query with timestamp option for #{dialect}" do
      results = db[dialect].execute_sql "SELECT * FROM accounts ORDER BY account_id ASC",
                                        single_use: { timestamp: @setup_timestamp[dialect] }

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal fields_hash
      results.rows.zip(@default_rows[dialect]).each do |expected, actual|
        assert_accounts_equal expected, actual
      end

      _(results.timestamp).wont_be :nil?
      _(results.timestamp).must_be_close_to @setup_timestamp[dialect], 1
    end

    it "runs a read with timestamp option for #{dialect}" do
      results = db[dialect].read "accounts", columns, single_use: { timestamp: @setup_timestamp[dialect] }

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal fields_hash
      results.rows.zip(@default_rows[dialect]).each do |expected, actual|
        assert_accounts_equal expected, actual
      end

      _(results.timestamp).wont_be :nil?
      _(results.timestamp).must_be_close_to @setup_timestamp[dialect], 1
    end

    it "runs a query with staleness option for #{dialect}" do
      results = db[dialect].execute_sql "SELECT * FROM accounts ORDER BY account_id ASC",
                                        single_use: { staleness: 0.0001 }

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal fields_hash
      results.rows.zip(@default_rows[dialect]).each do |expected, actual|
        assert_accounts_equal expected, actual
      end

      _(results.timestamp).wont_be :nil?
      _(results.timestamp).must_be_close_to @setup_timestamp[dialect], 3 # within 3 seconds?
    end

    it "runs a read with staleness option for #{dialect}" do
      results = db[dialect].read "accounts", columns, single_use: { staleness: 0.0001 }

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal fields_hash
      results.rows.zip(@default_rows[dialect]).each do |expected, actual|
        assert_accounts_equal expected, actual
      end

      _(results.timestamp).wont_be :nil?
      _(results.timestamp).must_be_close_to @setup_timestamp[dialect], 3 # within 3 seconds?
    end

    it "runs a query with bounded_timestamp option for #{dialect}" do
      results = db[dialect].execute_sql "SELECT * FROM accounts ORDER BY account_id ASC",
                                        single_use: { bounded_timestamp: @setup_timestamp[dialect] }

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal fields_hash
      results.rows.zip(@default_rows[dialect]).each do |expected, actual|
        assert_accounts_equal expected, actual
      end

      _(results.timestamp).wont_be :nil?
      _(results.timestamp).must_be_close_to @setup_timestamp[dialect], 3 # within 3 seconds?
    end

    it "runs a read with bounded_timestamp option for #{dialect}" do
      results = db[dialect].read "accounts", columns,
                                 single_use: { bounded_timestamp: @setup_timestamp[dialect] }

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal fields_hash
      results.rows.zip(@default_rows[dialect]).each do |expected, actual|
        assert_accounts_equal expected, actual
      end

      _(results.timestamp).wont_be :nil?
      _(results.timestamp).must_be_close_to @setup_timestamp[dialect], 3 # within 3 seconds?
    end

    it "runs a query with bounded_staleness option for #{dialect}" do
      results = db[dialect].execute_sql "SELECT * FROM accounts ORDER BY account_id ASC",
                                        single_use: { bounded_staleness: 0.0001 }

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal fields_hash
      results.rows.zip(@default_rows[dialect]).each do |expected, actual|
        assert_accounts_equal expected, actual
      end

      _(results.timestamp).wont_be :nil?
      _(results.timestamp).must_be_close_to @setup_timestamp[dialect], 3 # within 3 seconds?
    end

    it "runs a read with bounded_staleness option for #{dialect}" do
      results = db[dialect].read "accounts", columns, single_use: { bounded_staleness: 0.0001 }

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal fields_hash
      results.rows.zip(@default_rows[dialect]).each do |expected, actual|
        assert_accounts_equal expected, actual
      end

      _(results.timestamp).wont_be :nil?
      _(results.timestamp).must_be_close_to @setup_timestamp[dialect], 3 # within 3 seconds?
    end
  end

  def assert_accounts_equal expected, actual
    if actual[:account_id].nil?
      _(expected[:account_id]).must_be :nil?
    else
      _(expected[:account_id]).must_equal actual[:account_id]
    end

    if actual[:username].nil?
      _(expected[:username]).must_be :nil?
    else
      _(expected[:username]).must_equal actual[:username]
    end

    if actual[:reputation].nil?
      _(expected[:reputation]).must_be :nil?
    else
      _(expected[:reputation]).must_equal actual[:reputation]
    end

    if actual[:active].nil?
      _(expected[:active]).must_be :nil?
    else
      _(expected[:active]).must_equal actual[:active]
    end

    if expected[:avatar] && actual[:avatar]
      _(expected[:avatar].read).must_equal actual[:avatar].read
    end

    if actual[:friends].nil?
      _(expected[:friends]).must_be :nil?
    else
      _(expected[:friends]).must_equal actual[:friends]
    end
  end
end
