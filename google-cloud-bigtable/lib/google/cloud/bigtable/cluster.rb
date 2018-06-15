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


require "google/cloud/bigtable/cluster/list"
require "google/cloud/bigtable/cluster/job"

module Google
  module Cloud
    module Bigtable
      # # Cluster
      #
      # A configuration object describing how Cloud Bigtable should treat traffic
      # from a particular end user application.
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   instance = bigtable.instance("my-instance")
      #   cluster = instance.cluster("my-cluster")
      #
      #   # Update
      #   cluster.nodes = 3
      #   cluster.save
      #
      #   # Delete
      #   cluster.delete
      #
      class Cluster
        # @private
        # The gRPC Service object.
        attr_accessor :service

        # @private
        #
        # Creates a new Cluster instance.
        def initialize grpc, service
          @grpc = grpc
          @service = service
        end

        # The unique identifier for the project.
        #
        # @return [String]
        def project_id
          @grpc.name.split("/")[1]
        end

        # The unique identifier for the instance.
        #
        # @return [String]
        def instance_id
          @grpc.name.split("/")[3]
        end

        # The unique identifier for the cluster.
        #
        # @return [String]
        def cluster_id
          @grpc.name.split("/")[5]
        end

        # The unique name of the cluster. Value in the form
        # `projects/<project_id>/instances/<instance_id>/clusters/<cluster_id>`.
        #
        # @return [String]
        def path
          @grpc.name
        end

        # The current instance state.
        # Possible values are
        # `:CREATING`, `:READY`, `:STATE_NOT_KNOWN`, `:RESIZING`, `:DISABLED`.
        #
        # @return [Symbol]
        def state
          @grpc.state
        end

        # The cluster has been successfully created and is ready to serve requests.
        #
        # @return [Boolean]
        def ready?
          state == :READY
        end

        # The instance is currently being created, and may be destroyed if the
        # creation process encounters an error.
        #
        # @return [Boolean]
        def creating?
          state == :CREATING
        end

        # The cluster is currently being resized, and may revert to its previous
        # node count if the process encounters an error.
        # A cluster is still capable of serving requests while being resized,
        # but may exhibit performance as if its number of allocated nodes is
        # between the starting and requested states.
        #
        # @return [Boolean]
        def resizing?
          state == :RESIZING
        end

        # The cluster has no backing nodes. The data (tables) still
        # exist, but no operations can be performed on the cluster.
        #
        # @return [Boolean]
        def disabled?
          state == :DISABLED
        end

        # The number of nodes allocated to this cluster.
        #
        # @return [Integer]
        def nodes
          @grpc.serve_nodes
        end

        # The number of nodes allocated to this cluster. More nodes enable higher
        # throughput and more consistent performance.
        #
        # @param serve_nodes [Integer] Number of nodes
        def nodes= serve_nodes
          @grpc.serve_nodes = serve_nodes
        end

        # The type of storage used by this cluster to serve its
        # parent instance's tables, unless explicitly overridden.
        # Valid values are `:SSD`(Flash (SSD) storage should be used),
        # `:HDD`(Magnetic drive (HDD) storage should be used)
        #
        # @return [Symbol]
        def storage_type
          @grpc.default_storage_type
        end

        # Cluster location.
        # i.e "us-east-1b"
        #
        # @return [String]
        def location
          @grpc.location.split("/")[3]
        end

        # Cluster location path in form of
        # `projects/<project_id>/locations/<zone>`
        #
        # @return [String]
        def location_path
          @grpc.location
        end

        # Update cluster.
        #
        # Updatable fields are no of nodes.
        #
        # @return [Google::Cloud::Bigtable::Cluster::Job]
        #   The job representing the long-running, asynchronous processing of
        #   an update cluster operation.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   cluster = instance.cluster("my-cluster")
        #   cluster.nodes = 3
        #   job = cluster.save
        #
        #   job.done? #=> false
        #
        #   # To block until the operation completes.
        #   job.wait_until_done!
        #   job.done? #=> true
        #
        #   if job.error?
        #     status = job.error
        #   else
        #     cluster = job.cluster
        #   end
        #
        def save
          ensure_service!
          grpc = service.update_cluster(
            instance_id,
            cluster_id,
            location_path,
            nodes
          )
          Cluster::Job.from_grpc(grpc, service)
        end
        alias update save

        # Reload cluster information.
        #
        # @return [Google::Cloud::Bigtable::Cluster]

        def reload!
          @grpc = service.get_cluster(instance_id, cluster_id)
          self
        end

        # Permanently deletes the cluster
        #
        # @return [Boolean] Returns `true` if the cluster was deleted.
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #   cluster = instance.cluster("my-cluster")
        #   cluster.delete
        #
        def delete
          ensure_service!
          service.delete_cluster(instance_id, cluster_id)
          true
        end

        # @private
        #
        # Creates a new Cluster instance from a
        # Google::Bigtable::Admin::V2::Cluster.
        #
        # @param grpc [Google::Bigtable::Admin::V2::Cluster]
        # @param service [Google::Cloud::Bigtable::Service]
        # @return [Google::Cloud::Bigtable::Cluster]
        def self.from_grpc grpc, service
          new(grpc, service)
        end

        protected

        # @private
        #
        # Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end
      end
    end
  end
end
