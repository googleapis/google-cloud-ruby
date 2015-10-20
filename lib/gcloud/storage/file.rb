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

require "gcloud/storage/file/acl"
require "gcloud/storage/file/list"
require "gcloud/storage/file/verifier"

module Gcloud
  module Storage
    ##
    # = File
    #
    # Represents a File
    # ({Object}[https://cloud.google.com/storage/docs/json_api/v1/objects]) that
    # belongs to a Bucket. Files (Objects) are
    # the individual pieces of data that you store in Google Cloud Storage. A
    # file can be up to 5 TB in size. Files have two components:
    # data and metadata. The data component is the data from an external file or
    # other data source that you want to store in Google Cloud Storage. The
    # metadata component is a collection of name-value pairs that describe
    # various qualities of the data. For more information, see {Concepts and
    # Techniques}[https://cloud.google.com/storage/docs/concepts-techniques].
    #
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   storage = gcloud.storage
    #
    #   bucket = storage.bucket "my-bucket"
    #
    #   file = bucket.file "path/to/my-file.ext"
    #   file.download "/downloads/#{bucket.name}/#{file.name}"
    #
    class File
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # The Google API Client object.
      attr_accessor :gapi #:nodoc:

      ##
      # Create an empty File object.
      def initialize #:nodoc:
        @connection = nil
        @gapi = {}
      end

      ##
      # The kind of item this is.
      # For files, this is always storage#object.
      def kind
        @gapi["kind"]
      end

      ##
      # The ID of the file.
      def id
        @gapi["id"]
      end

      ##
      # The name of this file.
      def name
        @gapi["name"]
      end

      ##
      # The name of the bucket containing this file.
      def bucket
        @gapi["bucket"]
      end

      ##
      # The content generation of this file.
      # Used for object versioning.
      def generation
        @gapi["generation"]
      end

      ##
      # The version of the metadata for this file at this generation.
      # Used for preconditions and for detecting changes in metadata.
      # A metageneration number is only meaningful in the context of a
      # particular generation of a particular file.
      def metageneration
        @gapi["metageneration"]
      end

      ##
      # A URL that can be used to access the file using the REST API.
      def api_url
        @gapi["selfLink"]
      end

      ##
      # A URL that can be used to download the file using the REST API.
      def media_url
        @gapi["mediaLink"]
      end

      ##
      # Content-Length of the data in bytes.
      def size
        @gapi["size"]
      end

      ##
      # Creation time of the file.
      def created_at
        @gapi["timeCreated"]
      end

      ##
      # The creation or modification time of the file.
      # For buckets with versioning enabled, changing an object's
      # metadata does not change this property.
      def updated_at
        @gapi["updated"]
      end

      ##
      # MD5 hash of the data; encoded using base64.
      def md5
        @gapi["md5Hash"]
      end

      ##
      # The CRC32c checksum of the data, as described in
      # {RFC 4960, Appendix B}[http://tools.ietf.org/html/rfc4960#appendix-B].
      # Encoded using base64 in big-endian byte order.
      def crc32c
        @gapi["crc32c"]
      end

      ##
      # HTTP 1.1 Entity tag for the file.
      def etag
        @gapi["etag"]
      end

      ##
      # The {Cache-Control}[https://tools.ietf.org/html/rfc7234#section-5.2]
      # directive for the file data.
      def cache_control
        @gapi["cacheControl"]
      end

      ##
      # Updates the
      # {Cache-Control}[https://tools.ietf.org/html/rfc7234#section-5.2]
      # directive for the file data.
      def cache_control= cache_control
        patch_gapi! cache_control: cache_control
      end

      ##
      # The {Content-Disposition}[https://tools.ietf.org/html/rfc6266] of the
      # file data.
      def content_disposition
        @gapi["contentDisposition"]
      end

      ##
      # Updates the {Content-Disposition}[https://tools.ietf.org/html/rfc6266]
      # of the file data.
      def content_disposition= content_disposition
        patch_gapi! content_disposition: content_disposition
      end

      ##
      # The {Content-Encoding
      # }[https://tools.ietf.org/html/rfc7231#section-3.1.2.2] of the file data.
      def content_encoding
        @gapi["contentEncoding"]
      end

      ##
      # Updates the {Content-Encoding
      # }[https://tools.ietf.org/html/rfc7231#section-3.1.2.2] of the file data.
      def content_encoding= content_encoding
        patch_gapi! content_encoding: content_encoding
      end

      ##
      # The {Content-Language}[http://tools.ietf.org/html/bcp47] of the file
      # data.
      def content_language
        @gapi["contentLanguage"]
      end

      ##
      # Updates the {Content-Language}[http://tools.ietf.org/html/bcp47] of the
      # file data.
      def content_language= content_language
        patch_gapi! content_language: content_language
      end

      ##
      # The {Content-Type}[https://tools.ietf.org/html/rfc2616#section-14.17] of
      # the file data.
      def content_type
        @gapi["contentType"]
      end

      ##
      # Updates the
      # {Content-Type}[https://tools.ietf.org/html/rfc2616#section-14.17] of the
      # file data.
      def content_type= content_type
        patch_gapi! content_type: content_type
      end

      ##
      # A hash of custom, user-provided web-safe keys and arbitrary string
      # values that will returned with requests for the file as "x-goog-meta-"
      # response headers.
      def metadata
        m = @gapi["metadata"]
        m = m.to_hash if m.respond_to? :to_hash
        m.freeze
      end

      ##
      # Updates the hash of custom, user-provided web-safe keys and arbitrary
      # string values that will returned with requests for the file as
      # "x-goog-meta-" response headers.
      def metadata= metadata
        patch_gapi! metadata: metadata
      end

      ##
      # Updates the file with changes made in the given block in a single
      # PATCH request. The following attributes may be set: #cache_control=,
      # #content_disposition=, #content_encoding=, #content_language=,
      # #content_type=, and #metadata=. The #metadata hash accessible in the
      # block is completely mutable and will be included in the request.
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
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
        updater = Updater.new metadata
        yield updater
        patch_gapi! updater.updates unless updater.updates.empty?
      end

      ##
      # Download the file's contents to a local file.
      #
      # === Parameters
      #
      # +path+::
      #   The path on the local file system to write the data to.
      #   The path provided must be writable. (+String+)
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:verify]</code>::
      #   The verification algoruthm used to ensure the downloaded file contents
      #   are correct. Default is +:md5+. (+Symbol+)
      #
      #   Acceptable values are:
      #   * +md5+ - Verify file content match using the MD5 hash.
      #   * +crc32c+ - Verify file content match using the CRC32c hash.
      #   * +all+ - Perform all available file content verification.
      #   * +none+ - Don't perform file content verification.
      #
      # === Returns
      #
      # +::File+ object on the local file system
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #
      #   file = bucket.file "path/to/my-file.ext"
      #   file.download "path/to/downloaded/file.ext"
      #
      # The download is verified by calculating the MD5 digest.
      # The CRC32c digest can be used by passing :crc32c.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #
      #   file = bucket.file "path/to/my-file.ext"
      #   file.download "path/to/downloaded/file.ext", verify: :crc32c
      #
      # Both the MD5 and CRC32c digest can be used by passing :all.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #
      #   file = bucket.file "path/to/my-file.ext"
      #   file.download "path/to/downloaded/file.ext", verify: :all
      #
      # The download verification can be disabled by passing :none
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #
      #   file = bucket.file "path/to/my-file.ext"
      #   file.download "path/to/downloaded/file.ext", verify: :none
      #
      def download path, options = {}
        ensure_connection!
        resp = connection.download_file bucket, name
        if resp.success?
          ::File.open path, "wb+" do |f|
            f.write resp.body
          end
          verify_file! ::File.new(path), options
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Copy the file to a new location.
      #
      # === Parameters
      #
      # +dest_bucket_or_path+::
      #   Either the bucket to copy the file to, or the path to copy the file to
      #   in the current bucket. (+String+)
      # +dest_path+::
      #   If a bucket was provided in the first parameter, this contains the
      #   path to copy the file to in the given bucket. (+String+)
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:generation]</code>::
      #   Select a specific revision of the file to copy. The default is the
      #   latest version. (+Integer+)
      # <code>options[:acl]</code>::
      #   A predefined set of access controls to apply to new file.
      #   (+String+)
      #
      #   Acceptable values are:
      #   * +auth+, +auth_read+, +authenticated+, +authenticated_read+,
      #     +authenticatedRead+ - File owner gets OWNER access, and
      #     allAuthenticatedUsers get READER access.
      #   * +owner_full+, +bucketOwnerFullControl+ - File owner gets OWNER
      #     access, and project team owners get OWNER access.
      #   * +owner_read+, +bucketOwnerRead+ - File owner gets OWNER access, and
      #     project team owners get READER access.
      #   * +private+ - File owner gets OWNER access.
      #   * +project_private+, +projectPrivate+ - File owner gets OWNER access,
      #     and project team members get access according to their roles.
      #   * +public+, +public_read+, +publicRead+ - File owner gets OWNER
      #     access, and allUsers get READER access.
      #
      # === Returns
      #
      # +File+ object
      #
      # === Examples
      #
      # The file can also be copied to a new path in the current bucket:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #
      #   file = bucket.file "path/to/my-file.ext"
      #   file.copy "path/to/destination/file.ext"
      #
      # The file can also be copied to a different bucket:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #
      #   file = bucket.file "path/to/my-file.ext"
      #   file.copy "new-destination-bucket",
      #             "path/to/destination/file.ext"
      #
      # The file can also be copied by specifying a generation:
      #
      #   file.copy "copy/of/previous/generation/file.ext",
      #             generation: 123456
      #
      def copy dest_bucket_or_path, dest_path = nil, options = {}
        ensure_connection!
        dest_bucket, dest_path, options = fix_copy_args dest_bucket_or_path,
                                                        dest_path, options

        resp = connection.copy_file bucket, name,
                                    dest_bucket, dest_path, options
        if resp.success?
          File.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Permanently deletes the file.
      #
      # === Returns
      #
      # +true+ if the file was deleted.
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #
      #   file = bucket.file "path/to/my-file.ext"
      #   file.delete
      #
      def delete
        ensure_connection!
        resp = connection.delete_file bucket, name
        if resp.success?
          true
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Public URL to access the file. If the file is not public, requests to
      # the URL will return an error. (See File::Acl#public! and
      # Bucket::DefaultAcl#public!) For more information, read [Accessing Public
      # Data]{https://cloud.google.com/storage/docs/access-public-data}.
      #
      # To share a file that is not public see #signed_url.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:protocol]</code>::
      #   The protocol to use for the URL. Default is +HTTPS+. (+String+)
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-todo-app"
      #   file = bucket.file "avatars/heidi/400x400.png"
      #   public_url = file.public_url
      #
      # To generate the URL with a protocol other than HTTPS, use the +protocol+
      # option:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-todo-app"
      #   file = bucket.file "avatars/heidi/400x400.png"
      #   public_url = file.public_url protocol: "http"
      #
      def public_url options = {}
        protocol = options[:protocol] || :https
        "#{protocol}://storage.googleapis.com/#{bucket}/#{name}"
      end
      alias_method :url, :public_url

      ##
      # Access without authentication can be granted to a File for a specified
      # period of time. This URL uses a cryptographic signature
      # of your credentials to access the file. See the
      # {Access Control Signed URLs guide
      # }[https://cloud.google.com/storage/docs/access-control#Signed-URLs]
      # for more.
      #
      # Generating a URL requires service account credentials, either by
      # connecting with a service account when calling Gcloud.storage, or by
      # passing in the service account +issuer+ and +signing_key+ values. A
      # SignedUrlUnavailable is raised if the service account credentials are
      # missing. Service account credentials are acquired by following the steps
      # in {Service Account Authentication}[
      # https://cloud.google.com/storage/docs/authentication#service_accounts].
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:method]</code>::
      #   The HTTP verb to be used with the signed URL. Signed URLs can be used
      #   with +GET+, +HEAD+, +PUT+, and +DELETE+ requests. Default is +GET+.
      #   (+String+)
      # <code>options[:expires]</code>::
      #   The number of seconds until the URL expires. Default is 300/5 minutes.
      #   (+Integer+)
      # <code>options[:content_type]</code>::
      #   When provided, the client (browser) must send this value in the
      #   HTTP header. e.g. +text/plain+ (+String+)
      # <code>options[:content_md5]</code>::
      #   The MD5 digest value in base64. If you provide this in the string, the
      #   client (usually a browser) must provide this HTTP header with this
      #   same value in its request. (+String+)
      # <code>options[:issuer]</code>::
      #   Service Account's Client Email. (+String+)
      # <code>options[:signing_key]</code>::
      #   Service Account's Private Key. (+OpenSSL::PKey::RSA+ or +String+)
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-todo-app"
      #   file = bucket.file "avatars/heidi/400x400.png"
      #   shared_url = file.signed_url
      #
      # Any of the option parameters may be specified:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-todo-app"
      #   file = bucket.file "avatars/heidi/400x400.png"
      #   shared_url = file.signed_url method: "GET",
      #                                expires: 300 # 5 minutes from now
      #
      # Signed URLs require service account credentials. If you are not
      # authenticated with a service account, those credentials can be passed in
      # using the +issuer+ and +signing_key+ options. Although the private key
      # can be passed as a string for convenience, creating and storing an
      # instance of +OpenSSL::PKey::RSA+ is more efficient when making multiple
      # calls to +signed_url+.
      #
      #   require "gcloud/storage"
      #
      #   storage = Gcloud.storage
      #
      #   bucket = storage.bucket "my-todo-app"
      #   file = bucket.file "avatars/heidi/400x400.png"
      #   key = OpenSSL::PKey::RSA.new "-----BEGIN PRIVATE KEY-----\n..."
      #   shared_url = file.signed_url issuer: "service-account@gcloud.com",
      #                                signing_key: key
      #
      def signed_url options = {}
        ensure_connection!
        signer = File::Signer.new self
        signer.signed_url options
      end

      ##
      # The File::Acl instance used to control access to the file.
      #
      # A file has owners, writers, and readers. Permissions can be granted to
      # an individual user's email address, a group's email address,  as well as
      # many predefined lists. See the
      # {Access Control guide
      # }[https://cloud.google.com/storage/docs/access-control]
      # for more.
      #
      # === Examples
      #
      # Access to a file can be granted to a user by appending +"user-"+ to the
      # email address:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-todo-app"
      #   file = bucket.file "avatars/heidi/400x400.png"
      #
      #   email = "heidi@example.net"
      #   file.acl.add_reader "user-#{email}"
      #
      # Access to a file can be granted to a group by appending +"group-"+ to
      # the email address:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-todo-app"
      #   file = bucket.file "avatars/heidi/400x400.png"
      #
      #   email = "authors@example.net"
      #   file.acl.add_reader "group-#{email}"
      #
      # Access to a file can also be granted to a predefined list of
      # permissions:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
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
        ensure_connection!
        resp = connection.get_file bucket, name
        if resp.success?
          @gapi = resp.data
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :refresh!, :reload!

      ##
      # URI of the location and file name in the format of
      # <code>gs://my-bucket/file-name.json</code>.
      def to_gs_url #:nodoc:
        "gs://#{bucket}/#{name}"
      end

      ##
      # New File from a Google API Client object.
      def self.from_gapi gapi, conn #:nodoc:
        new.tap do |f|
          f.gapi = gapi
          f.connection = conn
        end
      end

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless connection
      end

      def patch_gapi! options = {}
        ensure_connection!
        resp = connection.patch_file bucket, name, options
        if resp.success?
          @gapi = resp.data
        else
          fail ApiError.from_response(resp)
        end
      end

      def fix_copy_args dest_bucket, dest_path, options = {}
        if dest_path.respond_to?(:to_hash) && options.empty?
          options, dest_path = dest_path, nil
        end
        dest_path, dest_bucket = dest_bucket, bucket if dest_path.nil?
        dest_bucket = dest_bucket.name if dest_bucket.respond_to? :name
        options[:acl] = File::Acl.predefined_rule_for options[:acl]
        [dest_bucket, dest_path, options]
      end

      def verify_file! file, options = {}
        verify = options[:verify] || :md5
        verify_md5    = verify == :md5    || verify == :all
        verify_crc32c = verify == :crc32c || verify == :all
        Verifier.verify_md5! self, file    if verify_md5
        Verifier.verify_crc32c! self, file if verify_crc32c
        file
      end

      ##
      # Create a signed_url for a file.
      class Signer #:nodoc:
        def initialize file
          @file = file
        end

        ##
        # The external path to the file.
        def ext_path
          "/#{@file.bucket}/#{@file.name}"
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
           ext_path].join "\n"
        end

        def determine_signing_key options = {}
          options[:signing_key] || options[:private_key] ||
            @file.connection.credentials.signing_key
        end

        def determine_issuer options = {}
          options[:issuer] || options[:client_email] ||
            @file.connection.credentials.issuer
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
          signature = Base64.encode64(signed_string).delete("\n")
          "#{ext_url}?GoogleAccessId=#{CGI.escape issuer}" \
                    "&Expires=#{expires}" \
                    "&Signature=#{CGI.escape signature}"
        end
      end

      ##
      # Yielded to a block to accumulate changes for a patch request.
      class Updater
        attr_reader :updates
        ##
        # Create an Updater object.
        def initialize metadata
          @metadata = if metadata.nil?
                        {}
                      else
                        metadata.dup
                      end
          @updates = {}
        end

        ATTRS = [:cache_control, :content_disposition, :content_encoding,
                 :content_language, :content_type, :metadata]

        ATTRS.each do |attr|
          define_method "#{attr}=" do |arg|
            updates[attr] = arg
          end
        end

        ##
        # Return metadata for mutation. Also adds metadata to @updates so that
        # it is included in the patch request.
        def metadata
          updates[:metadata] ||= @metadata
        end
      end
    end
  end
end
