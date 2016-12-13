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

module Google
  module Cloud
    module Storage
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
      class File
        ##
        # @private The Connection object.
        attr_accessor :service

        ##
        # @private The Google API Client object.
        attr_accessor :gapi

        ##
        # @private Create an empty File object.
        def initialize
          @service = nil
          @gapi = Google::Apis::StorageV1::Object.new
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
          patch_gapi! :cache_control
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
          patch_gapi! :content_disposition
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
          patch_gapi! :content_encoding
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
          patch_gapi! :content_language
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
          patch_gapi! :content_type
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
          patch_gapi! :metadata
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
          patch_gapi! updater.updates unless updater.updates.empty?
        end

        ##
        # Download the file's contents to a local file.
        #
        # By default, the download is verified by calculating the MD5 digest.
        #
        # If a [customer-supplied encryption
        # key](https://cloud.google.com/storage/docs/encryption#customer-supplied)
        # was used with {Bucket#create_file}, the `encryption_key` option must
        # be provided.
        #
        # @param [String] path The path on the local file system to write the
        #   data to. The path provided must be writable.
        # @param [Symbol] verify The verification algoruthm used to ensure the
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
        #
        # @return [File] Returns a `::File` object on the local file system
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
        def download path, verify: :md5, encryption_key: nil
          ensure_service!
          service.download_file \
            bucket, name, path,
            key: encryption_key
          verify_file! ::File.new(path), verify
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
        def copy dest_bucket_or_path, dest_path = nil, acl: nil,
                 generation: nil, encryption_key: nil
          ensure_service!
          options = { acl: acl, generation: generation,
                      key: encryption_key }
          dest_bucket, dest_path, options = fix_copy_args dest_bucket_or_path,
                                                          dest_path, options

          gapi = service.copy_file bucket, name,
                                   dest_bucket, dest_path, options
          File.from_gapi gapi, service
        end

        ##
        # Permanently deletes the file.
        #
        # @return [Boolean] Returns `true` if the file was deleted.
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
        def delete
          ensure_service!
          service.delete_file bucket, name
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
        #   shared_url = file.signed_url method: "GET",
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
        #                                  "x-goog-meta-foo" => bar,baz"
        #                                }
        #
        def signed_url method: nil, expires: nil, content_type: nil,
                       content_md5: nil, headers: nil, issuer: nil,
                       client_email: nil, signing_key: nil, private_key: nil
          ensure_service!
          options = { method: method, expires: expires, headers: headers,
                      content_type: content_type, content_md5: content_md5,
                      issuer: issuer, client_email: client_email,
                      signing_key: signing_key, private_key: private_key }
          signer = File::Signer.from_file self
          signer.signed_url options
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
        def reload!
          ensure_service!
          @gapi = service.get_file bucket, name
        end
        alias_method :refresh!, :reload!

        ##
        # @private URI of the location and file name in the format of
        # <code>gs://my-bucket/file-name.json</code>.
        def to_gs_url
          "gs://#{bucket}/#{name}"
        end

        ##
        # @private New File from a Google API Client object.
        def self.from_gapi gapi, service
          new.tap do |f|
            f.gapi = gapi
            f.service = service
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
          patch_gapi = Google::Apis::StorageV1::Object.new patch_args
          @gapi = service.patch_file bucket, name, patch_gapi
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
          Verifier.verify_md5! self, file    if verify_md5
          Verifier.verify_crc32c! self, file if verify_crc32c
          file
        end

        ##
        # @private Create a signed_url for a file.
        class Signer
          def initialize bucket, path, service
            @bucket = bucket
            @path = path
            @service = service
          end

          def self.from_file file
            new file.bucket, file.name, file.service
          end

          def self.from_bucket bucket, path
            new bucket.name, path, bucket.service
          end

          ##
          # The external path to the file.
          def ext_path
            URI.escape "/#{@bucket}/#{@path}"
          end

          ##
          # The external url to the file.
          def ext_url
            "https://storage.googleapis.com#{ext_path}"
          end

          def apply_option_defaults options
            adjusted_expires = (Time.now.utc + (options[:expires] || 300)).to_i
            options[:expires] = adjusted_expires
            options[:method]  ||= "GET"
            options
          end

          def signature_str options
            [options[:method], options[:content_md5],
             options[:content_type], options[:expires],
             format_extension_headers(options[:headers]) + ext_path].join "\n"
          end

          def determine_signing_key options = {}
            options[:signing_key] || options[:private_key] ||
              @service.credentials.signing_key
          end

          def determine_issuer options = {}
            options[:issuer] || options[:client_email] ||
              @service.credentials.issuer
          end

          def signed_url options
            options = apply_option_defaults options

            i = determine_issuer options
            s = determine_signing_key options

            fail SignedUrlUnavailable unless i && s

            sig = generate_signature s, options
            generate_signed_url i, sig, options[:expires]
          end

          def generate_signature signing_key, options = {}
            unless signing_key.respond_to? :sign
              signing_key = OpenSSL::PKey::RSA.new signing_key
            end
            signing_key.sign OpenSSL::Digest::SHA256.new, signature_str(options)
          end

          def generate_signed_url issuer, signed_string, expires
            signature = Base64.strict_encode64(signed_string).delete("\n")
            "#{ext_url}?GoogleAccessId=#{CGI.escape issuer}" \
              "&Expires=#{expires}" \
              "&Signature=#{CGI.escape signature}"
          end

          def format_extension_headers headers
            return "" if headers.nil?
            fail "Headers must be given in a Hash" unless headers.is_a? Hash
            flatten = headers.map do |key, value|
              "#{key.to_s.downcase}:#{value.gsub(/\s+/, ' ')}\n"
            end
            flatten.reject! { |h| h.start_with? "x-goog-encryption-key" }
            flatten.sort.join
          end
        end

        ##
        # Yielded to a block to accumulate changes for a patch request.
        class Updater < File
          attr_reader :updates
          ##
          # Create an Updater object.
          def initialize gapi
            @updates = []
            @gapi = gapi
          end

          ##
          # A hash of custom, user-provided web-safe keys and arbitrary string
          # values that will returned with requests for the file as
          # "x-goog-meta-" response headers.
          def metadata
            # do not freeze metadata
            @metadata ||= @gapi.metadata.to_h.dup
          end

          ##
          # Updates the hash of custom, user-provided web-safe keys and
          # arbitrary string values that will returned with requests for the
          # file as "x-goog-meta-" response headers.
          def metadata= metadata
            @metadata = metadata
            @gapi.metadata = @metadata
            patch_gapi! :metadata
          end

          ##
          # @private Make sure any metadata changes are saved
          def check_for_changed_metadata!
            return if @metadata == @gapi.metadata
            @gapi.metadata = @metadata
            patch_gapi! :metadata
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
