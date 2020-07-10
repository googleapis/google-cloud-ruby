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
  let(:batch_client) { $spanner.batch_client $spanner_instance_id, $spanner_database_id }
  let(:table_name) { "stuffs" }
  let(:table_index) { "IsStuffsIdPrime" }
  let(:batch_snapshot) { batch_client.batch_snapshot }

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
    batch_snapshot.close
    db.delete table_name # remove all data
  end

  it "reads all by default" do
    _(batch_snapshot.timestamp).must_be_kind_of Time
    serialized_snapshot = batch_snapshot.dump

    columns = [:id]
    rows = []
    partitions = batch_snapshot.partition_read table_name, columns
    partitions.each do |partition|
      _(partition.read.partition_token).wont_be_nil
      _(partition.read.columns).must_equal columns.map(&:to_s)
      _(partition.read.table).must_equal "stuffs"

      partition = batch_client.load_partition partition.dump

      _(partition.read.partition_token).wont_be_nil
      _(partition.read.columns).must_equal columns.map(&:to_s)
      _(partition.read.table).must_equal "stuffs"

      new_batch_snapshot = batch_client.load_batch_snapshot serialized_snapshot
      _(new_batch_snapshot.timestamp).must_be_kind_of Time
      results = new_batch_snapshot.execute_partition partition
      _(results).must_be_kind_of Google::Cloud::Spanner::Results

      unless results.fields.to_a.empty? # With so little data, just one partition should get the entire result set
        rows.concat(results.rows.map(&:to_h))
      end
    end

    _(rows).must_equal [{ id: 1 }, { id: 2 }, { id: 3 }, { id: 4 }, { id: 5 }, { id: 6 }, { id: 7 }, { id: 8 }, { id: 9 }, { id: 10 }, { id: 11 }, { id: 12 }]
    batch_snapshot.close
  end

  it "queries all by default" do
    batch_snapshot = batch_client.batch_snapshot
    serialized_snapshot = batch_snapshot.dump

    sql = "SELECT s.id, s.bool FROM stuffs AS s WHERE s.id = 2 AND s.bool = false"
    rows = []
    partitions = batch_snapshot.partition_query sql
    partitions.each do |partition|
      _(partition.execute.partition_token).wont_be_nil
      _(partition.execute.sql).must_equal sql

      partition = batch_client.load_partition partition.dump

      _(partition.execute.partition_token).wont_be_nil
      _(partition.execute.sql).must_equal sql

      new_batch_snapshot = batch_client.load_batch_snapshot serialized_snapshot
      results = new_batch_snapshot.execute_partition partition
      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      unless results.fields.to_a.empty? # With so little data, just one partition should get the entire result set
        rows.concat(results.rows.map(&:to_h))
      end
    end

    _(rows).must_equal [{:id=>2, :bool=>false}]
    batch_snapshot.close
  end

  it "queries all by default with query options" do
    batch_snapshot = batch_client.batch_snapshot
    serialized_snapshot = batch_snapshot.dump

    sql = "SELECT s.id, s.bool FROM stuffs AS s WHERE s.id = 2 AND s.bool = false"
    query_options = { optimizer_version: "1" }
    rows = []
    partitions = batch_snapshot.partition_query sql, query_options: query_options
    partitions.each do |partition|
      _(partition.execute.partition_token).wont_be_nil
      _(partition.execute.sql).must_equal sql

      partition = batch_client.load_partition partition.dump

      _(partition.execute.partition_token).wont_be_nil
      _(partition.execute.sql).must_equal sql

      new_batch_snapshot = batch_client.load_batch_snapshot serialized_snapshot
      results = new_batch_snapshot.execute_partition partition
      _(results).must_be_kind_of Google::Cloud::Spanner::Results
      unless results.fields.to_a.empty? # With so little data, just one partition should get the entire result set
        rows.concat(results.rows.map(&:to_h))
      end
    end

    _(rows).must_equal [{:id=>2, :bool=>false}]
    batch_snapshot.close
  end
end
