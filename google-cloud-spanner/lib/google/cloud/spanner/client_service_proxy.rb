# Copyright 2019 Google LLC
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


module Google
  module Cloud
    module Spanner
      ##
      # @private
      #
      # # ClientServiceProxy
      #
      # Represents proxy Spanner service for resource based
      # routing for data client.
      class ClientServiceProxy < SimpleDelegator
        # @private
        #
        # @param [Project] project
        # @param [String] instance_id
        # @param [true, false, nil] enable_resource_based_routing.
        #   Default resource-based routing is disabled.
        #
        def initialize project, instance_id, enable_resource_based_routing: nil
          @project = project
          @instance_id = instance_id
          @enable_resource_based_routing = enable_resource_based_routing

          __setobj__ @project.service
        end

        # Get instance endpoint uri.
        #
        # @return [String] If resource-based routing is enabled then returns
        #  first endpoint uri of instance, otherwise returns default
        #  global host uri.
        def endpoint_uri
          return @endpoint_uri if @endpoint_uri

          if resource_based_routing_enabled?
            instance = @project.instance @instance_id, fields: ["endpoint_uri"]
            @endpoint_uri = instance.endpoint_uris.first if instance
          end

          @endpoint_uri ||= host
        end

        def get_session session_name
          super session_name, endpoint_uri: endpoint_uri
        end

        def create_session database_name, labels: nil
          super database_name, labels: labels, endpoint_uri: endpoint_uri
        end

        def batch_create_sessions database_name, session_count, labels: nil
          super \
            database_name,
            session_count,
            labels: labels,
            endpoint_uri: endpoint_uri
        end

        def delete_session session_name
          super session_name, endpoint_uri: endpoint_uri
        end

        def execute_streaming_sql \
            session_name, sql,
            transaction: nil,
            params: nil,
            types: nil,
            resume_token: nil,
            partition_token: nil,
            seqno: nil
          super \
            session_name, sql,
            transaction: transaction,
            params: params,
            types: types,
            resume_token: resume_token,
            partition_token: partition_token,
            seqno: seqno,
            endpoint_uri: endpoint_uri
        end

        def execute_batch_dml session_name, transaction, statements, seqno
          super \
            session_name,
            transaction,
            statements,
            seqno,
            endpoint_uri: endpoint_uri
        end

        def streaming_read_table \
            session_name,
            table_name,
            columns,
            keys: nil,
            index: nil,
            transaction: nil,
            limit: nil,
            resume_token: nil,
            partition_token: nil
          super \
            session_name,
            table_name,
            columns,
            keys: keys,
            index: index,
            transaction: transaction,
            limit: limit,
            resume_token: resume_token,
            partition_token: partition_token,
            endpoint_uri: endpoint_uri
        end

        def partition_read \
            session_name,
            table_name,
            columns,
            transaction,
            keys: nil,
            index: nil,
            partition_size_bytes: nil,
            max_partitions: nil
          super \
            session_name,
            table_name,
            columns,
            transaction,
            keys: keys,
            index: index,
            partition_size_bytes: partition_size_bytes,
            max_partitions: max_partitions,
            endpoint_uri: endpoint_uri
        end

        def partition_query \
            session_name,
            sql,
            transaction,
            params: nil,
            types: nil,
            partition_size_bytes: nil,
            max_partitions: nil
          super \
            session_name,
            sql,
            transaction,
            params: params,
            types: types,
            partition_size_bytes: partition_size_bytes,
            max_partitions: max_partitions,
            endpoint_uri: endpoint_uri
        end

        def commit session_name, mutations = [], transaction_id: nil
          super \
            session_name,
            mutations,
            transaction_id: transaction_id,
            endpoint_uri: endpoint_uri
        end

        def rollback session_name, transaction_id
          super session_name, transaction_id, endpoint_uri: endpoint_uri
        end

        def begin_transaction session_name
          super session_name, endpoint_uri: endpoint_uri
        end

        def create_snapshot \
            session_name,
            strong: nil,
            timestamp: nil,
            staleness: nil
          super \
            session_name,
            strong: strong,
            timestamp: timestamp,
            staleness: staleness,
            endpoint_uri: endpoint_uri
        end

        def create_pdml session_name
          super session_name, endpoint_uri: endpoint_uri
        end

        private

        # Check resource based routing is enabled or not.
        #
        # @return [Boolean]
        def resource_based_routing_enabled?
          case @enable_resource_based_routing
          when TrueClass
            true
          when FalseClass
            false
          when NilClass
            ENV["GOOGLE_CLOUD_ENABLE_RESOURCE_BASED_ROUTING"] == "YES"
          else
            false
          end
        end
      end
    end
  end
end
