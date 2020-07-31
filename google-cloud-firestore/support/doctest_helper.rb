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

require "minitest/focus"

require "google/cloud/firestore"

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
      # doctest has issues running listen operations, so punt on it completely
      class StubbedListener
        def initialize *args
          @stopped = false
        end

        def start
          self
        end

        def stop
          @stopped = true
          self
        end

        def stopped?
          @stopped
        end
      end
      DocumentListener = StubbedListener
      QueryListener = StubbedListener
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
  doctest.skip "Google::Cloud::Firestore::V1::FirestoreClient"
  doctest.skip "Google::Cloud::Firestore::V1beta1::FirestoreClient"
  doctest.skip "Google::Cloud::Firestore::Admin::V1::FirestoreAdminClient"

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
  doctest.skip "Google::Cloud::Firestore::Client#list_collections"

  doctest.before "Google::Cloud::Firestore::Client#col_group" do
    mock_firestore do |mock|
      mock.expect :run_query, run_query_resp, run_query_args
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::Client#collection_group"

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
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [Hash, Gapic::CallOptions]
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
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [Hash, Gapic::CallOptions]
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
      mock.expect :commit, commit_resp, commit_args
      mock.expect :commit, commit_resp, commit_args
    end
  end

  doctest.before "Google::Cloud::Firestore::Transaction#get" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [Hash, Gapic::CallOptions]
      mock.expect :run_query, run_query_resp, run_query_args
      mock.expect :commit, commit_resp, commit_args
    end
  end
  doctest.before "Google::Cloud::Firestore::Transaction#get@Get a document snapshot given a document path:" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [Hash, Gapic::CallOptions]
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
      mock.expect :commit, commit_resp, commit_args
    end
  end
  doctest.before "Google::Cloud::Firestore::Transaction#get@Get a document snapshot given a document reference:" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [Hash, Gapic::CallOptions]
      mock.expect :batch_get_documents, batch_get_resp, batch_get_args
      mock.expect :commit, commit_resp, commit_args
    end
  end
  doctest.skip "Google::Cloud::Firestore::Transaction#run"

  # The method #get_all must be listed after #get because of reasons...
  doctest.before "Google::Cloud::Firestore::Transaction#get_all" do
    mock_firestore do |mock|
      mock.expect :begin_transaction, OpenStruct.new(transaction: "tx123"), [Hash, Gapic::CallOptions]
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

  doctest.before "Google::Cloud::Firestore::CollectionReference#list_documents" do
    mock_firestore do |mock|
      mock.expect :list_documents, documents_resp, list_documents_args
    end
  end

  doctest.before "Google::Cloud::Firestore::DocumentReference#cols" do
    mock_firestore do |mock|
      mock.expect :list_collection_ids, list_collection_resp, list_collection_args
    end
  end
  # Skip aliased methods
  doctest.skip "Google::Cloud::Firestore::DocumentReference#collections"
  doctest.skip "Google::Cloud::Firestore::DocumentReference#list_collections"

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

  doctest.before "Google::Cloud::Firestore::DocumentReference::List" do
    mock_firestore do |mock|
      mock.expect :list_documents, documents_resp, list_documents_args
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

def paged_enum_struct response
  OpenStruct.new response: response
end

def commit_args
  [Hash, Gapic::CallOptions]
end

def commit_resp
  Google::Cloud::Firestore::V1::CommitResponse.new(
    commit_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now),
    write_results: [Google::Cloud::Firestore::V1::WriteResult.new(
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now))]
    )
end

def list_collection_resp
  ["cities", "messages"].to_enum
end

def list_collection_args
  [Hash, Gapic::CallOptions]
end

def run_query_resp
  [
    run_query_resp_obj("cities/NYC", { name: "New York City", population: 1000000 }),
    run_query_resp_obj("cities/SF",  { name: "San Francisco", population: 1000000 }),
    run_query_resp_obj("cities/LA",  { name: "Los Angeles", population: 1000000 })
  ].to_enum
end

def run_query_resp_obj doc, data
  Google::Cloud::Firestore::V1::RunQueryResponse.new(
    transaction: "tx123",
    read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now),
    document: document_gapi(doc: doc, fields: Google::Cloud::Firestore::Convert.hash_to_fields(data))
  )
end

def run_query_args
  [Hash, Gapic::CallOptions]
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
    Google::Cloud::Firestore::V1::BatchGetDocumentsResponse.new(
      read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now),
      missing: "projects/my-project-id/databases/(default)/documents/cities/Atlantis"
    )
  ].to_enum
end

def batch_get_resp_obj doc, data
  Google::Cloud::Firestore::V1::BatchGetDocumentsResponse.new(
    read_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now),
    found: document_gapi(doc: doc, fields: Google::Cloud::Firestore::Convert.hash_to_fields(data))
  )
end

def batch_get_args
  [Hash, Gapic::CallOptions]
end

def list_documents_args
  [
    {
      parent:        "projects/my-project-id/databases/(default)/documents",
      collection_id: "cities",
      mask:          { field_paths: [] },
      show_missing:  true,
      page_size:     nil
    },
    nil
  ]
end

def document_gapi doc: "my-document", fields: {}
  Google::Cloud::Firestore::V1::Document.new(
    name: "projects/my-project-id/databases/(default)/documents/#{doc}",
    fields: fields,
    create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now),
    update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now)
  )
end

def documents_resp token: nil
  response = Google::Cloud::Firestore::V1::ListDocumentsResponse.new(
    documents: [document_gapi]
  )
  response.next_page_token = token if token
  paged_enum_struct response
end
