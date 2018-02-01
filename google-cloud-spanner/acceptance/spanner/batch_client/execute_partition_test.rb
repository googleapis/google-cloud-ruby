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

describe "Spanner Batch Client", :execute_partition, :spanner do
  let(:db) { spanner_client }
  let(:batch_client) { $spanner.batch_client $spanner_instance_id, $spanner_prefix }
  let(:table_name) { "stuffs" }
  let(:table_index) { "IsStuffsIdPrime" }
  let(:transaction) { batch_client.create_batch_read_only_transaction }

  before do
    db.delete table_name # remove all data
    db.insert table_name, [
      { id: 1, bool: false },
      { id: 2, bool: false },
      { id: 3, bool: true },
      { id: 4, bool: false },
      { id: 5, bool: true },
      { id: 6, bool: false },
      { id: 7, bool: true },
      { id: 8, bool: false },
      { id: 9, bool: false },
      { id: 10, bool: false },
      { id: 11, bool: true },
      { id: 12, bool: false }
    ]
  end

  after do
    transaction.close
    db.delete table_name # remove all data
  end

  it "reads all by default" do
    transaction.timestamp.must_be_kind_of Time
    batch_transaction_id = transaction.batch_transaction_id

    columns = [:id]
    partitions = transaction.partition_read table_name, columns
    partitions.each do |partition|
      partition.partition_token.wont_be_nil
      partition.columns.must_equal columns
      partition.table.must_equal "stuffs"


      new_transaction = batch_client.batch_read_only_transaction batch_transaction_id
      new_transaction.timestamp.must_be_kind_of Time
      results = new_transaction.execute_partition partition
      results.must_be_kind_of Google::Cloud::Spanner::Results
      unless results.fields.to_a.empty? # With so little data, just one partition should get the entire result set
        results.rows.map(&:to_h).must_equal [{ id: 1 }, { id: 2 }, { id: 3 }, { id: 4 }, { id: 5 }, { id: 6 }, { id: 7 }, { id: 8 }, { id: 9 }, { id: 10 }, { id: 11 }, { id: 12 }]
      end
    end

  end

  it "queries all by default" do
    transaction = batch_client.create_batch_read_only_transaction
    batch_transaction_id = transaction.batch_transaction_id

    sql = "SELECT s.id, s.bool FROM stuffs AS s WHERE s.id = 2 AND s.bool = false"
    partitions = transaction.partition_query sql
    partitions.each do |partition|
      partition.partition_token.wont_be_nil

      new_transaction = batch_client.batch_read_only_transaction batch_transaction_id
      results = new_transaction.execute_partition partition
      results.must_be_kind_of Google::Cloud::Spanner::Results
      unless results.fields.to_a.empty? # With so little data, just one partition should get the entire result set
        results.rows.map(&:to_h).must_equal [{:id=>2, :bool=>false}]
      end
    end
    transaction.close
  end
end
