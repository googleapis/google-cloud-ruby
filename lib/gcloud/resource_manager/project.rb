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

require "time"
require "gcloud/resource_manager/errors"
require "gcloud/resource_manager/project/list"
require "gcloud/resource_manager/project/updater"

module Gcloud
  module ResourceManager
    ##
    # = Project
    #
    # Project is a high-level Google Cloud Platform entity. It is a container
    # for ACLs, APIs, AppEngine Apps, VMs, and other Google Cloud Platform
    # resources.
    #
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   resource_manager = gcloud.resource_manager
    #   project = resource_manager.project "tokyo-rain-123"
    #   project.update do |p|
    #     p.name = "My Project"
    #     p.labels["env"] = "production"
    #   end
    #
    class Project
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # The Google API Client object.
      attr_accessor :gapi #:nodoc:

      ##
      # Create an empty Project object.
      def initialize #:nodoc:
        @connection = nil
        @gapi = {}
      end

      ##
      # The unique, user-assigned ID of the project. It must be 6 to 30
      # lowercase letters, digits, or hyphens. It must start with a letter.
      # Trailing hyphens are prohibited. e.g. tokyo-rain-123
      #
      def project_id
        @gapi["projectId"]
      end

      ##
      # The number uniquely identifying the project. e.g. 415104041262
      #
      def project_number
        @gapi["projectNumber"]
      end

      ##
      # The user-assigned name of the project.
      #
      def name
        @gapi["name"]
      end

      ##
      # Updates the user-assigned name of the project. This field is optional
      # and can remain unset.
      #
      # Allowed characters are: lowercase and uppercase letters, numbers,
      # hyphen, single-quote, double-quote, space, and exclamation point.
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   resource_manager = gcloud.resource_manager
      #   project = resource_manager.project "tokyo-rain-123"
      #   project.name = "My Project"
      #
      def name= new_name
        ensure_connection!
        @gapi["name"] = new_name
        resp = connection.update_project @gapi
        if resp.success?
          @gapi = resp.data
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # The labels associated with this project.
      #
      # Label keys must be between 1 and 63 characters long and must conform to
      # the regular expression <code>[a-z]([-a-z0-9]*[a-z0-9])?</code>.
      #
      # Label values must be between 0 and 63 characters long and must conform
      # to the regular expression <code>([a-z]([-a-z0-9]*[a-z0-9])?)?</code>.
      #
      # No more than 256 labels can be associated with a given resource.
      # (+Hash+)
      #
      # === Examples
      #
      # Labels are read-only and cannot be changed by direct assignment.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   resource_manager = gcloud.resource_manager
      #   project = resource_manager.project "tokyo-rain-123"
      #   project.labels["env"] #=> "dev" # read only
      #   project.labels["env"] = "production" # raises error
      #
      # Labels can be updated by passing a block, or by calling the #labels=
      # method.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   resource_manager = gcloud.resource_manager
      #   project = resource_manager.project "tokyo-rain-123"
      #   project.labels do |labels|
      #     labels["env"] = "production"
      #   end
      #
      def labels
        labels = @gapi["labels"]
        labels = labels.to_hash if labels.respond_to? :to_hash
        if block_given?
          yielded_labels = labels.dup
          yield yielded_labels
          self.labels = yielded_labels if yielded_labels != labels # changed
        else
          labels.freeze
        end
      end

      ##
      # Updates the labels associated with this project.
      #
      # Label keys must be between 1 and 63 characters long and must conform to
      # the regular expression <code>[a-z]([-a-z0-9]*[a-z0-9])?</code>.
      #
      # Label values must be between 0 and 63 characters long and must conform
      # to the regular expression <code>([a-z]([-a-z0-9]*[a-z0-9])?)?</code>.
      #
      # No more than 256 labels can be associated with a given resource.
      # (+Hash+)
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   resource_manager = gcloud.resource_manager
      #   project = resource_manager.project "tokyo-rain-123"
      #   project.labels = { "env" => "production" }
      #
      def labels= new_labels
        ensure_connection!
        @gapi["labels"] = new_labels
        resp = connection.update_project @gapi
        if resp.success?
          @gapi = resp.data
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # The time that this project was created.
      #
      def created_at
        Time.parse @gapi["createTime"]
      rescue
        nil
      end

      ##
      # The project lifecycle state.
      #
      # Possible values are:
      # * +ACTIVE+ - The normal and active state.
      # * +LIFECYCLE_STATE_UNSPECIFIED+ - Unspecified state. This is only
      #   used/useful for distinguishing unset values.
      # * +DELETE_REQUESTED+ - The project has been marked for deletion by the
      #   user (by invoking DeleteProject) or by the system (Google Cloud
      #   Platform). This can generally be reversed by invoking UndeleteProject.
      # * +DELETE_IN_PROGRESS+ - The process of deleting the project has begun.
      #   Reversing the deletion is no longer possible.
      #
      def state
        @gapi["lifecycleState"]
      end

      ##
      # Checks if the state is +ACTIVE+.
      def active?
        return false if state.nil?
        "ACTIVE".casecmp(state).zero?
      end

      ##
      # Checks if the state is +LIFECYCLE_STATE_UNSPECIFIED+.
      def unspecified?
        return false if state.nil?
        "LIFECYCLE_STATE_UNSPECIFIED".casecmp(state).zero?
      end

      ##
      # Checks if the state is +DELETE_REQUESTED+.
      def delete_requested?
        return false if state.nil?
        "DELETE_REQUESTED".casecmp(state).zero?
      end

      ##
      # Checks if the state is +DELETE_IN_PROGRESS+.
      def delete_in_progress?
        return false if state.nil?
        "DELETE_IN_PROGRESS".casecmp(state).zero?
      end

      ##
      # Updates the project in a single API call. See Project::Updater
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   resource_manager = gcloud.resource_manager
      #   project = resource_manager.project "tokyo-rain-123"
      #   project.update do |p|
      #     p.name = "My Project"
      #     p.labels["env"] = "production"
      #   end
      #
      def update
        updater = Updater.from_project self
        yield updater
        resp = connection.update_project updater.gapi
        if resp.success?
          @gapi = resp.data
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Reloads the project (with updated state) from the Google Cloud Resource
      # Manager service.
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   resource_manager = gcloud.resource_manager
      #   project = resource_manager.project "tokyo-rain-123"
      #   project.reload!
      #
      def reload!
        resp = connection.get_project project_id
        if resp.success?
          @gapi = resp.data
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :refresh!, :reload!

      ##
      # Marks the project for deletion. This method will only affect the project
      # if the following criteria are met:
      #
      # * The project does not have a billing account associated with it.
      # * The project has a lifecycle state of +ACTIVE+.
      # * This method changes the project's lifecycle state from +ACTIVE+ to
      #   +DELETE_REQUESTED+. The deletion starts at an unspecified time, at
      #   which point the lifecycle state changes to +DELETE_IN_PROGRESS+.
      #
      # Until the deletion completes, you can check the lifecycle state by
      # calling #reload!, or by retrieving the project with Manager#project. The
      # project remains visible to Manager#project and Manager#projects, but
      # cannot be updated.
      #
      # After the deletion completes, the project is not retrievable by the
      # Manager#project and Manager#projects methods.
      #
      # The caller must have modify permissions for this project.
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   resource_manager = gcloud.resource_manager
      #   project = resource_manager.project "tokyo-rain-123"
      #   project.active? #=> true
      #   project.delete
      #   project.active? #=> false
      #   project.delete_requested? #=> true
      #
      def delete
        resp = connection.delete_project project_id
        if resp.success?
          reload!
          true
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Restores the project. You can only use this method for a project that
      # has a lifecycle state of +DELETE_REQUESTED+. After deletion starts, as
      # indicated by a lifecycle state of +DELETE_IN_PROGRESS+, the project
      # cannot be restored.
      #
      # The caller must have modify permissions for this project.
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   resource_manager = gcloud.resource_manager
      #   project = resource_manager.project "tokyo-rain-123"
      #   project.delete_requested? #=> true
      #   project.undelete
      #   project.delete_requested? #=> false
      #   project.active? #=> true
      #
      def undelete
        resp = connection.undelete_project project_id
        if resp.success?
          reload!
          true
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Gets the {Cloud IAM}[https://cloud.google.com/iam/] access control
      # policy. See {Managing
      # Policies}[https://cloud.google.com/iam/docs/managing-policies]
      # for more information.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:force]</code>::
      #   Force load the latest policy when +true+. Otherwise the policy will be
      #   memoized to reduce the number of API calls made. The default is
      #   +false+. (+Boolean+)
      #
      # === Returns
      #
      # A hash that conforms to the following structure:
      #
      #   {
      #     "bindings" => [{
      #       "role" => "roles/viewer",
      #       "members" => ["serviceAccount:your-service-account"]
      #     }],
      #     "version" => 0,
      #     "etag" => "CAE="
      #   }
      #
      # === Examples
      #
      # By default the policy values are memoized to reduce the number of API
      # calls made.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   resource_manager = gcloud.resource_manager
      #   project = resource_manager.project "tokyo-rain-123"
      #   policy = project.policy
      #
      #   puts policy["bindings"]
      #   puts policy["version"]
      #   puts policy["etag"]
      #
      # Use the +force+ option to retrieve the latest policy from the service.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   resource_manager = gcloud.resource_manager
      #   project = resource_manager.project "tokyo-rain-123"
      #   policy = project.policy force: true
      #
      def policy options = {}
        @policy = nil if options[:force]
        @policy ||= begin
          ensure_connection!
          resp = connection.get_policy project_id
          fail ApiError.from_response(resp) unless resp.success?
          policy = resp.data["policy"]
          policy = policy.to_hash if policy.respond_to? :to_hash
          policy
        end
      end

      ##
      # Sets the {Cloud IAM}[https://cloud.google.com/iam/] access control
      # policy. See {Managing
      # Policies}[https://cloud.google.com/iam/docs/managing-policies]
      # for more information.
      #
      # === Parameters
      #
      # +new_policy+::
      #   A hash that conforms to the following structure:
      #
      #   {
      #     "bindings" => [{
      #       "role" => "roles/viewer",
      #       "members" => ["serviceAccount:your-service-account"]
      #     }]
      #   }
      #
      # === Example
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
      def policy= new_policy
        ensure_connection!
        resp = connection.set_policy project_id, new_policy
        if resp.success?
          @policy = resp.data["policy"]
          @policy = @policy.to_hash if @policy.respond_to? :to_hash
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Tests the specified permissions against the {Cloud
      # IAM}[https://cloud.google.com/iam/] access control policy. See
      # {Managing Policies}[https://cloud.google.com/iam/docs/managing-policies]
      # for more information.
      #
      # === Parameters
      #
      # +permissions+::
      #   The set of permissions to check access for. Permissions with wildcards
      #   (such as +*+ or +storage.*+) are not allowed.
      #   (String or Array of Strings)
      #
      # === Returns
      #
      # The permissions that have access. (Array of Strings)
      #
      # === Example
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
      def test_permissions *permissions
        permissions = Array(permissions).flatten
        ensure_connection!
        resp = connection.test_permissions project_id, permissions
        if resp.success?
          Array(resp.data["permissions"])
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # New Change from a Google API Client object.
      def self.from_gapi gapi, connection #:nodoc:
        new.tap do |p|
          p.gapi = gapi
          p.connection = connection
        end
      end

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless connection
      end
    end
  end
end
