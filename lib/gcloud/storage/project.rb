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

require "gcloud/storage/errors"
require "gcloud/storage/connection"
require "gcloud/storage/credentials"
require "gcloud/storage/bucket"
require "gcloud/storage/file"

module Gcloud
  module Storage
    ##
    # Represents the Project that the Buckets and Files belong to.
    class Project
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # Creates a new Connection instance.
      def initialize project, credentials
        @connection = Connection.new project, credentials
      end

      ##
      # The project identifier.
      def project
        connection.project
      end

      ##
      # Retrieves a list of buckets for the given project.
      def buckets
        resp = connection.list_buckets
        if resp.success?
          resp.data["items"].map do |gapi_object|
            Bucket.from_gapi gapi_object, connection
          end
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Retrieves bucket by name.
      def find_bucket bucket_name
        resp = connection.get_bucket bucket_name
        if resp.success?
          Bucket.from_gapi resp.data, connection
        else
          return nil if resp.data["error"]["code"] == 404
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Creates a new bucket.
      #
      #   bucket = project.create_bucket "my-bucket"
      #
      # The API call to create the bucket may be retried under certain
      # conditions. See Gcloud::Backoff to control this behavior, or
      # specify the wanted behavior in the call:
      #
      #   bucket = project.create_bucket "my-bucket", retries: 5
      def create_bucket bucket_name, options = {}
        resp = connection.insert_bucket bucket_name, options
        if resp.success?
          Bucket.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end
    end
  end
end
