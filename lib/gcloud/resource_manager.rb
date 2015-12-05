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

require "gcloud"
require "gcloud/resource_manager/manager"

#--
# Google Cloud Resource Manager
module Gcloud
  ##
  # Creates a new +Project+ instance connected to the Resource Manager service.
  # Each call creates a new connection.
  #
  # === Parameters
  #
  # +keyfile+::
  #   Keyfile downloaded from Google Cloud. If file path the file must be
  #   readable. (+String+ or +Hash+)
  # +options+::
  #   An optional Hash for controlling additional behavior. (+Hash+)
  # <code>options[:scope]</code>::
  #   The OAuth 2.0 scopes controlling the set of resources and operations that
  #   the connection can access. See {Using OAuth 2.0 to Access Google
  #   APIs}[https://developers.google.com/identity/protocols/OAuth2]. (+String+
  #   or +Array+)
  #
  #   The default scope is:
  #
  #   * +https://www.googleapis.com/auth/cloud-platform+
  #
  # === Returns
  #
  # Gcloud::ResourceManager::Manager
  #
  # === Example
  #
  #   require "gcloud/resource_manager"
  #
  #   resource_manager = Gcloud.resource_manager
  #   resource_manager.projects.each do |project|
  #     puts projects.project_id
  #   end
  #
  def self.resource_manager keyfile = nil, options = {}
    if keyfile.nil?
      credentials = Gcloud::ResourceManager::Credentials.default(
        scope: options[:scope])
    else
      credentials = Gcloud::ResourceManager::Credentials.new(
        keyfile, scope: options[:scope])
    end
    Gcloud::ResourceManager::Manager.new credentials
  end

  # rubocop:disable Metrics/LineLength
  # Disabled because there are links in the docs that are long.

  ##
  # = Google Cloud Resource Manager
  #
  # The Resource Manager API provides methods that you can use to
  # programmatically manage your projects in the Google Cloud Platform. You may
  # be familiar with managing projects in the {Developers
  # Console}[https://developers.google.com/console/help/new/]. With this API you
  # can do the following:
  #
  # * Get a list of all projects associated with an account
  # * Create new projects
  # * Update existing projects
  # * Delete projects
  # * Undelete, or recover, projects that you don't want to delete
  #
  # The Resource Manager API is a Beta release and is not covered by any SLA or
  # deprecation policy and may be subject to backward-incompatible changes.
  #
  # == Accessing the Service
  #
  # Currently, the full functionality of the Resource Manager API is available
  # only to whitelisted users. (Contact your account manager or a member of the
  # Google Cloud sales team if you are interested in access.) Read-only methods
  # such as ResourceManager::Manager#projects and
  # ResourceManager::Manager#project are accessible to any user who enables the
  # Resource Manager API in the {Developers
  # Console}[https://console.developers.google.com].
  #
  # == Authentication
  #
  # The Resource Manager API currently requires authentication of a {User
  # Account}[https://developers.google.com/identity/protocols/OAuth2], and
  # cannot currently be accessed with a {Service
  # Account}[https://developers.google.com/identity/protocols/OAuth2ServiceAccount].
  # To use a User Account install the {Google Cloud
  # SDK}[http://cloud.google.com/sdk] and authenticate with the following:
  #
  #   $ gcloud auth login
  #
  # Also make sure all +GCLOUD+ environment variables are cleared of any service
  # accounts. Then gcloud will be able to detect the user authentication and
  # connect with those credentials.
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   resource_manager = gcloud.resource_manager
  #
  # == Listing Projects
  #
  # Project is a collection of settings, credentials, and metadata about the
  # application or applications you're working on. You can retrieve and inspect
  # all projects that you have permissions to. (See Manager#projects)
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   resource_manager = gcloud.resource_manager
  #   resource_manager.projects.each do |project|
  #     puts projects.project_id
  #   end
  #
  # == Managing Projects with Labels
  #
  # Labels can be added to or removed from projects. (See Project#labels)
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   resource_manager = gcloud.resource_manager
  #   project = resource_manager.project "tokyo-rain-123"
  #   # Label the project as production
  #   project.update do |p|
  #     p.labels["env"] = "production"
  #   end
  #
  # Projects can then be filtered by labels. (See Manager#projects)
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   resource_manager = gcloud.resource_manager
  #   # Find only the productions projects
  #   projects = resource_manager.projects filter: "labels.env:production"
  #   projects.each do |project|
  #     puts project.project_id
  #   end
  #
  # == Creating a Project
  #
  # You can also use the API to create new projects. (See
  # Manager#create_project)
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   resource_manager = gcloud.resource_manager
  #   project = resource_manager.create_project "tokyo-rain-123",
  #                                             name: "Todos Development",
  #                                             labels: {env: :development}
  #
  # == Deleting a Project
  #
  # You can delete projects when they are no longer needed. (See
  # Manager#delete and Project#delete)
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   resource_manager = gcloud.resource_manager
  #   resource_manager.delete "tokyo-rain-123"
  #
  # == Undeleting a Project
  #
  # You can also restore a deleted project within the waiting period that
  # starts when the project was deleted. Restoring a project returns it to the
  # state it was in prior to being deleted. (See Manager#undelete and
  # Project#undelete)
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   resource_manager = gcloud.resource_manager
  #   resource_manager.undelete "tokyo-rain-123"
  #
  # == Managing IAM Policies
  #
  # Google Cloud Identity and Access Management ({Cloud
  # IAM}[https://cloud.google.com/iam/]) access control policies can be managed
  # on projects. These policies allow project owners to manage _who_ (identity)
  # has access to _what_ (role). See {Cloud IAM
  # Overview}[https://cloud.google.com/iam/docs/overview] for more information.
  #
  # A project's access control policy can be retrieved. (See Project#policy)
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   resource_manager = gcloud.resource_manager
  #   project = resource_manager.project "tokyo-rain-123"
  #   policy = project.policy
  #
  # A project's access control policy can also be set. (See Project#policy=)
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   resource_manager = gcloud.resource_manager
  #   project = resource_manager.project "tokyo-rain-123"
  #
  #   viewer_policy = {
  #     "bindings" => [{
  #       "role" => "roles/viewer",
  #       "members" => ["serviceAccount:your-service-account"]
  #     }]
  #   }
  #   project.policy = viewer_policy
  #
  # And permissions can be tested on a project. (See Project#test_permissions)
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   resource_manager = gcloud.resource_manager
  #   project = resource_manager.project "tokyo-rain-123"
  #   perms = project.test_permissions "resourcemanager.projects.get",
  #                                    "resourcemanager.projects.delete"
  #   perms.include? "resourcemanager.projects.get"    #=> true
  #   perms.include? "resourcemanager.projects.delete" #=> false
  #
  # For more information about using access control policies see {Managing
  # Policies}[https://cloud.google.com/iam/docs/managing-policies].
  #
  module ResourceManager
  end

  # rubocop:enable Metrics/LineLength
end
