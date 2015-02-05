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
