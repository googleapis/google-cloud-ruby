# Copyright 2015 Google LLC
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


require "google-cloud-resource_manager"
require "google/cloud/resource_manager/manager"

module Google
  module Cloud
    ##
    # # Google Cloud Resource Manager
    #
    # The Resource Manager API provides methods that you can use to
    # programmatically manage your projects in the Google Cloud Platform. You
    # may be familiar with managing projects in the [Developers
    # Console](https://developers.google.com/console/help/new/). With this API
    # you can do the following:
    #
    # * Get a list of all projects associated with an account
    # * Create new projects
    # * Update existing projects
    # * Delete projects
    # * Undelete, or recover, projects that you don't want to delete
    #
    # ## Authentication
    #
    # The Resource Manager API currently requires authentication of a [User
    # Account](https://developers.google.com/identity/protocols/OAuth2), and
    # cannot currently be accessed with a [Service
    # Account](https://developers.google.com/identity/protocols/OAuth2ServiceAccount).
    # To use a User Account install the [Google Cloud
    # SDK](http://cloud.google.com/sdk) and authenticate with the following:
    #
    # ```
    # $ gcloud auth login
    # ```
    #
    # Also make sure all `GCLOUD` environment variables are cleared of any
    # service accounts. Then google-cloud will be able to detect the user
    # authentication and connect with those credentials.
    #
    # ```ruby
    # require "google/cloud/resource_manager"
    #
    # resource_manager = Google::Cloud::ResourceManager.new
    # ```
    #
    # ## Listing Projects
    #
    # Project is a collection of settings, credentials, and metadata about the
    # application or applications you're working on. You can retrieve and
    # inspect all projects that you have permissions to. (See
    # {Google::Cloud::ResourceManager::Manager#projects})
    #
    # ```ruby
    # require "google/cloud/resource_manager"
    #
    # resource_manager = Google::Cloud::ResourceManager.new
    # resource_manager.projects.each do |project|
    #   puts projects.project_id
    # end
    # ```
    #
    # ## Managing Projects with Labels
    #
    # Labels can be added to or removed from projects. (See
    # {Google::Cloud::ResourceManager::Project#labels})
    #
    # ```ruby
    # require "google/cloud/resource_manager"
    #
    # resource_manager = Google::Cloud::ResourceManager.new
    # project = resource_manager.project "tokyo-rain-123"
    # # Label the project as production
    # project.update do |p|
    #   p.labels["env"] = "production"
    # end
    # ```
    #
    # Projects can then be filtered by labels. (See
    # {Google::Cloud::ResourceManager::Manager#projects})
    #
    # ```ruby
    # require "google/cloud/resource_manager"
    #
    # resource_manager = Google::Cloud::ResourceManager.new
    # # Find only the productions projects
    # projects = resource_manager.projects filter: "labels.env:production"
    # projects.each do |project|
    #   puts project.project_id
    # end
    # ```
    #
    # ## Creating a Project
    #
    # You can also use the API to create new projects. (See
    # {Google::Cloud::ResourceManager::Manager#create_project})
    #
    # ```ruby
    # require "google/cloud/resource_manager"
    #
    # resource_manager = Google::Cloud::ResourceManager.new
    # project = resource_manager.create_project "tokyo-rain-123",
    #                                           name: "Todos Development",
    #                                           labels: {env: :development}
    # ```
    #
    # ## Deleting a Project
    #
    # You can delete projects when they are no longer needed. (See
    # {Google::Cloud::ResourceManager::Manager#delete} and
    # {Google::Cloud::ResourceManager::Project#delete})
    #
    # ```ruby
    # require "google/cloud/resource_manager"
    #
    # resource_manager = Google::Cloud::ResourceManager.new
    # resource_manager.delete "tokyo-rain-123"
    # ```
    #
    # ## Undeleting a Project
    #
    # You can also restore a deleted project within the waiting period that
    # starts when the project was deleted. Restoring a project returns it to the
    # state it was in prior to being deleted. (See
    # {Google::Cloud::ResourceManager::Manager#undelete} and
    # {Google::Cloud::ResourceManager::Project#undelete})
    #
    # ```ruby
    # require "google/cloud/resource_manager"
    #
    # resource_manager = Google::Cloud::ResourceManager.new
    # resource_manager.undelete "tokyo-rain-123"
    # ```
    #
    # ## Configuring retries and timeout
    #
    # You can configure how many times API requests may be automatically
    # retried. When an API request fails, the response will be inspected to see
    # if the request meets criteria indicating that it may succeed on retry,
    # such as `500` and `503` status codes or a specific internal error code
    # such as `rateLimitExceeded`. If it meets the criteria, the request will be
    # retried after a delay. If another error occurs, the delay will be
    # increased before a subsequent attempt, until the `retries` limit is
    # reached.
    #
    # You can also set the request `timeout` value in seconds.
    #
    # ```ruby
    # require "google/cloud/resource_manager"
    #
    # resource_manager = Google::Cloud::ResourceManager.new retries: 10,
    #                                                       timeout: 120
    # ```
    #
    # See the [Resource Manager error
    # messages](https://cloud.google.com/resource-manager/docs/core_errors)
    # for a list of error conditions.
    #
    # ## Managing IAM Policies
    #
    # Google Cloud Identity and Access Management ([Cloud
    # IAM](https://cloud.google.com/iam/)) access control policies can be
    # managed on projects. These policies allow project owners to manage _who_
    # (identity) has access to _what_ (role). See [Cloud IAM
    # Overview](https://cloud.google.com/iam/docs/overview) for more
    # information.
    #
    # A project's access control policy can be retrieved. (See
    # {Google::Cloud::ResourceManager::Project#policy} and
    # {Google::Cloud::ResourceManager::Policy}.)
    #
    # ```ruby
    # require "google/cloud/resource_manager"
    #
    # resource_manager = Google::Cloud::ResourceManager.new
    # project = resource_manager.project "tokyo-rain-123"
    # policy = project.policy
    # ```
    #
    # A project's access control policy can also be updated:
    #
    # ```ruby
    # require "google/cloud/resource_manager"
    #
    # resource_manager = Google::Cloud::ResourceManager.new
    # project = resource_manager.project "tokyo-rain-123"
    #
    # policy = project.policy do |p|
    #   p.add "roles/viewer", "serviceAccount:your-service-account"
    # end
    # ```
    #
    # And permissions can be tested on a project. (See
    # {Google::Cloud::ResourceManager::Project#test_permissions})
    #
    # ```ruby
    # require "google/cloud/resource_manager"
    #
    # resource_manager = Google::Cloud::ResourceManager.new
    # project = resource_manager.project "tokyo-rain-123"
    # perms = project.test_permissions "resourcemanager.projects.get",
    #                                  "resourcemanager.projects.delete"
    # perms.include? "resourcemanager.projects.get"    #=> true
    # perms.include? "resourcemanager.projects.delete" #=> false
    # ```
    #
    # For more information about using access control policies see [Managing
    # Policies](https://cloud.google.com/iam/docs/managing-policies).
    #
    module ResourceManager
      ##
      # Creates a new `Project` instance connected to the Resource Manager
      # service. Each call creates a new connection.
      #
      # For more information on connecting to Google Cloud see the
      # [Authentication
      # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
      #
      # @param [String, Hash, Google::Auth::Credentials] credentials The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {ResourceManager::Credentials})
      # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      #   See [Using OAuth 2.0 to Access Google
      #   APIs](https://developers.google.com/identity/protocols/OAuth2).
      #
      #   The default scope is:
      #
      #   * `https://www.googleapis.com/auth/cloud-platform`
      # @param [Integer] retries Number of times to retry requests on server
      #   error. The default value is `3`. Optional.
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      # @param [String] keyfile Alias for the `credentials` argument.
      #   Deprecated.
      #
      # @return [Google::Cloud::ResourceManager::Manager]
      #
      # @example
      #   require "google/cloud/resource_manager"
      #
      #   resource_manager = Google::Cloud::ResourceManager.new
      #   resource_manager.projects.each do |project|
      #     puts projects.project_id
      #   end
      #
      def self.new credentials: nil, scope: nil, retries: nil, timeout: nil,
                   keyfile: nil
        credentials ||= keyfile
        credentials ||= ResourceManager::Credentials.default(scope: scope)
        unless credentials.is_a? Google::Auth::Credentials
          credentials = ResourceManager::Credentials.new credentials,
                                                         scope: scope
        end

        ResourceManager::Manager.new(
          ResourceManager::Service.new(
            credentials, retries: retries, timeout: timeout))
      end
    end
  end
end
