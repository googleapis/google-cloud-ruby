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

describe Google::Cloud::Datastore::Dataset, :find_all do
  let(:project)     { "my-todo-project" }
  let(:credentials) { OpenStruct.new }
  let(:dataset)     { Google::Cloud::Datastore::Dataset.new(Google::Cloud::Datastore::Service.new(project, credentials)) }
  # let(:query_cursor) { Google::Cloud::Datastore::Cursor.new "c3VwZXJhd2Vzb21lIQ==" }

  let(:key1) { Google::Cloud::Datastore::Key.new "ds-test", "thingie1" }
  let(:key2) { Google::Cloud::Datastore::Key.new "ds-test", "thingie2" }
  let(:key3) { Google::Cloud::Datastore::Key.new "ds-test", "thingie3" }
  let(:key4) { Google::Cloud::Datastore::Key.new "ds-test", "thingie4" }
  let(:key5) { Google::Cloud::Datastore::Key.new "ds-test", "thingie5" }
  let(:key6) { Google::Cloud::Datastore::Key.new "ds-test", "thingie6" }
  let(:keys) { [key1, key2, key3, key4, key5, key6] }

  let(:first_lookup_res) do
    Google::Datastore::V1::LookupResponse.new(
      found: (1..2).map do |i|
        Google::Datastore::V1::EntityResult.new(
          entity: Google::Datastore::V1::Entity.new(
            key: Google::Cloud::Datastore::Key.new("ds-test", "thingie#{i}").to_grpc,
            properties: { "name" => Google::Cloud::Core::GRPCUtils.to_value("thingamajig") }
          )
        )
      end,
      missing: (5..6).map do |i|
        Google::Datastore::V1::EntityResult.new(
          entity: Google::Datastore::V1::Entity.new(
            key: Google::Cloud::Datastore::Key.new("ds-test", "thingie#{i}").to_grpc,
            properties: { "name" => Google::Cloud::Core::GRPCUtils.to_value("thingamajig") }
          )
        )
      end,
      deferred: (3..4).map do |i|
        Google::Cloud::Datastore::Key.new("ds-test", "thingie#{i}").to_grpc
      end
    )
  end
  let(:second_lookup_res) do
    Google::Datastore::V1::LookupResponse.new(
      found: (3..4).map do |i|
        Google::Datastore::V1::EntityResult.new(
          entity: Google::Datastore::V1::Entity.new(
            key: Google::Cloud::Datastore::Key.new("ds-test", "thingie#{i}").to_grpc,
            properties: { "name" => Google::Cloud::Core::GRPCUtils.to_value("thingamajig") }
          )
        )
      end
    )
  end

  before do
    dataset.service.mocked_datastore = Minitest::Mock.new
  end

  after do
    dataset.service.mocked_datastore.verify
  end

  it "paginates" do
    first_lookup_req = Google::Datastore::V1::LookupRequest.new(
      project_id: project,
      keys: keys.map(&:to_grpc)
    )
    second_lookup_req = Google::Datastore::V1::LookupRequest.new(
      project_id: project,
      keys: [key3, key4].map(&:to_grpc)
    )
    dataset.service.mocked_datastore.expect :lookup, first_lookup_res,  [first_lookup_req]
    dataset.service.mocked_datastore.expect :lookup, second_lookup_res, [second_lookup_req]

    first_entities = dataset.find_all keys
    first_entities.count.must_equal 2
    first_entities.deferred.count.must_equal 2
    first_entities.missing.count.must_equal 2
    first_entities.each do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end
    first_entities.deferred.each do |deferred_key|
      deferred_key.must_be_kind_of Google::Cloud::Datastore::Key
    end
    first_entities.missing.each do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end

    second_entities = dataset.find_all first_entities.deferred
    second_entities.count.must_equal 2
    second_entities.deferred.count.must_equal 0
    second_entities.missing.count.must_equal 0
    second_entities.each do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end
  end

  it "paginates with consistency" do
    first_lookup_req = Google::Datastore::V1::LookupRequest.new(
      project_id: project,
      keys: keys.map(&:to_grpc),
      read_options: Google::Datastore::V1::ReadOptions.new(read_consistency: :EVENTUAL)
    )
    second_lookup_req = Google::Datastore::V1::LookupRequest.new(
      project_id: project,
      keys: [key3, key4].map(&:to_grpc),
      read_options: Google::Datastore::V1::ReadOptions.new(read_consistency: :EVENTUAL)
    )
    dataset.service.mocked_datastore.expect :lookup, first_lookup_res,  [first_lookup_req]
    dataset.service.mocked_datastore.expect :lookup, second_lookup_res, [second_lookup_req]

    first_entities = dataset.find_all keys, consistency: :eventual
    first_entities.count.must_equal 2
    first_entities.deferred.count.must_equal 2
    first_entities.missing.count.must_equal 2
    first_entities.each do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end
    first_entities.deferred.each do |deferred_key|
      deferred_key.must_be_kind_of Google::Cloud::Datastore::Key
    end
    first_entities.missing.each do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end

    second_entities = dataset.find_all first_entities.deferred, consistency: :eventual
    second_entities.count.must_equal 2
    second_entities.deferred.count.must_equal 0
    second_entities.missing.count.must_equal 0
    second_entities.each do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end
  end

  it "paginates with transaction" do
    tx_id = "giterdone".encode("ASCII-8BIT")
    begin_tx_res = Google::Datastore::V1::BeginTransactionResponse.new(transaction: tx_id)
    commit_res = Google::Datastore::V1::CommitResponse.new(
      # mutation_results: [Google::Datastore::V1::MutationResult.new(
      #   key: Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc
      # )]
    )
    dataset.service.mocked_datastore.expect :begin_transaction, begin_tx_res, [Google::Datastore::V1::BeginTransactionRequest]
    dataset.service.mocked_datastore.expect :commit, commit_res, [Google::Datastore::V1::CommitRequest]

    first_lookup_req = Google::Datastore::V1::LookupRequest.new(
      project_id: project,
      keys: keys.map(&:to_grpc),
      read_options: Google::Datastore::V1::ReadOptions.new(transaction: tx_id)
    )
    second_lookup_req = Google::Datastore::V1::LookupRequest.new(
      project_id: project,
      keys: [key3, key4].map(&:to_grpc),
      read_options: Google::Datastore::V1::ReadOptions.new(transaction: tx_id)
    )
    dataset.service.mocked_datastore.expect :lookup, first_lookup_res,  [first_lookup_req]
    dataset.service.mocked_datastore.expect :lookup, second_lookup_res, [second_lookup_req]

    dataset.transaction do |tx|
      first_entities = tx.find_all keys
      first_entities.count.must_equal 2
      first_entities.deferred.count.must_equal 2
      first_entities.missing.count.must_equal 2
      first_entities.each do |entity|
        entity.must_be_kind_of Google::Cloud::Datastore::Entity
      end
      first_entities.deferred.each do |deferred_key|
        deferred_key.must_be_kind_of Google::Cloud::Datastore::Key
      end
      first_entities.missing.each do |entity|
        entity.must_be_kind_of Google::Cloud::Datastore::Entity
      end

      second_entities = tx.find_all first_entities.deferred
      second_entities.count.must_equal 2
      second_entities.deferred.count.must_equal 0
      second_entities.missing.count.must_equal 0
      second_entities.each do |entity|
        entity.must_be_kind_of Google::Cloud::Datastore::Entity
      end
    end
  end

  it "paginates with next? and next" do
    first_lookup_req = Google::Datastore::V1::LookupRequest.new(
      project_id: project,
      keys: keys.map(&:to_grpc)
    )
    second_lookup_req = Google::Datastore::V1::LookupRequest.new(
      project_id: project,
      keys: [key3, key4].map(&:to_grpc)
    )
    dataset.service.mocked_datastore.expect :lookup, first_lookup_res,  [first_lookup_req]
    dataset.service.mocked_datastore.expect :lookup, second_lookup_res, [second_lookup_req]

    first_entities = dataset.find_all keys
    first_entities.next?.must_equal true
    first_entities.count.must_equal 2
    first_entities.deferred.count.must_equal 2
    first_entities.missing.count.must_equal 2
    first_entities.each do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end
    first_entities.deferred.each do |deferred_key|
      deferred_key.must_be_kind_of Google::Cloud::Datastore::Key
    end
    first_entities.missing.each do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end

    second_entities = first_entities.next
    second_entities.next?.must_equal false
    second_entities.count.must_equal 2
    second_entities.deferred.count.must_equal 0
    second_entities.missing.count.must_equal 0
    second_entities.each do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end
  end

  it "paginates with next? and next and consistency" do
    first_lookup_req = Google::Datastore::V1::LookupRequest.new(
      project_id: project,
      keys: keys.map(&:to_grpc),
      read_options: Google::Datastore::V1::ReadOptions.new(read_consistency: :EVENTUAL)
    )
    second_lookup_req = Google::Datastore::V1::LookupRequest.new(
      project_id: project,
      keys: [key3, key4].map(&:to_grpc),
      read_options: Google::Datastore::V1::ReadOptions.new(read_consistency: :EVENTUAL)
    )
    dataset.service.mocked_datastore.expect :lookup, first_lookup_res,  [first_lookup_req]
    dataset.service.mocked_datastore.expect :lookup, second_lookup_res, [second_lookup_req]

    first_entities = dataset.find_all keys, consistency: :eventual
    first_entities.next?.must_equal true
    first_entities.count.must_equal 2
    first_entities.deferred.count.must_equal 2
    first_entities.missing.count.must_equal 2
    first_entities.each do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end
    first_entities.deferred.each do |deferred_key|
      deferred_key.must_be_kind_of Google::Cloud::Datastore::Key
    end
    first_entities.missing.each do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end

    second_entities = first_entities.next
    second_entities.next?.must_equal false
    second_entities.count.must_equal 2
    second_entities.deferred.count.must_equal 0
    second_entities.missing.count.must_equal 0
    second_entities.each do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end
  end

  it "paginates with next? and next and transaction" do
    tx_id = "giterdone".encode("ASCII-8BIT")
    begin_tx_res = Google::Datastore::V1::BeginTransactionResponse.new(transaction: tx_id)
    commit_res = Google::Datastore::V1::CommitResponse.new(
      # mutation_results: [Google::Datastore::V1::MutationResult.new(
      #   key: Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc
      # )]
    )
    dataset.service.mocked_datastore.expect :begin_transaction, begin_tx_res, [Google::Datastore::V1::BeginTransactionRequest]
    dataset.service.mocked_datastore.expect :commit, commit_res, [Google::Datastore::V1::CommitRequest]

    first_lookup_req = Google::Datastore::V1::LookupRequest.new(
      project_id: project,
      keys: keys.map(&:to_grpc),
      read_options: Google::Datastore::V1::ReadOptions.new(transaction: tx_id)
    )
    second_lookup_req = Google::Datastore::V1::LookupRequest.new(
      project_id: project,
      keys: [key3, key4].map(&:to_grpc),
      read_options: Google::Datastore::V1::ReadOptions.new(transaction: tx_id)
    )
    dataset.service.mocked_datastore.expect :lookup, first_lookup_res,  [first_lookup_req]
    dataset.service.mocked_datastore.expect :lookup, second_lookup_res, [second_lookup_req]

    dataset.transaction do |tx|
      first_entities = tx.find_all keys
      first_entities.next?.must_equal true
      first_entities.count.must_equal 2
      first_entities.deferred.count.must_equal 2
      first_entities.missing.count.must_equal 2
      first_entities.each do |entity|
        entity.must_be_kind_of Google::Cloud::Datastore::Entity
      end
      first_entities.deferred.each do |deferred_key|
        deferred_key.must_be_kind_of Google::Cloud::Datastore::Key
      end
      first_entities.missing.each do |entity|
        entity.must_be_kind_of Google::Cloud::Datastore::Entity
      end

      second_entities = first_entities.next
      second_entities.next?.must_equal false
      second_entities.count.must_equal 2
      second_entities.deferred.count.must_equal 0
      second_entities.missing.count.must_equal 0
      second_entities.each do |entity|
        entity.must_be_kind_of Google::Cloud::Datastore::Entity
      end
    end
  end

  it "paginates with all" do
    first_lookup_req = Google::Datastore::V1::LookupRequest.new(
      project_id: project,
      keys: keys.map(&:to_grpc)
    )
    second_lookup_req = Google::Datastore::V1::LookupRequest.new(
      project_id: project,
      keys: [key3, key4].map(&:to_grpc)
    )
    dataset.service.mocked_datastore.expect :lookup, first_lookup_res,  [first_lookup_req]
    dataset.service.mocked_datastore.expect :lookup, second_lookup_res, [second_lookup_req]

    entities = dataset.find_all(keys).all.to_a
    entities.count.must_equal 4
    entities.each do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end
  end

  it "paginates with all and consistency" do
    first_lookup_req = Google::Datastore::V1::LookupRequest.new(
      project_id: project,
      keys: keys.map(&:to_grpc),
      read_options: Google::Datastore::V1::ReadOptions.new(read_consistency: :EVENTUAL)
    )
    second_lookup_req = Google::Datastore::V1::LookupRequest.new(
      project_id: project,
      keys: [key3, key4].map(&:to_grpc),
      read_options: Google::Datastore::V1::ReadOptions.new(read_consistency: :EVENTUAL)
    )
    dataset.service.mocked_datastore.expect :lookup, first_lookup_res,  [first_lookup_req]
    dataset.service.mocked_datastore.expect :lookup, second_lookup_res, [second_lookup_req]

    entities = dataset.find_all(keys, consistency: :eventual).all.to_a
    entities.count.must_equal 4
    entities.each do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end
  end

  it "paginates with all and transaction" do
    tx_id = "giterdone".encode("ASCII-8BIT")
    begin_tx_res = Google::Datastore::V1::BeginTransactionResponse.new(transaction: tx_id)
    commit_res = Google::Datastore::V1::CommitResponse.new(
      # mutation_results: [Google::Datastore::V1::MutationResult.new(
      #   key: Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc
      # )]
    )
    dataset.service.mocked_datastore.expect :begin_transaction, begin_tx_res, [Google::Datastore::V1::BeginTransactionRequest]
    dataset.service.mocked_datastore.expect :commit, commit_res, [Google::Datastore::V1::CommitRequest]

    first_lookup_req = Google::Datastore::V1::LookupRequest.new(
      project_id: project,
      keys: keys.map(&:to_grpc),
      read_options: Google::Datastore::V1::ReadOptions.new(transaction: tx_id)
    )
    second_lookup_req = Google::Datastore::V1::LookupRequest.new(
      project_id: project,
      keys: [key3, key4].map(&:to_grpc),
      read_options: Google::Datastore::V1::ReadOptions.new(transaction: tx_id)
    )
    dataset.service.mocked_datastore.expect :lookup, first_lookup_res,  [first_lookup_req]
    dataset.service.mocked_datastore.expect :lookup, second_lookup_res, [second_lookup_req]

    dataset.transaction do |tx|
      entities = tx.find_all(keys).all.to_a
      entities.count.must_equal 4
      entities.each do |entity|
        entity.must_be_kind_of Google::Cloud::Datastore::Entity
      end
    end
  end

  it "iterates with all using Enumerator" do
    first_lookup_req = Google::Datastore::V1::LookupRequest.new(
      project_id: project,
      keys: keys.map(&:to_grpc)
    )
    second_lookup_req = Google::Datastore::V1::LookupRequest.new(
      project_id: project,
      keys: [key3, key4].map(&:to_grpc)
    )
    dataset.service.mocked_datastore.expect :lookup, first_lookup_res,  [first_lookup_req]
    dataset.service.mocked_datastore.expect :lookup, second_lookup_res, [second_lookup_req]

    entities = dataset.find_all(keys).all.take(3)
    entities.count.must_equal 3
    entities.each do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end
  end

  it "iterates with all and request_limit set" do
    first_lookup_req = Google::Datastore::V1::LookupRequest.new(
      project_id: project,
      keys: keys.map(&:to_grpc)
    )
    second_lookup_req = Google::Datastore::V1::LookupRequest.new(
      project_id: project,
      keys: [key3, key4].map(&:to_grpc)
    )
    dataset.service.mocked_datastore.expect :lookup, first_lookup_res,  [first_lookup_req]
    dataset.service.mocked_datastore.expect :lookup, second_lookup_res, [second_lookup_req]

    # This test is a bit handwavy, as there aren't more results to lookup.
    # But if you reduce the limit it will not make additional call.
    entities = dataset.find_all(keys).all(request_limit: 1).to_a
    entities.count.must_equal 4
    entities.each do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end
  end
end
