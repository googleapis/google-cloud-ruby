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
  module Bigquery
    class Dataset
      ##
      # Dataset::List is a special case Array with additional values.
      class List < DelegateClass(::Array)
        ##
        # If not empty, indicates that there are more records that match
        # the request and this value should be passed to continue.
        attr_accessor :token

        # A hash of this page of results.
        attr_accessor :etag

        ##
        # @private Create a new Dataset::List with an array of datasets.
        def initialize arr = []
          super arr
        end

        ##
        # Whether there is a next page of datasets.
        #
        # @return [Boolean]
        #
        # @example
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   bigquery = gcloud.bigquery
        #
        #   datasets = bigquery.datasets
        #   if datasets.next?
        #     next_datasets = datasets.next
        #   end
        def next?
          !token.nil?
        end

        ##
        # Retrieve the next page of datasets.
        #
        # @return [Dataset::List]
        #
        # @example
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   bigquery = gcloud.bigquery
        #
        #   datasets = bigquery.datasets
        #   if datasets.next?
        #     next_datasets = datasets.next
        #   end
        def next
          return nil unless next?
          ensure_connection!
          options = { all: @hidden, token: token, max: @max }
          resp = @connection.list_datasets options
          if resp.success?
            self.class.from_response resp, @connection
          else
            fail ApiError.from_response(resp)
          end
        end

        ##
        # Retrieves all datasets by repeatedly loading {#next} until {#next?}
        # returns `false`. Calls the given block once for each dataset, which is
        # passed as the parameter.
        #
        # An Enumerator is returned if no block is given.
        #
        # This method may make several API calls until all datasets are
        # retrieved. Be sure to use as narrow a search criteria as possible.
        # Please use with caution.
        #
        # @param [Integer] request_limit The upper limit of API requests to make
        #   to load all datasets. Default is no limit.
        # @yield [dataset] The block for accessing each dataset.
        # @yieldparam [Dataset] dataset The dataset object.
        #
        # @return [Enumerator]
        #
        # @example Iterating each result by passing a block:
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   bigquery = gcloud.bigquery
        #
        #   bigquery.datasets.all do |dataset|
        #     puts dataset.name
        #   end
        #
        # @example Using the enumerator by not passing a block:
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   bigquery = gcloud.bigquery
        #
        #   all_names = bigquery.datasets.all.map do |dataset|
        #     dataset.name
        #   end
        #
        # @example Limit the number of API calls made:
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   bigquery = gcloud.bigquery
        #
        #   bigquery.datasets.all(request_limit: 10) do |dataset|
        #     puts dataset.name
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
        # @private New Dataset::List from a response object.
        def self.from_response resp, conn, hidden = nil, max = nil
          datasets = List.new(Array(resp.data["datasets"]).map do |gapi_object|
            Dataset.from_gapi gapi_object, conn
          end)
          datasets.instance_variable_set "@token", resp.data["nextPageToken"]
          datasets.instance_variable_set "@etag",  resp.data["etag"]
          datasets.instance_variable_set "@connection", conn
          datasets.instance_variable_set "@hidden",     hidden
          datasets.instance_variable_set "@max",        max
          datasets
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
