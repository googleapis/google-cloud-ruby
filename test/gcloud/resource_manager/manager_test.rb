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

require "helper"

describe Gcloud::ResourceManager::Manager, :mock_res_man do
  it "gets a project given a project_id" do
    mock_connection.get "/v1beta1/projects/example-project-123" do |env|
      [200, {"Content-Type" => "application/json"},
       random_project_hash(123).to_json]
    end

    project = resource_manager.project "example-project-123"

    project.must_be_kind_of Gcloud::ResourceManager::Project
    project.project_id.must_equal "example-project-123"
  end

  it "lists projects" do
    num_projects = 3
    mock_connection.get "/v1beta1/projects" do |env|
      env.params.wont_include "maxResults"
      env.params.wont_include "filter"
      [200, {"Content-Type" => "application/json"},
       list_projects_json(num_projects)]
    end

    projects = resource_manager.projects
    projects.size.must_equal num_projects
    projects.each { |z| z.must_be_kind_of Gcloud::ResourceManager::Project }
  end

  it "lists projects with max set" do
    mock_connection.get "/v1beta1/projects" do |env|
      env.params.must_include "maxResults"
      env.params["maxResults"].must_equal "3"
      env.params.wont_include "filter"
      [200, {"Content-Type" => "application/json"},
       list_projects_json(3, "next_page_token")]
    end

    projects = resource_manager.projects max: 3
    projects.count.must_equal 3
    projects.each { |z| z.must_be_kind_of Gcloud::ResourceManager::Project }
    projects.token.wont_be :nil?
    projects.token.must_equal "next_page_token"
  end

  it "lists projects with filter set" do
    mock_connection.get "/v1beta1/projects" do |env|
      env.params.must_include "filter"
      env.params["filter"].must_equal "labels.env:production"
      env.params.wont_include "maxResults"
      [200, {"Content-Type" => "application/json"},
       list_projects_json(3, "next_page_token")]
    end

    projects = resource_manager.projects filter: "labels.env:production"
    projects.count.must_equal 3
    projects.each { |z| z.must_be_kind_of Gcloud::ResourceManager::Project }
    projects.token.wont_be :nil?
    projects.token.must_equal "next_page_token"
  end

  it "paginates projects" do
    mock_connection.get "/v1beta1/projects" do |env|
      env.params.wont_include "pageToken"
      [200, {"Content-Type" => "application/json"},
       list_projects_json(3, "next_page_token")]
    end
    mock_connection.get "/v1beta1/projects" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      [200, {"Content-Type" => "application/json"},
       list_projects_json(2)]
    end

    first_projects = resource_manager.projects
    first_projects.count.must_equal 3
    first_projects.each { |z| z.must_be_kind_of Gcloud::ResourceManager::Project }
    first_projects.token.wont_be :nil?
    first_projects.token.must_equal "next_page_token"

    second_projects = resource_manager.projects token: first_projects.token
    second_projects.count.must_equal 2
    second_projects.each { |z| z.must_be_kind_of Gcloud::ResourceManager::Project }
    second_projects.token.must_be :nil?
  end

  it "paginates projects with next? and next" do
    mock_connection.get "/v1beta1/projects" do |env|
      env.params.wont_include "pageToken"
      [200, {"Content-Type" => "application/json"},
       list_projects_json(3, "next_page_token")]
    end
    mock_connection.get "/v1beta1/projects" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      [200, {"Content-Type" => "application/json"},
       list_projects_json(2)]
    end

    first_projects = resource_manager.projects
    first_projects.count.must_equal 3
    first_projects.each { |z| z.must_be_kind_of Gcloud::ResourceManager::Project }
    first_projects.next?.must_equal true

    second_projects = first_projects.next
    second_projects.count.must_equal 2
    second_projects.each { |z| z.must_be_kind_of Gcloud::ResourceManager::Project }
    second_projects.next?.must_equal false
  end

  def list_projects_json count = 2, token = nil
    projects = count.times.map { random_project_hash }
    hash = { "projects" => projects }
    hash["nextPageToken"] = token unless token.nil?
    hash.to_json
  end
end
