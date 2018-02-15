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
          #   require "google/cloud/dns"
          #
          #   dns = Google::Cloud::Dns.new
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
          #   require "google/cloud/dns"
          #
          #   dns = Google::Cloud::Dns.new
          #
          #   zones = dns.zones
          #   if zones.next?
          #     next_zones = zones.next
          #   end
          #
          def next
            return nil unless next?
            ensure_service!
            gapi = @service.list_zones token: token, max: @max
            Zone::List.from_gapi gapi, @service, @max
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
          #   make to load all zones. Default is no limit.
          # @yield [zone] The block for accessing each zone.
          # @yieldparam [Zone] zone The zone object.
          #
          # @return [Enumerator]
          #
          # @example Iterating each zone by passing a block:
          #   require "google/cloud/dns"
          #
          #   dns = Google::Cloud::Dns.new
          #   zones = dns.zones
          #
          #   zones.all do |zone|
          #     puts zone.name
          #   end
          #
          # @example Using the enumerator by not passing a block:
          #   require "google/cloud/dns"
          #
          #   dns = Google::Cloud::Dns.new
          #   zones = dns.zones
          #
          #   all_names = zones.all.map do |zone|
          #     zone.name
          #   end
          #
          # @example Limit the number of API calls made:
          #   require "google/cloud/dns"
          #
          #   dns = Google::Cloud::Dns.new
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
          # @private New Zones::List from a ListManagedZonesResponse object.
          def self.from_gapi gapi, conn, max = nil
            zones = new(Array(gapi.managed_zones).map do |g|
              Zone.from_gapi g, conn
            end)
            zones.instance_variable_set "@token",   gapi.next_page_token
            zones.instance_variable_set "@service", conn
            zones.instance_variable_set "@max",     max
            zones
          end

          protected

          ##
          # Raise an error unless an active connection is available.
          def ensure_service!
            raise "Must have active connection" unless @service
          end
        end
      end
    end
  end
end
