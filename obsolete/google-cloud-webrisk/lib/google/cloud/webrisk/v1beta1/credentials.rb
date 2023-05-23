# Copyright 2020 Google LLC
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
    module Webrisk
      module V1beta1
        class Credentials < Google::Auth::Credentials
          SCOPE = [
            "https://www.googleapis.com/auth/cloud-platform"
          ].freeze
          PATH_ENV_VARS = %w(WEBRISK_CREDENTIALS
                             WEBRISK_KEYFILE
                             GOOGLE_CLOUD_CREDENTIALS
                             GOOGLE_CLOUD_KEYFILE
                             GCLOUD_KEYFILE)
          JSON_ENV_VARS = %w(WEBRISK_CREDENTIALS_JSON
                             WEBRISK_KEYFILE_JSON
                             GOOGLE_CLOUD_CREDENTIALS_JSON
                             GOOGLE_CLOUD_KEYFILE_JSON
                             GCLOUD_KEYFILE_JSON)
          DEFAULT_PATHS = ["~/.config/gcloud/application_default_credentials.json"]
        end
      end
    end
  end
end
