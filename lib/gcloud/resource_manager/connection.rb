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

      def list_project options = {}
        params = { filter: options.delete(:filter),
                   pageToken: options.delete(:token),
                   maxResults: options.delete(:max)
                 }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @res_man.projects.list,
          parameters: params
        )
      end

      def get_project project_id
        @client.execute(
          api_method: @res_man.projects.get,
          parameters: { projectId: project_id }
        )
      end

      def create_project project_id, name, labels
        project_gapi = { projectId: project_id, name: name,
                         labels: labels }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @res_man.projects.create,
          body_object: project_gapi
        )
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

      def delete_project project_id
        @client.execute(
          api_method: @res_man.projects.delete,
          parameters: { projectId: project_id }
        )
      end

      def undelete_project project_id
        @client.execute(
          api_method: @res_man.projects.undelete,
          parameters: { projectId: project_id }
        )
      end

      def get_policy project_id
        @client.execute(
          api_method: @res_man.projects.get_iam_policy,
          parameters: { resource: project_id }
        )
      end

      def set_policy project_id, new_policy
        @client.execute(
          api_method: @res_man.projects.set_iam_policy,
          parameters: { resource: project_id },
          body_object: { policy: new_policy }
        )
      end

      def test_permissions project_id, permissions
        @client.execute(
          api_method: @res_man.projects.test_iam_permissions,
          parameters: { resource: project_id },
          body_object: { permissions: permissions }
        )
      end

      def inspect #:nodoc:
        "#{self.class}(#{@project})"
      end
    end
  end
end
