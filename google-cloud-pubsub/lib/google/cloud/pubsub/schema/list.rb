# Copyright 2021 Google LLC
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
    module PubSub
      class Schema
        ##
        # Schema::List is a special case Array with additional values.
        class List < DelegateClass(::Array)
          ##
          # If not empty, indicates that there are more schemas
          # that match the request and this value should be passed to
          # the next {Google::Cloud::PubSub::Project#schemas} to continue.
          attr_accessor :token

          ##
          # @private Create a new Schema::List with an array of values.
          def initialize arr = []
            @prefix = nil
            @token = nil
            @view = nil
            @max = nil
            super arr
          end

          ##
          # Whether there a next page of schemas.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/pubsub"
          #
          #   pubsub = Google::Cloud::PubSub.new
          #
          #   schemas = pubsub.schemas
          #   if schemas.next?
          #     next_schemas = schemas.next
          #   end
          #
          def next?
            !token.nil?
          end

          ##
          # Retrieve the next page of schemas.
          #
          # @return [Schema::List]
          #
          # @example
          #   require "google/cloud/pubsub"
          #
          #   pubsub = Google::Cloud::PubSub.new
          #
          #   schemas = pubsub.schemas
          #   if schemas.next?
          #     next_schemas = schemas.next
          #   end
          #
          def next
            return nil unless next?
            ensure_service!
            next_schemas
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
          #   make to load all schemas. Default is no limit.
          # @yield [schema] The block for accessing each schema.
          # @yieldparam [Schema] schema The schema object.
          #
          # @return [Enumerator]
          #
          # @example Iterating each schema by passing a block:
          #   require "google/cloud/pubsub"
          #
          #   pubsub = Google::Cloud::PubSub.new
          #
          #   schemas = pubsub.schemas
          #   schemas.all do |schema|
          #     puts schema.name
          #   end
          #
          # @example Using the enumerator by not passing a block:
          #   require "google/cloud/pubsub"
          #
          #   pubsub = Google::Cloud::PubSub.new
          #
          #   schemas = pubsub.schemas
          #   all_names = schemas.all.map do |schema|
          #     schema.name
          #   end
          #
          # @example Limit the number of API calls made:
          #   require "google/cloud/pubsub"
          #
          #   pubsub = Google::Cloud::PubSub.new
          #
          #   schemas = pubsub.schemas
          #   schemas.all(request_limit: 10) do |schema|
          #     puts schema.name
          #   end
          #
          def all request_limit: nil, &block
            request_limit = request_limit.to_i if request_limit
            return enum_for :all, request_limit: request_limit unless block_given?
            results = self
            loop do
              results.each(&block)
              if request_limit
                request_limit -= 1
                break if request_limit.negative?
              end
              break unless results.next?
              results = results.next
            end
          end

          ##
          # @private New Schemas::List from a
          # Google::Cloud::PubSub::V1::ListSchemasRequest object.
          def self.from_grpc grpc_list, service, view, max = nil
            subs = new(Array(grpc_list.schemas).map do |grpc|
              Schema.from_grpc grpc, service
            end)
            token = grpc_list.next_page_token
            token = nil if token == "".freeze
            subs.instance_variable_set :@token,   token
            subs.instance_variable_set :@service, service
            subs.instance_variable_set :@view,    view
            subs.instance_variable_set :@max,     max
            subs
          end

          protected

          ##
          # @private Raise an error unless an active connection to the service
          # is available.
          def ensure_service!
            raise "Must have active connection to service" unless @service
          end

          def next_schemas
            options = { prefix: @prefix, token: @token, max: @max }
            grpc = @service.list_schemas @view, options
            self.class.from_grpc grpc, @service, @view, @max
          end
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
