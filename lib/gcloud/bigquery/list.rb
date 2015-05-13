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
    # Bigquery::List is a special case Array with additional values.
    class List < DelegateClass(::Array)
      ##
      # If not empty, indicates that there are more records that match
      # the request and this value should be passed to continue.
      attr_accessor :token

      ##
      # Create a new Bigquery::List with an array of values.
      def initialize arr = [], token = nil
        super arr
        @token = token
      end

      ##
      # Create a List of Dataset objects from an API response.
      def self.datasets_from_resp resp, conn #:nodoc:
        datasets = Array(resp.data["datasets"]).map do |gapi_object|
          Dataset.from_gapi gapi_object, conn
        end
        new datasets, resp.data["nextPageToken"]
      end

      ##
      # Create a List of Table objects from an API response.
      def self.tables_from_resp resp, conn #:nodoc:
        tables = Array(resp.data["tables"]).map do |gapi_object|
          Table.from_gapi gapi_object, conn
        end
        new tables, resp.data["nextPageToken"]
      end
    end
  end
end
