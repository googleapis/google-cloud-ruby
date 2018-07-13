# Copyright 2017 Google LLC
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
    firestore = Google::Cloud::Firestore::Client.new(Google::Cloud::Firestore::Service.new("my-project-id", credentials))
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

  doctest.before "Google::Cloud::Firestore::Client" do
    mock_firestore do |mock|
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Client#cols" do
    mock_firestore do |mock|
      mock.expect :list_collection_ids, list_collection_resp, list_collection_args
      mock.expect :commit, commit_resp, commit_args
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::Client#collections"

  doctest.before "Google::Cloud::Firestore::Client#docs" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::Client#documents"

  doctest.before "Google::Cloud::Firestore::Client#get_all" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::Client#get_docs"
  doctest.skip "Google::Cloud::Firestore::Client#get_documents"
  doctest.skip "Google::Cloud::Firestore::Client#find"

  doctest.before "Google::Cloud::Firestore::Client#document_id" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.skip "Google::Cloud::Firestore::Client#field_path" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp_users, batch_get_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Client#field_delete" do
    mock_firestore do |mock|
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Client#field_server_time" do
    mock_firestore do |mock|
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Client#transaction" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [String, Hash]
      mock.expect :run_query, run_query_resp, run_query_args
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.skip "Google::Cloud::Firestore::FieldPath" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp_users, batch_get_args
    end
  end

  doctest.before "Google::Cloud::Firestore::FieldValue" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Batch" do
    mock_firestore do |mock|
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Transaction" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [String, Hash]
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
      mock.expect :commit, commit_resp, commit_args
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
  doctest.before "Google::Cloud::Firestore::Transaction#get@Get a document snapshot given a document path:" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [String, Hash]
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
      mock.expect :commit, commit_resp, commit_args
    end
  end
  doctest.before "Google::Cloud::Firestore::Transaction#get@Get a document snapshot given a document reference:" do
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

  doctest.before "Google::Cloud::Firestore::Query" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Query#start_at@Starting a query at a DocumentSnapshot" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Query#start_after@Starting a query after a DocumentSnapshot" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Query#end_before@Ending a query before a DocumentSnapshot" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Query#end_at@Ending a query at a DocumentSnapshot" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::CollectionReference" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end

  doctest.before "Google::Cloud::Firestore::CollectionReference#add" do
    mock_firestore do |mock|
      mock.expect :commit, commit_resp, commit_args
    end
  end

  # The method #get_all must be listed after #get because of reasons...
  doctest.before "Google::Cloud::Firestore::CollectionReference#get_all" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::CollectionReference#get_docs"
  doctest.skip "Google::Cloud::Firestore::CollectionReference#get_documents"
  doctest.skip "Google::Cloud::Firestore::CollectionReference#find"

  doctest.before "Google::Cloud::Firestore::DocumentReference#cols" do
    mock_firestore do |mock|
      mock.expect :list_collection_ids, list_collection_resp, list_collection_args
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::DocumentReference#collections"

  doctest.before "Google::Cloud::Firestore::DocumentReference#get" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
    end
  end

  doctest.before "Google::Cloud::Firestore::DocumentReference#create" do
    mock_firestore do |mock|
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::DocumentReference#set" do
    mock_firestore do |mock|
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::DocumentReference#update" do
    mock_firestore do |mock|
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::DocumentReference#delete" do
    mock_firestore do |mock|
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::DocumentSnapshot" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
    end
  end

  doctest.before "Google::Cloud::Firestore::DocumentSnapshot#get@Nested data can be accessing with field path:" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp_users, batch_get_args
    end
  end
  doctest.before "Google::Cloud::Firestore::DocumentSnapshot#get@Nested data can be accessing with FieldPath object:" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, batch_get_resp_users, batch_get_args
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::DocumentSnapshot#[]"

  doctest.before "Google::Cloud::Firestore::DocumentSnapshot#missing" do
    mock_firestore do |mock|
      mock.expect :batch_get_documents, missing_batch_get_resp, batch_get_args
    end
  end

  doctest.before "Google::Cloud::Firestore::CommitResponse" do
    mock_firestore do |mock|
      mock.expect :commit, commit_resp, commit_args
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
