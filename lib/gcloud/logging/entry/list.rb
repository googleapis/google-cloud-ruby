# Copyright 2016 Google Inc. All rights reserved.
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
        def next?
          !token.nil?
        end

        ##
        # Retrieve the next page of entries.
        def next
          return nil unless next?
          ensure_service!
          grpc = @service.list_entries token: token, projects: @projects,
                                       filter: @filter, order: @order, max: @max
          self.class.from_grpc grpc, @service
        rescue GRPC::BadStatus => e
          raise Gcloud::Error.from_error(e)
        end

        ##
        # Retrieves all entries by repeatedly loading {#next} until {#next?}
        # returns `false`. Calls the given block once for each result and cursor
        # combination, which are passed as parameters.
        #
        # An Enumerator is returned if no block is given.
        #
        # This method may make several API calls until all log entries are
        # retrieved. Be sure to use as narrow a search criteria as possible.
        # Please use with caution.
        #
        # @example Iterating each entry by passing a block:
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   logging = gcloud.logging
        #   entries = logging.entries order: "timestamp desc"
        #
        #   entries.all do |entry|
        #     puts "[#{e.timestamp}] #{e.log_name} #{e.payload.inspect}"
        #   end
        #
        # @example Using the enumerator by not passing a block:
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   logging = gcloud.logging
        #   entries = logging.entries order: "timestamp desc"
        #
        #   all_payloads = entries.all.map do |entry|
        #     entry.payload
        #   end
        #
        # @example Limit the number of API calls made:
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   logging = gcloud.logging
        #   entries = logging.entries order: "timestamp desc"
        #
        #   entries.all(max_api_calls: 10) do |entry|
        #     puts "[#{e.timestamp}] #{e.log_name} #{e.payload.inspect}"
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
        # @private New Entry::List from a
        # Google::Logging::V2::ListLogEntryResponse object.
        def self.from_grpc grpc_list, service, projects: nil, filter: nil,
                           order: nil, max: nil
          entries = new(Array(grpc_list.entries).map do |grpc_entry|
            Entry.from_grpc grpc_entry
          end)
          token = grpc_list.next_page_token
          token = nil if token == ""
          entries.instance_variable_set "@token", token
          entries.instance_variable_set "@service", service
          entries.instance_variable_set "@projects", projects
          entries.instance_variable_set "@filter", filter
          entries.instance_variable_set "@order", order
          entries.instance_variable_set "@max", max
          entries
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          fail "Must have active connection to service" unless @service
        end
      end
    end
  end
end
