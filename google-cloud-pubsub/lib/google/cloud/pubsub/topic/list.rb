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


require "delegate"

module Google
  module Cloud
    module Pubsub
      class Topic
        ##
        # Topic::List is a special case Array with additional values.
        class List < DelegateClass(::Array)
          ##
          # If not empty, indicates that there are more topics
          # that match the request and this value should be passed to
          # the next {Google::Cloud::Pubsub::Project#topics} to continue.
          attr_accessor :token

          ##
          # @private Create a new Topic::List with an array of values.
          def initialize arr = []
            super arr
          end

          ##
          # Whether there a next page of topics.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/pubsub"
          #
          #   pubsub = Google::Cloud::Pubsub.new
          #
          #   topics = pubsub.topics
          #   if topics.next?
          #     next_topics = topics.next
          #   end
          #
          def next?
            !token.nil?
          end

          ##
          # Retrieve the next page of topics.
          #
          # @return [Topic::List]
          #
          # @example
          #   require "google/cloud/pubsub"
          #
          #   pubsub = Google::Cloud::Pubsub.new
          #
          #   topics = pubsub.topics
          #   if topics.next?
          #     next_topics = topics.next
          #   end
          #
          def next
            return nil unless next?
            ensure_service!
            options = { token: token, max: @max }
            grpc = @service.list_topics options
            self.class.from_grpc grpc, @service, @max
          end

          ##
          # Retrieves remaining results by repeatedly invoking {#next} until
          # {#next?} returns `false`. Calls the given block once for each
          # result, which is passed as the argument to the block.
          #
          # An Enumerator is returned if no block is given.
          #
          # This method will make repeated API calls until all remaining results
          # are retrieved. (Unlike `#each`, for example, which merely iterates
          # over the results returned by a single API call.) Use with caution.
          #
          # @param [Integer] request_limit The upper limit of API requests to
          #   make to load all topics. Default is no limit.
          # @yield [topic] The block for accessing each topic.
          # @yieldparam [Topic] topic The topic object.
          #
          # @return [Enumerator]
          #
          # @example Iterating each topic by passing a block:
          #   require "google/cloud/pubsub"
          #
          #   pubsub = Google::Cloud::Pubsub.new
          #
          #   topics = pubsub.topics
          #   topics.all do |topic|
          #     puts topic.name
          #   end
          #
          # @example Using the enumerator by not passing a block:
          #   require "google/cloud/pubsub"
          #
          #   pubsub = Google::Cloud::Pubsub.new
          #
          #   topics = pubsub.topics
          #   all_names = topics.all.map do |topic|
          #     topic.name
          #   end
          #
          # @example Limit the number of API calls made:
          #   require "google/cloud/pubsub"
          #
          #   pubsub = Google::Cloud::Pubsub.new
          #
          #   topics = pubsub.topics
          #   topics.all(request_limit: 10) do |topic|
          #     puts topic.name
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
          # @private New Topic::List from a
          # Google::Pubsub::V1::ListTopicsResponse object.
          def self.from_grpc grpc_list, service, max = nil
            topics = new(Array(grpc_list.topics).map do |grpc|
              Topic.from_grpc grpc, service
            end)
            token = grpc_list.next_page_token
            token = nil if token == ""
            topics.instance_variable_set :@token,   token
            topics.instance_variable_set :@service, service
            topics.instance_variable_set :@max,     max
            topics
          end

          protected

          ##
          # @private Raise an error unless an active connection to the service
          # is available.
          def ensure_service!
            raise "Must have active connection to service" unless @service
          end
        end
      end
    end
  end
end
