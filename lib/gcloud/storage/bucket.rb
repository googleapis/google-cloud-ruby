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

require "gcloud/storage/bucket/acl"
require "gcloud/storage/bucket/list"
require "gcloud/storage/bucket/cors"
require "gcloud/storage/file"
require "gcloud/upload"

module Gcloud
  module Storage
    ##
    # = Bucket
    #
    # Represents a Storage bucket. Belongs to a Project and has many Files.
    #
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
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # The Google API Client object.
      attr_accessor :gapi #:nodoc:

      ##
      # Create an empty Bucket object.
      def initialize #:nodoc:
        @connection = nil
        @gapi = {}
      end

      ##
      # The kind of item this is.
      # For buckets, this is always +storage#bucket+.
      def kind
        @gapi["kind"]
      end

      ##
      # The ID of the bucket.
      def id
        @gapi["id"]
      end

      ##
      # The name of the bucket.
      def name
        @gapi["name"]
      end

      ##
      # A URL that can be used to access the bucket using the REST API.
      def api_url
        @gapi["selfLink"]
      end

      ##
      # Creation time of the bucket.
      def created_at
        @gapi["timeCreated"]
      end

      ##
      # Returns the current CORS configuration for a static website served from
      # the bucket. For more information, see {Cross-Origin Resource
      # Sharing (CORS)}[https://cloud.google.com/storage/docs/cross-origin].
      # The return value is a frozen (unmodifiable) array of hashes containing
      # the attributes specified for the Bucket resource field
      # {cors}[https://cloud.google.com/storage/docs/json_api/v1/buckets#cors].
      #
      # This method also accepts a block for updating the bucket's CORS rules.
      # See Bucket::Cors for details.
      #
      # === Examples
      #
      # Retrieving the bucket's CORS rules.
      #
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
      # Updating the bucket's CORS rules inside a block.
      #
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
        if block_given?
          cors_builder = Bucket::Cors.new @gapi["cors"]
          yield cors_builder
          self.cors = cors_builder if cors_builder.changed?
        end
        deep_dup_and_freeze @gapi["cors"]
      end

      ##
      # Updates the CORS configuration for a static website served from the
      # bucket. For more information, see {Cross-Origin Resource
      # Sharing (CORS)}[https://cloud.google.com/storage/docs/cross-origin].
      # Accepts an array of hashes containing the attributes specified for the
      # {resource description of
      # cors}[https://cloud.google.com/storage/docs/json_api/v1/buckets#cors].
      def cors= new_cors
        patch_gapi! cors: new_cors
      end

      ##
      # The location of the bucket.
      # Object data for objects in the bucket resides in physical
      # storage within this region. Defaults to US.
      # See the developer's guide for the authoritative list.
      #
      # https://cloud.google.com/storage/docs/concepts-techniques
      def location
        @gapi["location"]
      end

      ##
      # The destination bucket name for the bucket's logs. For more information,
      # see {Access Logs}[https://cloud.google.com/storage/docs/access-logs].
      def logging_bucket
        @gapi["logging"]["logBucket"] if @gapi["logging"]
      end

      ##
      # Updates the destination bucket for the bucket's logs. For more
      # information, see {Access
      # Logs}[https://cloud.google.com/storage/docs/access-logs]. (+String+)
      def logging_bucket= logging_bucket
        patch_gapi! logging_bucket: logging_bucket
      end

      ##
      # The logging object prefix for the bucket's logs. For more information,
      # see {Access Logs}[https://cloud.google.com/storage/docs/access-logs].
      def logging_prefix
        @gapi["logging"]["logObjectPrefix"] if @gapi["logging"]
      end

      ##
      # Updates the logging object prefix. This prefix will be used to create
      # log object names for the bucket. It can be at most 900 characters and
      # must be a {valid object
      # name}[https://cloud.google.com/storage/docs/bucket-naming#objectnames].
      # By default, the object prefix is the name
      # of the bucket for which the logs are enabled. For more information, see
      # {Access Logs}[https://cloud.google.com/storage/docs/access-logs].
      # (+String+)
      def logging_prefix= logging_prefix
        patch_gapi! logging_prefix: logging_prefix
      end

      ##
      # The bucket's storage class. This defines how objects in the bucket are
      # stored and determines the SLA and the cost of storage. Values include
      # +STANDARD+, +NEARLINE+, and +DURABLE_REDUCED_AVAILABILITY+.
      def storage_class
        @gapi["storageClass"]
      end

      ##
      # Whether {Object
      # Versioning}[https://cloud.google.com/storage/docs/object-versioning] is
      # enabled for the bucket.
      def versioning?
        !@gapi["versioning"].nil? && @gapi["versioning"]["enabled"]
      end

      ##
      # Updates whether {Object
      # Versioning}[https://cloud.google.com/storage/docs/object-versioning] is
      # enabled for the bucket. (+Boolean+)
      def versioning= new_versioning
        patch_gapi! versioning: new_versioning
      end

      ##
      # The index page returned from a static website served from the bucket
      # when a site visitor requests the top level directory. For more
      # information, see {How to Host a Static Website
      # }[https://cloud.google.com/storage/docs/website-configuration#step4].
      def website_main
        @gapi["website"]["mainPageSuffix"] if @gapi["website"]
      end

      ##
      # Updates the index page returned from a static website served from the
      # bucket when a site visitor requests the top level directory. For more
      # information, see {How to Host a Static Website
      # }[https://cloud.google.com/storage/docs/website-configuration#step4].
      # (+String+)
      def website_main= website_main
        patch_gapi! website_main: website_main
      end

      ##
      # The page returned from a static website served from the bucket when a
      # site visitor requests a resource that does not exist. For more
      # information, see {How to Host a Static Website
      # }[https://cloud.google.com/storage/docs/website-configuration#step4].
      def website_404
        @gapi["website"]["notFoundPage"] if @gapi["website"]
      end

      ##
      # Updates the page returned from a static website served from the bucket
      # when a site visitor requests a resource that does not exist. For more
      # information, see {How to Host a Static Website
      # }[https://cloud.google.com/storage/docs/website-configuration#step4].
      # (+String+)
      def website_404= website_404
        patch_gapi! website_404: website_404
      end

      ##
      # Updates the bucket with changes made in the given block in a single
      # PATCH request. The following attributes may be set: #cors=,
      # #logging_bucket=, #logging_prefix=, #versioning=, #website_main=, and
      # #website_404=. In addition, the #cors configuration accessible in the
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
      #   bucket.update do |b|
      #     b.website_main = "index.html"
      #     b.website_404 = "not_found.html"
      #     b.cors[0]["method"] = ["GET","POST","DELETE"]
      #     b.cors[1]["responseHeader"] << "X-Another-Custom-Header"
      #   end
      #
      # New CORS rules can also be added in a nested block. See Bucket::Cors for
      # details.
      #
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
        updater = Updater.new @gapi["cors"]
        yield updater
        patch_gapi! updater.updates unless updater.updates.empty?
      end

      ##
      # Permanently deletes the bucket.
      # The bucket must be empty before it can be deleted.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:retries]</code>::
      #   The number of times the API call should be retried.
      #   Default is Gcloud::Backoff.retries. (+Integer+)
      #
      # === Returns
      #
      # +true+ if the bucket was deleted.
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #   bucket.delete
      #
      # The API call to delete the bucket may be retried under certain
      # conditions. See Gcloud::Backoff to control this behavior, or
      # specify the wanted behavior in the call:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #   bucket.delete retries: 5
      #
      def delete options = {}
        ensure_connection!
        resp = connection.delete_bucket name, options
        if resp.success?
          true
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Retrieves a list of files matching the criteria.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:prefix]</code>::
      #   Filter results to files whose names begin with this prefix.
      #   (+String+)
      # <code>options[:token]</code>::
      #   A previously-returned page token representing part of the larger set
      #   of results to view. (+String+)
      # <code>options[:max]</code>::
      #   Maximum number of items plus prefixes to return. As duplicate prefixes
      #   are omitted, fewer total results may be returned than requested.
      #   The default value of this parameter is 1,000 items. (+Integer+)
      # <code>options[:versions]</code>::
      #   If +true+, lists all versions of an object as distinct results.
      #   The default is +false+. For more information, see
      #   {Object Versioning
      #   }[https://cloud.google.com/storage/docs/object-versioning].
      #   (+Boolean+)
      # <code>options[:max]</code>::
      #   Maximum number of buckets to return. (+Integer+)
      #
      # === Returns
      #
      # Array of Gcloud::Storage::File (See Gcloud::Storage::File::List)
      #
      # === Examples
      #
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
      # If you have a significant number of files, you may need to paginate
      # through them: (See File::List#token)
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #
      #   all_files = []
      #   tmp_files = bucket.files
      #   while tmp_files.any? do
      #     tmp_files.each do |file|
      #       all_files << file
      #     end
      #     # break loop if no more buckets available
      #     break if tmp_files.token.nil?
      #     # get the next group of files
      #     tmp_files = bucket.files token: tmp_files.token
      #   end
      #
      def files options = {}
        ensure_connection!
        resp = connection.list_files name, options
        if resp.success?
          File::List.from_response resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :find_files, :files

      ##
      # Retrieves a file matching the path.
      #
      # === Parameters
      #
      # +path+::
      #   Name (path) of the file. (+String+)
      #
      # === Returns
      #
      # Gcloud::Storage::File or nil if file does not exist
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
      #   puts file.name
      #
      def file path, options = {}
        ensure_connection!
        resp = connection.get_file name, path, options
        if resp.success?
          File.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :find_file, :file

      ##
      # Create a new File object by providing a path to a local file to upload
      # and the path to store it with in the bucket.
      #
      # === Parameters
      #
      # +file+::
      #   Path of the file on the filesystem to upload. (+String+)
      # +path+::
      #   Path to store the file in Google Cloud Storage. (+String+)
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:acl]</code>::
      #   A predefined set of access controls to apply to this file.
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
      # <code>options[:cache_control]</code>::
      #   The {Cache-Control}[https://tools.ietf.org/html/rfc7234#section-5.2]
      #   response header to be returned when the file is downloaded. (+String+)
      # <code>options[:content_disposition]</code>::
      #   The {Content-Disposition}[https://tools.ietf.org/html/rfc6266]
      #   response header to be returned when the file is downloaded. (+String+)
      # <code>options[:content_encoding]</code>::
      #   The {Content-Encoding
      #   }[https://tools.ietf.org/html/rfc7231#section-3.1.2.2] response header
      #   to be returned when the file is downloaded. (+String+)
      # <code>options[:content_language]</code>::
      #   The {Content-Language}[http://tools.ietf.org/html/bcp47] response
      #   header to be returned when the file is downloaded. (+String+)
      # <code>options[:content_type]</code>::
      #   The {Content-Type}[https://tools.ietf.org/html/rfc2616#section-14.17]
      #   response header to be returned when the file is downloaded. (+String+)
      # <code>options[:chunk_size]</code>::
      #   The number of bytes per chunk in a resumable upload. Must be divisible
      #   by 256KB. If it is not divisible by 265KB then it will be lowered to
      #   the nearest acceptable value. (+Integer+)
      # <code>options[:crc32c]</code>::
      #   The CRC32c checksum of the file data, as described in
      #   {RFC 4960, Appendix B}[http://tools.ietf.org/html/rfc4960#appendix-B].
      #   If provided, Cloud Storage will only create the file if the value
      #   matches the value calculated by the service. See
      #   {Validation}[https://cloud.google.com/storage/docs/hashes-etags]
      #   for more information. (+String+)
      # <code>options[:md5]</code>::
      #   The MD5 hash of the file data. If provided, Cloud Storage will only
      #   create the file if the value matches the value calculated by the
      #   service. See
      #   {Validation}[https://cloud.google.com/storage/docs/hashes-etags]
      #   for more information. (+String+)
      # <code>options[:metadata]</code>::
      #   A hash of custom, user-provided web-safe keys and arbitrary string
      #   values that will returned with requests for the file as "x-goog-meta-"
      #   response headers. (+Hash+)
      #
      # === Returns
      #
      # Gcloud::Storage::File
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
      #   bucket.create_file "path/to/local.file.ext"
      #
      # Additionally, a destination path can be specified.
      #
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
      # A +chunk_size+ value can be provided in the options to be used
      # in resumable uploads. This value is the number of bytes per
      # chunk and must be divisible by 256KB. If it is not divisible
      # by 265KB then it will be lowered to the nearest acceptable
      # value.
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #
      #   bucket.create_file "path/to/local.file.ext",
      #                      "destination/path/file.ext",
      #                      chunk_size: 1024*1024 # 1 MB chunk
      #
      # ==== Troubleshooting large uploads
      #
      # You may encounter errors while attempting to upload large files. Below
      # are a couple of common cases and their solutions.
      #
      # ===== Handling memory errors
      #
      # If you encounter a memory error such as +NoMemoryError+, try performing
      # a resumable upload and setting the +chunk_size+ option to a value that
      # works for your environment, as explained in the final example above.
      #
      # ===== Handling broken pipe errors
      #
      # To avoid broken pipe (+Errno::EPIPE+) errors when uploading, add the
      # {httpclient}[https://rubygems.org/gems/httpclient] gem to your project,
      # and the configuration shown below. These lines must execute after you
      # require gcloud but before you make your first gcloud connection. The
      # first statement configures {Faraday}[https://rubygems.org/gems/faraday]
      # to use httpclient. The second statement, which should only be added if
      # you are using a version of Faraday at or above 0.9.2, is a workaround
      # for {this gzip
      # issue}[https://github.com/GoogleCloudPlatform/gcloud-ruby/issues/367].
      #
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
      def create_file file, path = nil, options = {}
        ensure_connection!
        ensure_file_exists! file
        options[:acl] = File::Acl.predefined_rule_for options[:acl]
        resumable = resumable_upload?(file)
        resp = @connection.upload_file resumable, name, file, path, options

        if resp.success?
          File.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :upload_file, :create_file
      alias_method :new_file, :create_file

      ##
      # The Bucket::Acl instance used to control access to the bucket.
      #
      # A bucket has owners, writers, and readers. Permissions can be granted to
      # an individual user's email address, a group's email address, as well as
      # many predefined lists. See the
      # {Access Control guide
      # }[https://cloud.google.com/storage/docs/access-control]
      # for more.
      #
      # === Examples
      #
      # Access to a bucket can be granted to a user by appending +"user-"+ to
      # the email address:
      #
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
      # Access to a bucket can be granted to a group by appending +"group-"+ to
      # the email address:
      #
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
      # Access to a bucket can also be granted to a predefined list of
      # permissions:
      #
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
      # as well as many predefined lists. See the
      # {Access Control guide
      # }[https://cloud.google.com/storage/docs/access-control]
      # for more.
      #
      # === Examples
      #
      # Access to a bucket's files can be granted to a user by appending
      # +"user-"+ to the email address:
      #
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
      # Access to a bucket's files can be granted to a group by appending
      # +"group-"+ to the email address:
      #
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
      # Access to a bucket's files can also be granted to a predefined list of
      # permissions:
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   storage = gcloud.storage
      #
      #   bucket = storage.bucket "my-todo-app"
      #
      #   bucket.default_acl.public!
      def default_acl
        @default_acl ||= Bucket::DefaultAcl.new self
      end

      ##
      # Reloads the bucket with current data from the Storage service.
      def reload!
        ensure_connection!
        resp = connection.get_bucket name
        if resp.success?
          @gapi = resp.data
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :refresh!, :reload!

      ##
      # New Bucket from a Google API Client object.
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
        resp = connection.patch_bucket name, options
        if resp.success?
          @gapi = resp.data
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Raise an error if the file is not found.
      def ensure_file_exists! file
        return if ::File.file? file
        fail ArgumentError, "cannot find file #{file}"
      end

      ##
      # Determines if a resumable upload should be used.
      def resumable_upload? file #:nodoc:
        ::File.size?(file).to_i > Upload.resumable_threshold
      end

      ##
      # Given nil, empty array, a gapi array of hashes, or any value, returns a
      # deeply dup'd and frozen array of simple hashes or values (not gapi
      # objects.)
      def deep_dup_and_freeze array
        return [].freeze if array.nil? || array.empty?
        array = Array(array.dup)
        array = array.map do |h|
          h = h.to_hash if h.respond_to? :to_hash
          h.dup.freeze
        end
        array.freeze
      end

      ##
      # Yielded to a block to accumulate changes for a patch request.
      class Updater
        attr_reader :updates
        ##
        # Create an Updater object.
        def initialize cors
          @cors = cors ? Array(cors.dup) : []
          @cors = @cors.map { |x| x.to_hash if x.respond_to? :to_hash }
          @updates = {}
        end

        ATTRS = [:cors, :logging_bucket, :logging_prefix, :versioning,
                 :website_main, :website_404]

        ATTRS.each do |attr|
          define_method "#{attr}=" do |arg|
            updates[attr] = arg
          end
        end

        ##
        # Return CORS for mutation. Also adds CORS to @updates so that it
        # is included in the patch request.
        def cors
          updates[:cors] ||= @cors
          if block_given?
            cors_builder = Bucket::Cors.new updates[:cors]
            yield cors_builder
            updates[:cors] = cors_builder if cors_builder.changed?
          end
          updates[:cors]
        end
      end
    end
  end
end
