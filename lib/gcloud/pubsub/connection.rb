# Copyright 2015 Google Inc. All rights reserved.
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
  module Pubsub
    ##
    # @private Represents the connection to Pub/Sub,
    # as well as expose the API calls.
    class Connection
      API_VERSION = "v1"

      attr_accessor :project
      attr_accessor :credentials

      ##
      # Creates a new Connection instance.
      def initialize project, credentials
        @project = project
        @credentials = credentials
        @client = Google::APIClient.new application_name:    "gcloud-ruby",
                                        application_version: Gcloud::VERSION
        @client.authorization = nil # @credentials.client
        @pubsub = @client.discovered_api "pubsub", API_VERSION
      end

      def project_path options = {}
        project_name = options[:project] || project
        "projects/#{project_name}"
      end

      def topic_path topic_name, options = {}
        return topic_name if topic_name.to_s.include? "/"
        "#{project_path(options)}/topics/#{topic_name}"
      end

      def subscription_path subscription_name, options = {}
        return subscription_name if subscription_name.to_s.include? "/"
        "#{project_path(options)}/subscriptions/#{subscription_name}"
      end

      def inspect
        "#{self.class}(#{@project})"
      end

      protected

      def subscription_data topic, options = {}
        deadline   = options[:deadline]
        endpoint   = options[:endpoint]
        attributes = (options[:attributes] || {}).to_h

        data = { topic: topic_path(topic) }
        data[:ackDeadlineSeconds] = deadline if deadline
        if endpoint
          data[:pushConfig] = { pushEndpoint: endpoint,
                                attributes:   attributes }
        end
        data
      end
    end
  end
end
