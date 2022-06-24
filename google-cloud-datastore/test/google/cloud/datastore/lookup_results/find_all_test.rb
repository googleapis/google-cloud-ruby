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

describe Google::Cloud::Datastore::Dataset, :find_all, :mock_datastore do
  # let(:query_cursor) { Google::Cloud::Datastore::Cursor.new "c3VwZXJhd2Vzb21lIQ==" }

  let(:key1) { Google::Cloud::Datastore::Key.new "ds-test", "thingie1" }
  let(:key2) { Google::Cloud::Datastore::Key.new "ds-test", "thingie2" }
  let(:key3) { Google::Cloud::Datastore::Key.new "ds-test", "thingie3" }
  let(:key4) { Google::Cloud::Datastore::Key.new "ds-test", "thingie4" }
  let(:key5) { Google::Cloud::Datastore::Key.new "ds-test", "thingie5" }
  let(:key6) { Google::Cloud::Datastore::Key.new "ds-test", "thingie6" }
  let(:keys) { [key1, key2, key3, key4, key5, key6] }
  let(:first_keys) { keys.map(&:to_grpc) }
  let(:second_keys) { [key3, key4].map(&:to_grpc) }

  let(:first_lookup_res) do
    Google::Cloud::Datastore::V1::LookupResponse.new(
      found: (1..2).map do |i|
        Google::Cloud::Datastore::V1::EntityResult.new(
          entity: Google::Cloud::Datastore::V1::Entity.new(
            key: Google::Cloud::Datastore::Key.new("ds-test", "thingie#{i}").to_grpc,
            properties: { "name" => Google::Cloud::Datastore::Convert.to_value("thingamajig") }
          )
        )
      end,
      missing: (5..6).map do |i|
        Google::Cloud::Datastore::V1::EntityResult.new(
          entity: Google::Cloud::Datastore::V1::Entity.new(
            key: Google::Cloud::Datastore::Key.new("ds-test", "thingie#{i}").to_grpc,
            properties: { "name" => Google::Cloud::Datastore::Convert.to_value("thingamajig") }
          )
        )
      end,
      deferred: (3..4).map do |i|
        Google::Cloud::Datastore::Key.new("ds-test", "thingie#{i}").to_grpc
      end
    )
  end
  let(:second_lookup_res) do
    Google::Cloud::Datastore::V1::LookupResponse.new(
      found: (3..4).map do |i|
        Google::Cloud::Datastore::V1::EntityResult.new(
          entity: Google::Cloud::Datastore::V1::Entity.new(
            key: Google::Cloud::Datastore::Key.new("ds-test", "thingie#{i}").to_grpc,
            properties: { "name" => Google::Cloud::Datastore::Convert.to_value("thingamajig") }
          )
        )
      end
    )
  end

  before do
    dataset.service.mocked_service = Minitest::Mock.new
  end

  after do
    dataset.service.mocked_service.verify
  end

  it "paginates" do
    dataset.service.mocked_service.expect :lookup, first_lookup_res, project_id: project, keys: first_keys, read_options: nil
    dataset.service.mocked_service.expect :lookup, second_lookup_res, project_id: project, keys: second_keys, read_options: nil

    first_entities = dataset.find_all keys
    _(first_entities.count).must_equal 2
    _(first_entities.deferred.count).must_equal 2
    _(first_entities.missing.count).must_equal 2
    first_entities.each do |entity|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    end
    first_entities.deferred.each do |deferred_key|
      _(deferred_key).must_be_kind_of Google::Cloud::Datastore::Key
    end
    first_entities.missing.each do |entity|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    end

    second_entities = dataset.find_all first_entities.deferred
    _(second_entities.count).must_equal 2
    _(second_entities.deferred.count).must_equal 0
    _(second_entities.missing.count).must_equal 0
    second_entities.each do |entity|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    end
  end

  it "paginates with consistency" do
    read_options = Google::Cloud::Datastore::V1::ReadOptions.new(read_consistency: :EVENTUAL)
    dataset.service.mocked_service.expect :lookup, first_lookup_res, project_id: project, keys: first_keys, read_options: read_options
    dataset.service.mocked_service.expect :lookup, second_lookup_res, project_id: project, keys: second_keys, read_options: read_options

    first_entities = dataset.find_all keys, consistency: :eventual
    _(first_entities.count).must_equal 2
    _(first_entities.deferred.count).must_equal 2
    _(first_entities.missing.count).must_equal 2
    first_entities.each do |entity|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    end
    first_entities.deferred.each do |deferred_key|
      _(deferred_key).must_be_kind_of Google::Cloud::Datastore::Key
    end
    first_entities.missing.each do |entity|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    end

    second_entities = dataset.find_all first_entities.deferred, consistency: :eventual
    _(second_entities.count).must_equal 2
    _(second_entities.deferred.count).must_equal 0
    _(second_entities.missing.count).must_equal 0
    second_entities.each do |entity|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    end
  end

  it "paginates with transaction" do
    tx_id = "giterdone".encode("ASCII-8BIT")
    begin_tx_res = Google::Cloud::Datastore::V1::BeginTransactionResponse.new(transaction: tx_id)
    commit_res = Google::Cloud::Datastore::V1::CommitResponse.new(
      # mutation_results: [Google::Cloud::Datastore::V1::MutationResult.new(
      #   key: Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc
      # )]
    )
    dataset.service.mocked_service.expect :begin_transaction, begin_tx_res, project_id: project, transaction_options: nil
    dataset.service.mocked_service.expect :commit, commit_res, project_id: project, mode: :TRANSACTIONAL, mutations: [], transaction: tx_id
    read_options = Google::Cloud::Datastore::V1::ReadOptions.new(transaction: tx_id)
    dataset.service.mocked_service.expect :lookup, first_lookup_res, project_id: project, keys: first_keys, read_options: read_options
    dataset.service.mocked_service.expect :lookup, second_lookup_res, project_id: project, keys: second_keys, read_options: read_options

    dataset.transaction do |tx|
      first_entities = tx.find_all keys
      _(first_entities.count).must_equal 2
      _(first_entities.deferred.count).must_equal 2
      _(first_entities.missing.count).must_equal 2
      first_entities.each do |entity|
        _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
      end
      first_entities.deferred.each do |deferred_key|
        _(deferred_key).must_be_kind_of Google::Cloud::Datastore::Key
      end
      first_entities.missing.each do |entity|
        _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
      end

      second_entities = tx.find_all first_entities.deferred
      _(second_entities.count).must_equal 2
      _(second_entities.deferred.count).must_equal 0
      _(second_entities.missing.count).must_equal 0
      second_entities.each do |entity|
        _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
      end
    end
  end

  it "paginates with next? and next" do
    dataset.service.mocked_service.expect :lookup, first_lookup_res, project_id: project, keys: first_keys, read_options: nil
    dataset.service.mocked_service.expect :lookup, second_lookup_res, project_id: project, keys: second_keys, read_options: nil

    first_entities = dataset.find_all keys
    _(first_entities.next?).must_equal true
    _(first_entities.count).must_equal 2
    _(first_entities.deferred.count).must_equal 2
    _(first_entities.missing.count).must_equal 2
    first_entities.each do |entity|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    end
    first_entities.deferred.each do |deferred_key|
      _(deferred_key).must_be_kind_of Google::Cloud::Datastore::Key
    end
    first_entities.missing.each do |entity|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    end

    second_entities = first_entities.next
    _(second_entities.next?).must_equal false
    _(second_entities.count).must_equal 2
    _(second_entities.deferred.count).must_equal 0
    _(second_entities.missing.count).must_equal 0
    second_entities.each do |entity|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    end
  end

  it "paginates with next? and next and consistency" do
    read_options = Google::Cloud::Datastore::V1::ReadOptions.new(read_consistency: :EVENTUAL)
    dataset.service.mocked_service.expect :lookup, first_lookup_res, project_id: project, keys: first_keys, read_options: read_options
    dataset.service.mocked_service.expect :lookup, second_lookup_res, project_id: project, keys: second_keys, read_options: read_options

    first_entities = dataset.find_all keys, consistency: :eventual
    _(first_entities.next?).must_equal true
    _(first_entities.count).must_equal 2
    _(first_entities.deferred.count).must_equal 2
    _(first_entities.missing.count).must_equal 2
    first_entities.each do |entity|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    end
    first_entities.deferred.each do |deferred_key|
      _(deferred_key).must_be_kind_of Google::Cloud::Datastore::Key
    end
    first_entities.missing.each do |entity|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    end

    second_entities = first_entities.next
    _(second_entities.next?).must_equal false
    _(second_entities.count).must_equal 2
    _(second_entities.deferred.count).must_equal 0
    _(second_entities.missing.count).must_equal 0
    second_entities.each do |entity|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    end
  end

  it "paginates with next? and next and transaction" do
    tx_id = "giterdone".encode("ASCII-8BIT")
    begin_tx_res = Google::Cloud::Datastore::V1::BeginTransactionResponse.new(transaction: tx_id)
    commit_res = Google::Cloud::Datastore::V1::CommitResponse.new(
      # mutation_results: [Google::Cloud::Datastore::V1::MutationResult.new(
      #   key: Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc
      # )]
    )
    dataset.service.mocked_service.expect :begin_transaction, begin_tx_res, project_id: project, transaction_options: nil
    dataset.service.mocked_service.expect :commit, commit_res, project_id: project, mode: :TRANSACTIONAL, mutations: [], transaction: tx_id
    read_options = Google::Cloud::Datastore::V1::ReadOptions.new(transaction: tx_id)
    dataset.service.mocked_service.expect :lookup, first_lookup_res, project_id: project, keys: first_keys, read_options: read_options
    dataset.service.mocked_service.expect :lookup, second_lookup_res, project_id: project, keys: second_keys, read_options: read_options

    dataset.transaction do |tx|
      first_entities = tx.find_all keys
      _(first_entities.next?).must_equal true
      _(first_entities.count).must_equal 2
      _(first_entities.deferred.count).must_equal 2
      _(first_entities.missing.count).must_equal 2
      first_entities.each do |entity|
        _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
      end
      first_entities.deferred.each do |deferred_key|
        _(deferred_key).must_be_kind_of Google::Cloud::Datastore::Key
      end
      first_entities.missing.each do |entity|
        _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
      end

      second_entities = first_entities.next
      _(second_entities.next?).must_equal false
      _(second_entities.count).must_equal 2
      _(second_entities.deferred.count).must_equal 0
      _(second_entities.missing.count).must_equal 0
      second_entities.each do |entity|
        _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
      end
    end
  end

  it "paginates with all" do
    dataset.service.mocked_service.expect :lookup, first_lookup_res, project_id: project, keys: first_keys, read_options: nil
    dataset.service.mocked_service.expect :lookup, second_lookup_res, project_id: project, keys: second_keys, read_options: nil

    entities = dataset.find_all(keys).all.to_a
    _(entities.count).must_equal 4
    entities.each do |entity|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    end
  end

  it "paginates with all and consistency" do
    read_options = Google::Cloud::Datastore::V1::ReadOptions.new(read_consistency: :EVENTUAL)
    dataset.service.mocked_service.expect :lookup, first_lookup_res, project_id: project, keys: first_keys, read_options: read_options
    dataset.service.mocked_service.expect :lookup, second_lookup_res, project_id: project, keys: second_keys, read_options: read_options

    entities = dataset.find_all(keys, consistency: :eventual).all.to_a
    _(entities.count).must_equal 4
    entities.each do |entity|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    end
  end

  it "paginates with all and transaction" do
    tx_id = "giterdone".encode("ASCII-8BIT")
    begin_tx_res = Google::Cloud::Datastore::V1::BeginTransactionResponse.new(transaction: tx_id)
    commit_res = Google::Cloud::Datastore::V1::CommitResponse.new(
      # mutation_results: [Google::Cloud::Datastore::V1::MutationResult.new(
      #   key: Google::Cloud::Datastore::Key.new("ds-test", "thingie").to_grpc
      # )]
    )
    dataset.service.mocked_service.expect :begin_transaction, begin_tx_res, project_id: project, transaction_options: nil
    dataset.service.mocked_service.expect :commit, commit_res, project_id: project, mode: :TRANSACTIONAL, mutations: [], transaction: tx_id
    read_options = Google::Cloud::Datastore::V1::ReadOptions.new(transaction: tx_id)
    dataset.service.mocked_service.expect :lookup, first_lookup_res, project_id: project, keys: first_keys, read_options: read_options
    dataset.service.mocked_service.expect :lookup, second_lookup_res, project_id: project, keys: second_keys, read_options: read_options

    dataset.transaction do |tx|
      entities = tx.find_all(keys).all.to_a
      _(entities.count).must_equal 4
      entities.each do |entity|
        _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
      end
    end
  end

  it "iterates with all using Enumerator" do
    dataset.service.mocked_service.expect :lookup, first_lookup_res, project_id: project, keys: first_keys, read_options: nil
    dataset.service.mocked_service.expect :lookup, second_lookup_res, project_id: project, keys: second_keys, read_options: nil

    entities = dataset.find_all(keys).all.take(3)
    _(entities.count).must_equal 3
    entities.each do |entity|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    end
  end

  it "iterates with all and request_limit set" do
    dataset.service.mocked_service.expect :lookup, first_lookup_res, project_id: project, keys: first_keys, read_options: nil
    dataset.service.mocked_service.expect :lookup, second_lookup_res, project_id: project, keys: second_keys, read_options: nil

    # This test is a bit handwavy, as there aren't more results to lookup.
    # But if you reduce the limit it will not make additional call.
    entities = dataset.find_all(keys).all(request_limit: 1).to_a
    _(entities.count).must_equal 4
    entities.each do |entity|
      _(entity).must_be_kind_of Google::Cloud::Datastore::Entity
    end
  end
end
