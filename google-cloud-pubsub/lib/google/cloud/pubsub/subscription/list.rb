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

module Google
  module Cloud
    module Pubsub
      class Subscription
        ##
        # Subscription::List is a special case Array with additional values.
        class List < DelegateClass(::Array)
          ##
          # If not empty, indicates that there are more subscriptions
          # that match the request and this value should be passed to
          # the next {Google::Cloud::Pubsub::Topic#subscriptions} to continue.
          def token
            page_token = @paged_enum.page_token
            page_token if page_token && page_token != ""
          end

          ##
          # @private Create a new Subscription::List with an array of values.
          def initialize arr = []
            @topic = nil
            @prefix = nil
            @token = nil
            @max = nil
            super arr
          end

          ##
          # Whether there a next page of subscriptions.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/pubsub"
          #
          #   pubsub = Google::Cloud::Pubsub.new
          #
          #   subscriptions = pubsub.subscriptions
          #   if subscriptions.next?
          #     next_subscriptions = subscriptions.next
          #   end
          #
          def next?
            ensure_paged_enum!
            @paged_enum.next_page?
          end

          ##
          # Retrieve the next page of subscriptions.
          #
          # @return [Subscription::List]
          #
          # @example
          #   require "google/cloud/pubsub"
          #
          #   pubsub = Google::Cloud::Pubsub.new
          #
          #   subscriptions = pubsub.subscriptions
          #   if subscriptions.next?
          #     next_subscriptions = subscriptions.next
          #   end
          #
          def next
            return nil unless next?
            @paged_enum.next_page
            if @topic
              self.class.from_topic_grpc @paged_enum, @service, @topic
            else
              self.class.from_grpc @paged_enum, @service
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
          # @param [Integer] request_limit The upper limit of API requests to
          #   make to load all subscriptions. Default is no limit.
          # @yield [subscription] The block for accessing each subscription.
          # @yieldparam [Subscription] subscription The subscription object.
          #
          # @return [Enumerator]
          #
          # @example Iterating each subscription by passing a block:
          #   require "google/cloud/pubsub"
          #
          #   pubsub = Google::Cloud::Pubsub.new
          #
          #   subscriptions = pubsub.subscriptions
          #   subscriptions.all do |subscription|
          #     puts subscription.name
          #   end
          #
          # @example Using the enumerator by not passing a block:
          #   require "google/cloud/pubsub"
          #
          #   pubsub = Google::Cloud::Pubsub.new
          #
          #   subscriptions = pubsub.subscriptions
          #   all_names = subscriptions.all.map do |subscription|
          #     subscription.name
          #   end
          #
          # @example Limit the number of API calls made:
          #   require "google/cloud/pubsub"
          #
          #   pubsub = Google::Cloud::Pubsub.new
          #
          #   subscriptions = pubsub.subscriptions
          #   subscriptions.all(request_limit: 10) do |subscription|
          #     puts subscription.name
          #   end
          #
          def all request_limit: nil
            request_limit = request_limit.to_i if request_limit
            unless block_given?
              return enum_for(:all, request_limit: request_limit)
            end
            results = self
            loop do
              results.each { |r| yield r }
              if request_limit
                request_limit -= 1
                break if request_limit < 0
              end
              break unless results.next?
              results = results.next
            end
          end

          ##
          # @private New Subscriptions::List from a
          # Google::Pubsub::V1::ListSubscriptionsRequest object.
          def self.from_grpc paged_enum, service
            subs = new
            paged_enum.page.each do |topic_grpc|
              subs << Subscription.from_grpc(topic_grpc, service)
            end
            subs.instance_variable_set "@paged_enum", paged_enum
            subs.instance_variable_set "@service", service
            subs
          end

          ##
          # @private New Subscriptions::List from a
          # Google::Pubsub::V1::ListTopicSubscriptionsResponse object.
          def self.from_topic_grpc paged_enum, service, topic
            subs = new
            paged_enum.page.each do |subscription_name|
              subs << Subscription.new_lazy(subscription_name, service)
            end
            subs.instance_variable_set "@paged_enum", paged_enum
            subs.instance_variable_set "@service", service
            subs.instance_variable_set "@topic", topic
            subs
          end

          protected

          ##
          # @private Raise an error unless an active connection to the service
          # is available.
          def ensure_paged_enum!
            fail "Must have active connection to service" unless @paged_enum
          end
        end
      end
    end
  end
end
