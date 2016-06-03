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


require "delegate"

module Gcloud
  module Pubsub
    class Subscription
      ##
      # Subscription::List is a special case Array with additional values.
      class List < DelegateClass(::Array)
        ##
        # If not empty, indicates that there are more subscriptions
        # that match the request and this value should be passed to
        # the next {Gcloud::Pubsub::Topic#subscriptions} to continue.
        attr_accessor :token

        ##
        # Create a new Subscription::List with an array of values.
        def initialize arr = []
          super arr
        end

        ##
        # Whether there a next page of subscriptions.
        def next?
          !token.nil?
        end

        ##
        # Retrieve the next page of subscriptions.
        def next
          return nil unless next?
          ensure_service!
          if @topic
            next_topic_subscriptions
          else
            next_subscriptions
          end
        end

        ##
        # Retrieves all subscriptions by repeatedly loading {#next} until
        # {#next?} returns `false`. Calls the given block once for each
        # subscription, which is passed as the parameter.
        #
        # An Enumerator is returned if no block is given.
        #
        # This method may make several API calls until all subscriptions are
        # retrieved. Be sure to use as narrow a search criteria as possible.
        # Please use with caution.
        #
        # @example Iterating each subscription by passing a block:
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   pubsub = gcloud.pubsub
        #
        #   subscriptions = pubsub.subscriptions
        #   subscriptions.all do |subscription|
        #     puts subscription.name
        #   end
        #
        # @example Using the enumerator by not passing a block:
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   pubsub = gcloud.pubsub
        #
        #   subscriptions = pubsub.subscriptions
        #   all_names = subscriptions.all.map do |subscription|
        #     subscription.name
        #   end
        #
        # @example Limit the number of API calls made:
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   pubsub = gcloud.pubsub
        #
        #   subscriptions = pubsub.subscriptions
        #   subscriptions.all(max_api_calls: 10) do |subscription|
        #     puts subscription.name
        #   end
        #
        def all max_api_calls: nil
          max_api_calls = max_api_calls.to_i if max_api_calls
          unless block_given?
            return enum_for(:all, max_api_calls: max_api_calls)
          end
          results = self
          loop do
            results.each { |r| yield r }
            if max_api_calls
              max_api_calls -= 1
              break if max_api_calls < 0
            end
            break unless results.next?
            results = results.next
          end
        end

        ##
        # @private New Subscriptions::List from a
        # Google::Pubsub::V1::ListSubscriptionsRequest object.
        def self.from_grpc grpc_list, service, max = nil
          subs = new(Array(grpc_list.subscriptions).map do |grpc|
            Subscription.from_grpc grpc, service
          end)
          token = grpc_list.next_page_token
          token = nil if token == ""
          subs.instance_variable_set "@token",   token
          subs.instance_variable_set "@service", service
          subs.instance_variable_set "@max",     max
          subs
        end

        ##
        # @private New Subscriptions::List from a
        # Google::Pubsub::V1::ListTopicSubscriptionsResponse object.
        def self.from_topic_grpc grpc_list, service, topic, max = nil
          subs = new(Array(grpc_list.subscriptions).map do |grpc|
            Subscription.new_lazy grpc, service
          end)
          token = grpc_list.next_page_token
          token = nil if token == ""
          subs.instance_variable_set "@token",   token
          subs.instance_variable_set "@service", service
          subs.instance_variable_set "@topic",   topic
          subs.instance_variable_set "@max",     max
          subs
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          fail "Must have active connection to service" unless @service
        end

        def next_subscriptions
          options = { prefix: @prefix, token: @token, max: @max }
          grpc = @service.list_subscriptions options
          self.class.from_grpc grpc, @service, @max
        rescue GRPC::BadStatus => e
          raise Error.from_error(e)
        end

        def next_topic_subscriptions
          options = { token: @token, max: @max }
          grpc = @service.list_topics_subscriptions @topic, options
          self.class.from_topic_grpc grpc, @service, @topic, @max
        rescue GRPC::BadStatus => e
          raise Error.from_error(e)
        end
      end
    end
  end
end
