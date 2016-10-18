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


require "google/cloud/storage/bucket/acl"
require "google/cloud/storage/bucket/list"
require "google/cloud/storage/bucket/cors"
require "google/cloud/storage/post_object"
require "google/cloud/storage/file"
require "pathname"

module Google
  module Cloud
    module Storage
      ##
      # # Bucket
      #
      # Represents a Storage bucket. Belongs to a Project and has many Files.
      #
      # @example
      #   require "google/cloud/storage"
      #
      #   storage = Google::Cloud::Storage.new
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
        # Returns the current CORS configuration for a static website served
        # from the bucket.
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
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-todo-app"
        #   bucket.cors.size #=> 2
        #   rule = bucket.cors.first
        #   rule.origin #=> ["http://example.org"]
        #   rule.methods #=> ["GET","POST","DELETE"]
        #   rule.headers #=> ["X-My-Custom-Header"]
        #   rule.max_age #=> 3600
        #
        # @example Updating the bucket's CORS rules inside a block.
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #   bucket = storage.bucket "my-todo-app"
        #
        #   bucket.update do |b|
        #     b.cors do |c|
        #       c.add_rule ["http://example.org", "https://example.org"],
        #                  "*",
        #                  headers: ["X-My-Custom-Header"],
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
        # By default, the object prefix is the name of the bucket for which the
        # logs are enabled.
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
        # `MULTI_REGIONAL`, `REGIONAL`, `NEARLINE`, `COLDLINE`, `STANDARD`,
        # and `DURABLE_REDUCED_AVAILABILITY`.
        def storage_class
          @gapi.storage_class
        end

        ##
        # Whether [Object
        # Versioning](https://cloud.google.com/storage/docs/object-versioning)
        # is enabled for the bucket.
        def versioning?
          @gapi.versioning.enabled? unless @gapi.versioning.nil?
        end

        ##
        # Updates whether [Object
        # Versioning](https://cloud.google.com/storage/docs/object-versioning)
        # is enabled for the bucket.
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
        # PATCH request. The following attributes may be set: {#cors},
        # {#logging_bucket=}, {#logging_prefix=}, {#versioning=},
        # {#website_main=}, and {#website_404=}. In addition, the #cors
        # configuration accessible in the block is completely mutable and will
        # be included in the request. (See {Bucket::Cors})
        #
        # @yield [bucket] a block yielding a delegate object for updating the
        #   file
        #
        # @example
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-todo-app"
        #   bucket.update do |b|
        #     b.website_main = "index.html"
        #     b.website_404 = "not_found.html"
        #     b.cors[0].methods = ["GET","POST","DELETE"]
        #     b.cors[1].headers << "X-Another-Custom-Header"
        #   end
        #
        # @example New CORS rules can also be added in a nested block:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #   bucket = storage.bucket "my-todo-app"
        #
        #   bucket.update do |b|
        #     b.cors do |c|
        #       c.add_rule ["http://example.org", "https://example.org"],
        #                  "*",
        #                  headers: ["X-My-Custom-Header"],
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
        # conditions. See {Google::Cloud#storage} to control this behavior.
        #
        # @return [Boolean] Returns `true` if the bucket was deleted.
        #
        # @example
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
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
        #   `prefix`, do not contain `delimiter`. Objects whose names, aside
        #   from the `prefix`, contain `delimiter` will have their name,
        #   truncated after the `delimiter`, returned in `prefixes`. Duplicate
        #   `prefixes` are omitted.
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of items plus prefixes to return.
        #   As duplicate prefixes are omitted, fewer total results may be
        #   returned than requested. The default value of this parameter is
        #   1,000 items.
        # @param [Boolean] versions If `true`, lists all versions of an object
        #   as distinct results. The default is `false`. For more information,
        #   see [Object Versioning
        #   ](https://cloud.google.com/storage/docs/object-versioning).
        #
        # @return [Array<Google::Cloud::Storage::File>] (See
        #   {Google::Cloud::Storage::File::List})
        #
        # @example
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-bucket"
        #   files = bucket.files
        #   files.each do |file|
        #     puts file.name
        #   end
        #
        # @example Retrieve all files: (See {File::List#all})
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-bucket"
        #   files = bucket.files
        #   files.all do |file|
        #     puts file.name
        #   end
        #
        def files prefix: nil, delimiter: nil, token: nil, max: nil,
                  versions: nil
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
        # was used with {#create_file}, the `encryption_key` option must be
        # provided or else the file's CRC32C checksum and MD5 hash will not be
        # returned.
        #
        # @param [String] path Name (path) of the file.
        # @param [Integer] generation When present, selects a specific revision
        #   of this object. Default is the latest version.
        # @param [String] encryption_key Optional. The customer-supplied,
        #   AES-256 encryption key used to encrypt the file, if one was provided
        #   to {#create_file}.
        #
        # @return [Google::Cloud::Storage::File, nil] Returns nil if file does
        #   not exist
        #
        # @example
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   file = bucket.file "path/to/my-file.ext"
        #   puts file.name
        #
        def file path, generation: nil, encryption_key: nil
          ensure_service!
          options = { generation: generation, key: encryption_key }
          gapi = service.get_file name, path, options
          File.from_gapi gapi, service
        rescue Google::Cloud::NotFoundError
          nil
        end
        alias_method :find_file, :file

        ##
        # Creates a new {File} object by providing a path to a local file to
        # upload and the path to store it with in the bucket.
        #
        # #### Customer-supplied encryption keys
        #
        # By default, Google Cloud Storage manages server-side encryption keys
        # on your behalf. However, a [customer-supplied encryption key](https://cloud.google.com/storage/docs/encryption#customer-supplied)
        # can be provided with the `encryption_key` option. If given, the same
        # key must be provided to subsequently download or copy the file. If you
        # use customer-supplied encryption keys, you must securely manage your
        # keys and ensure that they are not lost. Also, please note that file
        # metadata is not encrypted, with the exception of the CRC32C checksum
        # and MD5 hash. The names of files and buckets are also not encrypted,
        # and you can read or update the metadata of an encrypted file without
        # providing the encryption key.
        #
        # @param [String] file Path of the file on the filesystem to upload.
        # @param [String] path Path to store the file in Google Cloud Storage.
        # @param [String] acl A predefined set of access controls to apply to
        #   this file.
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
        # @param [String] cache_control The
        #   [Cache-Control](https://tools.ietf.org/html/rfc7234#section-5.2)
        #   response header to be returned when the file is downloaded.
        # @param [String] content_disposition The
        #   [Content-Disposition](https://tools.ietf.org/html/rfc6266)
        #   response header to be returned when the file is downloaded.
        # @param [String] content_encoding The [Content-Encoding
        #   ](https://tools.ietf.org/html/rfc7231#section-3.1.2.2) response
        #   header to be returned when the file is downloaded.
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
        # @param [Hash] metadata A hash of custom, user-provided web-safe keys
        #   and arbitrary string values that will returned with requests for the
        #   file as "x-goog-meta-" response headers.
        # @param [Symbol, String] storage_class Storage class of the file.
        #   Determines how the file is stored and determines the SLA and the
        #   cost of storage. Values include `:multi_regional`, `:regional`,
        #   `:nearline`, `:coldline`, `:standard`, and `:dra` (Durable Reduced
        #   Availability), as well as the strings returned by
        #   {Bucket#storage_class}. For more information, see [Storage
        #   Classes](https://cloud.google.com/storage/docs/storage-classes) and
        #   [Per-Object Storage
        #   Class](https://cloud.google.com/storage/docs/per-object-storage-class).
        #   The default value is the default storage class for the bucket.
        # @param [String] encryption_key Optional. A customer-supplied, AES-256
        #   encryption key that will be used to encrypt the file.
        #
        # @return [Google::Cloud::Storage::File]
        #
        # @example
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   bucket.create_file "path/to/local.file.ext"
        #
        # @example Specifying a destination path:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   bucket.create_file "path/to/local.file.ext",
        #                      "destination/path/file.ext"
        #
        # @example Providing a customer-supplied encryption key:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #   bucket = storage.bucket "my-bucket"
        #
        #   # Key generation shown for example purposes only. Write your own.
        #   cipher = OpenSSL::Cipher.new "aes-256-cfb"
        #   cipher.encrypt
        #   key = cipher.random_key
        #
        #   bucket.create_file "path/to/local.file.ext",
        #                      "destination/path/file.ext",
        #                      encryption_key: key
        #
        #   # Store your key and hash securely for later use.
        #   file = bucket.file "destination/path/file.ext",
        #                      encryption_key: key
        #
        def create_file file, path = nil, acl: nil, cache_control: nil,
                        content_disposition: nil, content_encoding: nil,
                        content_language: nil, content_type: nil,
                        crc32c: nil, md5: nil, metadata: nil,
                        storage_class: nil, encryption_key: nil
          ensure_service!
          options = { acl: File::Acl.predefined_rule_for(acl), md5: md5,
                      cache_control: cache_control, content_type: content_type,
                      content_disposition: content_disposition, crc32c: crc32c,
                      content_encoding: content_encoding, metadata: metadata,
                      content_language: content_language, key: encryption_key,
                      storage_class: storage_class_for(storage_class) }
          ensure_io_or_file_exists! file
          path ||= file.path if file.respond_to? :path
          path ||= file if file.is_a? String
          fail ArgumentError, "must provide path" if path.nil?

          gapi = service.insert_file name, file, path, options
          File.from_gapi gapi, service
        end
        alias_method :upload_file, :create_file
        alias_method :new_file, :create_file

        ##
        # Access without authentication can be granted to a File for a specified
        # period of time. This URL uses a cryptographic signature of your
        # credentials to access the file identified by `path`. A URL can be
        # created for paths that do not yet exist. For instance, a URL can be
        # created to `PUT` file contents to.
        #
        # Generating a URL requires service account credentials, either by
        # connecting with a service account when calling
        # {Google::Cloud.storage}, or by passing in the service account `issuer`
        # and `signing_key` values. Although the private key can be passed as a
        # string for convenience, creating and storing an instance of
        # `OpenSSL::PKey::RSA` is more efficient when making multiple calls to
        # `signed_url`.
        #
        # A {SignedUrlUnavailable} is raised if the service account credentials
        # are missing. Service account credentials are acquired by following the
        # steps in [Service Account Authentication](
        # https://cloud.google.com/storage/docs/authentication#service_accounts).
        #
        # @see https://cloud.google.com/storage/docs/access-control#Signed-URLs
        #   Access Control Signed URLs guide
        #
        # @param [String] path Path to of the file in Google Cloud Storage.
        # @param [String] method The HTTP verb to be used with the signed URL.
        #   Signed URLs can be used
        #   with `GET`, `HEAD`, `PUT`, and `DELETE` requests. Default is `GET`.
        # @param [Integer] expires The number of seconds until the URL expires.
        #   Default is 300/5 minutes.
        # @param [String] content_type When provided, the client (browser) must
        #   send this value in the HTTP header. e.g. `text/plain`
        # @param [String] content_md5 The MD5 digest value in base64. If you
        #   provide this in the string, the client (usually a browser) must
        #   provide this HTTP header with this same value in its request.
        # @param [Hash] headers Google extension headers (custom HTTP headers
        #   that begin with `x-goog-`) that must be included in requests that
        #   use the signed URL.
        # @param [String] issuer Service Account's Client Email.
        # @param [String] client_email Service Account's Client Email.
        # @param [OpenSSL::PKey::RSA, String] signing_key Service Account's
        #   Private Key.
        # @param [OpenSSL::PKey::RSA, String] private_key Service Account's
        #   Private Key.
        #
        # @example
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-todo-app"
        #   shared_url = bucket.signed_url "avatars/heidi/400x400.png"
        #
        # @example Any of the option parameters may be specified:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-todo-app"
        #   shared_url = bucket.signed_url "avatars/heidi/400x400.png",
        #                                  method: "PUT",
        #                                  expires: 300 # 5 minutes from now
        #
        # @example Using the issuer and signing_key options:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud.storage
        #
        #   bucket = storage.bucket "my-todo-app"
        #   key = OpenSSL::PKey::RSA.new "-----BEGIN PRIVATE KEY-----\n..."
        #   shared_url = bucket.signed_url "avatars/heidi/400x400.png",
        #                                  issuer: "service-account@gcloud.com",
        #                                  signing_key: key
        #
        # @example Using the headers option:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud.storage
        #
        #   bucket = storage.bucket "my-todo-app"
        #   shared_url = bucket.signed_url "avatars/heidi/400x400.png",
        #                                  headers: {
        #                                    "x-goog-acl" => "private",
        #                                    "x-goog-meta-foo" => "bar,baz"
        #                                  }
        #
        def signed_url path, method: nil, expires: nil, content_type: nil,
                       content_md5: nil, headers: nil, issuer: nil,
                       client_email: nil, signing_key: nil, private_key: nil
          ensure_service!
          options = { method: method, expires: expires, headers: headers,
                      content_type: content_type, content_md5: content_md5,
                      issuer: issuer, client_email: client_email,
                      signing_key: signing_key, private_key: private_key }
          signer = File::Signer.from_bucket self, path
          signer.signed_url options
        end

        ##
        # Generate a PostObject that includes the fields and url to
        # upload objects via html forms.
        #
        # Generating a PostObject requires service account credentials,
        # either by connecting with a service account when calling
        # {Google::Cloud.storage}, or by passing in the service account
        # `issuer` and `signing_key` values. Although the private key can
        # be passed as a string for convenience, creating and storing
        # an instance of # `OpenSSL::PKey::RSA` is more efficient
        # when making multiple calls to `post_object`.
        #
        # A {SignedUrlUnavailable} is raised if the service account credentials
        # are missing. Service account credentials are acquired by following the
        # steps in [Service Account Authentication](
        # https://cloud.google.com/storage/docs/authentication#service_accounts).
        #
        # @see https://cloud.google.com/storage/docs/xml-api/post-object
        #
        # @param [String] path Path to of the file in Google Cloud Storage.
        # @param [Hash] policy The security policy that describes what
        #   can and cannot be uploaded in the form. When provided,
        #   the PostObject fields will include a Signature based on the JSON
        #   representation of this Hash and the same policy in Base64 format.
        #   If you do not provide a security policy, requests are considered
        #   to be anonymous and will only work with buckets that have granted
        #   WRITE or FULL_CONTROL permission to anonymous users.
        #   See [Policy Document](https://cloud.google.com/storage/docs/xml-api/post-object#policydocument)
        #   for more information.
        # @param [String] issuer Service Account's Client Email.
        # @param [String] client_email Service Account's Client Email.
        # @param [OpenSSL::PKey::RSA, String] signing_key Service Account's
        #   Private Key.
        # @param [OpenSSL::PKey::RSA, String] private_key Service Account's
        #   Private Key.
        #
        # @return [PostObject]
        #
        # @example
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-todo-app"
        #   post = bucket.post_object "avatars/heidi/400x400.png"
        #
        #   post.url #=> "https://storage.googleapis.com"
        #   post.fields[:key] #=> "my-todo-app/avatars/heidi/400x400.png"
        #   post.fields[:GoogleAccessId] #=> "0123456789@gserviceaccount.com"
        #   post.fields[:signature] #=> "ABC...XYZ="
        #   post.fields[:policy] #=> "ABC...XYZ="
        #
        # @example Using a policy to define the upload authorization:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   policy = {
        #     expiration: (Time.now + 3600).iso8601,
        #     conditions: [
        #       ["starts-with", "$key", ""],
        #       {acl: "bucket-owner-read"},
        #       {bucket: "travel-maps"},
        #       {success_action_redirect: "http://example.com/success.html"},
        #       ["eq", "$Content-Type", "image/jpeg"],
        #       ["content-length-range", 0, 1000000]
        #     ]
        #   }
        #
        #   bucket = storage.bucket "my-todo-app"
        #   post = bucket.post_object "avatars/heidi/400x400.png",
        #                              policy: policy
        #
        #   post.url #=> "https://storage.googleapis.com"
        #   post.fields[:key] #=> "my-todo-app/avatars/heidi/400x400.png"
        #   post.fields[:GoogleAccessId] #=> "0123456789@gserviceaccount.com"
        #   post.fields[:signature] #=> "ABC...XYZ="
        #   post.fields[:policy] #=> "ABC...XYZ="
        #
        # @example Using the issuer and signing_key options:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-todo-app"
        #   key = OpenSSL::PKey::RSA.new
        #   post = bucket.post_object "avatars/heidi/400x400.png",
        #                             issuer: "service-account@gcloud.com",
        #                             signing_key: key
        #
        #   post.url #=> "https://storage.googleapis.com"
        #   post.fields[:key] #=> "my-todo-app/avatars/heidi/400x400.png"
        #   post.fields[:GoogleAccessId] #=> "0123456789@gserviceaccount.com"
        #   post.fields[:signature] #=> "ABC...XYZ="
        #   post.fields[:policy] #=> "ABC...XYZ="
        #
        def post_object path, policy: nil, issuer: nil,
                        client_email: nil, signing_key: nil,
                        private_key: nil
          ensure_service!
          options = { issuer: issuer, client_email: client_email,
                      signing_key: signing_key, private_key: private_key,
                      policy: policy }

          signer = File::Signer.from_bucket self, path
          signer.post_object options
        end

        ##
        # The Bucket::Acl instance used to control access to the bucket.
        #
        # A bucket has owners, writers, and readers. Permissions can be granted
        # to an individual user's email address, a group's email address, as
        # well as many predefined lists.
        #
        # @see https://cloud.google.com/storage/docs/access-control Access
        #   Control guide
        #
        # @example Grant access to a user by prepending `"user-"` to an email:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-todo-app"
        #
        #   email = "heidi@example.net"
        #   bucket.acl.add_reader "user-#{email}"
        #
        # @example Grant access to a group by prepending `"group-"` to an email:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-todo-app"
        #
        #   email = "authors@example.net"
        #   bucket.acl.add_reader "group-#{email}"
        #
        # @example Or, grant access via a predefined permissions list:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
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
        # granted to an individual user's email address, a group's email
        # address, as well as many predefined lists.
        #
        # @see https://cloud.google.com/storage/docs/access-control Access
        #   Control guide
        #
        # @example Grant access to a user by prepending `"user-"` to an email:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-todo-app"
        #
        #   email = "heidi@example.net"
        #   bucket.default_acl.add_reader "user-#{email}"
        #
        # @example Grant access to a group by prepending `"group-"` to an email
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-todo-app"
        #
        #   email = "authors@example.net"
        #   bucket.default_acl.add_reader "group-#{email}"
        #
        # @example Or, grant access via a predefined permissions list:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
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
        def ensure_io_or_file_exists! file
          return if file.respond_to?(:read) && file.respond_to?(:rewind)
          return if ::File.file? file
          fail ArgumentError, "cannot find file #{file}"
        end

        def storage_class_for str
          return nil if str.nil?
          { "durable_reduced_availability" => "DURABLE_REDUCED_AVAILABILITY",
            "dra" => "DURABLE_REDUCED_AVAILABILITY",
            "durable" => "DURABLE_REDUCED_AVAILABILITY",
            "nearline" => "NEARLINE",
            "coldline" => "COLDLINE",
            "multi_regional" => "MULTI_REGIONAL",
            "regional" => "REGIONAL",
            "standard" => "STANDARD" }[str.to_s.downcase] || str.to_s
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
          # @private Make sure any cors changes are saved
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
end
