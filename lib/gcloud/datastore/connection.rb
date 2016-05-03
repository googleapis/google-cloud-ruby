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
    # @private
    #
    # Represent the HTTP connection to the Datastore,
    # as well as the Datastore API calls.
    #
    # This class only deals with Protocol Buffer objects,
    # and is not part of the public API.
    class Connection
      API_VERSION = "v1beta2"
      API_URL = "https://www.googleapis.com"

      ##
      # The project/dataset_id connected to.
      attr_accessor :dataset_id

      ##
      # The Credentials object for signing HTTP requests.
      attr_accessor :credentials

      ##
      # Create a new Connection instance.
      #
      # @example
      #   conn = Gcloud::Datastore.Connection.new "my-todo-project",
      #     Gcloud::Datastore::Credentials.new("/path/to/keyfile.json")
      #
      def initialize dataset_id, credentials
        @dataset_id = dataset_id
        @credentials = credentials
      end

      ##
      # Allocate IDs for incomplete keys.
      # (This is useful for referencing an entity before it is inserted.)
      def allocate_ids *incomplete_keys
        allocate_ids = Proto::AllocateIdsRequest.new.tap do |ai|
          ai.key = incomplete_keys
        end

        rpc_response = rpc("allocateIds", allocate_ids)
        Proto::AllocateIdsResponse.decode rpc_response
      end

      ##
      # Look up entities by keys.
      def lookup *keys, consistency: nil, transaction: nil
        lookup = Proto::LookupRequest.new key: keys
        if consistency == :eventual
          lookup.read_options = Proto::ReadOptions.new(read_consistency: 2)
        elsif consistency == :strong
          lookup.read_options = Proto::ReadOptions.new(read_consistency: 1)
        elsif transaction
          lookup.read_options = Proto::ReadOptions.new(
            transaction: transaction)
        end

        Proto::LookupResponse.decode rpc("lookup", lookup)
      end

      # Query for entities.
      def run_query query, partition = nil, consistency: nil, transaction: nil
        run_query = Proto::RunQueryRequest.new.tap do |rq|
          rq.query = query
          rq.partition_id = partition if partition
        end
        if consistency == :eventual
          run_query.read_options = Proto::ReadOptions.new(read_consistency: 2)
        elsif consistency == :strong
          run_query.read_options = Proto::ReadOptions.new(read_consistency: 1)
        elsif transaction
          run_query.read_options = Proto::ReadOptions.new(
            transaction: transaction)
        end

        Proto::RunQueryResponse.decode rpc("runQuery", run_query)
      end

      ##
      # Begin a new transaction.
      def begin_transaction
        tx_request = Proto::BeginTransactionRequest.new

        response_rpc = rpc "beginTransaction", tx_request
        Proto::BeginTransactionResponse.decode response_rpc
      end

      ##
      # Commit a transaction, optionally creating, deleting or modifying
      # some entities.
      def commit mutation, transaction = nil
        mode = Proto::CommitRequest::Mode::NON_TRANSACTIONAL
        mode = Proto::CommitRequest::Mode::TRANSACTIONAL if transaction

        commit = Proto::CommitRequest.new.tap do |c|
          c.mutation = mutation
          c.mode = mode
          c.transaction = transaction
        end

        Proto::CommitResponse.decode rpc("commit", commit)
      end

      ##
      # Roll back a transaction.
      def rollback transaction
        rollback = Proto::RollbackRequest.new.tap do |r|
          r.transaction = transaction
        end

        Proto::RollbackResponse.decode rpc("rollback", rollback)
      end

      ##
      # The default HTTP headers to be sent on all API calls.
      def default_http_headers
        @default_http_headers ||= {
          "User-Agent"   => "gcloud-node/#{Gcloud::VERSION}",
          "Content-Type" => "application/x-protobuf" }
      end
      ##
      # Update the default HTTP headers.
      attr_writer :default_http_headers

      ##
      # The HTTP object that makes calls to Datastore.
      # This must be a Faraday object.
      def http
        @http ||= Faraday.new url: http_host
      end
      ##
      # Update the HTTP object.
      attr_writer :http

      ##
      # The Datastore API URL.
      def http_host
        @http_host || ENV["DATASTORE_HOST"] || API_URL
      end

      ##
      # Update the Datastore API URL.
      def http_host= new_http_host
        @http = nil # Reset the HTTP connection when host is set
        @http_host = new_http_host
      end

      def inspect
        "#{self.class}(#{@dataset_id})"
      end

      protected

      ##
      # Convenience method for making an API call to Datastore.
      # Requests will be signed with the credentials object.
      def rpc proto_method, proto_request
        response = http.post(rpc_path proto_method) do |req|
          req.headers.merge! default_http_headers
          req.body = get_proto_request_body proto_request

          @credentials.sign_http_request req
        end

        fail ApiError.new(proto_method, response) unless response.success?

        response.body
      end

      ## Generates the HTTP Path value for the API call.
      def rpc_path proto_method
        "/datastore/#{API_VERSION}/datasets/#{dataset_id}/#{proto_method}"
      end

      ##
      # Convenience method for encoding a Beefcake object to a string.
      def get_proto_request_body proto_request
        proto_request_body = ""
        proto_request.encode proto_request_body
        proto_request_body
      end
    end
  end
end
