# Copyright 2016 Google Inc. All rights reserved.
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

require "grpc"
require "google/cloud/datastore"

# IMPORTANT: Comment out the monkey-patches below when working on or debugging
# doctest errors, but please restore them again to support concise error
# expectations such as: `descriptions.cursor #=> raise NoMethodError`
class RuntimeError
  def to_s
    "#<RuntimeError: RuntimeError>"
  end
end
class NoMethodError
  def to_s
    "#<NoMethodError: NoMethodError>"
  end
end

class File
  def self.file? f
    true
  end
  def self.readable? f
    true
  end
  def self.read *args
    "fake file data"
  end
  def self.open f, mode = "r", opts = {}
    StringIO.new("abc123")
  end
end

module Google
  module Cloud
    module Datastore
      def self.stub_new
        define_singleton_method :new do |*args|
          yield *args
        end
      end
      # Create default unmocked methods that will raise if ever called
      def self.new *args
        raise "This code example is not yet mocked"
      end
      class Credentials
        # Override the default constructor
        def self.new *args
          OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
        end
      end
    end
  end
end

def mock_datastore
  Google::Cloud::Datastore.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    datastore = Google::Cloud::Datastore::Dataset.new(Google::Cloud::Datastore::Service.new("my-todo-project", credentials))

    datastore.service.mocked_service = Minitest::Mock.new
    yield datastore.service.mocked_service
    datastore
  end
end

YARD::Doctest.configure do |doctest|
  ##
  # SKIP
  #

  # Skip all GAPIC for now
  doctest.skip "Google::Cloud::Datastore::V1::DatastoreClient"

  # Skip all aliases, since tests would be exact duplicates
  doctest.skip "Google::Cloud::Datastore::Dataset#upsert"
  doctest.skip "Google::Cloud::Datastore::Dataset#get"
  doctest.skip "Google::Cloud::Datastore::Dataset#lookup"
  doctest.skip "Google::Cloud::Datastore::Dataset#run_query"
  doctest.skip "Google::Cloud::Datastore::Key#dataset_id"
  doctest.skip "Google::Cloud::Datastore::Query#filter"
  doctest.skip "Google::Cloud::Datastore::Query#cursor"
  doctest.skip "Google::Cloud::Datastore::Query#projection"
  doctest.skip "Google::Cloud::Datastore::Query#distinct_on"
  doctest.skip "Google::Cloud::Datastore::Transaction#upsert"
  doctest.skip "Google::Cloud::Datastore::Transaction#get"
  doctest.skip "Google::Cloud::Datastore::Transaction#lookup"
  doctest.skip "Google::Cloud::Datastore::Transaction#run_query"
  doctest.skip "Google::Cloud::Datastore::Transaction#begin_transaction"

  ##
  # BEFORE (mocking)
  #

  doctest.before("Google::Cloud#datastore") do
    mock_datastore do |mock|
      mock.expect :commit, OpenStruct.new(mutation_results: []), ["my-todo-project", :NON_TRANSACTIONAL, Array, Hash]
    end
  end

  doctest.before("Google::Cloud.datastore") do
    mock_datastore do |mock|
      mock.expect :commit, OpenStruct.new(mutation_results: []), ["my-todo-project", :NON_TRANSACTIONAL, Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore") do
    mock_datastore do |mock|
    end
  end

  doctest.before("Google::Cloud::Datastore.new") do
    mock_datastore do |mock|
      mock.expect :commit, OpenStruct.new(mutation_results: []), ["my-todo-project", :NON_TRANSACTIONAL, Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Commit") do
    mock_datastore do |mock|
      mock.expect :commit, OpenStruct.new(mutation_results: []), ["my-todo-project", :NON_TRANSACTIONAL, Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Cursor") do
    mock_datastore do |mock|
      mock.expect :run_query, run_query_res, ["my-todo-project", nil, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Dataset") do
    mock_datastore do |mock|
      mock.expect :run_query, run_query_res, ["my-todo-project", nil, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Dataset#allocate_ids") do
    mock_datastore do |mock|
      mock.expect :allocate_ids, OpenStruct.new(keys: []), ["my-todo-project", Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Dataset#save") do
    mock_datastore do |mock|
      mock.expect :commit, OpenStruct.new(mutation_results: [entity_grpc("Task", 123456)]), ["my-todo-project", :NON_TRANSACTIONAL, Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Dataset#save@Update an existing entity:") do
    mock_datastore do |mock|
      mock.expect :lookup, lookup_res, ["my-todo-project", Array, Hash]
      mock.expect :commit, OpenStruct.new(mutation_results: []), ["my-todo-project", :NON_TRANSACTIONAL, Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Dataset#insert") do
    mock_datastore do |mock|
      mock.expect :commit, OpenStruct.new(mutation_results: [entity_grpc("Task", 123456)]), ["my-todo-project", :NON_TRANSACTIONAL, Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Dataset#update") do
    mock_datastore do |mock|
      mock.expect :lookup, lookup_res, ["my-todo-project", Array, Hash]
      mock.expect :commit, OpenStruct.new(mutation_results: []), ["my-todo-project", :NON_TRANSACTIONAL, Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Dataset#update@Update multiple new entities in a batch:") do
    mock_datastore do |mock|
      mock.expect :run_query, run_query_res, ["my-todo-project", nil, Hash]
      mock.expect :commit, OpenStruct.new(mutation_results: []), ["my-todo-project", :NON_TRANSACTIONAL, Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Dataset#delete") do
    mock_datastore do |mock|
      mock.expect :lookup, lookup_res, ["my-todo-project", Array, Hash]
      mock.expect :commit, OpenStruct.new(mutation_results: []), ["my-todo-project", :NON_TRANSACTIONAL, Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Dataset#commit") do
    mock_datastore do |mock|
      mock.expect :commit, OpenStruct.new(mutation_results: []), ["my-todo-project", :NON_TRANSACTIONAL, Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Dataset#find") do
    mock_datastore do |mock|
      mock.expect :lookup, lookup_res, ["my-todo-project", Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Dataset#run@Run an ancestor query with eventual consistency:") do
    mock_datastore do |mock|
      mock.expect :run_query, run_query_res, ["my-todo-project", nil, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Dataset#run@Run the query within a namespace with the `namespace` option:") do
    mock_datastore do |mock|
      mock.expect :run_query, run_query_res, ["my-todo-project", Google::Datastore::V1::PartitionId, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Dataset#run@Run the GQL query within a namespace with `namespace` option:") do
    mock_datastore do |mock|
      mock.expect :run_query, run_query_res, ["my-todo-project", Google::Datastore::V1::PartitionId, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Dataset#transaction") do
    mock_datastore do |mock|
      mock.expect :begin_transaction, begin_tx_res, ["my-todo-project"]
      mock.expect :lookup, lookup_res, ["my-todo-project", Array, Hash]
      mock.expect :commit, OpenStruct.new(mutation_results: []), ["my-todo-project", :TRANSACTIONAL, Array, Hash]
    end
  end

  doctest.before('Google::Cloud::Datastore::Dataset::LookupResults') do
    mock_datastore do |mock|
      mock.expect :lookup, lookup_res(3), ["my-todo-project", Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Dataset::QueryResults") do
    mock_datastore do |mock|
      mock.expect :run_query, run_query_res, ["my-todo-project", nil, Hash]
      mock.expect :run_query, run_query_res(:NO_MORE_RESULTS), ["my-todo-project", nil, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Entity") do
    mock_datastore do |mock|
      mock.expect :lookup, lookup_res, ["my-todo-project", Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Entity#key=") do
    mock_datastore do |mock|
      mock.expect :lookup, lookup_res, ["my-todo-project", Array, Hash]
      mock.expect :commit, OpenStruct.new(mutation_results: []), ["my-todo-project", :NON_TRANSACTIONAL, Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Entity#properties") do
    mock_datastore do |mock|
      mock.expect :lookup, lookup_res, ["my-todo-project", Array, Hash]
      mock.expect :commit, OpenStruct.new(mutation_results: []), ["my-todo-project", :NON_TRANSACTIONAL, Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::GqlQuery") do
    mock_datastore do |mock|
      mock.expect :run_query, run_query_res, ["my-todo-project", nil, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Key") do
    mock_datastore do |mock|
      mock.expect :lookup, lookup_res, ["my-todo-project", Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Key#parent") do
    mock_datastore do |mock|
      mock.expect :lookup, lookup_res, ["my-todo-project", Array, Hash]
      mock.expect :run_query, run_query_res, ["my-todo-project", nil, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Query") do
    mock_datastore do |mock|
      mock.expect :run_query, run_query_res, ["my-todo-project", nil, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Query@Run the query within a namespace with the `namespace` option:") do
    mock_datastore do |mock|
      mock.expect :run_query, run_query_res, ["my-todo-project", Google::Datastore::V1::PartitionId, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Transaction") do
    mock_datastore do |mock|
      mock.expect :begin_transaction, begin_tx_res, ["my-todo-project"]
      mock.expect :lookup, lookup_res, ["my-todo-project", Array, Hash]
      mock.expect :commit, OpenStruct.new(mutation_results: []), ["my-todo-project", :TRANSACTIONAL, Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Transaction@Transactional read:") do
    mock_datastore do |mock|
      mock.expect :begin_transaction, begin_tx_res, ["my-todo-project"]
      mock.expect :lookup, lookup_res, ["my-todo-project", Array, Hash]
      mock.expect :run_query, run_query_res, ["my-todo-project", nil, Hash]
      mock.expect :commit, OpenStruct.new(mutation_results: []), ["my-todo-project", :TRANSACTIONAL, Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Transaction#delete") do
    mock_datastore do |mock|
      mock.expect :begin_transaction, begin_tx_res, ["my-todo-project"]
      mock.expect :lookup, lookup_res, ["my-todo-project", Array, Hash]
      mock.expect :commit, OpenStruct.new(mutation_results: []), ["my-todo-project", :TRANSACTIONAL, Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Transaction#find") do
    mock_datastore do |mock|
      mock.expect :begin_transaction, begin_tx_res, ["my-todo-project"]
      mock.expect :lookup, lookup_res, ["my-todo-project", Array, Hash]
      mock.expect :commit, OpenStruct.new(mutation_results: []), ["my-todo-project", :TRANSACTIONAL, Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Transaction#run") do
    mock_datastore do |mock|
      mock.expect :begin_transaction, begin_tx_res, ["my-todo-project"]
      mock.expect :run_query, run_query_res, ["my-todo-project", nil, Hash]
      mock.expect :commit, OpenStruct.new(mutation_results: []), ["my-todo-project", :TRANSACTIONAL, Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Transaction#run@Run the query within a namespace with the `namespace` option:") do
    mock_datastore do |mock|
      mock.expect :begin_transaction, begin_tx_res, ["my-todo-project"]
      mock.expect :run_query, run_query_res, ["my-todo-project", Google::Datastore::V1::PartitionId, Hash]
      mock.expect :commit, OpenStruct.new(mutation_results: []), ["my-todo-project", :TRANSACTIONAL, Array, Hash]
    end
  end

  doctest.before("Google::Cloud::Datastore::Transaction#commit") do
    mock_datastore do |mock|
      mock.expect :begin_transaction, begin_tx_res, ["my-todo-project"]
      mock.expect :lookup, lookup_res, ["my-todo-project", Array, Hash]
      mock.expect :commit, OpenStruct.new(mutation_results: []), ["my-todo-project", :TRANSACTIONAL, Array, Hash]
    end
  end
end

# Context stubs for missing references
# TODO: Update examples to declare/initialize all referenced members

def task_key1
  key_grpc "Task", "task_key1"
end

def task_key2
  key_grpc "Task", "task_key1"
end

def task_key3
  key_grpc "Task", "task_key1"
end

def from_key
  key_grpc "Task", "from_key"
end

def to_key
  key_grpc "Task", "to_key"
end

def amount
  1
end

def transfer_funds from_key, to_key, amount

end

def task1
  entity 1
end

def task2
  entity 2
end

def task3
  entity 3
end

def task4
  entity 4
end

def task_list
  entity 5
end

def page_size
  1
end

def page_cursor
  "cursor 123"
end

##
# Helpers
#

def entity count
  t = Google::Cloud::Datastore::Entity.new
  t.key = Google::Cloud::Datastore::Key.new "Task"
  t["description"] = "Test #{count}."
  t["created"]     = Time.now
  t["done"]        = false
  t.exclude_from_indexes! "description", true
  t
end


def entity_grpc kind = "Task", id_or_name = "sampleTask"
  Google::Cloud::Datastore::Entity.new.tap do |e|
    e.key = key_grpc(kind, id_or_name)
    e["description"] = "Learn Cloud Datastore"
    e["location"] = { longitude: -122.0862462, latitude: 37.4220041 }
    e["avatar"] = StringIO.new("abc123")
  end.to_grpc
end

def key_grpc kind = "Task", id_or_name = "sampleTask"
  key = Google::Cloud::Datastore::Key.new(kind, id_or_name)
  key.namespace = "example-ns"
  key.project = "my-todo-project"
  key
end

def run_query_res_entities
  3.times.map do |i|
    Google::Datastore::V1::EntityResult.new(
      entity: Google::Cloud::Datastore::Entity.new.tap do |e|
        e.key = Google::Cloud::Datastore::Key.new "ds-test", 1000+i
        e["name"] = "thingamajig"
      end.to_grpc,
      cursor: "result-cursor-1-#{i}".force_encoding("ASCII-8BIT")
    )
  end
end

def run_query_res more_results = :NOT_FINISHED
  Google::Datastore::V1::RunQueryResponse.new(
    batch: Google::Datastore::V1::QueryResultBatch.new(
      entity_results: run_query_res_entities,
      more_results: more_results,
      end_cursor: "second-page-cursor".force_encoding("ASCII-8BIT")
    )
  )
end

def lookup_res count = 1
  entities = count.times.map do |i|
    Google::Datastore::V1::EntityResult.new(
      entity: entity_grpc
    )
  end
  Google::Datastore::V1::LookupResponse.new(
    found: entities
  )
end

def begin_tx_res
  tx_id = "giterdone".encode("ASCII-8BIT")
  Google::Datastore::V1::BeginTransactionResponse.new(transaction: tx_id)
end
