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


require "googleauth"

module Google
  module Cloud
    module Translate
      ##
      # # Credentials
      #
      # Represents the authentication and authorization used to connect to the
      # Cloud Translation API.
      #
      # @example
      #   require "google/cloud/translate"
      #
      #   keyfile = "/path/to/keyfile.json"
      #   creds = Google::Cloud::Translate::Credentials.new keyfile
      #
      #   translate = Google::Cloud::Translate.new(
      #     project_id: "my-todo-project",
      #     credentials: creds
      #   )
      #
      #   translate.project_id #=> "my-todo-project"
      #
      class Credentials < Google::Auth::Credentials
        SCOPE = ["https://www.googleapis.com/auth/cloud-platform"]
        PATH_ENV_VARS = %w(TRANSLATE_CREDENTIALS
                           TRANSLATE_KEYFILE
                           GOOGLE_CLOUD_CREDENTIALS
                           GOOGLE_CLOUD_KEYFILE
                           GCLOUD_KEYFILE)
        JSON_ENV_VARS = %w(TRANSLATE_CREDENTIALS_JSON
                           TRANSLATE_KEYFILE_JSON
                           GOOGLE_CLOUD_CREDENTIALS_JSON
                           GOOGLE_CLOUD_KEYFILE_JSON
                           GCLOUD_KEYFILE_JSON)
        DEFAULT_PATHS = \
          ["~/.config/gcloud/application_default_credentials.json"]
      end
    end
  end
end
