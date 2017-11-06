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
end
