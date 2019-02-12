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
    module ResourceManager
      ##
      # # Resource
      #
      # A container to reference an id for any resource type. A `resource` in
      # Google Cloud Platform is a generic term for something a developer may
      # want to interact with through an API. Some examples are an App Engine
      # app, a Compute Engine instance, a Cloud SQL database, and so on. (See
      # {Manager#resource}.)
      #
      # @example
      #   require "google/cloud/resource_manager"
      #
      #   resource_manager = Google::Cloud::ResourceManager.new
      #   project = resource_manager.project "tokyo-rain-123"
      #   folder = Google::Cloud::ResourceManager::Resource.new "folder", "1234"
      #   project.parent = folder
      #
      class Resource
        ##
        # Create a Resource object.
        #
        # @param [String] type The resource type this id is for. At present, the
        #   valid types are: "organization" and "folder".
        # @param [String] id The type-specific id. This should correspond to the
        #   id used in the type-specific API's.
        def initialize type, id
          raise ArgumentError, "type is required" if type.nil?
          raise ArgumentError, "id is required"   if id.nil?

          @type = type
          @id   = id
        end

        ##
        # Required field representing the resource type this id is for. At
        # present, the valid types are: "organization" and "folder".
        # @return [String]
        attr_accessor :type

        ##
        # Required field for the type-specific id. This should correspond to the
        # id used in the type-specific API's.
        # @return [String]
        attr_accessor :id

        ##
        # Checks if the type is `folder`.
        # @return [Boolean]
        def folder?
          return false if type.nil?
          "folder".casecmp(type).zero?
        end

        ##
        # Checks if the type is `organization`.
        # @return [Boolean]
        def organization?
          return false if type.nil?
          "organization".casecmp(type).zero?
        end

        ##
        # Create a Resource object with type `folder`.
        #
        # @param [String] id The type-specific id. This should correspond to the
        #   id used in the type-specific API's.
        # @return [Resource]
        def self.folder id
          new "folder", id
        end

        ##
        # Create a Resource object with type `organization`.
        #
        # @param [String] id The type-specific id. This should correspond to the
        #   id used in the type-specific API's.
        # @return [Resource]
        def self.organization id
          new "organization", id
        end

        ##
        # @private Convert the Resource to a Google API Client ResourceId
        # object.
        def to_gapi
          Google::Apis::CloudresourcemanagerV1::ResourceId.new(
            type: type,
            id: id
          )
        end

        ##
        # @private Create new Resource from a Google API Client ResourceId
        # object.
        def self.from_gapi gapi
          new gapi.type, gapi.id
        end
      end
    end
  end
end
