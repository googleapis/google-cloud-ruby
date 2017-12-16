# Copyright 2015 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google/cloud/errors"
require "google/cloud/resource_manager/credentials"
require "google/cloud/resource_manager/service"
require "google/cloud/resource_manager/project"

module Google
  module Cloud
    module ResourceManager
      ##
      # # Manager
      #
      # Provides methods for creating, retrieving, and updating projects.
      #
      # @example
      #   require "google/cloud/resource_manager"
      #
      #   resource_manager = Google::Cloud::ResourceManager.new
      #   resource_manager.projects.each do |project|
      #     puts projects.project_id
      #   end
      #
      # See {Google::Cloud#resource_manager}
      class Manager
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private Creates a new Service instance.
        #
        # See {Google::Cloud.resource_manager}
        def initialize service
          @service = service
        end

        ##
        # Retrieves the projects that are visible to the user and satisfy the
        # specified filter. This method returns projects in an unspecified
        # order. New projects do not necessarily appear at the end of the list.
        #
        # @param [String] filter An expression for filtering the results of the
        #   request. Filter rules are case insensitive.
        #
        #   The fields eligible for filtering are:
        #
        #   * `name`
        #   * `id`
        #   * `labels.key` - where `key` is the name of a label
        #
        #   Some examples of using labels as filters:
        #
        #   * `name:*` - The project has a name.
        #   * `name:Howl` - The project's name is Howl or howl.
        #   * `name:HOWL` - Equivalent to above.
        #   * `NAME:howl` - Equivalent to above.
        #   * `labels.color:*` - The project has the label color.
        #   * `labels.color:red` - The project's label color has the value red.
        #   * <code>labels.color:red labels.size:big</code> - The project's
        #     label color has the value red and its label size has the value
        #     big.
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of projects to return.
        #
        # @return [Array<Google::Cloud::ResourceManager::Project>] (See
        #   {Google::Cloud::ResourceManager::Project::List})
        #
        # @example
        #   require "google/cloud/resource_manager"
        #
        #   resource_manager = Google::Cloud::ResourceManager.new
        #   projects = resource_manager.projects
        #
        #   projects.each do |project|
        #     puts project.project_id
        #   end
        #
        # @example Projects can be filtered using the `filter` option:
        #   require "google/cloud/resource_manager"
        #
        #   resource_manager = Google::Cloud::ResourceManager.new
        #   projects = resource_manager.projects filter: "labels.env:production"
        #
        #   projects.each do |project|
        #     puts project.project_id
        #   end
        #
        # @example Retrieve all projects: (See {Project::List#all})
        #   require "google/cloud/resource_manager"
        #
        #   resource_manager = Google::Cloud::ResourceManager.new
        #   projects = resource_manager.projects
        #
        #   projects.all do |project|
        #     puts project.project_id
        #   end
        #
        def projects filter: nil, token: nil, max: nil
          gapi = service.list_project filter: filter, token: token, max: max
          Project::List.from_gapi gapi, self, filter, max
        end

        ##
        # Retrieves the project identified by the specified `project_id`.
        #
        # @param [String] project_id The ID of the project.
        #
        # @return [Google::Cloud::ResourceManager::Project, nil] Returns `nil`
        #   if the project does not exist
        #
        # @example
        #   require "google/cloud/resource_manager"
        #
        #   resource_manager = Google::Cloud::ResourceManager.new
        #   project = resource_manager.project "tokyo-rain-123"
        #   project.project_id #=> "tokyo-rain-123"
        #
        def project project_id
          gapi = service.get_project project_id
          Project.from_gapi gapi, service
        rescue NotFoundError
          nil
        end

        ##
        # Creates a project resource.
        #
        # Initially, the project resource is owned by its creator exclusively.
        # The creator can later grant permission to others to read or update the
        # project.
        #
        # Several APIs are activated automatically for the project, including
        # Google Cloud Storage.
        #
        # @param [String] project_id The unique, user-assigned ID of the
        #   project. It must be 6 to 30 lowercase letters, digits, or hyphens.
        #   It must start with a letter. Trailing hyphens are prohibited.
        # @param [String] name The user-assigned name of the project. This field
        #   is optional and can remain unset.
        #
        #   Allowed characters are: lowercase and uppercase letters, numbers,
        #   hyphen, single-quote, double-quote, space, and exclamation point.
        # @param [Hash] labels The labels associated with this project.
        #
        #   Label keys must be between 1 and 63 characters long and must conform
        #   to the following regular expression:
        #   <code>[a-z]([-a-z0-9]*[a-z0-9])?</code>.
        #
        #   Label values must be between 0 and 63 characters long and must
        #   conform to the regular expression
        #   <code>([a-z]([-a-z0-9]*[a-z0-9])?)?</code>.
        #
        #   No more than 256 labels can be associated with a given resource.
        #
        # @return [Google::Cloud::ResourceManager::Project]
        #
        # @example
        #   require "google/cloud/resource_manager"
        #
        #   resource_manager = Google::Cloud::ResourceManager.new
        #   project = resource_manager.create_project "tokyo-rain-123"
        #
        # @example A project can also be created with a `name` and `labels`:
        #   require "google/cloud/resource_manager"
        #
        #   resource_manager = Google::Cloud::ResourceManager.new
        #   project = resource_manager.create_project "tokyo-rain-123",
        #     name: "Todos Development", labels: {env: :development}
        #
        def create_project project_id, name: nil, labels: nil
          gapi = service.create_project project_id, name, labels
          Project.from_gapi gapi, service
        end

        ##
        # Marks the project for deletion. This method will only affect the
        # project if the following criteria are met:
        #
        # * The project does not have a billing account associated with it.
        # * The project has a lifecycle state of `ACTIVE`.
        # * This method changes the project's lifecycle state from `ACTIVE` to
        #   `DELETE_REQUESTED`. The deletion starts at an unspecified time, at
        #   which point the lifecycle state changes to `DELETE_IN_PROGRESS`.
        #
        # Until the deletion completes, you can check the lifecycle state by
        # retrieving the project with Manager#project. The project remains
        # visible to Manager#project and Manager#projects, but cannot be
        # updated.
        #
        # After the deletion completes, the project is not retrievable by the
        # Manager#project and Manager#projects methods.
        #
        # The caller must have modify permissions for this project.
        #
        # @param [String] project_id The ID of the project.
        #
        # @example
        #   require "google/cloud/resource_manager"
        #
        #   resource_manager = Google::Cloud::ResourceManager.new
        #   resource_manager.delete "tokyo-rain-123"
        #
        def delete project_id
          service.delete_project project_id
          true
        end

        ##
        # Restores the project. You can only use this method for a project that
        # has a lifecycle state of `DELETE_REQUESTED`. After deletion starts, as
        # indicated by a lifecycle state of `DELETE_IN_PROGRESS`, the project
        # cannot be restored.
        #
        # The caller must have modify permissions for this project.
        #
        # @param [String] project_id The ID of the project.
        #
        # @example
        #   require "google/cloud/resource_manager"
        #
        #   resource_manager = Google::Cloud::ResourceManager.new
        #   resource_manager.undelete "tokyo-rain-123"
        #
        def undelete project_id
          service.undelete_project project_id
          true
        end

        protected

        ##
        # Create an options hash from the projects parameters.
        def list_projects_options filter, options
          # Handle only sending in options
          if filter.is_a?(::Hash) && options.empty?
            options = filter
            filter = nil
          end
          # Give named parameter priority
          options[:filter] = filter || options[:filter]
          options
        end
      end
    end
  end
end
