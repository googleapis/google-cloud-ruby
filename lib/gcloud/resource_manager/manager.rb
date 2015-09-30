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
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:filter]</code>::
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
      #   projects = resource_manager.projects filter: "labels.env:production"
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
      def projects options = {}
        resp = connection.list_project options
        if resp.success?
          Project::List.from_response resp, self
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Retrieves the project identified by the specified +project_id+.
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
    end
  end
end
