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
  attr_reader :request_enum, :responses

  def initialize responses
    # EnumeratorQueue will return an enum that blocks
    @responses = [Google::Cloud::Firestore::EnumeratorQueue.new]
    responses.each do |response|
      @responses.last.push response

      # create a new response enum when reset is received
      if (response.response_type == :target_change &&
          response.target_change.target_change_type == :RESET)
        @responses << Google::Cloud::Firestore::EnumeratorQueue.new
      end
    end
  end

  def listen request_enum, options: nil
    @request_enum = request_enum
    # return response enumerator
    response_enum = @responses.shift
    response_enum.each
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
