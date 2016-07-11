# Copyright 2016 Google Inc. All rights reserved.
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
require "gcloud/errors"
require "google/apis/cloudresourcemanager_v1beta1"

module Gcloud
  module ResourceManager
    ##
    # @private
    # Represents the service to Resource Manager, as well as expose the API
    # calls.
    class Service
      ##
      # Alias to the Google Client API module
      API = Google::Apis::CloudresourcemanagerV1beta1

      attr_accessor :credentials

      ##
      # Creates a new Service instance.
      def initialize credentials, retries: nil
        @credentials = credentials
        @service = API::CloudResourceManagerService.new
        @service.client_options.application_name    = "gcloud-ruby"
        @service.client_options.application_version = Gcloud::VERSION
        @service.request_options.retries = retries || 3
        @service.authorization = @credentials.client
      end

      def service
        return mocked_service if mocked_service
        @service
      end
      attr_accessor :mocked_service

      ##
      # Returns API::ListProjectsResponse
      def list_project filter: nil, token: nil, max: nil
        service.list_projects page_token: token, page_size: max, filter: filter
      end

      ##
      # Returns API::Project
      def get_project project_id
        service.get_project project_id
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Returns API::Project
      def create_project project_id, name, labels
        project_attrs = { projectId: project_id, name: name,
                          labels: labels }.delete_if { |_, v| v.nil? }
        service.create_project API::Project.new(project_attrs)
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Updated the project, given a API::Project.
      # Returns API::Project
      def update_project project_gapi
        service.update_project project_gapi.project_id, project_gapi
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      def delete_project project_id
        service.delete_project project_id
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      def undelete_project project_id
        service.undelete_project project_id
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Returns API::Policy
      def get_policy project_id
        service.get_project_iam_policy "projects/#{project_id}"
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Returns API::Policy
      def set_policy project_id, new_policy
        req = API::SetIamPolicyRequest.new policy: new_policy
        service.set_project_iam_policy "projects/#{project_id}", req
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      ##
      # Returns API::TestIamPermissionsResponse
      def test_permissions project_id, permissions
        req = API::TestIamPermissionsRequest.new permissions: permissions
        service.test_project_iam_permissions "projects/#{project_id}", req
      rescue Google::Apis::Error => e
        raise Gcloud::Error.from_error(e)
      end

      def inspect
        "#{self.class}"
      end
    end
  end
end
