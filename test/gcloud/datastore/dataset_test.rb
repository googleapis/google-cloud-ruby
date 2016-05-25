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
  let(:run_query_res) do
    run_query_res_entities = 2.times.map do |i|
      Google::Datastore::V1beta3::EntityResult.new(
        entity: Gcloud::Datastore::Entity.new.tap do |e|
          e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
          e["name"] = "thingamajig"
        end.to_grpc,
        cursor: "result-cursor-#{i}".force_encoding("ASCII-8BIT")
      )
    end
    Google::Datastore::V1beta3::RunQueryResponse.new(
      batch: Google::Datastore::V1beta3::QueryResultBatch.new(
        entity_results: run_query_res_entities,
        end_cursor: Gcloud::GRPCUtils.decode_bytes(query_cursor)
      )
    )
  end
  let(:begin_transaction_response) do
    Google::Datastore::V1beta3::BeginTransactionResponse.new.tap do |response|
      response.transaction = "giterdone"
    end
  end
  let(:query_cursor) { Gcloud::Datastore::Cursor.new "c3VwZXJhd2Vzb21lIQ==" }

  let(:lookup_res) do
    Google::Datastore::V1beta3::LookupResponse.new(
      found: 2.times.map do
        Google::Datastore::V1beta3::EntityResult.new(
          entity: Google::Datastore::V1beta3::Entity.new(
            key: Gcloud::Datastore::Key.new("ds-test", "thingie").to_grpc,
            properties: { "name" => Gcloud::GRPCUtils.to_value("thingamajig") }
          )
        )
      end
    )
  end
  let(:commit_res) do
    Google::Datastore::V1beta3::CommitResponse.new(
      mutation_results: [
        Google::Datastore::V1beta3::MutationResult.new(key: Gcloud::Datastore::Key.new("ds-test", "thingie").to_grpc)
      ]
    )
  end

  let(:multiple_commit_res) do
    Google::Datastore::V1beta3::CommitResponse.new(
      mutation_results: [
        Google::Datastore::V1beta3::MutationResult.new(key: Gcloud::Datastore::Key.new("ds-test", "thingie").to_grpc),
        Google::Datastore::V1beta3::MutationResult.new(key: Gcloud::Datastore::Key.new("ds-test", "thangie").to_grpc)
      ]
    )
  end

  before do
    dataset.service.mocked_datastore = Minitest::Mock.new
  end

  after do
    dataset.service.mocked_datastore.verify
  end

  it "allocate_ids returns complete keys" do
    allocate_req = Google::Datastore::V1beta3::AllocateIdsRequest.new(
      project_id: project,
      keys: [Gcloud::Datastore::Key.new("ds-test").to_grpc]
    )
    allocate_res = Google::Datastore::V1beta3::AllocateIdsResponse.new(
      keys: [Gcloud::Datastore::Key.new("ds-test", 1234).to_grpc]
    )
    dataset.service.mocked_datastore.expect :allocate_ids, allocate_res, [allocate_req]

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

  it "save will persist complete entities" do
    # Remove key from response
    commit_res.mutation_results.first.key = nil
    mutation = Google::Datastore::V1beta3::Mutation.new(
      upsert: Gcloud::Datastore::Entity.new.tap do |e|
        e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
        e["name"] = "thingamajig"
      end.to_grpc)
    commit_req = Google::Datastore::V1beta3::CommitRequest.new(
      project_id: project,
      mode: :NON_TRANSACTIONAL,
      mutations: [mutation]
    )
    dataset.service.mocked_datastore.expect :commit, commit_res, [commit_req]

    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end

    entity.key.must_be :complete?
    entity.wont_be :persisted?
    dataset.save entity
    entity.key.must_be :complete?
    entity.must_be :persisted?
  end

  it "save will persist incomplete entities" do
    mutation = Google::Datastore::V1beta3::Mutation.new(
      upsert: Gcloud::Datastore::Entity.new.tap do |e|
        e.key = Gcloud::Datastore::Key.new "ds-test"
        e["name"] = "thingamajig"
      end.to_grpc)
    commit_req = Google::Datastore::V1beta3::CommitRequest.new(
      project_id: project,
      mode: :NON_TRANSACTIONAL,
      mutations: [mutation]
    )
    dataset.service.mocked_datastore.expect :commit, commit_res, [commit_req]

    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test"
      e["name"] = "thingamajig"
    end
    entity.key.wont_be :complete?
    entity.wont_be :persisted?
    dataset.save entity
    entity.key.must_be :complete?
    entity.must_be :persisted?
  end

  it "save will persist complete entities with upsert alias" do
    # Remove key from response
    commit_res.mutation_results.first.key = nil
    mutation = Google::Datastore::V1beta3::Mutation.new(
      upsert: Gcloud::Datastore::Entity.new.tap do |e|
        e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
        e["name"] = "thingamajig"
      end.to_grpc)
    commit_req = Google::Datastore::V1beta3::CommitRequest.new(
      project_id: project,
      mode: :NON_TRANSACTIONAL,
      mutations: [mutation]
    )
    dataset.service.mocked_datastore.expect :commit, commit_res, [commit_req]

    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity.key.must_be :complete?
    entity.wont_be :persisted?
    dataset.upsert entity
    entity.key.must_be :complete?
    entity.must_be :persisted?
  end

  it "save will persist incomplete entities with upsert alias" do
    mutation = Google::Datastore::V1beta3::Mutation.new(
      upsert: Gcloud::Datastore::Entity.new.tap do |e|
        e.key = Gcloud::Datastore::Key.new "ds-test"
        e["name"] = "thingamajig"
      end.to_grpc)
    commit_req = Google::Datastore::V1beta3::CommitRequest.new(
      project_id: project,
      mode: :NON_TRANSACTIONAL,
      mutations: [mutation]
    )
    dataset.service.mocked_datastore.expect :commit, commit_res, [commit_req]

    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test"
      e["name"] = "thingamajig"
    end
    entity.key.wont_be :complete?
    entity.wont_be :persisted?
    dataset.upsert entity
    entity.key.must_be :complete?
    entity.must_be :persisted?
  end

  it "save will persist multiple entities" do
    mutation1 = Google::Datastore::V1beta3::Mutation.new(
      upsert: Gcloud::Datastore::Entity.new.tap do |e|
        e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
        e["name"] = "thingamajig"
      end.to_grpc)
    mutation2 = Google::Datastore::V1beta3::Mutation.new(
      upsert: Gcloud::Datastore::Entity.new.tap do |e|
        e.key = Gcloud::Datastore::Key.new "ds-test", "thangie"
        e["name"] = "thungamajig"
      end.to_grpc)
    commit_req = Google::Datastore::V1beta3::CommitRequest.new(
      project_id: project,
      mode: :NON_TRANSACTIONAL,
      mutations: [mutation1, mutation2]
    )

    dataset.service.mocked_datastore.expect :commit, multiple_commit_res, [commit_req]

    entity1 = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    entity1.wont_be :persisted?
    entity2.wont_be :persisted?
    dataset.save entity1, entity2
    entity1.must_be :persisted?
    entity2.must_be :persisted?
  end

  it "save will persist multiple entities in an array" do
    mutation1 = Google::Datastore::V1beta3::Mutation.new(
      upsert: Gcloud::Datastore::Entity.new.tap do |e|
        e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
        e["name"] = "thingamajig"
      end.to_grpc)
    mutation2 = Google::Datastore::V1beta3::Mutation.new(
      upsert: Gcloud::Datastore::Entity.new.tap do |e|
        e.key = Gcloud::Datastore::Key.new "ds-test", "thangie"
        e["name"] = "thungamajig"
      end.to_grpc)
    commit_req = Google::Datastore::V1beta3::CommitRequest.new(
      project_id: project,
      mode: :NON_TRANSACTIONAL,
      mutations: [mutation1, mutation2]
    )

    dataset.service.mocked_datastore.expect :commit, multiple_commit_res, [commit_req]

    entity1 = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    entity1.wont_be :persisted?
    entity2.wont_be :persisted?
    dataset.save [entity1, entity2]
    entity1.must_be :persisted?
    entity2.must_be :persisted?
  end

  it "insert will persist complete entities" do
    # Remove key from response
    commit_res.mutation_results.first.key = nil
    mutation = Google::Datastore::V1beta3::Mutation.new(
      insert: Gcloud::Datastore::Entity.new.tap do |e|
        e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
        e["name"] = "thingamajig"
      end.to_grpc)
    commit_req = Google::Datastore::V1beta3::CommitRequest.new(
      project_id: project,
      mode: :NON_TRANSACTIONAL,
      mutations: [mutation]
    )
    dataset.service.mocked_datastore.expect :commit, commit_res, [commit_req]

    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity.key.must_be :complete?
    entity.wont_be :persisted?
    dataset.insert entity
    entity.key.must_be :complete?
    entity.must_be :persisted?
  end

  it "insert will persist incomplete entities" do
    mutation = Google::Datastore::V1beta3::Mutation.new(
      insert: Gcloud::Datastore::Entity.new.tap do |e|
        e.key = Gcloud::Datastore::Key.new "ds-test"
        e["name"] = "thingamajig"
      end.to_grpc)
    commit_req = Google::Datastore::V1beta3::CommitRequest.new(
      project_id: project,
      mode: :NON_TRANSACTIONAL,
      mutations: [mutation]
    )
    dataset.service.mocked_datastore.expect :commit, commit_res, [commit_req]

    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test"
      e["name"] = "thingamajig"
    end
    entity.key.wont_be :complete?
    entity.wont_be :persisted?
    dataset.insert entity
    entity.key.must_be :complete?
    entity.must_be :persisted?
  end

  it "insert will persist multiple entities" do
    mutation1 = Google::Datastore::V1beta3::Mutation.new(
      insert: Gcloud::Datastore::Entity.new.tap do |e|
        e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
        e["name"] = "thingamajig"
      end.to_grpc)
    mutation2 = Google::Datastore::V1beta3::Mutation.new(
      insert: Gcloud::Datastore::Entity.new.tap do |e|
        e.key = Gcloud::Datastore::Key.new "ds-test", "thangie"
        e["name"] = "thungamajig"
      end.to_grpc)
    commit_req = Google::Datastore::V1beta3::CommitRequest.new(
      project_id: project,
      mode: :NON_TRANSACTIONAL,
      mutations: [mutation1, mutation2]
    )

    dataset.service.mocked_datastore.expect :commit, multiple_commit_res, [commit_req]

    entity1 = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    entity1.wont_be :persisted?
    entity2.wont_be :persisted?
    dataset.insert entity1, entity2
    entity1.must_be :persisted?
    entity2.must_be :persisted?
  end

  it "insert will persist multiple entities in an array" do
    mutation1 = Google::Datastore::V1beta3::Mutation.new(
      insert: Gcloud::Datastore::Entity.new.tap do |e|
        e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
        e["name"] = "thingamajig"
      end.to_grpc)
    mutation2 = Google::Datastore::V1beta3::Mutation.new(
      insert: Gcloud::Datastore::Entity.new.tap do |e|
        e.key = Gcloud::Datastore::Key.new "ds-test", "thangie"
        e["name"] = "thungamajig"
      end.to_grpc)
    commit_req = Google::Datastore::V1beta3::CommitRequest.new(
      project_id: project,
      mode: :NON_TRANSACTIONAL,
      mutations: [mutation1, mutation2]
    )

    dataset.service.mocked_datastore.expect :commit, multiple_commit_res, [commit_req]

    entity1 = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    entity1.wont_be :persisted?
    entity2.wont_be :persisted?
    dataset.insert [entity1, entity2]
    entity1.must_be :persisted?
    entity2.must_be :persisted?
  end

  it "update will persist entities" do
    # Remove key from response
    commit_res.mutation_results.first.key = nil
    mutation = Google::Datastore::V1beta3::Mutation.new(
      update: Gcloud::Datastore::Entity.new.tap do |e|
        e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
        e["name"] = "thingamajig"
      end.to_grpc)
    commit_req = Google::Datastore::V1beta3::CommitRequest.new(
      project_id: project,
      mode: :NON_TRANSACTIONAL,
      mutations: [mutation]
    )
    dataset.service.mocked_datastore.expect :commit, commit_res, [commit_req]

    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity.key.must_be :complete?
    entity.wont_be :persisted?
    dataset.update entity
    entity.key.must_be :complete?
    entity.must_be :persisted?
  end

  it "update will persist multiple entities" do
    # Remove keys from response
    multiple_commit_res.mutation_results.each { |m| m.key = nil }
    mutation1 = Google::Datastore::V1beta3::Mutation.new(
      update: Gcloud::Datastore::Entity.new.tap do |e|
        e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
        e["name"] = "thingamajig"
      end.to_grpc)
    mutation2 = Google::Datastore::V1beta3::Mutation.new(
      update: Gcloud::Datastore::Entity.new.tap do |e|
        e.key = Gcloud::Datastore::Key.new "ds-test", "thangie"
        e["name"] = "thungamajig"
      end.to_grpc)
    commit_req = Google::Datastore::V1beta3::CommitRequest.new(
      project_id: project,
      mode: :NON_TRANSACTIONAL,
      mutations: [mutation1, mutation2]
    )

    dataset.service.mocked_datastore.expect :commit, multiple_commit_res, [commit_req]

    entity1 = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    entity1.wont_be :persisted?
    entity2.wont_be :persisted?
    dataset.update entity1, entity2
    entity1.must_be :persisted?
    entity2.must_be :persisted?
  end

  it "update will persist multiple entities in an array" do
    # Remove keys from response
    multiple_commit_res.mutation_results.each { |m| m.key = nil }
    mutation1 = Google::Datastore::V1beta3::Mutation.new(
      update: Gcloud::Datastore::Entity.new.tap do |e|
        e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
        e["name"] = "thingamajig"
      end.to_grpc)
    mutation2 = Google::Datastore::V1beta3::Mutation.new(
      update: Gcloud::Datastore::Entity.new.tap do |e|
        e.key = Gcloud::Datastore::Key.new "ds-test", "thangie"
        e["name"] = "thungamajig"
      end.to_grpc)
    commit_req = Google::Datastore::V1beta3::CommitRequest.new(
      project_id: project,
      mode: :NON_TRANSACTIONAL,
      mutations: [mutation1, mutation2]
    )

    dataset.service.mocked_datastore.expect :commit, multiple_commit_res, [commit_req]

    entity1 = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    entity1.wont_be :persisted?
    entity2.wont_be :persisted?
    dataset.update [entity1, entity2]
    entity1.must_be :persisted?
    entity2.must_be :persisted?
  end

  it "find can take a kind and id" do
    lookup_req = Google::Datastore::V1beta3::LookupRequest.new(
      project_id: project,
      keys: [Gcloud::Datastore::Key.new("ds-test", 123).to_grpc]
    )
    dataset.service.mocked_datastore.expect :lookup, lookup_res, [lookup_req]

    entity = dataset.find "ds-test", 123
    entity.must_be_kind_of Gcloud::Datastore::Entity
  end

  it "find can take a kind and name" do
    lookup_req = Google::Datastore::V1beta3::LookupRequest.new(
      project_id: project,
      keys: [Gcloud::Datastore::Key.new("ds-test", "thingie").to_grpc]
    )
    dataset.service.mocked_datastore.expect :lookup, lookup_res, [lookup_req]

    entity = dataset.find "ds-test", "thingie"
    entity.must_be_kind_of Gcloud::Datastore::Entity
  end

  it "find can take a key" do
    lookup_req = Google::Datastore::V1beta3::LookupRequest.new(
      project_id: project,
      keys: [Gcloud::Datastore::Key.new("ds-test", "thingie").to_grpc]
    )
    dataset.service.mocked_datastore.expect :lookup, lookup_res, [lookup_req]

    key = Gcloud::Datastore::Key.new "ds-test", "thingie"
    entity = dataset.find key
    entity.must_be_kind_of Gcloud::Datastore::Entity
  end

  it "find is aliased to get" do
    lookup_req = Google::Datastore::V1beta3::LookupRequest.new(
      project_id: project,
      keys: [Gcloud::Datastore::Key.new("ds-test", 123).to_grpc]
    )
    dataset.service.mocked_datastore.expect :lookup, lookup_res, [lookup_req]

    entity = dataset.get "ds-test", 123
    entity.must_be_kind_of Gcloud::Datastore::Entity
  end

  it "find can specify consistency" do
    lookup_req = Google::Datastore::V1beta3::LookupRequest.new(
      project_id: project,
      keys: [Gcloud::Datastore::Key.new("ds-test", 123).to_grpc],
      read_options: Google::Datastore::V1beta3::ReadOptions.new(read_consistency: :EVENTUAL)
    )
    dataset.service.mocked_datastore.expect :lookup, lookup_res, [lookup_req]

    entity = dataset.find "ds-test", 123, consistency: :eventual
    entity.must_be_kind_of Gcloud::Datastore::Entity
  end

  it "find raises if consistency is a bad value" do
    error = expect do
      dataset.find "ds-test", 123, consistency: "foobar"
    end.must_raise ArgumentError
    error.message.must_equal "Consistency must be :eventual or :strong, not \"foobar\"."
  end

  it "find_all takes several keys" do
    lookup_req = Google::Datastore::V1beta3::LookupRequest.new(
      project_id: project,
      keys: [Gcloud::Datastore::Key.new("ds-test", "thingie1").to_grpc,
             Gcloud::Datastore::Key.new("ds-test", "thingie2").to_grpc]
    )
    dataset.service.mocked_datastore.expect :lookup, lookup_res, [lookup_req]

    key1 = Gcloud::Datastore::Key.new "ds-test", "thingie1"
    key2 = Gcloud::Datastore::Key.new "ds-test", "thingie2"
    entities = dataset.find_all key1, key2
    entities.count.must_equal 2
    entities.deferred.count.must_equal 0
    entities.missing.count.must_equal 0
    entities.each do |entity|
      entity.must_be_kind_of Gcloud::Datastore::Entity
    end
  end

  it "find_all is aliased to lookup" do
    lookup_req = Google::Datastore::V1beta3::LookupRequest.new(
      project_id: project,
      keys: [Gcloud::Datastore::Key.new("ds-test", "thingie1").to_grpc,
             Gcloud::Datastore::Key.new("ds-test", "thingie2").to_grpc]
    )
    dataset.service.mocked_datastore.expect :lookup, lookup_res, [lookup_req]

    key1 = Gcloud::Datastore::Key.new "ds-test", "thingie1"
    key2 = Gcloud::Datastore::Key.new "ds-test", "thingie2"
    entities = dataset.lookup key1, key2
    entities.count.must_equal 2
    entities.deferred.count.must_equal 0
    entities.missing.count.must_equal 0
    entities.each do |entity|
      entity.must_be_kind_of Gcloud::Datastore::Entity
    end
  end

  it "find_all can specify consistency" do
    lookup_req = Google::Datastore::V1beta3::LookupRequest.new(
      project_id: project,
      keys: [Gcloud::Datastore::Key.new("ds-test", "thingie1").to_grpc,
             Gcloud::Datastore::Key.new("ds-test", "thingie2").to_grpc],
      read_options: Google::Datastore::V1beta3::ReadOptions.new(read_consistency: :EVENTUAL)
    )
    dataset.service.mocked_datastore.expect :lookup, lookup_res, [lookup_req]

    key1 = Gcloud::Datastore::Key.new "ds-test", "thingie1"
    key2 = Gcloud::Datastore::Key.new "ds-test", "thingie2"
    entities = dataset.lookup key1, key2, consistency: :eventual
    entities.count.must_equal 2
    entities.deferred.count.must_equal 0
    entities.missing.count.must_equal 0
    entities.each do |entity|
      entity.must_be_kind_of Gcloud::Datastore::Entity
    end
  end

  it "find_all raises if consistency is a bad value" do
    error = expect do
      key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      entities = dataset.lookup key, key, consistency: "foobar"
    end.must_raise ArgumentError
    error.message.must_equal "Consistency must be :eventual or :strong, not \"foobar\"."
  end

  describe "find_all result object" do
    let(:lookup_res_deferred) do
      lookup_res.tap do |response|
        2.times.map do
          response.deferred << Gcloud::Datastore::Key.new("ds-test", "thingie").to_grpc
        end
      end
    end

    let(:lookup_res_missing) do
      lookup_res.tap do |response|
        2.times.map do
          response.missing << Google::Datastore::V1beta3::EntityResult.new(
            entity:  Gcloud::Datastore::Entity.new.tap do |e|
              e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
              e["name"] = "thingamajig"
            end.to_grpc
          )
        end
      end
    end

    it "contains deferred entities" do
      lookup_req = Google::Datastore::V1beta3::LookupRequest.new(
        project_id: project,
        keys: [Gcloud::Datastore::Key.new("ds-test", "thingie1").to_grpc,
               Gcloud::Datastore::Key.new("ds-test", "thingie2").to_grpc]
      )
      dataset.service.mocked_datastore.expect :lookup, lookup_res_deferred, [lookup_req]

      key1 = Gcloud::Datastore::Key.new "ds-test", "thingie1"
      key2 = Gcloud::Datastore::Key.new "ds-test", "thingie2"
      entities = dataset.find_all key1, key2
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
      lookup_req = Google::Datastore::V1beta3::LookupRequest.new(
        project_id: project,
        keys: [Gcloud::Datastore::Key.new("ds-test", "thingie1").to_grpc,
               Gcloud::Datastore::Key.new("ds-test", "thingie2").to_grpc]
      )
      dataset.service.mocked_datastore.expect :lookup, lookup_res_missing, [lookup_req]

      key1 = Gcloud::Datastore::Key.new "ds-test", "thingie1"
      key2 = Gcloud::Datastore::Key.new "ds-test", "thingie2"
      entities = dataset.find_all key1, key2
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
    mutation = Google::Datastore::V1beta3::Mutation.new(
      delete: Gcloud::Datastore::Key.new("ds-test", "thingie").to_grpc
    )
    commit_req = Google::Datastore::V1beta3::CommitRequest.new(
      project_id: project,
      mode: :NON_TRANSACTIONAL,
      mutations: [mutation]
    )
    dataset.service.mocked_datastore.expect :commit, commit_res, [commit_req]

    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    dataset.delete entity
  end

  it "delete with multiple entity will call commit" do
    mutation1 = Google::Datastore::V1beta3::Mutation.new(
      delete: Gcloud::Datastore::Key.new("ds-test", "thingie").to_grpc)
    mutation2 = Google::Datastore::V1beta3::Mutation.new(
      delete: Gcloud::Datastore::Key.new("ds-test", "thangie").to_grpc)
    commit_req = Google::Datastore::V1beta3::CommitRequest.new(
      project_id: project,
      mode: :NON_TRANSACTIONAL,
      mutations: [mutation1, mutation2]
    )

    dataset.service.mocked_datastore.expect :commit, multiple_commit_res, [commit_req]

    entity1 = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    dataset.delete entity1, entity2
  end

  it "delete with multiple entity in an array will call commit" do
    mutation1 = Google::Datastore::V1beta3::Mutation.new(
      delete: Gcloud::Datastore::Key.new("ds-test", "thingie").to_grpc)
    mutation2 = Google::Datastore::V1beta3::Mutation.new(
      delete: Gcloud::Datastore::Key.new("ds-test", "thangie").to_grpc)
    commit_req = Google::Datastore::V1beta3::CommitRequest.new(
      project_id: project,
      mode: :NON_TRANSACTIONAL,
      mutations: [mutation1, mutation2]
    )

    dataset.service.mocked_datastore.expect :commit, multiple_commit_res, [commit_req]

    entity1 = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    dataset.delete [entity1, entity2]
  end

  it "delete with key will call commit" do
    mutation = Google::Datastore::V1beta3::Mutation.new(
      delete: Gcloud::Datastore::Key.new("ds-test", "thingie").to_grpc
    )
    commit_req = Google::Datastore::V1beta3::CommitRequest.new(
      project_id: project,
      mode: :NON_TRANSACTIONAL,
      mutations: [mutation]
    )
    dataset.service.mocked_datastore.expect :commit, commit_res, [commit_req]

    key = Gcloud::Datastore::Key.new "ds-test", "thingie"
    dataset.delete key
  end

  it "delete with multiple keys will call commit" do
    mutation1 = Google::Datastore::V1beta3::Mutation.new(
      delete: Gcloud::Datastore::Key.new("ds-test", "thingie").to_grpc)
    mutation2 = Google::Datastore::V1beta3::Mutation.new(
      delete: Gcloud::Datastore::Key.new("ds-test", "thangie").to_grpc)
    commit_req = Google::Datastore::V1beta3::CommitRequest.new(
      project_id: project,
      mode: :NON_TRANSACTIONAL,
      mutations: [mutation1, mutation2]
    )

    dataset.service.mocked_datastore.expect :commit, multiple_commit_res, [commit_req]

    entity1 = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    dataset.delete entity1.key, entity2.key
  end

  it "delete with multiple keys in an array will call commit" do
    mutation1 = Google::Datastore::V1beta3::Mutation.new(
      delete: Gcloud::Datastore::Key.new("ds-test", "thingie").to_grpc)
    mutation2 = Google::Datastore::V1beta3::Mutation.new(
      delete: Gcloud::Datastore::Key.new("ds-test", "thangie").to_grpc)
    commit_req = Google::Datastore::V1beta3::CommitRequest.new(
      project_id: project,
      mode: :NON_TRANSACTIONAL,
      mutations: [mutation1, mutation2]
    )

    dataset.service.mocked_datastore.expect :commit, multiple_commit_res, [commit_req]

    entity1 = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
      e["name"] = "thingamajig"
    end
    entity2 = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "thangie"
      e["name"] = "thungamajig"
    end
    dataset.delete [entity1.key, entity2.key]
  end

  it "run will fulfill a query" do
    run_query_req = Google::Datastore::V1beta3::RunQueryRequest.new(
      project_id: project,
      query: Gcloud::Datastore::Query.new.kind("User").to_grpc
    )
    dataset.service.mocked_datastore.expect :run_query, run_query_res, [run_query_req]

    query = Gcloud::Datastore::Query.new.kind("User")
    entities = dataset.run query
    entities.count.must_equal 2
    entities.each do |entity|
      entity.must_be_kind_of Gcloud::Datastore::Entity
    end
    entities.cursor_for(entities.first).must_equal Gcloud::Datastore::Cursor.from_grpc("result-cursor-0")
    entities.cursor_for(entities.last).must_equal  Gcloud::Datastore::Cursor.from_grpc("result-cursor-1")
    entities.cursor.must_equal query_cursor
    entities.end_cursor.must_equal query_cursor
    entities.more_results.must_equal :MORE_RESULTS_TYPE_UNSPECIFIED
    refute entities.not_finished?
    refute entities.more_after_limit?
    refute entities.more_after_cursor?
    refute entities.no_more?
  end

  it "commit will save and delete entities" do
    mutations = [Google::Datastore::V1beta3::Mutation.new(
      upsert: Gcloud::Datastore::Entity.new.tap do |e|
        e.key = Gcloud::Datastore::Key.new "ds-test", "to-be-saved"
        e["name"] = "Gonna be saved"
      end.to_grpc), Google::Datastore::V1beta3::Mutation.new(
        delete: Gcloud::Datastore::Key.new("ds-test", "to-be-deleted").to_grpc)
    ]
    commit_req = Google::Datastore::V1beta3::CommitRequest.new(
      project_id: project,
      mode: :NON_TRANSACTIONAL,
      mutations: mutations
    )
    dataset.service.mocked_datastore.expect :commit, commit_res, [commit_req]

    entity_to_be_saved = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "to-be-saved"
      e["name"] = "Gonna be saved"
    end
    entity_to_be_deleted = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test", "to-be-deleted"
      e["name"] = "Gonna be deleted"
    end

    entity_to_be_saved.wont_be :persisted?
    dataset.commit do |c|
      c.save entity_to_be_saved
      c.delete entity_to_be_deleted
    end
    entity_to_be_saved.must_be :persisted?
  end

  it "run_query will fulfill a query" do
    run_query_req = Google::Datastore::V1beta3::RunQueryRequest.new(
      project_id: project,
      query: Gcloud::Datastore::Query.new.kind("User").to_grpc
    )
    dataset.service.mocked_datastore.expect :run_query, run_query_res, [run_query_req]

    query = Gcloud::Datastore::Query.new.kind("User")
    entities = dataset.run_query query
    entities.count.must_equal 2
    entities.each do |entity|
      entity.must_be_kind_of Gcloud::Datastore::Entity
    end
    entities.cursor_for(entities.first).must_equal Gcloud::Datastore::Cursor.from_grpc("result-cursor-0")
    entities.cursor_for(entities.last).must_equal  Gcloud::Datastore::Cursor.from_grpc("result-cursor-1")
    entities.cursor.must_equal query_cursor
    entities.more_results.must_equal :MORE_RESULTS_TYPE_UNSPECIFIED
    refute entities.not_finished?
    refute entities.more_after_limit?
    refute entities.more_after_cursor?
    refute entities.no_more?
  end

  it "run_query will fulfill a query with a namespace" do
    run_query_req = Google::Datastore::V1beta3::RunQueryRequest.new(
      project_id: project,
      partition_id: Google::Datastore::V1beta3::PartitionId.new(
        namespace_id: "foobar"
      ),
      query: Gcloud::Datastore::Query.new.kind("User").to_grpc
    )
    dataset.service.mocked_datastore.expect :run_query, run_query_res, [run_query_req]

    query = Gcloud::Datastore::Query.new.kind("User")
    entities = dataset.run_query query, namespace: "foobar"
    entities.count.must_equal 2
    entities.each do |entity|
      entity.must_be_kind_of Gcloud::Datastore::Entity
    end
    entities.cursor_for(entities.first).must_equal Gcloud::Datastore::Cursor.from_grpc("result-cursor-0")
    entities.cursor_for(entities.last).must_equal  Gcloud::Datastore::Cursor.from_grpc("result-cursor-1")
    entities.cursor.must_equal query_cursor
    entities.more_results.must_equal :MORE_RESULTS_TYPE_UNSPECIFIED
    refute entities.not_finished?
    refute entities.more_after_limit?
    refute entities.more_after_cursor?
    refute entities.no_more?
  end

  it "run will fulfill a gql query" do
    run_query_req = Google::Datastore::V1beta3::RunQueryRequest.new(
      project_id: project,
      gql_query: Google::Datastore::V1beta3::GqlQuery.new(
        query_string: "SELECT * FROM Task")
    )
    dataset.service.mocked_datastore.expect :run_query, run_query_res, [run_query_req]

    gql = dataset.gql "SELECT * FROM Task"
    entities = dataset.run gql
    entities.count.must_equal 2
    entities.each do |entity|
      entity.must_be_kind_of Gcloud::Datastore::Entity
    end
    entities.cursor_for(entities.first).must_equal Gcloud::Datastore::Cursor.from_grpc("result-cursor-0")
    entities.cursor_for(entities.last).must_equal  Gcloud::Datastore::Cursor.from_grpc("result-cursor-1")
    entities.cursor.must_equal query_cursor
    entities.end_cursor.must_equal query_cursor
    entities.more_results.must_equal :MORE_RESULTS_TYPE_UNSPECIFIED
    refute entities.not_finished?
    refute entities.more_after_limit?
    refute entities.more_after_cursor?
    refute entities.no_more?
  end

  it "run will fulfill a gql query with a namespace" do
    run_query_req = Google::Datastore::V1beta3::RunQueryRequest.new(
      project_id: project,
      partition_id: Google::Datastore::V1beta3::PartitionId.new(
        namespace_id: "foobar"
      ),
      gql_query: Google::Datastore::V1beta3::GqlQuery.new(
        query_string: "SELECT * FROM Task")
    )
    dataset.service.mocked_datastore.expect :run_query, run_query_res, [run_query_req]

    gql = dataset.gql "SELECT * FROM Task"
    entities = dataset.run gql, namespace: "foobar"
    entities.count.must_equal 2
    entities.each do |entity|
      entity.must_be_kind_of Gcloud::Datastore::Entity
    end
    entities.cursor_for(entities.first).must_equal Gcloud::Datastore::Cursor.from_grpc("result-cursor-0")
    entities.cursor_for(entities.last).must_equal  Gcloud::Datastore::Cursor.from_grpc("result-cursor-1")
    entities.cursor.must_equal query_cursor
    entities.end_cursor.must_equal query_cursor
    entities.more_results.must_equal :MORE_RESULTS_TYPE_UNSPECIFIED
    refute entities.not_finished?
    refute entities.more_after_limit?
    refute entities.more_after_cursor?
    refute entities.no_more?
  end

  it "run_query will fulfill a gql query" do
    run_query_req = Google::Datastore::V1beta3::RunQueryRequest.new(
      project_id: project,
      gql_query: Google::Datastore::V1beta3::GqlQuery.new(
        query_string: "SELECT * FROM Task")
    )
    dataset.service.mocked_datastore.expect :run_query, run_query_res, [run_query_req]

    gql = dataset.gql "SELECT * FROM Task"
    entities = dataset.run_query gql
    entities.count.must_equal 2
    entities.each do |entity|
      entity.must_be_kind_of Gcloud::Datastore::Entity
    end
    entities.cursor_for(entities.first).must_equal Gcloud::Datastore::Cursor.from_grpc("result-cursor-0")
    entities.cursor_for(entities.last).must_equal  Gcloud::Datastore::Cursor.from_grpc("result-cursor-1")
    entities.cursor.must_equal query_cursor
    entities.end_cursor.must_equal query_cursor
    entities.more_results.must_equal :MORE_RESULTS_TYPE_UNSPECIFIED
    refute entities.not_finished?
    refute entities.more_after_limit?
    refute entities.more_after_cursor?
    refute entities.no_more?
  end

  it "run_query will fulfill a gql query with a namespace" do
    run_query_req = Google::Datastore::V1beta3::RunQueryRequest.new(
      project_id: project,
      partition_id: Google::Datastore::V1beta3::PartitionId.new(
        namespace_id: "foobar"
      ),
      gql_query: Google::Datastore::V1beta3::GqlQuery.new(
        query_string: "SELECT * FROM Task")
    )
    dataset.service.mocked_datastore.expect :run_query, run_query_res, [run_query_req]

    gql = dataset.gql "SELECT * FROM Task"
    entities = dataset.run_query gql, namespace: "foobar"
    entities.count.must_equal 2
    entities.each do |entity|
      entity.must_be_kind_of Gcloud::Datastore::Entity
    end
    entities.cursor_for(entities.first).must_equal Gcloud::Datastore::Cursor.from_grpc("result-cursor-0")
    entities.cursor_for(entities.last).must_equal  Gcloud::Datastore::Cursor.from_grpc("result-cursor-1")
    entities.cursor.must_equal query_cursor
    entities.end_cursor.must_equal query_cursor
    entities.more_results.must_equal :MORE_RESULTS_TYPE_UNSPECIFIED
    refute entities.not_finished?
    refute entities.more_after_limit?
    refute entities.more_after_cursor?
    refute entities.no_more?
  end

  it "run will fulfill a query and return an object that can paginate" do
    first_run_query_req = Google::Datastore::V1beta3::RunQueryRequest.new(
      project_id: project,
      partition_id: Google::Datastore::V1beta3::PartitionId.new(
        namespace_id: "foobar"
      ),
      gql_query: Google::Datastore::V1beta3::GqlQuery.new(
        query_string: "SELECT * FROM Task")
    )
    first_run_query_res = run_query_res.dup
    first_run_query_res.batch = run_query_res.batch.dup
    first_run_query_res.batch.more_results = :MORE_RESULTS_AFTER_CURSOR
    first_run_query_res.query = Gcloud::Datastore::Query.new.kind("Task").to_grpc
    next_run_query_req = Google::Datastore::V1beta3::RunQueryRequest.new(
      project_id: project,
      partition_id: Google::Datastore::V1beta3::PartitionId.new(
        namespace_id: "foobar"
      ),
      query: Gcloud::Datastore::Query.new.kind("Task").start(query_cursor).to_grpc
    )
    next_run_query_res = run_query_res.dup
    next_run_query_res.batch = run_query_res.batch.dup
    next_run_query_res.batch.more_results = :NO_MORE_RESULTS
    dataset.service.mocked_datastore.expect :run_query, first_run_query_res, [first_run_query_req]
    dataset.service.mocked_datastore.expect :run_query, next_run_query_res, [next_run_query_req]

    gql = dataset.gql "SELECT * FROM Task"
    entities = dataset.run_query gql, namespace: "foobar"
    entities.count.must_equal 2
    entities.each do |entity|
      entity.must_be_kind_of Gcloud::Datastore::Entity
    end
    entities.cursor_for(entities.first).must_equal Gcloud::Datastore::Cursor.from_grpc("result-cursor-0")
    entities.cursor_for(entities.last).must_equal  Gcloud::Datastore::Cursor.from_grpc("result-cursor-1")
    entities.cursor.must_equal query_cursor
    entities.end_cursor.must_equal query_cursor
    entities.more_results.must_equal :MORE_RESULTS_AFTER_CURSOR
    refute entities.not_finished?
    refute entities.more_after_limit?
    assert entities.more_after_cursor?
    refute entities.no_more?

    assert entities.next?
    next_entities = entities.next

    next_entities.each do |entity|
      entity.must_be_kind_of Gcloud::Datastore::Entity
    end
    next_entities.cursor_for(next_entities.first).must_equal Gcloud::Datastore::Cursor.from_grpc("result-cursor-0")
    next_entities.cursor_for(next_entities.last).must_equal  Gcloud::Datastore::Cursor.from_grpc("result-cursor-1")
    next_entities.cursor.must_equal query_cursor
    next_entities.end_cursor.must_equal query_cursor
    next_entities.more_results.must_equal :NO_MORE_RESULTS
    refute next_entities.not_finished?
    refute next_entities.more_after_limit?
    refute next_entities.more_after_cursor?
    assert next_entities.no_more?

    refute next_entities.next?
  end

  it "run will fulfill a query and return an object that can paginate with all" do
    first_run_query_req = Google::Datastore::V1beta3::RunQueryRequest.new(
      project_id: project,
      partition_id: Google::Datastore::V1beta3::PartitionId.new(
        namespace_id: "foobar"
      ),
      gql_query: Google::Datastore::V1beta3::GqlQuery.new(
        query_string: "SELECT * FROM Task")
    )
    first_run_query_res = run_query_res.dup
    first_run_query_res.batch = run_query_res.batch.dup
    first_run_query_res.batch.more_results = :MORE_RESULTS_AFTER_CURSOR
    first_run_query_res.query = Gcloud::Datastore::Query.new.kind("Task").to_grpc
    next_run_query_req = Google::Datastore::V1beta3::RunQueryRequest.new(
      project_id: project,
      partition_id: Google::Datastore::V1beta3::PartitionId.new(
        namespace_id: "foobar"
      ),
      query: Gcloud::Datastore::Query.new.kind("Task").start(query_cursor).to_grpc
    )
    next_run_query_res = run_query_res.dup
    next_run_query_res.batch = run_query_res.batch.dup
    next_run_query_res.batch.more_results = :NO_MORE_RESULTS
    dataset.service.mocked_datastore.expect :run_query, first_run_query_res, [first_run_query_req]
    dataset.service.mocked_datastore.expect :run_query, next_run_query_res, [next_run_query_req]

    gql = dataset.gql "SELECT * FROM Task"
    entities = dataset.run_query gql, namespace: "foobar"
    entities.all
    entities.count.must_equal 4
    entities.each do |entity|
      entity.must_be_kind_of Gcloud::Datastore::Entity
    end
    entities.cursor.must_equal query_cursor
    entities.end_cursor.must_equal query_cursor
    entities.more_results.must_equal :NO_MORE_RESULTS
    refute entities.not_finished?
    refute entities.more_after_limit?
    refute entities.more_after_cursor?
    assert entities.no_more?

    refute entities.next?
  end

  it "run will raise when given an unknown argument" do
    expect do
      entities = dataset.run 123
    end.must_raise ArgumentError
  end

  it "query returns a Query instance" do
    query = dataset.query "Task"
    query.must_be_kind_of Gcloud::Datastore::Query

    grpc = query.to_grpc
    grpc.kind.map(&:name).must_include "Task"
    grpc.kind.map(&:name).wont_include "User"

    # Add a second kind to the query
    query.kind "User"

    grpc = query.to_grpc
    grpc.kind.map(&:name).must_include "Task"
    grpc.kind.map(&:name).must_include "User"
  end

  it "key returns a Key instance" do
    key = dataset.key "ThisThing", 1234
    key.must_be_kind_of Gcloud::Datastore::Key
    key.kind.must_equal "ThisThing"
    key.id.must_equal 1234
    key.name.must_be :nil?

    key = dataset.key "ThisThing", "charlie"
    key.must_be_kind_of Gcloud::Datastore::Key
    key.kind.must_equal "ThisThing"
    key.id.must_be :nil?
    key.name.must_equal "charlie"
  end

  it "key sets a parent and grandparent in the constructor" do
    path = [["OtherThing", "root"], ["ThatThing", 6789], ["ThisThing", 1234]]
    key = dataset.key path, project: "custom-ds", namespace: "custom-ns"
    key.kind.must_equal "ThisThing"
    key.id.must_equal 1234
    key.name.must_be :nil?
    key.path.must_equal [["OtherThing", "root"], ["ThatThing", 6789], ["ThisThing", 1234]]
    key.project.must_equal "custom-ds"
    key.namespace.must_equal "custom-ns"

    key.parent.wont_be :nil?
    key.parent.kind.must_equal "ThatThing"
    key.parent.id.must_equal 6789
    key.parent.name.must_be :nil?
    key.parent.path.must_equal [["OtherThing", "root"], ["ThatThing", 6789]]
    key.parent.project.must_equal "custom-ds"
    key.parent.namespace.must_equal "custom-ns"

    key.parent.parent.wont_be :nil?
    key.parent.parent.kind.must_equal "OtherThing"
    key.parent.parent.id.must_be :nil?
    key.parent.parent.name.must_equal "root"
    key.parent.parent.path.must_equal [["OtherThing", "root"]]
    key.parent.parent.project.must_equal "custom-ds"
    key.parent.parent.namespace.must_equal "custom-ns"
  end

  it "entity returns an Entity instance" do
    entity = dataset.entity
    entity.must_be_kind_of Gcloud::Datastore::Entity
  end

  it "entity sets the Key's kind for the new Entity" do
    entity = dataset.entity "User"
    entity.must_be_kind_of Gcloud::Datastore::Entity
    entity.key.kind.must_equal "User"
    entity.key.id.must_be :nil?
    entity.key.name.must_be :nil?
  end

  it "entity sets the Key's kind and id for the new Entity" do
    entity = dataset.entity "User", 123
    entity.must_be_kind_of Gcloud::Datastore::Entity
    entity.key.kind.must_equal "User"
    entity.key.id.must_equal 123
    entity.key.name.must_be :nil?
  end

  it "entity sets the Key's kind and name for the new Entity" do
    entity = dataset.entity "User", "username"
    entity.must_be_kind_of Gcloud::Datastore::Entity
    entity.key.kind.must_equal "User"
    entity.key.id.must_be :nil?
    entity.key.name.must_equal "username"
  end

  it "entity sets the Key object for the new Entity" do
    key = dataset.key "User", "username"
    entity = dataset.entity key
    entity.must_be_kind_of Gcloud::Datastore::Entity
    entity.key.kind.must_equal "User"
    entity.key.id.must_be :nil?
    entity.key.name.must_equal "username"
  end

  it "entity sets a key's parent and grandparent" do
    path = [["OtherThing", "root"], ["ThatThing", 6789], ["ThisThing", 1234]]
    entity = dataset.entity path, project: "custom-ds", namespace: "custom-ns"
    entity.key.kind.must_equal "ThisThing"
    entity.key.id.must_equal 1234
    entity.key.name.must_be :nil?
    entity.key.path.must_equal [["OtherThing", "root"], ["ThatThing", 6789], ["ThisThing", 1234]]
    entity.key.project.must_equal "custom-ds"
    entity.key.namespace.must_equal "custom-ns"

    entity.key.parent.wont_be :nil?
    entity.key.parent.kind.must_equal "ThatThing"
    entity.key.parent.id.must_equal 6789
    entity.key.parent.name.must_be :nil?
    entity.key.parent.path.must_equal [["OtherThing", "root"], ["ThatThing", 6789]]
    entity.key.parent.project.must_equal "custom-ds"
    entity.key.parent.namespace.must_equal "custom-ns"

    entity.key.parent.parent.wont_be :nil?
    entity.key.parent.parent.kind.must_equal "OtherThing"
    entity.key.parent.parent.id.must_be :nil?
    entity.key.parent.parent.name.must_equal "root"
    entity.key.parent.parent.path.must_equal [["OtherThing", "root"]]
    entity.key.parent.parent.project.must_equal "custom-ds"
    entity.key.parent.parent.namespace.must_equal "custom-ns"
  end


  it "entity can configure the new Entity using a block" do
    entity = dataset.entity "User", "username" do |e|
      e["name"] = "User McUser"
      e["email"] = "user@example.net"
    end
    entity.must_be_kind_of Gcloud::Datastore::Entity
    entity.key.kind.must_equal "User"
    entity.key.id.must_be :nil?
    entity.key.name.must_equal "username"
    entity.properties["name"].must_equal "User McUser"
    entity.properties["email"].must_equal "user@example.net"
  end

  describe "query result object" do
    let(:run_query_res_not_finished) do
      run_query_res.tap do |response|
        response.batch.more_results = :NOT_FINISHED
      end
    end
    let(:run_query_res_more_after_limit) do
      run_query_res.tap do |response|
        response.batch.more_results = :MORE_RESULTS_AFTER_LIMIT
      end
    end
    let(:run_query_res_more_after_cursor) do
      run_query_res.tap do |response|
        response.batch.more_results = :MORE_RESULTS_AFTER_CURSOR
      end
    end
    let(:run_query_res_no_more) do
      run_query_res.tap do |response|
        response.batch.more_results = :NO_MORE_RESULTS
      end
    end

    it "has more_results not_finished" do
      run_query_req = Google::Datastore::V1beta3::RunQueryRequest.new(
        project_id: project,
        query: Gcloud::Datastore::Query.new.kind("User").to_grpc
      )
      dataset.service.mocked_datastore.expect :run_query, run_query_res_not_finished, [run_query_req]

      query = Gcloud::Datastore::Query.new.kind("User")
      entities = dataset.run query
      entities.count.must_equal 2
      entities.each do |entity|
        entity.must_be_kind_of Gcloud::Datastore::Entity
      end
      entities.cursor.must_equal query_cursor
      entities.more_results.must_equal :NOT_FINISHED
      assert entities.not_finished?
      refute entities.more_after_limit?
      refute entities.more_after_cursor?
      refute entities.no_more?
    end

    it "has more_results more_after_limit" do
      run_query_req = Google::Datastore::V1beta3::RunQueryRequest.new(
        project_id: project,
        query: Gcloud::Datastore::Query.new.kind("User").to_grpc
      )
      dataset.service.mocked_datastore.expect :run_query, run_query_res_more_after_limit, [run_query_req]

      query = Gcloud::Datastore::Query.new.kind("User")
      entities = dataset.run query
      entities.count.must_equal 2
      entities.each do |entity|
        entity.must_be_kind_of Gcloud::Datastore::Entity
      end
      entities.cursor.must_equal query_cursor
      entities.more_results.must_equal :MORE_RESULTS_AFTER_LIMIT
      refute entities.not_finished?
      assert entities.more_after_limit?
      refute entities.more_after_cursor?
      refute entities.no_more?
    end

    it "has more_results more_after_cursor" do
      run_query_req = Google::Datastore::V1beta3::RunQueryRequest.new(
        project_id: project,
        query: Gcloud::Datastore::Query.new.kind("User").to_grpc
      )
      dataset.service.mocked_datastore.expect :run_query, run_query_res_more_after_cursor, [run_query_req]

      query = Gcloud::Datastore::Query.new.kind("User")
      entities = dataset.run query
      entities.count.must_equal 2
      entities.each do |entity|
        entity.must_be_kind_of Gcloud::Datastore::Entity
      end
      entities.cursor.must_equal query_cursor
      entities.more_results.must_equal :MORE_RESULTS_AFTER_CURSOR
      refute entities.not_finished?
      refute entities.more_after_limit?
      assert entities.more_after_cursor?
      refute entities.no_more?
    end

    it "has more_results no_more" do
      run_query_req = Google::Datastore::V1beta3::RunQueryRequest.new(
        project_id: project,
        query: Gcloud::Datastore::Query.new.kind("User").to_grpc
      )
      dataset.service.mocked_datastore.expect :run_query, run_query_res_no_more, [run_query_req]

      query = Gcloud::Datastore::Query.new.kind("User")
      entities = dataset.run query
      entities.count.must_equal 2
      entities.each do |entity|
        entity.must_be_kind_of Gcloud::Datastore::Entity
      end
      entities.cursor.must_equal query_cursor
      entities.more_results.must_equal :NO_MORE_RESULTS
      refute entities.not_finished?
      refute entities.more_after_limit?
      refute entities.more_after_cursor?
      assert entities.no_more?
    end
  end

  it "transaction will return a Transaction" do
    tx_id = "giterdone".encode("ASCII-8BIT")
    begin_tx_res = Google::Datastore::V1beta3::BeginTransactionResponse.new(transaction: tx_id)
    dataset.service.mocked_datastore.expect :begin_transaction, begin_tx_res, [Google::Datastore::V1beta3::BeginTransactionRequest]

    tx = dataset.transaction
    tx.must_be_kind_of Gcloud::Datastore::Transaction
    tx.id.must_equal "giterdone"
  end

  it "transaction will commit with a block" do
    tx_id = "giterdone".encode("ASCII-8BIT")
    begin_tx_res = Google::Datastore::V1beta3::BeginTransactionResponse.new(transaction: tx_id)
    commit_res = Google::Datastore::V1beta3::CommitResponse.new(
      mutation_results: [Google::Datastore::V1beta3::MutationResult.new(
        key: Gcloud::Datastore::Key.new("ds-test", "thingie").to_grpc
      )]
    )
    dataset.service.mocked_datastore.expect :begin_transaction, begin_tx_res, [Google::Datastore::V1beta3::BeginTransactionRequest]
    dataset.service.mocked_datastore.expect :commit, commit_res, [Google::Datastore::V1beta3::CommitRequest]

    entity = Gcloud::Datastore::Entity.new.tap do |e|
      e.key = Gcloud::Datastore::Key.new "ds-test"
      e["name"] = "thingamajig"
    end
    dataset.transaction do |tx|
      tx.save entity
    end
  end

  it "transaction will wrap errors in TransactionError" do
    tx_id = "giterdone".encode("ASCII-8BIT")
    begin_tx_res = Google::Datastore::V1beta3::BeginTransactionResponse.new(transaction: tx_id)
    rollback_res = Google::Datastore::V1beta3::RollbackResponse.new
    dataset.service.mocked_datastore.expect :begin_transaction, begin_tx_res, [Google::Datastore::V1beta3::BeginTransactionRequest]
    dataset.service.mocked_datastore.expect :rollback, rollback_res, [Google::Datastore::V1beta3::RollbackRequest]

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

  it "transaction will wrap errors for both commit and rollback" do
    # Save mocked service so we can restore it later.
    mocked_service = dataset.service
    begin
      tx_id = "giterdone".encode("ASCII-8BIT")
      begin_tx_res = Google::Datastore::V1beta3::BeginTransactionResponse.new(transaction: tx_id)

      stub = Object.new
      stub.instance_variable_set "@response", begin_tx_res
      def stub.begin_transaction
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

      entity = Gcloud::Datastore::Entity.new.tap do |e|
        e.key = Gcloud::Datastore::Key.new "ds-test", "thingie"
        e["name"] = "thingamajig"
      end

      error = assert_raises Gcloud::Datastore::TransactionError do
        dataset.transaction do |tx|
          tx.save entity
        end
      end

      error.wont_be :nil?
      error.message.must_equal "Transaction failed to commit and rollback."
      error.commit_error.wont_be :nil?
      error.commit_error.message.must_equal "commit error"
      error.rollback_error.wont_be :nil?
      error.rollback_error.message.must_equal "rollback error"
    ensure
      # Reset mocked service so the call to verify works.
      dataset.service = mocked_service
    end
  end
end
