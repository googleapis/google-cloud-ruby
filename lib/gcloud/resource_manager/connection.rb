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

require "gcloud/version"
require "google/api_client"

module Gcloud
  module ResourceManager
    ##
    # Represents the connection to Resource Manager, as well as expose the API
    # calls.
    class Connection #:nodoc:
      API_VERSION = "v1beta1"

      attr_accessor :credentials #:nodoc:

      ##
      # Creates a new Connection instance.
      def initialize credentials #:nodoc:
        @credentials = credentials
        @client = Google::APIClient.new application_name:    "gcloud-ruby",
                                        application_version: Gcloud::VERSION
        @client.authorization = @credentials.client
        @res_man = @client.discovered_api "cloudresourcemanager", API_VERSION
      end

      ##
      # Updated the project, given the project Google API Client object/hash.
      # We try not to pass the gapi objects, but there is no PATCH, so we need
      # to pass in a complete Project object.
      def update_project project_gapi
        project_id = project_gapi["projectId"]

        @client.execute(
          api_method: @res_man.projects.update,
          parameters: { projectId: project_id },
          body_object: project_gapi
        )
      end

      def inspect #:nodoc:
        "#{self.class}(#{@project})"
      end
    end
  end
end
