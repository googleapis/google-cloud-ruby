#--
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

module Gcloud
  module Bigquery
    ##
    # = QueryJob
    #
    # A Job subclass representing a query operation that may be performed
    # on a Table. A QueryJob instance is created when you call
    # Project#query_job, Dataset#query_job, or View#data.
    #
    # See {Querying Data}[https://cloud.google.com/bigquery/querying-data]
    # and the {Jobs API
    # reference}[https://cloud.google.com/bigquery/docs/reference/v2/jobs]
    # for details.
    #
    class QueryJob < Job
      ##
      # Checks if the priority for the query is +BATCH+.
      def batch?
        val = config["query"]["priority"]
        val == "BATCH"
      end

      ##
      # Checks if the priority for the query is +INTERACTIVE+.
      def interactive?
        val = config["query"]["priority"]
        return true if val.nil?
        val == "INTERACTIVE"
      end

      ##
      # Checks if the the query job allows arbitrarily large results at a slight
      # cost to performance.
      def large_results?
        val = config["query"]["preserveNulls"]
        return false if val.nil?
        val
      end

      ##
      # Checks if the query job looks for an existing result in the query cache.
      # For more information, see {Query
      # Caching}[https://cloud.google.com/bigquery/querying-data#querycaching].
      def cache?
        val = config["query"]["useQueryCache"]
        return false if val.nil?
        val
      end

      ##
      # Checks if the query job flattens nested and repeated fields in the query
      # results. The default is +true+. If the value is +false+, #large_results?
      # should return +true+.
      def flatten?
        val = config["query"]["flattenResults"]
        return true if val.nil?
        val
      end

      ##
      # Checks if the query results are from the query cache.
      def cache_hit?
        stats["query"]["cacheHit"]
      end

      ##
      # The number of bytes processed by the query.
      def bytes_processed
        stats["query"]["totalBytesProcessed"]
      end

      ##
      # The table in which the query results are stored.
      def destination
        table = config["query"]["destinationTable"]
        return nil unless table
        retrieve_table table["projectId"],
                       table["datasetId"],
                       table["tableId"]
      end

      ##
      # Retrieves the query results for the job.
      #
      # === Parameters
      #
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:token]</code>::
      #   Page token, returned by a previous call, identifying the result set.
      #   (+String+)
      # <code>options[:max]</code>::
      #   Maximum number of results to return. (+Integer+)
      # <code>options[:start]</code>::
      #   Zero-based index of the starting row to read. (+Integer+)
      # <code>options[:timeout]</code>::
      #   How long to wait for the query to complete, in milliseconds, before
      #   returning. Default is 10,000 milliseconds (10 seconds). (+Integer+)
      #
      # === Returns
      #
      # Gcloud::Bigquery::QueryData
      #
      # === Example
      #
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
      #   data.each do |row|
      #     puts row["word"]
      #   end
      #   data = data.next if data.next?
      #
      def query_results options = {}
        ensure_connection!
        resp = connection.job_query_results job_id, options
        if resp.success?
          QueryData.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end
    end
  end
end
