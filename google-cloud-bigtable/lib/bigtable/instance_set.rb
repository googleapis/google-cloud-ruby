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

require "google/cloud/bigtable/admin/v2"
require "google/bigtable/admin/v2/instance_pb"
require "bigtable/instance"

module Bigtable
  class InstanceSet
    include Enumerable

    def initialize config
      @config = config
    end

    # each method for Enumerable interface. the method fetches and yields
    # BigTable Instance objects.
    # @example
    #   # object can be used as a ruby enumerable.
    #   names = instances.collect(:name).to_a
    def each
      page_token = nil
      loop do
        response = client.list_instances @config.project_path,
                                         page_token: page_token
        response.instances.each do |instance|
          yield Bigtable::Instance.from_proto_ob instance, client
        end

        page_token = response.next_page_token
        break if page_token.nil? || page_token.empty?
      end
    end

    # finds the instance object corresponding to given instance id in the
    # project
    # @param instance_id [String]
    # @return [Bigtable::Instance]
    # @example
    #  instances.find 'my-instance'
    def find instance_id
      instance = client.get_instance @config.instance_path instance_id
      Bigtable::Instance.from_proto_ob instance, client
    end

    # creates a new instance with given params
    # @param instance_id [String]
    #   The unique id for the instance to create. This parameter is
    #   mandatory and should be unique.
    # @param display_name [String]
    #   The display name for the instance to be created.
    # @param clusters [Bigtable::Cluster]
    #   A list of Bigtable::Cluster objects to be created. The
    #   created object must contain cluster id.
    # @param type [Symbol]
    #   The type of cluster to create. :DEVELOPEMENT, :PRODUCTION.
    #   In case the type is set to :Development, you should not
    #   specify the serve_nodes param in cluster.
    # @param options [Google::Gax::CallOptions]
    #   Overrides the default settings for this call, e.g, timeout,
    #   retries, etc.
    # @param labels [Hash{String => String}]
    #   Labels are a flexible and lightweight mechanism for organizing cloud
    #   resources into groups that reflect a customer's organizational needs and
    #   deployment strategies. They can be used to filter resources and
    #   aggregate metrics.
    #
    #   * Label keys must be between 1 and 63 characters long and must conform
    #     to the regular expression: +[\p{Ll}\p{Lo}][\p{Ll}\p{Lo}\p{N}_-]{0,62}+
    #   * Label values must be between 0 and 63 characters long and must conform
    #     to the regular expression: +[\p{Ll}\p{Lo}\p{N}_-]{0,63}+
    #   * No more than 64 labels can be associated with a given resource.
    #   * Keys and values must both be under 128 bytes.
    # @return [Bigtable::Instance]
    # The created instance object.
    #
    # @example
    #   # create a development cluster in us-central1-c
    #   cluster = Bigtable::Cluster.new cluster_id: "my_unique_cluster",
    #                                   location: "us-central1-c"
    #
    #   ins = bigtable.instances.create! instance_id: "my_unique_instance",
    #                                    display_name: "Instance Name",
    #                                    clusters: [cluster]
    #
    #   # create a production cluster in us-central1-c
    #   cluster_p = Bigtable::Cluster.new cluster_id: "my_unique_cluster",
    #                                   location: "us-central1-c",
    #                                   serve_nodes: 3
    #
    #   ins_p = bigtable.instances.create! instance_id: "my_unique_instance",
    #                                    display_name: "Instance Name",
    #                                    type: :PRODUCTION,
    #                                    clusters: [cluster]
    def create! instance_id:, display_name:, clusters:,
                type: :DEVELOPMENT, labels: {}, **options
      instance = {
        "display_name" => display_name, "type" => type, "labels" => labels
      }

      cluster_hash = clusters.map { |c| [c.cluster_id, c.to_proto_ob] }.to_h
      operation = client.create_instance @config.project_path,
                                         instance_id, instance,
                                         cluster_hash, options
      operation.wait_until_done!
      Bigtable::Instance.from_proto_ob operation.response, client
    end

    private

    # Create or return bigtable instance admin client
    # @return [Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdminClient]
    def client
      @client ||= begin
        Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin.new(
          @config.admin_credentials
        )
      end
    end
  end
end
