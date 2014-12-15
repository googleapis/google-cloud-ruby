# Copyright 2014 Google Inc. All rights reserved.
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
  module Storage
    ##
    # Represents the connection to Storage,
    # as well as expose the API calls.
    class Connection #:nodoc:
      API_VERSION = "v1"
      API_URL = "https://www.googleapis.com"

      attr_accessor :project
      attr_accessor :credentials #:nodoc:

      ##
      # Creates a new Connection instance.
      def initialize project, credentials
        @project = project
        @credentials = credentials
        @client = Google::APIClient.new application_name:    "gcloud-ruby",
                                        application_version: Gcloud::VERSION
        @client.authorization = @credentials.client
        @storage = @client.discovered_api "storage", "v1"
      end

      ##
      # Retrieves a list of buckets for the given project.
      def list_buckets
        @client.execute(
          api_method: @storage.buckets.list,
          parameters: { project: @project }
        )
      end

      ##
      # Retrieves bucket by name.
      def get_bucket bucket_name
        @client.execute(
          api_method: @storage.buckets.get,
          parameters: { bucket: bucket_name }
        )
      end

      ##
      # Creates a new bucket.
      def insert_bucket bucket_name
        @client.execute(
          api_method: @storage.buckets.insert,
          parameters: { project: @project },
          body_object: { name: bucket_name }
        )
      end
    end
  end
end
