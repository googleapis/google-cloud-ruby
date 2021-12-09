# Copyright 2016 Google LLC
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

# DO NOT EDIT: Unless you're fixing a P0/P1 and/or a security issue. This class
# is frozen to all new features from `google-cloud-spanner/v2.11.0` onwards.


require "delegate"

module Google
  module Cloud
    module Spanner
      class Instance
        ##
        # Instance::List is a special case Array with additional
        # values.
        #
        # @deprecated Use the result of
        # {Google::Cloud::Spanner::Admin::Instance#instance_admin Client#list_instances}
        # instead.
        class List < DelegateClass(::Array)
          ##
          # If not empty, indicates that there are more records that match
          # the request and this value should be passed to continue.
          attr_accessor :token

          ##
          # @private Create a new Instance::List with an array of
          # Instance instances.
          def initialize arr = []
            super arr
          end

          ##
          # Whether there is a next page of instances.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/spanner"
          #
          #   spanner = Google::Cloud::Spanner.new
          #
          #   instances = spanner.instances
          #   if instances.next?
          #     next_instances = instances.next
          #   end
          def next?
            !token.nil?
          end

          ##
          # Retrieve the next page of instances.
          #
          # @return [Instance::List] The list of instances.
          #
          # @example
          #   require "google/cloud/spanner"
          #
          #   spanner = Google::Cloud::Spanner.new
          #
          #   instances = spanner.instances
          #   if instances.next?
          #     next_instances = instances.next
          #   end
          def next
            return nil unless next?
            ensure_service!
            options = { token: token, max: @max }
            grpc = @service.list_instances(**options)
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
          #   make to load all instances. Default is no limit.
          # @yield [instance] The block for accessing each instance.
          # @yieldparam [Instance] instance The instance object.
          #
          # @return [Enumerator]
          #
          # @example Iterating each instance by passing a block:
          #   require "google/cloud/spanner"
          #
          #   spanner = Google::Cloud::Spanner.new
          #
          #   spanner.instances.all do |instance|
          #     puts instance.instance_id
          #   end
          #
          # @example Using the enumerator by not passing a block:
          #   require "google/cloud/spanner"
          #
          #   spanner = Google::Cloud::Spanner.new
          #
          #   all_instance_ids = spanner.instances.all.map do |instance|
          #     instance.instance_id
          #   end
          #
          # @example Limit the number of API calls made:
          #   require "google/cloud/spanner"
          #
          #   spanner = Google::Cloud::Spanner.new
          #
          #   spanner.instances.all(request_limit: 10) do |instance|
          #     puts instance.instance_id
          #   end
          #
          def all request_limit: nil, &block
            request_limit = request_limit.to_i if request_limit
            unless block_given?
              return enum_for :all, request_limit: request_limit
            end
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
          # @private New Instance::List from a
          # `Google::Cloud::Spanner::Admin::Instance::V1::ListInstancesResponse`
          # object.
          def self.from_grpc grpc, service, max = nil
            instances = List.new(Array(grpc.instances).map do |instance|
              Instance.from_grpc instance, service
            end)
            token = grpc.next_page_token
            token = nil if token == "".freeze
            instances.instance_variable_set :@token,   token
            instances.instance_variable_set :@service, service
            instances.instance_variable_set :@max,     max
            instances
          end

          protected

          ##
          # Raise an error unless an active service is available.
          def ensure_service!
            raise "Must have active connection" unless @service
          end
        end
      end
    end
  end
end
