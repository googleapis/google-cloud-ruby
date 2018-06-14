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


require "google/cloud/bigtable/errors"
require "google/cloud/bigtable/service"
require "google/cloud/bigtable/instance"
require "google/cloud/bigtable/cluster"

module Google
  module Cloud
    module Bigtable
      # # Project
      #
      # Projects are top-level containers in Google Cloud Platform. They store
      # information about billing and authorized users, and they contain
      # Cloud Bigtable data. Each project has a friendly name and a unique ID.
      #
      # Google::Cloud::Bigtable::Project is the main object for interacting with
      # Cloud Bigtable.
      #
      # {Google::Cloud::Bigtable::Cluster}, {Google::Cloud::Bigtable::Instance}
      # objects are created, accessed, and managed by Google::Cloud::Bigtable::Project.
      #
      # See {Google::Cloud::Bigtable.new} and {Google::Cloud#bigtable}.
      #
      # @example Obtaining an instance and a clusters from a project.
      #   require "google/cloud"
      #
      #   bigtable = Google::Cloud::Bigtable.new
      #
      #   instance = bigtable.instance("my-instance")
      #   clusters = bigtable.clusters # All cluster in project
      #
      class Project
        # @private
        # The Service object
        attr_accessor :service

        # @private
        # Creates a new Bigtable Project instance.
        # @param service [Google::Cloud::Bigtable::Service]

        def initialize service
          @service = service
        end

        # The identifier for the Cloud Bigtable project.
        #
        # @return [String] Project id.
        #
        # @example
        #   require "google/cloud"
        #
        #   bigtable = Google::Cloud::Bigtable.new(
        #     project_id: "my-project",
        #     credentials: "/path/to/keyfile.json"
        #   )
        #
        #   bigtable.project_id #=> "my-project"

        def project_id
          ensure_service!
          service.project_id
        end

        # Retrieves the list of Bigtable instances for the project.
        #
        # @param token [String] The `token` value returned by the last call to
        #   `instances`; indicates that this is a continuation of a call,
        #   and that the system should return the next page of data.
        # @return [Array<Google::Cloud::Bigtable::Instance>] The list of instances.
        #   (See {Google::Cloud::Bigtable::Instance::List})
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instances = bigtable.instances
        #   instances.all do |instance|
        #     puts instance.instance_id
        #   end

        def instances token: nil
          ensure_service!
          grpc = service.list_instances(token: token)
          Instance::List.from_grpc(grpc, service)
        end

        # Get existing Bigtable instance.
        #
        # @param instance_id [String] Existing instance id.
        # @return [Google::Cloud::Bigtable::Instance, nil]
        #
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   instance = bigtable.instance("my-instance")
        #
        #   if instance
        #     puts instance.instance_id
        #   end

        def instance instance_id
          ensure_service!
          grpc = service.get_instance(instance_id)
          Instance.from_grpc(grpc, service)
        rescue Google::Cloud::NotFoundError
          nil
        end

        # Create a Bigtable instance.
        #
        # @param instance_id [String] The unique identifier for the instance,
        #   which cannot be changed after the instance is created. Values are of
        #   the form `[a-z][-a-z0-9]*[a-z0-9]` and must be between 6 and 30
        #   characters in length. Required.
        # @param display_name [String] The descriptive name for this instance as it
        #   appears in UIs. Must be unique per project and between 4 and 30
        #   characters in length.
        # @param type [Symbol] The type of the instance.
        #   Valid values are `:DEVELOPMENT` or `:PRODUCTION`.
        #   Default `:PRODUCTION` instance will created if left blank.
        # @param labels [Hash{String=>String}] labels Cloud Labels are a flexible and lightweight
        #   mechanism for organizing cloud resources into groups that reflect a
        #   customer's organizational needs and deployment strategies. Cloud
        #   Labels can be used to filter collections of resources. They can be
        #   used to control how resource metrics are aggregated. And they can be
        #   used as arguments to policy management rules (e.g. route, firewall,
        #   load balancing, etc.).
        #
        #   * Label keys must be between 1 and 63 characters long and must
        #     conform to the following regular expression:
        #     `[a-z]([-a-z0-9]*[a-z0-9])?`.
        #   * Label values must be between 0 and 63 characters long and must
        #     conform to the regular expression `([a-z]([-a-z0-9]*[a-z0-9])?)?`.
        #   * No more than 64 labels can be associated with a given resource.
        # @param clusters [Hash{String => Google::Cloud::Bigtable::Cluster}]
        #   (See {Google::Cloud::Bigtable::Instance::ClusterMap})
        #   If passed as an empty use code block to add clusters.
        #   Minimum one cluster must be specified.
        # @yield [clusters] A block for adding clusters.
        # @yieldparam [Hash{String => Google::Cloud::Bigtable::Cluster}]
        #   Cluster map of cluster name and cluster object.
        #   (See {Google::Cloud::Bigtable::Instance::ClusterMap})
        # @return [Google::Cloud::Bigtable::Instance::Job]
        #   The job representing the long-running, asynchronous processing of
        #   an instance create operation.
        #
        # @example Create development instance.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   job = bigtable.create_instance(
        #     "my-instance",
        #     "Instance for user data",
        #     type: :DEVELOPMENT,
        #     labels: { "env" => "dev"}
        #   ) do |clusters|
        #     clusters.add("test-cluster", "us-east1-b", nodes: 1)
        #   end
        #
        #   job.done? #=> false
        #
        #   # Reload job until completion.
        #   job.wait_until_done
        #   job.done? #=> true
        #
        #   if job.error?
        #     status = job.error
        #   else
        #     instance = job.instance
        #   end
        #
        # @example Create production instance.
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   job = bigtable.create_instance(
        #     "my-instance",
        #     "Instance for user data",
        #     labels: { "env" => "dev"}
        #   ) do |clusters|
        #     clusters.add("test-cluster", "us-east1-b", nodes: 3, storage_type: :SSD)
        #   end
        #
        #   job.done? #=> false
        #
        #   # To block until the operation completes.
        #   job.wait_until_done
        #   job.done? #=> true
        #
        #   if job.error?
        #     status = job.error
        #   else
        #     instance = job.instance
        #   end

        def create_instance \
            instance_id,
            display_name: nil,
            type: nil,
            labels: nil,
            clusters: nil
          labels = Hash[labels.map { |k, v| [String(k), String(v)] }] if labels

          instance_attrs = {
            display_name: display_name,
            type: type,
            labels: labels
          }.delete_if { |_, v| v.nil? }
          instance = Google::Bigtable::Admin::V2::Instance.new(instance_attrs)
          clusters ||= Instance::ClusterMap.new
          yield clusters if block_given?

          clusters.each_value do |cluster|
            unless cluster.location == ""
              cluster.location = service.location_path(cluster.location)
            end
          end

          grpc = service.create_instance(
            instance_id,
            instance,
            clusters.to_h
          )
          Instance::Job.from_grpc(grpc, service)
        end

        # List all clusters in project.
        #
        # @param token [String] The `token` value returned by the last call to
        #   `clusters`; indicates that this is a continuation of a call,
        #   and that the system should return the next page of data.
        # @return [Array<Google::Cloud::Bigtable::Cluster>]
        #   (See {Google::Cloud::Bigtable::Cluster::List})
        # @example
        #   require "google/cloud/bigtable"
        #
        #   bigtable = Google::Cloud::Bigtable.new
        #
        #   bigtable.clusters.all do |cluster|
        #     puts cluster.cluster_id
        #     puts cluster.ready?
        #   end

        def clusters token: nil
          ensure_service!
          grpc = service.list_clusters("-", token: token)
          Cluster::List.from_grpc(grpc, service, instance_id: "-")
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
