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

describe Google::Cloud::Datastore::Transaction, :mock_datastore do
  let(:service) do
    s = dataset.service
    s.mocked_service = Minitest::Mock.new
    s.mocked_service.expect :begin_transaction, begin_tx_res, [project_id: project, transaction_options: nil]
    s
  end
  let(:transaction) { Google::Cloud::Datastore::Transaction.new service }
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
    run_query_res_entities = 2.times.map do
      Google::Cloud::Datastore::V1::EntityResult.new(
        entity: Google::Cloud::Datastore::Entity.new.tap do |e|
          e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
          e["name"] = "thingamajig"
        end.to_grpc
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

  after do
    transaction.service.mocked_service.verify
  end

  it "save does not persist entities" do
    _(begin_tx_res).wont_equal "poop"
    entity = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    transaction.save entity
    # Testing implementation like we are writing Java!
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_upserts")).must_include entity
  end

  it "save does not persist entities with upsert alias" do
    _(begin_tx_res).wont_equal "poop"
    entity = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    transaction.upsert entity
    # Testing implementation like we are writing Java!
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_upserts")).must_include entity
  end

  it "save does not persist multiple entities" do
    _(begin_tx_res).wont_equal "poop"
    entity1 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    transaction.save entity1, entity2
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_upserts")).must_include entity1
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_upserts")).must_include entity2
  end

  it "save does not persist multiple entities in an array" do
    _(begin_tx_res).wont_equal "poop"
    entity1 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    transaction.save [entity1, entity2]
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_upserts")).must_include entity1
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_upserts")).must_include entity2
  end

  it "insert does not persist entities" do
    _(begin_tx_res).wont_equal "poop"
    entity = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    transaction.insert entity
    # Testing implementation like we are writing Java!
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_inserts")).must_include entity
  end

  it "insert does not persist multiple entities" do
    _(begin_tx_res).wont_equal "poop"
    entity1 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    transaction.insert entity1, entity2
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_inserts")).must_include entity1
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_inserts")).must_include entity2
  end

  it "insert does not persist multiple entities in an array" do
    _(begin_tx_res).wont_equal "poop"
    entity1 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    transaction.insert [entity1, entity2]
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_inserts")).must_include entity1
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_inserts")).must_include entity2
  end

  it "update does not persist entities" do
    _(begin_tx_res).wont_equal "poop"
    entity = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    transaction.update entity
    # Testing implementation like we are writing Java!
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_updates")).must_include entity
  end

  it "update does not persist multiple entities" do
    _(begin_tx_res).wont_equal "poop"
    entity1 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    transaction.update entity1, entity2
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_updates")).must_include entity1
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_updates")).must_include entity2
  end

  it "update does not persist multiple entities in an array" do
    _(begin_tx_res).wont_equal "poop"
    entity1 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    transaction.update [entity1, entity2]
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_updates")).must_include entity1
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_updates")).must_include entity2
  end

  it "delete does not persist entities" do
    entity = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    transaction.delete entity
    # Testing implementation is bad, mkay?
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_deletes")).must_include entity.key
  end

  it "delete does not persist multiple entities" do
    _(begin_tx_res).wont_equal "poop"
    entity1 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    transaction.delete entity1, entity2
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_deletes")).must_include entity1.key
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_deletes")).must_include entity2.key
  end

  it "delete does not persist multiple entities in an array" do
    _(begin_tx_res).wont_equal "poop"
    entity1 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    transaction.delete [entity1, entity2]
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_deletes")).must_include entity1.key
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_deletes")).must_include entity2.key
  end

  it "delete does not persist keys" do
    entity = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    transaction.delete entity.key
    # Testing implementation like a BOSS!
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_deletes")).must_include entity.key
  end

  it "delete does not persist multiple keys" do
    _(begin_tx_res).wont_equal "poop"
    entity1 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    transaction.delete entity1.key, entity2.key
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_deletes")).must_include entity1.key
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_deletes")).must_include entity2.key
  end

  it "delete does not persist multiple keys in an array" do
    _(begin_tx_res).wont_equal "poop"
    entity1 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    transaction.delete [entity1.key, entity2.key]
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_deletes")).must_include entity1.key
    _(transaction.instance_variable_get("@commit").instance_variable_get("@shared_deletes")).must_include entity2.key
  end

  it "commit will save and delete entities" do
    commit_res = Google::Cloud::Datastore::V1::CommitResponse.new(
      mutation_results: [
        Google::Cloud::Datastore::V1::MutationResult.new,
        Google::Cloud::Datastore::V1::MutationResult.new]
    )
    mode = :TRANSACTIONAL
    mutations = [
      Google::Cloud::Datastore::V1::Mutation.new(
        upsert: Google::Cloud::Datastore::Entity.new.tap do |e|
          e.key = Google::Cloud::Datastore::Key.new "ds-test", "to-be-saved"
          e["name"] = "Gonna be saved"
        end.to_grpc),
      Google::Cloud::Datastore::V1::Mutation.new(
        insert: Google::Cloud::Datastore::Entity.new.tap do |e|
          e.key = Google::Cloud::Datastore::Key.new "ds-test", "to-be-inserted"
          e["name"] = "Gonna be inserted"
        end.to_grpc),
      Google::Cloud::Datastore::V1::Mutation.new(
        update: Google::Cloud::Datastore::Entity.new.tap do |e|
          e.key = Google::Cloud::Datastore::Key.new "ds-test", "to-be-updated"
          e["name"] = "Gonna be updated"
        end.to_grpc),
      Google::Cloud::Datastore::V1::Mutation.new(
        delete: Google::Cloud::Datastore::Key.new("ds-test", "to-be-deleted").to_grpc)
    ]
    transaction.service.mocked_service.expect :commit, commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: tx_id]

    entity_to_be_saved = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "to-be-saved"
      e["name"] = "Gonna be saved"
    end
    entity_to_be_inserted = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "to-be-inserted"
      e["name"] = "Gonna be inserted"
    end
    entity_to_be_updated = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "to-be-updated"
      e["name"] = "Gonna be updated"
    end
    entity_to_be_deleted = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "to-be-deleted"
      e["name"] = "Gonna be deleted"
    end

    _(entity_to_be_saved).wont_be :persisted?
    transaction.commit do |c|
      c.save entity_to_be_saved
      c.insert entity_to_be_inserted
      c.update entity_to_be_updated
      c.delete entity_to_be_deleted
    end
    _(entity_to_be_saved).must_be :persisted?
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
    read_options = Google::Cloud::Datastore::V1::ReadOptions.new(transaction: tx_id)
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

  it "commit persists entities with complete keys" do
    commit_res = Google::Cloud::Datastore::V1::CommitResponse.new(
      mutation_results: [Google::Cloud::Datastore::V1::MutationResult.new]
    )
    mode = :TRANSACTIONAL
    mutations = [
      Google::Cloud::Datastore::V1::Mutation.new(
        upsert: Google::Cloud::Datastore::Entity.new.tap do |e|
          e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
          e["name"] = "thingamajig"
        end.to_grpc)
    ]
    transaction.service.mocked_service.expect :commit, commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: tx_id]

    entity = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    _(entity.key).must_be :complete?
    transaction.save entity
    _(entity).wont_be :persisted?
    transaction.commit
    _(entity.key).must_be :complete?
    _(entity).must_be :persisted?
  end

  it "commit persists entities with incomplete keys" do
    commit_res = Google::Cloud::Datastore::V1::CommitResponse.new(
      mutation_results: [
        Google::Cloud::Datastore::V1::MutationResult.new(
          key: Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc
        )]
    )
    mode = :TRANSACTIONAL
    mutations = [
      Google::Cloud::Datastore::V1::Mutation.new(
        upsert: Google::Cloud::Datastore::Entity.new.tap do |e|
          e.key = Google::Cloud::Datastore::Key.new "ds-test"
          e["name"] = "thingamajig"
        end.to_grpc)
    ]
    transaction.service.mocked_service.expect :commit, commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: tx_id]

    entity = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test"
      e["name"] = "thingamajig"
    end
    _(entity.key).must_be :incomplete?
    transaction.save entity
    _(entity).wont_be :persisted?
    transaction.commit
    _(entity.key).must_be :complete?
    _(entity).must_be :persisted?
  end

  it "rollback does not persist entities" do
    rollback_res = Google::Cloud::Datastore::V1::RollbackResponse.new
    transaction.service.mocked_service.expect :rollback, rollback_res, [project_id: project, transaction: tx_id]

    entity = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    transaction.save entity
    transaction.rollback
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
end
