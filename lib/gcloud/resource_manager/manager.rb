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
