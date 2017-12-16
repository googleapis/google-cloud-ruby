# Copyright 2015 Google LLC
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


require "googleauth"

module Google
  module Cloud
    module Pubsub
      ##
      # # Credentials
      #
      # Represents the authentication and authorization used to connect to the
      # Pub/Sub API.
      #
      # @example
      #   require "google/cloud/pubsub"
      #
      #   keyfile = "/path/to/keyfile.json"
      #   creds = Google::Cloud::Pubsub::Credentials.new keyfile
      #
      #   pubsub = Google::Cloud::Pubsub.new(
      #     project_id: "my-project",
      #     credentials: creds
      #   )
      #
      #   pubsub.project_id #=> "my-project"
      #
      class Credentials < Google::Auth::Credentials
        SCOPE = ["https://www.googleapis.com/auth/pubsub"]
        PATH_ENV_VARS = %w(PUBSUB_CREDENTIALS
                           PUBSUB_KEYFILE
                           GOOGLE_CLOUD_CREDENTIALS
                           GOOGLE_CLOUD_KEYFILE
                           GCLOUD_KEYFILE)
        JSON_ENV_VARS = %w(PUBSUB_CREDENTIALS_JSON
                           PUBSUB_KEYFILE_JSON
                           GOOGLE_CLOUD_CREDENTIALS_JSON
                           GOOGLE_CLOUD_KEYFILE_JSON
                           GCLOUD_KEYFILE_JSON)
        DEFAULT_PATHS = \
          ["~/.config/gcloud/application_default_credentials.json"]
      end
    end
  end
end
