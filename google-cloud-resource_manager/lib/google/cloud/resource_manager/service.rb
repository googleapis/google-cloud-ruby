# Copyright 2016 Google LLC
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


require "google/cloud/errors"
require "google/cloud/resource_manager/version"
require "google/apis/cloudresourcemanager_v1"

module Google
  module Cloud
    module ResourceManager
      ##
      # @private
      # Represents the service to Resource Manager, as well as expose the API
      # calls.
      class Service
        ##
        # Alias to the Google Client API module
        API = Google::Apis::CloudresourcemanagerV1

        attr_accessor :credentials

        ##
        # Creates a new Service instance.
        def initialize credentials, retries: nil, timeout: nil
          @credentials = credentials
          @service = API::CloudResourceManagerService.new
          @service.client_options.application_name = \
            "gcloud-ruby"
          @service.client_options.application_version = \
            Google::Cloud::ResourceManager::VERSION
          @service.client_options.open_timeout_sec = timeout
          @service.client_options.read_timeout_sec = timeout
          @service.client_options.send_timeout_sec = timeout
          @service.request_options.retries = retries || 3
          @service.request_options.header ||= {}
          @service.request_options.header["x-goog-api-client"] = \
            "gl-ruby/#{RUBY_VERSION} " \
            "gccl/#{Google::Cloud::ResourceManager::VERSION}"
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
          execute do
            service.list_projects page_token: token, page_size: max,
                                  filter: filter
          end
        end

        ##
        # Returns API::Project
        def get_project project_id
          execute { service.get_project project_id }
        end

        ##
        # Returns API::Project
        def create_project project_id, name, labels
          project_attrs = { project_id: project_id, name: name,
                            labels: labels }.delete_if { |_, v| v.nil? }
          execute { service.create_project API::Project.new(project_attrs) }
        end

        ##
        # Updated the project, given a API::Project.
        # Returns API::Project
        def update_project project_gapi
          execute do
            service.update_project project_gapi.project_id, project_gapi
          end
        end

        def delete_project project_id
          execute { service.delete_project project_id }
        end

        def undelete_project project_id
          execute { service.undelete_project project_id }
        end

        ##
        # Returns API::Policy
        def get_policy project_id
          execute { service.get_project_iam_policy project_id }
        end

        ##
        # Returns API::Policy
        def set_policy project_id, new_policy
          req = API::SetIamPolicyRequest.new policy: new_policy
          execute do
            service.set_project_iam_policy project_id, req
          end
        end

        ##
        # Returns API::TestIamPermissionsResponse
        def test_permissions project_id, permissions
          req = API::TestIamPermissionsRequest.new permissions: permissions
          execute do
            service.test_project_iam_permissions project_id, req
          end
        end

        def inspect
          self.class.to_s
        end

        protected

        def execute
          yield
        rescue Google::Apis::Error => e
          raise Google::Cloud::Error.from_error(e)
        end
      end
    end
  end
end
