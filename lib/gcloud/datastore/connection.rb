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

      # rubocop:disable all
      def save *entities
        # Disable rules because the complexity here is neccessary.
        commit = Proto::CommitRequest.new
        commit.mode = Proto::CommitRequest::Mode::NON_TRANSACTIONAL

        auto_ids = [] # store entities that are getting new ids

        commit.mutation = Proto::Mutation.new.tap do |mutation|
          entities.each do |entity|
            if entity.key.id.nil? && entity.key.name.nil?
              mutation.insert_auto_id ||= []
              mutation.insert_auto_id << entity.to_proto
              auto_ids << entity
            else
              mutation.upsert ||= []
              mutation.upsert << entity.to_proto
            end
          end
        end

        response = Proto::CommitResponse.decode rpc("commit", commit)

        # Assign the newly created id to the entity
        new_auto_ids = Array(response.mutation_result.insert_auto_id_key)
        new_auto_ids.each_with_index do |key, index|
          entity = auto_ids[index]
          entity.key = Key.from_proto key
        end
        entities
      end
      # rubocop:enable all

      def find kind, id_or_name
        lookup(Key.new(kind, id_or_name)).first
      end

      def lookup *keys
        lookup = Proto::LookupRequest.new
        lookup.key = keys.map(&:to_proto)

        response = Proto::LookupResponse.decode rpc("lookup", lookup)
        Array(response.found).map do |found|
          Gcloud::Datastore::Entity.from_proto found.entity
        end
      end

      def delete *entities
        commit = Proto::CommitRequest.new
        commit.mode = Proto::CommitRequest::Mode::NON_TRANSACTIONAL
        commit.mutation = Proto::Mutation.new
        commit.mutation.delete = entities.map { |entity| entity.key.to_proto }

        Proto::CommitResponse.decode rpc("commit", commit)

        true
      end

      protected

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
  end
end
