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

module Gcloud
  module ResourceManager
    ##
    # = Project
    #
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   resource_manager = gcloud.resource_manager
    #   resource_manager.projects.each do |project|
    #     puts projects.project_id
    #   end
    #
    # See Gcloud#resource_manager
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
      # the following regular expression: [a-z]([-a-z0-9]*[a-z0-9])?.
      #
      # Label values must be between 0 and 63 characters long and must conform
      # to the regular expression ([a-z]([-a-z0-9]*[a-z0-9])?)?.
      #
      # No more than 256 labels can be associated with a given resource.
      #
      # Clients should store labels in a representation such as JSON that does
      # not depend on specific characters being disallowed.
      # e.g. +"environment" => "dev"+
      #
      def labels
        @gapi["labels"]
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
