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
      class Entry
        ##
        # Entry::List is a special case Array with additional values.
        class List < DelegateClass(::Array)
          ##
          # If not empty, indicates that there are more records that match
          # the request and this value should be passed to continue.
          attr_accessor :token

          ##
          # @private Create a new Entry::List with an array of Entry instances.
          def initialize arr = []
            super arr
          end

          ##
          # Whether there is a next page of entries.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/logging"
          #
          #   logging = Google::Cloud::Logging.new
          #
          #   entries = logging.entries
          #   if entries.next?
          #     next_entries = entries.next
          #   end
          #
          def next?
            !token.nil?
          end

          ##
          # Retrieve the next page of entries.
          #
          # @return [Sink::List]
          #
          # @example
          #   require "google/cloud/logging"
          #
          #   logging = Google::Cloud::Logging.new
          #
          #   entries = logging.entries
          #   if entries.next?
          #     next_entries = entries.next
          #   end
          #
          def next
            return nil unless next?
            ensure_service!
            grpc = @service.list_entries token: token, resources: @resources,
                                         filter: @filter, order: @order,
                                         max: @max, projects: @projects
            self.class.from_grpc grpc, @service
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
          #   make to load all log entries. Default is no limit.
          # @yield [entry] The block for accessing each log entry.
          # @yieldparam [Entry] entry The log entry object.
          #
          # @return [Enumerator]
          #
          # @example Iterating each log entry by passing a block:
          #   require "google/cloud/logging"
          #
          #   logging = Google::Cloud::Logging.new
          #   entries = logging.entries order: "timestamp desc"
          #
          #   entries.all do |e|
          #     puts "[#{e.timestamp}] #{e.log_name} #{e.payload.inspect}"
          #   end
          #
          # @example Using the enumerator by not passing a block:
          #   require "google/cloud/logging"
          #
          #   logging = Google::Cloud::Logging.new
          #   entries = logging.entries order: "timestamp desc"
          #
          #   all_payloads = entries.all.map do |entry|
          #     entry.payload
          #   end
          #
          # @example Limit the number of API calls made:
          #   require "google/cloud/logging"
          #
          #   logging = Google::Cloud::Logging.new
          #   entries = logging.entries order: "timestamp desc"
          #
          #   entries.all(request_limit: 10) do |e|
          #     puts "[#{e.timestamp}] #{e.log_name} #{e.payload.inspect}"
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
          # @private New Entry::List from a
          # Google::Logging::V2::ListLogEntryResponse object.
          def self.from_grpc grpc_list, service, resources: nil, filter: nil,
                             order: nil, max: nil, projects: nil
            entries = new(Array(grpc_list.entries).map do |grpc_entry|
              Entry.from_grpc grpc_entry
            end)
            token = grpc_list.next_page_token
            token = nil if token == ""
            entries.instance_variable_set "@token", token
            entries.instance_variable_set "@service", service
            entries.instance_variable_set "@projects", projects
            entries.instance_variable_set "@resources", resources
            entries.instance_variable_set "@filter", filter
            entries.instance_variable_set "@order", order
            entries.instance_variable_set "@max", max
            entries
          end

          protected

          ##
          # @private Raise an error unless an active connection to the service
          # is available.
          def ensure_service!
            fail "Must have active connection to service" unless @service
          end
        end
      end
    end
  end
end
