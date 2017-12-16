# Copyright 2016 Google LLC
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
    module Logging
      class Sink
        ##
        # Sink::List is a special case Array with additional values.
        class List < DelegateClass(::Array)
          ##
          # If not empty, indicates that there are more records that match
          # the request and this value should be passed to continue.
          attr_accessor :token

          ##
          # @private Create a new Sink::List with an array of Sink instances.
          def initialize arr = []
            super arr
          end

          ##
          # Whether there is a next page of sinks.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/logging"
          #
          #   logging = Google::Cloud::Logging.new
          #
          #   sinks = logging.sinks
          #   if sinks.next?
          #     next_sinks = sinks.next
          #   end
          #
          def next?
            !token.nil?
          end

          ##
          # Retrieve the next page of sinks.
          #
          # @return [Sink::List]
          #
          # @example
          #   require "google/cloud/logging"
          #
          #   logging = Google::Cloud::Logging.new
          #
          #   sinks = logging.sinks
          #   if sinks.next?
          #     next_sinks = sinks.next
          #   end
          #
          def next
            return nil unless next?
            ensure_service!
            list_grpc = @service.list_sinks token: token, max: @max
            self.class.from_grpc list_grpc, @service
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
          #   make to load all sinks. Default is no limit.
          # @yield [sink] The block for accessing each sink.
          # @yieldparam [Sink] sink The sink object.
          #
          # @return [Enumerator]
          #
          # @example Iterating each sink by passing a block:
          #   require "google/cloud/logging"
          #
          #   logging = Google::Cloud::Logging.new
          #   sinks = logging.sinks
          #
          #   sinks.all do |sink|
          #     puts "#{sink.name}: #{sink.filter} -> #{sink.destination}"
          #   end
          #
          # @example Using the enumerator by not passing a block:
          #   require "google/cloud/logging"
          #
          #   logging = Google::Cloud::Logging.new
          #   sinks = logging.sinks
          #
          #   all_names = sinks.all.map do |sink|
          #     sink.name
          #   end
          #
          # @example Limit the number of API calls made:
          #   require "google/cloud/logging"
          #
          #   logging = Google::Cloud::Logging.new
          #   sinks = logging.sinks
          #
          #   sinks.all(request_limit: 10) do |sink|
          #     puts "#{sink.name}: #{sink.filter} -> #{sink.destination}"
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
          # @private New Sink::List from a
          # Google::Logging::V2::ListSinksResponse object.
          def self.from_grpc grpc_list, service, max = nil
            sinks = new(Array(grpc_list.sinks).map do |grpc|
              Sink.from_grpc grpc, service
            end)
            token = grpc_list.next_page_token
            token = nil if token == ""
            sinks.instance_variable_set "@token", token
            sinks.instance_variable_set "@service", service
            sinks.instance_variable_set "@max", max
            sinks
          end

          protected

          ##
          # Raise an error unless an active service is available.
          def ensure_service!
            fail "Must have active service" unless @service
          end
        end
      end
    end
  end
end
