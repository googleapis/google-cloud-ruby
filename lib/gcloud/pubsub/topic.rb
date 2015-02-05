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

require "gcloud/pubsub/errors"
require "gcloud/pubsub/subscription"

module Gcloud
  module Pubsub
    ##
    # Represents a Topic.
    class Topic
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # The Google API Client object.
      attr_accessor :gapi #:nodoc:

      ##
      # Create an empty Topic object.
      def initialize #:nodoc:
        @connection = nil
        @gapi = {}
      end

      ##
      # The name of the topic.
      def name
        @gapi["name"]
      end

      ##
      # Permenently deletes the topic.
      # The topic must be empty.
      #
      #   topic.delete
      def delete
        ensure_connection!
        resp = connection.delete_topic topic_name
        if resp.success?
          true
        else
          ApiError.from_response(resp)
        end
      end

      ##
      # Creates a subscription on a given topic for a given subscriber.
      #
      # If the name is not provided in the request, the server will assign a
      # random name for this subscription on the same project as the topic.
      def create_subscription subscription_name = nil
        ensure_connection!
        resp = connection.create_subscription topic_name, subscription_name
        if resp.success?
          Subscription.from_gapi resp.data, connection
        else
          # TODO: Handle ALREADY_EXISTS and NOT_FOUND
          fail ApiError.from_response(resp)
        end
      end
      alias_method :subscribe, :create_subscription

      ##
      # Retrieves a subscription by name.
      def subscription subscription_name
        ensure_connection!
        resp = connection.get_subscription subscription_name
        if resp.success?
          Subscription.from_gapi resp.data, connection
        else
          nil
        end
      end

      ##
      # New Topic from a Google API Client object.
      def self.from_gapi gapi, conn #:nodoc:
        new.tap do |f|
          f.gapi = gapi
          f.connection = conn
        end
      end

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless connection
      end

      ##
      # Gets the topic name from the path.
      # "/topics/project-identifier/topic-name"
      # will return "topic-name"
      def topic_name
        name.split("/").last
      end
    end
  end
end
