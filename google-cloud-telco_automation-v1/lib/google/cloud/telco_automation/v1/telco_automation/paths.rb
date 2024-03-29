# frozen_string_literal: true

# Copyright 2023 Google LLC
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
    module TelcoAutomation
      module V1
        module TelcoAutomation
          # Path helper methods for the TelcoAutomation API.
          module Paths
            ##
            # Create a fully-qualified Blueprint resource string.
            #
            # The resource will be in the following format:
            #
            # `projects/{project}/locations/{location}/orchestrationClusters/{orchestration_cluster}/blueprints/{blueprint}`
            #
            # @param project [String]
            # @param location [String]
            # @param orchestration_cluster [String]
            # @param blueprint [String]
            #
            # @return [::String]
            def blueprint_path project:, location:, orchestration_cluster:, blueprint:
              raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
              raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"
              raise ::ArgumentError, "orchestration_cluster cannot contain /" if orchestration_cluster.to_s.include? "/"

              "projects/#{project}/locations/#{location}/orchestrationClusters/#{orchestration_cluster}/blueprints/#{blueprint}"
            end

            ##
            # Create a fully-qualified Deployment resource string.
            #
            # The resource will be in the following format:
            #
            # `projects/{project}/locations/{location}/orchestrationClusters/{orchestration_cluster}/deployments/{deployment}`
            #
            # @param project [String]
            # @param location [String]
            # @param orchestration_cluster [String]
            # @param deployment [String]
            #
            # @return [::String]
            def deployment_path project:, location:, orchestration_cluster:, deployment:
              raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
              raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"
              raise ::ArgumentError, "orchestration_cluster cannot contain /" if orchestration_cluster.to_s.include? "/"

              "projects/#{project}/locations/#{location}/orchestrationClusters/#{orchestration_cluster}/deployments/#{deployment}"
            end

            ##
            # Create a fully-qualified EdgeSlm resource string.
            #
            # The resource will be in the following format:
            #
            # `projects/{project}/locations/{location}/edgeSlms/{edge_slm}`
            #
            # @param project [String]
            # @param location [String]
            # @param edge_slm [String]
            #
            # @return [::String]
            def edge_slm_path project:, location:, edge_slm:
              raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
              raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"

              "projects/#{project}/locations/#{location}/edgeSlms/#{edge_slm}"
            end

            ##
            # Create a fully-qualified HydratedDeployment resource string.
            #
            # The resource will be in the following format:
            #
            # `projects/{project}/locations/{location}/orchestrationClusters/{orchestration_cluster}/deployments/{deployment}/hydratedDeployments/{hydrated_deployment}`
            #
            # @param project [String]
            # @param location [String]
            # @param orchestration_cluster [String]
            # @param deployment [String]
            # @param hydrated_deployment [String]
            #
            # @return [::String]
            def hydrated_deployment_path project:, location:, orchestration_cluster:, deployment:, hydrated_deployment:
              raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
              raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"
              raise ::ArgumentError, "orchestration_cluster cannot contain /" if orchestration_cluster.to_s.include? "/"
              raise ::ArgumentError, "deployment cannot contain /" if deployment.to_s.include? "/"

              "projects/#{project}/locations/#{location}/orchestrationClusters/#{orchestration_cluster}/deployments/#{deployment}/hydratedDeployments/#{hydrated_deployment}"
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
            # Create a fully-qualified OrchestrationCluster resource string.
            #
            # The resource will be in the following format:
            #
            # `projects/{project}/locations/{location}/orchestrationClusters/{orchestration_cluster}`
            #
            # @param project [String]
            # @param location [String]
            # @param orchestration_cluster [String]
            #
            # @return [::String]
            def orchestration_cluster_path project:, location:, orchestration_cluster:
              raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
              raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"

              "projects/#{project}/locations/#{location}/orchestrationClusters/#{orchestration_cluster}"
            end

            ##
            # Create a fully-qualified PublicBlueprint resource string.
            #
            # The resource will be in the following format:
            #
            # `projects/{project}/locations/{location}/publicBlueprints/{public_lueprint}`
            #
            # @param project [String]
            # @param location [String]
            # @param public_lueprint [String]
            #
            # @return [::String]
            def public_blueprint_path project:, location:, public_lueprint:
              raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
              raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"

              "projects/#{project}/locations/#{location}/publicBlueprints/#{public_lueprint}"
            end

            extend self
          end
        end
      end
    end
  end
end
