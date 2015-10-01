#--
# Copyright 2015 Google Inc. All rights reserved.
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

require "gcloud/resource_manager/credentials"
require "gcloud/resource_manager/connection"
require "gcloud/resource_manager/errors"
require "gcloud/resource_manager/project"

module Gcloud
  module ResourceManager
    ##
    # = Manager
    #
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   resource_manager = gcloud.resource_manager
    #   resource_manager.projects.each do |project|
    #     puts projects.project_id
    #   end
    #
    # See Gcloud#resource_manager
    class Manager
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # Creates a new Connection instance.
      #
      # See Gcloud.resource_manager
      def initialize credentials #:nodoc:
        @connection = Connection.new credentials
      end

      ##
      # Retrieves the projects that are visible to the user and satisfy the
      # specified filter. This method returns projects in an unspecified order.
      # New projects do not necessarily appear at the end of the list.
      #
      # === Parameters
      #
      # +filter+::
      #   An expression for filtering the results of the request. Filter rules
      #   are case insensitive. (+String+)
      #
      #   The fields eligible for filtering are:
      #   * +name+
      #   * +id+
      #   * +labels.key+ - where +key+ is the name of a label
      #
      #   Some examples of using labels as filters:
      #   * +name:*+ - The project has a name.
      #   * +name:Howl+ - The project's name is Howl or howl.
      #   * +name:HOWL+ - Equivalent to above.
      #   * +NAME:howl+ - Equivalent to above.
      #   * +labels.color:*+ - The project has the label color.
      #   * +labels.color:red+ - The project's label color has the value red.
      #   * +labels.color:red label.size:big+ - The project's label color has
      #   the value red and its label size has the value big.
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:token]</code>::
      #   A previously-returned page token representing part of the larger set
      #   of results to view. (+String+)
      # <code>options[:max]</code>::
      #   Maximum number of projects to return. (+Integer+)
      #
      # === Returns
      #
      # Array of Gcloud::ResourceManager::Project
      # (Gcloud::ResourceManager::Project::List)
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   resource_manager = gcloud.resource_manager
      #   projects = resource_manager.projects
      #   projects.each do |project|
      #     puts project.project_id
      #   end
      #
      # Projects can be filtered using the +filter+ option:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   resource_manager = gcloud.resource_manager
      #   projects = resource_manager.projects "labels.env:production"
      #   projects.each do |project|
      #     puts project.project_id
      #   end
      #
      # If you have a significant number of projects, you may need to paginate
      # through them: (Gcloud::ResourceManager::Project::List)
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   resource_manager = gcloud.resource_manager
      #   projects = resource_manager.projects.all
      #   projects.each do |project|
      #     puts project.project_id
      #   end
      #
      def projects filter = nil, options = {}
        resp = connection.list_project list_projects_options(filter, options)
        if resp.success?
          Project::List.from_response resp, self
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Retrieves the project identified by the specified +project_id+.
      #
      # === Parameters
      #
      # +project_id+::
      #   The ID of the project. (+String+)
      #
      # === Returns
      #
      # Gcloud::ResourceManager::Project, or +nil+ if the project does not exist
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   resource_manager = gcloud.resource_manager
      #   project = resource_manager.project "tokyo-rain-123"
      #   project.project_id #=> "tokyo-rain-123"
      #
      def project project_id
        resp = connection.get_project project_id
        if resp.success?
          Project.from_gapi resp.data, connection
        else
          nil
        end
      end

      ##
      # Creates a project resource.
      #
      # Initially, the project resource is owned by its creator exclusively. The
      # creator can later grant permission to others to read or update the
      # project.
      #
      # Several APIs are activated automatically for the project, including
      # Google Cloud Storage.
      #
      # === Parameters
      #
      # +project_id+::
      #   The unique, user-assigned ID of the project. It must be 6 to 30
      #   lowercase letters, digits, or hyphens. It must start with a letter.
      #   Trailing hyphens are prohibited. (+String+)
      # +name+::
      #   The user-assigned name of the project. This field is optional and can
      #   remain unset.
      #
      #   Allowed characters are: lowercase and uppercase letters, numbers,
      #   hyphen, single-quote, double-quote, space, and exclamation point.
      #   (+String+)
      # +name+::
      #   The labels associated with this project.
      #
      #   Label keys must be between 1 and 63 characters long and must conform
      #   to the following regular expression: [a-z]([-a-z0-9]*[a-z0-9])?.
      #
      #   Label values must be between 0 and 63 characters long and must conform
      #   to the regular expression ([a-z]([-a-z0-9]*[a-z0-9])?)?.
      #
      #   No more than 256 labels can be associated with a given resource.
      #
      #   Clients should store labels in a representation such as JSON that does
      #   not depend on specific characters being disallowed. (+Hash+)
      #
      # === Returns
      #
      # Gcloud::ResourceManager::Project
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   resource_manager = gcloud.resource_manager
      #   project = resource_manager.create_project "tokyo-rain-123"
      #
      # A project can also be created with a +name+ and +labels+.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   resource_manager = gcloud.resource_manager
      #   project = resource_manager.create_project "tokyo-rain-123",
      #                                             "Todos Development",
      #                                             "env" => "development"
      #
      def create_project project_id, name = nil, labels = {}
        labels = nil if labels && labels.empty?
        resp = connection.create_project project_id, name, labels
        if resp.success?
          Project.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Marks the project for deletion. This method will only affect the project
      # if the following criteria are met:
      #
      # * The project does not have a billing account associated with it.
      # * The project has a lifecycle state of +ACTIVE+.
      # * This method changes the project's lifecycle state from +ACTIVE+ to
      # +DELETE_REQUESTED_. The deletion starts at an unspecified time, at which
      # point the lifecycle state changes to +DELETE_IN_PROGRESS+.
      #
      # Until the deletion completes, you can check the lifecycle state checked
      # by retrieving the project with GetProject, and the project remains
      # visible to ListProjects. However, you cannot update the project.
      #
      # After the deletion completes, the project is not retrievable by the
      # GetProject and ListProjects methods.
      #
      # The caller must have modify permissions for this project.
      #
      # === Parameters
      #
      # +project_id+::
      #   The ID of the project. (+String+)
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   resource_manager = gcloud.resource_manager
      #   resource_manager.delete "tokyo-rain-123"
      #
      def delete project_id
        resp = connection.delete_project project_id
        if resp.success?
          true
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Restores the project. You can only use this method for a project that
      # has a lifecycle state of +DELETE_REQUESTED+. After deletion starts, as
      # indicated by a lifecycle state of +DELETE_IN_PROGRESS+, the project
      # cannot be restored.
      #
      # The caller must have modify permissions for this project.
      #
      # === Parameters
      #
      # +project_id+::
      #   The ID of the project. (+String+)
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   resource_manager = gcloud.resource_manager
      #   resource_manager.undelete "tokyo-rain-123"
      #
      def undelete project_id
        resp = connection.undelete_project project_id
        if resp.success?
          true
        else
          fail ApiError.from_response(resp)
        end
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
