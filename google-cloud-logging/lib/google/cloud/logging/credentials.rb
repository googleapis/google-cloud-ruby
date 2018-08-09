# Copyright 2016 Google LLC
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


require "google/cloud/logging/v2/credentials"

module Google
  module Cloud
    module Logging
      ##
      # # Credentials
      #
      # Represents the authentication and authorization used to connect to the
      # Stackdriver Logging API.
      #
      # @example
      #   require "google/cloud/logging"
      #
      #   keyfile = "/path/to/keyfile.json"
      #   creds = Google::Cloud::Logging::Credentials.new keyfile
      #
      #   logging = Google::Cloud::Logging.new(
      #     project_id: "my-project",
      #     credentials: creds
      #   )
      #
      #   logging.project_id #=> "my-project"
      #
      class Credentials < Google::Cloud::Logging::V2::Credentials
      end
    end
  end
end
