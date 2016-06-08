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
  module Dns
    class Zone
      ##
      # Zone::List is a special case Array with additional values.
      class List < DelegateClass(::Array)
        ##
        # If not empty, indicates that there are more zones that match
        # the request and this value should be passed to continue.
        attr_accessor :token

        ##
        # @private Create a new Zone::List with an array of Zone instances.
        def initialize arr = []
          super arr
        end

        ##
        # Whether there a next page of zones.
        #
        # @return [Boolean]
        #
        # @example
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   dns = gcloud.dns
        #
        #   zones = dns.zones
        #   if zones.next?
        #     next_zones = zones.next
        #   end
        #
        def next?
          !token.nil?
        end

        ##
        # Retrieve the next page of zones.
        #
        # @return [Zone::List]
        #
        # @example
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   dns = gcloud.dns
        #
        #   zones = dns.zones
        #   if zones.next?
        #     next_zones = zones.next
        #   end
        #
        def next
          return nil unless next?
          ensure_connection!
          resp = @connection.list_zones token: token, max: @max
          if resp.success?
            Zone::List.from_response resp, @connection, @max
          else
            fail ApiError.from_response(resp)
          end
        end

        ##
        # Retrieves all zones by repeatedly loading {#next} until {#next?}
        # returns `false`. Calls the given block once for each zone, which is
        # passed as the parameter.
        #
        # An Enumerator is returned if no block is given.
        #
        # This method may make several API calls until all zones are retrieved.
        # Be sure to use as narrow a search criteria as possible. Please use
        # with caution.
        #
        # @param [Integer] request_limit The upper limit of API requests to make
        #   to load all zones. Default is no limit.
        # @yield [zone] The block for accessing each zone.
        # @yieldparam [Zone] zone The zone object.
        #
        # @return [Enumerator]
        #
        # @example Iterating each zone by passing a block:
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   dns = gcloud.dns
        #   zones = dns.zones
        #
        #   zones.all do |zone|
        #     puts zone.name
        #   end
        #
        # @example Using the enumerator by not passing a block:
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   dns = gcloud.dns
        #   zones = dns.zones
        #
        #   all_names = zones.all.map do |zone|
        #     zone.name
        #   end
        #
        # @example Limit the number of API calls made:
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   dns = gcloud.dns
        #   zones = dns.zones
        #
        #   zones.all(request_limit: 10) do |zone|
        #     puts zone.name
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
        # @private New Zones::List from a response object.
        def self.from_response resp, conn, max = nil
          zones = new(Array(resp.data["managedZones"]).map do |gapi_object|
            Zone.from_gapi gapi_object, conn
          end)
          zones.instance_variable_set "@token",      resp.data["nextPageToken"]
          zones.instance_variable_set "@connection", conn
          zones.instance_variable_set "@max",        max
          zones
        end

        protected

        ##
        # Raise an error unless an active connection is available.
        def ensure_connection!
          fail "Must have active connection" unless @connection
        end
      end
    end
  end
end
