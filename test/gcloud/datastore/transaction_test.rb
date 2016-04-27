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

  after do
    transaction.connection.verify
  end

  it "save does not persist entities" do
    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    transaction.save entity
    transaction.send(:shared_mutation).upsert.must_include entity.to_proto
  end

  it "delete does not persist entities" do
    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    transaction.delete entity
    transaction.send(:shared_mutation).delete.must_include entity.key.to_proto
  end

  it "delete does not persist keys" do
    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    transaction.delete entity.key
    transaction.send(:shared_mutation).delete.must_include entity.key.to_proto
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
