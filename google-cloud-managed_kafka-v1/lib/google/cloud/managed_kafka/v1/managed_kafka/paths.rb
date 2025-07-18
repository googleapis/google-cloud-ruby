# frozen_string_literal: true

# Copyright 2024 Google LLC
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

# Auto-generated by gapic-generator-ruby. DO NOT EDIT!


module Google
  module Cloud
    module ManagedKafka
      module V1
        module ManagedKafka
          # Path helper methods for the ManagedKafka API.
          module Paths
            ##
            # Create a fully-qualified Acl resource string.
            #
            # The resource will be in the following format:
            #
            # `projects/{project}/locations/{location}/clusters/{cluster}/acls/{acl}`
            #
            # @param project [String]
            # @param location [String]
            # @param cluster [String]
            # @param acl [String]
            #
            # @return [::String]
            def acl_path project:, location:, cluster:, acl:
              raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
              raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"
              raise ::ArgumentError, "cluster cannot contain /" if cluster.to_s.include? "/"

              "projects/#{project}/locations/#{location}/clusters/#{cluster}/acls/#{acl}"
            end

            ##
            # Create a fully-qualified CaPool resource string.
            #
            # The resource will be in the following format:
            #
            # `projects/{project}/locations/{location}/caPools/{ca_pool}`
            #
            # @param project [String]
            # @param location [String]
            # @param ca_pool [String]
            #
            # @return [::String]
            def ca_pool_path project:, location:, ca_pool:
              raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
              raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"

              "projects/#{project}/locations/#{location}/caPools/#{ca_pool}"
            end

            ##
            # Create a fully-qualified Cluster resource string.
            #
            # The resource will be in the following format:
            #
            # `projects/{project}/locations/{location}/clusters/{cluster}`
            #
            # @param project [String]
            # @param location [String]
            # @param cluster [String]
            #
            # @return [::String]
            def cluster_path project:, location:, cluster:
              raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
              raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"

              "projects/#{project}/locations/#{location}/clusters/#{cluster}"
            end

            ##
            # Create a fully-qualified ConsumerGroup resource string.
            #
            # The resource will be in the following format:
            #
            # `projects/{project}/locations/{location}/clusters/{cluster}/consumerGroups/{consumer_group}`
            #
            # @param project [String]
            # @param location [String]
            # @param cluster [String]
            # @param consumer_group [String]
            #
            # @return [::String]
            def consumer_group_path project:, location:, cluster:, consumer_group:
              raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
              raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"
              raise ::ArgumentError, "cluster cannot contain /" if cluster.to_s.include? "/"

              "projects/#{project}/locations/#{location}/clusters/#{cluster}/consumerGroups/#{consumer_group}"
            end

            ##
            # Create a fully-qualified CryptoKey resource string.
            #
            # The resource will be in the following format:
            #
            # `projects/{project}/locations/{location}/keyRings/{key_ring}/cryptoKeys/{crypto_key}`
            #
            # @param project [String]
            # @param location [String]
            # @param key_ring [String]
            # @param crypto_key [String]
            #
            # @return [::String]
            def crypto_key_path project:, location:, key_ring:, crypto_key:
              raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
              raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"
              raise ::ArgumentError, "key_ring cannot contain /" if key_ring.to_s.include? "/"

              "projects/#{project}/locations/#{location}/keyRings/#{key_ring}/cryptoKeys/#{crypto_key}"
            end

            ##
            # Create a fully-qualified Location resource string.
            #
            # The resource will be in the following format:
            #
            # `projects/{project}/locations/{location}`
            #
            # @param project [String]
            # @param location [String]
            #
            # @return [::String]
            def location_path project:, location:
              raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"

              "projects/#{project}/locations/#{location}"
            end

            ##
            # Create a fully-qualified Topic resource string.
            #
            # The resource will be in the following format:
            #
            # `projects/{project}/locations/{location}/clusters/{cluster}/topics/{topic}`
            #
            # @param project [String]
            # @param location [String]
            # @param cluster [String]
            # @param topic [String]
            #
            # @return [::String]
            def topic_path project:, location:, cluster:, topic:
              raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
              raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"
              raise ::ArgumentError, "cluster cannot contain /" if cluster.to_s.include? "/"

              "projects/#{project}/locations/#{location}/clusters/#{cluster}/topics/#{topic}"
            end

            extend self
          end
        end
      end
    end
  end
end
