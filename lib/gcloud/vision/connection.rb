# Copyright 2016 Google Inc. All rights reserved.
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


require "gcloud/version"
require "google/api_client"

module Gcloud
  module Vision
    ##
    # @private Represents the connection to Vision,
    # as well as expose the API calls.
    class Connection
      attr_accessor :project
      attr_accessor :credentials

      ##
      # Creates a new Connection instance.
      def initialize project, credentials
        @project = project
        @credentials = credentials
        @client = Google::APIClient.new application_name:    "gcloud-ruby",
                                        application_version: Gcloud::VERSION
        @client.authorization = @credentials.client
        custom_discovery_url = Addressable::URI.parse(
          "https://vision.googleapis.com/$discovery/rest?version=v1")
        @client.register_discovery_uri "vision", "v1", custom_discovery_url
        @vision = @client.discovered_api "vision", "v1"
      end

      def annotate requests
        @client.execute(
          api_method: @vision.images.annotate,
          body_object: { requests: requests }
        )
      end
    end
  end
end
