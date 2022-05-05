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

describe "Spanner Client", :snapshot, :spanner do
  let :db do
    { gsql: spanner_client, pg: spanner_pg_client }
  end
  let :columns do
    [:account_id, :username, :friends, :active, :reputation, :avatar]
  end
  let :fields_hash do
    { account_id: :INT64, username: :STRING,  friends: [:INT64], active: :BOOL, reputation: :FLOAT64, avatar: :BYTES }
  end
  let :select_dql do
    { gsql: "SELECT account_id, username FROM accounts WHERE account_id = @id",
      pg: "SELECT account_id, username FROM accounts WHERE account_id = $1" }
  end

  let :select_params do
    { gsql: { id: 1 }, pg: { p1: 1 } }
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
    it "runs a query for #{dialect}" do
      results = nil
      db[dialect].snapshot do |snp|
        _(snp.transaction_id).wont_be :nil?
        _(snp.timestamp).wont_be :nil?

        results = snp.execute_sql "SELECT * FROM accounts ORDER BY account_id ASC"
      end

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal fields_hash
      results.rows.zip(@default_rows[dialect]).each do |expected, actual|
        assert_accounts_equal expected, actual
      end
    end

    it "runs a query with query options for #{dialect}" do
      query_options = { optimizer_version: "3", optimizer_statistics_package: "latest" }
      results = nil
      db[dialect].snapshot do |snp|
        _(snp.transaction_id).wont_be :nil?
        _(snp.timestamp).wont_be :nil?

        results = snp.execute_sql "SELECT * FROM accounts ORDER BY account_id ASC", query_options: query_options
      end

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal fields_hash
      results.rows.zip(@default_rows[dialect]).each do |expected, actual|
        assert_accounts_equal expected, actual
      end
    end

    it "runs a read for #{dialect}" do
      results = nil
      db[dialect].snapshot do |snp|
        _(snp.transaction_id).wont_be :nil?
        _(snp.timestamp).wont_be :nil?

        results = snp.read "accounts", columns
      end

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal fields_hash
      results.rows.zip(@default_rows[dialect]).each do |expected, actual|
        assert_accounts_equal expected, actual
      end
    end

    it "runs a query with strong option for #{dialect}" do
      results = nil
      db[dialect].snapshot strong: true do |snp|
        _(snp.transaction_id).wont_be :nil?
        _(snp.timestamp).wont_be :nil?

        results = snp.execute_sql "SELECT * FROM accounts ORDER BY account_id ASC"
      end

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal fields_hash
      results.rows.zip(@default_rows[dialect]).each do |expected, actual|
        assert_accounts_equal expected, actual
      end
    end

    it "runs a read with strong option for #{dialect}" do
      results = nil
      db[dialect].snapshot strong: true do |snp|
        _(snp.transaction_id).wont_be :nil?
        _(snp.timestamp).wont_be :nil?

        results = snp.read "accounts", columns
      end

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal fields_hash
      results.rows.zip(@default_rows[dialect]).each do |expected, actual|
        assert_accounts_equal expected, actual
      end
    end

    it "runs a query with timestamp option for #{dialect}" do
      results = nil
      db[dialect].snapshot timestamp: @setup_timestamp[dialect] do |snp|
        _(snp.transaction_id).wont_be :nil?
        _(snp.timestamp).wont_be :nil?

        results = snp.execute_sql "SELECT * FROM accounts ORDER BY account_id ASC"
      end

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal fields_hash
      results.rows.zip(@default_rows[dialect]).each do |expected, actual|
        assert_accounts_equal expected, actual
      end
    end

    it "runs a read with timestamp option for #{dialect}" do
      results = nil
      db[dialect].snapshot timestamp: @setup_timestamp[dialect] do |snp|
        _(snp.transaction_id).wont_be :nil?
        _(snp.timestamp).wont_be :nil?

        results = snp.read "accounts", columns
      end

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal fields_hash
      results.rows.zip(@default_rows[dialect]).each do |expected, actual|
        assert_accounts_equal expected, actual
      end
    end

    it "runs a query with staleness option for #{dialect}" do
      results = nil
      db[dialect].snapshot staleness: 0.0001 do |snp|
        _(snp.transaction_id).wont_be :nil?
        _(snp.timestamp).wont_be :nil?

        results = snp.execute_sql "SELECT * FROM accounts ORDER BY account_id ASC"
      end

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal fields_hash
      results.rows.zip(@default_rows[dialect]).each do |expected, actual|
        assert_accounts_equal expected, actual
      end
    end

    it "runs a read with staleness option for #{dialect}" do
      results = nil
      db[dialect].snapshot staleness: 0.0001 do |snp|
        _(snp.transaction_id).wont_be :nil?
        _(snp.timestamp).wont_be :nil?

        results = snp.read "accounts", columns
      end

      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      _(results.fields.to_h).must_equal fields_hash
      results.rows.zip(@default_rows[dialect]).each do |expected, actual|
        assert_accounts_equal expected, actual
      end
    end


    it "strong reads are consistent even when updates happen for #{dialect}" do
      first_row = @default_rows[dialect].first
      sample_row = { account_id: first_row[:account_id], username: first_row[:username] }
      modified_row = { account_id: first_row[:account_id], username: first_row[:username].reverse }

      db[dialect].snapshot strong: true do |snp|
        _(snp.transaction_id).wont_be :nil?
        _(snp.timestamp).wont_be :nil?

        results = snp.read "accounts", [:account_id, :username], keys: sample_row[:account_id]
        # verify we got the row we were expecting
        _(results.rows.first.to_h).must_equal sample_row

        # outside of the snapshot, update the row!
        db[dialect].update "accounts", modified_row

        results2 = snp.read "accounts", [:account_id, :username], keys: modified_row[:account_id]
        # verify we got the previous row, not the modified row
        _(results2.rows.first.to_h).must_equal sample_row
      end
    end

    it "strong queries are consistent even when updates happen for #{dialect}" do
      first_row = @default_rows[dialect].first
      sample_row = { account_id: first_row[:account_id], username: first_row[:username] }
      modified_row = { account_id: first_row[:account_id], username: first_row[:username].reverse }

      db[dialect].snapshot strong: true do |snp|
        _(snp.transaction_id).wont_be :nil?
        _(snp.timestamp).wont_be :nil?

        results = snp.execute_sql select_dql[dialect], params: select_params[dialect]
        # verify we got the row we were expecting
        _(results.rows.first.to_h).must_equal sample_row

        # outside of the snapshot, update the row!
        db[dialect].update "accounts", modified_row

        results2 = snp.execute_sql select_dql[dialect], params: select_params[dialect]
        # verify we got the previous row, not the modified row
        _(results2.rows.first.to_h).must_equal sample_row
      end
    end

    it "timestamp reads are consistent even when updates happen for #{dialect}" do
      first_row = @default_rows[dialect].first
      sample_row = { account_id: first_row[:account_id], username: first_row[:username] }
      modified_row = { account_id: first_row[:account_id], username: first_row[:username].reverse }

      db[dialect].snapshot timestamp: @setup_timestamp[dialect] do |snp|
        _(snp.transaction_id).wont_be :nil?
        _(snp.timestamp).wont_be :nil?

        results = snp.read "accounts", [:account_id, :username], keys: sample_row[:account_id]
        # verify we got the row we were expecting
        _(results.rows.first.to_h).must_equal sample_row

        # outside of the snapshot, update the row!
        db[dialect].update "accounts", modified_row

        results2 = snp.read "accounts", [:account_id, :username], keys: modified_row[:account_id]
        # verify we got the previous row, not the modified row
        _(results2.rows.first.to_h).must_equal sample_row
      end
    end

    it "timestamp queries are consistent even when updates happen for #{dialect}" do
      first_row = @default_rows[dialect].first
      sample_row = { account_id: first_row[:account_id], username: first_row[:username] }
      modified_row = { account_id: first_row[:account_id], username: first_row[:username].reverse }

      db[dialect].snapshot timestamp: @setup_timestamp[dialect] do |snp|
        _(snp.transaction_id).wont_be :nil?
        _(snp.timestamp).wont_be :nil?

        results = snp.execute_sql select_dql[dialect], params: select_params[dialect]
        # verify we got the row we were expecting
        _(results.rows.first.to_h).must_equal sample_row

        # outside of the snapshot, update the row!
        db[dialect].update "accounts", modified_row

        results2 = snp.execute_sql select_dql[dialect], params: select_params[dialect]
        # verify we got the previous row, not the modified row
        _(results2.rows.first.to_h).must_equal sample_row
      end
    end

    it "staleness reads are consistent even when updates happen for #{dialect}" do
      first_row = @default_rows[dialect].first
      sample_row = { account_id: first_row[:account_id], username: first_row[:username] }
      modified_row = { account_id: first_row[:account_id], username: first_row[:username].reverse }

      db[dialect].snapshot staleness: 0.0001 do |snp|
        _(snp.transaction_id).wont_be :nil?
        _(snp.timestamp).wont_be :nil?

        results = snp.read "accounts", [:account_id, :username], keys: sample_row[:account_id]
        # verify we got the row we were expecting
        _(results.rows.first.to_h).must_equal sample_row

        # outside of the snapshot, update the row!
        db[dialect].update "accounts", modified_row

        results2 = snp.read "accounts", [:account_id, :username], keys: modified_row[:account_id]
        # verify we got the previous row, not the modified row
        _(results2.rows.first.to_h).must_equal sample_row
      end
    end

    it "staleness queries are consistent even when updates happen for #{dialect}" do
      first_row = @default_rows[dialect].first
      sample_row = { account_id: first_row[:account_id], username: first_row[:username] }
      modified_row = { account_id: first_row[:account_id], username: first_row[:username].reverse }

      db[dialect].snapshot staleness: 0.0001 do |snp|
        _(snp.transaction_id).wont_be :nil?
        _(snp.timestamp).wont_be :nil?

        results = snp.execute_sql select_dql[dialect], params: select_params[dialect]
        # verify we got the row we were expecting
        _(results.rows.first.to_h).must_equal sample_row

        # outside of the snapshot, update the row!
        db[dialect].update "accounts", modified_row

        results2 = snp.execute_sql select_dql[dialect], params: select_params[dialect]
        # verify we got the previous row, not the modified row
        _(results2.rows.first.to_h).must_equal sample_row
      end
    end

    it "multiuse snapshot reads are consistent even when delete happen for #{dialect}" do
      keys = @default_rows[dialect].map { |row| row[:account_id] }

      db[dialect].snapshot do |snp|
        _(snp.transaction_id).wont_be :nil?
        _(snp.timestamp).wont_be :nil?

        results = snp.read "accounts", [:account_id, :username], keys: keys
        _(results).must_be_kind_of Google::Cloud::Spanner::Results

        rows = results.rows.to_a
        _(rows.count).must_equal @default_rows[dialect].count
        rows.zip(@default_rows[dialect]).each do |expected, actual|
          _(expected[:account_id]).must_equal actual[:account_id]
          _(expected[:username]).must_equal actual[:username]
        end

        # outside of the snapshot, delete rows
        db[dialect].delete "accounts", keys

        # read rows and from snaphot and verify rows got from the snapshot
        results2 = snp.read "accounts", [:account_id, :username], keys: keys
        _(results2).must_be_kind_of Google::Cloud::Spanner::Results
        rows2 = results2.rows.to_a

        _(rows2.count).must_equal @default_rows[dialect].count
        rows2.zip(@default_rows[dialect]).each do |expected, actual|
          _(expected[:account_id]).must_equal actual[:account_id]
          _(expected[:username]).must_equal actual[:username]
        end
      end

      # outside of snapshot check all rows are deleted
      rows3 = db[dialect].execute_sql("SELECT * FROM accounts").rows.to_a
      _(rows3.count).must_equal 0
    end

    it "multiuse snapshot reads with read timestamp are consistent even when delete happen for #{dialect}" do
      keys = @default_rows[dialect].map { |row| row[:account_id] }

      db[dialect].snapshot read_timestamp: @setup_timestamp[dialect] do |snp|
        _(snp.transaction_id).wont_be :nil?
        _(snp.timestamp).wont_be :nil?

        results = snp.read "accounts", [:account_id, :username], keys: keys
        _(results).must_be_kind_of Google::Cloud::Spanner::Results

        rows = results.rows.to_a
        _(rows.count).must_equal @default_rows[dialect].count
        rows.zip(@default_rows[dialect]).each do |expected, actual|
          _(expected[:account_id]).must_equal actual[:account_id]
          _(expected[:username]).must_equal actual[:username]
        end

        # outside of the snapshot, delete rows
        db[dialect].delete "accounts", keys

        # read rows and from snaphot and verify rows got from the snapshot
        results2 = snp.read "accounts", [:account_id, :username], keys: keys
        _(results2).must_be_kind_of Google::Cloud::Spanner::Results
        rows2 = results2.rows.to_a
        _(rows2.count).must_equal @default_rows[dialect].count
        rows2.zip(@default_rows[dialect]).each do |expected, actual|
          _(expected[:account_id]).must_equal actual[:account_id]
          _(expected[:username]).must_equal actual[:username]
        end
      end

      # outside of snapshot check all rows are deleted
      rows3 = db[dialect].execute_sql("SELECT * FROM accounts").rows.to_a
      _(rows3.count).must_equal 0
    end

    it "multiuse snapshot reads with exact staleness are consistent even when delete happen for #{dialect}" do
      keys = @default_rows[dialect].map { |row| row[:account_id] }

      sleep 1
      delta = 0.001

      db[dialect].snapshot exact_staleness: delta do |snp|
        _(snp.transaction_id).wont_be :nil?
        _(snp.timestamp).wont_be :nil?

        results = snp.read "accounts", [:account_id, :username], keys: keys
        _(results).must_be_kind_of Google::Cloud::Spanner::Results

        rows = results.rows.to_a
        _(rows.count).must_equal @default_rows[dialect].count
        rows.zip(@default_rows[dialect]).each do |expected, actual|
          _(expected[:account_id]).must_equal actual[:account_id]
          _(expected[:username]).must_equal actual[:username]
        end

        # outside of the snapshot, delete rows
        db[dialect].delete "accounts", keys

        # read rows and from snaphot and verify rows got from the snapshot
        results2 = snp.read "accounts", [:account_id, :username], keys: keys
        _(results2).must_be_kind_of Google::Cloud::Spanner::Results
        rows2 = results2.rows.to_a
        _(rows2.count).must_equal @default_rows[dialect].count
        rows2.zip(@default_rows[dialect]).each do |expected, actual|
          _(expected[:account_id]).must_equal actual[:account_id]
          _(expected[:username]).must_equal actual[:username]
        end
      end

      # outside of snapshot check all rows are deleted
      rows3 = db[dialect].execute_sql("SELECT * FROM accounts").rows.to_a
      _(rows3.count).must_equal 0
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
