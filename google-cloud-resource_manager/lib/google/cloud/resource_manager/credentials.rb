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
    module ResourceManager
      ##
      # # Credentials
      #
      # Represents the authentication and authorization used to connect to the
      # Resource Manager API.
      #
      # @example
      #   require "google/cloud/resource_manager"
      #
      #   keyfile = "/path/to/keyfile.json"
      #   creds = Google::Cloud::ResourceManager::Credentials.new keyfile
      #
      #   resource_manager = Google::Cloud::ResourceManager.new(
      #     credentials: creds
      #   )
      #
      class Credentials < Google::Auth::Credentials
        SCOPE = ["https://www.googleapis.com/auth/cloud-platform"]
        PATH_ENV_VARS = %w(RESOURCE_MANAGER_CREDENTIALS
                           RESOURCE_MANAGER_KEYFILE
                           GOOGLE_CLOUD_CREDENTIALS
                           GOOGLE_CLOUD_KEYFILE
                           GCLOUD_KEYFILE)
        JSON_ENV_VARS = %w(RESOURCE_MANAGER_CREDENTIALS_JSON
                           RESOURCE_MANAGER_KEYFILE_JSON
                           GOOGLE_CLOUD_CREDENTIALS_JSON
                           GOOGLE_CLOUD_KEYFILE_JSON
                           GCLOUD_KEYFILE_JSON)
        DEFAULT_PATHS = \
          ["~/.config/gcloud/application_default_credentials.json"]
      end
    end
  end
end
