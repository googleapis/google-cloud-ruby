# Copyright 2017 Google LLC
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
require "google/cloud/logging/credentials"

module Google
  module Cloud
    module Debugger
      ##
      # # Credentials
      #
      # Represents the authentication and authorization used to connect to the
      # Stackdriver Debugger service.
      #
      # @example
      #   require "google/cloud/debugger"
      #
      #   keyfile = "/path/to/keyfile.json"
      #   creds = Google::Cloud::Debugger::Credentials.new keyfile
      #
      #   debugger = Google::Cloud::Debugger.new(
      #     project_id: "my-project",
      #     credentials: creds
      #   )
      #
      #   debugger.project_id #=> "my-project"
      #
      class Credentials < Google::Auth::Credentials
        SCOPE = ["https://www.googleapis.com/auth/cloud_debugger"] +
                Google::Cloud::Logging::Credentials::SCOPE
        PATH_ENV_VARS = %w(DEBUGGER_CREDENTIALS
                           GOOGLE_CLOUD_CREDENTIALS
                           DEBUGGER_KEYFILE
                           GOOGLE_CLOUD_KEYFILE
                           GCLOUD_KEYFILE)
        JSON_ENV_VARS = %w(DEBUGGER_CREDENTIALS_JSON
                           GOOGLE_CLOUD_CREDENTIALS_JSON
                           DEBUGGER_KEYFILE_JSON
                           GOOGLE_CLOUD_KEYFILE_JSON
                           GCLOUD_KEYFILE_JSON)
        DEFAULT_PATHS = \
          ["~/.config/gcloud/application_default_credentials.json"]
      end
    end
  end
end
