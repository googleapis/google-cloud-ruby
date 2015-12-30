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
        formatted_rows = format_rows gapi["rows"],
                                     gapi["schema"]["fields"]

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
