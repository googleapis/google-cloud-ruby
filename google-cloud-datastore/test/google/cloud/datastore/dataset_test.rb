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

describe Google::Cloud::Datastore::Dataset, :mock_datastore do
  let(:query) { Google::Cloud::Datastore::Query.new.kind("User") }
  let(:gql_query_grpc) { Google::Cloud::Datastore::V1::GqlQuery.new(query_string: "SELECT * FROM Task") }
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
  let(:begin_transaction_response) do
    Google::Cloud::Datastore::V1::BeginTransactionResponse.new.tap do |response|
      response.transaction = "giterdone"
    end
  end
  let(:query_cursor) { Google::Cloud::Datastore::Cursor.new "c3VwZXJhd2Vzb21lIQ==" }

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
  let(:commit_res) do
    Google::Cloud::Datastore::V1::CommitResponse.new(
      mutation_results: [
        Google::Cloud::Datastore::V1::MutationResult.new(key: Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc)
      ]
    )
  end

  let(:multiple_commit_res) do
    Google::Cloud::Datastore::V1::CommitResponse.new(
      mutation_results: [
        Google::Cloud::Datastore::V1::MutationResult.new(key: Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc),
        Google::Cloud::Datastore::V1::MutationResult.new(key: Google::Cloud::Datastore::Key.new("ds-test", "thangie").to_grpc)
      ]
    )
  end

  before do
    dataset.service.mocked_service = Minitest::Mock.new
  end

  after do
    dataset.service.mocked_service.verify
  end

  it "allocate_ids returns complete keys" do
    keys = [Google::Cloud::Datastore::Key.new("ds-test").to_grpc]
    allocate_res = Google::Cloud::Datastore::V1::AllocateIdsResponse.new(
      keys: [Google::Cloud::Datastore::Key.new("ds-test", 1234).to_grpc]
    )
    dataset.service.mocked_service.expect :allocate_ids, allocate_res, [project_id: project, keys: keys]

    incomplete_key = Google::Cloud::Datastore::Key.new "ds-test"
    _(incomplete_key).must_be :incomplete?
    returned_keys = dataset.allocate_ids incomplete_key
    _(returned_keys.count).must_equal 1
    _(returned_keys.first).must_be_kind_of Google::Cloud::Datastore::Key
    _(returned_keys.first).must_be :complete?
  end

  it "allocate_ids raises when not given an incomplete key" do
    complete_key = Google::Cloud::Datastore::Key.new "ds-test", 789
    _(complete_key).must_be :complete?
    assert_raises Google::Cloud::Datastore::KeyError do
      dataset.allocate_ids complete_key
    end
  end

  it "save will persist complete entities" do
    # Remove key from response
    commit_res.mutation_results.first.key = nil
    mutation = Google::Cloud::Datastore::V1::Mutation.new(
      upsert: Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
        e["name"] = "thingamajig"
      end.to_grpc)
    mode = :NON_TRANSACTIONAL
    mutations = [mutation]
    dataset.service.mocked_service.expect :commit, commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: nil]

    entity = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end

    _(entity.key).must_be :complete?
    _(entity).wont_be :persisted?
    dataset.save entity
    _(entity.key).must_be :complete?
    _(entity).must_be :persisted?
  end

  it "save will persist incomplete entities" do
    mutation = Google::Cloud::Datastore::V1::Mutation.new(
      upsert: Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test"
        e["name"] = "thingamajig"
      end.to_grpc)

    mode = :NON_TRANSACTIONAL
    mutations = [mutation]
    dataset.service.mocked_service.expect :commit, commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: nil]

    entity = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test"
      e["name"] = "thingamajig"
    end
    _(entity.key).wont_be :complete?
    _(entity).wont_be :persisted?
    dataset.save entity
    _(entity.key).must_be :complete?
    _(entity).must_be :persisted?
  end

  it "save will persist complete entities with upsert alias" do
    # Remove key from response
    commit_res.mutation_results.first.key = nil
    mutation = Google::Cloud::Datastore::V1::Mutation.new(
      upsert: Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
        e["name"] = "thingamajig"
      end.to_grpc)

    mode = :NON_TRANSACTIONAL
    mutations = [mutation]
    dataset.service.mocked_service.expect :commit, commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: nil]

    entity = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    _(entity.key).must_be :complete?
    _(entity).wont_be :persisted?
    dataset.upsert entity
    _(entity.key).must_be :complete?
    _(entity).must_be :persisted?
  end

  it "save will persist incomplete entities with upsert alias" do
    mutation = Google::Cloud::Datastore::V1::Mutation.new(
      upsert: Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test"
        e["name"] = "thingamajig"
      end.to_grpc)

    mode = :NON_TRANSACTIONAL
    mutations = [mutation]
    dataset.service.mocked_service.expect :commit, commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: nil]

    entity = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test"
      e["name"] = "thingamajig"
    end
    _(entity.key).wont_be :complete?
    _(entity).wont_be :persisted?
    dataset.upsert entity
    _(entity.key).must_be :complete?
    _(entity).must_be :persisted?
  end

  it "save will persist multiple entities" do
    mutation1 = Google::Cloud::Datastore::V1::Mutation.new(
      upsert: Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
        e["name"] = "thingamajig"
      end.to_grpc)
    mutation2 = Google::Cloud::Datastore::V1::Mutation.new(
      upsert: Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
        e["name"] = "thungamajig"
      end.to_grpc)
    mode = :NON_TRANSACTIONAL
    mutations = [mutation1, mutation2]

    dataset.service.mocked_service.expect :commit, multiple_commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: nil]

    entity1 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    _(entity1).wont_be :persisted?
    _(entity2).wont_be :persisted?
    dataset.save entity1, entity2
    _(entity1).must_be :persisted?
    _(entity2).must_be :persisted?
  end

  it "save will persist multiple entities in an array" do
    mutation1 = Google::Cloud::Datastore::V1::Mutation.new(
      upsert: Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
        e["name"] = "thingamajig"
      end.to_grpc)
    mutation2 = Google::Cloud::Datastore::V1::Mutation.new(
      upsert: Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
        e["name"] = "thungamajig"
      end.to_grpc)
    mode = :NON_TRANSACTIONAL
    mutations = [mutation1, mutation2]

    dataset.service.mocked_service.expect :commit, multiple_commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: nil]

    entity1 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    _(entity1).wont_be :persisted?
    _(entity2).wont_be :persisted?
    dataset.save [entity1, entity2]
    _(entity1).must_be :persisted?
    _(entity2).must_be :persisted?
  end

  it "insert will persist complete entities" do
    # Remove key from response
    commit_res.mutation_results.first.key = nil
    mutation = Google::Cloud::Datastore::V1::Mutation.new(
      insert: Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
        e["name"] = "thingamajig"
      end.to_grpc)

    mode = :NON_TRANSACTIONAL
    mutations = [mutation]
    dataset.service.mocked_service.expect :commit, commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: nil]

    entity = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    _(entity.key).must_be :complete?
    _(entity).wont_be :persisted?
    dataset.insert entity
    _(entity.key).must_be :complete?
    _(entity).must_be :persisted?
  end

  it "insert will persist incomplete entities" do
    mutation = Google::Cloud::Datastore::V1::Mutation.new(
      insert: Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test"
        e["name"] = "thingamajig"
      end.to_grpc)

    mode = :NON_TRANSACTIONAL
    mutations = [mutation]
    dataset.service.mocked_service.expect :commit, commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: nil]

    entity = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test"
      e["name"] = "thingamajig"
    end
    _(entity.key).wont_be :complete?
    _(entity).wont_be :persisted?
    dataset.insert entity
    _(entity.key).must_be :complete?
    _(entity).must_be :persisted?
  end

  it "insert will persist multiple entities" do
    mutation1 = Google::Cloud::Datastore::V1::Mutation.new(
      insert: Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
        e["name"] = "thingamajig"
      end.to_grpc)
    mutation2 = Google::Cloud::Datastore::V1::Mutation.new(
      insert: Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
        e["name"] = "thungamajig"
      end.to_grpc)

    mode = :NON_TRANSACTIONAL
    mutations = [mutation1, mutation2]

    dataset.service.mocked_service.expect :commit, multiple_commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: nil]

    entity1 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    _(entity1).wont_be :persisted?
    _(entity2).wont_be :persisted?
    dataset.insert entity1, entity2
    _(entity1).must_be :persisted?
    _(entity2).must_be :persisted?
  end

  it "insert will persist multiple entities in an array" do
    mutation1 = Google::Cloud::Datastore::V1::Mutation.new(
      insert: Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
        e["name"] = "thingamajig"
      end.to_grpc)
    mutation2 = Google::Cloud::Datastore::V1::Mutation.new(
      insert: Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
        e["name"] = "thungamajig"
      end.to_grpc)

    mode = :NON_TRANSACTIONAL
    mutations = [mutation1, mutation2]

    dataset.service.mocked_service.expect :commit, multiple_commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: nil]

    entity1 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    _(entity1).wont_be :persisted?
    _(entity2).wont_be :persisted?
    dataset.insert [entity1, entity2]
    _(entity1).must_be :persisted?
    _(entity2).must_be :persisted?
  end

  it "update will persist entities" do
    # Remove key from response
    commit_res.mutation_results.first.key = nil
    mutation = Google::Cloud::Datastore::V1::Mutation.new(
      update: Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
        e["name"] = "thingamajig"
      end.to_grpc)
    mode = :NON_TRANSACTIONAL
    mutations = [mutation]
    dataset.service.mocked_service.expect :commit, commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: nil]

    entity = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    _(entity.key).must_be :complete?
    _(entity).wont_be :persisted?
    dataset.update entity
    _(entity.key).must_be :complete?
    _(entity).must_be :persisted?
  end

  it "update will persist multiple entities" do
    # Remove keys from response
    multiple_commit_res.mutation_results.each { |m| m.key = nil }
    mutation1 = Google::Cloud::Datastore::V1::Mutation.new(
      update: Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
        e["name"] = "thingamajig"
      end.to_grpc)
    mutation2 = Google::Cloud::Datastore::V1::Mutation.new(
      update: Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
        e["name"] = "thungamajig"
      end.to_grpc)
    mode = :NON_TRANSACTIONAL
    mutations = [mutation1, mutation2]

    dataset.service.mocked_service.expect :commit, multiple_commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: nil]

    entity1 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    _(entity1).wont_be :persisted?
    _(entity2).wont_be :persisted?
    dataset.update entity1, entity2
    _(entity1).must_be :persisted?
    _(entity2).must_be :persisted?
  end

  it "update will persist multiple entities in an array" do
    # Remove keys from response
    multiple_commit_res.mutation_results.each { |m| m.key = nil }
    mutation1 = Google::Cloud::Datastore::V1::Mutation.new(
      update: Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
        e["name"] = "thingamajig"
      end.to_grpc)
    mutation2 = Google::Cloud::Datastore::V1::Mutation.new(
      update: Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
        e["name"] = "thungamajig"
      end.to_grpc)
    mode = :NON_TRANSACTIONAL
    mutations = [mutation1, mutation2]

    dataset.service.mocked_service.expect :commit, multiple_commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: nil]

    entity1 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    _(entity1).wont_be :persisted?
    _(entity2).wont_be :persisted?
    dataset.update [entity1, entity2]
    _(entity1).must_be :persisted?
    _(entity2).must_be :persisted?
  end

  it "find can take a kind and id" do
    keys = [Google::Cloud::Datastore::Key.new("ds-test", 123).to_grpc]
    dataset.service.mocked_service.expect :lookup, lookup_res, [project_id: project, keys: keys, read_options: nil]

    entity = dataset.find "ds-test", 123
    _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
  end

  it "find can take a kind and name" do
    keys = [Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc]
    dataset.service.mocked_service.expect :lookup, lookup_res, [project_id: project, keys: keys, read_options: nil]

    entity = dataset.find "ds-test", "thingie"
    _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
  end

  it "find can take a key" do
    keys = [Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc]
    dataset.service.mocked_service.expect :lookup, lookup_res, [project_id: project, keys: keys, read_options: nil]

    key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
    entity = dataset.find key
    _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
  end

  it "find is aliased to get" do
    keys = [Google::Cloud::Datastore::Key.new("ds-test", 123).to_grpc]
    dataset.service.mocked_service.expect :lookup, lookup_res, [project_id: project, keys: keys, read_options: nil]

    entity = dataset.get "ds-test", 123
    _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
  end

  it "find can specify consistency" do
    keys = [Google::Cloud::Datastore::Key.new("ds-test", 123).to_grpc]
    read_options = Google::Cloud::Datastore::V1::ReadOptions.new(read_consistency: :EVENTUAL)
    dataset.service.mocked_service.expect :lookup, lookup_res, [project_id: project, keys: keys, read_options: read_options]

    entity = dataset.find "ds-test", 123, consistency: :eventual
    _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
  end

  it "find raises if consistency is a bad value" do
    error = expect do
      dataset.find "ds-test", 123, consistency: "foobar"
    end.must_raise ArgumentError
    _(error.message).must_equal "Consistency must be :eventual or :strong, not \"foobar\"."
  end

  it "find_all takes several keys" do
    keys = [Google::Cloud::Datastore::Key.new("ds-test", "thingie1").to_grpc,
            Google::Cloud::Datastore::Key.new("ds-test", "thingie2").to_grpc]
    dataset.service.mocked_service.expect :lookup, lookup_res, [project_id: project, keys: keys, read_options: nil]

    key1 = Google::Cloud::Datastore::Key.new "ds-test", "thingie1"
    key2 = Google::Cloud::Datastore::Key.new "ds-test", "thingie2"
    entities = dataset.find_all key1, key2
    _(entities.count).must_equal 2
    _(entities.deferred.count).must_equal 0
    _(entities.missing.count).must_equal 0
    entities.each do |entity|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    end
  end

  it "find_all is aliased to lookup" do
    keys = [Google::Cloud::Datastore::Key.new("ds-test", "thingie1").to_grpc,
            Google::Cloud::Datastore::Key.new("ds-test", "thingie2").to_grpc]
    dataset.service.mocked_service.expect :lookup, lookup_res, [project_id: project, keys: keys, read_options: nil]

    key1 = Google::Cloud::Datastore::Key.new "ds-test", "thingie1"
    key2 = Google::Cloud::Datastore::Key.new "ds-test", "thingie2"
    entities = dataset.lookup key1, key2
    _(entities.count).must_equal 2
    _(entities.deferred.count).must_equal 0
    _(entities.missing.count).must_equal 0
    entities.each do |entity|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    end
  end

  it "find_all can specify consistency" do
    keys = [Google::Cloud::Datastore::Key.new("ds-test", "thingie1").to_grpc,
            Google::Cloud::Datastore::Key.new("ds-test", "thingie2").to_grpc]
    read_options = Google::Cloud::Datastore::V1::ReadOptions.new(read_consistency: :EVENTUAL)
    dataset.service.mocked_service.expect :lookup, lookup_res, [project_id: project, keys: keys, read_options: read_options]

    key1 = Google::Cloud::Datastore::Key.new "ds-test", "thingie1"
    key2 = Google::Cloud::Datastore::Key.new "ds-test", "thingie2"
    entities = dataset.lookup key1, key2, consistency: :eventual
    _(entities.count).must_equal 2
    _(entities.deferred.count).must_equal 0
    _(entities.missing.count).must_equal 0
    entities.each do |entity|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    end
  end

  it "find_all raises if consistency is a bad value" do
    error = expect do
      key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      entities = dataset.lookup key, key, consistency: "foobar"
    end.must_raise ArgumentError
    _(error.message).must_equal "Consistency must be :eventual or :strong, not \"foobar\"."
  end

  describe "find_all result object" do
    let(:lookup_res_deferred) do
      lookup_res.tap do |response|
        2.times.map do
          response.deferred << Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc
        end
      end
    end

    let(:lookup_res_missing) do
      lookup_res.tap do |response|
        2.times.map do
          response.missing << Google::Cloud::Datastore::V1::EntityResult.new(
            entity: Google::Cloud::Datastore::Entity.new.tap do |e|
              e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
              e["name"] = "thingamajig"
            end.to_grpc
          )
        end
      end
    end

    it "contains deferred entities" do
      keys = [Google::Cloud::Datastore::Key.new("ds-test", "thingie1").to_grpc,
              Google::Cloud::Datastore::Key.new("ds-test", "thingie2").to_grpc]
      dataset.service.mocked_service.expect :lookup, lookup_res_deferred, [project_id: project, keys: keys, read_options: nil]

      key1 = Google::Cloud::Datastore::Key.new "ds-test", "thingie1"
      key2 = Google::Cloud::Datastore::Key.new "ds-test", "thingie2"
      entities = dataset.find_all key1, key2
      _(entities.count).must_equal 2
      _(entities.deferred.count).must_equal 2
      _(entities.missing.count).must_equal 0
      entities.each do |entity|
        _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
      end
      entities.deferred.each do |deferred_key|
        _(deferred_key).must_be_kind_of Google::Cloud::Datastore::Key
      end
    end

    it "contains missing entities" do
      keys = [Google::Cloud::Datastore::Key.new("ds-test", "thingie1").to_grpc,
              Google::Cloud::Datastore::Key.new("ds-test", "thingie2").to_grpc]
      dataset.service.mocked_service.expect :lookup, lookup_res_missing, [project_id: project, keys: keys, read_options: nil]

      key1 = Google::Cloud::Datastore::Key.new "ds-test", "thingie1"
      key2 = Google::Cloud::Datastore::Key.new "ds-test", "thingie2"
      entities = dataset.find_all key1, key2
      _(entities.count).must_equal 2
      _(entities.deferred.count).must_equal 0
      _(entities.missing.count).must_equal 2
      entities.each do |entity|
        _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
      end
      entities.missing.each do |entity|
        _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
      end
    end
  end

  it "delete with entity will call commit" do
    mutation = Google::Cloud::Datastore::V1::Mutation.new(
      delete: Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc
    )
    mode = :NON_TRANSACTIONAL
    mutations = [mutation]
    dataset.service.mocked_service.expect :commit, commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: nil]

    entity = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    dataset.delete entity
  end

  it "delete with multiple entity will call commit" do
    mutation1 = Google::Cloud::Datastore::V1::Mutation.new(
      delete: Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc)
    mutation2 = Google::Cloud::Datastore::V1::Mutation.new(
      delete: Google::Cloud::Datastore::Key.new("ds-test", "thangie").to_grpc)
    mode = :NON_TRANSACTIONAL
    mutations = [mutation1, mutation2]

    dataset.service.mocked_service.expect :commit, multiple_commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: nil]

    entity1 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    dataset.delete entity1, entity2
  end

  it "delete with multiple entity in an array will call commit" do
    mutation1 = Google::Cloud::Datastore::V1::Mutation.new(
      delete: Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc)
    mutation2 = Google::Cloud::Datastore::V1::Mutation.new(
      delete: Google::Cloud::Datastore::Key.new("ds-test", "thangie").to_grpc)
    mode = :NON_TRANSACTIONAL
    mutations = [mutation1, mutation2]

    dataset.service.mocked_service.expect :commit, multiple_commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: nil]

    entity1 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    dataset.delete [entity1, entity2]
  end

  it "delete with key will call commit" do
    mutation = Google::Cloud::Datastore::V1::Mutation.new(
      delete: Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc
    )
    mode = :NON_TRANSACTIONAL
    mutations = [mutation]
    dataset.service.mocked_service.expect :commit, commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: nil]

    key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
    dataset.delete key
  end

  it "delete with multiple keys will call commit" do
    mutation1 = Google::Cloud::Datastore::V1::Mutation.new(
      delete: Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc)
    mutation2 = Google::Cloud::Datastore::V1::Mutation.new(
      delete: Google::Cloud::Datastore::Key.new("ds-test", "thangie").to_grpc)
    mode = :NON_TRANSACTIONAL
    mutations = [mutation1, mutation2]

    dataset.service.mocked_service.expect :commit, multiple_commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: nil]

    entity1 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    dataset.delete entity1.key, entity2.key
  end

  it "delete with multiple keys in an array will call commit" do
    mutation1 = Google::Cloud::Datastore::V1::Mutation.new(
      delete: Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc)
    mutation2 = Google::Cloud::Datastore::V1::Mutation.new(
      delete: Google::Cloud::Datastore::Key.new("ds-test", "thangie").to_grpc)
    mode = :NON_TRANSACTIONAL
    mutations = [mutation1, mutation2]

    dataset.service.mocked_service.expect :commit, multiple_commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: nil]

    entity1 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    dataset.delete [entity1.key, entity2.key]
  end

  it "run will fulfill a query" do
    dataset.service.mocked_service.expect :run_query, run_query_res, [project_id: project, partition_id: nil, read_options: nil, query: query.to_grpc, gql_query: nil]

    entities = dataset.run query
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

  it "commit will save and delete entities" do
    mode = :NON_TRANSACTIONAL
    mutations = [Google::Cloud::Datastore::V1::Mutation.new(
                   upsert: Google::Cloud::Datastore::Entity.new.tap do |e|
                     e.key = Google::Cloud::Datastore::Key.new "ds-test", "to-be-saved"
                     e["name"] = "Gonna be saved"
                   end.to_grpc), Google::Cloud::Datastore::V1::Mutation.new(
                                 delete: Google::Cloud::Datastore::Key.new("ds-test", "to-be-deleted").to_grpc)
    ]
    dataset.service.mocked_service.expect :commit, commit_res, [project_id: project, mode: mode, mutations: mutations, transaction: nil]

    entity_to_be_saved = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "to-be-saved"
      e["name"] = "Gonna be saved"
    end
    entity_to_be_deleted = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test", "to-be-deleted"
      e["name"] = "Gonna be deleted"
    end

    _(entity_to_be_saved).wont_be :persisted?
    dataset.commit do |c|
      c.save entity_to_be_saved
      c.delete entity_to_be_deleted
    end
    _(entity_to_be_saved).must_be :persisted?
  end

  it "run_query will fulfill a query" do
    dataset.service.mocked_service.expect :run_query, run_query_res, [project_id: project, partition_id: nil, read_options: nil, query: query.to_grpc, gql_query: nil]

    entities = dataset.run_query query
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
    _(entities.more_results).must_equal :MORE_RESULTS_TYPE_UNSPECIFIED
    refute entities.not_finished?
    refute entities.more_after_limit?
    refute entities.more_after_cursor?
    refute entities.no_more?
  end

  it "run_query will fulfill a query with a namespace" do
    partition_id = Google::Cloud::Datastore::V1::PartitionId.new(namespace_id: "foobar")
    dataset.service.mocked_service.expect :run_query, run_query_res, [project_id: project, partition_id: partition_id, read_options: nil, query: query.to_grpc, gql_query: nil]

    entities = dataset.run_query query, namespace: "foobar"
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
    _(entities.more_results).must_equal :MORE_RESULTS_TYPE_UNSPECIFIED
    refute entities.not_finished?
    refute entities.more_after_limit?
    refute entities.more_after_cursor?
    refute entities.no_more?
  end

  it "run will fulfill a gql query" do
    dataset.service.mocked_service.expect :run_query, run_query_res, [project_id: project, partition_id: nil, read_options: nil, query: nil, gql_query: gql_query_grpc]

    gql = dataset.gql "SELECT * FROM Task"
    entities = dataset.run gql
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

  it "run will fulfill a gql query with a namespace" do
    partition_id = Google::Cloud::Datastore::V1::PartitionId.new(namespace_id: "foobar")
    dataset.service.mocked_service.expect :run_query, run_query_res, [project_id: project, partition_id: partition_id, read_options: nil, query: nil, gql_query: gql_query_grpc]

    gql = dataset.gql "SELECT * FROM Task"
    entities = dataset.run gql, namespace: "foobar"
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

  it "run_query will fulfill a gql query" do
    dataset.service.mocked_service.expect :run_query, run_query_res, [project_id: project, partition_id: nil, read_options: nil, query: nil, gql_query: gql_query_grpc]

    gql = dataset.gql "SELECT * FROM Task"
    entities = dataset.run_query gql
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

  it "run_query will fulfill a gql query with a namespace" do
    partition_id = Google::Cloud::Datastore::V1::PartitionId.new(namespace_id: "foobar")
    dataset.service.mocked_service.expect :run_query, run_query_res, [project_id: project, partition_id: partition_id, read_options: nil, query: nil, gql_query: gql_query_grpc]

    gql = dataset.gql "SELECT * FROM Task"
    entities = dataset.run_query gql, namespace: "foobar"
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

  it "run will raise when given an unknown argument" do
    expect do
      entities = dataset.run 123
    end.must_raise ArgumentError
  end

  it "query returns a Query instance" do
    query = dataset.query "Task"
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
    key = dataset.key "ThisThing", 1234
    _(key).must_be_kind_of Google::Cloud::Datastore::Key
    _(key.kind).must_equal "ThisThing"
    _(key.id).must_equal 1234
    _(key.name).must_be :nil?

    key = dataset.key "ThisThing", "charlie"
    _(key).must_be_kind_of Google::Cloud::Datastore::Key
    _(key.kind).must_equal "ThisThing"
    _(key.id).must_be :nil?
    _(key.name).must_equal "charlie"
  end

  it "key sets a parent and grandparent in the constructor" do
    path = [["OtherThing", "root"], ["ThatThing", 6789], ["ThisThing", 1234]]
    key = dataset.key path, project: "custom-ds", namespace: "custom-ns"
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

  it "entity returns an Entity instance" do
    entity = dataset.entity
    _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
  end

  it "entity sets the Key's kind for the new Entity" do
    entity = dataset.entity "User"
    _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    _(entity.key.kind).must_equal "User"
    _(entity.key.id).must_be :nil?
    _(entity.key.name).must_be :nil?
  end

  it "entity sets the Key's kind and id for the new Entity" do
    entity = dataset.entity "User", 123
    _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    _(entity.key.kind).must_equal "User"
    _(entity.key.id).must_equal 123
    _(entity.key.name).must_be :nil?
  end

  it "entity sets the Key's kind and name for the new Entity" do
    entity = dataset.entity "User", "username"
    _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    _(entity.key.kind).must_equal "User"
    _(entity.key.id).must_be :nil?
    _(entity.key.name).must_equal "username"
  end

  it "entity sets the Key object for the new Entity" do
    key = dataset.key "User", "username"
    entity = dataset.entity key
    _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    _(entity.key.kind).must_equal "User"
    _(entity.key.id).must_be :nil?
    _(entity.key.name).must_equal "username"
  end

  it "entity sets a key's parent and grandparent" do
    path = [["OtherThing", "root"], ["ThatThing", 6789], ["ThisThing", 1234]]
    entity = dataset.entity path, project: "custom-ds", namespace: "custom-ns"
    _(entity.key.kind).must_equal "ThisThing"
    _(entity.key.id).must_equal 1234
    _(entity.key.name).must_be :nil?
    _(entity.key.path).must_equal [["OtherThing", "root"], ["ThatThing", 6789], ["ThisThing", 1234]]
    _(entity.key.project).must_equal "custom-ds"
    _(entity.key.namespace).must_equal "custom-ns"

    _(entity.key.parent).wont_be :nil?
    _(entity.key.parent.kind).must_equal "ThatThing"
    _(entity.key.parent.id).must_equal 6789
    _(entity.key.parent.name).must_be :nil?
    _(entity.key.parent.path).must_equal [["OtherThing", "root"], ["ThatThing", 6789]]
    _(entity.key.parent.project).must_equal "custom-ds"
    _(entity.key.parent.namespace).must_equal "custom-ns"

    _(entity.key.parent.parent).wont_be :nil?
    _(entity.key.parent.parent.kind).must_equal "OtherThing"
    _(entity.key.parent.parent.id).must_be :nil?
    _(entity.key.parent.parent.name).must_equal "root"
    _(entity.key.parent.parent.path).must_equal [["OtherThing", "root"]]
    _(entity.key.parent.parent.project).must_equal "custom-ds"
    _(entity.key.parent.parent.namespace).must_equal "custom-ns"
  end

  it "entity can configure the new Entity using a block" do
    entity = dataset.entity "User", "username" do |e|
      e["name"] = "User McUser"
      e["email"] = "user@example.net"
    end
    _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    _(entity.key.kind).must_equal "User"
    _(entity.key.id).must_be :nil?
    _(entity.key.name).must_equal "username"
    _(entity.properties["name"]).must_equal "User McUser"
    _(entity.properties["email"]).must_equal "user@example.net"
  end

  it "transaction will return a Transaction" do
    tx_id = "giterdone".encode("ASCII-8BIT")
    begin_tx_res = Google::Cloud::Datastore::V1::BeginTransactionResponse.new(transaction: tx_id)
    dataset.service.mocked_service.expect :begin_transaction, begin_tx_res, [project_id: project, transaction_options: nil]

    tx = dataset.transaction
    _(tx).must_be_kind_of Google::Cloud::Datastore::Transaction
    _(tx.id).must_equal "giterdone"
  end

  it "transaction will return a Transaction with previous_transaction" do
    previous_transaction_id = "giterdone-previous".encode("ASCII-8BIT")
    tx_id = "giterdone".encode("ASCII-8BIT")
    tx_options = Google::Cloud::Datastore::V1::TransactionOptions.new
    tx_options.read_write = Google::Cloud::Datastore::V1::TransactionOptions::ReadWrite.new(
        previous_transaction: previous_transaction_id
      )
    begin_tx_res = Google::Cloud::Datastore::V1::BeginTransactionResponse.new(transaction: tx_id)
    dataset.service.mocked_service.expect :begin_transaction, begin_tx_res, [project_id: project, transaction_options: tx_options]

    tx = dataset.transaction previous_transaction: previous_transaction_id
    _(tx).must_be_kind_of Google::Cloud::Datastore::Transaction
    _(tx.id).must_equal "giterdone"
  end

  it "read_only_transaction will return a read-only Transaction" do
    tx_id = "giterdone".encode("ASCII-8BIT")
    tx_options = Google::Cloud::Datastore::V1::TransactionOptions.new(
      read_write: nil,
      read_only: Google::Cloud::Datastore::V1::TransactionOptions::ReadOnly.new
    )
    begin_tx_res = Google::Cloud::Datastore::V1::BeginTransactionResponse.new(transaction: tx_id)
    dataset.service.mocked_service.expect :begin_transaction, begin_tx_res, [project_id: project, transaction_options: tx_options]

    tx = dataset.read_only_transaction
    _(tx).must_be_kind_of Google::Cloud::Datastore::ReadOnlyTransaction
  end

  it "snapshot will return a read-only Transaction" do
    tx_id = "giterdone".encode("ASCII-8BIT")
    tx_options = Google::Cloud::Datastore::V1::TransactionOptions.new(
      read_write: nil,
      read_only: Google::Cloud::Datastore::V1::TransactionOptions::ReadOnly.new
    )
    begin_tx_res = Google::Cloud::Datastore::V1::BeginTransactionResponse.new(transaction: tx_id)
    dataset.service.mocked_service.expect :begin_transaction, begin_tx_res, [project_id: project, transaction_options: tx_options]

    tx = dataset.snapshot
    _(tx).must_be_kind_of Google::Cloud::Datastore::ReadOnlyTransaction
  end

  it "transaction will commit with a block" do
    tx_id = "giterdone".encode("ASCII-8BIT")
    begin_tx_res = Google::Cloud::Datastore::V1::BeginTransactionResponse.new(transaction: tx_id)
    commit_res = Google::Cloud::Datastore::V1::CommitResponse.new(
      mutation_results: [Google::Cloud::Datastore::V1::MutationResult.new(
                           key: Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc
                         )]
    )
    mutation = Google::Cloud::Datastore::V1::Mutation.new(
      upsert: Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test"
        e["name"] = "thingamajig"
      end.to_grpc)
    dataset.service.mocked_service.expect :begin_transaction, begin_tx_res, [project_id: project, transaction_options: nil]
    dataset.service.mocked_service.expect :commit, commit_res, [project_id: project, mode: :TRANSACTIONAL, mutations: [mutation], transaction: tx_id]

    entity = Google::Cloud::Datastore::Entity.new.tap do |e|
      e.key = Google::Cloud::Datastore::Key.new "ds-test"
      e["name"] = "thingamajig"
    end
    dataset.transaction do |tx|
      tx.save entity
    end
  end

  it "transaction will wrap errors in TransactionError" do
    tx_id = "giterdone".encode("ASCII-8BIT")
    begin_tx_res = Google::Cloud::Datastore::V1::BeginTransactionResponse.new(transaction: tx_id)
    rollback_res = Google::Cloud::Datastore::V1::RollbackResponse.new
    dataset.service.mocked_service.expect :begin_transaction, begin_tx_res, [project_id: project, transaction_options: nil]
    dataset.service.mocked_service.expect :rollback, rollback_res, [project_id: project, transaction: tx_id]

    error = assert_raises Google::Cloud::Datastore::TransactionError do
      dataset.transaction do |tx|
        fail "This error should be wrapped by TransactionError."
      end
    end

    _(error).wont_be :nil?
    _(error.message).must_equal "Transaction failed to commit."
    _(error.cause).wont_be :nil?
    _(error.cause.message).must_equal "This error should be wrapped by TransactionError."
  end

  it "transaction will wrap errors for both commit and rollback" do
    # Save mocked service so we can restore it later.
    mocked_service = dataset.service
    begin
      tx_id = "giterdone".encode("ASCII-8BIT")
      begin_tx_res = Google::Cloud::Datastore::V1::BeginTransactionResponse.new(transaction: tx_id)

      stub = self
      stub.instance_variable_set :@response, begin_tx_res
      def stub.begin_transaction read_only: nil, previous_transaction: nil
        @response
      end
      def stub.commit *args
        raise "commit error"
      end
      def stub.rollback *args
        raise "rollback error"
      end
      # Replace mocked connection with this one off object.
      dataset.service = stub

      entity = Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
        e["name"] = "thingamajig"
      end

      error = assert_raises Google::Cloud::Datastore::TransactionError do
        dataset.transaction do |tx|
          tx.save entity
        end
      end

      _(error).wont_be :nil?
      _(error).must_be_kind_of Google::Cloud::Datastore::TransactionError
      _(error.message).must_equal "Transaction failed to commit and rollback."
      _(error.cause).wont_be :nil?
      _(error.cause).must_be_kind_of RuntimeError
      _(error.cause.message).must_equal "rollback error"
      if error.cause.respond_to? :cause # RuntimeError#cause not on Ruby 2.0
        _(error.cause.cause).must_be_kind_of RuntimeError
        _(error.cause.cause.message).must_equal "commit error"
      end
    ensure
      # Reset mocked service so the call to verify works.
      dataset.service = mocked_service
    end
  end

  describe "transaction retry" do
    it "retries when an unavailable error is raised" do
      tx_id = "giterdone".encode("ASCII-8BIT")
      begin_tx_res = Google::Cloud::Datastore::V1::BeginTransactionResponse.new(transaction: tx_id)
      dataset.service.mocked_service.expect :begin_transaction, begin_tx_res, [project_id: project, transaction_options: nil]

      retry_tx_id = "doitlive".encode("ASCII-8BIT")
      retry_begin_tx_res = Google::Cloud::Datastore::V1::BeginTransactionResponse.new(transaction: retry_tx_id)
      retry_tx_options = Google::Cloud::Datastore::V1::TransactionOptions.new(
        read_write: Google::Cloud::Datastore::V1::TransactionOptions::ReadWrite.new(
          previous_transaction: tx_id
        )
      )
      dataset.service.mocked_service.expect :begin_transaction, retry_begin_tx_res, [project_id: project, transaction_options: retry_tx_options]

      mocked_service = dataset.service.mocked_service
      def mocked_service.commit *args
        if @first_commit.nil?
          @first_commit = true

          raise Google::Cloud::UnavailableError.new("unavailable")
        end

        Google::Cloud::Datastore::V1::CommitResponse.new(mutation_results: [
            Google::Cloud::Datastore::V1::MutationResult.new(
              key: Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc
            )
        ])
      end

      entity = Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test"
        e["name"] = "thingamajig"
      end
      dataset.transaction do |tx|
        tx.save entity
      end
    end

    it "does not retry when an unsupported error is raised" do
      tx_id = "giterdone".encode("ASCII-8BIT")
      begin_tx_res = Google::Cloud::Datastore::V1::BeginTransactionResponse.new(transaction: tx_id)
      rollback_res = Google::Cloud::Datastore::V1::RollbackResponse.new
      dataset.service.mocked_service.expect :begin_transaction, begin_tx_res, [project_id: project, transaction_options: nil]
      dataset.service.mocked_service.expect :rollback, rollback_res, [project_id: project, transaction: tx_id]

      mocked_service = dataset.service.mocked_service
      def mocked_service.commit *args
        raise "unsupported"
      end

      entity = Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test"
        e["name"] = "thingamajig"
      end
      error = expect do
        dataset.transaction do |tx|
          tx.save entity
        end
      end.must_raise Google::Cloud::Datastore::TransactionError
      _(error.message).must_equal "Transaction failed to commit."
      _(error.cause).must_be_kind_of StandardError
      _(error.cause.message).must_equal "unsupported"
    end
  end
end
