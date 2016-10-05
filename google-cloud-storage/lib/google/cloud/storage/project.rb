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


require "google/cloud/core/gce"
require "google/cloud/storage/errors"
require "google/cloud/storage/service"
require "google/cloud/storage/credentials"
require "google/cloud/storage/bucket"
require "google/cloud/storage/bucket/cors"
require "google/cloud/storage/file"

module Google
  module Cloud
    module Storage
      ##
      # # Project
      #
      # Represents the project that storage buckets and files belong to.
      # All data in Google Cloud Storage belongs inside a project.
      # A project consists of a set of users, a set of APIs, billing,
      # authentication, and monitoring settings for those APIs.
      #
      # Google::Cloud::Storage::Project is the main object for interacting with
      # Google Storage. {Google::Cloud::Storage::Bucket} objects are created,
      # read, updated, and deleted by Google::Cloud::Storage::Project.
      #
      # See {Google::Cloud#storage}
      #
      # @example
      #   require "google/cloud/storage"
      #
      #   storage = Google::Cloud::Storage.new
      #
      #   bucket = storage.bucket "my-bucket"
      #   file = bucket.file "path/to/my-file.ext"
      #
      class Project
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private Creates a new Project instance.
        #
        # See {Google::Cloud#storage}
        def initialize service
          @service = service
        end

        ##
        # The Storage project connected to.
        #
        # @example
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new(
        #     project: "my-todo-project",
        #     keyfile: "/path/to/keyfile.json"
        #   )
        #
        #   storage.project #=> "my-todo-project"
        #
        def project
          service.project
        end

        ##
        # @private Default project.
        def self.default_project
          ENV["STORAGE_PROJECT"] ||
            ENV["GOOGLE_CLOUD_PROJECT"] ||
            ENV["GCLOUD_PROJECT"] ||
            Google::Cloud::Core::GCE.project_id
        end

        ##
        # Retrieves a list of buckets for the given project.
        #
        # @param [String] prefix Filter results to buckets whose names begin
        #   with this prefix.
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of buckets to return.
        #
        # @return [Array<Google::Cloud::Storage::Bucket>] (See
        #   {Google::Cloud::Storage::Bucket::List})
        #
        # @example
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   buckets = storage.buckets
        #   buckets.each do |bucket|
        #     puts bucket.name
        #   end
        #
        # @example Retrieve buckets with names that begin with a given prefix:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   user_buckets = storage.buckets prefix: "user-"
        #   user_buckets.each do |bucket|
        #     puts bucket.name
        #   end
        #
        # @example Retrieve all buckets: (See {Bucket::List#all})
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   buckets = storage.buckets
        #   buckets.all do |bucket|
        #     puts bucket.name
        #   end
        #
        def buckets prefix: nil, token: nil, max: nil
          options = { prefix: prefix, token: token, max: max }
          gapi = service.list_buckets options
          Bucket::List.from_gapi gapi, service, prefix, max
        end
        alias_method :find_buckets, :buckets

        ##
        # Retrieves bucket by name.
        #
        # @param [String] bucket_name Name of a bucket.
        #
        # @return [Google::Cloud::Storage::Bucket, nil] Returns nil if bucket
        #   does not exist
        #
        # @example
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-bucket"
        #   puts bucket.name
        #
        def bucket bucket_name
          gapi = service.get_bucket bucket_name
          Bucket.from_gapi gapi, service
        rescue Google::Cloud::NotFoundError
          nil
        end
        alias_method :find_bucket, :bucket

        ##
        # Creates a new bucket with optional attributes. Also accepts a block
        # for defining the CORS configuration for a static website served from
        # the bucket. See {Bucket::Cors} for details.
        #
        # The API call to create the bucket may be retried under certain
        # conditions. See {Google::Cloud#storage} to control this behavior.
        #
        # You can pass [website
        # settings](https://cloud.google.com/storage/docs/website-configuration)
        # for the bucket, including a block that defines CORS rule. See
        # {Bucket::Cors} for details.
        #
        # @see https://cloud.google.com/storage/docs/cross-origin Cross-Origin
        #   Resource Sharing (CORS)
        # @see https://cloud.google.com/storage/docs/website-configuration How
        #   to Host a Static Website
        #
        # @param [String] bucket_name Name of a bucket.
        # @param [String] acl Apply a predefined set of access controls to this
        #   bucket.
        #
        #   Acceptable values are:
        #
        #   * `auth`, `auth_read`, `authenticated`, `authenticated_read`,
        #     `authenticatedRead` - Project team owners get OWNER access, and
        #     allAuthenticatedUsers get READER access.
        #   * `private` - Project team owners get OWNER access.
        #   * `project_private`, `projectPrivate` - Project team members get
        #     access according to their roles.
        #   * `public`, `public_read`, `publicRead` - Project team owners get
        #     OWNER access, and allUsers get READER access.
        #   * `public_write`, `publicReadWrite` - Project team owners get OWNER
        #     access, and allUsers get WRITER access.
        # @param [String] default_acl Apply a predefined set of default object
        #   access controls to this bucket.
        #
        #   Acceptable values are:
        #
        #   * `auth`, `auth_read`, `authenticated`, `authenticated_read`,
        #     `authenticatedRead` - File owner gets OWNER access, and
        #     allAuthenticatedUsers get READER access.
        #   * `owner_full`, `bucketOwnerFullControl` - File owner gets OWNER
        #     access, and project team owners get OWNER access.
        #   * `owner_read`, `bucketOwnerRead` - File owner gets OWNER access,
        #     and project team owners get READER access.
        #   * `private` - File owner gets OWNER access.
        #   * `project_private`, `projectPrivate` - File owner gets OWNER
        #     access, and project team members get access according to their
        #     roles.
        #   * `public`, `public_read`, `publicRead` - File owner gets OWNER
        #     access, and allUsers get READER access.
        # @param [String] location The location of the bucket. Object data for
        #   objects in the bucket resides in physical storage within this
        #   region. Possible values include `ASIA`, `EU`, and `US`. (See the
        #   [developer's
        #   guide](https://cloud.google.com/storage/docs/bucket-locations) for
        #   the authoritative list. The default value is `US`.
        # @param [String] logging_bucket The destination bucket for the bucket's
        #   logs. For more information, see [Access
        #   Logs](https://cloud.google.com/storage/docs/access-logs).
        # @param [String] logging_prefix The prefix used to create log object
        #   names for the bucket. It can be at most 900 characters and must be a
        #   [valid object
        #   name](https://cloud.google.com/storage/docs/bucket-naming#objectnames)
        #   . By default, the object prefix is the name of the bucket for which
        #   the logs are enabled. For more information, see [Access
        #   Logs](https://cloud.google.com/storage/docs/access-logs).
        # @param [Symbol, String] storage_class Defines how objects in the
        #   bucket are stored and determines the SLA and the cost of storage.
        #   Values include `:standard`, `:nearline`, and `:dra` (Durable Reduced
        #   Availability), as well as the strings returned by
        #   Bucket#storage_class. For more information, see [Storage
        #   Classes](https://cloud.google.com/storage/docs/storage-classes). The
        #   default value is `:standard`.
        # @param [Boolean] versioning Whether [Object
        #   Versioning](https://cloud.google.com/storage/docs/object-versioning)
        #   is to be enabled for the bucket. The default value is `false`.
        # @param [String] website_main The index page returned from a static
        #   website served from the bucket when a site visitor requests the top
        #   level directory. For more information, see [How to Host a Static
        #   Website
        #   ](https://cloud.google.com/storage/docs/website-configuration#step4).
        # @param [String] website_404 The page returned from a static website
        #   served from the bucket when a site visitor requests a resource that
        #   does not exist. For more information, see [How to Host a Static
        #   Website
        #   ](https://cloud.google.com/storage/docs/website-configuration#step4).
        # @yield [bucket] a block for configuring the bucket before it is
        #   created
        # @yieldparam [Bucket] cors the bucket object to be configured
        #
        # @return [Google::Cloud::Storage::Bucket]
        #
        # @example
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.create_bucket "my-bucket"
        #
        # @example Configure the bucket in a block:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.create_bucket "my-bucket" do |b|
        #     b.website_main = "index.html"
        #     b.website_404 = "not_found.html"
        #     b.cors.add_rule ["http://example.org", "https://example.org"],
        #                      "*",
        #                      response_headers: ["X-My-Custom-Header"],
        #                      max_age: 300
        #   end
        #
        def create_bucket bucket_name, acl: nil, default_acl: nil,
                          location: nil, storage_class: nil,
                          logging_bucket: nil, logging_prefix: nil,
                          website_main: nil, website_404: nil, versioning: nil
          new_bucket = Google::Apis::StorageV1::Bucket.new({
            name: bucket_name,
            location: location,
            storage_class: storage_class_for(storage_class)
          }.delete_if { |_, v| v.nil? })
          updater = Bucket::Updater.new(new_bucket).tap do |b|
            b.logging_bucket = logging_bucket unless logging_bucket.nil?
            b.logging_prefix = logging_prefix unless logging_prefix.nil?
            b.website_main = website_main unless website_main.nil?
            b.website_404 = website_404 unless website_404.nil?
            b.versioning = versioning unless versioning.nil?
          end
          yield updater if block_given?
          updater.check_for_mutable_cors!
          gapi = service.insert_bucket \
            new_bucket, acl: acl_rule(acl), default_acl: acl_rule(default_acl)
          Bucket.from_gapi gapi, service
        end

        protected

        def acl_rule option_name
          Bucket::Acl.predefined_rule_for option_name
        end

        def storage_class_for str
          { "durable_reduced_availability" => "DURABLE_REDUCED_AVAILABILITY",
            "dra" => "DURABLE_REDUCED_AVAILABILITY",
            "durable" => "DURABLE_REDUCED_AVAILABILITY",
            "nearline" => "NEARLINE",
            "standard" => "STANDARD" }[str.to_s.downcase]
        end
      end
    end
  end
end
