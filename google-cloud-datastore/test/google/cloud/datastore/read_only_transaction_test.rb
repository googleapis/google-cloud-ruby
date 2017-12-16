# Copyright 2014 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Datastore::ReadOnlyTransaction, :mock_datastore do
  let(:service) do
    s = dataset.service
    s.mocked_service = Minitest::Mock.new
    s.mocked_service.expect :begin_transaction, begin_tx_res, [project, transaction_options: Google::Datastore::V1::TransactionOptions.new(read_write: nil, read_only: Google::Datastore::V1::TransactionOptions::ReadOnly.new)]
    s
  end
  let(:transaction) { Google::Cloud::Datastore::ReadOnlyTransaction.new service }
  let(:commit_res) do
    Google::Datastore::V1::CommitResponse.new(
      mutation_results: [Google::Datastore::V1::MutationResult.new]
    )
  end
  let(:lookup_res) do
    Google::Datastore::V1::LookupResponse.new(
      found: 2.times.map do
        Google::Datastore::V1::EntityResult.new(
          entity: Google::Datastore::V1::Entity.new(
            key: Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc,
            properties: { "name" => Google::Cloud::Datastore::Convert.to_value("thingamajig") }
          )
        )
      end
    )
  end
  let(:run_query_res) do
    run_query_res_entities = 2.times.map do
      Google::Datastore::V1::EntityResult.new(
        entity: Google::Cloud::Datastore::Entity.new.tap do |e|
          e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
          e["name"] = "thingamajig"
        end.to_grpc
      )
    end
    Google::Datastore::V1::RunQueryResponse.new(
      batch: Google::Datastore::V1::QueryResultBatch.new(
        entity_results: run_query_res_entities,
        end_cursor: Google::Cloud::Datastore::Convert.decode_bytes(query_cursor)
      )
    )
  end
  let(:query_cursor) { Google::Cloud::Datastore::Cursor.new "c3VwZXJhd2Vzb21lIQ==" }
  let(:begin_tx_res) do
    Google::Datastore::V1::BeginTransactionResponse.new(transaction: tx_id)
  end
  let(:tx_id) { "giterdone".encode("ASCII-8BIT") }

  after do
    transaction.service.mocked_service.verify
  end

  it "find can take a key" do
    keys = [Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc]
    read_options = Google::Datastore::V1::ReadOptions.new(transaction: tx_id)
    transaction.service.mocked_service.expect :lookup, lookup_res, [project, keys, read_options: read_options, options: default_options]

    key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
    entity = transaction.find key
    entity.must_be_kind_of Google::Cloud::Datastore::Entity
  end

  it "find_all takes several keys" do
    keys = [Google::Cloud::Datastore::Key.new("ds-test", "thingie1").to_grpc,
             Google::Cloud::Datastore::Key.new("ds-test", "thingie2").to_grpc]
    read_options = Google::Datastore::V1::ReadOptions.new(transaction: tx_id)
    transaction.service.mocked_service.expect :lookup, lookup_res, [project, keys, read_options: read_options, options: default_options]

    key1 = Google::Cloud::Datastore::Key.new "ds-test", "thingie1"
    key2 = Google::Cloud::Datastore::Key.new "ds-test", "thingie2"
    entities = transaction.find_all key1, key2
    entities.count.must_equal 2
    entities.deferred.count.must_equal 0
    entities.missing.count.must_equal 0
    entities.each do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end
  end

  it "run will fulfill a query" do
    query_grpc = Google::Cloud::Datastore::Query.new.kind("User").to_grpc
    read_options = Google::Datastore::V1::ReadOptions.new(transaction: tx_id)
    transaction.service.mocked_service.expect :run_query, run_query_res, [project, nil, read_options: read_options, query: query_grpc, gql_query: nil, options: default_options]

    query = Google::Cloud::Datastore::Query.new.kind("User")
    entities = transaction.run query
    entities.count.must_equal 2
    entities.each do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end
    entities.cursor.must_equal query_cursor
    entities.end_cursor.must_equal query_cursor
    entities.more_results.must_equal :MORE_RESULTS_TYPE_UNSPECIFIED
    refute entities.not_finished?
    refute entities.more_after_limit?
    refute entities.more_after_cursor?
    refute entities.no_more?
  end

  describe "error handling" do
    it "start will raise if transaction is already open" do
      transaction.id.wont_be :nil?
      error = assert_raises Google::Cloud::Datastore::TransactionError do
        transaction.start
      end
      error.wont_be :nil?
      error.message.must_equal "Transaction already opened."
    end

    it "commit will raise if transaction is not open" do
      transaction.id.wont_be :nil?
      transaction.reset!
      transaction.id.must_be :nil?
      error = assert_raises Google::Cloud::Datastore::TransactionError do
        transaction.commit
      end
      error.wont_be :nil?
      error.message.must_equal "Cannot commit when not in a transaction."
    end

    it "transaction will raise if transaction is not open" do
      transaction.id.wont_be :nil?
      transaction.reset!
      transaction.id.must_be :nil?
      error = assert_raises Google::Cloud::Datastore::TransactionError do
        transaction.rollback
      end
      error.wont_be :nil?
      error.message.must_equal "Cannot rollback when not in a transaction."
    end
  end
end
