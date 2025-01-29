# frozen_string_literal: true

# Copyright 2025 Google LLC
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

require "google/cloud/bigtable/admin/v2/bigtable_table_admin"

describe "::Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin::Client helpers" do
  class ClientStub
    attr_accessor :responses

    def initialize
      @blocks = []
      @responses = []
    end

    def expect &block
      @blocks << block
    end

    def expectations_empty?
      @blocks.empty?
    end

    def call_rpc *args, **kwargs
      raise "No more expectations" if expectations_empty?
      response = @blocks.shift.call(*args, **kwargs)
      @responses << response
      operation = GRPC::ActiveCall::Operation.new nil
      catch :response do
        yield response, operation if block_given?
        response
      end
    end

    def endpoint
      "endpoint.example.com"
    end

    def universe_domain
      "example.com"
    end

    def stub_logger
      nil
    end

    def logger
      nil
    end
  end

  let(:table_name) { "projects/my-project/instances/my-instance/tables/my-table" }
  let(:consistency_token) { "blahblah12345" }
  let(:generation_response) {
    ::Google::Cloud::Bigtable::Admin::V2::GenerateConsistencyTokenResponse.new consistency_token: consistency_token
  }
  let(:inconsistent_response) {
    ::Google::Cloud::Bigtable::Admin::V2::CheckConsistencyResponse.new consistent: false
  }
  let(:consistent_response) {
    ::Google::Cloud::Bigtable::Admin::V2::CheckConsistencyResponse.new consistent: true
  }
  let(:grpc_channel) { GRPC::Core::Channel.new "localhost:8888", nil, :this_channel_is_insecure }

  describe "#wait_for_replication" do
    it "detects immediate return" do
      client_stub = ClientStub.new
      client_stub.expect do |name, request, options:|
        assert_equal :generate_consistency_token, name
        assert_equal table_name, request.name
        generation_response
      end
      client_stub.expect do |name, request, options:|
        assert_equal :check_consistency, name
        assert_equal table_name, request.name
        assert_equal consistency_token, request.consistency_token
        consistent_response
      end

      Gapic::ServiceStub.stub :new, client_stub do
        client = ::Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin::Client.new do |config|
          config.credentials = grpc_channel
        end
        assert_nil client.wait_for_replication(table_name, mock_delay: true)
        assert client_stub.expectations_empty?
      end
    end

    it "detects return after two tries" do
      client_stub = ClientStub.new
      client_stub.expect do |name, request, options:|
        assert_equal :generate_consistency_token, name
        assert_equal table_name, request.name
        generation_response
      end
      client_stub.expect do |name, request, options:|
        assert_equal :check_consistency, name
        assert_equal table_name, request.name
        assert_equal consistency_token, request.consistency_token
        inconsistent_response
      end
      client_stub.expect do |name, request, options:|
        assert_equal :check_consistency, name
        assert_equal table_name, request.name
        assert_equal consistency_token, request.consistency_token
        consistent_response
      end

      Gapic::ServiceStub.stub :new, client_stub do
        client = ::Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin::Client.new do |config|
          config.credentials = grpc_channel
        end
        assert_nil client.wait_for_replication(table_name, mock_delay: true)
        assert client_stub.expectations_empty?
      end
    end

    it "times out and returns the token" do
      client_stub = ClientStub.new
      client_stub.expect do |name, request, options:|
        assert_equal :generate_consistency_token, name
        assert_equal table_name, request.name
        generation_response
      end
      client_stub.expect do |name, request, options:|
        assert_equal :check_consistency, name
        assert_equal table_name, request.name
        assert_equal consistency_token, request.consistency_token
        inconsistent_response
      end
      client_stub.expect do |name, request, options:|
        assert_equal :check_consistency, name
        assert_equal table_name, request.name
        assert_equal consistency_token, request.consistency_token
        inconsistent_response
      end

      Gapic::ServiceStub.stub :new, client_stub do
        client = ::Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin::Client.new do |config|
          config.credentials = grpc_channel
        end
        token = client.wait_for_replication(table_name, timeout: 1.5, mock_delay: true)
        assert_equal consistency_token, token
        assert client_stub.expectations_empty?
      end
    end

    it "supports passing in the token" do
      client_stub = ClientStub.new
      client_stub.expect do |name, request, options:|
        assert_equal :check_consistency, name
        assert_equal table_name, request.name
        assert_equal consistency_token, request.consistency_token
        consistent_response
      end

      Gapic::ServiceStub.stub :new, client_stub do
        client = ::Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin::Client.new do |config|
          config.credentials = grpc_channel
        end
        assert_nil client.wait_for_replication(table_name, consistency_token: consistency_token, mock_delay: true)
        assert client_stub.expectations_empty?
      end
    end
  end

end
