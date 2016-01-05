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
  module Logging
    ##
    # @private Represents the connection to Logging,
    # as well as expose the API calls.
    class Connection
      API_VERSION = "v2beta1"

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
        @logging = @client.discovered_api "logging", API_VERSION
      end

      def list_resources token: nil, max: nil
        params = { pageToken: token,
                   maxResults: max
                 }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @logging.monitored_resource_descriptors.list,
          parameters: params
        )
      end

      def get_sink name
        @client.execute(
          api_method: @logging.projects.sinks.get,
          parameters: { sinkName: sink_path(name) }
        )
      end

      def update_sink name, destination, filter, version
        params = { sinkName: sink_path(name) }
        updated_sink_object = {
          name: name, destination: destination,
          filter: filter, outputVersionFormat: version
        }.delete_if { |_, v| v.nil? }

        @client.execute(
          api_method: @logging.projects.sinks.update,
          parameters: params,
          body_object: updated_sink_object
        )
      end

      def delete_sink name
        @client.execute(
          api_method: @logging.projects.sinks.delete,
          parameters: { sinkName: sink_path(name) }
        )
      end

      protected

      def sink_path sink_name
        "projects/#{@project}/sinks/#{sink_name}"
      end
    end
  end
end
