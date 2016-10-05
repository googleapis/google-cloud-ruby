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


require "google-cloud-storage"
require "google/cloud/storage/project"

module Google
  module Cloud
    ##
    # # Google Cloud Storage
    #
    # Google Cloud Storage is an Internet service to store data in Google's
    # cloud. It allows world-wide storage and retrieval of any amount of data
    # and at any time, taking advantage of Google's own reliable and fast
    # networking infrastructure to perform data operations in a cost effective
    # manner.
    #
    # The goal of google-cloud is to provide a API that is comfortable to
    # Rubyists. Authentication is handled by {Google::Cloud#storage}. You can
    # provide the project and credential information to connect to the Storage
    # service, or if you are running on Google Compute Engine this configuration
    # is taken care of for you.
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new(
    #   project: "my-todo-project",
    #   keyfile: "/path/to/keyfile.json"
    # )
    #
    # bucket = storage.bucket "my-bucket"
    # file = bucket.file "path/to/my-file.ext"
    # ```
    #
    # You can learn more about various options for connection on the
    # [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # To learn more about Cloud Storage, read the
    # [Google Cloud Storage Overview
    # ](https://cloud.google.com/storage/docs/overview).
    #
    # ## Retrieving Buckets
    #
    # A Bucket is the container for your data. There is no limit on the number
    # of buckets that you can create in a project. You can use buckets to
    # organize and control access to your data. Each bucket has a unique name,
    # which is how they are retrieved: (See
    # {Google::Cloud::Storage::Project#bucket})
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.bucket "my-todo-app"
    # ```
    #
    # You can also retrieve all buckets on a project: (See
    # {Google::Cloud::Storage::Project#buckets})
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # all_buckets = storage.buckets
    # ```
    #
    # If you have a significant number of buckets, you may need to paginate
    # through them: (See {Google::Cloud::Storage::Bucket::List#token})
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # all_buckets = []
    # tmp_buckets = storage.buckets
    # while tmp_buckets.any? do
    #   tmp_buckets.each do |bucket|
    #     all_buckets << bucket
    #   end
    #   # break loop if no more buckets available
    #   break if tmp_buckets.token.nil?
    #   # get the next group of buckets
    #   tmp_buckets = storage.buckets token: tmp_buckets.token
    # end
    # ```
    #
    # ## Creating a Bucket
    #
    # A unique name is all that is needed to create a new bucket: (See
    # {Google::Cloud::Storage::Project#create_bucket})
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.create_bucket "my-todo-app-attachments"
    # ```
    #
    # ## Retrieving Files
    #
    # A File is an individual pieces of data that you store in Google Cloud
    # Storage. Files contain the data stored as well as metadata describing the
    # data. Files belong to a bucket and cannot be shared among buckets. There
    # is no limit on the number of objects that you can create in a bucket.
    #
    # Files are retrieved by their name, which is the path of the file in the
    # bucket: (See {Google::Cloud::Storage::Bucket#file})
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.bucket "my-todo-app"
    # file = bucket.file "avatars/heidi/400x400.png"
    # ```
    #
    # You can also retrieve all files in a bucket: (See Bucket#files)
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.bucket "my-todo-app"
    # all_files = bucket.files
    # ```
    #
    # Or you can retrieve all files in a specified path:
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.bucket "my-todo-app"
    # avatar_files = bucket.files prefix: "avatars/"
    # ```
    #
    # If you have a significant number of files, you may need to paginate
    # through them: (See {Google::Cloud::Storage::File::List#token})
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.bucket "my-todo-app"
    #
    # all_files = []
    # tmp_files = bucket.files
    # while tmp_files.any? do
    #   tmp_files.each do |file|
    #     all_files << file
    #   end
    #   # break loop if no more files available
    #   break if tmp_files.token.nil?
    #   # get the next group of files
    #   tmp_files = bucket.files token: tmp_files.token
    # end
    # ```
    #
    # ## Creating a File
    #
    # A new File can be uploaded by specifying the location of a file on the
    # local file system, and the name/path that the file should be stored in the
    # bucket. (See {Google::Cloud::Storage::Bucket#create_file})
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.bucket "my-todo-app"
    # bucket.create_file "/var/todo-app/avatars/heidi/400x400.png",
    #                    "avatars/heidi/400x400.png"
    # ```
    #
    # ### Customer-supplied encryption keys
    #
    # By default, Google Cloud Storage manages server-side encryption keys on
    # your behalf. However, a [customer-supplied encryption
    # key](https://cloud.google.com/storage/docs/encryption#customer-supplied)
    # can be provided with the `encryption_key` and `encryption_key_sha256`
    # options. If given, the same key and SHA256 hash also must be provided to
    # subsequently download or copy the file. If you use customer-supplied
    # encryption keys, you must securely manage your keys and ensure that they
    # are not lost. Also, please note that file metadata is not encrypted, with
    # the exception of the CRC32C checksum and MD5 hash. The names of files and
    # buckets are also not encrypted, and you can read or update the metadata of
    # an encrypted file without providing the encryption key.
    #
    # ```ruby
    # require "google/cloud/storage"
    # require "digest/sha2"
    #
    # storage = Google::Cloud::Storage.new
    # bucket = storage.bucket "my-todo-app"
    #
    # # Key generation shown for example purposes only. Write your own.
    # cipher = OpenSSL::Cipher.new "aes-256-cfb"
    # cipher.encrypt
    # key = cipher.random_key
    # key_hash = Digest::SHA256.digest key
    #
    # bucket.create_file "/var/todo-app/avatars/heidi/400x400.png",
    #                    "avatars/heidi/400x400.png",
    #                    encryption_key: key,
    #                    encryption_key_sha256: key_hash
    #
    # # Store your key and hash securely for later use.
    # file = bucket.file "avatars/heidi/400x400.png",
    #                    encryption_key: key,
    #                    encryption_key_sha256: key_hash
    # ```
    #
    # ## Downloading a File
    #
    # Files can be downloaded to the local file system. (See
    # {Google::Cloud::Storage::File#download})
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.bucket "my-todo-app"
    # file = bucket.file "avatars/heidi/400x400.png"
    # file.download "/var/todo-app/avatars/heidi/400x400.png"
    # ```
    #
    # ## Using Signed URLs
    #
    # Access without authentication can be granted to a File for a specified
    # period of time. This URL uses a cryptographic signature of your
    # credentials to access the file. (See
    # {Google::Cloud::Storage::File#signed_url})
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.bucket "my-todo-app"
    # file = bucket.file "avatars/heidi/400x400.png"
    # shared_url = file.signed_url method: "GET",
    #                              expires: 300 # 5 minutes from now
    # ```
    #
    # ## Controlling Access to a Bucket
    #
    # Access to a bucket is controlled with
    # {Google::Cloud::Storage::Bucket#acl}. A bucket has owners, writers, and
    # readers. Permissions can be granted to an individual user's email address,
    # a group's email address, as well as many predefined lists. See the [Access
    # Control guide](https://cloud.google.com/storage/docs/access-control) for
    # more.
    #
    # Access to a bucket can be granted to a user by appending `"user-"` to the
    # email address:
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.bucket "my-todo-app"
    #
    # email = "heidi@example.net"
    # bucket.acl.add_reader "user-#{email}"
    # ```
    #
    # Access to a bucket can be granted to a group by appending `"group-"` to
    # the email address:
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.bucket "my-todo-app"
    #
    # email = "authors@example.net"
    # bucket.acl.add_reader "group-#{email}"
    # ```
    #
    # Access to a bucket can also be granted to a predefined list of
    # permissions:
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.bucket "my-todo-app"
    #
    # bucket.acl.public!
    # ```
    #
    # ## Controlling Access to a File
    #
    # Access to a file is controlled in two ways, either by the setting the
    # default permissions to all files in a bucket with
    # {Google::Cloud::Storage::Bucket#default_acl}, or by setting permissions to
    # an individual file with {Google::Cloud::Storage::File#acl}.
    #
    # Access to a file can be granted to a user by appending `"user-"` to the
    # email address:
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.bucket "my-todo-app"
    # file = bucket.file "avatars/heidi/400x400.png"
    #
    # email = "heidi@example.net"
    # file.acl.add_reader "user-#{email}"
    # ```
    #
    # Access to a file can be granted to a group by appending `"group-"` to the
    # email address:
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.bucket "my-todo-app"
    # file = bucket.file "avatars/heidi/400x400.png"
    #
    # email = "authors@example.net"
    # file.acl.add_reader "group-#{email}"
    # ```
    #
    # Access to a file can also be granted to a predefined list of permissions:
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.bucket "my-todo-app"
    # file = bucket.file "avatars/heidi/400x400.png"
    #
    # file.acl.public!
    # ```
    #
    # ## Configuring retries and timeout
    #
    # You can configure how many times API requests may be automatically
    # retried. When an API request fails, the response will be inspected to see
    # if the request meets criteria indicating that it may succeed on retry,
    # such as `500` and `503` status codes or a specific internal error code
    # such as `rateLimitExceeded`. If it meets the criteria, the request will be
    # retried after a delay. If another error occurs, the delay will be
    # increased before a subsequent attempt, until the `retries` limit is
    # reached.
    #
    # You can also set the request `timeout` value in seconds.
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new retries: 10, timeout: 120
    # ```
    #
    # See the [Storage status and error
    # codes](https://cloud.google.com/storage/docs/json_api/v1/status-codes)
    # for a list of error conditions.
    #
    module Storage
      ##
      # Creates a new object for connecting to the Storage service.
      # Each call creates a new connection.
      #
      # For more information on connecting to Google Cloud see the
      # [Authentication
      # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
      #
      # @param [String] project Project identifier for the Storage service you
      #   are connecting to.
      # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud. If
      #   file path the file must be readable.
      # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      #   See [Using OAuth 2.0 to Access Google
      #   APIs](https://developers.google.com/identity/protocols/OAuth2).
      #
      #   The default scope is:
      #
      #   * `https://www.googleapis.com/auth/devstorage.full_control`
      # @param [Integer] retries Number of times to retry requests on server
      #   error. The default value is `3`. Optional.
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      #
      # @return [Google::Cloud::Storage::Project]
      #
      # @example
      #   require "google/cloud/storage"
      #
      #   storage = Google::Cloud::Storage.new(
      #     project: "my-todo-project",
      #     keyfile: "/path/to/keyfile.json"
      #   )
      #
      #   bucket = storage.bucket "my-bucket"
      #   file = bucket.file "path/to/my-file.ext"
      #
      def self.new project: nil, keyfile: nil, scope: nil, retries: nil,
                   timeout: nil
        project ||= Google::Cloud::Storage::Project.default_project
        project = project.to_s # Always cast to a string
        fail ArgumentError, "project is missing" if project.empty?

        if keyfile.nil?
          credentials = Google::Cloud::Storage::Credentials.default scope: scope
        else
          credentials = Google::Cloud::Storage::Credentials.new(
            keyfile, scope: scope)
        end

        Google::Cloud::Storage::Project.new(
          Google::Cloud::Storage::Service.new(
            project, credentials, retries: retries, timeout: timeout))
      end
    end
  end
end
