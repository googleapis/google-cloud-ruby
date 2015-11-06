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
require "google/api_client"

module Gcloud
  module Search
    ##
    # Temporary substitute for Google::APIClient. Once the Search API is
    # discoverable, initialization of this class in Connection should be
    # replaced with the Google API Client.
    class APIClient #:nodoc:
      attr_accessor :authorization, :connection

      ##
      # Creates a new APIClient instance.
      def initialize _options
        @connection = Faraday.default_connection
      end

      def discovered_api name, version
        DiscoveredApi.new name, version
      end

      def execute options
        api_method = options[:api_method]
        uri = api_method[:uri]
        params = options[:parameters]
        uri.gsub! "{projectId}", params.delete(:projectId) if params[:projectId]
        uri.gsub! "{indexId}", params.delete(:indexId) if params[:indexId]
        uri.gsub! "{docId}", params.delete(:docId) if params[:docId]
        run api_method[:method], uri, options
      end

      def inspect
        "#{self.class}(#{@project})"
      end

      protected

      ##
      # Return type for APIClient#discovered_api
      class DiscoveredApi
        def initialize name, version
          @name = name
          @version = version
        end

        def indexes
          IndexResourcePath.new @name, @version, "indexes", "indexId"
        end

        def documents
          ResourcePath.new @name,
                           @version,
                           "indexes/{indexId}/documents",
                           "docId"
        end
      end

      ##
      # Return type for DiscoveredApi http verb methods
      class ResourcePath
        def initialize api_name, api_version, resource_root, resource_id_param
          @root = "https://#{api_name}.googleapis.com/#{api_version}" \
                  "/projects/{projectId}/#{resource_root}"
          @resource_id_param = resource_id_param
        end

        def create
          api_method :post
        end

        def delete
          api_method :delete, "/{docId}"
        end

        def get
          api_method :get, "/{docId}"
        end

        def list
          api_method :get
        end

        def api_method method, path = nil
          { method: method, uri: "#{@root}#{path}" }
        end
      end

      ##
      # Special-case return type for DiscoveredApi http search verb method
      class IndexResourcePath < ResourcePath
        def search
          api_method :get, "/{indexId}/search"
        end
      end

      def run method, uri, options = {}
        fix_serialization! options
        if authorization.nil?
          @connection.send method do |req|
            req.url uri
            req.params = options[:parameters] if options[:parameters]
            req.body = options[:body] if options[:body]
          end
        else
          options[:method] = method
          options[:uri] = uri
          options[:connection] = @connection
          authorization.fetch_protected_resource options
        end
      end

      def fix_serialization! options
        return unless options[:body_object]
        options[:headers] = { "Content-Type" => "application/json" }
        options[:body] = options.delete(:body_object).to_json
      end
    end
  end
end
