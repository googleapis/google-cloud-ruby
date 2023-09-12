# frozen_string_literal: true

# Copyright 2018 Google LLC
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


require "google/cloud/bigtable/version"
require "google/cloud/bigtable/errors"
require "google/cloud/bigtable/credentials"
require "google/cloud/bigtable/v2"
require "google/cloud/bigtable/admin/v2"
require "google/cloud/bigtable/convert"
require "gapic/lru_hash"
require "concurrent"

module Google
  module Cloud
    module Bigtable
      # @private
      # gRPC Cloud Bigtable service, including API methods.
      class Service
        # @private
        attr_accessor :project_id, :credentials, :host, :host_admin, :timeout

        # @private
        # Creates a new Service instance.
        #
        # @param project_id [String] Project identifier
        # @param credentials [Google::Auth::Credentials, String, Hash, GRPC::Core::Channel,
        #   GRPC::Core::ChannelCredentials, Proc]
        #   The means for authenticating requests made by the client. This parameter can be one of the following types.
        #   `Google::Auth::Credentials` uses the properties of its represented keyfile for authenticating requests made
        #   by this client.
        #   `String` will be treated as the path to the keyfile to use to construct credentials for this client.
        #   `Hash` will be treated as the contents of a keyfile to use to construct credentials for this client.
        #   `GRPC::Core::Channel` will be used to make calls through.
        #   `GRPC::Core::ChannelCredentials` will be used to set up the gRPC client. The channel credentials should
        #   already be composed with a `GRPC::Core::CallCredentials` object.
        #   `Proc` will be used as an updater_proc for the gRPC channel. The proc transforms the metadata for requests,
        #   generally, to give OAuth credentials.
        # @param timeout [Integer]
        #   The default timeout, in seconds, for calls made through this client.
        #
        def initialize project_id, credentials, host: nil, host_admin: nil, timeout: nil,
                       channel_selection: nil, channel_count: nil
          @project_id = project_id
          @credentials = credentials
          @host = host
          @host_admin = host_admin
          @timeout = timeout
          @channel_selection = channel_selection
          @channel_count = channel_count
          @bigtable_clients = ::Gapic::LruHash.new 10
          @mutex = Mutex.new
        end

        def instances
          return mocked_instances if mocked_instances
          @instances ||= Admin::V2::BigtableInstanceAdmin::Client.new do |config|
            config.credentials = credentials if credentials
            config.timeout = timeout if timeout
            config.endpoint = host_admin if host_admin
            config.lib_name = "gccl"
            config.lib_version = Google::Cloud::Bigtable::VERSION
            config.metadata = { "google-cloud-resource-prefix": "projects/#{@project_id}" }
          end
        end
        attr_accessor :mocked_instances

        def tables
          return mocked_tables if mocked_tables
          @tables ||= Admin::V2::BigtableTableAdmin::Client.new do |config|
            config.credentials = credentials if credentials
            config.timeout = timeout if timeout
            config.endpoint = host_admin if host_admin
            config.lib_name = "gccl"
            config.lib_version = Google::Cloud::Bigtable::VERSION
            config.metadata = { "google-cloud-resource-prefix": "projects/#{@project_id}" }
          end
        end
        attr_accessor :mocked_tables

        def client table_path, app_profile_id
          return mocked_client if mocked_client
          table_key = "#{table_path}_#{app_profile_id}"
          @mutex.synchronize do
            if @bigtable_clients.get(table_key).nil?
              bigtable_client = create_bigtable_client table_path, app_profile_id
              @bigtable_clients.put table_key, bigtable_client
            end
            @bigtable_clients.get table_key
          end
        end
        attr_accessor :mocked_client

        ##
        # Creates an instance within a project.
        #
        # @param instance_id [String]
        #   The permanent identifier to be used for the new instance.
        #
        # @param instance [Google::Cloud::Bigtable::Admin::V2::Instance | Hash]
        # @param clusters [Hash{String => Google::Cloud::Bigtable::Admin::V2::Cluster | Hash}]
        #   The clusters to be created in the instance.
        #   Note that the cluster ID is the last segment of a cluster name. In the
        #   following cluster name, 'mycluster' is the cluster ID:
        #   +projects/myproject/instances/myinstance/clusters/mycluster+.
        #   Alternatively, provide a hash in the form of `Google::Cloud::Bigtable::Admin::V2::Cluster`
        # @return [Gapic::Operation]
        #
        def create_instance instance_id, instance, clusters
          instances.create_instance parent:      project_path,
                                    instance_id: instance_id,
                                    instance:    instance,
                                    clusters:    clusters
        end

        ##
        # Lists the instances in a project.
        #
        # @param token [String]
        #   The value of +next_page_token+ returned by a previous call.
        # @return [Google::Cloud::Bigtable::Admin::V2::ListInstancesResponse]
        #
        def list_instances token: nil
          instances.list_instances parent: project_path, page_token: token
        end

        ##
        # Gets information about an instance.
        #
        # @param instance_id [String]
        #   Unique ID of the requested instance.
        # @return [Google::Cloud::Bigtable::Admin::V2::Instance]
        #
        def get_instance instance_id
          instances.get_instance name: instance_path(instance_id)
        end

        ##
        # Partially updates an instance.
        #
        # @param instance [Google::Cloud::Bigtable::Admin::V2::Instance | Hash]
        #   The instance that will (partially) replace the current value.
        #   Alternatively, provide a hash in the form of `Google::Cloud::Bigtable::Admin::V2::Instance.
        # @param update_mask [Google::Protobuf::FieldMask | Hash]
        #   List of instance properties to be replaced.
        #   Must be explicitly set.
        #   Alternatively, provide a hash in the form of `Google::Protobuf::FieldMask`.
        # @return [Gapic::Operation]
        #
        def partial_update_instance instance, update_mask
          instances.partial_update_instance instance: instance, update_mask: update_mask
        end

        ##
        # Deletes an instance from a project.
        #
        # @param instance_id [String]
        #   Unique ID of the instance to be deleted.
        #
        def delete_instance instance_id
          instances.delete_instance name: instance_path(instance_id)
        end

        ##
        # Creates a cluster within an instance.
        #
        # @param instance_id [String]
        #   Unique ID of the instance in which to create the new cluster
        # @param cluster_id [String]
        #   Unique permanent identifier for the new cluster
        # @param cluster [Google::Cloud::Bigtable::Admin::V2::Cluster | Hash]
        #   The cluster to be created.
        #   Alternatively, provide a hash in the form of `Google::Cloud::Bigtable::Admin::V2::Cluster`
        #
        # @return [Gapic::Operation]
        #
        def create_cluster instance_id, cluster_id, cluster
          cluster.location = location_path cluster.location unless cluster.location == ""

          instances.create_cluster parent: instance_path(instance_id), cluster_id: cluster_id, cluster: cluster
        end

        ##
        # Lists information about clusters in an instance.
        #
        # @param instance_id [String]
        #   Unique ID of the instance for which a list of clusters is requested.
        # @param token [String]
        #   The value of +next_page_token+ returned by a previous call.
        # @return [Google::Cloud::Bigtable::Admin::V2::ListClustersResponse]
        #
        def list_clusters instance_id, token: nil
          instances.list_clusters parent: instance_path(instance_id), page_token: token
        end

        ##
        # Gets information about a cluster.
        #
        # @param instance_id [String]
        #   Unique ID of the instance the cluster is in.
        # @param cluster_id [String]
        #   Unique ID of the requested cluster.
        # @return [Google::Cloud::Bigtable::Admin::V2::Cluster]
        #
        def get_cluster instance_id, cluster_id
          instances.get_cluster name: cluster_path(instance_id, cluster_id)
        end

        ##
        # Updates a cluster within an instance.
        #
        # @param instance_id [String]
        #   Unique ID of the instance the cluster is in.
        # @param cluster_id [String]
        #   Unique ID of the cluster.
        # @param location [String]
        #   Location of this cluster's nodes and storage. For best
        #   performance, clients should be located as close as possible to this
        #   cluster. Requird format for the location string:
        #   +projects/<project>/locations/<zone>+.
        # @param serve_nodes [Integer]
        #   The number of nodes allocated to this cluster. More nodes enable higher
        #   throughput and more consistent performance.
        # @return [Gapic::Operation]
        #
        def update_cluster instance_id, cluster_id, location, serve_nodes
          instances.update_cluster name:        cluster_path(instance_id, cluster_id),
                                   location:    location,
                                   serve_nodes: serve_nodes
        end

        ##
        # Deletes a cluster from an instance.
        #
        # @param instance_id [String]
        #   Unique ID of the instance the cluster is in.
        # @param cluster_id [String]
        #    Unique ID of the cluster to be deleted.
        #
        def delete_cluster instance_id, cluster_id
          instances.delete_cluster name: cluster_path(instance_id, cluster_id)
        end

        ##
        # Creates a new table in the specified instance.
        # Optionally, creates the table with a full set of initial column families.
        #
        # @param instance_id [String]
        #   Unique ID of the instance to create the table in.
        # @param table_id [String]
        #   Unique, permanent identifier for the new table.
        # @param table [Google::Cloud::Bigtable::Admin::V2::Table | Hash]
        #   The table to create.
        #   Alternatively, provide a hash in the form of `Google::Cloud::Bigtable::Admin::V2::Table`.
        # @param initial_splits [Array<Google::Cloud::Bigtable::Admin::V2::CreateTableRequest::Split | Hash>]
        #   The optional list of row keys that will be used to initially split the
        #   table into several tablets (tablets are similar to HBase regions).
        #   Given two split keys, +s1+ and +s2+, three tablets will be created,
        #   spanning the key ranges: +[, s1), [s1, s2), [s2, )+.
        #
        #   Example:
        #
        #   * Row keys := +["a", "apple", "custom", "customer_1", "customer_2",+
        #     +"other", "zz"]+
        #   * initial_split_keys := +["apple", "customer_1", "customer_2", "other"]+
        #   * Key assignment:
        #     * Tablet 1 +[, apple)                => {"a"}.+
        #       * Tablet 2 +[apple, customer_1)      => {"apple", "custom"}.+
        #       * Tablet 3 +[customer_1, customer_2) => {"customer_1"}.+
        #       * Tablet 4 +[customer_2, other)      => {"customer_2"}.+
        #       * Tablet 5 +[other, )                => {"other", "zz"}.+
        #   Alternatively, provide a hash in the form of
        #   `Google::Cloud::Bigtable::Admin::V2::CreateTableRequest::Split`
        # @return [Google::Cloud::Bigtable::Admin::V2::Table]
        #
        def create_table instance_id, table_id, table, initial_splits: nil
          initial_splits = initial_splits.map { |key| { key: key } } if initial_splits

          tables.create_table(
            **{
              parent:         instance_path(instance_id),
              table_id:       table_id,
              table:          table,
              initial_splits: initial_splits
            }.compact
          )
        end

        ##
        # Lists all tables in an instance.
        #
        # @param instance_id [String]
        #   Unique ID of the instance for which tables should be listed.
        # @param view [Google::Cloud::Bigtable::Admin::V2::Table::View]
        #   View to be applied to the returned tables' fields.
        #   Defaults to +NAME_ONLY+ if unspecified; no others are currently supported.
        # @return [Gapic::PagedEnumerable<Google::Cloud::Bigtable::Admin::V2::Table>]
        #   An enumerable of Google::Cloud::Bigtable::Admin::V2::Table instances.
        #   See Gapic::PagedEnumerable documentation for other
        #   operations such as per-page iteration or access to the response.
        #
        def list_tables instance_id, view: nil
          tables.list_tables parent: instance_path(instance_id), view: view
        end

        ##
        # Gets metadata about the specified table.
        #
        # @param instance_id [String]
        #   Unique ID of the instance the table is in.
        # @param table_id [String]
        #   Unique ID of the requested table.
        # @param view [Google::Cloud::Bigtable::Admin::V2::Table::View]
        #   View to be applied to the returned table's fields.
        #   Defaults to +SCHEMA_VIEW+ if unspecified.
        # @return [Google::Cloud::Bigtable::Admin::V2::Table]
        #
        def get_table instance_id, table_id, view: nil
          tables.get_table name: table_path(instance_id, table_id), view: view
        end

        ##
        # Permanently deletes a table and all of its data.
        #
        # @param instance_id [String]
        #   Unique ID of the instance the table is in.
        # @param table_id [String]
        #   Unique ID of the table to be deleted.
        #
        def delete_table instance_id, table_id
          tables.delete_table name: table_path(instance_id, table_id)
        end

        ##
        # Performs a series of column family modifications on the specified table.
        # Either all or none of the modifications will occur before this method
        # returns. Data requests received prior to completion of this method may reach a table
        # in which only some modifications have taken effect.
        #
        # @param instance_id [String]
        #   Unique ID of the instance the table is in.
        # @param table_id [String]
        #   Unique ID of the table whose families should be modified.
        # @param modifications
        #   [Array<Google::Cloud::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification | Hash>]
        #   Modifications to be atomically applied to the specified table's families.
        #   Entries are applied in order, meaning that earlier modifications can be
        #   masked by later ones (in the case of repeated updates to the same family,
        #   for example).
        #   Alternatively, provide a hash in the form of
        #    `Google::Cloud::Bigtable::Admin::V2::ModifyColumnFamiliesRequest::Modification`.
        # @return [Google::Cloud::Bigtable::Admin::V2::Table]
        #
        def modify_column_families instance_id, table_id, modifications
          tables.modify_column_families name: table_path(instance_id, table_id), modifications: modifications
        end

        ##
        # Generates a consistency token for a table.
        # The consistency token can be be used in CheckConsistency to check whether
        # mutations to the table that finished before this call started have been replicated.
        # The token will be available for 90 days.
        #
        # @param instance_id [String]
        #   Unique ID of the instance the table is in.
        # @param table_id [String]
        #   Unique ID of the table the consistency token is for.
        # @return [Google::Cloud::Bigtable::Admin::V2::GenerateConsistencyTokenResponse]
        #
        def generate_consistency_token instance_id, table_id
          tables.generate_consistency_token name: table_path(instance_id, table_id)
        end

        ##
        # Checks replication consistency based on a consistency token.
        # Determines if replication has caught up, based on the conditions in the token
        # and the check request.
        #
        # @param instance_id [String]
        #   Unique ID of the instance the table is in.
        # @param table_id [String]
        #   Unique ID of the table to check for replication consistency.
        # @param token [String] Consistency token
        #   The token created for the table using GenerateConsistencyToken.
        # @return [Google::Cloud::Bigtable::Admin::V2::CheckConsistencyResponse]
        #
        def check_consistency instance_id, table_id, token
          tables.check_consistency name: table_path(instance_id, table_id), consistency_token: token
        end

        ##
        # Permanently deletes a row range from a table. The request can
        # specify whether to delete all rows in a table or only rows that match a
        # particular row key prefix.
        #
        # @param instance_id [String]
        #   Unique ID of the instance the table is in.
        # @param table_id [String]
        #   Unique ID of the table to delete a range of rows from.
        # @param row_key_prefix [String]
        #   All rows whose row keys start with this row key prefix will be deleted.
        #   Prefix cannot be zero length.
        # @param delete_all_data_from_table [true, false]
        #   If true, delete all rows in the table. Setting this to false is a no-op.
        # @param timeout [Integer] Seconds. Sets the API call timeout if deadline exceeds exception.
        #
        def drop_row_range instance_id, table_id, row_key_prefix: nil, delete_all_data_from_table: nil, timeout: nil
          call_options = nil

          # Pass a timeout with a larger value if the drop operation throws
          # an error for timeout time.
          if timeout
            retry_policy = Gapic::CallOptions::RetryPolicy.new max_delay: timeout * 1000
            call_options = Gapic::CallOptions.new retry_policy: retry_policy
          end

          tables.drop_row_range(
            {
              name:                       table_path(instance_id, table_id),
              row_key_prefix:             row_key_prefix,
              delete_all_data_from_table: delete_all_data_from_table
            },
            call_options
          )
        end

        ##
        # Creates an app profile within an instance.
        #
        # @param instance_id [String]
        #   Unique ID of the instance.
        # @param app_profile_id [String]
        #   The permanent identifier for the new app profile within its
        #   instance.
        # @param app_profile [Google::Cloud::Bigtable::Admin::V2::AppProfile | Hash]
        #   The app profile to be created.
        #   Alternatively, provide a hash in the form of `Google::Cloud::Bigtable::Admin::V2::AppProfile`.
        # @param ignore_warnings [Boolean]
        #   If true, ignore safety checks when creating the app profile.
        # @return [Google::Cloud::Bigtable::Admin::V2::AppProfile]
        #
        def create_app_profile instance_id, app_profile_id, app_profile, ignore_warnings: nil
          instances.create_app_profile parent:          instance_path(instance_id),
                                       app_profile_id:  app_profile_id,
                                       app_profile:     app_profile,
                                       ignore_warnings: ignore_warnings
        end

        ##
        # Gets information about an app profile.
        #
        # @param instance_id [String]
        #   Unique ID of the instance.
        # @param app_profile_id [String]
        #   Unique ID of the requested app profile.
        # @return [Google::Cloud::Bigtable::Admin::V2::AppProfile]
        #
        def get_app_profile instance_id, app_profile_id
          instances.get_app_profile name: app_profile_path(instance_id, app_profile_id)
        end

        ##
        # Lists information about app profiles in an instance.
        #
        # @param instance_id [String]
        #   Unique ID of the instance
        # @return [Gapic::PagedEnumerable<Google::Cloud::Bigtable::Admin::V2::AppProfile>]
        #   An enumerable of Google::Cloud::Bigtable::Admin::V2::AppProfile instances.
        #   See Gapic::PagedEnumerable documentation for other
        #   operations such as per-page iteration or access to the response
        #   object.
        #
        def list_app_profiles instance_id
          instances.list_app_profiles parent: instance_path(instance_id)
        end

        ##
        # Updates an app profile within an instance.
        #
        # @param app_profile [Google::Cloud::Bigtable::Admin::V2::AppProfile | Hash]
        #   The app profile that will (partially) replace the current value.
        #   Alternatively, provide a hash in the form of
        #   `Google::Cloud::Bigtable::Admin::V2::AppProfile`.
        # @param update_mask [Google::Protobuf::FieldMask | Hash]
        #   The subset of app profile fields that should be replaced.
        #   If unset, all fields will be replaced.
        #   Alternatively, provide a hash similar to `Google::Protobuf::FieldMask`.
        # @param ignore_warnings [Boolean]
        #   If true, ignore safety checks when updating the app profile.
        # @return [Google::Longrunning::Operation]
        #
        def update_app_profile app_profile, update_mask, ignore_warnings: nil
          instances.update_app_profile app_profile:     app_profile,
                                       update_mask:     update_mask,
                                       ignore_warnings: ignore_warnings
        end

        ##
        # Deletes an app profile from an instance.
        #
        # @param instance_id [String]
        #   Unique ID of the instance.
        # @param app_profile_id [String]
        #   Unique ID of the app profile to be deleted.
        # @param ignore_warnings [Boolean]
        #   If true, ignore safety checks when deleting the app profile.
        #
        def delete_app_profile instance_id, app_profile_id, ignore_warnings: nil
          instances.delete_app_profile name:            app_profile_path(instance_id, app_profile_id),
                                       ignore_warnings: ignore_warnings
        end

        ##
        # Gets the access control policy for an backup resource. Returns an empty
        # policy if an backup exists but does not have a policy set.
        #
        # @return [Google::Iam::V1::Policy]
        #
        def get_backup_policy instance_id, cluster_id, backup_id
          tables.get_iam_policy resource: backup_path(instance_id, cluster_id, backup_id)
        end

        ##
        # Sets the access control policy on an backup resource. Replaces any
        # existing policy.
        #
        # @param policy [Google::Iam::V1::Policy | Hash]
        #   REQUIRED: The complete policy to be applied to the +resource+. The size of
        #   the policy is limited to a few 10s of KB. An empty policy is valid
        #   for Cloud Bigtable, but certain Cloud Platform services (such as Projects)
        #   might reject an empty policy.
        #   Alternatively, provide a hash similar to `Google::Iam::V1::Policy`.
        # @return [Google::Iam::V1::Policy]
        #
        def set_backup_policy instance_id, cluster_id, backup_id, policy
          tables.set_iam_policy resource: backup_path(instance_id, cluster_id, backup_id), policy: policy
        end

        ##
        # Returns permissions that the caller has for the specified backup resource.
        #
        # @param permissions [Array<String>]
        #   The set of permissions to check for the +resource+. Permissions with
        #   wildcards (such as '*' or 'storage.*') are not allowed. For more
        #   information see
        #   [IAM Overview](https://cloud.google.com/iam/docs/overview#permissions).
        # @return [Google::Iam::V1::TestIamPermissionsResponse]
        #
        def test_backup_permissions instance_id, cluster_id, backup_id, permissions
          tables.test_iam_permissions resource:    backup_path(instance_id, cluster_id, backup_id),
                                      permissions: permissions
        end

        ##
        # Gets the access control policy for an instance resource. Returns an empty
        # policy if an instance exists but does not have a policy set.
        #
        # @param instance_id [String]
        #   Unique ID of the instance for which the policy is being requested.
        # @return [Google::Iam::V1::Policy]
        #
        def get_instance_policy instance_id
          instances.get_iam_policy resource: instance_path(instance_id)
        end

        ##
        # Sets the access control policy on an instance resource. Replaces any
        # existing policy.
        #
        # @param instance_id [String]
        #   Unique ID of the instance the policy is for.
        # @param policy [Google::Iam::V1::Policy | Hash]
        #   REQUIRED: The complete policy to be applied to the +resource+. The size of
        #   the policy is limited to a few 10s of KB. An empty policy is valid
        #   for Cloud Bigtable, but certain Cloud Platform services (such as Projects)
        #   might reject an empty policy.
        #   Alternatively, provide a hash similar to `Google::Iam::V1::Policy`.
        # @return [Google::Iam::V1::Policy]
        #
        def set_instance_policy instance_id, policy
          instances.set_iam_policy resource: instance_path(instance_id), policy: policy
        end

        ##
        # Returns permissions that the caller has for the specified instance resource.
        #
        # @param instance_id [String]
        #   The instance ID that the policy detail is being requested for.
        # @param permissions [Array<String>]
        #   The set of permissions to check for the +resource+. Permissions with
        #   wildcards (such as '*' or 'storage.*') are not allowed. For more
        #   information see
        #   [IAM Overview](https://cloud.google.com/iam/docs/overview#permissions).
        # @return [Google::Iam::V1::TestIamPermissionsResponse]
        #
        def test_instance_permissions instance_id, permissions
          instances.test_iam_permissions resource: instance_path(instance_id), permissions: permissions
        end

        ##
        # Gets the access control policy for an table resource. Returns an empty
        # policy if an table exists but does not have a policy set.
        #
        # @param table_id [String]
        #   Unique ID of the table for which the policy is being requested.
        # @return [Google::Iam::V1::Policy]
        #
        def get_table_policy instance_id, table_id
          tables.get_iam_policy resource: table_path(instance_id, table_id)
        end

        ##
        # Sets the access control policy on an table resource. Replaces any
        # existing policy.
        #
        # @param table_id [String]
        #   Unique ID of the table the policy is for.
        # @param policy [Google::Iam::V1::Policy | Hash]
        #   REQUIRED: The complete policy to be applied to the +resource+. The size of
        #   the policy is limited to a few 10s of KB. An empty policy is valid
        #   for Cloud Bigtable, but certain Cloud Platform services (such as Projects)
        #   might reject an empty policy.
        #   Alternatively, provide a hash similar to `Google::Iam::V1::Policy`.
        # @return [Google::Iam::V1::Policy]
        #
        def set_table_policy instance_id, table_id, policy
          tables.set_iam_policy resource: table_path(instance_id, table_id), policy: policy
        end

        ##
        # Returns permissions that the caller has for the specified table resource.
        #
        # @param table_id [String]
        #   The table ID that the policy detail is being requested for.
        # @param permissions [Array<String>]
        #   The set of permissions to check for the +resource+. Permissions with
        #   wildcards (such as '*' or 'storage.*') are not allowed. For more
        #   information see
        #   [IAM Overview](https://cloud.google.com/iam/docs/overview#permissions).
        # @return [Google::Iam::V1::TestIamPermissionsResponse]
        #
        def test_table_permissions instance_id, table_id, permissions
          tables.test_iam_permissions resource: table_path(instance_id, table_id), permissions: permissions
        end

        def read_rows instance_id, table_id, app_profile_id: nil, rows: nil, filter: nil, rows_limit: nil
          client(table_path(instance_id, table_id), app_profile_id).read_rows(
            **{
              table_name:     table_path(instance_id, table_id),
              rows:           rows,
              filter:         filter,
              rows_limit:     rows_limit,
              app_profile_id: app_profile_id
            }
          )
        end

        def sample_row_keys table_name, app_profile_id: nil
          client(table_name, app_profile_id).sample_row_keys table_name: table_name, app_profile_id: app_profile_id
        end

        def mutate_row table_name, row_key, mutations, app_profile_id: nil
          client(table_name, app_profile_id).mutate_row(
            **{
              table_name:     table_name,
              app_profile_id: app_profile_id,
              row_key:        row_key,
              mutations:      mutations
            }.compact
          )
        end

        def mutate_rows table_name, entries, app_profile_id: nil
          client(table_name, app_profile_id).mutate_rows(
            **{
              table_name:     table_name,
              app_profile_id: app_profile_id,
              entries:        entries
            }.compact
          )
        end

        def check_and_mutate_row table_name,
                                 row_key,
                                 app_profile_id: nil,
                                 predicate_filter: nil,
                                 true_mutations: nil,
                                 false_mutations: nil
          client(table_name, app_profile_id).check_and_mutate_row(
            **{
              table_name:       table_name,
              app_profile_id:   app_profile_id,
              row_key:          row_key,
              predicate_filter: predicate_filter,
              true_mutations:   true_mutations,
              false_mutations:  false_mutations
            }.compact
          )
        end

        def read_modify_write_row table_name, row_key, rules, app_profile_id: nil
          client(table_name, app_profile_id).read_modify_write_row(
            **{
              table_name:     table_name,
              app_profile_id: app_profile_id,
              row_key:        row_key,
              rules:          rules
            }.compact
          )
        end

        ##
        # Starts creating a new backup. The underlying Google::Longrunning::Operation tracks creation of the backup.
        #
        # @return [Gapic::Operation]
        #
        def create_backup instance_id:, cluster_id:, backup_id:, source_table_id:, expire_time:
          backup = Google::Cloud::Bigtable::Admin::V2::Backup.new \
            source_table: table_path(instance_id, source_table_id), expire_time: expire_time
          tables.create_backup parent: cluster_path(instance_id, cluster_id), backup_id: backup_id, backup: backup
        end

        ##
        # Starts copying the selected backup to the chosen location.
        # The underlying Google::Longrunning::Operation tracks the copying of backup.
        #
        # @return [Gapic::Operation]
        #
        def copy_backup project_id:, instance_id:, cluster_id:, backup_id:, source_backup:, expire_time:
          tables.copy_backup parent: "projects/#{project_id}/instances/#{instance_id}/clusters/#{cluster_id}",
                             backup_id: backup_id,
                             source_backup: source_backup,
                             expire_time: expire_time
        end

        ##
        # @return [Google::Cloud::Bigtable::Admin::V2::Backup]
        #
        def get_backup instance_id, cluster_id, backup_id
          tables.get_backup name: backup_path(instance_id, cluster_id, backup_id)
        end

        ##
        # @return [Gapic::PagedEnumerable<Google::Cloud::Bigtable::Admin::V2::Backup>]
        #
        def list_backups instance_id, cluster_id
          tables.list_backups parent: cluster_path(instance_id, cluster_id)
        end

        ##
        # @param backup [Google::Cloud::Bigtable::Admin::V2::Backup | Hash]
        # @param fields [Array(String|Symbol)] the paths of fields to be updated
        #
        def update_backup backup, fields
          mask = Google::Protobuf::FieldMask.new paths: fields.map(&:to_s)
          tables.update_backup backup: backup, update_mask: mask
        end

        def delete_backup instance_id, cluster_id, backup_id
          tables.delete_backup name: backup_path(instance_id, cluster_id, backup_id)
        end

        ##
        # Create a new table by restoring from a completed backup.
        #
        # @param table_id [String] The table ID for the new table. This table must not yet exist.
        # @param instance_id [String] The instance ID for the source backup. The table will be created in this instance
        #   if table_instance_id is not provided.
        # @param cluster_id [String] The cluster ID for the source backup.
        # @param backup_id [String] The backup ID for the source backup.
        # @param table_instance_id [String] The instance ID for the table, if different from instance_id. Optional.
        #
        # @return [Gapic::Operation] The {Google::Longrunning::Operation#metadata metadata} field type is
        #   {Google::Cloud::Bigtable::Admin::RestoreTableMetadata RestoreTableMetadata}. The
        #   {Google::Longrunning::Operation#response response} type is
        #   {Google::Cloud::Bigtable::Admin::V2::Table Table}, if successful.
        #
        def restore_table table_id, instance_id, cluster_id, backup_id, table_instance_id: nil
          table_instance_id ||= instance_id
          tables.restore_table parent:   instance_path(table_instance_id),
                               table_id: table_id,
                               backup:   backup_path(instance_id, cluster_id, backup_id)
        end

        ##
        # Creates a formatted project path.
        #
        # @return [String]
        #   Formatted project path
        #   +projects/<project>+
        #
        def project_path
          Admin::V2::BigtableInstanceAdmin::Paths.project_path project: project_id
        end

        ##
        # Creates a formatted instance path.
        #
        # @param instance_id [String]
        # @return [String]
        #   Formatted instance path
        #   +projects/<project>/instances/[a-z][a-z0-9\\-]+[a-z0-9]+.
        #
        def instance_path instance_id
          Admin::V2::BigtableInstanceAdmin::Paths.instance_path project: project_id, instance: instance_id
        end

        ##
        # Creates a formatted cluster path.
        #
        # @param instance_id [String]
        # @param cluster_id [String]
        # @return [String]
        #   Formatted cluster path
        #   +projects/<project>/instances/<instance>/clusters/<cluster>+.
        #
        def cluster_path instance_id, cluster_id
          Admin::V2::BigtableInstanceAdmin::Paths.cluster_path project:  project_id,
                                                               instance: instance_id,
                                                               cluster:  cluster_id
        end

        ##
        # Creates a formatted location path.
        #
        # @param location [String]
        #   zone name i.e us-east1-b
        # @return [String]
        #   Formatted location path
        #   +projects/<project_id>/locations/<location>+.
        #
        def location_path location
          Admin::V2::BigtableInstanceAdmin::Paths.location_path project: project_id, location: location
        end

        ##
        # Creates a formatted table path.
        #
        # @param table_id [String]
        # @return [String]
        #   Formatted table path
        #   +projects/<project>/instances/<instance>/tables/<table>+
        #
        def table_path instance_id, table_id
          Admin::V2::BigtableTableAdmin::Paths.table_path project: project_id, instance: instance_id, table: table_id
        end

        ##
        # Creates a formatted app profile path.
        #
        # @param instance_id [String]
        # @param app_profile_id [String]
        # @return [String]
        #   Formatted snapshot path
        #   +projects/<project>/instances/<instance>/appProfiles/<app_profile>+
        #
        def app_profile_path instance_id, app_profile_id
          Admin::V2::BigtableInstanceAdmin::Paths.app_profile_path project:     project_id,
                                                                   instance:    instance_id,
                                                                   app_profile: app_profile_id
        end

        ##
        # Creates a formatted backup path.
        #
        # @return [String] Formatted backup path
        #   `projects/<project>/instances/<instance>/clusters/<cluster>/backups/<backup>`
        #
        def backup_path instance_id, cluster_id, backup_id
          Admin::V2::BigtableTableAdmin::Paths.backup_path project:  project_id,
                                                           instance: instance_id,
                                                           cluster:  cluster_id,
                                                           backup:   backup_id
        end

        ##
        # Inspects the service object.
        # @return [String]
        #
        def inspect
          "#{self.class}(#{@project_id})"
        end

        def create_bigtable_client table_path, app_profile_id
          V2::Bigtable::Client.new do |config|
            config.credentials = credentials if credentials
            config.timeout = timeout if timeout
            config.endpoint = host if host
            config.lib_name = "gccl"
            config.lib_version = Google::Cloud::Bigtable::VERSION
            config.metadata = { "google-cloud-resource-prefix": "projects/#{@project_id}" }
            config.channel_pool.channel_selection = @channel_selection
            config.channel_pool.channel_count = @channel_count
            request, options = Convert.ping_and_warm_request table_path, app_profile_id, timeout
            config.channel_pool.on_channel_create = proc do |channel|
              channel.call_rpc :ping_and_warm, request, options: options
            end
          end
        end
      end
    end
  end
end
