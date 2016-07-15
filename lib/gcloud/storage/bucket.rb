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


require "gcloud/storage/bucket/acl"
require "gcloud/storage/bucket/list"
require "gcloud/storage/bucket/cors"
require "gcloud/storage/file"
require "pathname"

module Gcloud
  module Storage
    ##
    # # Bucket
    #
    # Represents a Storage bucket. Belongs to a Project and has many Files.
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   storage = gcloud.storage
    #
    #   bucket = storage.bucket "my-bucket"
    #   file = bucket.file "path/to/my-file.ext"
    #
    class Bucket
      ##
      # @private The Service object.
      attr_accessor :service

      ##
      # @private The Google API Client object.
      attr_accessor :gapi

      ##
      # @private Create an empty Bucket object.
      def initialize
        @service = nil
        @gapi = Google::Apis::StorageV1::Bucket.new
      end

      ##
      # The kind of item this is.
      # For buckets, this is always `storage#bucket`.
      def kind
        @gapi.kind
      end

      ##
      # The ID of the bucket.
      def id
        @gapi.id
      end

      ##
      # The name of the bucket.
      def name
        @gapi.name
      end

      ##
      # A URL that can be used to access the bucket using the REST API.
      def api_url
        @gapi.self_link
      end

      ##
      # Creation time of the bucket.
      def created_at
        @gapi.time_created
      end

      ##
      # Returns the current CORS configuration for a static website served from
      # the bucket.
      #
      # The return value is a frozen (unmodifiable) array of hashes containing
      # the attributes specified for the Bucket resource field
      # [cors](https://cloud.google.com/storage/docs/json_api/v1/buckets#cors).
      #
      # This method also accepts a block for updating the bucket's CORS rules.
      # See {Bucket::Cors} for details.
      #
      # @see https://cloud.google.com/storage/docs/cross-origin Cross-Origin
      #   Resource Sharing (CORS)
      #
      # @yield [cors] a block for setting CORS rules
      # @yieldparam [Bucket::Cors] cors the object accepting CORS rules
      #
      # @example Retrieving the bucket's CORS rules.
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-todo-app"
      #   bucket.cors #=> [{"origin"=>["http://example.org"],
      #               #     "method"=>["GET","POST","DELETE"],
      #               #     "responseHeader"=>["X-My-Custom-Header"],
      #               #     "maxAgeSeconds"=>3600}]
      #
      # @example Updating the bucket's CORS rules inside a block.
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #   bucket = storage.bucket "my-todo-app"
      #
      #   bucket.update do |b|
      #     b.cors do |c|
      #       c.add_rule ["http://example.org", "https://example.org"],
      #                  "*",
      #                  response_headers: ["X-My-Custom-Header"],
      #                  max_age: 3600
      #     end
      #   end
      #
      def cors
        cors_builder = Bucket::Cors.from_gapi @gapi.cors_configurations
        if block_given?
          yield cors_builder
          if cors_builder.changed?
            @gapi.cors_configurations = cors_builder.to_gapi
            patch_gapi! :cors_configurations
          end
        end
        cors_builder.freeze # always return frozen objects
      end

      ##
      # The location of the bucket.
      # Object data for objects in the bucket resides in physical
      # storage within this region. Defaults to US.
      # See the developer's guide for the authoritative list.
      #
      # @see https://cloud.google.com/storage/docs/concepts-techniques
      def location
        @gapi.location
      end

      ##
      # The destination bucket name for the bucket's logs.
      #
      # @see https://cloud.google.com/storage/docs/access-logs Access Logs
      #
      def logging_bucket
        @gapi.logging.log_bucket if @gapi.logging
      end

      ##
      # Updates the destination bucket for the bucket's logs.
      #
      # @see https://cloud.google.com/storage/docs/access-logs Access Logs
      #
      # @param [String] logging_bucket The bucket to hold the logging output
      #
      def logging_bucket= logging_bucket
        @gapi.logging ||= Google::Apis::StorageV1::Bucket::Logging.new
        @gapi.logging.log_bucket = logging_bucket
        patch_gapi! :logging
      end

      ##
      # The logging object prefix for the bucket's logs. For more information,
      #
      # @see https://cloud.google.com/storage/docs/access-logs Access Logs
      #
      def logging_prefix
        @gapi.logging.log_object_prefix if @gapi.logging
      end

      ##
      # Updates the logging object prefix. This prefix will be used to create
      # log object names for the bucket. It can be at most 900 characters and
      # must be a [valid object
      # name](https://cloud.google.com/storage/docs/bucket-naming#objectnames).
      # By default, the object prefix is the name
      # of the bucket for which the logs are enabled.
      #
      # @see https://cloud.google.com/storage/docs/access-logs Access Logs
      #
      def logging_prefix= logging_prefix
        @gapi.logging ||= Google::Apis::StorageV1::Bucket::Logging.new
        @gapi.logging.log_object_prefix = logging_prefix
        patch_gapi! :logging
      end

      ##
      # The bucket's storage class. This defines how objects in the bucket are
      # stored and determines the SLA and the cost of storage. Values include
      # `STANDARD`, `NEARLINE`, and `DURABLE_REDUCED_AVAILABILITY`.
      def storage_class
        @gapi.storage_class
      end

      ##
      # Whether [Object
      # Versioning](https://cloud.google.com/storage/docs/object-versioning) is
      # enabled for the bucket.
      def versioning?
        @gapi.versioning.enabled? unless @gapi.versioning.nil?
      end

      ##
      # Updates whether [Object
      # Versioning](https://cloud.google.com/storage/docs/object-versioning) is
      # enabled for the bucket.
      #
      # @return [Boolean]
      #
      def versioning= new_versioning
        @gapi.versioning ||= Google::Apis::StorageV1::Bucket::Versioning.new
        @gapi.versioning.enabled = new_versioning
        patch_gapi! :versioning
      end

      ##
      # The index page returned from a static website served from the bucket
      # when a site visitor requests the top level directory.
      #
      # @see https://cloud.google.com/storage/docs/website-configuration#step4
      #   How to Host a Static Website
      #
      def website_main
        @gapi.website.main_page_suffix if @gapi.website
      end

      ##
      # Updates the index page returned from a static website served from the
      # bucket when a site visitor requests the top level directory.
      #
      # @see https://cloud.google.com/storage/docs/website-configuration#step4
      #   How to Host a Static Website
      #
      def website_main= website_main
        @gapi.website ||= Google::Apis::StorageV1::Bucket::Website.new
        @gapi.website.main_page_suffix = website_main
        patch_gapi! :website
      end

      ##
      # The page returned from a static website served from the bucket when a
      # site visitor requests a resource that does not exist.
      #
      # @see https://cloud.google.com/storage/docs/website-configuration#step4
      #   How to Host a Static Website
      #
      def website_404
        @gapi.website.not_found_page if @gapi.website
      end

      ##
      # Updates the page returned from a static website served from the bucket
      # when a site visitor requests a resource that does not exist.
      #
      # @see https://cloud.google.com/storage/docs/website-configuration#step4
      #   How to Host a Static Website
      #
      def website_404= website_404
        @gapi.website ||= Google::Apis::StorageV1::Bucket::Website.new
        @gapi.website.not_found_page = website_404
        patch_gapi! :website
      end

      ##
      # Updates the bucket with changes made in the given block in a single
      # PATCH request. The following attributes may be set: {#cors=},
      # {#logging_bucket=}, {#logging_prefix=}, {#versioning=},
      # {#website_main=}, and {#website_404=}. In addition, the #cors
      # configuration accessible in the block is completely mutable and will be
      # included in the request. (See {Bucket::Cors})
      #
      # @yield [bucket] a block yielding a delegate object for updating the file
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #   bucket.update do |b|
      #     b.website_main = "index.html"
      #     b.website_404 = "not_found.html"
      #     b.cors[0]["method"] = ["GET","POST","DELETE"]
      #     b.cors[1]["responseHeader"] << "X-Another-Custom-Header"
      #   end
      #
      # @example New CORS rules can also be added in a nested block:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #   bucket = storage.bucket "my-todo-app"
      #
      #   bucket.update do |b|
      #     b.cors do |c|
      #       c.add_rule ["http://example.org", "https://example.org"],
      #                  "*",
      #                  response_headers: ["X-My-Custom-Header"],
      #                  max_age: 300
      #     end
      #   end
      #
      def update
        updater = Updater.new @gapi
        yield updater
        # Add check for mutable cors
        updater.check_for_mutable_cors!
        patch_gapi! updater.updates unless updater.updates.empty?
      end

      ##
      # Permanently deletes the bucket.
      # The bucket must be empty before it can be deleted.
      #
      # The API call to delete the bucket may be retried under certain
      # conditions. See {Gcloud::Backoff} to control this behavior.
      #
      # @return [Boolean] Returns `true` if the bucket was deleted.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #   bucket.delete
      #
      def delete
        ensure_service!
        service.delete_bucket name
        true
      end

      ##
      # Retrieves a list of files matching the criteria.
      #
      # @param [String] prefix Filter results to files whose names begin with
      #   this prefix.
      # @param [String] delimiter Returns results in a directory-like mode.
      #   `items` will contain only objects whose names, aside from the
      #   `prefix`, do not contain `delimiter`. Objects whose names, aside from
      #   the `prefix`, contain `delimiter` will have their name, truncated
      #   after the `delimiter`, returned in `prefixes`. Duplicate `prefixes`
      #   are omitted.
      # @param [String] token A previously-returned page token representing part
      #   of the larger set of results to view.
      # @param [Integer] max Maximum number of items plus prefixes to return. As
      #   duplicate prefixes are omitted, fewer total results may be returned
      #   than requested. The default value of this parameter is 1,000 items.
      # @param [Boolean] versions If `true`, lists all versions of an object as
      #   distinct results. The default is `false`. For more information, see
      #   [Object Versioning
      #   ](https://cloud.google.com/storage/docs/object-versioning).
      #
      # @return [Array<Gcloud::Storage::File>] (See
      #   {Gcloud::Storage::File::List})
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #   files = bucket.files
      #   files.each do |file|
      #     puts file.name
      #   end
      #
      # @example Retrieve all files: (See {File::List#all})
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #   files = bucket.files
      #   files.all do |file|
      #     puts file.name
      #   end
      #
      def files prefix: nil, delimiter: nil, token: nil, max: nil, versions: nil
        ensure_service!
        options = {
          prefix:    prefix,
          delimiter: delimiter,
          token:     token,
          max:       max,
          versions:  versions
        }
        gapi = service.list_files name, options
        File::List.from_gapi gapi, service, name, prefix, delimiter, max,
                             versions
      end
      alias_method :find_files, :files

      ##
      # Retrieves a file matching the path.
      #
      # If a [customer-supplied encryption
      # key](https://cloud.google.com/storage/docs/encryption#customer-supplied)
      # was used with {#create_file}, the `encryption_key` and
      # `encryption_key_sha256` options must be provided or else the file's
      # CRC32C checksum and MD5 hash will not be returned.
      #
      # @param [String] path Name (path) of the file.
      # @param [Integer] generation When present, selects a specific revision of
      #   this object. Default is the latest version.
      # @param [String] encryption_key Optional. The customer-supplied, AES-256
      #   encryption key used to encrypt the file, if one was provided to
      #   {#create_file}. Must be provided if `encryption_key_sha256` is
      #   provided.
      # @param [String] encryption_key_sha256 Optional. The SHA256 hash of the
      #   customer-supplied, AES-256 encryption key used to encrypt the file, if
      #   one was provided to {#create_file}. Must be provided if
      #   `encryption_key` is provided.
      #
      # @return [Gcloud::Storage::File, nil] Returns nil if file does not exist
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #
      #   file = bucket.file "path/to/my-file.ext"
      #   puts file.name
      #
      def file path, generation: nil, encryption_key: nil,
               encryption_key_sha256: nil
        ensure_service!
        options = { generation: generation, key: encryption_key,
                    key_sha256: encryption_key_sha256 }
        gapi = service.get_file name, path, options
        File.from_gapi gapi, service
      rescue Gcloud::NotFoundError
        nil
      end
      alias_method :find_file, :file

      ##
      # Creates a new {File} object by providing a path to a local file to
      # upload and the path to store it with in the bucket.
      #
      # #### Customer-supplied encryption keys
      #
      # By default, Google Cloud Storage manages server-side encryption keys on
      # your behalf. However, a [customer-supplied encryption
      # key](https://cloud.google.com/storage/docs/encryption#customer-supplied)
      # can be provided with the `encryption_key` and `encryption_key_sha256`
      # options. If given, the same key and SHA256 hash also must be provided to
      # subsequently download or copy the file. If you use customer-supplied
      # encryption keys, you must securely manage your keys and ensure that they
      # are not lost. Also, please note that file metadata is not encrypted,
      # with the exception of the CRC32C checksum and MD5 hash. The names of
      # files and buckets are also not encrypted, and you can read or update the
      # metadata of an encrypted file without providing the encryption key.
      #
      # @param [String] file Path of the file on the filesystem to upload.
      # @param [String] path Path to store the file in Google Cloud Storage.
      # @param [String] acl A predefined set of access controls to apply to this
      #   file.
      #
      #   Acceptable values are:
      #
      #   * `auth`, `auth_read`, `authenticated`, `authenticated_read`,
      #     `authenticatedRead` - File owner gets OWNER access, and
      #     allAuthenticatedUsers get READER access.
      #   * `owner_full`, `bucketOwnerFullControl` - File owner gets OWNER
      #     access, and project team owners get OWNER access.
      #   * `owner_read`, `bucketOwnerRead` - File owner gets OWNER access, and
      #     project team owners get READER access.
      #   * `private` - File owner gets OWNER access.
      #   * `project_private`, `projectPrivate` - File owner gets OWNER access,
      #     and project team members get access according to their roles.
      #   * `public`, `public_read`, `publicRead` - File owner gets OWNER
      #     access, and allUsers get READER access.
      # @param [String] cache_control The
      #   [Cache-Control](https://tools.ietf.org/html/rfc7234#section-5.2)
      #   response header to be returned when the file is downloaded.
      # @param [String] content_disposition The
      #   [Content-Disposition](https://tools.ietf.org/html/rfc6266)
      #   response header to be returned when the file is downloaded.
      # @param [String] content_encoding The [Content-Encoding
      #   ](https://tools.ietf.org/html/rfc7231#section-3.1.2.2) response header
      #   to be returned when the file is downloaded.
      # @param [String] content_language The
      #   [Content-Language](http://tools.ietf.org/html/bcp47) response
      #   header to be returned when the file is downloaded.
      # @param [String] content_type The
      #   [Content-Type](https://tools.ietf.org/html/rfc2616#section-14.17)
      #   response header to be returned when the file is downloaded.
      # @param [String] crc32c The CRC32c checksum of the file data, as
      #   described in [RFC 4960, Appendix
      #   B](http://tools.ietf.org/html/rfc4960#appendix-B).
      #   If provided, Cloud Storage will only create the file if the value
      #   matches the value calculated by the service. See
      #   [Validation](https://cloud.google.com/storage/docs/hashes-etags)
      #   for more information.
      # @param [String] md5 The MD5 hash of the file data. If provided, Cloud
      #   Storage will only create the file if the value matches the value
      #   calculated by the service. See
      #   [Validation](https://cloud.google.com/storage/docs/hashes-etags) for
      #   more information.
      # @param [Hash] metadata A hash of custom, user-provided web-safe keys and
      #   arbitrary string values that will returned with requests for the file
      #   as "x-goog-meta-" response headers.
      # @param [String] encryption_key Optional. A customer-supplied, AES-256
      #   encryption key that will be used to encrypt the file. Must be provided
      #   if `encryption_key_sha256` is provided.
      # @param [String] encryption_key_sha256 Optional. The SHA256 hash of the
      #   customer-supplied, AES-256 encryption key that will be used to encrypt
      #   the file. Must be provided if `encryption_key` is provided.
      #
      # @return [Gcloud::Storage::File]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #
      #   bucket.create_file "path/to/local.file.ext"
      #
      # @example Specifying a destination path:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #
      #   bucket.create_file "path/to/local.file.ext",
      #                      "destination/path/file.ext"
      #
      # @example Providing a customer-supplied encryption key:
      #   require "gcloud"
      #   require "digest/sha2"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #   bucket = storage.bucket "my-bucket"
      #
      #   # Key generation shown for example purposes only. Write your own.
      #   cipher = OpenSSL::Cipher.new "aes-256-cfb"
      #   cipher.encrypt
      #   key = cipher.random_key
      #   key_hash = Digest::SHA256.digest key
      #
      #   bucket.create_file "path/to/local.file.ext",
      #                      "destination/path/file.ext",
      #                      encryption_key: key,
      #                      encryption_key_sha256: key_hash
      #
      #   # Store your key and hash securely for later use.
      #   file = bucket.file "destination/path/file.ext",
      #                      encryption_key: key,
      #                      encryption_key_sha256: key_hash
      #
      # @example Avoiding broken pipe errors with large uploads:
      #   require "gcloud"
      #
      #   # Use httpclient to avoid broken pipe errors with large uploads
      #   Faraday.default_adapter = :httpclient
      #
      #   # Only add the following statement if using Faraday >= 0.9.2
      #   # Override gzip middleware with no-op for httpclient
      #   Faraday::Response.register_middleware :gzip =>
      #                                           Faraday::Response::Middleware
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      def create_file file, path = nil, acl: nil, cache_control: nil,
                      content_disposition: nil, content_encoding: nil,
                      content_language: nil, content_type: nil,
                      crc32c: nil, md5: nil, metadata: nil, encryption_key: nil,
                      encryption_key_sha256: nil
        ensure_service!
        options = { acl: File::Acl.predefined_rule_for(acl), md5: md5,
                    cache_control: cache_control, content_type: content_type,
                    content_disposition: content_disposition, crc32c: crc32c,
                    content_encoding: content_encoding,
                    content_language: content_language, metadata: metadata,
                    key: encryption_key, key_sha256: encryption_key_sha256 }
        ensure_file_exists! file
        # TODO: Handle file as an IO and path is missing more gracefully
        path ||= Pathname(file).to_path
        gapi = service.insert_file name, file, path, options
        File.from_gapi gapi, service
      end
      alias_method :upload_file, :create_file
      alias_method :new_file, :create_file

      ##
      # The Bucket::Acl instance used to control access to the bucket.
      #
      # A bucket has owners, writers, and readers. Permissions can be granted to
      # an individual user's email address, a group's email address, as well as
      # many predefined lists.
      #
      # @see https://cloud.google.com/storage/docs/access-control Access Control
      #   guide
      #
      # @example Grant access to a user by pre-pending `"user-"` to an email:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-todo-app"
      #
      #   email = "heidi@example.net"
      #   bucket.acl.add_reader "user-#{email}"
      #
      # @example Grant access to a group by pre-pending `"group-"` to an email:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-todo-app"
      #
      #   email = "authors@example.net"
      #   bucket.acl.add_reader "group-#{email}"
      #
      # @example Or, grant access via a predefined permissions list:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-todo-app"
      #
      #   bucket.acl.public!
      #
      def acl
        @acl ||= Bucket::Acl.new self
      end

      ##
      # The Bucket::DefaultAcl instance used to control access to the bucket's
      # files.
      #
      # A bucket's files have owners, writers, and readers. Permissions can be
      # granted to an individual user's email address, a group's email address,
      # as well as many predefined lists.
      #
      # @see https://cloud.google.com/storage/docs/access-control Access Control
      #   guide
      #
      # @example Grant access to a user by pre-pending `"user-"` to an email:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-todo-app"
      #
      #   email = "heidi@example.net"
      #   bucket.default_acl.add_reader "user-#{email}"
      #
      # @example Grant access to a group by pre-pending `"group-"` to an email
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-todo-app"
      #
      #   email = "authors@example.net"
      #   bucket.default_acl.add_reader "group-#{email}"
      #
      # @example Or, grant access via a predefined permissions list:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-todo-app"
      #
      #   bucket.default_acl.public!
      #
      def default_acl
        @default_acl ||= Bucket::DefaultAcl.new self
      end

      ##
      # Reloads the bucket with current data from the Storage service.
      def reload!
        ensure_service!
        @gapi = service.get_bucket name
      end
      alias_method :refresh!, :reload!

      ##
      # @private New Bucket from a Google API Client object.
      def self.from_gapi gapi, conn
        new.tap do |f|
          f.gapi = gapi
          f.service = conn
        end
      end

      protected

      ##
      # Raise an error unless an active service is available.
      def ensure_service!
        fail "Must have active connection" unless service
      end

      def patch_gapi! *attributes
        attributes.flatten!
        return if attributes.empty?
        ensure_service!
        patch_args = Hash[attributes.map do |attr|
          [attr, @gapi.send(attr)]
        end]
        patch_gapi = Google::Apis::StorageV1::Bucket.new patch_args
        @gapi = service.patch_bucket name, patch_gapi
      end

      ##
      # Raise an error if the file is not found.
      def ensure_file_exists! file
        return if ::File.file? file
        fail ArgumentError, "cannot find file #{file}"
      end

      ##
      # @private Determines if a resumable upload should be used.
      def resumable_upload? file
        ::File.size?(file).to_i > Upload.resumable_threshold
      end

      ##
      # Yielded to a block to accumulate changes for a patch request.
      class Updater < Bucket
        attr_reader :updates
        ##
        # Create an Updater object.
        def initialize gapi
          @updates = []
          @gapi = gapi
          @cors_builder = nil
        end

        def cors
          # Same as Bucket#cors, but not frozen
          @cors_builder ||= Bucket::Cors.from_gapi @gapi.cors_configurations
          yield @cors_builder if block_given?
          @cors_builder
        end

        ##
        # Make sure any cors changes are saved
        def check_for_mutable_cors!
          return if @cors_builder.nil?
          return unless @cors_builder.changed?
          @gapi.cors_configurations = @cors_builder.to_gapi
          patch_gapi! :cors_configurations
        end

        protected

        ##
        # Queue up all the updates instead of making them.
        def patch_gapi! attribute
          @updates << attribute
          @updates.uniq!
        end
      end
    end
  end
end
