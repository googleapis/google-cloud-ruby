# Copyright 2016 Google LLC
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

##
# This file is here to be autorequired by bundler, so that the
# Google::Cloud.storage and Google::Cloud#storage methods can be available, but
# the library and all dependencies won't be loaded until required and used.


gem "google-cloud-core"
require "google/cloud"

module Google
  module Cloud
    ##
    # Creates a new object for connecting to the Storage service.
    # Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # @see https://cloud.google.com/storage/docs/authentication#oauth Storage
    #   OAuth 2.0 Authentication
    #
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
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
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   storage = gcloud.storage
    #   bucket = storage.bucket "my-bucket"
    #   file = bucket.file "path/to/my-file.ext"
    #
    # @example The default scope can be overridden with the `scope` option:
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   readonly_scope = "https://www.googleapis.com/auth/devstorage.read_only"
    #   readonly_storage = gcloud.storage scope: readonly_scope
    #
    def storage scope: nil, retries: nil, timeout: nil
      Google::Cloud.storage @project, @keyfile, scope: scope,
                                                retries: (retries || @retries),
                                                timeout: (timeout || @timeout)
    end

    ##
    # Creates a new object for connecting to the Storage service.
    # Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # @param [String] project_id Project identifier for the Storage service
    #   you are connecting to. If not present, the default project for the
    #   credentials is used.
    # @param [String, Hash, Google::Auth::Credentials] credentials The path to
    #   the keyfile as a String, the contents of the keyfile as a Hash, or a
    #   Google::Auth::Credentials object. (See {Storage::Credentials})
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
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
    #   storage = Google::Cloud.storage "my-project",
    #                            "/path/to/keyfile.json"
    #
    #   bucket = storage.bucket "my-bucket"
    #   file = bucket.file "path/to/my-file.ext"
    #
    def self.storage project_id = nil, credentials = nil, scope: nil,
                     retries: nil, timeout: nil
      require "google/cloud/storage"
      Google::Cloud::Storage.new project_id: project_id,
                                 credentials: credentials,
                                 scope: scope, retries: retries,
                                 timeout: timeout
    end
  end
end
