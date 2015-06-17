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
require "gcloud/storage/file"

module Gcloud
  module Storage
    ##
    # = Bucket
    #
    # Represents a Storage bucket. Belongs to a Project and has many Files.
    #
    #   require "glcoud/storage"
    #
    #   storage = Gcloud.storage
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
      # The URI of this bucket.
      def url
        @gapi["selfLink"]
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
      # Creation time of the bucket.
      def created_at
        @gapi["timeCreated"]
      end

      ##
      # Permenently deletes the bucket.
      # The bucket must be empty before it can be deleted.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavor. (+Hash+)
      # +options [:retries]+::
      #   The number of times the API call should be retried.
      #   Default is Gcloud::Backoff.retries. (+Integer+)
      #
      # === Returns
      #
      # +true+ if the bucket was deleted.
      #
      # === Examples
      #
      #   require "gcloud/storage"
      #
      #   storage = Gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #   bucket.delete
      #
      # The API call to delete the bucket may be retried under certain
      # conditions. See Gcloud::Backoff to control this behavior, or
      # specify the wanted behavior in the call:
      #
      #   require "gcloud/storage"
      #
      #   storage = Gcloud.storage
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
          ApiError.from_response(resp)
        end
      end

      ##
      # Retrieves a list of files matching the criteria.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavor. (+Hash+)
      # +options [:prefix]+::
      #   Filter results to files whose names begin with this prefix.
      #   (+String+)
      # +options [:token]+::
      #   A previously-returned page token representing part of the larger set
      #   of results to view. (+String+)
      # +options [:max]+::
      #   Maximum number of items plus prefixes to return. As duplicate prefixes
      #   are omitted, fewer total results may be returned than requested.
      #   The default value of this parameter is 1,000 items. (+Integer+)
      # +options [:versions]+::
      #   If +true+, lists all versions of an object as distinct results.
      #   The default is +false+. For more information, see
      #   {Object Versioning
      #   }[https://cloud.google.com/storage/docs/object-versioning].
      #   (+Boolean+)
      # +options [:max]+::
      #   Maximum number of buckets to return. (+Integer+)
      #
      # === Returns
      #
      # Array of Gcloud::Datastore::File (Gcloud::Datastore::File::List)
      #
      # === Examples
      #
      #   require "gcloud/storage"
      #
      #   storage = Gcloud.storage
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
      #   require "gcloud/storage"
      #
      #   storage = Gcloud.storage
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
          File::List.from_resp resp, connection
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
      # Gcloud::Datastore::File or nil if file does not exist
      #
      # === Example
      #
      #   require "gcloud/storage"
      #
      #   storage = Gcloud.storage
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
      #   An optional Hash for controlling additional behavor. (+Hash+)
      # +options [:acl]+::
      #   A predefined set of access controls to apply to this file.
      #   (+String+)
      #
      #   Acceptable values are:
      #   * +auth+, +auth_read+, +authenticated+, +authenticated_read+,
      #     +authenticatedRead+:: File owner gets OWNER access, and
      #     allAuthenticatedUsers get READER access.
      #   * +owner_full+, +bucketOwnerFullControl+:: File owner gets OWNER
      #     access, and project team owners get OWNER access.
      #   * +owner_read+, +bucketOwnerRead+:: File owner gets OWNER access, and
      #     project team owners get READER access.
      #   * +private+:: File owner gets OWNER access.
      #   * +project_private+, +projectPrivate+:: File owner gets OWNER access,
      #     and project team members get access according to their roles.
      #   * +public+, +public_read+, +publicRead+:: File owner gets OWNER
      #     access, and allUsers get READER access.
      #
      # === Returns
      #
      # Gcloud::Datastore::File
      #
      # === Examples
      #
      #   require "gcloud/storage"
      #
      #   storage = Gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #
      #   bucket.create_file "path/to/local.file.ext"
      #
      # Additionally, a destination path can be specified.
      #
      #   require "gcloud/storage"
      #
      #   storage = Gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #
      #   bucket.create_file "path/to/local.file.ext",
      #                      "destination/path/file.ext"
      #
      # A chunk_size value can be provided in the options to be used
      # in resumable uploads. This value is the number of bytes per
      # chunk and must be divisible by 256KB. If it is not divisible
      # by 265KB then it will be lowered to the nearest acceptible
      # value.
      #
      #   require "gcloud/storage"
      #
      #   storage = Gcloud.storage
      #
      #   bucket = storage.bucket "my-bucket"
      #
      #   bucket.create_file "path/to/local.file.ext",
      #                      "destination/path/file.ext",
      #                      chunk_size: 1024*1024 # 1 MB chunk
      #
      def create_file file, path = nil, options = {}
        ensure_connection!
        # TODO: Raise if file doesn't exist
        # ensure_file_exists!
        fail unless ::File.file? file

        options[:acl] = File::Acl.predefined_rule_for options[:acl]

        if resumable_upload? file
          upload_resumable file, path, options[:chunk_size], options
        else
          upload_multipart file, path, options
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
      #   require "gcloud/storage"
      #
      #   storage = Gcloud.storage
      #
      #   bucket = storage.bucket "my-todo-app"
      #
      #   email = "heidi@example.net"
      #   bucket.acl.add_reader "user-#{email}"
      #
      # Access to a bucket can be granted to a group by appending +"group-"+ to
      # the email address:
      #
      #   require "gcloud/storage"
      #
      #   storage = Gcloud.storage
      #
      #   bucket = storage.bucket "my-todo-app"
      #
      #   email = "authors@example.net"
      #   bucket.acl.add_reader "group-#{email}"
      #
      # Access to a bucket can also be granted to a predefined list of
      # permissions:
      #
      #   require "gcloud/storage"
      #
      #   storage = Gcloud.storage
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
      #   require "gcloud/storage"
      #
      #   storage = Gcloud.storage
      #
      #   bucket = storage.bucket "my-todo-app"
      #
      #   email = "heidi@example.net"
      #   bucket.default_acl.add_reader "user-#{email}"
      #
      # Access to a bucket's files can be granted to a group by appending
      # +"group-"+ to the email address:
      #
      #   require "gcloud/storage"
      #
      #   storage = Gcloud.storage
      #
      #   bucket = storage.bucket "my-todo-app"
      #
      #   email = "authors@example.net"
      #   bucket.default_acl.add_reader "group-#{email}"
      #
      # Access to a bucket's files can also be granted to a predefined list of
      # permissions:
      #
      #   require "gcloud/storage"
      #
      #   storage = Gcloud.storage
      #
      #   bucket = storage.bucket "my-todo-app"
      #
      #   bucket.default_acl.public!
      def default_acl
        @default_acl ||= Bucket::DefaultAcl.new self
      end

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

      ##
      # Determines if a resumable upload should be used.
      def resumable_upload? file #:nodoc:
        ::File.size?(file).to_i > Storage.resumable_threshold
      end

      def upload_multipart file, path, options = {}
        resp = @connection.insert_file_multipart name, file, path, options

        if resp.success?
          File.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      def upload_resumable file, path, chunk_size, options = {}
        chunk_size = verify_chunk_size! chunk_size

        resp = @connection.insert_file_resumable name, file,
                                                 path, chunk_size, options

        if resp.success?
          File.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Determines if a chunk_size is valid.
      def verify_chunk_size! chunk_size
        chunk_size = chunk_size.to_i
        chunk_mod = 256 * 1024 # 256KB
        if (chunk_size.to_i % chunk_mod) != 0
          chunk_size = (chunk_size / chunk_mod) * chunk_mod
        end
        return if chunk_size.zero?
        chunk_size
      end
    end
  end
end
