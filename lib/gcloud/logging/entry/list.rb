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
        # Retrieves all log entries by repeatedly loading {#next} until
        # {#next?} returns `false`. Returns the list instance for method
        # chaining.
        #
        # This method may make several API calls until all log entries are
        # retrieved. Be sure to use as narrow a search criteria as possible.
        # Please use with caution.
        #
        # @example
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   logging = gcloud.logging
        #   hour_ago = (Time.now - 60*60).utc.strftime('%FT%TZ')
        #   recent_errors = "timestamp >= \"#{hour_ago}\" severity >= ERROR"
        #   entries = logging.entries(filter: recent_errors).all
        #
        def all
          while next?
            next_records = self.next
            push(*next_records)
            self.token = next_records.token
          end
          self
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
