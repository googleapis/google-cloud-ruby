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
require "google/cloud/pubsub/v1/publisher/credentials.rb"

module Google
  module Cloud
    module PubSub
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
      #   creds = Google::Cloud::PubSub::Credentials.new keyfile
      #
      #   pubsub = Google::Cloud::PubSub.new(
      #     project_id: "my-project",
      #     credentials: creds
      #   )
      #
      #   pubsub.project_id #=> "my-project"
      #
      class Credentials < Google::Cloud::PubSub::V1::Publisher::Credentials
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
