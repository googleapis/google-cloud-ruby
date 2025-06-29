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
    module AIPlatform
      module V1
        module PersistentResourceService
          # Path helper methods for the PersistentResourceService API.
          module Paths
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
            # Create a fully-qualified Network resource string.
            #
            # The resource will be in the following format:
            #
            # `projects/{project}/global/networks/{network}`
            #
            # @param project [String]
            # @param network [String]
            #
            # @return [::String]
            def network_path project:, network:
              raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"

              "projects/#{project}/global/networks/#{network}"
            end

            ##
            # Create a fully-qualified NetworkAttachment resource string.
            #
            # The resource will be in the following format:
            #
            # `projects/{project}/regions/{region}/networkAttachments/{networkattachment}`
            #
            # @param project [String]
            # @param region [String]
            # @param networkattachment [String]
            #
            # @return [::String]
            def network_attachment_path project:, region:, networkattachment:
              raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
              raise ::ArgumentError, "region cannot contain /" if region.to_s.include? "/"

              "projects/#{project}/regions/#{region}/networkAttachments/#{networkattachment}"
            end

            ##
            # Create a fully-qualified PersistentResource resource string.
            #
            # The resource will be in the following format:
            #
            # `projects/{project}/locations/{location}/persistentResources/{persistent_resource}`
            #
            # @param project [String]
            # @param location [String]
            # @param persistent_resource [String]
            #
            # @return [::String]
            def persistent_resource_path project:, location:, persistent_resource:
              raise ::ArgumentError, "project cannot contain /" if project.to_s.include? "/"
              raise ::ArgumentError, "location cannot contain /" if location.to_s.include? "/"

              "projects/#{project}/locations/#{location}/persistentResources/#{persistent_resource}"
            end

            ##
            # Create a fully-qualified Reservation resource string.
            #
            # The resource will be in the following format:
            #
            # `projects/{project_id_or_number}/zones/{zone}/reservations/{reservation_name}`
            #
            # @param project_id_or_number [String]
            # @param zone [String]
            # @param reservation_name [String]
            #
            # @return [::String]
            def reservation_path project_id_or_number:, zone:, reservation_name:
              raise ::ArgumentError, "project_id_or_number cannot contain /" if project_id_or_number.to_s.include? "/"
              raise ::ArgumentError, "zone cannot contain /" if zone.to_s.include? "/"

              "projects/#{project_id_or_number}/zones/#{zone}/reservations/#{reservation_name}"
            end

            extend self
          end
        end
      end
    end
  end
end
