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
    # # Project
    #
    # Projects are top-level containers in Google Cloud Platform. They store
    # information about billing and authorized users, and they control access to
    # Google Cloud Search resources. Each project has a friendly name and a
    # unique ID. Projects can be created only in the [Google Developers
    # Console](https://console.developers.google.com). See {Gcloud#search}.
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   search = gcloud.search
    #   index = search.index "books"
    #
    class Project
      ##
      # @private The Connection object.
      attr_accessor :connection

      ##
      # @private Creates a new Connection instance.
      #
      # See Gcloud.search
      def initialize project, credentials
        project = project.to_s # Always cast to a string
        fail ArgumentError, "project is missing" if project.empty?
        @connection = Connection.new project, credentials
      end

      ##
      # The ID of the current project.
      #
      # @return [String]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new "my-project", "/path/to/keyfile.json"
      #   search = gcloud.search
      #
      #   search.project #=> "my-project"
      #
      def project
        connection.project
      end

      ##
      # @private Default project.
      def self.default_project
        ENV["SEARCH_PROJECT"] ||
          ENV["GCLOUD_PROJECT"] ||
          ENV["GOOGLE_CLOUD_PROJECT"] ||
          Gcloud::GCE.project_id
      end

      ##
      # Retrieves an existing index by ID.
      #
      # @param [String] index_id The ID of an index.
      # @param [Boolean] skip_lookup Optionally create an Index object without
      #   verifying the index resource exists on the Search service. Documents
      #   saved on this object will create the index resource if the resource
      #   does not yet exist. Default is +false+.
      #
      # @return [Gcloud::Search::Index, nil] nil if the index does not exist
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #
      #   index = search.index "books"
      #   index.index_id #=> "books"
      #
      # @example A new index can be created with +index_id+ and +skip_lookup+:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #
      #   index = search.index "more-books"
      #   index #=> nil
      #   index = search.index "more-books", skip_lookup: true
      #   index.index_id #=> "more-books"
      #
      def index index_id, skip_lookup: false
        if skip_lookup
          index_hash = { "indexId" => index_id, "projectId" => project }
          return Gcloud::Search::Index.from_raw index_hash, connection
        end
        indexes(prefix: index_id).all.detect do |ix|
          ix.index_id == index_id
        end
      end

      ##
      # Retrieves the list of indexes belonging to the project.
      #
      # @param [String] prefix The prefix of the index name. It is used to list
      #   all indexes with names that have this prefix.
      # @param [String] token A previously-returned page token representing part
      #   of the larger set of results to view.
      # @param [Integer] max Maximum number of indexes to return. The default is
      #   +100+.
      #
      # @return [Array<Gcloud::Search::Index>] (See
      #   {Gcloud::Search::Index::List})
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #
      #   indexes = search.indexes
      #   indexes.each do |index|
      #     puts index.index_id
      #   end
      #
      # @example Using pagination: (See {Gcloud::Search::Index::List})
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   search = gcloud.search
      #
      #   indexes = search.indexes
      #   loop do
      #     indexes.each do |index|
      #       puts index.index_id
      #     end
      #     break unless indexes.next?
      #     indexes = indexes.next
      #   end
      #
      def indexes prefix: nil, token: nil, max: nil
        ensure_connection!
        options = { prefix: prefix, token: token, max: max }
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
