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


require "gcloud/bigquery/data"

module Gcloud
  module Bigquery
    ##
    # # QueryData
    #
    # Represents Data returned from a query a a list of name/value pairs.
    class QueryData < Data
      ##
      # @private The Connection object.
      attr_accessor :connection

      # @private
      def initialize arr = []
        @job = nil
        super
      end

      # The total number of bytes processed for this query.
      def total_bytes
        @gapi["totalBytesProcessed"]
      end

      # Whether the query has completed or not. When data is present this will
      # always be `true`. When `false`, `total` will not be available.
      def complete?
        @gapi["jobComplete"]
      end

      # Whether the query result was fetched from the query cache.
      def cache_hit?
        @gapi["cacheHit"]
      end

      ##
      # The schema of the data.
      def schema
        s = @gapi["schema"]
        s = s.to_hash if s.respond_to? :to_hash
        s = {} if s.nil?
        s
      end

      ##
      # The fields of the data.
      def fields
        f = schema["fields"]
        f = f.to_hash if f.respond_to? :to_hash
        f = [] if f.nil?
        f
      end

      ##
      # The name of the columns in the data.
      def headers
        fields.map { |f| f["name"] }
      end

      ##
      # Is there a next page of data?
      def next?
        !token.nil?
      end

      def next
        return nil unless next?
        ensure_connection!
        resp = connection.job_query_results job_id, token: token
        if resp.success?
          QueryData.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Retrieves all rows by repeatedly loading {#next} until {#next?} returns
      # `false`. Calls the given block once for each row, which is passed as the
      # parameter.
      #
      # An Enumerator is returned if no block is given.
      #
      # This method may make several API calls until all rows are retrieved. Be
      # sure to use as narrow a search criteria as possible. Please use with
      # caution.
      #
      # @example Iterating each row by passing a block:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #
      #   q = "SELECT word FROM publicdata:samples.shakespeare"
      #   job = bigquery.query_job q
      #
      #   job.wait_until_done!
      #   data = job.query_results
      #   data.all do |row|
      #     puts row["word"]
      #   end
      #
      # @example Using the enumerator by not passing a block:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #
      #   q = "SELECT word FROM publicdata:samples.shakespeare"
      #   job = bigquery.query_job q
      #
      #   job.wait_until_done!
      #   data = job.query_results
      #   words = data.all.map do |row|
      #     row["word"]
      #   end
      #
      # @example Limit the number of API calls made:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #
      #   q = "SELECT word FROM publicdata:samples.shakespeare"
      #   job = bigquery.query_job q
      #
      #   job.wait_until_done!
      #   data = job.query_results
      #   data.all(max_api_calls: 10) do |row|
      #     puts row["word"]
      #   end
      #
      def all max_api_calls: nil
        max_api_calls = max_api_calls.to_i if max_api_calls
        return enum_for(:all, max_api_calls: max_api_calls) unless block_given?
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
      # The BigQuery {Job} that was created to run the query.
      def job
        return @job if @job
        return nil unless job?
        ensure_connection!
        resp = connection.get_job job_id
        if resp.success?
          @job = Job.from_gapi resp.data, connection
        else
          return nil if resp.status == 404
          fail ApiError.from_response(resp)
        end
      end

      ##
      # @private New Data from a response object.
      def self.from_gapi gapi, connection
        if gapi["schema"].nil?
          formatted_rows = []
        else
          formatted_rows = format_rows gapi["rows"],
                                       gapi["schema"]["fields"]
        end

        data = new formatted_rows
        data.gapi = gapi
        data.connection = connection
        data
      end

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless connection
      end

      def job?
        @gapi["jobReference"] && @gapi["jobReference"]["jobId"]
      end

      def job_id
        @gapi["jobReference"]["jobId"]
      end
    end
  end
end
