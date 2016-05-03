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

describe Gcloud::Datastore::Transaction do
  let(:project)     { "my-todo-project" }
  let(:credentials) { OpenStruct.new }
  let(:connection)  do
    mock = Minitest::Mock.new
    mock.expect :begin_transaction, begin_transaction_response
    mock
  end
  let(:transaction) { Gcloud::Datastore::Transaction.new connection }
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
  let(:commit_response) do
    Gcloud::Datastore::Proto::CommitResponse.new.tap do |response|
      response.mutation_result = Gcloud::Datastore::Proto::MutationResult.new
    end
  end
  let(:begin_transaction_response) do
    Gcloud::Datastore::Proto::BeginTransactionResponse.new.tap do |response|
      response.transaction = "giterdone"
    end
  end
  let(:query_cursor) { "c3VwZXJhd2Vzb21lIQ==" }

  after do
    transaction.connection.verify
  end

  it "save does not persist entities" do
    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    transaction.save entity
    transaction.instance_variable_get("@commit").send(:shared_upserts).must_include entity
  end

  it "delete does not persist entities" do
    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    transaction.delete entity
    transaction.instance_variable_get("@commit").send(:shared_deletes).must_include entity.key
  end

  it "delete does not persist keys" do
    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    transaction.delete entity.key
    transaction.instance_variable_get("@commit").send(:shared_deletes).must_include entity.key
  end

  it "commit will save and delete entities" do
    transaction.connection.expect :commit,
                                  commit_response,
                                  [Gcloud::Datastore::Proto::Mutation, String]

    entity_to_be_saved = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "to-be-saved"
      e["name"] = "Gonna be saved"
    end
    entity_to_be_deleted = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "to-be-saved"
      e["name"] = "Gonna be deleted"
    end

    entity_to_be_saved.wont_be :persisted?
    transaction.commit do |c|
      c.save entity_to_be_saved
      c.delete entity_to_be_deleted
    end
    entity_to_be_saved.must_be :persisted?
  end

  it "find can take a key" do
    transaction.connection.expect :lookup,
                                  lookup_response,
                                  [Gcloud::Datastore::Proto::Key,
                                   transaction: transaction.id]

    key = Gcloud::Datastore::Key.new "ds-test", "thingie"
    entity = transaction.find key
    entity.must_be_kind_of Gcloud::Datastore::Entity
  end

  it "find_all takes several keys" do
    transaction.connection.expect :lookup,
                                  lookup_response,
                                  [Gcloud::Datastore::Proto::Key,
                                   Gcloud::Datastore::Proto::Key,
                                   transaction: transaction.id]

    key = Gcloud::Datastore::Key.new "ds-test", "thingie"
    entities = transaction.find_all key, key
    entities.count.must_equal 2
    entities.deferred.count.must_equal 0
    entities.missing.count.must_equal 0
    entities.each do |entity|
      entity.must_be_kind_of Gcloud::Datastore::Entity
    end
  end

  it "run will fulfill a query" do
    transaction.connection.expect :run_query,
                                  run_query_response,
                                  [Gcloud::Datastore::Proto::Query, nil,
                                   transaction: transaction.id]

    query = Gcloud::Datastore::Query.new.kind("User")
    entities = transaction.run query
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

  it "commit persists entities" do
    transaction.connection.expect :commit,
                                  commit_response,
                                  [Gcloud::Datastore::Proto::Mutation,
                                   String]

    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    transaction.save entity
    entity.wont_be :persisted?
    transaction.commit
    entity.must_be :persisted?
  end

  it "rollback does not persist entities" do
    transaction.connection.expect :rollback,
                                  true,
                                  [String]

    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    transaction.save entity
    transaction.rollback
  end

  describe "error handling" do
    it "start will raise if transaction is already open" do
      transaction.id.wont_be :nil?
      error = assert_raises Gcloud::Datastore::TransactionError do
        transaction.start
      end
      error.wont_be :nil?
      error.message.must_equal "Transaction already opened."
    end

    it "commit will raise if transaction is not open" do
      transaction.id.wont_be :nil?
      transaction.reset!
      transaction.id.must_be :nil?
      error = assert_raises Gcloud::Datastore::TransactionError do
        transaction.commit
      end
      error.wont_be :nil?
      error.message.must_equal "Cannot commit when not in a transaction."
    end

    it "transaction will raise if transaction is not open" do
      transaction.id.wont_be :nil?
      transaction.reset!
      transaction.id.must_be :nil?
      error = assert_raises Gcloud::Datastore::TransactionError do
        transaction.rollback
      end
      error.wont_be :nil?
      error.message.must_equal "Cannot rollback when not in a transaction."
    end
  end
end
