# Copyright 2018 Google LLC
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
require "concurrent"

describe "Spanner Client", :batch_update, :spanner do
  let :db do
    { gsql: spanner_client, pg: spanner_pg_client }
  end

  let :insert_dml do
    { gsql: "INSERT INTO accounts (account_id, username, active, reputation) \
             VALUES (@account_id, @username, @active, @reputation)",
      pg: "INSERT INTO accounts (account_id, username, active, reputation) VALUES ($1, $2, $3, $4)" }
  end

  let :update_dml do
    { gsql: "UPDATE accounts SET username = @username, active = @active WHERE account_id = @account_id",
      pg: "UPDATE accounts SET username = $2, active = $3 WHERE account_id = $1" }
  end

  let :select_dql do
    { gsql: "SELECT username FROM accounts WHERE account_id = @account_id",
      pg: "SELECT username FROM accounts WHERE account_id = $1" }
  end

  let(:update_dml_syntax_error) { "UPDDDD accounts" }
  let :delete_dml do
    { gsql: "DELETE FROM accounts WHERE account_id = @account_id",
      pg: "DELETE FROM accounts WHERE account_id = $1" }
  end
  let :insert_params do
    { gsql: { account_id: 4, username: "inserted", active: true, reputation: 88.8 },
      pg: { p1: 4, p2: "inserted", p3: true, p4: 88.8 } }
  end
  let :update_params do
    { gsql: { account_id: 4, username: "updated", active: false },
      pg:  { p1: 4, p2: "updated", p3: false } }
  end
  let :delete_params do
    { gsql: { account_id: 4 }, pg: { p1: 4 } }
  end

  before do
    db[:gsql].commit do |c|
      c.delete "accounts"
      c.insert "accounts", default_account_rows
    end
    unless emulator_enabled?
      db[:pg].commit do |c|
        c.delete "accounts"
        c.insert "accounts", default_pg_account_rows
      end
    end
  end

  after do
    db[:gsql].delete "accounts"
    db[:pg].delete "accounts" unless emulator_enabled?
  end

  dialects = [:gsql]
  dialects.push :pg unless emulator_enabled?

  dialects.each do |dialect|
    it "executes multiple DML statements in a batch for #{dialect}" do
      prior_results = db[dialect].execute_sql "SELECT * FROM accounts"
      _(prior_results.rows.count).must_equal 3

      timestamp = db[dialect].transaction do |tx|
        _(tx.transaction_id).wont_be :nil?

        row_counts = tx.batch_update do |b|
          b.batch_update insert_dml[dialect], params: insert_params[dialect]
          b.batch_update update_dml[dialect], params: update_params[dialect]
          b.batch_update delete_dml[dialect], params: delete_params[dialect]
        end

        _(row_counts).must_be_kind_of Array
        _(row_counts.count).must_equal 3
        _(row_counts[0]).must_equal 1
        _(row_counts[1]).must_equal 1
        _(row_counts[2]).must_equal 1

        update_results = tx.execute_sql \
          select_dql[dialect],
          params: delete_params[dialect]
        _(update_results.rows.count).must_equal 0
      end
      _(timestamp).must_be_kind_of Time
    end

    it "raises InvalidArgumentError when no DML statements are executed in a batch for #{dialect}" do
      prior_results = db[dialect].execute_sql "SELECT * FROM accounts"
      _(prior_results.rows.count).must_equal 3

      timestamp = db[dialect].transaction do |tx|
        _(tx.transaction_id).wont_be :nil?

        err = expect do
          tx.batch_update { |b| } # rubocop:disable Lint/EmptyBlock
        end.must_raise Google::Cloud::InvalidArgumentError
        _(err.message).must_match(
          /3:(No statements in batch DML request|Request must contain at least one DML statement)/
        )
      end
      _(timestamp).must_be_kind_of Time
    end

    it "executes multiple DML statements in a batch with syntax error for #{dialect}" do
      prior_results = db[dialect].execute_sql "SELECT * FROM accounts"
      _(prior_results.rows.count).must_equal 3

      timestamp = db[dialect].transaction do |tx|
        _(tx.transaction_id).wont_be :nil?
        begin
          tx.batch_update do |b|
            b.batch_update insert_dml[dialect], params: insert_params[dialect]
            b.batch_update update_dml_syntax_error, params: update_params[dialect]
            b.batch_update delete_dml[dialect], params: delete_params[dialect]
          end
        rescue Google::Cloud::Spanner::BatchUpdateError => e
          _(e.cause).must_be_kind_of Google::Cloud::InvalidArgumentError
          _(e.cause.message).must_equal "Statement 1: 'UPDDDD accounts' is not valid DML."

          row_counts = e.row_counts
          _(row_counts).must_be_kind_of Array
          _(row_counts.count).must_equal 1
          _(row_counts[0]).must_equal 1
        end
        update_results = tx.execute_sql \
          select_dql[dialect],
          params: delete_params[dialect]
        _(update_results.rows.count).must_equal 1 # DELETE statement did not execute.
      end
      _(timestamp).must_be_kind_of Time
    end

    it "runs execute_update and batch_update in the same transaction for #{dialect}" do
      prior_results = db[dialect].execute_sql "SELECT * FROM accounts"
      _(prior_results.rows.count).must_equal 3

      timestamp = db[dialect].transaction do |tx|
        _(tx.transaction_id).wont_be :nil?

        row_counts = tx.batch_update do |b|
          b.batch_update insert_dml[dialect], params: insert_params[dialect]
          b.batch_update update_dml[dialect], params: update_params[dialect]
        end

        _(row_counts).must_be_kind_of Array
        _(row_counts.count).must_equal 2
        _(row_counts[0]).must_equal 1
        _(row_counts[1]).must_equal 1

        delete_row_count = tx.execute_update delete_dml[dialect], params: delete_params[dialect]

        _(delete_row_count).must_equal 1

        update_results = tx.execute_sql \
          select_dql[dialect],
          params: delete_params[dialect]
        _(update_results.rows.count).must_equal 0
      end
      _(timestamp).must_be_kind_of Time
    end

    describe "request options for #{dialect}" do
      it "execute batch update with priority options for #{dialect}" do
        db[dialect].transaction do |tx|
          row_counts = tx.batch_update request_options: { priority: :PRIORITY_HIGH } do |b|
            b.batch_update insert_dml[dialect], params: insert_params[dialect]
            b.batch_update update_dml[dialect], params: update_params[dialect]
          end

          _(row_counts).must_be_kind_of Array
          _(row_counts.count).must_equal 2
        end
      end
    end
  end
end
