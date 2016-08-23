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


require "google/cloud/datastore/credentials"
require "google/datastore/v1/datastore_services_pb"
require "google/cloud/core/grpc_backoff"

module Google
  module Cloud
    module Datastore
      ##
      # @private Represents the gRPC Datastore service, including all the API
      # methods.
      class Service
        attr_accessor :project, :credentials, :host, :retries, :timeout

        ##
        # Creates a new Service instance.
        def initialize project, credentials, host: nil, retries: nil,
                       timeout: nil
          @project = project
          @credentials = credentials
          @host = host || "datastore.googleapis.com"
          @retries = retries
          @timeout = timeout
        end

        def creds
          return credentials if insecure?
          GRPC::Core::ChannelCredentials.new.compose \
            GRPC::Core::CallCredentials.new credentials.client.updater_proc
        end

        def datastore
          return mocked_datastore if mocked_datastore
          @datastore ||= Google::Datastore::V1::Datastore::Stub.new(
            host, creds, timeout: timeout)
        end
        attr_accessor :mocked_datastore

        def insecure?
          credentials == :this_channel_is_insecure
        end

        ##
        # Allocate IDs for incomplete keys.
        # (This is useful for referencing an entity before it is inserted.)
        def allocate_ids *incomplete_keys
          allocate_req = Google::Datastore::V1::AllocateIdsRequest.new(
            project_id: project,
            keys: incomplete_keys
          )

          execute { datastore.allocate_ids allocate_req }
        end

        ##
        # Look up entities by keys.
        def lookup *keys, consistency: nil, transaction: nil
          lookup_req = Google::Datastore::V1::LookupRequest.new(
            project_id: project,
            keys: keys
          )
          lookup_req.read_options = generate_read_options consistency,
                                                          transaction

          execute { datastore.lookup lookup_req }
        end

        # Query for entities.
        def run_query query, namespace = nil, consistency: nil, transaction: nil
          run_req = Google::Datastore::V1::RunQueryRequest.new(
            project_id: project)
          if query.is_a? Google::Datastore::V1::Query
            run_req["query"] = query
          elsif query.is_a? Google::Datastore::V1::GqlQuery
            run_req["gql_query"] = query
          else
            fail ArgumentError, "Unable to query with a #{query.class} object."
          end
          run_req.read_options = generate_read_options consistency, transaction

          run_req.partition_id = Google::Datastore::V1::PartitionId.new(
            namespace_id: namespace) if namespace

          execute { datastore.run_query run_req }
        end

        ##
        # Begin a new transaction.
        def begin_transaction
          tx_req = Google::Datastore::V1::BeginTransactionRequest.new(
            project_id: project
          )

          execute { datastore.begin_transaction tx_req }
        end

        ##
        # Commit a transaction, optionally creating, deleting or modifying
        # some entities.
        def commit mutations, transaction: nil
          commit_req = Google::Datastore::V1::CommitRequest.new(
            project_id: project,
            mode: :NON_TRANSACTIONAL,
            mutations: mutations
          )
          if transaction
            commit_req.mode = :TRANSACTIONAL
            commit_req.transaction = transaction
          end

          execute { datastore.commit commit_req }
        end

        ##
        # Roll back a transaction.
        def rollback transaction
          rb_req = Google::Datastore::V1::RollbackRequest.new(
            project_id: project,
            transaction: transaction
          )

          execute { datastore.rollback rb_req }
        end

        def inspect
          "#{self.class}(#{@project})"
        end

        ##
        # Performs backoff and error handling
        def execute
          Google::Cloud::Core::GrpcBackoff.new(retries: retries).execute do
            yield
          end
        rescue GRPC::BadStatus => e
          raise Google::Cloud::Error.from_error(e)
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
      end
    end
  end
end
