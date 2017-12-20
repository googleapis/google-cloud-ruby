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

require "google/cloud/firestore"

##
# Monkey-Patch CallOptions to support Mocks
class Google::Gax::CallOptions
  ##
  # Minitest Mock depends on === to match same-value objects.
  # By default, CallOptions objects do not match with ===.
  # Therefore, we must add this capability.
  def === other
    return false unless other.is_a? Google::Gax::CallOptions
    timeout === other.timeout &&
      retry_options === other.retry_options &&
      page_token === other.page_token &&
      kwargs === other.kwargs
  end
  def == other
    return false unless other.is_a? Google::Gax::CallOptions
    timeout == other.timeout &&
      retry_options == other.retry_options &&
      page_token == other.page_token &&
      kwargs == other.kwargs
  end
end

module Google
  module Cloud
    module Firestore
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
      module Generate
        def self.unique_id *args
          "RANDOMID123XYZ"
        end
      end
    end
  end
end

def mock_firestore
  Google::Cloud::Firestore.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
    firestore = Google::Cloud::Firestore::Database.new(Google::Cloud::Firestore::Service.new("my-project-id", credentials))
    firestore_mock = Minitest::Mock.new

    firestore.service.instance_variable_set :@firestore, firestore_mock
    if block_given?
      yield firestore_mock
    end
    firestore
  end
end

YARD::Doctest.configure do |doctest|
  # Current mocking does not support testing GAPIC layer. (Auth failures occur.)
  doctest.skip "Google::Cloud::Firestore::V1beta1::FirestoreClient"

  doctest.before "Google::Cloud#firestore" do
    mock_firestore
  end

  doctest.before "Google::Cloud.firestore" do
    mock_firestore
  end

  doctest.before "Google::Cloud::Firestore" do
    mock_firestore
  end

  doctest.skip "Google::Cloud::Firestore::Credentials" # occasionally getting "This code example is not yet mocked"

  doctest.before "Google::Cloud::Firestore::Project" do
    mock_firestore
  end

  doctest.before "Google::Cloud::Firestore::Database" do
    mock_firestore do |mock|
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Database#cols" do
    mock_firestore do |mock|
      mock.expect :list_collection_ids, list_collection_resp, list_collection_args
      mock.expect :commit, commit_resp, commit_args
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::Database#collections"

  doctest.before "Google::Cloud::Firestore::Database#docs" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::Database#documents"

  doctest.before "Google::Cloud::Firestore::Database#query" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end
  doctest.skip "Google::Cloud::Firestore::Database#q"

  doctest.before "Google::Cloud::Firestore::Database#select" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Database#from" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Database#where" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Database#order" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Database#offset" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Database#limit" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Database#start_at" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Database#start_after" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Database#end_before" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Database#end_at" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Database#get" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end
  doctest.before "Google::Cloud::Firestore::Database#get@Get a document with data given a document path:" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
    end
  end
  doctest.before "Google::Cloud::Firestore::Database#get@Get a document with data given a document reference:" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
    end
  end
  doctest.skip "Google::Cloud::Firestore::Database#run"

  # The method #get_all must be listed after #get because of reasons...
  doctest.before "Google::Cloud::Firestore::Database#get_all" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::Database#get_docs"
  doctest.skip "Google::Cloud::Firestore::Database#get_documents"
  doctest.skip "Google::Cloud::Firestore::Database#find"

  doctest.before "Google::Cloud::Firestore::Database#transaction" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [String, Hash]
      mock.expect :run_query, run_query_resp, run_query_args
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Database#read_only_transaction" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
      mock.expect :rollback, nil, [String, String, Hash]
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::Database#read_transaction"
  doctest.skip "Google::Cloud::Firestore::Database#snapshot"

  doctest.before "Google::Cloud::Firestore::Batch" do
    mock_firestore do |mock|
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Batch#cols" do
    mock_firestore do |mock|
      mock.expect :list_collection_ids, list_collection_resp, list_collection_args
      mock.expect :commit, commit_resp, commit_args
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::Batch#collections"

  doctest.before "Google::Cloud::Firestore::Batch#docs" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::Batch#documents"

  doctest.before "Google::Cloud::Firestore::Batch#query" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end
  doctest.skip "Google::Cloud::Firestore::Batch#q"

  doctest.before "Google::Cloud::Firestore::Batch#select" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Batch#from" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Batch#where" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Batch#order" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Batch#offset" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Batch#limit" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Batch#start_at" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Batch#start_after" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Batch#end_before" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Batch#end_at" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Batch#get" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end
  doctest.before "Google::Cloud::Firestore::Batch#get@Get a document with data given a document path:" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
    end
  end
  doctest.before "Google::Cloud::Firestore::Batch#get@Get a document with data given a document reference:" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
    end
  end
  doctest.skip "Google::Cloud::Firestore::Batch#run"

  # The method #get_all must be listed after #get because of reasons...
  doctest.before "Google::Cloud::Firestore::Batch#get_all" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::Batch#get_docs"
  doctest.skip "Google::Cloud::Firestore::Batch#get_documents"
  doctest.skip "Google::Cloud::Firestore::Batch#find"

  doctest.before "Google::Cloud::Firestore::Transaction" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [String, Hash]
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
      mock.expect :commit, commit_resp, commit_args
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Transaction#cols" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [String, Hash]
      mock.expect :list_collection_ids, list_collection_resp, list_collection_args
      mock.expect :commit, commit_resp, commit_args
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::Transaction#collections"

  doctest.before "Google::Cloud::Firestore::Transaction#docs" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [String, Hash]
      mock.expect :run_query, run_query_resp, run_query_args
      mock.expect :commit, commit_resp, commit_args
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::Transaction#documents"

  doctest.before "Google::Cloud::Firestore::Transaction#query" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [String, Hash]
      mock.expect :run_query, run_query_resp, run_query_args
      mock.expect :commit, commit_resp, commit_args
    end
  end
  doctest.skip "Google::Cloud::Firestore::Transaction#q"

  doctest.before "Google::Cloud::Firestore::Transaction#select" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [String, Hash]
      mock.expect :run_query, run_query_resp, run_query_args
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Transaction#from" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [String, Hash]
      mock.expect :run_query, run_query_resp, run_query_args
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Transaction#where" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [String, Hash]
      mock.expect :run_query, run_query_resp, run_query_args
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Transaction#order" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [String, Hash]
      mock.expect :run_query, run_query_resp, run_query_args
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Transaction#offset" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [String, Hash]
      mock.expect :run_query, run_query_resp, run_query_args
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Transaction#limit" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [String, Hash]
      mock.expect :run_query, run_query_resp, run_query_args
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Transaction#start_at" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [String, Hash]
      mock.expect :run_query, run_query_resp, run_query_args
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Transaction#start_after" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [String, Hash]
      mock.expect :run_query, run_query_resp, run_query_args
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Transaction#end_before" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [String, Hash]
      mock.expect :run_query, run_query_resp, run_query_args
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Transaction#end_at" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [String, Hash]
      mock.expect :run_query, run_query_resp, run_query_args
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Transaction#get" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [String, Hash]
      mock.expect :run_query, run_query_resp, run_query_args
      mock.expect :commit, commit_resp, commit_args
    end
  end
  doctest.before "Google::Cloud::Firestore::Transaction#get@Get a document with data given a document path:" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [String, Hash]
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
      mock.expect :commit, commit_resp, commit_args
    end
  end
  doctest.before "Google::Cloud::Firestore::Transaction#get@Get a document with data given a document reference:" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [String, Hash]
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
      mock.expect :commit, commit_resp, commit_args
    end
  end
  doctest.skip "Google::Cloud::Firestore::Transaction#run"

  # The method #get_all must be listed after #get because of reasons...
  doctest.before "Google::Cloud::Firestore::Transaction#get_all" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [String, Hash]
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
      mock.expect :commit, commit_resp, commit_args
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::Transaction#get_docs"
  doctest.skip "Google::Cloud::Firestore::Transaction#get_documents"
  doctest.skip "Google::Cloud::Firestore::Transaction#find"

  doctest.before "Google::Cloud::Firestore::ReadOnlyTransaction" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
      mock.expect :run_query, run_query_resp, run_query_args
      mock.expect :rollback, nil, [String, String, Hash]
    end
  end

  doctest.before "Google::Cloud::Firestore::ReadOnlyTransaction#col" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
      mock.expect :rollback, nil, [String, String, Hash]
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::ReadOnlyTransaction#collection"

  # The method #cols must be listed after #col because of reasons...
  doctest.before "Google::Cloud::Firestore::ReadOnlyTransaction#cols" do
    mock_firestore do |mock|
      mock.expect :list_collection_ids, list_collection_resp, list_collection_args
      mock.expect :rollback, nil, [String, String, Hash]
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::ReadOnlyTransaction#collections"

  doctest.before "Google::Cloud::Firestore::ReadOnlyTransaction#get@Get a document with data given a document path:" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
      mock.expect :rollback, nil, [String, String, Hash]
    end
  end
  doctest.before "Google::Cloud::Firestore::ReadOnlyTransaction#get@Get a document with data given a document reference:" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
      mock.expect :rollback, nil, [String, String, Hash]
    end
  end
  doctest.skip "Google::Cloud::Firestore::ReadOnlyTransaction#run"

  # The method #get_all must be listed after #get because of reasons...
  doctest.before "Google::Cloud::Firestore::ReadOnlyTransaction#get_all" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
      mock.expect :rollback, nil, [String, String, Hash]
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::ReadOnlyTransaction#get_docs"
  doctest.skip "Google::Cloud::Firestore::ReadOnlyTransaction#get_documents"
  doctest.skip "Google::Cloud::Firestore::ReadOnlyTransaction#find"

  doctest.before "Google::Cloud::Firestore::Collection::Reference" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Collection::Reference#add" do
    mock_firestore do |mock|
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Collection::Reference#docs" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::Collection::Reference#documents"
  doctest.skip "Google::Cloud::Firestore::Collection::Reference#get"
  doctest.skip "Google::Cloud::Firestore::Collection::Reference#run"

  # The method #get_all must be listed after #get because of reasons...
  doctest.before "Google::Cloud::Firestore::Collection::Reference#get_all" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::Collection::Reference#get_docs"
  doctest.skip "Google::Cloud::Firestore::Collection::Reference#get_documents"
  doctest.skip "Google::Cloud::Firestore::Collection::Reference#find"

  doctest.before "Google::Cloud::Firestore::Document::Reference#cols" do
    mock_firestore do |mock|
      mock.expect :list_collection_ids, list_collection_resp, list_collection_args
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::Document::Reference#collections"

  doctest.before "Google::Cloud::Firestore::Document::Reference#get" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Document::Reference#create" do
    mock_firestore do |mock|
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Document::Reference#set" do
    mock_firestore do |mock|
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Document::Reference#update" do
    mock_firestore do |mock|
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Document::Reference#delete" do
    mock_firestore do |mock|
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Document::Snapshot" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Document::Snapshot#cols" do
    mock_firestore do |mock|
      mock.expect :list_collection_ids, list_collection_resp, list_collection_args
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::Document::Snapshot#collections"

  doctest.before "Google::Cloud::Firestore::Document::Snapshot#get@Nested data can be accessing with field path:" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp_users, batch_get_args
    end
  end
  doctest.before "Google::Cloud::Firestore::Document::Snapshot#get@Nested data can be accessing with field path array:" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp_users, batch_get_args
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::Document::Snapshot#[]"

  doctest.before "Google::Cloud::Firestore::Document::Snapshot#missing" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, missing_batch_get_resp, batch_get_args
    end
  end
end

# Fixture helpers
def commit_args
  [String, Array, Hash]
end

def commit_resp
  Google::Firestore::V1beta1::CommitResponse.new(
    commit_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now),
    write_results: [Google::Firestore::V1beta1::WriteResult.new(
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now))]
    )
end

def list_collection_resp
  ["cities", "messages"].to_enum
end

def list_collection_args
  [String, Hash]
end

def run_query_resp
  [
    run_query_resp_obj("cities/NYC", { name: "New York City", population: 1000000 }),
    run_query_resp_obj("cities/SF",  { name: "San Francisco", population: 1000000 }),
    run_query_resp_obj("cities/LA",  { name: "Los Angeles", population: 1000000 })
  ].to_enum
end

def run_query_resp_obj doc, data
  Google::Firestore::V1beta1::RunQueryResponse.new(
    transaction: "tx123",
    read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now),
    document: Google::Firestore::V1beta1::Document.new(
      name: "projects/my-project-id/databases/(default)/documents/#{doc}",
      fields: Google::Cloud::Firestore::Convert.hash_to_fields(data),
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now)
    ))
end

def run_query_args
  [String, Hash]
end

def batch_get_resp
  [
    batch_get_resp_obj("cities/NYC", { name: "New York City", population: 1000000 }),
    batch_get_resp_obj("cities/SF",  { name: "San Francisco", population: 1000000 }),
    batch_get_resp_obj("cities/LA",  { name: "Los Angeles", population: 1000000 })
  ].to_enum
end

def batch_get_resp_users
  user_data = {
    name: "Frank",
    age: 12,
    favorites: {
      food: "Pizza",
      color: "Blue",
      subject: "recess"
    }
  }
  [
    batch_get_resp_obj("users/frank", user_data),
  ].to_enum
end

def missing_batch_get_resp
  [
    Google::Firestore::V1beta1::BatchGetDocumentsResponse.new(
      read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now),
      missing: "projects/my-project-id/databases/(default)/documents/cities/Atlantis"
    )
  ].to_enum
end

def batch_get_resp_obj doc, data
  Google::Firestore::V1beta1::BatchGetDocumentsResponse.new(
    read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now),
    found: Google::Firestore::V1beta1::Document.new(
      name: "projects/my-project-id/databases/(default)/documents/#{doc}",
      fields: Google::Cloud::Firestore::Convert.hash_to_fields(data),
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now)
    ))
end

def batch_get_args
  [String, Array, Hash]
end
