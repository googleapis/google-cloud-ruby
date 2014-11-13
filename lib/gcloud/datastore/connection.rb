# Copyright 2014 Google Inc. All rights reserved.
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

require "faraday"

module Gcloud
  module Datastore
    ##
    # Represents the HTTP connection to the Datastore,
    # as well as the Datastore API calls.
    class Connection # :nodoc:
      API_VERSION = "v1beta2"
      API_URL = "https://www.googleapis.com"

      attr_accessor :dataset_id
      attr_accessor :credentials # :nodoc:

      ##
      # Creates a new Connection instance.
      def initialize dataset_id, credentials
        @dataset_id = dataset_id
        @credentials = credentials
      end

      ##
      # Generate IDs for an incomplete Key.
      def allocate_ids *incomplete_keys
        allocate_ids = Proto::AllocateIdsRequest.new.tap do |ai|
          ai.key = incomplete_keys
        end

        rpc_response = rpc("allocateIds", allocate_ids)
        Proto::AllocateIdsResponse.decode rpc_response
      end

      def lookup *keys
        lookup = Proto::LookupRequest.new
        lookup.key = keys

        Proto::LookupResponse.decode rpc("lookup", lookup)
      end

      def run_query query
        run_query = Proto::RunQueryRequest.new.tap do |rq|
          rq.query = query
        end

        Proto::RunQueryResponse.decode rpc("runQuery", run_query)
      end

      def begin_transaction
        tx_request = Proto::BeginTransactionRequest.new

        response_rpc = rpc "beginTransaction", tx_request
        Proto::BeginTransactionResponse.decode response_rpc
      end

      def commit mutation, transaction = nil
        mode = transaction ? Proto::CommitRequest::Mode::TRANSACTIONAL :
                             Proto::CommitRequest::Mode::NON_TRANSACTIONAL
        commit = Proto::CommitRequest.new.tap do |c|
          c.mutation = mutation
          c.mode = mode
          c.transaction = transaction
        end

        Proto::CommitResponse.decode rpc("commit", commit)
      end

      def rollback transaction
        rollback = Proto::RollbackRequest.new.tap do |r|
          r.transaction = transaction
        end

        Proto::RollbackResponse.decode rpc("rollback", rollback)
      end

      def default_http_headers # :nodoc:
        @default_http_headers ||= {
          "User-Agent"   => "gcloud-node/#{Gcloud::VERSION}",
          "Content-Type" => "application/x-protobuf" }
      end
      attr_writer :default_http_headers # :nodoc:

      def http # :nodoc:
        @http ||= Faraday.new url: API_URL
      end
      attr_writer :http # :nodoc:

      protected

      def rpc proto_method, proto_request
        response = http.post(rpc_path proto_method) do |req|
          req.headers.merge! default_http_headers
          req.body = get_proto_request_body proto_request

          @credentials.sign_http_request req
        end

        # TODO: Raise a proper error if the response is not 2xx (success)
        fail response.inspect unless response.success?
        response.body
      end

      def rpc_path proto_method
        "/datastore/#{API_VERSION}/datasets/#{dataset_id}/#{proto_method}"
      end

      def get_proto_request_body proto_request
        proto_request_body = ""
        proto_request.encode proto_request_body
        proto_request_body
      end
    end
  end
end
