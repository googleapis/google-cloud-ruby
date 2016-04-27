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
  let(:dataset)     { Gcloud::Datastore::Dataset.new project, credentials }
  let(:service) do
    s = dataset.service
    s.mocked_datastore = Minitest::Mock.new
    s.mocked_datastore.expect :begin_transaction, begin_tx_res, [Google::Datastore::V1beta3::BeginTransactionRequest]
    s
  end
  let(:transaction) { Gcloud::Datastore::Transaction.new service }
  let(:commit_res) do
    Google::Datastore::V1beta3::CommitResponse.new(
      mutation_results: [Google::Datastore::V1beta3::MutationResult.new]
    )
  end
  let(:begin_tx_res) do
    Google::Datastore::V1beta3::BeginTransactionResponse.new(transaction: tx_id)
  end
  let(:tx_id) { "giterdone".encode("ASCII-8BIT") }

  after do
    transaction.service.mocked_datastore.verify
  end

  it "save does not persist entities" do
    begin_tx_res.wont_equal "poop"
    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    transaction.save entity
    transaction.send(:shared_upserts).must_include entity
  end

  it "delete does not persist entities" do
    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    transaction.delete entity
    transaction.send(:shared_deletes).must_include entity.key
  end

  it "delete does not persist keys" do
    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    transaction.delete entity.key
    transaction.send(:shared_deletes).must_include entity.key
  end

  it "commit persists entities" do
    commit_res = Google::Datastore::V1beta3::CommitResponse.new(
      mutation_results: [
        Google::Datastore::V1beta3::MutationResult.new(
          key: Gcloud::Datastore::Key.new("ds-test", "thingie").to_grpc
        )]
    )
    commit_req = Google::Datastore::V1beta3::CommitRequest.new(
      project_id: project,
      mode: :NON_TRANSACTIONAL,
      mutations: [Google::Datastore::V1beta3::Mutation.new(
        upsert: Gcloud::Datastore::Entity.new.tap do |e|
          e.key = Gcloud::Datastore::Key.new "ds-test"
          e["name"] = "thingamajig"
        end.to_grpc)]
    )
    transaction.service.mocked_datastore.expect :commit, commit_res,
                                  [Google::Datastore::V1beta3::CommitRequest]

    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test"
      e["name"] = "thingamajig"
    end
    entity.key.must_be :incomplete?
    transaction.save entity
    transaction.commit
    entity.key.must_be :complete?
  end

  it "rollback does not persist entities" do
    rollback_res = Google::Datastore::V1beta3::RollbackResponse.new
    rollback_req = Google::Datastore::V1beta3::RollbackRequest.new(
      project_id: project,
      transaction: tx_id
    )
    transaction.service.mocked_datastore.expect :rollback, rollback_res, [rollback_req]

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
