# frozen_string_literal: true

require "google/cloud/bigtable/admin/v2"
require "google/bigtable/admin/v2/instance_pb"

module Bigtable
  # Protobuf references
  Instance = Google::Bigtable::Admin::V2::Instance
  Cluster = Google::Bigtable::Admin::V2::Cluster

  class InstanceAdminError < StandardError; end # :nodoc:

  class InstanceAdminClient
    # Bigtable instance admin client for creating, configuring, and deleting
    # instances and clusters
    #
    # @example
    #   Bigtable::InstanceAdminClient.new(
    #     "project-id-xyz",
    #     credentials: "keyfile.json"
    #   )
    #
    #   # Or if google project default credentials set
    #
    #   Bigtable::InstanceAdminClient.new("project-id-xyz")

    attr_reader :project_id, :options

    # @param project_id [String]
    # @param options [Hash]
    def initialize project_id, options = {}
      @project_id = project_id
      @options = options
    end

    # Get instance information
    #
    # @param instance_id [String]
    # @return [Google::Bigtable::Admin::V2::Instance]
    # @example
    #   client = Bigtable.instance_admin_client "project-id"
    #   client.instance "my-instance-id"

    def instance instance_id
      client.get_instance(
        instance_path(instance_id)
      )
    end

    # List all instances
    #
    # @param page_token [String]
    #   The value of +next_page_token+ returned by a previous call.
    # @return [Google::Bigtable::Admin::V2::ListInstancesResponse]
    #   Response has list of instances, failed locations and next page token
    # @example
    #   client = Bigtable.instance_admin_client "project-id"
    #   response = client.instances
    #   instances = response.instances
    #
    #   # Get instances using next page token
    #   unless response.next_page_token.empty?
    #     response = client.instances(response.next_page_token)
    #     instances.concat(response.instances)
    #   end

    def instances page_token: nil
      response = client.list_instances(
        project_path,
        page_token: page_token
      )

      if response.failed_locations.any?
        LOGGER.warn("Failed locations #{response.failed_locations.join(',')}")
      end

      response
    end

    # Create instance with clusters.
    #
    # @param instance [Bigtable::Instance | Hash]
    #   The instance to create. Fields are name, type and lables.
    #   Serve nodes cannot be specified for development instances
    # @param clusters [Array<Bigtable::Cluster>]
    #   The clusters to be created within the instance and
    #   Cluster name must be unique.
    #   One cluster must be specified.
    # @return [Google::Gax::Operation]
    # @example
    #   client = Bigtable.instance_admin_client "project-id"
    #
    #   instance = Bigtable::Instance.new name: "my-instance"
    #
    #   cluster = Bigtable::Cluster.new({
    #     name: "app-cluster",
    #     location: "us-east1-b"
    #   })
    #
    #   operation = client.create_instance(instance, [ cluster ])
    #
    #   raise operation.results.message if operation.error?
    #
    #   results = operation.results
    #   metadata = operation.metadata

    def create_instance instance, clusters
      req_instance = instance.clone
      req_instance.name = ""

      # Create Hash{String => Google::Bigtable::Admin::V2::Cluster}
      req_clusters = clusters.each_with_object({}) do |cluster, result|
        req_cluster = cluster.clone
        req_cluster.location = location_path(cluster.location)
        req_cluster.name = ""
        result[cluster.name] = req_cluster
      end

      operation = client.create_instance(
        project_path,
        instance.name,
        req_instance,
        req_clusters
      )
      operation.wait_until_done!
      operation
    end

    # Update instance display name, type and lables.
    #
    # @param instance_id [String]
    #   Existing instance id
    # @param display_name [String]
    #   The descriptive name for this instance as it appears in UIs.
    #   Can be changed at any time, but should be kept globally unique
    #   to avoid confusion.
    # @param type [Bigtable::Instance::Type]
    #   The type of the instance. Defaults to +PRODUCTION+.
    # @param labels [Hash{String => String}]
    # @example
    #   client = Bigtable.instance_admin_client "project-id"
    #
    #   client.update_instance "my-instance", {
    #     display_name: "APP Instance",
    #     type: :PRODUCTION
    #   })

    def update_instance instance_id, display_name: nil, type: nil, labels: {}
      client.update_instance(
        instance_path(instance_id),
        display_name,
        type,
        labels
      )
    end

    # Delete instance
    # @param instance_id [String]
    #   Existing instance id
    # @example
    #   client = Bigtable.instance_admin_client "project-id"
    #
    #   client.delete_instance "my-instance"

    def delete_instance instance_id
      client.delete_instance(
        instance_path(instance_id)
      )
    end

    # Create cluster
    #
    # @param instance_id [String]
    #   Existing instance id
    # @param cluster [Google::Bigtable::Admin::V2::Cluster | Hash]
    #   The cluster to be created.
    #   Cluster fields are name, location, serve_nodes, default_storage_type.
    # @return [Google::Gax::Operation]
    # @example
    #   client = Bigtable.instance_admin_client "project-id"
    #
    #   cluster = Bigtable::Cluster.new({
    #     name: "cluster-1",
    #     location: "us-east-1a",
    #     serve_nodes: 3,
    #     default_storage_type: :SSD
    #   })
    #
    #   operation = client.create_cluster "instance-1", cluster
    #
    #   raise operation.results.message if operation.error?
    #
    #   results = operation.results
    #   metadata = operation.metadata

    def create_cluster instance_id, cluster
      req_cluster = cluster.clone
      req_cluster.name = ""
      req_cluster.location = location_path(cluster.location)

      operation = client.create_cluster(
        instance_path(instance_id),
        cluster.name,
        req_cluster
      )
      operation.wait_until_done!
      operation
    end

    # Get cluster information
    # @param instance_id [String]
    #   Existing instance id
    # @param cluster_id [String]
    #   Existing cluster id
    # @return [Google::Bigtable::Admin::V2::Cluster]
    # @example
    #   client = Bigtable.instance_admin_client "project-id"
    #
    #   client.cluster "instance-1", "cluster-1"

    def cluster instance_id, cluster_id
      client.get_cluster(
        cluster_path(instance_id, cluster_id)
      )
    end

    # List all clusters
    # @param instance_id [String]
    #   Existing instance id
    # @param page_token [String]
    #   The value of +next_page_token+ returned by a previous call.
    # @return [Array<Google::Bigtable::Admin::V2::Cluster>]
    # @example
    #   client = Bigtable.instance_admin_client "project-id"
    #
    #   response = client.clusters
    #   clusters = response.clusters
    #
    #   # Get next page clusters using next page token
    #   unless response.next_page_token.empty?
    #     response = client.clusters(response.next_page_token)
    #     clusters.concat(response.clusters)
    #   end

    def clusters instance_id, page_token: nil
      response = client.list_clusters(
        instance_path(instance_id),
        page_token: page_token
      )

      if response.failed_locations.any?
        LOGGER.warn("Failed locations #{response.failed_locations.join(',')}")
      end

      response
    end

    # Update cluster
    # @param instance_id [String]
    #   Existing instance id
    # @param cluster_id [String]
    #   Existing cluster_id id
    # @param serve_nodes [Integer]
    #   The number of nodes allocated to this cluster.
    #   More nodes enable higher throughput and more consistent performance.
    # @return [Google::Gax::Operation]
    # @example
    #   client = Bigtable.instance_admin_client "project-id"
    #
    #   serve_nodes = 6
    #   operation = client.update_cluster "instance-1", "cluster-1", serve_nodes
    #
    #   raise operation.results.message if operation.error?
    #
    #   results = operation.results
    #   metadata = operation.metadata

    def update_cluster instance_id, cluster_id, serve_nodes
      operation = client.update_cluster(
        cluster_path(instance_id, cluster_id),
        nil,
        serve_nodes
      )
      operation.wait_until_done!
      operation
    end

    # Delete cluster
    # @param instance_id [String]
    #   Existing instance id
    # @param cluster_id [String]
    #   Existing cluster_id id
    # @example
    #   TODO
    def delete_cluster instance_id, cluster_id
      client.delete_cluster(
        cluster_path(instance_id, cluster_id)
      )
    end

    private

    # Create or return bigtable instance admin client
    # @return [Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient]

    def client
      @client ||= begin
        if options[:credentials].is_a?(String)
          options[:credentials] =
            Google::Cloud::Bigtable::Admin::Credentials.new(
              options[:credentials],
              scopes: options[:scopes]
            )
        end

        Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin.new options
      end
    end

    # Created formatted instance path
    # @param instance_id [String]
    # @return [String]
    #   Formatted instance path
    #   +projects/<project>/instances/[a-z][a-z0-9\\-]+[a-z0-9]+.

    def instance_path instance_id
      Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient
        .instance_path(
          project_id,
          instance_id
        )
    end

    # Created formatted project path
    # @return [String]
    #   Formatted project path
    #   +projects/<project>+

    def project_path
      Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient
        .project_path(
          project_id
        )
    end

    # Created formatted cluster path
    # @param instance_id [String]
    # @param cluster_id [String]
    # @return [String]
    #   Formatted cluster path
    #   +projects/<project>/instances/<instance>/clusters/<cluster>+.

    def cluster_path instance_id, cluster_id
      Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient
        .cluster_path(
          project_id,
          instance_id,
          cluster_id
        )
    end

    # @param location [String]
    #   zone name i.e us-east1-b
    # @return [String]
    #   Formatted location path
    #   +projects/<project_id>/locations/<location>+.

    def location_path location
      Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient
        .location_path(
          project_id,
          location
        )
    end
  end
end
