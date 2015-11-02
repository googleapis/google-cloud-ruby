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

require "gcloud/gce"
require "gcloud/search/connection"
require "gcloud/search/credentials"
require "gcloud/search/index"
require "gcloud/search/errors"

module Gcloud
  module Search
    ##
    # = Project
    #
    # See Gcloud#search
    class Project
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # Creates a new Connection instance.
      #
      # See Gcloud.search
      def initialize project, credentials #:nodoc:
        project = project.to_s # Always cast to a string
        fail ArgumentError, "project is missing" if project.empty?
        @connection = Connection.new project, credentials
      end

      ##
      # The unique ID string for the current project.
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new "my-todo-project", "/path/to/keyfile.json"
      #   search = gcloud.search
      #
      #   search.project #=> "my-todo-project"
      #
      def project
        connection.project
      end

      ##
      # Default project.
      def self.default_project #:nodoc:
        ENV["SEARCH_PROJECT"] ||
          ENV["GCLOUD_PROJECT"] ||
          ENV["GOOGLE_CLOUD_PROJECT"] ||
          Gcloud::GCE.project_id
      end

      def index index_id
        ensure_connection!
        resp = connection.list_indexes prefix: index_id
        if resp.success?
          # Find the index with the exact id, otherwise return nil
          data = Array(JSON.parse(resp.body)["indexes"]).detect do |ix|
            ix["indexId"] == index_id
          end
          return Index.from_raw(data, connection) unless data.nil?
          nil
        else
          fail ApiError.from_response(resp)
        end
      end

      def indexes options = {}
        ensure_connection!
        resp = connection.list_indexes options
        if resp.success?
          Index::List.from_response resp, connection
        else
          fail ApiError.from_response(resp)
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
