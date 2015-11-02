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
        @client = @credentials.client
        @connection = Faraday.default_connection
      end

      def list_indexes options = {}
        if options[:prefix]
          options[:params] ||= {}
          options[:params]["indexNamePrefix"] = options.delete :prefix
        end
        run "indexes", options
      end

      def inspect #:nodoc:
        "#{self.class}(#{@project})"
      end

      protected

      def run path, options = {}
        options[:uri] = uri path
        if @client.nil?
          @connection.get do |req|
            req.url options[:uri]
            req.params = options[:params] if options[:params]
            req.body = options[:body] if options[:body]
          end
        else
          options[:connection] = @connection
          @client.fetch_protected_resource options
        end
      end

      def uri path
        host = "https://cloudsearch.googleapis.com"
        "#{host}/#{API_VERSION}/projects/#{@project}/#{path}"
      end
    end
  end
end
