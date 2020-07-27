# Copyright 2018 Google LLC
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


require "google/cloud/bigtable/v2/bigtable/credentials"

module Google
  module Cloud
    module Bigtable
      ##
      # # Credentials
      #
      # Represents the authentication and authorization used to connect to the
      # Bigtable API.
      #
      # @example
      #   require "google/cloud/bigtable"
      #
      #   keyfile = "/path/to/keyfile.json"
      #   creds = Google::Cloud::Bigtable::Credentials.new keyfile
      #
      #   bigtable = Google::Cloud::Bigtable.new(
      #     project_id: "my-todo-project",
      #     credentials: creds
      #   )
      #
      #   bigtable.project_id #=> "my-todo-project"
      #
      class Credentials < Google::Cloud::Bigtable::V2::Bigtable::Credentials
        self.scope = [
          "https://www.googleapis.com/auth/bigtable.admin",
          "https://www.googleapis.com/auth/bigtable.admin.cluster",
          "https://www.googleapis.com/auth/bigtable.admin.instance",
          "https://www.googleapis.com/auth/bigtable.admin.table",
          "https://www.googleapis.com/auth/bigtable.data",
          "https://www.googleapis.com/auth/bigtable.data.readonly",
          "https://www.googleapis.com/auth/cloud-bigtable.admin",
          "https://www.googleapis.com/auth/cloud-bigtable.admin.cluster",
          "https://www.googleapis.com/auth/cloud-bigtable.admin.table",
          "https://www.googleapis.com/auth/cloud-bigtable.data",
          "https://www.googleapis.com/auth/cloud-bigtable.data.readonly",
          "https://www.googleapis.com/auth/cloud-platform",
          "https://www.googleapis.com/auth/cloud-platform.read-only"
        ]
      end
    end
  end
end
