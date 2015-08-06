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
    # = Query Job
    class QueryJob < Job
      def batch?
        val = config["query"]["priority"]
        val == "BATCH"
      end

      def interactive?
        val = config["query"]["priority"]
        return true if val.nil?
        val == "INTERACTIVE"
      end

      def large_results?
        val = config["query"]["preserveNulls"]
        return false if val.nil?
        val
      end

      def cache?
        val = config["query"]["useQueryCache"]
        return false if val.nil?
        val
      end

      def flatten?
        val = config["query"]["flattenResults"]
        return true if val.nil?
        val
      end

      ##
      # Whether the query result was fetched from the query cache.
      def cache_hit?
        stats["query"]["cacheHit"]
      end

      ##
      # Total bytes processed for this job.
      def bytes_processed
        stats["query"]["totalBytesProcessed"]
      end

      def destination
        table = config["query"]["destinationTable"]
        return nil unless table
        retrieve_table table["projectId"],
                       table["datasetId"],
                       table["tableId"]
      end

      ##
      # Get the data for the job.
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
