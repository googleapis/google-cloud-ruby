# Copyright 2016 Google LLC
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


require "google/cloud/errors"
require "google/cloud/datastore/credentials"
require "google/cloud/datastore/version"
require "google/cloud/datastore/v1"

module Google
  module Cloud
    module Datastore
      ##
      # @private Represents the GAX Datastore service, including all the API
      # methods.
      class Service
        attr_accessor :project, :credentials, :host, :timeout

        ##
        # Creates a new Service instance.
        def initialize project, credentials, host: nil, timeout: nil
          @project = project
          @credentials = credentials
          @host = host
          @timeout = timeout
        end

        def service
          return mocked_service if mocked_service
          @service ||= V1::Datastore::Client.new do |config|
            config.credentials = credentials if credentials
            config.timeout = timeout if timeout
            config.endpoint = host if host
            config.lib_name = "gccl"
            config.lib_version = Google::Cloud::Datastore::VERSION
            config.metadata = { "google-cloud-resource-prefix": "projects/#{@project}" }
          end
        end
        attr_accessor :mocked_service

        ##
        # Allocate IDs for incomplete keys.
        # (This is useful for referencing an entity before it is inserted.)
        def allocate_ids *incomplete_keys
          service.allocate_ids project_id: project, keys: incomplete_keys
        end

        ##
        # Look up entities by keys.
        def lookup *keys, consistency: nil, transaction: nil
          read_options = generate_read_options consistency, transaction

          service.lookup project_id: project, keys: keys, read_options: read_options
        end

        # Query for entities.
        def run_query query, namespace = nil, consistency: nil, transaction: nil
          gql_query = nil
          if query.is_a? Google::Cloud::Datastore::V1::GqlQuery
            gql_query = query
            query = nil
          end
          read_options = generate_read_options consistency, transaction
          if namespace
            partition_id = Google::Cloud::Datastore::V1::PartitionId.new(
              namespace_id: namespace
            )
          end

          service.run_query project_id: project,
                            partition_id: partition_id,
                            read_options: read_options,
                            query: query,
                            gql_query: gql_query
        end

        ##
        # Begin a new transaction.
        def begin_transaction read_only: nil, previous_transaction: nil
          if read_only
            transaction_options = Google::Cloud::Datastore::V1::TransactionOptions.new
            transaction_options.read_only = \
              Google::Cloud::Datastore::V1::TransactionOptions::ReadOnly.new
          end
          if previous_transaction
            transaction_options ||= \
              Google::Cloud::Datastore::V1::TransactionOptions.new
            rw = Google::Cloud::Datastore::V1::TransactionOptions::ReadWrite.new(
              previous_transaction: previous_transaction.encode("ASCII-8BIT")
            )
            transaction_options.read_write = rw
          end
          service.begin_transaction project_id: project, transaction_options: transaction_options
        end

        ##
        # Commit a transaction, optionally creating, deleting or modifying
        # some entities.
        def commit mutations, transaction: nil
          mode = transaction.nil? ? :NON_TRANSACTIONAL : :TRANSACTIONAL
          service.commit project_id: project, mode: mode, mutations: mutations, transaction: transaction
        end

        ##
        # Roll back a transaction.
        def rollback transaction
          service.rollback project_id: project, transaction: transaction
        end

        def inspect
          "#{self.class}(#{@project})"
        end

        protected

        def generate_read_options consistency, transaction
          if consistency == :eventual
            return Google::Cloud::Datastore::V1::ReadOptions.new(
              read_consistency: :EVENTUAL
            )
          elsif consistency == :strong
            return Google::Cloud::Datastore::V1::ReadOptions.new(
              read_consistency: :STRONG
            )
          elsif transaction
            return Google::Cloud::Datastore::V1::ReadOptions.new(
              transaction: transaction
            )
          end
          nil
        end
      end
    end
  end
end
