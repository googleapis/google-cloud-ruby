# Copyright 2017, Google Inc. All rights reserved.
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


require "google-cloud-firestore"
require "google/cloud/firestore/project"

module Google
  module Cloud
    ##
    # # Cloud Firestore
    #
    module Firestore
      ##
      # Creates a new object for connecting to the Firestore service.
      # Each call creates a new connection.
      #
      # For more information on connecting to Google Cloud see the
      # [Authentication
      # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/guides/authentication).
      #
      # @param [String] project Project identifier for the Firestore service you
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
      #   * `https://www.googleapis.com/auth/datastore`
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      # @param [Hash] client_config A hash of values to override the default
      #   behavior of the API client. Optional.
      #
      # @return [Google::Cloud::Firestore::Database]
      #
      # @example
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      def self.new project: nil, keyfile: nil, scope: nil, timeout: nil,
                   client_config: nil
        project ||= Google::Cloud::Firestore::Project.default_project
        project = project.to_s # Always cast to a string
        fail ArgumentError, "project is missing" if project.empty?

        if keyfile.nil?
          credentials = Google::Cloud::Firestore::Credentials.default \
            scope: scope
        else
          credentials = Google::Cloud::Firestore::Credentials.new \
            keyfile, scope: scope
        end

        Google::Cloud::Firestore::Database.new \
          Google::Cloud::Firestore::Service.new \
            project, credentials,
            timeout: timeout, client_config: client_config
      end
    end
  end
end
