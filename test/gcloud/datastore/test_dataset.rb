# Copyright 2014 Google Inc. All rights reserved.
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
require "gcloud/datastore"

describe Gcloud::Datastore::Dataset do
  let(:project)     { "my-todo-project" }
  let(:credentials) { OpenStruct.new }
  let(:dataset)     { Gcloud::Datastore::Dataset.new project, credentials }
  let(:allocate_ids_response) do
    Gcloud::Datastore::Proto::AllocateIdsResponse.new.tap do |response|
      response.key = []
      response.key << Gcloud::Datastore::Key.new("ds-test", 1234).to_proto
    end
  end
  let(:commit_response) do
    Gcloud::Datastore::Proto::CommitResponse.new.tap do |response|
      response.mutation_result = Gcloud::Datastore::Proto::MutationResult.new
    end
  end
  let(:lookup_response) do
    Gcloud::Datastore::Proto::LookupResponse.new.tap do |response|
      response.found = 2.times.map do
        Gcloud::Datastore::Proto::EntityResult.new.tap do |er|
          er.entity = Gcloud::Datastore::Entity.new.tap do |e|
            e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
            e["name"] = "thingamajig"
          end.to_proto
        end
      end
    end
  end
  let(:run_query_response) do
    Gcloud::Datastore::Proto::RunQueryResponse.new.tap do |response|
      response.batch = Gcloud::Datastore::Proto::QueryResultBatch.new.tap do |batch|
        batch.entity_result = 2.times.map do
          Gcloud::Datastore::Proto::EntityResult.new.tap do |er|
            er.entity = Gcloud::Datastore::Entity.new.tap do |e|
              e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
              e["name"] = "thingamajig"
            end.to_proto
          end
        end
        batch.end_cursor = Gcloud::Datastore::Proto.decode_cursor query_cursor
      end
    end
  end
  let(:begin_transaction_response) do
    Gcloud::Datastore::Proto::BeginTransactionResponse.new.tap do |response|
      response.transaction = "giterdone"
    end
  end
  let(:query_cursor) { "c3VwZXJhd2Vzb21lIQ==" }

  before do
    dataset.connection = Minitest::Mock.new
  end

  after do
    dataset.connection.verify
  end

  it "allocate_ids returns complete keys" do
    dataset.connection.expect :allocate_ids,
                              allocate_ids_response,
                              [Gcloud::Datastore::Proto::Key]

    incomplete_key = Gcloud::Datastore::Key.new "ds-test"
    incomplete_key.must_be :incomplete?
    returned_keys = dataset.allocate_ids incomplete_key
    returned_keys.count.must_equal 1
    returned_keys.first.must_be_kind_of Gcloud::Datastore::Key
    returned_keys.first.must_be :complete?
  end

  it "allocate_ids raises when not given an incomplete key" do
    complete_key = Gcloud::Datastore::Key.new "ds-test", 789
    complete_key.must_be :complete?
    assert_raises Gcloud::Datastore::Error do
      dataset.allocate_ids complete_key
    end
  end

  it "save will persist entities" do
    dataset.connection.expect :commit,
                              commit_response,
                              [Gcloud::Datastore::Proto::Mutation]

    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    dataset.save entity
  end

  it "find can take a kind and id" do
    dataset.connection.expect :lookup,
                              lookup_response,
                              [Gcloud::Datastore::Proto::Key]

    entity = dataset.find "ds-test", 123
    entity.must_be_kind_of Gcloud::Datastore::Entity
  end

  it "find can take a kind and name" do
    dataset.connection.expect :lookup,
                              lookup_response,
                              [Gcloud::Datastore::Proto::Key]

    entity = dataset.find "ds-test", "thingie"
    entity.must_be_kind_of Gcloud::Datastore::Entity
  end

  it "find can take a key" do
    dataset.connection.expect :lookup,
                              lookup_response,
                              [Gcloud::Datastore::Proto::Key]

    key = Gcloud::Datastore::Key.new "ds-test", "thingie"
    entity = dataset.find key
    entity.must_be_kind_of Gcloud::Datastore::Entity
  end

  it "find is aliased to get" do
    dataset.connection.expect :lookup,
                              lookup_response,
                              [Gcloud::Datastore::Proto::Key]

    entity = dataset.get "ds-test", 123
    entity.must_be_kind_of Gcloud::Datastore::Entity
  end

  it "find_all takes several keys" do
    dataset.connection.expect :lookup,
                              lookup_response,
                              [Gcloud::Datastore::Proto::Key,
                               Gcloud::Datastore::Proto::Key]

    key = Gcloud::Datastore::Key.new "ds-test", "thingie"
    entities = dataset.find_all key, key
    entities.count.must_equal 2
    entities.deferred.count.must_equal 0
    entities.missing.count.must_equal 0
    entities.each do |entity|
      entity.must_be_kind_of Gcloud::Datastore::Entity
    end
  end

  it "find_all is aliased to lookup" do
    dataset.connection.expect :lookup,
                              lookup_response,
                              [Gcloud::Datastore::Proto::Key,
                               Gcloud::Datastore::Proto::Key]

    key = Gcloud::Datastore::Key.new "ds-test", "thingie"
    entities = dataset.lookup key, key
    entities.count.must_equal 2
    entities.deferred.count.must_equal 0
    entities.missing.count.must_equal 0
    entities.each do |entity|
      entity.must_be_kind_of Gcloud::Datastore::Entity
    end
  end

  describe "find_all result object" do
    let(:lookup_response_deferred) do
      lookup_response.tap do |response|
        response.deferred = 2.times.map do
          Gcloud::Datastore::Key.new("ds-test", "thingie").to_proto
        end
      end
    end

    let(:lookup_response_missing) do
      lookup_response.tap do |response|
        response.missing = 2.times.map do
          Gcloud::Datastore::Proto::EntityResult.new.tap do |er|
            er.entity = Gcloud::Datastore::Entity.new.tap do |e|
              e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
              e["name"] = "thingamajig"
            end.to_proto
          end
        end
      end
    end

    it "contains deferred entities" do
      dataset.connection.expect :lookup,
                                lookup_response_deferred,
                                [Gcloud::Datastore::Proto::Key,
                                 Gcloud::Datastore::Proto::Key]

      key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      entities = dataset.find_all key, key
      entities.count.must_equal 2
      entities.deferred.count.must_equal 2
      entities.missing.count.must_equal 0
      entities.each do |entity|
        entity.must_be_kind_of Gcloud::Datastore::Entity
      end
      entities.deferred.each do |deferred_key|
        deferred_key.must_be_kind_of Gcloud::Datastore::Key
      end
    end

    it "contains missing entities" do
      dataset.connection.expect :lookup,
                                lookup_response_missing,
                                [Gcloud::Datastore::Proto::Key,
                                 Gcloud::Datastore::Proto::Key]

      key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      entities = dataset.find_all key, key
      entities.count.must_equal 2
      entities.deferred.count.must_equal 0
      entities.missing.count.must_equal 2
      entities.each do |entity|
        entity.must_be_kind_of Gcloud::Datastore::Entity
      end
      entities.missing.each do |entity|
        entity.must_be_kind_of Gcloud::Datastore::Entity
      end
    end
  end

  it "delete with entity will call commit" do
    dataset.connection.expect :commit,
                              commit_response,
                              [Gcloud::Datastore::Proto::Mutation]

    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    dataset.delete entity
  end

  it "delete with key will call commit" do
    dataset.connection.expect :commit,
                              commit_response,
                              [Gcloud::Datastore::Proto::Mutation]

    key = Gcloud::Datastore::Key.new "ds-test", "thingie"
    dataset.delete key
  end

  it "run will fulfill a query" do
    dataset.connection.expect :run_query,
                              run_query_response,
                              [Gcloud::Datastore::Proto::Query]

    query = Gcloud::Datastore::Query.new.kind("User")
    entities = dataset.run query
    entities.count.must_equal 2
    entities.each do |entity|
      entity.must_be_kind_of Gcloud::Datastore::Entity
    end
    entities.cursor.must_equal query_cursor
    entities.end_cursor.must_equal query_cursor
    entities.more_results.must_be :nil?
    refute entities.not_finished?
    refute entities.more_after_limit?
    refute entities.no_more?
  end

  it "run_query will fulfill a query" do
    dataset.connection.expect :run_query,
                              run_query_response,
                              [Gcloud::Datastore::Proto::Query]

    query = Gcloud::Datastore::Query.new.kind("User")
    entities = dataset.run_query query
    entities.count.must_equal 2
    entities.each do |entity|
      entity.must_be_kind_of Gcloud::Datastore::Entity
    end
    entities.cursor.must_equal query_cursor
    entities.more_results.must_be :nil?
    refute entities.not_finished?
    refute entities.more_after_limit?
    refute entities.no_more?
  end

  describe "query result object" do
    let(:run_query_response_not_finished) do
      run_query_response.tap do |response|
        response.batch.more_results =
          Gcloud::Datastore::Proto::QueryResultBatch::MoreResultsType::NOT_FINISHED
      end
    end
    let(:run_query_response_more_after_limit) do
      run_query_response.tap do |response|
        response.batch.more_results =
          Gcloud::Datastore::Proto::QueryResultBatch::MoreResultsType::MORE_RESULTS_AFTER_LIMIT
      end
    end
    let(:run_query_response_no_more) do
      run_query_response.tap do |response|
        response.batch.more_results =
          Gcloud::Datastore::Proto::QueryResultBatch::MoreResultsType::NO_MORE_RESULTS
      end
    end

    it "has more_results not_finished" do
      dataset.connection.expect :run_query,
                                run_query_response_not_finished,
                                [Gcloud::Datastore::Proto::Query]

      query = Gcloud::Datastore::Query.new.kind("User")
      entities = dataset.run query
      entities.count.must_equal 2
      entities.each do |entity|
        entity.must_be_kind_of Gcloud::Datastore::Entity
      end
      entities.cursor.must_equal query_cursor
      entities.more_results.must_equal "NOT_FINISHED"
      assert entities.not_finished?
      refute entities.more_after_limit?
      refute entities.no_more?
    end

    it "has more_results more_after_limit" do
      dataset.connection.expect :run_query,
                                run_query_response_more_after_limit,
                                [Gcloud::Datastore::Proto::Query]

      query = Gcloud::Datastore::Query.new.kind("User")
      entities = dataset.run query
      entities.count.must_equal 2
      entities.each do |entity|
        entity.must_be_kind_of Gcloud::Datastore::Entity
      end
      entities.cursor.must_equal query_cursor
      entities.more_results.must_equal "MORE_RESULTS_AFTER_LIMIT"
      refute entities.not_finished?
      assert entities.more_after_limit?
      refute entities.no_more?
    end

    it "has more_results no_more" do
      dataset.connection.expect :run_query,
                                run_query_response_no_more,
                                [Gcloud::Datastore::Proto::Query]

      query = Gcloud::Datastore::Query.new.kind("User")
      entities = dataset.run query
      entities.count.must_equal 2
      entities.each do |entity|
        entity.must_be_kind_of Gcloud::Datastore::Entity
      end
      entities.cursor.must_equal query_cursor
      entities.more_results.must_equal "NO_MORE_RESULTS"
      refute entities.not_finished?
      refute entities.more_after_limit?
      assert entities.no_more?
    end
  end


  it "transaction will return a Transaction" do
    dataset.connection.expect :begin_transaction,
                              begin_transaction_response

    tx = dataset.transaction
    tx.must_be_kind_of Gcloud::Datastore::Transaction
    tx.id.must_equal "giterdone"
  end

  it "transaction will commit with a block" do
    dataset.connection.expect :begin_transaction,
                              begin_transaction_response
    dataset.connection.expect :commit,
                              commit_response,
                              [Gcloud::Datastore::Proto::Mutation,
                               String]

    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    dataset.transaction do |tx|
      tx.save entity
    end
  end

  it "transaction will wrap errors in TransactionError" do
    dataset.connection.expect :begin_transaction,
                              begin_transaction_response
    dataset.connection.expect :rollback, nil, [String]

    error = assert_raises Gcloud::Datastore::TransactionError do
      dataset.transaction do |tx|
        fail "This error should be wrapped by TransactionError."
      end
    end

    error.wont_be :nil?
    error.message.must_equal "Transaction failed to commit."
    error.inner.wont_be :nil?
    error.inner.message.must_equal "This error should be wrapped by TransactionError."
  end
end
