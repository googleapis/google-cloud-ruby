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

require "gcloud/version"
require "gcloud/search/api_client"

module Gcloud
  module Search
    ##
    # Represents the connection to Search,
    # as well as expose the API calls.
    class Connection #:nodoc:
      API_VERSION = "v1"

      attr_accessor :project
      attr_accessor :credentials #:nodoc:
      attr_accessor :client #:nodoc:
      attr_accessor :connection #:nodoc:

      ##
      # Creates a new Connection instance.
      def initialize project, credentials #:nodoc:
        @project = project
        @credentials = credentials
        client_config = {
          application_name: "gcloud-ruby",
          application_version: Gcloud::VERSION
        }
        @client = Gcloud::Search::APIClient.new client_config
        @client.authorization = @credentials.client
        @search = @client.discovered_api "cloudsearch", API_VERSION
      end

      def list_indexes options = {}
        params = { projectId: @project,
                   indexNamePrefix: options[:prefix],
                   view: (options[:view] || "FULL"),
                   pageSize: options[:max],
                   pageToken: options[:token]
        }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @search.indexes.list,
          parameters: params
        )
      end

      def delete_index index_id
        @client.execute(
          api_method: @search.indexes.delete,
          parameters: { projectId: @project,
                        indexId: index_id }
        )
      end

      def get_doc index_id, doc_id
        @client.execute(
          api_method: @search.documents.get,
          parameters: { projectId: @project,
                        indexId: index_id,
                        docId: doc_id }
        )
      end

      def list_docs index_id, options = {}
        params = { projectId: @project,
                   indexId: index_id,
                   view: (options[:view] || "FULL"),
                   pageSize: options[:max],
                   pageToken: options[:token]
                 }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @search.documents.list,
          parameters: params
        )
      end

      def create_doc index_id, document_hash
        @client.execute(
          api_method: @search.documents.create,
          parameters: { projectId: @project,
                        indexId: index_id },
          body_object: document_hash
        )
      end

      def delete_doc index_id, doc_id
        @client.execute(
          api_method: @search.documents.delete,
          parameters: { projectId: @project,
                        indexId: index_id,
                        docId: doc_id }
        )
      end

      def search index_id, query, options = {}
        @client.execute(
          api_method: @search.indexes.search,
          parameters: search_request(index_id, query, options)
        )
      end

      def inspect #:nodoc:
        "#{self.class}(#{@project})"
      end

      protected

      def search_request index_id, query, options = {}
        { projectId: @project,
          indexId: index_id,
          query: query,
          fieldExpressions: options[:expressions],
          matchedCountAccuracy: options[:matched_count_accuracy],
          offset: options[:offset],
          orderBy: options[:order],
          pageSize: options[:max],
          pageToken: options[:token],
          returnFields: options[:return_fields],
          scorerSize: options[:scorer_size],
          scorer: options[:scorer]
        }.delete_if { |_, v| v.nil? }
      end
    end
  end
end
