# Copyright 2016 Google LLC
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

require "google/cloud/resource_manager"

module Google
  module Cloud
    module ResourceManager
      def self.stub_new
        define_singleton_method :new do |*args|
          yield *args
        end
      end
      # Create default unmocked methods that will raise if ever called
      def self.new *args
        raise "This code example is not yet mocked"
      end
      class Credentials
        # Override the default constructor
        def self.new *args
          OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))
        end
      end
    end
  end
end

def mock_translate
  Google::Cloud::ResourceManager.stub_new do |*args|
    credentials = OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {}))

    resource_manager = Google::Cloud::ResourceManager::Manager.new(Google::Cloud::ResourceManager::Service.new(credentials))

    resource_manager.service = Minitest::Mock.new
    yield resource_manager.service
    resource_manager
  end
end

YARD::Doctest.configure do |doctest|
  # Skip aliases
  doctest.skip "Google::Cloud::ResourceManager::Project#refresh!"

  doctest.before "Google::Cloud#resource_manager" do
    mock_translate do |mock|
      mock.expect :list_project, OpenStruct.new(projects: []), [Hash]
    end
  end

  doctest.before "Google::Cloud.resource_manager" do
    mock_translate do |mock|
      mock.expect :list_project, OpenStruct.new(projects: []), [Hash]
    end
  end

  doctest.before "Google::Cloud::ResourceManager.new" do
    mock_translate do |mock|
      mock.expect :list_project, OpenStruct.new(projects: []), [Hash]
    end
  end

  doctest.skip "Google::Cloud::ResourceManager::Credentials" # occasionally getting "This code example is not yet mocked"

  doctest.before "Google::Cloud::ResourceManager::Manager" do
    mock_translate do |mock|
      mock.expect :list_project, OpenStruct.new(projects: []), [Hash]
    end
  end

  doctest.before "Google::Cloud::ResourceManager::Manager#project" do
    mock_translate do |mock|
      mock.expect :get_project, project_gapi, ["tokyo-rain-123"]
    end
  end

  doctest.before "Google::Cloud::ResourceManager::Manager#projects" do
    mock_translate do |mock|
      mock.expect :list_project, OpenStruct.new(projects: []), [Hash]
    end
  end

  doctest.before "Google::Cloud::ResourceManager::Manager#create_project" do
    mock_translate do |mock|
      mock.expect :create_project, project_gapi, ["tokyo-rain-123", nil, nil]
    end
  end

  doctest.before "Google::Cloud::ResourceManager::Manager#create_project@A project can also be created with a `name` and `labels`:" do
    mock_translate do |mock|
      mock.expect :create_project, project_gapi, ["tokyo-rain-123", "Todos Development", {:env=>:development}]
    end
  end

  doctest.before "Google::Cloud::ResourceManager::Manager#delete" do
    mock_translate do |mock|
      mock.expect :delete_project, project_gapi, ["tokyo-rain-123"]
    end
  end

  doctest.before "Google::Cloud::ResourceManager::Manager#undelete" do
    mock_translate do |mock|
      mock.expect :undelete_project, project_gapi, ["tokyo-rain-123"]
    end
  end

  doctest.before "Google::Cloud::ResourceManager::Project" do
    mock_translate do |mock|
      mock.expect :get_project, project_gapi, ["tokyo-rain-123"]
      mock.expect :update_project, project_gapi(labels: {"env"=>"production"}), [Google::Apis::CloudresourcemanagerV1::Project]
    end
  end

  doctest.before "Google::Cloud::ResourceManager::Project#reload!" do
    mock_translate do |mock|
      mock.expect :get_project, project_gapi, ["tokyo-rain-123"]
      mock.expect :get_project, project_gapi, ["tokyo-rain-123"]
    end
  end

  doctest.before "Google::Cloud::ResourceManager::Project#delete" do
    mock_translate do |mock|
      mock.expect :get_project, project_gapi, ["tokyo-rain-123"]
      mock.expect :delete_project, project_gapi(lifecycle_state: "DELETE_REQUESTED"), ["tokyo-rain-123"]
      mock.expect :get_project, project_gapi(lifecycle_state: "DELETE_REQUESTED"), ["tokyo-rain-123"]
    end
  end

  doctest.before "Google::Cloud::ResourceManager::Project#undelete" do
    mock_translate do |mock|
      mock.expect :get_project, project_gapi(lifecycle_state: "DELETE_REQUESTED"), ["tokyo-rain-123"]
      mock.expect :undelete_project, project_gapi, ["tokyo-rain-123"]
      mock.expect :get_project, project_gapi, ["tokyo-rain-123"]
    end
  end

  doctest.before "Google::Cloud::ResourceManager::Project#policy" do
    mock_translate do |mock|
      mock.expect :get_project, project_gapi, ["tokyo-rain-123"]
      mock.expect :get_policy, policy_gapi, ["tokyo-rain-123"]
      mock.expect :set_policy, policy_gapi, ["tokyo-rain-123", Google::Apis::CloudresourcemanagerV1::Policy]
    end
  end

  doctest.before "Google::Cloud::ResourceManager::Project#test_permissions" do
    mock_translate do |mock|
      mock.expect :get_project, project_gapi, ["tokyo-rain-123"]
      mock.expect :test_permissions, permissions_resp, ["tokyo-rain-123", ["resourcemanager.projects.get", "resourcemanager.projects.delete"]]
    end
  end

  doctest.before "Google::Cloud::ResourceManager::Project::List" do
    mock_translate do |mock|
      mock.expect :list_project, OpenStruct.new(projects: []), [Hash]
    end
  end

  doctest.before "Google::Cloud::ResourceManager::Policy" do
    mock_translate do |mock|
      mock.expect :get_project, project_gapi, ["tokyo-rain-123"]
      mock.expect :get_policy, policy_gapi, ["tokyo-rain-123"]
      mock.expect :set_policy, policy_gapi, ["tokyo-rain-123", Google::Apis::CloudresourcemanagerV1::Policy]
    end
  end
end

# Fixture helpers

def project_gapi project_id: "tokyo-rain-123", name: "My Project", labels: {}, lifecycle_state: "ACTIVE"
  Google::Apis::CloudresourcemanagerV1::Project.new(
    project_id: project_id, name: name, labels: labels, lifecycle_state: lifecycle_state
  )
end

def policy_gapi
  Google::Apis::CloudresourcemanagerV1::Policy.new(
    bindings: []
  )
end

def permissions_resp permissions: ["resourcemanager.projects.get"]
  Google::Apis::CloudresourcemanagerV1::TestIamPermissionsResponse.new(
    permissions: permissions
  )
end
