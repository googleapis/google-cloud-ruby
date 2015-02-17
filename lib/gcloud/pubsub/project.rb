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

require "gcloud/pubsub/connection"
require "gcloud/pubsub/credentials"
require "gcloud/pubsub/errors"
require "gcloud/pubsub/topic"

module Gcloud
  module Pubsub
    ##
    # Represents the Project that the Topics and Files belong to.
    class Project
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # Creates a new Connection instance.
      def initialize project, credentials
        @connection = Connection.new project, credentials
      end

      ##
      # The project identifier.
      def project
        connection.project
      end

      ##
      # Retrieves topic by name.
      def topic topic_name
        resp = connection.get_topic topic_name
        if resp.success?
          Topic.from_gapi resp.data, connection
        else
          return nil if resp.data["error"]["code"] == 404
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Creates a new topic.
      #
      #   topic = project.create_topic "my-topic"
      def create_topic topic_name
        resp = connection.create_topic topic_name
        if resp.success?
          Topic.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Retrieves a list of topics for the given project.
      def topics options = {}
        resp = connection.list_topics options
        if resp.success?
          Topic::List.from_resp resp, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Retrieves a list of subscriptions for the given project.
      def subscriptions
        resp = connection.list_subscriptions
        if resp.success?
          Array(resp.data["subscription"]).map do |gapi_object|
            Subscription.from_gapi gapi_object, connection
          end
        else
          fail ApiError.from_response(resp)
        end
      end
    end
  end
end
