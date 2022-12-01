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

require "simplecov"

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "google/cloud/firestore"
require "grpc"

##
# Monkey-Patch CallOptions to support Mocks
#
class Gapic::CallOptions
  ##
  # Minitest Mock depends on === to match same-value objects.
  # By default, CallOptions objects do not match with ===.
  # Therefore, we must add this capability.
  def === other
    return false unless other.is_a? Gapic::CallOptions
    timeout === other.timeout &&
      retry_policy === other.retry_policy &&
      metadata === other.metadata
  end
  def == other
    return false unless other.is_a? Gapic::CallOptions
    timeout === other.timeout &&
      retry_policy === other.retry_policy &&
      metadata === other.metadata
  end

  class RetryPolicy
    def === other
      return false unless other.is_a? Gapic::CallOptions::RetryPolicy
      retry_codes === other.retry_codes &&
        initial_delay === other.initial_delay &&
        multiplier === other.multiplier &&
        max_delay === other.max_delay &&
        delay === other.delay
    end
  end
end

class StreamingListenStub
  attr_reader :requests, :responses

  def initialize response_groups
    @requests = []
    @responses = response_groups.map do |responses|
      RaisableEnumeratorQueue.new.tap do |q|
        responses.each do |response|
          q.push response
        end
      end
    end
  end

  def listen request_enum, options
    @requests << request_enum
    @responses.shift.each
  end

  class RaisableEnumeratorQueue
    def initialize sentinel = nil
      @queue    = Queue.new
      @sentinel = sentinel
    end

    def push obj
      @queue.push obj
    end

    def each
      return enum_for(:each) unless block_given?

      loop do
        obj = @queue.pop
        # This is the only way to raise and have it be handled by the listener thread
        raise obj if obj.is_a? StandardError
        break if obj.equal? @sentinel
        yield obj
      end
    end
  end
end

class MockFirestore < Minitest::Spec
  let(:project) { "projectID" }
  let(:transaction_id) { "transaction123" }
  let(:database_path) { "projects/#{project}/databases/(default)" }
  let(:documents_path) { "#{database_path}/documents" }
  let(:full_doc_paths) {
    ["#{documents_path}/users/alice", "#{documents_path}/users/bob", "#{documents_path}/users/carol"]
  }
  let(:default_project_options) { Gapic::CallOptions.new(metadata: { "google-cloud-resource-prefix" => "projects/#{project}" }) }
  let(:default_options) { Gapic::CallOptions.new(metadata: { "google-cloud-resource-prefix" => database_path }, retry_policy: {}) }
  let(:credentials) { OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {})) }
  let(:firestore) { Google::Cloud::Firestore::Client.new(Google::Cloud::Firestore::Service.new(project, credentials)) }
  let(:firestore_mock) { Minitest::Mock.new }

  before do
    firestore.service.instance_variable_set :@firestore, firestore_mock
  end

  after do
    firestore_mock.verify
  end

  # Register this spec type for when :firestore is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_firestore
  end

  def wait_until &block
    wait_count = 0
    until block.call
      fail "wait_until criteria was not met" if wait_count > 6
      wait_count += 1
      sleep (2**wait_count) + rand(0..wait_count)
    end
  end

  def batch_get_documents_args database: database_path,
                               documents: full_doc_paths,
                               mask: nil,
                               transaction: nil,
                               new_transaction: nil
    req = {
      database: database,
      documents: documents,
      mask: mask
    }
    req[:transaction] = transaction if transaction
    req[:new_transaction] = new_transaction if new_transaction
    [req, default_options]
  end

  def commit_args database: database_path,
                  writes: [],
                  transaction: nil
    req = {
      database: database,
      writes: writes
    }
    req[:transaction] = transaction if transaction
    [req, default_options]
  end

  def list_collection_ids_args parent: "projects/#{project}/databases/(default)/documents",
                               page_size: nil,
                               page_token: nil
    [{ parent: parent, page_size: page_size, page_token: page_token }, default_options]
  end

  def list_collection_ids_resp *ids, next_page_token: nil
    Google::Cloud::Firestore::V1::ListCollectionIdsResponse.new collection_ids: ids, next_page_token: next_page_token
  end

  def run_query_args query,
                     parent: "projects/#{project}/databases/(default)/documents",
                     transaction: nil,
                     new_transaction: nil
    req = {
      parent: parent,
      structured_query: query
    }
    req[:transaction] = transaction if transaction
    req[:new_transaction] = new_transaction if new_transaction
    [req, default_options]
  end

  def partition_query_args query_grpc,
                           parent: "projects/#{project}/databases/(default)/documents",
                           partition_count: 2,
                           page_token: nil,
                           page_size: nil
    [
      Google::Cloud::Firestore::V1::PartitionQueryRequest.new(
        parent: parent,
        structured_query: query_grpc,
        partition_count: partition_count,
        page_token: page_token,
        page_size: page_size
      )
    ]
  end

  def partition_query_resp doc_ids: ["10", "20"], token: nil
    Google::Cloud::Firestore::V1::PartitionQueryResponse.new(
      partitions: doc_ids.map { |id| cursor_grpc doc_ids: [id] },
      next_page_token: token
    )
  end

  def cursor_grpc doc_ids: ["10"], before: true
    converted_values = doc_ids.map do |doc_id|
      Google::Cloud::Firestore::V1::Value.new(
        reference_value: document_path(doc_id)
      )
    end
    Google::Cloud::Firestore::V1::Cursor.new(
      values: converted_values,
      before: before
    )
  end

  def paged_enum_struct response
    OpenStruct.new response: response
  end

  def document_path doc_id
    "projects/#{project}/databases/(default)/documents/my-collection-id/#{doc_id}"
  end
end

class WatchFirestore < MockFirestore
  let(:read_time) { Time.now }

  def add_resp
    Google::Cloud::Firestore::V1::ListenResponse.new(
      target_change: Google::Cloud::Firestore::V1::TargetChange.new(
        target_change_type: :ADD
      )
    )
  end

  def reset_resp
    Google::Cloud::Firestore::V1::ListenResponse.new(
      target_change: Google::Cloud::Firestore::V1::TargetChange.new(
        target_change_type: :RESET
      )
    )
  end

  def current_resp token, offset
    Google::Cloud::Firestore::V1::ListenResponse.new(
      target_change: Google::Cloud::Firestore::V1::TargetChange.new(
        target_change_type: :CURRENT,
        resume_token: token,
        read_time: build_timestamp(offset)
      )
    )
  end

  def no_change_resp token, offset
    Google::Cloud::Firestore::V1::ListenResponse.new(
      target_change: Google::Cloud::Firestore::V1::TargetChange.new(
        target_change_type: :NO_CHANGE,
        resume_token: token,
        read_time: build_timestamp(offset)
      )
    )
  end

  def doc_change_resp doc_id, offset, data
    Google::Cloud::Firestore::V1::ListenResponse.new(
      document_change: Google::Cloud::Firestore::V1::DocumentChange.new(
        document: Google::Cloud::Firestore::V1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/watch/#{doc_id}",
          fields: Google::Cloud::Firestore::Convert.hash_to_fields(data),
          create_time: build_timestamp(offset),
          update_time: build_timestamp(offset)
        )
      )
    )
  end

  def doc_delete_resp doc_id, offset
    Google::Cloud::Firestore::V1::ListenResponse.new(
      document_delete: Google::Cloud::Firestore::V1::DocumentDelete.new(
        document: "projects/#{project}/databases/(default)/documents/watch/#{doc_id}",
        read_time: build_timestamp(offset)
      )
    )
  end

  def doc_remove_resp doc_id, offset
    Google::Cloud::Firestore::V1::ListenResponse.new(
      document_remove: Google::Cloud::Firestore::V1::DocumentRemove.new(
        document: "projects/#{project}/databases/(default)/documents/watch/#{doc_id}",
        read_time: build_timestamp(offset)
      )
    )
  end

  def filter_resp count
    Google::Cloud::Firestore::V1::ListenResponse.new(
      filter: Google::Cloud::Firestore::V1::ExistenceFilter.new(
        count: count
      )
    )
  end

  def build_timestamp offset = 0
    Google::Cloud::Firestore::Convert.time_to_timestamp(read_time + offset)
  end

  # Register this spec type for when :firestore is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :watch_firestore
  end
end
