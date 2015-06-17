#--
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
    # = Project
    #
    # Represents the project that storage buckets and files belong to.
    # All data in Google Cloud Storage belongs inside a project.
    # A project consists of a set of users, a set of APIs, billing,
    # authentication, and monitoring settings for those APIs.
    #
    # Gcloud::Storage::Project is the main object for interacting with
    # Google Storage. Gcloud::Storage::Bucket objects are created,
    # read, updated, and deleted by Gcloud::Storage::Project.
    #
    #   require "gcloud/datastore"
    #
    #   storage = Gcloud.storage
    #
    #   bucket = storage.find_bucket "my-bucket"
    #   file = bucket.find_file "path/to/my-file.ext"
    #
    # See Gcloud.storage
    class Project
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # Creates a new Project instance.
      #
      # See Gcloud.storage
      def initialize project, credentials #:nodoc:
        @connection = Connection.new project, credentials
      end

      ##
      # The Storage project connected to.
      #
      # === Example
      #
      #   require "gcloud/datastore"
      #
      #   storage = Gcloud.storage "my-todo-project",
      #                            "/path/to/keyfile.json"
      #
      #   storage.project #=> "my-todo-project"
      #
      def project
        connection.project
      end

      ##
      # Default project.
      def self.default_project #:nodoc:
        ENV["STORAGE_PROJECT"] || ENV["GOOGLE_CLOUD_PROJECT"]
      end

      ##
      # Retrieves a list of buckets for the given project.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavor. (+Hash+)
      # +options [:prefix]+::
      #   Filter results to buckets whose names begin with this prefix.
      #   (+String+)
      # +options [:token]+::
      #   A previously-returned page token representing part of the larger set
      #   of results to view. (+String+)
      # +options [:max]+::
      #   Maximum number of buckets to return. (+Integer+)
      #
      # === Returns
      #
      # Array of Gcloud::Datastore::Bucket (Gcloud::Datastore::Bucket::List)
      #
      # === Examples
      #
      #   require "gcloud/datastore"
      #
      #   storage = Gcloud.storage
      #
      #   buckets = storage.buckets
      #   buckets.each do |bucket|
      #     puts bucket.name
      #   end
      #
      # You can also retrieve all buckets whose names begin with a prefix using
      # the +:prefix+ option:
      #
      #   require "gcloud/storage"
      #
      #   storage = Gcloud.storage
      #
      #   user_buckets = storage.buckets prefix: "user-"
      #
      # If you have a significant number of buckets, you may need to paginate
      # through them: (See Bucket::List#token)
      #
      #   require "gcloud/storage"
      #
      #   storage = Gcloud.storage
      #
      #   all_buckets = []
      #   tmp_buckets = storage.buckets
      #   while tmp_buckets.any? do
      #     tmp_buckets.each do |bucket|
      #       all_buckets << bucket
      #     end
      #     # break loop if no more buckets available
      #     break if tmp_buckets.token.nil?
      #     # get the next group of buckets
      #     tmp_buckets = storage.buckets token: tmp_buckets.token
      #   end
      #
      def buckets options = {}
        resp = connection.list_buckets options
        if resp.success?
          Bucket::List.from_resp resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Retrieves bucket by name.
      #
      # === Parameters
      #
      # +bucket_name+::
      #   Name of a bucket. (+String+)
      #
      # === Returns
      #
      # Gcloud::Datastore::Bucket or nil if bucket does not exist
      #
      # === Example
      #
      #   require "gcloud/storage"
      #
      #   storage = Gcloud.storage
      #
      #   bucket = storage.find_bucket "my-bucket"
      #   puts bucket.name
      #
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
      # === Parameters
      #
      # +bucket_name+::
      #   Name of a bucket. (+String+)
      # +options+::
      #   An optional Hash for controlling additional behavor. (+Hash+)
      # +options [:retries]+::
      #   The number of times the API call should be retried.
      #   Default is Gcloud::Backoff.retries. (+Integer+)
      #
      # === Returns
      #
      # Gcloud::Datastore::Bucket
      #
      # === Examples
      #
      #   require "gcloud/storage"
      #
      #   storage = Gcloud.storage
      #
      #   bucket = storage.create_bucket "my-bucket"
      #
      # The API call to create the bucket may be retried under certain
      # conditions. See Gcloud::Backoff to control this behavior, or
      # specify the wanted behavior in the call with the +:retries:+ option:
      #
      #   require "gcloud/storage"
      #
      #   storage = Gcloud.storage
      #
      #   bucket = storage.create_bucket "my-bucket", retries: 5
      #
      def create_bucket bucket_name, options = {}
        options[:acl] = Bucket::Acl.predefined_rule_for options[:acl]
        default_acl = options[:default_acl]
        default_acl = Bucket::DefaultAcl.predefined_rule_for default_acl
        options[:default_acl] = default_acl

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
