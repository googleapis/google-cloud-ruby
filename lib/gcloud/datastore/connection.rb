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

require "gcloud"
require "json"
require "faraday"
require "signet/oauth_2/client"
require "gcloud/datastore/entity"
require "gcloud/datastore/key"
require "gcloud/datastore/query"

module Gcloud
  module Datastore
    ##
    # Datastore Entity
    #
    # See Gcloud::Datastore.new
    class Connection
      API_VERSION = "v1beta2"
      TOKEN_CREDENTIAL_URI = "https://accounts.google.com/o/oauth2/token"
      AUDIENCE = "https://accounts.google.com/o/oauth2/token"
      SCOPE = ["https://www.googleapis.com/auth/datastore",
               "https://www.googleapis.com/auth/userinfo.email"]

      attr_accessor :dataset_id

      ##
      # Creates a new Connection instance.
      # See Gcloud::Datastore.new
      def initialize dataset_id, keyfile #:nodoc:
        @dataset_id = dataset_id

        if keyfile.nil?
          fail "You must provide a keyfile to connect with."
        elsif !File.exist?(keyfile)
          fail "The keyfile '#{keyfile}' is not a valid file."
        end

        options = JSON.parse(File.read(keyfile))
        init_client! options
      end

      ##
      # Generate IDs for a Key before creating an entity.
      #
      #   conn = Gcloud::Datastore.connection
      #   empty_key = Gcloud::Datastore::Key.new "Task"
      #   task_keys = conn.allocate_ids empty_key, 5
      def allocate_ids incomplete_key, count = 1
        fail "An incomplete key must be provided." if incomplete_key.complete?

        allocate_ids = Proto::AllocateIdsRequest.new
        allocate_ids.key = count.times.map { incomplete_key.to_proto }

        rpc_response = rpc("allocateIds", allocate_ids)
        response = Proto::AllocateIdsResponse.decode rpc_response
        Array(response.key).map do |key|
          Gcloud::Datastore::Key.from_proto key
        end
      end

      # rubocop:disable all
      def save *entities
        mut = mutation

        save_entities_to_mutation entities, mut

        response = commit_rpc mut

        auto_id_assign_ids response.mutation_result.insert_auto_id_key

        entities
      end

      def find key_or_kind, id_or_name = nil
        key = key_or_kind
        unless key_or_kind.is_a?(Gcloud::Datastore::Key)
          key = Gcloud::Datastore::Key.new key_or_kind, id_or_name
        end
        find_all(key).first
      end

      def find_all *keys
        lookup = Proto::LookupRequest.new
        lookup.key = keys.map(&:to_proto)

        response = Proto::LookupResponse.decode rpc("lookup", lookup)
        Array(response.found).map do |found|
          Gcloud::Datastore::Entity.from_proto found.entity
        end
      end
      alias_method :lookup, :find_all

      def delete *entities
        mut = mutation do |m|
          m.delete = entities.map { |entity| entity.key.to_proto }
        end

        commit_rpc mut

        true
      end

      def run query
        run_query = new_run_query_request query.to_proto
        response = Proto::RunQueryResponse.decode rpc("runQuery", run_query)
        results = Array(response.batch.entity_result).map do |result|
          Gcloud::Datastore::Entity.from_proto result.entity
        end
        Gcloud::Datastore::List.new results,
                                    encode_cursor(response.batch.end_cursor)
      end

      ##
      # Runs the given block in a database transaction.
      # If no block is given the transaction object is returned.
      #
      #   user = Gcloud::Datastore::Entity.new
      #   user.key = Gcloud::Datastore::Key.new "User", "username"
      #   user["name"] = "Test"
      #   user["email"] = "test@example.net"
      #
      #   Gcloud::Datastore.connection.transaction do |tx|
      #     if tx.find(user.key).nil?
      #       tx.save user
      #     end
      #   end
      #
      # Alternatively, you can manually commit or rollback by
      # using the returned transaction object.
      #
      #   user = Gcloud::Datastore::Entity.new
      #   user.key = Gcloud::Datastore::Key.new "User", "username"
      #   user["name"] = "Test"
      #   user["email"] = "test@example.net"
      #
      #   tx = Gcloud::Datastore.connection.transaction
      #   begin
      #     if tx.find(user.key).nil?
      #       tx.save user
      #     end
      #     tx.commit
      #   rescue
      #     tx.rollback
      #   end
      def transaction
        tx = Transaction.new self
        return tx unless block_given?

        begin
          yield tx
          tx.commit
        rescue
          tx.rollback
          raise "Transaction failed to commit."
        end
      end

      protected

      def new_run_query_request query_proto
        Proto::RunQueryRequest.new.tap do |rq|
          rq.query = query_proto
        end
      end

      def encode_cursor cursor
        Array(cursor).pack("m").chomp
      end

      def init_client! options
        client_opts = {
          token_credential_uri: TOKEN_CREDENTIAL_URI,
          audience: AUDIENCE,
          scope: SCOPE,
          issuer: options["client_email"],
          signing_key: OpenSSL::PKey::RSA.new(options["private_key"])
        }

        @client = Signet::OAuth2::Client.new client_opts
        @client.fetch_access_token!
      end

      def auto_id_register entity
        @_auto_id_entities ||= []
        @_auto_id_entities << entity
      end

      def auto_id_assign_ids auto_ids
        @_auto_id_entities ||= []
        Array(auto_ids).each_with_index do |key, index|
          entity = @_auto_id_entities[index]
          entity.key = Key.from_proto key
        end
        @_auto_id_entities = []
      end

      def mutation
        # Always return a new mutation object
        mut = Proto::Mutation.new.tap do |m|
          m.upsert = []
          m.update = []
          m.insert = []
          m.insert_auto_id = []
          m.delete = []
        end
        yield mut if block_given?
        mut
      end

      def save_entities_to_mutation entities, mut
        entities.each do |entity|
          if entity.key.id.nil? && entity.key.name.nil?
            mut.insert_auto_id << entity.to_proto
            auto_id_register entity
          else
            mut.upsert << entity.to_proto
          end
        end
      end

      def commit_rpc proto_mutation #:nodoc:
        commit = Proto::CommitRequest.new
        commit.mode = Proto::CommitRequest::Mode::NON_TRANSACTIONAL
        commit.mutation = proto_mutation
        Proto::CommitResponse.decode rpc("commit", commit)
      end

      def http_headers
        { "User-Agent"   => "gcloud-node/#{Gcloud::VERSION}",
          "Content-Type" => "application/x-protobuf" }
      end

      def conn
        @conn ||= Faraday.new url: "https://www.googleapis.com"
      end

      # rubocop:disable all
      def rpc proto_method, proto_request
        # Disable rules because the complexity here is neccessary.
        proto_request_body = ""
        proto_request.encode proto_request_body
        path = "/datastore/#{API_VERSION}/datasets/#{self.dataset_id}/#{proto_method}"

        response = self.conn.post path do |req|
          req.headers.merge! http_headers
          req.body = proto_request_body

          if @client
            @client.fetch_access_token! if @client.expired?
            @client.generate_authenticated_request request: req
          end
        end

        # TODO: Raise a proper error if the response is not 2xx (success)
        raise response.inspect unless response.success?
        response.body
      end
      # rubocop:enable all
    end

    ##
    # Special Connection for Local Development Server
    #
    # See Gcloud::Datastore.devserver
    class Devserver < Connection
      def initialize dataset_id, host, port
        @dataset_id = dataset_id
        @conn = Faraday.new url: "http://#{host}:#{port}"
        @client = nil
      end
    end

    ##
    # List is a special case Array with cursor.
    #
    #   entities = Gcloud::Datastore::List.new [entity1, entity2, entity3]
    #   entities.cursor = "c3VwZXJhd2Vzb21lIQ"
    class List < DelegateClass(::Array)
      attr_accessor :cursor

      def initialize arr = [], cursor = nil
        super arr
        @cursor = cursor
      end
    end

    ##
    # Special Connection instance for running transactions.
    #
    # See Gcloud::Datastore::Connection.transaction
    class Transaction < Connection
      attr_reader :id

      def initialize connection #:nodoc:
        @dataset_id = connection.dataset_id
        @conn       = connection.conn
        @client     = connection.instance_variable_get :@client
        clear
        start
      end

      def save *entities
        save_entities_to_mutation entities, mutation
        # Do not save or assign auto_ids yet
        entities
      end

      def delete *entities
        mutation do |m|
          m.delete = entities.map { |entity| entity.key.to_proto }
        end
        # Do not delete yet
        true
      end

      def clear
        @mut = nil
        @id  = nil
        @_auto_id_entities = []
      end

      def start
        fail "Transaction already opened" unless @id.nil?
        tx_request = Proto::BeginTransactionRequest.new
        response_rpc = rpc "beginTransaction", tx_request
        response = Proto::BeginTransactionResponse.decode response_rpc
        @id = response.transaction
      end

      def commit
        fail "Cannot commit when not in a transaction" if @id.nil?
        response = commit_rpc mutation
        auto_id_assign_ids response.mutation_result.insert_auto_id_key
        true
      end

      def rollback
        fail "Cannot rollback when not in a transaction" if @id.nil?
        rollback = Proto::RollbackRequest.new
        rollback.transaction = @id
        Proto::RollbackResponse.decode rpc("rollback", rollback)
        true
      end

      protected

      def commit_rpc proto_mutation #:nodoc:
        commit = Proto::CommitRequest.new
        commit.transaction = @id
        commit.mode = Proto::CommitRequest::Mode::TRANSACTIONAL
        commit.mutation = proto_mutation
        Proto::CommitResponse.decode rpc("commit", commit)
      end

      def mutation
        # Always return the same new mutation object
        @mut ||= super() # Use parens so the block isn't passed
        yield @mut if block_given?
        @mut
      end
    end
  end
end
