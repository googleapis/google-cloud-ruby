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
    class Sink
      ##
      # Sink::List is a special case Array with additional values.
      class List < DelegateClass(::Array)
        ##
        # If not empty, indicates that there are more records that match
        # the request and this value should be passed to continue.
        attr_accessor :token

        ##
        # Create a new Sink::List with an array of Sink instances.
        def initialize arr = []
          super arr
        end

        ##
        # Whether there a next page of sinks.
        def next?
          !token.nil?
        end

        ##
        # Retrieve the next page of sinks.
        def next
          return nil unless next?
          ensure_service!
          list_grpc = @service.list_sinks token: token
          self.class.from_grpc list_grpc, @service
        rescue GRPC::BadStatus => e
          raise Gcloud::Error.from_error(e)
        end

        ##
        # Retrieves all sinks by repeatedly loading {#next?} until {#next?}
        # returns false. Returns the list instance for method chaining.
        #
        # @example
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   logging = gcloud.logging
        #   all_sinks = logging.sinks.all # Load all pages of sinks
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
        # @private New Sink::List from a Google::Logging::V2::ListSinksResponse
        # object.
        def self.from_grpc grpc_list, service
          sinks = new(Array(grpc_list.sinks).map do |grpc|
            Sink.from_grpc grpc, service
          end)
          sinks.instance_eval do
            @token = grpc_list.next_page_token
            @token = nil if @token == ""
            @service = service
          end
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
