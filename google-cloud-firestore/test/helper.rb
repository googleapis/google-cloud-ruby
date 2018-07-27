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

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "google/cloud/firestore"
require "grpc"

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

  def listen request_enum, options: nil
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
        # This is the only way to raise and have it be handled by the steam thread
        raise obj if obj.is_a? StandardError
        break if obj.equal? @sentinel
        yield obj
      end
    end
  end
end

class MockFirestore < Minitest::Spec
  let(:project) { "projectID" }
  let(:default_project_options) { Google::Gax::CallOptions.new(kwargs: { "google-cloud-resource-prefix" => "projects/#{project}" }) }
  let(:default_options) { Google::Gax::CallOptions.new(kwargs: { "google-cloud-resource-prefix" => "projects/#{project}/databases/(default)" }) }
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
      fail "wait_until criterial was not met" if wait_count > 100
      wait_count += 1
      sleep 0.01
    end
  end
end

class WatchFirestore < MockFirestore
  let(:read_time) { Time.now }

  def add_resp
    Google::Firestore::V1beta1::ListenResponse.new(
      target_change: Google::Firestore::V1beta1::TargetChange.new(
        target_change_type: :ADD
      )
    )
  end

  def reset_resp
    Google::Firestore::V1beta1::ListenResponse.new(
      target_change: Google::Firestore::V1beta1::TargetChange.new(
        target_change_type: :RESET
      )
    )
  end

  def current_resp token, offset
    Google::Firestore::V1beta1::ListenResponse.new(
      target_change: Google::Firestore::V1beta1::TargetChange.new(
        target_change_type: :CURRENT,
        resume_token: token,
        read_time: build_timestamp(offset)
      )
    )
  end

  def no_change_resp token, offset
    Google::Firestore::V1beta1::ListenResponse.new(
      target_change: Google::Firestore::V1beta1::TargetChange.new(
        target_change_type: :NO_CHANGE,
        resume_token: token,
        read_time: build_timestamp(offset)
      )
    )
  end

  def doc_change_resp doc_id, offset, data
    Google::Firestore::V1beta1::ListenResponse.new(
      document_change: Google::Firestore::V1beta1::DocumentChange.new(
        document: Google::Firestore::V1beta1::Document.new(
          name: "projects/#{project}/databases/(default)/documents/watch/#{doc_id}",
          fields: Google::Cloud::Firestore::Convert.hash_to_fields(data),
          create_time: build_timestamp(offset),
          update_time: build_timestamp(offset)
        )
      )
    )
  end

  def doc_delete_resp doc_id, offset
    Google::Firestore::V1beta1::ListenResponse.new(
      document_delete: Google::Firestore::V1beta1::DocumentDelete.new(
        document: "projects/#{project}/databases/(default)/documents/watch/#{doc_id}",
        read_time: build_timestamp(offset)
      )
    )
  end

  def doc_remove_resp doc_id, offset
    Google::Firestore::V1beta1::ListenResponse.new(
      document_remove: Google::Firestore::V1beta1::DocumentRemove.new(
        document: "projects/#{project}/databases/(default)/documents/watch/#{doc_id}",
        read_time: build_timestamp(offset)
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
