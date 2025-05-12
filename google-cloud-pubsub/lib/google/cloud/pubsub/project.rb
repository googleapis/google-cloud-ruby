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


require "google/cloud/errors"
require "google/cloud/pubsub/service"
require "google/cloud/pubsub/credentials"
require "google/cloud/pubsub/publisher"
require "google/cloud/pubsub/subscriber"

module Google
  module Cloud
    module PubSub
      DEFAULT_COMPRESS = false
      DEFAULT_COMPRESSION_BYTES_THRESHOLD = 240

      ##
      # # Project
      #
      # Represents the project that pubsub messages are pushed to and pulled
      # from. {Topic} is a named resource to which messages are sent by
      # publishers. {Subscription} is a named resource representing the stream
      # of messages from a single, specific topic, to be delivered to the
      # subscribing application. {Message} is a combination of data and
      # attributes that a publisher sends to a topic and is eventually delivered
      # to subscribers.
      #
      # See {Google::Cloud#pubsub}
      #
      # @example
      #   require "google/cloud/pubsub"
      #
      #   pubsub = Google::Cloud::PubSub.new
      #
      #   topic = pubsub.topic "my-topic"
      #   topic.publish "task completed"
      #
      class Project
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private Creates a new Pub/Sub Project instance.
        def initialize service
          @service = service
        end

        # The Pub/Sub project connected to.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new(
        #     project_id: "my-project",
        #     credentials: "/path/to/keyfile.json"
        #   )
        #
        #   pubsub.project_id #=> "my-project"
        #
        def project_id
          service.project
        end
        alias project project_id

        ##
        # The universe domain the client is connected to
        #
        # @return [String]
        #
        def universe_domain
          service.universe_domain
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
