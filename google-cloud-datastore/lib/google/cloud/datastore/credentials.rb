# Copyright 2014 Google LLC
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
require "google/cloud/datastore/v1/credentials"

module Google
  module Cloud
    module Datastore
      ##
      # # Credentials
      #
      # Represents the authentication and authorization used to connect to the
      # Datastore API.
      #
      # @example
      #   require "google/cloud/datastore"
      #
      #   keyfile = "/path/to/keyfile.json"
      #   creds = Google::Cloud::Datastore::Credentials.new keyfile
      #
      #   datastore = Google::Cloud::Datastore.new(
      #     project_id: "my-todo-project",
      #     credentials: creds
      #   )
      #
      #   datastore.project_id #=> "my-todo-project"
      #
      class Credentials < Google::Cloud::Datastore::V1::Credentials
      end
    end
  end
end
