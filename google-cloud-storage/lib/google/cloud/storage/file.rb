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


require "uri"
require "google/cloud/storage/file/acl"
require "google/cloud/storage/file/list"
require "google/cloud/storage/file/verifier"
require "google/cloud/storage/file/signer"
require "zlib"

module Google
  module Cloud
    module Storage
      GOOGLEAPIS_URL = "https://storage.googleapis.com".freeze

      ##
      # # File
      #
      # Represents a File
      # ([Object](https://cloud.google.com/storage/docs/json_api/v1/objects))
      # that belongs to a {Bucket}. Files (Objects) are the individual pieces of
      # data that you store in Google Cloud Storage. A file can be up to 5 TB in
      # size. Files have two components: data and metadata. The data component
      # is the data from an external file or other data source that you want to
      # store in Google Cloud Storage. The metadata component is a collection of
      # name-value pairs that describe various qualities of the data.
      #
      # @see https://cloud.google.com/storage/docs/concepts-techniques Concepts
      #   and Techniques
      #
      # @example
      #   require "google/cloud/storage"
      #
      #   storage = Google::Cloud::Storage.new
      #
      #   bucket = storage.bucket "my-bucket"
      #
      #   file = bucket.file "path/to/my-file.ext"
      #   file.download "path/to/downloaded/file.ext"
      #
      # @example Download a public file with an unauthenticated client:
      #   require "google/cloud/storage"
      #
      #   storage = Google::Cloud::Storage.anonymous
      #
      #   bucket = storage.bucket "public-bucket", skip_lookup: true
      #   file = bucket.file "path/to/public-file.ext", skip_lookup: true
      #
      #   downloaded = file.download
      #   downloaded.rewind
      #   downloaded.read #=> "Hello world!"
      #
      class File
        ##
        # @private The Connection object.
        attr_accessor :service

        ##
        # If this attribute is set to `true`, transit costs for operations on
        # the file will be billed to the current project for this client. (See
        # {Project#project} for the ID of the current project.) If this
        # attribute is set to a project ID, and that project is authorized for
        # the currently authenticated service account, transit costs will be
        # billed to that project. This attribute is required with requester
        # pays-enabled buckets. The default is `nil`.
        #
        # In general, this attribute should be set when first retrieving the
        # owning bucket by providing the `user_project` option to
        # {Project#bucket} or {Project#buckets}.
        #
        # See also {Bucket#requester_pays=} and {Bucket#requester_pays}.
        #
        # @example Setting a non-default project:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "other-project-bucket", user_project: true
        #   file = bucket.file "path/to/file.ext" # Billed to current project
        #   file.user_project = "my-other-project"
        #   file.download "file.ext" # Billed to "my-other-project"
        #
        attr_accessor :user_project

        ##
        # @private The Google API Client object.
        attr_accessor :gapi

        ##
        # @private Create an empty File object.
        def initialize
          @service = nil
          @gapi = Google::Apis::StorageV1::Object.new
          @user_project = nil
        end

        ##
        # The kind of item this is.
        # For files, this is always storage#object.
        def kind
          @gapi.kind
        end

        ##
        # The ID of the file.
        def id
          @gapi.id
        end

        ##
        # The name of this file.
        def name
          @gapi.name
        end

        ##
        # The name of the {Bucket} containing this file.
        def bucket
          @gapi.bucket
        end

        ##
        # The content generation of this file.
        # Used for object versioning.
        def generation
          @gapi.generation
        end

        ##
        # The version of the metadata for this file at this generation.
        # Used for preconditions and for detecting changes in metadata.
        # A metageneration number is only meaningful in the context of a
        # particular generation of a particular file.
        def metageneration
          @gapi.metageneration
        end

        ##
        # A URL that can be used to access the file using the REST API.
        def api_url
          @gapi.self_link
        end

        ##
        # A URL that can be used to download the file using the REST API.
        def media_url
          @gapi.media_link
        end

        ##
        # Content-Length of the data in bytes.
        def size
          @gapi.size.to_i if @gapi.size
        end

        ##
        # Creation time of the file.
        def created_at
          @gapi.time_created
        end

        ##
        # The creation or modification time of the file.
        # For buckets with versioning enabled, changing an object's
        # metadata does not change this property.
        def updated_at
          @gapi.updated
        end

        ##
        # MD5 hash of the data; encoded using base64.
        def md5
          @gapi.md5_hash
        end

        ##
        # The CRC32c checksum of the data, as described in
        # [RFC 4960, Appendix B](http://tools.ietf.org/html/rfc4960#appendix-B).
        # Encoded using base64 in big-endian byte order.
        def crc32c
          @gapi.crc32c
        end

        ##
        # HTTP 1.1 Entity tag for the file.
        def etag
          @gapi.etag
        end

        ##
        # The [Cache-Control](https://tools.ietf.org/html/rfc7234#section-5.2)
        # directive for the file data.
        def cache_control
          @gapi.cache_control
        end

        ##
        # Updates the
        # [Cache-Control](https://tools.ietf.org/html/rfc7234#section-5.2)
        # directive for the file data.
        def cache_control= cache_control
          @gapi.cache_control = cache_control
          update_gapi! :cache_control
        end

        ##
        # The [Content-Disposition](https://tools.ietf.org/html/rfc6266) of the
        # file data.
        def content_disposition
          @gapi.content_disposition
        end

        ##
        # Updates the [Content-Disposition](https://tools.ietf.org/html/rfc6266)
        # of the file data.
        def content_disposition= content_disposition
          @gapi.content_disposition = content_disposition
          update_gapi! :content_disposition
        end

        ##
        # The [Content-Encoding
        # ](https://tools.ietf.org/html/rfc7231#section-3.1.2.2) of the file
        # data.
        def content_encoding
          @gapi.content_encoding
        end

        ##
        # Updates the [Content-Encoding
        # ](https://tools.ietf.org/html/rfc7231#section-3.1.2.2) of the file
        # data.
        def content_encoding= content_encoding
          @gapi.content_encoding = content_encoding
          update_gapi! :content_encoding
        end

        ##
        # The [Content-Language](http://tools.ietf.org/html/bcp47) of the file
        # data.
        def content_language
          @gapi.content_language
        end

        ##
        # Updates the [Content-Language](http://tools.ietf.org/html/bcp47) of
        # the file data.
        def content_language= content_language
          @gapi.content_language = content_language
          update_gapi! :content_language
        end

        ##
        # The [Content-Type](https://tools.ietf.org/html/rfc2616#section-14.17)
        # of the file data.
        def content_type
          @gapi.content_type
        end

        ##
        # Updates the
        # [Content-Type](https://tools.ietf.org/html/rfc2616#section-14.17) of
        # the file data.
        def content_type= content_type
          @gapi.content_type = content_type
          update_gapi! :content_type
        end

        ##
        # A hash of custom, user-provided web-safe keys and arbitrary string
        # values that will returned with requests for the file as "x-goog-meta-"
        # response headers.
        def metadata
          m = @gapi.metadata
          m = m.to_h if m.respond_to? :to_h
          m.dup.freeze
        end

        ##
        # Updates the hash of custom, user-provided web-safe keys and arbitrary
        # string values that will returned with requests for the file as
        # "x-goog-meta-" response headers.
        def metadata= metadata
          @gapi.metadata = metadata
          update_gapi! :metadata
        end

        ##
        # An [RFC 4648](https://tools.ietf.org/html/rfc4648#section-4)
        # Base64-encoded string of the SHA256 hash of the [customer-supplied
        # encryption
        # key](https://cloud.google.com/storage/docs/encryption#customer-supplied).
        # You can use this SHA256 hash to uniquely identify the AES-256
        # encryption key required to decrypt this file.
        def encryption_key_sha256
          return nil unless @gapi.customer_encryption
          Base64.decode64 @gapi.customer_encryption.key_sha256
        end

        ##
        # The file's storage class. This defines how the file is stored and
        # determines the SLA and the cost of storage. For more information, see
        # [Storage
        # Classes](https://cloud.google.com/storage/docs/storage-classes) and
        # [Per-Object Storage
        # Class](https://cloud.google.com/storage/docs/per-object-storage-class).
        def storage_class
          @gapi.storage_class
        end

        ##
        # Updates how the file is stored and determines the SLA and the cost of
        # storage. Accepted values include `:multi_regional`, `:regional`,
        # `:nearline`, and `:coldline`, as well as the equivalent strings
        # returned by {File#storage_class} or {Bucket#storage_class}. For more
        # information, see [Storage
        # Classes](https://cloud.google.com/storage/docs/storage-classes) and
        # [Per-Object Storage
        # Class](https://cloud.google.com/storage/docs/per-object-storage-class).
        # The  default value is the default storage class for the bucket. See
        # {Bucket#storage_class}.
        # @param [Symbol, String] storage_class Storage class of the file.
        def storage_class= storage_class
          @gapi.storage_class = storage_class_for(storage_class)
          update_gapi! :storage_class
        end

        ##
        # Retrieves a list of versioned files for the current object.
        #
        # Useful for listing archived versions of the file, restoring the live
        # version of the file to an older version, or deleting an archived
        # version. You can turn versioning on or off for a bucket at any time
        # with {Bucket#versioning=}. Turning versioning off leaves existing file
        # versions in place and causes the bucket to stop accumulating new
        # archived object versions. (See {Bucket#versioning} and
        # {File#generation})
        #
        # @see https://cloud.google.com/storage/docs/object-versioning Object
        #   Versioning
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
        #
        #   file = bucket.file "path/to/my-file.ext"
        #   file.generation #=> 1234567890
        #   file.generations.each do |versioned_file|
        #     versioned_file.generation
        #   end
        #
        def generations
          ensure_service!
          gapi = service.list_files bucket, prefix: name,
                                            versions: true,
                                            user_project: user_project
          File::List.from_gapi gapi, service, bucket, name, nil, nil, true,
                               user_project: user_project
        end

        ##
        # Updates the file with changes made in the given block in a single
        # PATCH request. The following attributes may be set: {#cache_control=},
        # {#content_disposition=}, {#content_encoding=}, {#content_language=},
        # {#content_type=}, and {#metadata=}. The {#metadata} hash accessible in
        # the block is completely mutable and will be included in the request.
        #
        # @yield [file] a block yielding a delegate object for updating the file
        #
        # @example
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   file = bucket.file "path/to/my-file.ext"
        #
        #   file.update do |f|
        #     f.cache_control = "private, max-age=0, no-cache"
        #     f.content_disposition = "inline; filename=filename.ext"
        #     f.content_encoding = "deflate"
        #     f.content_language = "de"
        #     f.content_type = "application/json"
        #     f.metadata["player"] = "Bob"
        #     f.metadata["score"] = "10"
        #   end
        #
        def update
          updater = Updater.new gapi
          yield updater
          updater.check_for_changed_metadata!
          update_gapi! updater.updates unless updater.updates.empty?
        end

        ##
        # Download the file's contents to a local file or an IO instance.
        #
        # By default, the download is verified by calculating the MD5 digest.
        #
        # If a [customer-supplied encryption
        # key](https://cloud.google.com/storage/docs/encryption#customer-supplied)
        # was used with {Bucket#create_file}, the `encryption_key` option must
        # be provided.
        #
        # @param [String, IO] path The path on the local file system to write
        #   the data to. The path provided must be writable. Can also be an IO
        #   object, or IO-ish object like StringIO. If an IO object, the object
        #   will be written to, not the filesystem. If omitted, a new StringIO
        #   instance will be written to and returned. Optional.
        # @param [Symbol] verify The verification algorithm used to ensure the
        #   downloaded file contents are correct. Default is `:md5`.
        #
        #   Acceptable values are:
        #
        #   * `md5` - Verify file content match using the MD5 hash.
        #   * `crc32c` - Verify file content match using the CRC32c hash.
        #   * `all` - Perform all available file content verification.
        #   * `none` - Don't perform file content verification.
        #
        # @param [String] encryption_key Optional. The customer-supplied,
        #   AES-256 encryption key used to encrypt the file, if one was provided
        #   to {Bucket#create_file}.
        # @param [Boolean] skip_decompress Optional. If `true`, the data for a
        #   Storage object returning a `Content-Encoding: gzip` response header
        #   will *not* be automatically decompressed by this client library. The
        #   default is `nil`. Note that all requests by this client library send
        #   the `Accept-Encoding: gzip` header, so decompressive transcoding is
        #   not performed in the Storage service. (See [Transcoding of
        #   gzip-compressed files](https://cloud.google.com/storage/docs/transcoding))
        #
        # @return [IO] Returns an IO object representing the file data. This
        #   will ordinarily be a `::File` object referencing the local file
        #   system. However, if the argument to `path` is `nil`, a StringIO
        #   instance will be returned. If the argument to `path` is an IO
        #   object, then that object will be returned.
        #
        # @example
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   file = bucket.file "path/to/my-file.ext"
        #   file.download "path/to/downloaded/file.ext"
        #
        # @example Use the CRC32c digest by passing :crc32c.
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   file = bucket.file "path/to/my-file.ext"
        #   file.download "path/to/downloaded/file.ext", verify: :crc32c
        #
        # @example Use the MD5 and CRC32c digests by passing :all.
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   file = bucket.file "path/to/my-file.ext"
        #   file.download "path/to/downloaded/file.ext", verify: :all
        #
        # @example Disable the download verification by passing :none.
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   file = bucket.file "path/to/my-file.ext"
        #   file.download "path/to/downloaded/file.ext", verify: :none
        #
        # @example Download to an in-memory StringIO object.
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   file = bucket.file "path/to/my-file.ext"
        #   downloaded = file.download
        #   downloaded.rewind
        #   downloaded.read #=> "Hello world!"
        #
        # @example Download a public file with an unauthenticated client:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.anonymous
        #
        #   bucket = storage.bucket "public-bucket", skip_lookup: true
        #   file = bucket.file "path/to/public-file.ext", skip_lookup: true
        #
        #   downloaded = file.download
        #   downloaded.rewind
        #   downloaded.read #=> "Hello world!"
        #
        def download path = nil, verify: :md5, encryption_key: nil,
                     skip_decompress: nil
          ensure_service!
          if path.nil?
            path = StringIO.new
            path.set_encoding "ASCII-8BIT"
          end
          file, resp = service.download_file \
            bucket, name, path, key: encryption_key, user_project: user_project
          # FIX: downloading with encryption key will return nil
          file ||= ::File.new(path)
          verify_file! file, verify
          if !skip_decompress &&
             Array(resp.header["Content-Encoding"]).include?("gzip")
            file = gzip_decompress file
          end
          file
        end

        ##
        # Copy the file to a new location.
        #
        # If a [customer-supplied encryption
        # key](https://cloud.google.com/storage/docs/encryption#customer-supplied)
        # was used with {Bucket#create_file}, the `encryption_key` option must
        # be provided.
        #
        # @param [String] dest_bucket_or_path Either the bucket to copy the file
        #   to, or the path to copy the file to in the current bucket.
        # @param [String] dest_path If a bucket was provided in the first
        #   parameter, this contains the path to copy the file to in the given
        #   bucket.
        # @param [String] acl A predefined set of access controls to apply to
        #   new file.
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
        # @param [Integer] generation Select a specific revision of the file to
        #   copy. The default is the latest version.
        # @param [String] encryption_key Optional. The customer-supplied,
        #   AES-256 encryption key used to encrypt the file, if one was provided
        #   to {Bucket#create_file}.
        # @yield [file] a block yielding a delegate object for updating
        #
        # @return [Google::Cloud::Storage::File]
        #
        # @example The file can be copied to a new path in the current bucket:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   file = bucket.file "path/to/my-file.ext"
        #   file.copy "path/to/destination/file.ext"
        #
        # @example The file can also be copied to a different bucket:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   file = bucket.file "path/to/my-file.ext"
        #   file.copy "new-destination-bucket",
        #             "path/to/destination/file.ext"
        #
        # @example The file can also be copied by specifying a generation:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   file = bucket.file "path/to/my-file.ext"
        #   file.copy "copy/of/previous/generation/file.ext",
        #             generation: 123456
        #
        # @example The file can be modified during copying:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   file = bucket.file "path/to/my-file.ext"
        #   file.copy "new-destination-bucket",
        #             "path/to/destination/file.ext" do |f|
        #     f.metadata["copied_from"] = "#{file.bucket}/#{file.name}"
        #   end
        #
        def copy dest_bucket_or_path, dest_path = nil, acl: nil,
                 generation: nil, encryption_key: nil
          ensure_service!
          options = { acl: acl, generation: generation, key: encryption_key,
                      user_project: user_project }
          dest_bucket, dest_path, options = fix_copy_args dest_bucket_or_path,
                                                          dest_path, options

          copy_gapi = nil
          if block_given?
            updater = Updater.new gapi
            yield updater
            updater.check_for_changed_metadata!
            copy_gapi = gapi_from_attrs(updater.updates) if updater.updates.any?
          end

          resp = service.copy_file bucket, name, dest_bucket, dest_path,
                                   copy_gapi, options
          until resp.done
            sleep 1
            resp = service.copy_file bucket, name, dest_bucket, dest_path,
                                     copy_gapi,
                                     options.merge(token: resp.rewrite_token)
          end
          File.from_gapi resp.resource, service, user_project: user_project
        end

        ##
        # [Rewrites](https://cloud.google.com/storage/docs/json_api/v1/objects/rewrite)
        # the file to the same {#bucket} and {#name} with a new
        # [customer-supplied encryption
        # key](https://cloud.google.com/storage/docs/encryption#customer-supplied).
        #
        # If a new key is provided to this method, the new key must be used to
        # subsequently download or copy the file. You must securely manage your
        # keys and ensure that they are not lost. Also, please note that file
        # metadata is not encrypted, with the exception of the CRC32C checksum
        # and MD5 hash. The names of files and buckets are also not encrypted,
        # and you can read or update the metadata of an encrypted file without
        # providing the encryption key.
        #
        # @see https://cloud.google.com/storage/docs/encryption
        #
        # @param [String, nil] encryption_key Optional. The last
        #   customer-supplied, AES-256 encryption key used to encrypt the file,
        #   if one was used.
        # @param [String, nil] new_encryption_key Optional. The new
        #   customer-supplied, AES-256 encryption key with which to encrypt the
        #   file. If `nil`, the rewritten file will be encrypted using the
        #   default server-side encryption, not customer-supplied encryption
        #   keys.
        #
        # @return [Google::Cloud::Storage::File]
        #
        # @example The file will be rewritten with a new encryption key:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #   bucket = storage.bucket "my-bucket"
        #
        #   # Old key was stored securely for later use.
        #   old_key = "y\x03\"\x0E\xB6\xD3\x9B\x0E\xAB*\x19\xFAv\xDEY\xBEI..."
        #
        #   file = bucket.file "path/to/my-file.ext", encryption_key: old_key
        #
        #   # Key generation shown for example purposes only. Write your own.
        #   cipher = OpenSSL::Cipher.new "aes-256-cfb"
        #   cipher.encrypt
        #   new_key = cipher.random_key
        #
        #   file.rotate encryption_key: old_key, new_encryption_key: new_key
        #
        def rotate encryption_key: nil, new_encryption_key: nil
          ensure_service!
          options = { source_key: encryption_key,
                      destination_key: new_encryption_key,
                      user_project: user_project }
          gapi = service.rewrite_file bucket, name, bucket, name, nil, options
          until gapi.done
            sleep 1
            options[:token] = gapi.rewrite_token
            gapi = service.rewrite_file bucket, name, bucket, name, nil, options
          end
          File.from_gapi gapi.resource, service, user_project: user_project
        end

        ##
        # Permanently deletes the file.
        #
        # @return [Boolean] Returns `true` if the file was deleted.
        # @param [Boolean, Integer] generation Specify a version of the file to
        #   delete. When `true`, it will delete the version returned by
        #   {#generation}. The default behavior is to delete the latest version
        #   of the file (regardless of the version to which the file is set,
        #   which is the version returned by {#generation}.)
        #
        # @example
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   file = bucket.file "path/to/my-file.ext"
        #   file.delete
        #
        # @example The file's generation can used by passing `true`:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   file = bucket.file "path/to/my-file.ext"
        #   file.delete generation: true
        #
        # @example A generation can also be specified:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   file = bucket.file "path/to/my-file.ext"
        #   file.delete generation: 123456
        #
        def delete generation: nil
          generation = self.generation if generation == true
          ensure_service!
          service.delete_file bucket, name, generation: generation,
                                            user_project: user_project
          true
        end

        ##
        # Public URL to access the file. If the file is not public, requests to
        # the URL will return an error. (See {File::Acl#public!} and
        # {Bucket::DefaultAcl#public!}) To share a file that is not public see
        # {#signed_url}.
        #
        # @see https://cloud.google.com/storage/docs/access-public-data
        #   Accessing Public Data
        #
        # @param [String] protocol The protocol to use for the URL. Default is
        #   `HTTPS`.
        #
        # @example
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-todo-app"
        #   file = bucket.file "avatars/heidi/400x400.png"
        #   public_url = file.public_url
        #
        # @example Generate the URL with a protocol other than HTTPS:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-todo-app"
        #   file = bucket.file "avatars/heidi/400x400.png"
        #   public_url = file.public_url protocol: "http"
        #
        def public_url protocol: :https
          "#{protocol}://storage.googleapis.com/#{bucket}/#{name}"
        end
        alias_method :url, :public_url

        ##
        # Access without authentication can be granted to a File for a specified
        # period of time. This URL uses a cryptographic signature of your
        # credentials to access the file.
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
        # @param [Hash] query Query string parameters to include in the signed
        #   URL. The given parameters are not verified by the signature.
        #
        #   Parameters such as `response-content-disposition` and
        #   `response-content-type` can alter the behavior of the response when
        #   using the URL, but only when the file resource is missing the
        #   corresponding values. (These values can be permanently set using
        #   {#content_disposition=} and {#content_type=}.)
        #
        # @example
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-todo-app"
        #   file = bucket.file "avatars/heidi/400x400.png"
        #   shared_url = file.signed_url
        #
        # @example Any of the option parameters may be specified:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-todo-app"
        #   file = bucket.file "avatars/heidi/400x400.png"
        #   shared_url = file.signed_url method: "PUT",
        #                                content_type: "image/png",
        #                                expires: 300 # 5 minutes from now
        #
        # @example Using the `issuer` and `signing_key` options:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud.storage
        #
        #   bucket = storage.bucket "my-todo-app"
        #   file = bucket.file "avatars/heidi/400x400.png"
        #   key = OpenSSL::PKey::RSA.new "-----BEGIN PRIVATE KEY-----\n..."
        #   shared_url = file.signed_url issuer: "service-account@gcloud.com",
        #                                signing_key: key
        #
        # @example Using the `headers` option:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-todo-app"
        #   file = bucket.file "avatars/heidi/400x400.png"
        #   shared_url = file.signed_url method: "GET",
        #                                headers: {
        #                                  "x-goog-acl" => "public-read",
        #                                  "x-goog-meta-foo" => "bar,baz"
        #                                }
        #
        def signed_url method: nil, expires: nil, content_type: nil,
                       content_md5: nil, headers: nil, issuer: nil,
                       client_email: nil, signing_key: nil, private_key: nil,
                       query: nil
          ensure_service!
          signer = File::Signer.from_file self
          signer.signed_url method: method, expires: expires, headers: headers,
                            content_type: content_type,
                            content_md5: content_md5,
                            issuer: issuer, client_email: client_email,
                            signing_key: signing_key, private_key: private_key,
                            query: query
        end

        ##
        # The {File::Acl} instance used to control access to the file.
        #
        # A file has owners, writers, and readers. Permissions can be granted to
        # an individual user's email address, a group's email address,  as well
        # as many predefined lists.
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
        #   file = bucket.file "avatars/heidi/400x400.png"
        #
        #   email = "heidi@example.net"
        #   file.acl.add_reader "user-#{email}"
        #
        # @example Grant access to a group by prepending `"group-"` to an email:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-todo-app"
        #   file = bucket.file "avatars/heidi/400x400.png"
        #
        #   email = "authors@example.net"
        #   file.acl.add_reader "group-#{email}"
        #
        # @example Or, grant access via a predefined permissions list:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-todo-app"
        #   file = bucket.file "avatars/heidi/400x400.png"
        #
        #   file.acl.public!
        #
        def acl
          @acl ||= File::Acl.new self
        end

        ##
        # Reloads the file with current data from the Storage service.
        #
        # @param [Boolean, Integer] generation Specify a version of the file to
        #   reload with. When `true`, it will reload the version returned by
        #   {#generation}. The default behavior is to reload with the latest
        #   version of the file (regardless of the version to which the file is
        #   set, which is the version returned by {#generation}.)
        #
        # @example
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   file = bucket.file "path/to/my-file.ext"
        #   file.reload!
        #
        # @example The file's generation can used by passing `true`:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   file = bucket.file "path/to/my-file.ext", generation: 123456
        #   file.reload! generation: true
        #
        # @example A generation can also be specified:
        #   require "google/cloud/storage"
        #
        #   storage = Google::Cloud::Storage.new
        #
        #   bucket = storage.bucket "my-bucket"
        #
        #   file = bucket.file "path/to/my-file.ext", generation: 123456
        #   file.reload! generation: 123457
        #
        def reload! generation: nil
          generation = self.generation if generation == true
          ensure_service!
          @gapi = service.get_file bucket, name, generation: generation,
                                                 user_project: user_project
          # If NotFound then lazy will never be unset
          @lazy = nil
          self
        end
        alias_method :refresh!, :reload!

        ##
        # Determines whether the file exists in the Storage service.
        def exists?
          # Always true if we have a grpc object
          return true unless lazy?
          # If we have a value, return it
          return @exists unless @exists.nil?
          ensure_gapi!
          @exists = true
        rescue Google::Cloud::NotFoundError
          @exists = false
        end

        ##
        # @private
        # Determines whether the file was created without retrieving the
        # resource record from the API.
        def lazy?
          @lazy
        end

        ##
        # @private URI of the location and file name in the format of
        # <code>gs://my-bucket/file-name.json</code>.
        def to_gs_url
          "gs://#{bucket}/#{name}"
        end

        ##
        # @private New File from a Google API Client object.
        def self.from_gapi gapi, service, user_project: nil
          new.tap do |f|
            f.gapi = gapi
            f.service = service
            f.user_project = user_project
          end
        end

        ##
        # @private New lazy Bucket object without making an HTTP request.
        def self.new_lazy bucket, name, service, generation: nil,
                          user_project: nil
          # TODO: raise if name is nil?
          new.tap do |f|
            f.gapi.bucket = bucket
            f.gapi.name = name
            f.gapi.generation = generation
            f.service = service
            f.user_project = user_project
            f.instance_variable_set :@lazy, true
          end
        end

        protected

        ##
        # Raise an error unless an active service is available.
        def ensure_service!
          fail "Must have active connection" unless service
        end

        ##
        # Ensures the Google::Apis::StorageV1::Bucket object exists.
        def ensure_gapi!
          ensure_service!
          return unless lazy?
          reload! generation: true
        end

        def update_gapi! *attributes
          attributes.flatten!
          return if attributes.empty?
          update_gapi = gapi_from_attrs attributes
          return if update_gapi.nil?

          ensure_service!

          if attributes.include? :storage_class
            @gapi = rewrite_gapi bucket, name, update_gapi
          else
            @gapi = service.patch_file \
              bucket, name, update_gapi, user_project: user_project
          end
        end

        def gapi_from_attrs *attributes
          attributes.flatten!
          return nil if attributes.empty?
          attr_params = Hash[attributes.map do |attr|
            [attr, @gapi.send(attr)]
          end]
          Google::Apis::StorageV1::Object.new attr_params
        end

        def rewrite_gapi bucket, name, update_gapi
          resp = service.rewrite_file \
            bucket, name, bucket, name, update_gapi, user_project: user_project
          until resp.done
            sleep 1
            resp = service.rewrite_file \
              bucket, name, bucket, name, update_gapi,
              token: resp.rewrite_token, user_project: user_project
          end
          resp.resource
        end

        def fix_copy_args dest_bucket, dest_path, options = {}
          if dest_path.respond_to?(:to_hash) && options.empty?
            options = dest_path
            dest_path = nil
          end
          if dest_path.nil?
            dest_path = dest_bucket
            dest_bucket = bucket
          end
          dest_bucket = dest_bucket.name if dest_bucket.respond_to? :name
          options[:acl] = File::Acl.predefined_rule_for options[:acl]
          [dest_bucket, dest_path, options]
        end

        def verify_file! file, verify = :md5
          verify_md5    = verify == :md5    || verify == :all
          verify_crc32c = verify == :crc32c || verify == :all
          Verifier.verify_md5! self, file    if verify_md5    && md5
          Verifier.verify_crc32c! self, file if verify_crc32c && crc32c
          file
        end

        # @return [IO] Returns an IO object representing the file data. This
        #   will either be a `::File` object referencing the local file
        #   system or a StringIO instance.
        def gzip_decompress local_file
          if local_file.respond_to? :path
            gz = ::File.open(Pathname(local_file).to_path, "rb") do |f|
              Zlib::GzipReader.new(StringIO.new(f.read))
            end
            uncompressed_string = gz.read
            ::File.open(Pathname(local_file).to_path, "w") do |f|
              f.write uncompressed_string
              f
            end
          else # local_file is StringIO
            local_file.rewind
            gz = Zlib::GzipReader.new StringIO.new(local_file.read)
            StringIO.new gz.read
          end
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
        class Updater < File
          # @private
          attr_reader :updates

          ##
          # @private Create an Updater object.
          def initialize gapi
            @updates = []
            @gapi = gapi
            @metadata ||= @gapi.metadata.to_h.dup
          end

          ##
          # A hash of custom, user-provided web-safe keys and arbitrary string
          # values that will returned with requests for the file as
          # "x-goog-meta-" response headers.
          def metadata
            @metadata
          end

          ##
          # Updates the hash of custom, user-provided web-safe keys and
          # arbitrary string values that will returned with requests for the
          # file as "x-goog-meta-" response headers.
          def metadata= metadata
            @metadata = metadata
            @gapi.metadata = @metadata
            update_gapi! :metadata
          end

          ##
          # @private Make sure any metadata changes are saved
          def check_for_changed_metadata!
            return if @metadata == @gapi.metadata.to_h
            @gapi.metadata = @metadata
            update_gapi! :metadata
          end

          protected

          ##
          # Queue up all the updates instead of making them.
          def update_gapi! attribute
            @updates << attribute
            @updates.uniq!
          end
        end
      end
    end
  end
end
