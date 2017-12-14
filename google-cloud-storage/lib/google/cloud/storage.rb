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
    #   project_id: "my-project",
    #   credentials: "/path/to/keyfile.json"
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
    # A {Google::Cloud::Storage::Bucket} instance is a container for your data.
    # There is no limit on the number of buckets that you can create in a
    # project. You can use buckets to organize and control access to your data.
    # For more information, see [Working with
    # Buckets](https://cloud.google.com/storage/docs/creating-buckets).
    #
    # Each bucket has a globally unique name, which is how they are retrieved:
    # (See {Google::Cloud::Storage::Project#bucket})
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
    # If you have a significant number of buckets, you may need to fetch them
    # in multiple service requests.
    #
    # Iterating over each bucket, potentially with multiple API calls, by
    # invoking `all` with a block:
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # buckets = storage.buckets
    # buckets.all do |bucket|
    #   puts bucket.name
    # end
    # ```
    #
    # Limiting the number of API calls made:
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # buckets = storage.buckets
    # buckets.all(request_limit: 10) do |bucket|
    #   puts bucket.name
    # end
    # ```
    #
    # See {Google::Cloud::Storage::Bucket::List} for details.
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
    # A {Google::Cloud::Storage::File} instance is an individual data object
    # that you store in Google Cloud Storage. Files contain the data stored as
    # well as metadata describing the data. Files belong to a bucket and cannot
    # be shared among buckets. There is no limit on the number of files that
    # you can create in a bucket. For more information, see [Working with
    # Objects](https://cloud.google.com/storage/docs/object-basics).
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
    # If you have a significant number of files, you may need to fetch them
    # in multiple service requests.
    #
    # Iterating over each file, potentially with multiple API calls, by
    # invoking `all` with a block:
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    # bucket = storage.bucket "my-todo-app"
    #
    # files = storage.files
    # files.all do |file|
    #   puts file.name
    # end
    # ```
    #
    # Limiting the number of API calls made:
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # files = storage.files
    # files.all(request_limit: 10) do |file|
    #   puts bucket.name
    # end
    # ```
    #
    # See {Google::Cloud::Storage::File::List} for details.
    #
    # ## Creating a File
    #
    # A new file can be uploaded by specifying the location of a file on the
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
    # Files can also be created from an in-memory StringIO object:
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.bucket "my-todo-app"
    # bucket.create_file StringIO.new("Hello world!"), "hello-world.txt"
    # ```
    #
    # ### Customer-supplied encryption keys
    #
    # By default, Google Cloud Storage manages server-side encryption keys on
    # your behalf. However, a [customer-supplied encryption
    # key](https://cloud.google.com/storage/docs/encryption#customer-supplied)
    # can be provided with the `encryption_key` option. If given, the same key
    # must be provided to subsequently download or copy the file. If you use
    # customer-supplied encryption keys, you must securely manage your keys and
    # ensure that they are not lost. Also, please note that file metadata is not
    # encrypted, with the exception of the CRC32C checksum and MD5 hash. The
    # names of files and buckets are also not encrypted, and you can read or
    # update the metadata of an encrypted file without providing the encryption
    # key.
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    # bucket = storage.bucket "my-todo-app"
    #
    # # Key generation shown for example purposes only. Write your own.
    # cipher = OpenSSL::Cipher.new "aes-256-cfb"
    # cipher.encrypt
    # key = cipher.random_key
    #
    # bucket.create_file "/var/todo-app/avatars/heidi/400x400.png",
    #                    "avatars/heidi/400x400.png",
    #                    encryption_key: key
    #
    # # Store your key and hash securely for later use.
    # file = bucket.file "avatars/heidi/400x400.png",
    #                    encryption_key: key
    # ```
    #
    # Use {Google::Cloud::Storage::File#rotate} to rotate customer-supplied
    # encryption keys.
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    # bucket = storage.bucket "my-todo-app"
    #
    # # Old key was stored securely for later use.
    # old_key = "y\x03\"\x0E\xB6\xD3\x9B\x0E\xAB*\x19\xFAv\xDEY\xBEI..."
    #
    # file = bucket.file "path/to/my-file.ext", encryption_key: old_key
    #
    # # Key generation shown for example purposes only. Write your own.
    # cipher = OpenSSL::Cipher.new "aes-256-cfb"
    # cipher.encrypt
    # new_key = cipher.random_key
    #
    # file.rotate encryption_key: old_key, new_encryption_key: new_key
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
    # Files can also be downloaded to an in-memory StringIO object:
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.bucket "my-todo-app"
    # file = bucket.file "hello-world.txt"
    #
    # downloaded = file.download
    # downloaded.rewind
    # downloaded.read #=> "Hello world!"
    # ```
    #
    # Download a public file with an anonymous, unauthenticated client. Use
    # `skip_lookup` to avoid errors retrieving non-public bucket and file
    # metadata.
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.anonymous
    #
    # bucket = storage.bucket "public-bucket", skip_lookup: true
    # file = bucket.file "path/to/public-file.ext", skip_lookup: true
    #
    # downloaded = file.download
    # downloaded.rewind
    # downloaded.read #=> "Hello world!"
    # ```
    #
    # ## Creating and downloading gzip-encoded files
    #
    # When uploading a gzip-compressed file, you should pass
    # `content_encoding: "gzip"` if you want the file to be eligible for
    # [decompressive transcoding](https://cloud.google.com/storage/docs/transcoding)
    # when it is later downloaded. In addition, giving the gzip-compressed file
    # a name containing the original file extension (for example, `.txt`) will
    # ensure that the file's `Content-Type` metadata is set correctly. (You can
    # also set the file's `Content-Type` metadata explicitly with the
    # `content_type` option.)
    #
    # ```ruby
    # require "zlib"
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # gz = StringIO.new ""
    # z = Zlib::GzipWriter.new gz
    # z.write "Hello world!"
    # z.close
    # data = StringIO.new gz.string
    #
    # bucket = storage.bucket "my-bucket"
    #
    # bucket.create_file data, "path/to/gzipped.txt",
    #                    content_encoding: "gzip"
    #
    # file = bucket.file "path/to/gzipped.txt"
    #
    # # The downloaded data is decompressed by default.
    # file.download "path/to/downloaded/hello.txt"
    #
    # # The downloaded data remains compressed with skip_decompress.
    # file.download "path/to/downloaded/gzipped.txt",
    #               skip_decompress: true
    # ```
    #
    # ## Using Signed URLs
    #
    # Access without authentication can be granted to a file for a specified
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
    # ## Assigning payment to the requester
    #
    # The requester pays feature enables the owner of a bucket to indicate that
    # a client accessing the bucket or a file it contains must assume the
    # transit costs related to the access.
    #
    # Assign transit costs for bucket and file operations to requesting clients
    # with the `requester_pays` flag:
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.bucket "my-bucket"
    #
    # bucket.requester_pays = true # API call
    # # Clients must now provide `user_project` option when calling
    # # Project#bucket to access this bucket.
    # ```
    #
    # Once the `requester_pays` flag is enabled for a bucket, a client
    # attempting to access the bucket and its files must provide the
    # `user_project` option to {Project#bucket}. If the argument given is
    # `true`, transit costs for operations on the requested bucket or a file it
    # contains will be billed to the current project for the client. (See
    # {Project#project} for the ID of the current project.)
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.bucket "other-project-bucket", user_project: true
    #
    # files = bucket.files # Billed to current project
    # ```
    #
    # If the argument is a project ID string, and the indicated project is
    # authorized for the currently authenticated service account, transit costs
    # will be billed to the indicated project.
    #
    # ```ruby
    # require "google/cloud/storage"
    #
    # storage = Google::Cloud::Storage.new
    #
    # bucket = storage.bucket "other-project-bucket",
    #                         user_project: "my-other-project"
    # files = bucket.files # Billed to "my-other-project"
    # ```
    #
    # ## Configuring Pub/Sub notification subscriptions
    #
    # You can configure notifications to send Google Cloud Pub/Sub messages
    # about changes to files in your buckets. For example, you can track files
    # that are created and deleted in your bucket. Each notification contains
    # information describing both the event that triggered it and the file that
    # changed.
    #
    # You can send notifications to any Cloud Pub/Sub topic in any project for
    # which your service account has sufficient permissions. As shown below, you
    # need to explicitly grant permission to your service account to enable
    # Google Cloud Storage to publish on behalf of your account. (Even if your
    # current project created and owns the topic.)
    #
    # ```ruby
    # require "google/cloud/pubsub"
    # require "google/cloud/storage"
    #
    # pubsub = Google::Cloud::Pubsub.new
    # topic = pubsub.create_topic "my-topic"
    # topic.policy do |p|
    #   p.add "roles/pubsub.publisher",
    #         "serviceAccount:my-project" \
    #         "@gs-project-accounts.iam.gserviceaccount.com"
    # end
    #
    # storage = Google::Cloud::Storage.new
    # bucket = storage.bucket "my-bucket"
    #
    # notification = bucket.create_notification topic.name
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
      # @param [String] project_id Project identifier for the Storage service
      #   you are connecting to. If not present, the default project for the
      #   credentials is used.
      # @param [String, Hash, Google::Auth::Credentials] credentials The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Storage::Credentials})
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
      # @param [String] project Alias for the `project_id` argument. Deprecated.
      # @param [String] keyfile Alias for the `credentials` argument.
      #   Deprecated.
      #
      # @return [Google::Cloud::Storage::Project]
      #
      # @example
      #   require "google/cloud/storage"
      #
      #   storage = Google::Cloud::Storage.new(
      #     project_id: "my-project",
      #     credentials: "/path/to/keyfile.json"
      #   )
      #
      #   bucket = storage.bucket "my-bucket"
      #   file = bucket.file "path/to/my-file.ext"
      #
      def self.new project_id: nil, credentials: nil, scope: nil, retries: nil,
                   timeout: nil, project: nil, keyfile: nil
        project_id ||= (project || Storage::Project.default_project_id)
        project_id = project_id.to_s # Always cast to a string
        fail ArgumentError, "project_id is missing" if project_id.empty?

        credentials ||= (keyfile || Storage::Credentials.default(scope: scope))
        unless credentials.is_a? Google::Auth::Credentials
          credentials = Storage::Credentials.new credentials, scope: scope
        end

        Storage::Project.new(
          Storage::Service.new(
            project_id, credentials, retries: retries, timeout: timeout))
      end

      ##
      # Creates an unauthenticated, anonymous client for retrieving public data
      # from the Storage service. Each call creates a new connection.
      #
      # @param [Integer] retries Number of times to retry requests on server
      #   error. The default value is `3`. Optional.
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      #
      # @return [Google::Cloud::Storage::Project]
      #
      # @example Use `skip_lookup` to avoid retrieving non-public metadata:
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
      def self.anonymous retries: nil, timeout: nil
        Storage::Project.new(
          Storage::Service.new(nil, nil, retries: retries, timeout: timeout)
        )
      end
    end
  end
end
