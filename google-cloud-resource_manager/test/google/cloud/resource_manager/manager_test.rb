# Copyright 2015 Google LLC
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

require "helper"

describe Google::Cloud::ResourceManager::Manager, :mock_res_man do
  it "gets a project given a project_id" do
    mock = Minitest::Mock.new
    random_project = random_project_gapi(123)
    mock.expect :get_project, random_project, ["example-project-123"]

    resource_manager.service.mocked_service = mock
    project = resource_manager.project "example-project-123"
    mock.verify

    _(project).must_be_kind_of Google::Cloud::ResourceManager::Project
    _(project.project_id).must_equal "example-project-123"
  end

  it "creates a project" do
    mock = Minitest::Mock.new
    created_project = create_project_gapi("new-project-456")
    mock.expect :create_project, created_project, [Google::Apis::CloudresourcemanagerV1::Project.new(project_id: "new-project-456")]

    resource_manager.service.mocked_service = mock
    project = resource_manager.create_project "new-project-456"
    mock.verify

    _(project).must_be_kind_of Google::Cloud::ResourceManager::Project
    _(project.project_id).must_equal "new-project-456"
    _(project.name).must_be :nil?
    _(project.labels).must_be :empty?
    _(project.parent).must_be :nil?
  end

  it "creates a project with a name and labels and parent" do
    mock = Minitest::Mock.new
    created_project = create_project_gapi("new-project-789", "My New Project", {"env" => "development"}, Google::Apis::CloudresourcemanagerV1::ResourceId.new(type: "folder", id: "1234"))
    mock.expect :create_project, created_project, [Google::Apis::CloudresourcemanagerV1::Project.new(project_id: "new-project-789", name: "My New Project", labels: {:env => :development}, parent: {type: "folder", id: "1234"})]

    resource_manager.service.mocked_service = mock
    folder = resource_manager.resource "folder", "1234"
    project = resource_manager.create_project "new-project-789",
                                              name: "My New Project",
                                              labels: {env: :development},
                                              parent: folder
    mock.verify

    _(project).must_be_kind_of Google::Cloud::ResourceManager::Project
    _(project.project_id).must_equal "new-project-789"
    _(project.name).must_equal "My New Project"
    _(project.labels).must_equal("env" => "development")
    _(project.parent).must_be_kind_of Google::Cloud::ResourceManager::Resource
    _(project.parent.type).must_equal "folder"
    _(project.parent.id).must_equal "1234"
    _(project.parent).must_be :folder?
    _(project.parent).wont_be :organization?
  end

  it "lists projects" do
    mock = Minitest::Mock.new
    mock.expect :list_projects, list_projects_response(3), page_token: nil, page_size: nil, filter: nil

    resource_manager.service.mocked_service = mock
    projects = resource_manager.projects
    mock.verify

    _(projects.size).must_equal 3
    projects.each { |z| _(z).must_be_kind_of Google::Cloud::ResourceManager::Project }
  end

  it "lists projects with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_projects, list_projects_response(3, "next_page_token"), page_token: nil, page_size: 3, filter: nil

    resource_manager.service.mocked_service = mock
    projects = resource_manager.projects max: 3
    mock.verify

    _(projects.count).must_equal 3
    projects.each { |z| _(z).must_be_kind_of Google::Cloud::ResourceManager::Project }
    _(projects.token).wont_be :nil?
    _(projects.token).must_equal "next_page_token"
  end

  it "lists projects with filter set" do
    mock = Minitest::Mock.new
    mock.expect :list_projects, list_projects_response(3, "next_page_token"), page_token: nil, page_size: nil, filter: "labels.env:production"

    resource_manager.service.mocked_service = mock
    projects = resource_manager.projects filter: "labels.env:production"
    mock.verify

    _(projects.count).must_equal 3
    projects.each { |z| _(z).must_be_kind_of Google::Cloud::ResourceManager::Project }
    _(projects.token).wont_be :nil?
    _(projects.token).must_equal "next_page_token"
  end

  it "paginates projects" do
    mock = Minitest::Mock.new
    mock.expect :list_projects, list_projects_response(3, "next_page_token"), page_token: nil, page_size: nil, filter: nil
    mock.expect :list_projects, list_projects_response(2),                    page_token: "next_page_token", page_size: nil, filter: nil

    resource_manager.service.mocked_service = mock
    first_projects = resource_manager.projects
    second_projects = resource_manager.projects token: first_projects.token
    mock.verify

    _(first_projects.count).must_equal 3
    first_projects.each { |z| _(z).must_be_kind_of Google::Cloud::ResourceManager::Project }
    _(first_projects.token).wont_be :nil?
    _(first_projects.token).must_equal "next_page_token"

    _(second_projects.count).must_equal 2
    second_projects.each { |z| _(z).must_be_kind_of Google::Cloud::ResourceManager::Project }
    _(second_projects.token).must_be :nil?
  end

  it "paginates projects with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_projects, list_projects_response(3, "next_page_token"), page_token: nil, page_size: nil, filter: nil
    mock.expect :list_projects, list_projects_response(2),                    page_token: "next_page_token", page_size: nil, filter: nil

    resource_manager.service.mocked_service = mock
    first_projects = resource_manager.projects
    second_projects = first_projects.next
    mock.verify

    _(first_projects.count).must_equal 3
    first_projects.each { |z| _(z).must_be_kind_of Google::Cloud::ResourceManager::Project }
    _(first_projects.next?).must_equal true

    _(second_projects.count).must_equal 2
    second_projects.each { |z| _(z).must_be_kind_of Google::Cloud::ResourceManager::Project }
    _(second_projects.next?).must_equal false
  end

  it "paginates projects with next? and next and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_projects, list_projects_response(3, "next_page_token"), page_token: nil, page_size: 3, filter: nil
    mock.expect :list_projects, list_projects_response(2),                    page_token: "next_page_token", page_size: 3, filter: nil

    resource_manager.service.mocked_service = mock
    first_projects = resource_manager.projects max: 3
    second_projects = first_projects.next
    mock.verify

    _(first_projects.count).must_equal 3
    first_projects.each { |z| _(z).must_be_kind_of Google::Cloud::ResourceManager::Project }
    _(first_projects.next?).must_equal true

    _(second_projects.count).must_equal 2
    second_projects.each { |z| _(z).must_be_kind_of Google::Cloud::ResourceManager::Project }
    _(second_projects.next?).must_equal false
  end

  it "paginates projects with next? and next and filter set" do
    mock = Minitest::Mock.new
    mock.expect :list_projects, list_projects_response(3, "next_page_token"), page_token: nil, page_size: nil, filter: "labels.env:production"
    mock.expect :list_projects, list_projects_response(2),                    page_token: "next_page_token", page_size: nil, filter: "labels.env:production"

    resource_manager.service.mocked_service = mock
    first_projects = resource_manager.projects filter: "labels.env:production"
    second_projects = first_projects.next
    mock.verify

    _(first_projects.count).must_equal 3
    first_projects.each { |z| _(z).must_be_kind_of Google::Cloud::ResourceManager::Project }
    _(first_projects.next?).must_equal true

    _(second_projects.count).must_equal 2
    second_projects.each { |z| _(z).must_be_kind_of Google::Cloud::ResourceManager::Project }
    _(second_projects.next?).must_equal false
  end

  it "paginates projects with all" do
    mock = Minitest::Mock.new
    mock.expect :list_projects, list_projects_response(3, "next_page_token"), page_token: nil, page_size: nil, filter: nil
    mock.expect :list_projects, list_projects_response(2),                    page_token: "next_page_token", page_size: nil, filter: nil

    resource_manager.service.mocked_service = mock
    projects = resource_manager.projects.all.to_a
    mock.verify

    _(projects.count).must_equal 5
    projects.each { |z| _(z).must_be_kind_of Google::Cloud::ResourceManager::Project }
  end

  it "paginates projects with all and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_projects, list_projects_response(3, "next_page_token"), page_token: nil, page_size: 3, filter: nil
    mock.expect :list_projects, list_projects_response(2),                    page_token: "next_page_token", page_size: 3, filter: nil

    resource_manager.service.mocked_service = mock
    projects = resource_manager.projects(max: 3).all.to_a
    mock.verify

    _(projects.count).must_equal 5
    projects.each { |z| _(z).must_be_kind_of Google::Cloud::ResourceManager::Project }
  end

  it "paginates projects with all and filter set" do
    mock = Minitest::Mock.new
    mock.expect :list_projects, list_projects_response(3, "next_page_token"), page_token: nil, page_size: nil, filter: "labels.env:production"
    mock.expect :list_projects, list_projects_response(2),                    page_token: "next_page_token", page_size: nil, filter: "labels.env:production"

    resource_manager.service.mocked_service = mock
    projects = resource_manager.projects(filter: "labels.env:production").all.to_a
    mock.verify

    _(projects.count).must_equal 5
    projects.each { |z| _(z).must_be_kind_of Google::Cloud::ResourceManager::Project }
  end

  it "paginates projects with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_projects, list_projects_response(3, "next_page_token"),   page_token: nil, page_size: nil, filter: nil
    mock.expect :list_projects, list_projects_response(3, "second_page_token"), page_token: "next_page_token", page_size: nil, filter: nil

    resource_manager.service.mocked_service = mock
    projects = resource_manager.projects.all.take(5)
    mock.verify

    _(projects.count).must_equal 5
    projects.each { |z| _(z).must_be_kind_of Google::Cloud::ResourceManager::Project }
  end

  it "paginates projects with all and request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_projects, list_projects_response(3, "next_page_token"),   page_token: nil, page_size: nil, filter: nil
    mock.expect :list_projects, list_projects_response(3, "second_page_token"), page_token: "next_page_token", page_size: nil, filter: nil

    resource_manager.service.mocked_service = mock
    projects = resource_manager.projects.all(request_limit: 1).to_a
    mock.verify

    _(projects.count).must_equal 6
    projects.each { |z| _(z).must_be_kind_of Google::Cloud::ResourceManager::Project }
  end

  it "deletes a project" do
    mock = Minitest::Mock.new
    empty_response = Google::Apis::CloudresourcemanagerV1::Empty.new
    mock.expect :delete_project, empty_response, ["existing-project-123"]

    resource_manager.service.mocked_service = mock
    resource_manager.delete "existing-project-123"
    mock.verify
  end

  it "undeletes a project" do
    mock = Minitest::Mock.new
    empty_response = Google::Apis::CloudresourcemanagerV1::Empty.new
    mock.expect :undelete_project, empty_response, ["deleted-project-456"]

    resource_manager.service.mocked_service = mock
    resource_manager.undelete "deleted-project-456"
    mock.verify
  end

  it "creates a resource" do
    folder = resource_manager.resource "folder", "1234"
    _(folder).must_be_kind_of Google::Cloud::ResourceManager::Resource
    _(folder.type).must_equal "folder"
    _(folder.id).must_equal "1234"
    _(folder).must_be :folder?
    _(folder).wont_be :organization?

    organization = resource_manager.resource "organization", "7890"
    _(organization).must_be_kind_of Google::Cloud::ResourceManager::Resource
    _(organization.type).must_equal "organization"
    _(organization.id).must_equal "7890"
    _(organization).wont_be :folder?
    _(organization).must_be :organization?
  end

  it "creating a resource without type or id raises" do
    error = expect do
      resource_manager.resource "folder", nil
    end.must_raise ArgumentError
    _(error.message).must_equal "id is required"

    error = expect do
      resource_manager.resource nil, "1234"
    end.must_raise ArgumentError
    _(error.message).must_equal "type is required"
  end

  def create_project_gapi project_id = nil, name = nil, labels = {}, parent = nil
    gapi = random_project_gapi
    gapi.project_id = project_id if project_id
    gapi.name       = name
    gapi.labels     = labels
    gapi.parent     = parent
    gapi
  end

  def list_projects_response count = 2, token = nil
    projects = count.times.map { random_project_gapi }
    hash = { projects: projects }
    hash[:next_page_token] = token unless token.nil?
    Google::Apis::CloudresourcemanagerV1::ListProjectsResponse.new(**hash)
  end
end
