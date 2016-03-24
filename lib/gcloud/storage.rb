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


require "gcloud"
require "gcloud/storage/project"

module Gcloud
  ##
  # Creates a new object for connecting to the Storage service.
  # Each call creates a new connection.
  #
  # For more information on connecting to Google Cloud see the <a
  # ui-sref="docs.guides({ guideId: 'authentication' })"
  # href="AUTHENTICATION">Authentication Guide</a>.
  #
  # @param [String] project Project identifier for the Storage service you are
  #   connecting to.
  # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud. If file
  #   path the file must be readable.
  # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
  #   set of resources and operations that the connection can access. See [Using
  #   OAuth 2.0 to Access Google
  #   APIs](https://developers.google.com/identity/protocols/OAuth2).
  #
  #   The default scope is:
  #
  #   * `https://www.googleapis.com/auth/devstorage.full_control`
  #
  # @return [Gcloud::Storage::Project]
  #
  # @example
  #   require "gcloud/storage"
  #
  #   storage = Gcloud.storage "my-todo-project",
  #                            "/path/to/keyfile.json"
  #
  #   bucket = storage.bucket "my-bucket"
  #   file = bucket.file "path/to/my-file.ext"
  #
  def self.storage project = nil, keyfile = nil, scope: nil
    project ||= Gcloud::Storage::Project.default_project
    if keyfile.nil?
      credentials = Gcloud::Storage::Credentials.default scope: scope
    else
      credentials = Gcloud::Storage::Credentials.new keyfile, scope: scope
    end
    Gcloud::Storage::Project.new project, credentials
  end

  ##
  # # Google Cloud Storage
  #
  # Google Cloud Storage is an Internet service to store data in Google's cloud.
  # It allows world-wide storage and retrieval of any amount of data and at any
  # time, taking advantage of Google's own reliable and fast networking
  # infrastructure to perform data operations in a cost effective manner.
  #
  # Gcloud's goal is to provide a API that is familiar and comfortable to
  # Rubyists. Authentication is handled by {Gcloud#storage}. You can provide the
  # project and credential information to connect to the Storage service, or if
  # you are running on Google Compute Engine this configuration is taken care
  # of for you.
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new "my-todo-project",
  #                     "/path/to/keyfile.json"
  # storage = gcloud.storage
  #
  # bucket = storage.bucket "my-bucket"
  # file = bucket.file "path/to/my-file.ext"
  # ```
  #
  # You can learn more about various options for connection on the <a
  # ui-sref="docs.guides({ guideId: 'authentication' })"
  # href="../AUTHENTICATION">Authentication Guide</a>.
  #
  # To learn more about Cloud Storage, read the
  # [Google Cloud Storage Overview
  # ](https://cloud.google.com/storage/docs/overview).
  #
  # ## Retrieving Buckets
  #
  # A Bucket is the container for your data. There is no limit on the number of
  # buckets that you can create in a project. You can use buckets to organize
  # and control access to your data. Each bucket has a unique name, which is how
  # they are retrieved: (See {Project#bucket})
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # storage = gcloud.storage
  #
  # bucket = storage.bucket "my-todo-app"
  # ```
  #
  # You can also retrieve all buckets on a project: (See {Project#buckets})
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # storage = gcloud.storage
  #
  # all_buckets = storage.buckets
  # ```
  #
  # If you have a significant number of buckets, you may need to paginate
  # through them: (See {Bucket::List#token})
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # storage = gcloud.storage
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
  # A unique name is all that is needed to create a new bucket:
  # (See {Project#create_bucket})
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # storage = gcloud.storage
  #
  # bucket = storage.create_bucket "my-todo-app-attachments"
  # ```
  #
  # ## Retrieving Files
  #
  # A File is an individual pieces of data that you store in Google Cloud
  # Storage. Files contain the data stored as well as metadata describing the
  # data. Files belong to a bucket and cannot be shared among buckets. There is
  # no limit on the number of objects that you can create in a bucket.
  #
  # Files are retrieved by their name, which is the path of the file in the
  # bucket: (See {Bucket#file})
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # storage = gcloud.storage
  #
  # bucket = storage.bucket "my-todo-app"
  # file = bucket.file "avatars/heidi/400x400.png"
  # ```
  #
  # You can also retrieve all files in a bucket: (See Bucket#files)
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # storage = gcloud.storage
  #
  # bucket = storage.bucket "my-todo-app"
  # all_files = bucket.files
  # ```
  #
  # Or you can retrieve all files in a specified path:
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # storage = gcloud.storage
  #
  # bucket = storage.bucket "my-todo-app"
  # avatar_files = bucket.files prefix: "avatars/"
  # ```
  #
  # If you have a significant number of files, you may need to paginate through
  # them: (See {File::List#token})
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # storage = gcloud.storage
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
  # A new File can be uploaded by specifying the location of a file on the local
  # file system, and the name/path that the file should be stored in the bucket.
  # (See {Bucket#create_file})
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # storage = gcloud.storage
  #
  # bucket = storage.bucket "my-todo-app"
  # bucket.create_file "/var/todo-app/avatars/heidi/400x400.png",
  #                    "avatars/heidi/400x400.png"
  # ```
  #
  # ### A note about large uploads
  #
  # You may encounter a Broken pipe (Errno::EPIPE) error when attempting to
  # upload large files. To avoid this problem, add the
  # [httpclient](https://rubygems.org/gems/httpclient) gem to your project, and
  # the line (or lines) of configuration shown below. These lines must execute
  # after you require gcloud but before you make your first gcloud connection.
  # The first statement configures [Faraday](https://rubygems.org/gems/faraday)
  # to use httpclient. The second statement, which should only be added if you
  # are using a version of Faraday at or above 0.9.2, is a workaround for [this
  # gzip issue](https://github.com/GoogleCloudPlatform/gcloud-ruby/issues/367).
  #
  # ```ruby
  # require "gcloud"
  #
  # # Use httpclient to avoid broken pipe errors with large uploads
  # Faraday.default_adapter = :httpclient
  #
  # # Only add the following statement if using Faraday >= 0.9.2
  # # Override gzip middleware with no-op for httpclient
  # Faraday::Response.register_middleware :gzip =>
  #                                         Faraday::Response::Middleware
  #
  # gcloud = Gcloud.new
  # storage = gcloud.storage
  # ```
  #
  # ## Downloading a File
  #
  # Files can be downloaded to the local file system. (See {File#download})
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # storage = gcloud.storage
  #
  # bucket = storage.bucket "my-todo-app"
  # file = bucket.file "avatars/heidi/400x400.png"
  # file.download "/var/todo-app/avatars/heidi/400x400.png"
  # ```
  #
  # ## Using Signed URLs
  #
  # Access without authentication can be granted to a File for a specified
  # period of time. This URL uses a cryptographic signature
  # of your credentials to access the file. (See {File#signed_url})
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # storage = gcloud.storage
  #
  # bucket = storage.bucket "my-todo-app"
  # file = bucket.file "avatars/heidi/400x400.png"
  # shared_url = file.signed_url method: "GET",
  #                              expires: 300 # 5 minutes from now
  # ```
  #
  # ## Controlling Access to a Bucket
  #
  # Access to a bucket is controlled with {Bucket#acl}. A bucket has owners,
  # writers, and readers. Permissions can be granted to an individual user's
  # email address, a group's email address, as well as many predefined lists.
  # See the
  # [Access Control guide](https://cloud.google.com/storage/docs/access-control)
  # for more.
  #
  # Access to a bucket can be granted to a user by appending `"user-"` to the
  # email address:
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # storage = gcloud.storage
  #
  # bucket = storage.bucket "my-todo-app"
  #
  # email = "heidi@example.net"
  # bucket.acl.add_reader "user-#{email}"
  # ```
  #
  # Access to a bucket can be granted to a group by appending `"group-"` to the
  # email address:
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # storage = gcloud.storage
  #
  # bucket = storage.bucket "my-todo-app"
  #
  # email = "authors@example.net"
  # bucket.acl.add_reader "group-#{email}"
  # ```
  #
  # Access to a bucket can also be granted to a predefined list of permissions:
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # storage = gcloud.storage
  #
  # bucket = storage.bucket "my-todo-app"
  #
  # bucket.acl.public!
  # ```
  #
  # ## Controlling Access to a File
  #
  # Access to a file is controlled in two ways, either by the setting the
  # default permissions to all files in a bucket with {Bucket#default_acl}, or
  # by setting permissions to an individual file with {File#acl}.
  #
  # Access to a file can be granted to a user by appending `"user-"` to the
  # email address:
  #
  # ```ruby
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # storage = gcloud.storage
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
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # storage = gcloud.storage
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
  # require "gcloud"
  #
  # gcloud = Gcloud.new
  # storage = gcloud.storage
  #
  # bucket = storage.bucket "my-todo-app"
  # file = bucket.file "avatars/heidi/400x400.png"
  #
  # file.acl.public!
  # ```
  #
  module Storage
  end
end
