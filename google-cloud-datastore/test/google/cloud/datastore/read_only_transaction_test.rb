# Copyright 2014 Google LLC
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

require "helper"

describe Google::Cloud::Datastore::ReadOnlyTransaction, :mock_datastore do
  let(:service) do
    s = dataset.service
    s.mocked_service = Minitest::Mock.new
    s.mocked_service.expect :begin_transaction, begin_tx_res, [project_id: project, transaction_options: Google::Cloud::Datastore::V1::TransactionOptions.new(read_write: nil, read_only: Google::Cloud::Datastore::V1::TransactionOptions::ReadOnly.new)]
    s
  end
  let(:transaction) { Google::Cloud::Datastore::ReadOnlyTransaction.new service }
  let(:commit_res) do
    Google::Cloud::Datastore::V1::CommitResponse.new(
      mutation_results: [Google::Cloud::Datastore::V1::MutationResult.new]
    )
  end
  let(:lookup_res) do
    Google::Cloud::Datastore::V1::LookupResponse.new(
      found: 2.times.map do
        Google::Cloud::Datastore::V1::EntityResult.new(
          entity: Google::Cloud::Datastore::V1::Entity.new(
            key: Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc,
            properties: { "name" => Google::Cloud::Datastore::Convert.to_value("thingamajig") }
          )
        )
      end
    )
  end
  let(:run_query_res) do
    run_query_res_entities = 2.times.map do |i|
      Google::Cloud::Datastore::V1::EntityResult.new(
        entity: Google::Cloud::Datastore::Entity.new.tap do |e|
          e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
          e["name"] = "thingamajig"
        end.to_grpc,
        cursor: "result-cursor-#{i}".force_encoding("ASCII-8BIT")
      )
    end
    Google::Cloud::Datastore::V1::RunQueryResponse.new(
      batch: Google::Cloud::Datastore::V1::QueryResultBatch.new(
        entity_results: run_query_res_entities,
        end_cursor: Google::Cloud::Datastore::Convert.decode_bytes(query_cursor)
      )
    )
  end
  let(:query_cursor) { Google::Cloud::Datastore::Cursor.new "c3VwZXJhd2Vzb21lIQ==" }
  let(:begin_tx_res) do
    Google::Cloud::Datastore::V1::BeginTransactionResponse.new(transaction: tx_id)
  end
  let(:tx_id) { "giterdone".encode("ASCII-8BIT") }
  let(:read_options) { Google::Cloud::Datastore::V1::ReadOptions.new(transaction: tx_id) }
  let(:gql_query_grpc) { Google::Cloud::Datastore::V1::GqlQuery.new(query_string: "SELECT * FROM Task") }

  after do
    transaction.service.mocked_service.verify
  end

  it "find can take a key" do
    keys = [Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc]
    read_options = Google::Cloud::Datastore::V1::ReadOptions.new(transaction: tx_id)
    transaction.service.mocked_service.expect :lookup, lookup_res, [project_id: project, keys: keys, read_options: read_options]

    key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
    entity = transaction.find key
    _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
  end

  it "find_all takes several keys" do
    keys = [Google::Cloud::Datastore::Key.new("ds-test", "thingie1").to_grpc,
             Google::Cloud::Datastore::Key.new("ds-test", "thingie2").to_grpc]
    read_options = Google::Cloud::Datastore::V1::ReadOptions.new(transaction: tx_id)
    transaction.service.mocked_service.expect :lookup, lookup_res, [project_id: project, keys: keys, read_options: read_options]

    key1 = Google::Cloud::Datastore::Key.new "ds-test", "thingie1"
    key2 = Google::Cloud::Datastore::Key.new "ds-test", "thingie2"
    entities = transaction.find_all key1, key2
    _(entities.count).must_equal 2
    _(entities.deferred.count).must_equal 0
    _(entities.missing.count).must_equal 0
    entities.each do |entity|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    end
  end

  it "run will fulfill a query" do
    query_grpc = Google::Cloud::Datastore::Query.new.kind("User").to_grpc
    transaction.service.mocked_service.expect :run_query, run_query_res, [project_id: project, partition_id: nil, read_options: read_options, query: query_grpc, gql_query: nil]

    query = Google::Cloud::Datastore::Query.new.kind("User")
    entities = transaction.run query
    _(entities.count).must_equal 2
    entities.each do |entity|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    end
    _(entities.cursor).must_equal query_cursor
    _(entities.end_cursor).must_equal query_cursor
    _(entities.more_results).must_equal :MORE_RESULTS_TYPE_UNSPECIFIED
    refute entities.not_finished?
    refute entities.more_after_limit?
    refute entities.more_after_cursor?
    refute entities.no_more?
  end

  it "run will fulfill a gql query" do
    transaction.service.mocked_service.expect :run_query, run_query_res, [project_id: project, partition_id: nil, read_options: read_options, query: nil, gql_query: gql_query_grpc]

    gql = transaction.gql "SELECT * FROM Task"
    entities = transaction.run gql
    _(entities.count).must_equal 2
    entities.each do |entity|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    end
    _(entities.cursor_for(entities.first)).must_equal Google::Cloud::Datastore::Cursor.from_grpc("result-cursor-0")
    _(entities.cursor_for(entities.last)).must_equal Google::Cloud::Datastore::Cursor.from_grpc("result-cursor-1")
    entities.each_with_cursor do |entity, cursor|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
      _(cursor).must_be_kind_of Google::Cloud::Datastore::Cursor
    end
    # can use the enumerator without passing a block...
    entities.each_with_cursor.map do |entity, cursor|
      [entity.key, cursor]
    end.each do |result, cursor|
      _(result).must_be_kind_of Google::Cloud::Datastore::Key
      _(cursor).must_be_kind_of Google::Cloud::Datastore::Cursor
    end
    _(entities.cursor).must_equal query_cursor
    _(entities.end_cursor).must_equal query_cursor
    _(entities.more_results).must_equal :MORE_RESULTS_TYPE_UNSPECIFIED
    refute entities.not_finished?
    refute entities.more_after_limit?
    refute entities.more_after_cursor?
    refute entities.no_more?
  end

  describe "error handling" do
    it "start will raise if transaction is already open" do
      _(transaction.id).wont_be :nil?
      error = assert_raises Google::Cloud::Datastore::TransactionError do
        transaction.start
      end
      _(error).wont_be :nil?
      _(error.message).must_equal "Transaction already opened."
    end

    it "commit will raise if transaction is not open" do
      _(transaction.id).wont_be :nil?
      transaction.reset!
      _(transaction.id).must_be :nil?
      error = assert_raises Google::Cloud::Datastore::TransactionError do
        transaction.commit
      end
      _(error).wont_be :nil?
      _(error.message).must_equal "Cannot commit when not in a transaction."
    end

    it "transaction will raise if transaction is not open" do
      _(transaction.id).wont_be :nil?
      transaction.reset!
      _(transaction.id).must_be :nil?
      error = assert_raises Google::Cloud::Datastore::TransactionError do
        transaction.rollback
      end
      _(error).wont_be :nil?
      _(error.message).must_equal "Cannot rollback when not in a transaction."
    end
  end

  it "query returns a Query instance" do
    query = transaction.query "Task"
    _(query).must_be_kind_of Google::Cloud::Datastore::Query

    grpc = query.to_grpc
    _(grpc.kind.map(&:name)).must_include "Task"
    _(grpc.kind.map(&:name)).wont_include "User"

    # Add a second kind to the query
    query.kind "User"

    grpc = query.to_grpc
    _(grpc.kind.map(&:name)).must_include "Task"
    _(grpc.kind.map(&:name)).must_include "User"
  end

  it "key returns a Key instance" do
    key = transaction.key "ThisThing", 1234
    _(key).must_be_kind_of Google::Cloud::Datastore::Key
    _(key.kind).must_equal "ThisThing"
    _(key.id).must_equal 1234
    _(key.name).must_be :nil?

    key = transaction.key "ThisThing", "charlie"
    _(key).must_be_kind_of Google::Cloud::Datastore::Key
    _(key.kind).must_equal "ThisThing"
    _(key.id).must_be :nil?
    _(key.name).must_equal "charlie"
  end

  it "key sets a parent and grandparent in the constructor" do
    path = [["OtherThing", "root"], ["ThatThing", 6789], ["ThisThing", 1234]]
    key = transaction.key path, project: "custom-ds", namespace: "custom-ns"
    _(key.kind).must_equal "ThisThing"
    _(key.id).must_equal 1234
    _(key.name).must_be :nil?
    _(key.path).must_equal [["OtherThing", "root"], ["ThatThing", 6789], ["ThisThing", 1234]]
    _(key.project).must_equal "custom-ds"
    _(key.namespace).must_equal "custom-ns"

    _(key.parent).wont_be :nil?
    _(key.parent.kind).must_equal "ThatThing"
    _(key.parent.id).must_equal 6789
    _(key.parent.name).must_be :nil?
    _(key.parent.path).must_equal [["OtherThing", "root"], ["ThatThing", 6789]]
    _(key.parent.project).must_equal "custom-ds"
    _(key.parent.namespace).must_equal "custom-ns"

    _(key.parent.parent).wont_be :nil?
    _(key.parent.parent.kind).must_equal "OtherThing"
    _(key.parent.parent.id).must_be :nil?
    _(key.parent.parent.name).must_equal "root"
    _(key.parent.parent.path).must_equal [["OtherThing", "root"]]
    _(key.parent.parent.project).must_equal "custom-ds"
    _(key.parent.parent.namespace).must_equal "custom-ns"
  end
end
