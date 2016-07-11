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
    class Change
      ##
      # Change::List is a special case Array with additional values.
      class List < DelegateClass(::Array)
        ##
        # If not empty, indicates that there are more changes that match
        # the request and this value should be passed to continue.
        attr_accessor :token

        ##
        # @private Create a new Change::List with an array of Change instances.
        def initialize arr = []
          super arr
        end

        ##
        # Whether there a next page of changes.
        #
        # @return [Boolean]
        #
        # @example
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   dns = gcloud.dns
        #   zone = dns.zone "example-com"
        #
        #   changes = zone.changes
        #   if changes.next?
        #     next_changes = changes.next
        #   end
        #
        def next?
          !token.nil?
        end

        ##
        # Retrieve the next page of changes.
        #
        # @return [Change::List]
        #
        # @example
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   dns = gcloud.dns
        #   zone = dns.zone "example-com"
        #
        #   changes = zone.changes
        #   if changes.next?
        #     next_changes = changes.next
        #   end
        #
        def next
          return nil unless next?
          ensure_zone!
          @zone.changes token: token, max: @max, order: @order
        end

        ##
        # Retrieves all changes by repeatedly loading {#next} until {#next?}
        # returns `false`. Calls the given block once for each change, which is
        # passed as the parameter.
        #
        # An Enumerator is returned if no block is given.
        #
        # This method may make several API calls until all changes are
        # retrieved. Be sure to use as narrow a search criteria as possible.
        # Please use with caution.
        #
        # @param [Integer] request_limit The upper limit of API requests to make
        #   to load all changes. Default is no limit.
        # @yield [change] The block for accessing each change.
        # @yieldparam [Change] change The change object.
        #
        # @return [Enumerator]
        #
        # @example Iterating each change by passing a block:
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   dns = gcloud.dns
        #   zone = dns.zone "example-com"
        #   changes = zone.changes
        #
        #   changes.all do |change|
        #     puts change.name
        #   end
        #
        # @example Using the enumerator by not passing a block:
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   dns = gcloud.dns
        #   zone = dns.zone "example-com"
        #   changes = zone.changes
        #
        #   all_names = changes.all.map do |change|
        #     change.name
        #   end
        #
        # @example Limit the number of API calls made:
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   dns = gcloud.dns
        #   zone = dns.zone "example-com"
        #   changes = zone.changes
        #
        #   changes.all(request_limit: 10) do |change|
        #     puts change.name
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
        # @private New Changes::List from a response object.
        def self.from_gapi gapi, zone, max = nil, order = nil
          changes = new(Array(gapi.changes).map do |g|
            Change.from_gapi g, zone
          end)
          changes.instance_variable_set "@token", gapi.next_page_token
          changes.instance_variable_set "@zone",  zone
          changes.instance_variable_set "@max",   max
          changes.instance_variable_set "@order", order
          changes
        end

        protected

        ##
        # Raise an error unless an active connection is available.
        def ensure_zone!
          fail "Must have active connection" unless @zone
        end
      end
    end
  end
end
