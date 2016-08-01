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


require "google/cloud/bigquery/service"
require "google/cloud/bigquery/data"

module Google
  module Cloud
    module Bigquery
      ##
      # # QueryData
      #
      # Represents Data returned from a query a a list of name/value pairs.
      class QueryData < Data
        ##
        # @private The Service object.
        attr_accessor :service

        # @private
        def initialize arr = []
          @job = nil
          super
        end

        # The total number of bytes processed for this query.
        def total_bytes
          Integer @gapi.total_bytes_processed
        rescue
          nil
        end

        # Whether the query has completed or not. When data is present this will
        # always be `true`. When `false`, `total` will not be available.
        def complete?
          @gapi.job_complete
        end

        # Whether the query result was fetched from the query cache.
        def cache_hit?
          @gapi.cache_hit
        end

        ##
        # The schema of the data.
        def schema
          Schema.from_gapi(@gapi.schema).freeze
        end

        ##
        # The fields of the data.
        def fields
          f = schema.fields
          f = f.to_hash if f.respond_to? :to_hash
          f = [] if f.nil?
          f
        end

        ##
        # The name of the columns in the data.
        def headers
          fields.map(&:name)
        end

        ##
        # Whether there is a next page of query data.
        #
        # @return [Boolean]
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   bigquery = gcloud.bigquery
        #   job = bigquery.job "my_job"
        #
        #   data = job.query_results
        #   if data.next?
        #     next_data = data.next
        #   end
        #
        def next?
          !token.nil?
        end

        ##
        # Retrieve the next page of query data.
        #
        # @return [QueryData]
        #
        # @example
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   bigquery = gcloud.bigquery
        #   job = bigquery.job "my_job"
        #
        #   data = job.query_results
        #   if data.next?
        #     next_data = data.next
        #   end
        #
        def next
          return nil unless next?
          ensure_service!
          gapi = service.job_query_results job_id, token: token
          QueryData.from_gapi gapi, service
        end

        ##
        # Retrieves all rows by repeatedly loading {#next} until {#next?}
        # returns `false`. Calls the given block once for each row, which is
        # passed as the parameter.
        #
        # An Enumerator is returned if no block is given.
        #
        # This method may make several API calls until all rows are retrieved.
        # Be sure to use as narrow a search criteria as possible. Please use
        # with caution.
        #
        # @param [Integer] request_limit The upper limit of API requests to make
        #   to load all data. Default is no limit.
        # @yield [row] The block for accessing each row of data.
        # @yieldparam [Hash] row The row object.
        #
        # @return [Enumerator]
        #
        # @example Iterating each row by passing a block:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   bigquery = gcloud.bigquery
        #   job = bigquery.job "my_job"
        #
        #   data = job.query_results
        #   data.all do |row|
        #     puts row["word"]
        #   end
        #
        # @example Using the enumerator by not passing a block:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   bigquery = gcloud.bigquery
        #   job = bigquery.job "my_job"
        #
        #   data = job.query_results
        #   words = data.all.map do |row|
        #     row["word"]
        #   end
        #
        # @example Limit the number of API calls made:
        #   require "google/cloud"
        #
        #   gcloud = Google::Cloud.new
        #   bigquery = gcloud.bigquery
        #   job = bigquery.job "my_job"
        #
        #   data = job.query_results
        #   data.all(request_limit: 10) do |row|
        #     puts row["word"]
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
        # The BigQuery {Job} that was created to run the query.
        def job
          return @job if @job
          return nil unless job?
          ensure_service!
          gapi = service.get_job job_id
          @job = Job.from_gapi gapi, service
        rescue Google::Cloud::NotFoundError
          nil
        end

        ##
        # @private New Data from a response object.
        def self.from_gapi gapi, service
          if gapi.schema.nil?
            formatted_rows = []
          else
            formatted_rows = format_rows gapi.rows,
                                         gapi.schema.fields
          end

          data = new formatted_rows
          data.gapi = gapi
          data.service = service
          data
        end

        protected

        ##
        # Raise an error unless an active connection is available.
        def ensure_service!
          fail "Must have active connection" unless service
        end

        def job?
          @gapi.job_reference && @gapi.job_reference.job_id
        end

        def job_id
          @gapi.job_reference.job_id
        end
      end
    end
  end
end
