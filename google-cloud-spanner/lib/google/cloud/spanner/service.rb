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


require "google/cloud/spanner/errors"
require "google/cloud/spanner/credentials"
require "google/cloud/spanner/version"
require "google/cloud/spanner/v1"
require "google/cloud/spanner/admin/instance/v1"
require "google/cloud/spanner/admin/database/v1"
require "google/cloud/spanner/convert"

module Google
  module Cloud
    module Spanner
      ##
      # @private Represents the gRPC Spanner service, including all the API
      # methods.
      class Service
        attr_accessor :project, :credentials, :timeout, :host, :lib_name,
                      :lib_version

        ##
        # Creates a new Service instance.
        def initialize project, credentials,
                       host: nil, timeout: nil, lib_name: nil, lib_version: nil
          @project = project
          @credentials = credentials
          @host = host
          @timeout = timeout
          @lib_name = lib_name
          @lib_version = lib_version
        end

        def channel
          require "grpc"
          GRPC::Core::Channel.new host, chan_args, chan_creds
        end

        def chan_args
          { "grpc.service_config_disable_resolution" => 1 }
        end

        def chan_creds
          return credentials if insecure?
          require "grpc"
          GRPC::Core::ChannelCredentials.new.compose \
            GRPC::Core::CallCredentials.new credentials.client.updater_proc
        end

        def service
          return mocked_service if mocked_service
          @service ||= \
            V1::Spanner::Client.new do |config|
              config.credentials = channel
              config.timeout = timeout if timeout
              config.endpoint = host if host
              config.lib_name = lib_name_with_prefix
              config.lib_version = Google::Cloud::Spanner::VERSION
              config.metadata = { "google-cloud-resource-prefix" => "projects/#{@project}" }
            end
        end
        attr_accessor :mocked_service

        def instances
          return mocked_instances if mocked_instances
          @instances ||= \
            Admin::Instance::V1::InstanceAdmin::Client.new do |config|
              config.credentials = channel
              config.timeout = timeout if timeout
              config.endpoint = host if host
              config.lib_name = lib_name_with_prefix
              config.lib_version = Google::Cloud::Spanner::VERSION
              config.metadata = { "google-cloud-resource-prefix" => "projects/#{@project}" }
            end
        end
        attr_accessor :mocked_instances

        def databases
          return mocked_databases if mocked_databases
          @databases ||= \
            Admin::Database::V1::DatabaseAdmin::Client.new do |config|
              config.credentials = channel
              config.timeout = timeout if timeout
              config.endpoint = host if host
              config.lib_name = lib_name_with_prefix
              config.lib_version = Google::Cloud::Spanner::VERSION
              config.metadata = { "google-cloud-resource-prefix" => "projects/#{@project}" }
            end
        end
        attr_accessor :mocked_databases

        def insecure?
          credentials == :this_channel_is_insecure
        end

        def list_instances token: nil, max: nil
          paged_enum = instances.list_instances parent:     project_path,
                                                page_size:  max,
                                                page_token: token
          paged_enum.response
        end

        def get_instance name
          instances.get_instance name: instance_path(name)
        end

        def create_instance instance_id, name: nil, config: nil, nodes: nil,
                            labels: nil
          labels = Hash[labels.map { |k, v| [String(k), String(v)] }] if labels

          create_obj = Admin::Instance::V1::Instance.new({
            display_name: name, config: instance_config_path(config),
            node_count: nodes, labels: labels
          }.delete_if { |_, v| v.nil? })

          instances.create_instance parent:      project_path,
                                    instance_id: instance_id,
                                    instance:    create_obj
        end

        def update_instance instance
          mask = Google::Protobuf::FieldMask.new(
            paths: %w[display_name node_count labels]
          )

          instances.update_instance instance: instance, field_mask: mask
        end

        def delete_instance name
          instances.delete_instance name: instance_path(name)
        end

        def get_instance_policy name
          instances.get_iam_policy resource: instance_path(name)
        end

        def set_instance_policy name, new_policy
          instances.set_iam_policy resource: instance_path(name),
                                   policy:  new_policy
        end

        def test_instance_permissions name, permissions
          instances.test_iam_permissions resource:    instance_path(name),
                                         permissions: permissions
        end

        def list_instance_configs token: nil, max: nil
          paged_enum = instances.list_instance_configs \
            parent: project_path, page_size: max, page_token: token
          paged_enum.response
        end

        def get_instance_config name
          instances.get_instance_config name: instance_config_path(name)
        end

        def list_databases instance_id, token: nil, max: nil
          paged_enum = databases.list_databases \
            parent:     instance_path(instance_id),
            page_size:  max,
            page_token: token
          paged_enum.response
        end

        def get_database instance_id, database_id
          databases.get_database name: database_path(instance_id, database_id)
        end

        def create_database instance_id, database_id, statements: []
          databases.create_database \
            parent: instance_path(instance_id),
            create_statement: "CREATE DATABASE `#{database_id}`",
            extra_statements: Array(statements)
        end

        def drop_database instance_id, database_id
          databases.drop_database \
            database: database_path(instance_id, database_id)
        end

        def get_database_ddl instance_id, database_id
          databases.get_database_ddl \
            database: database_path(instance_id, database_id)
        end

        def update_database_ddl instance_id, database_id, statements: [],
                                operation_id: nil
          databases.update_database_ddl \
            database: database_path(instance_id, database_id),
            statements: Array(statements),
            operation_id: operation_id
        end

        def get_database_policy instance_id, database_id
          databases.get_iam_policy \
            resource: database_path(instance_id, database_id)
        end

        def set_database_policy instance_id, database_id, new_policy
          databases.set_iam_policy \
            resource: database_path(instance_id, database_id),
            policy:   new_policy
        end

        def test_database_permissions instance_id, database_id, permissions
          databases.test_iam_permissions \
            resource:    database_path(instance_id, database_id),
            permissions: permissions
        end

        def get_session session_name
          opts = default_options_from_session session_name
          service.get_session({ name: session_name }, opts)
        end

        def create_session database_name, labels: nil
          opts = default_options_from_session database_name
          session = V1::Session.new labels: labels if labels
          service.create_session(
            { database: database_name, session: session }, opts
          )
        end

        def batch_create_sessions database_name, session_count, labels: nil
          opts = default_options_from_session database_name
          session = V1::Session.new labels: labels if labels
          # The response may have fewer sessions than requested in the RPC.
          request = {
            database: database_name,
            session_count: session_count,
            session_template: session
          }
          service.batch_create_sessions request, opts
        end

        def delete_session session_name
          opts = default_options_from_session session_name
          service.delete_session({ name: session_name }, opts)
        end

        def execute_streaming_sql session_name, sql, transaction: nil,
                                  params: nil, types: nil, resume_token: nil,
                                  partition_token: nil, seqno: nil,
                                  query_options: nil
          opts = default_options_from_session session_name
          request =  {
            session: session_name,
            sql: sql,
            transaction: transaction,
            params: params,
            param_types: types,
            resume_token: resume_token,
            partition_token: partition_token,
            seqno: seqno,
            query_options: query_options
          }
          service.execute_streaming_sql request, opts
        end

        def execute_batch_dml session_name, transaction, statements, seqno
          opts = default_options_from_session session_name
          statements = statements.map(&:to_grpc)
          request = {
            session: session_name,
            transaction: transaction,
            statements: statements,
            seqno: seqno
          }
          results = service.execute_batch_dml request, opts

          if results.status.code.zero?
            results.result_sets.map { |rs| rs.stats.row_count_exact }
          else
            begin
              raise Google::Cloud::Error.from_error results.status
            rescue Google::Cloud::Error
              raise Google::Cloud::Spanner::BatchUpdateError.from_grpc results
            end
          end
        end

        def streaming_read_table session_name, table_name, columns, keys: nil,
                                 index: nil, transaction: nil, limit: nil,
                                 resume_token: nil, partition_token: nil
          opts = default_options_from_session session_name
          request = {
            session: session_name, table: table_name, columns: columns,
            key_set: keys, transaction: transaction, index: index,
            limit: limit, resume_token: resume_token,
            partition_token: partition_token
          }
          service.streaming_read request, opts
        end

        def partition_read session_name, table_name, columns, transaction,
                           keys: nil, index: nil, partition_size_bytes: nil,
                           max_partitions: nil
          partition_opts = partition_options partition_size_bytes,
                                             max_partitions

          opts = default_options_from_session session_name
          request = {
            session: session_name, table: table_name, key_set: keys,
            transaction: transaction, index: index, columns: columns,
            partition_options: partition_opts
          }
          service.partition_read request, opts
        end

        def partition_query session_name, sql, transaction, params: nil,
                            types: nil, partition_size_bytes: nil,
                            max_partitions: nil
          partition_opts = partition_options partition_size_bytes,
                                             max_partitions

          opts = default_options_from_session session_name
          request = {
            session: session_name, sql: sql, transaction: transaction,
            params: params, param_types: types,
            partition_options: partition_opts
          }
          service.partition_query request, opts
        end

        def commit session_name, mutations = [], transaction_id: nil
          tx_opts = nil
          if transaction_id.nil?
            tx_opts = V1::TransactionOptions.new(
              read_write: V1::TransactionOptions::ReadWrite.new
            )
          end
          opts = default_options_from_session session_name
          request = {
            session: session_name, transaction_id: transaction_id,
            single_use_transaction: tx_opts, mutations: mutations
          }
          service.commit request, opts
        end

        def rollback session_name, transaction_id
          opts = default_options_from_session session_name
          request = { session: session_name, transaction_id: transaction_id }
          service.rollback request, opts
        end

        def begin_transaction session_name
          tx_opts = V1::TransactionOptions.new(
            read_write: V1::TransactionOptions::ReadWrite.new
          )
          opts = default_options_from_session session_name
          request = { session: session_name, options: tx_opts }
          service.begin_transaction request, opts
        end

        def create_snapshot session_name, strong: nil, timestamp: nil,
                            staleness: nil
          tx_opts = V1::TransactionOptions.new(
            read_only: V1::TransactionOptions::ReadOnly.new(
              {
                strong: strong,
                read_timestamp: Convert.time_to_timestamp(timestamp),
                exact_staleness: Convert.number_to_duration(staleness),
                return_read_timestamp: true
              }.delete_if { |_, v| v.nil? }
            )
          )
          opts = default_options_from_session session_name
          request = { session: session_name, options: tx_opts }
          service.begin_transaction request, opts
        end

        def create_pdml session_name
          tx_opts = V1::TransactionOptions.new(
            partitioned_dml: V1::TransactionOptions::PartitionedDml.new
          )
          opts = default_options_from_session session_name
          request = { session: session_name, options: tx_opts }
          service.begin_transaction request, opts
        end

        def create_backup instance_id, database_id, backup_id, expire_time
          backup = {
            database: database_path(instance_id, database_id),
            expire_time: expire_time
          }
          databases.create_backup parent:    instance_path(instance_id),
                                  backup_id: backup_id,
                                  backup:    backup
        end

        def get_backup instance_id, backup_id
          databases.get_backup name: backup_path(instance_id, backup_id)
        end

        def update_backup backup, update_mask
          databases.update_backup backup: backup, update_mask: update_mask
        end

        def delete_backup instance_id, backup_id
          databases.delete_backup name: backup_path(instance_id, backup_id)
        end

        def list_backups instance_id,
                         filter: nil, page_size: nil, page_token: nil
          databases.list_backups parent:    instance_path(instance_id),
                                 filter:    filter,
                                 page_size: page_size,
                                 page_token: page_token
        end

        def list_database_operations instance_id,
                                     filter: nil,
                                     page_size: nil,
                                     page_token: nil
          databases.list_database_operations(
            parent:     instance_path(instance_id),
            filter:     filter,
            page_size:  page_size,
            page_token: page_token
          )
        end

        def list_backup_operations instance_id,
                                   filter: nil, page_size: nil,
                                   page_token: nil
          databases.list_backup_operations(
            parent:     instance_path(instance_id),
            filter:     filter,
            page_size:  page_size,
            page_token: page_token
          )
        end

        def restore_database backup_instance_id, backup_id,
                             database_instance_id, database_id
          databases.restore_database(
            parent:      instance_path(database_instance_id),
            database_id: database_id,
            backup:      backup_path(backup_instance_id, backup_id)
          )
        end

        def inspect
          "#{self.class}(#{@project})"
        end

        protected

        def lib_name_with_prefix
          return "gccl" if [nil, "gccl"].include? lib_name

          value = lib_name.dup
          value << "/#{lib_version}" if lib_version
          value << " gccl"
        end

        def default_options_from_session session_name
          default_prefix = session_name.split("/sessions/").first
          { metadata: { "google-cloud-resource-prefix" => default_prefix } }
        end

        def partition_options partition_size_bytes, max_partitions
          return nil unless partition_size_bytes || max_partitions
          partition_opts = V1::PartitionOptions.new
          if partition_size_bytes
            partition_opts.partition_size_bytes = partition_size_bytes
          end
          partition_opts.max_partitions = max_partitions if max_partitions
          partition_opts
        end

        def project_path
          Admin::Instance::V1::InstanceAdmin::Paths.project_path \
            project: project
        end

        def instance_path name
          return name if name.to_s.include? "/"

          Admin::Instance::V1::InstanceAdmin::Paths.instance_path \
            project: project, instance: name
        end

        def instance_config_path name
          return name if name.to_s.include? "/"

          Admin::Instance::V1::InstanceAdmin::Paths.instance_config_path \
            project: project, instance_config: name
        end

        def database_path instance_id, database_id
          Admin::Database::V1::DatabaseAdmin::Paths.database_path \
            project: project, instance: instance_id, database: database_id
        end

        def session_path instance_id, database_id, session_id
          V1::Spanner::Paths.session_path \
            project: project, instance: instance_id, database: database_id,
            session: session_id
        end

        def backup_path instance_id, backup_id
          Admin::Database::V1::DatabaseAdmin::Paths.backup_path \
            project: project, instance: instance_id, backup: backup_id
        end
      end
    end
  end
end
