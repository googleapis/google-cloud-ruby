# Copyright 2016 Google Inc. All rights reserved.
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
# This file is here to be autorequired by bundler, so that the .bigquery and
# #bigquery methods can be available, but the library and all dependencies won't
# be loaded until required and used.


gem "google-cloud-core"
require "google/cloud"

module Google
  module Cloud
    ##
    # Creates a new object for connecting to the Datastore service.
    # Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scope is:
    #
    #   * `https://www.googleapis.com/auth/datastore`
    # @param [Integer] retries Number of times to retry requests on server
    #   error. The default value is `3`. Optional.
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    #
    # @return [Google::Cloud::Datastore::Dataset]
    #
    # @example
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   datastore = gcloud.datastore
    #
    #   task = datastore.entity "Task" do |t|
    #     t["type"] = "Personal"
    #     t["done"] = false
    #     t["priority"] = 4
    #     t["description"] = "Learn Cloud Datastore"
    #   end
    #
    #   datastore.save task
    #
    # @example You shouldn't need to override the default scope, but you can:
    #   require "google/cloud"
    #
    #   gcloud  = Google::Cloud.new
    #   platform_scope = "https://www.googleapis.com/auth/cloud-platform"
    #   datastore = gcloud.datastore scope: platform_scope
    #
    def datastore scope: nil, retries: nil, timeout: nil
      Google::Cloud.datastore @project, @keyfile,
                              scope: scope, retries: (retries || @retries),
                              timeout: (timeout || @timeout)
    end

    ##
    # Creates a new object for connecting to the Datastore service.
    # Each call creates a new connection.
    #
    # For more information on connecting to Google Cloud see the [Authentication
    # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
    #
    # @param [String] project Dataset identifier for the Datastore you are
    #   connecting to.
    # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud. If
    #   file path the file must be readable.
    # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling the
    #   set of resources and operations that the connection can access. See
    #   [Using OAuth 2.0 to Access Google
    #   APIs](https://developers.google.com/identity/protocols/OAuth2).
    #
    #   The default scope is:
    #
    #   * `https://www.googleapis.com/auth/datastore`
    # @param [Integer] retries Number of times to retry requests on server
    #   error. The default value is `3`. Optional.
    # @param [Integer] timeout Default timeout to use in requests. Optional.
    #
    # @return [Google::Cloud::Datastore::Dataset]
    #
    # @example
    #   require "google/cloud"
    #
    #   datastore = Google::Cloud.datastore "my-todo-project",
    #                              "/path/to/keyfile.json"
    #
    #   task = datastore.entity "Task", "sampleTask" do |t|
    #     t["type"] = "Personal"
    #     t["done"] = false
    #     t["priority"] = 4
    #     t["description"] = "Learn Cloud Datastore"
    #   end
    #
    #   datastore.save task
    #
    def self.datastore project = nil, keyfile = nil, scope: nil, retries: nil,
                       timeout: nil
      require "google/cloud/datastore"
      Google::Cloud::Datastore.new project: project, keyfile: keyfile,
                                   scope: scope, retries: retries,
                                   timeout: timeout
    end
  end
end
