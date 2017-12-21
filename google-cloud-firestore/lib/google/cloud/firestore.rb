# Copyright 2017 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require "google-cloud-firestore"
require "google/cloud/firestore/client"

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
      # @param [String] project_id Identifier for a Firestore project. If not
      #   present, the default project for the credentials is used.
      # @param [String, Hash, Google::Auth::Credentials] credentials The path to
      #   the keyfile as a String, the contents of the keyfile as a Hash, or a
      #   Google::Auth::Credentials object. (See {Datastore::Credentials})
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
      # @param [String] project Alias for the `project_id` argument. Deprecated.
      # @param [String] keyfile Alias for the `credentials` argument.
      #   Deprecated.
      #
      # @return [Google::Cloud::Firestore::Client]
      #
      # @example
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      def self.new project_id: nil, credentials: nil, scope: nil, timeout: nil,
                   client_config: nil, project: nil, keyfile: nil
        project_id ||= (project || Firestore::Service.default_project_id)
        project_id = project_id.to_s # Always cast to a string
        fail ArgumentError, "project_id is missing" if project_id.empty?

        credentials ||= keyfile
        credentials ||= Firestore::Credentials.default(scope: scope)
        unless credentials.is_a? Google::Auth::Credentials
          credentials = Firestore::Credentials.new credentials, scope: scope
        end

        Firestore::Client.new \
          Firestore::Service.new \
            project_id, credentials,
            timeout: timeout, client_config: client_config
      end
    end
  end
end
