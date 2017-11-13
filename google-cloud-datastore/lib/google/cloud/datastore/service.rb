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


require "google/cloud/errors"
require "google/cloud/datastore/credentials"
require "google/cloud/datastore/version"
require "google/cloud/datastore/v1"
require "google/gax/errors"

module Google
  module Cloud
    module Datastore
      ##
      # @private Represents the GAX Datastore service, including all the API
      # methods.
      class Service
        attr_accessor :project, :credentials, :host, :timeout, :client_config

        ##
        # Creates a new Service instance.
        def initialize project, credentials, host: nil, timeout: nil,
                       client_config: nil
          @project = project
          @credentials = credentials
          @host = host || V1::DatastoreClient::SERVICE_ADDRESS
          @timeout = timeout
          @client_config = client_config || {}
        end

        def channel
          require "grpc"
          GRPC::Core::Channel.new host, nil, chan_creds
        end

        def chan_creds
          return credentials if insecure?
          require "grpc"
          GRPC::Core::ChannelCredentials.new.compose \
            GRPC::Core::CallCredentials.new credentials.client.updater_proc
        end

        def service
          return mocked_service if mocked_service
          @service ||= V1::DatastoreClient.new(
            service_path: host,
            credentials: channel,
            timeout: timeout,
            client_config: client_config,
            lib_name: "gccl",
            lib_version: Google::Cloud::Datastore::VERSION)
        end
        attr_accessor :mocked_service

        def insecure?
          credentials == :this_channel_is_insecure
        end

        ##
        # Allocate IDs for incomplete keys.
        # (This is useful for referencing an entity before it is inserted.)
        def allocate_ids *incomplete_keys
          execute do
            service.allocate_ids project, incomplete_keys,
                                 options: default_options
          end
        end

        ##
        # Look up entities by keys.
        def lookup *keys, consistency: nil, transaction: nil
          read_options = generate_read_options consistency, transaction

          execute do
            service.lookup project, keys,
                           read_options: read_options, options: default_options
          end
        end

        # Query for entities.
        def run_query query, namespace = nil, consistency: nil, transaction: nil
          gql_query = nil
          if query.is_a? Google::Datastore::V1::GqlQuery
            gql_query = query
            query = nil
          end
          read_options = generate_read_options consistency, transaction
          partition_id = Google::Datastore::V1::PartitionId.new(
            namespace_id: namespace) if namespace

          execute do
            service.run_query project,
                              partition_id,
                              read_options: read_options,
                              query: query,
                              gql_query: gql_query,
                              options: default_options
          end
        end

        ##
        # Begin a new transaction.
        def begin_transaction
          execute { service.begin_transaction project }
        end

        ##
        # Commit a transaction, optionally creating, deleting or modifying
        # some entities.
        def commit mutations, transaction: nil
          mode =  transaction.nil? ? :NON_TRANSACTIONAL : :TRANSACTIONAL
          execute do
            service.commit project, mode, mutations, transaction: transaction,
                                                     options: default_options
          end
        end

        ##
        # Roll back a transaction.
        def rollback transaction
          execute do
            service.rollback project, transaction, options: default_options
          end
        end

        def inspect
          "#{self.class}(#{@project})"
        end

        protected

        def generate_read_options consistency, transaction
          if consistency == :eventual
            return Google::Datastore::V1::ReadOptions.new(
              read_consistency: :EVENTUAL)
          elsif consistency == :strong
            return  Google::Datastore::V1::ReadOptions.new(
              read_consistency: :STRONG)
          elsif transaction
            return  Google::Datastore::V1::ReadOptions.new(
              transaction: transaction)
          end
          nil
        end

        def default_headers
          { "google-cloud-resource-prefix" => "projects/#{@project}" }
        end

        def default_options
          Google::Gax::CallOptions.new kwargs: default_headers
        end

        def execute
          yield
        rescue Google::Gax::GaxError => e
          # GaxError wraps BadStatus, but exposes it as #cause
          raise Google::Cloud::Error.from_error(e.cause)
        end
      end
    end
  end
end
