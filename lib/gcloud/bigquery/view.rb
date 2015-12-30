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
require "gcloud/bigquery/table/list"
require "gcloud/bigquery/errors"

module Gcloud
  module Bigquery
    ##
    # # View
    #
    # A view is a virtual table defined by a SQL query. You can query views in
    # the browser tool, or by using a query job.
    #
    # BigQuery's views are logical views, not materialized views, which means
    # that the query that defines the view is re-executed every time the view is
    # queried. Queries are billed according to the total amount of data in all
    # table fields referenced directly or indirectly by the top-level query.
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   bigquery = gcloud.bigquery
    #   dataset = bigquery.dataset "my_dataset"
    #   view = dataset.create_view "my_view",
    #            "SELECT name, age FROM [proj:dataset.users]"
    #
    class View
      ##
      # @private The Connection object.
      attr_accessor :connection

      ##
      # @private The Google API Client object.
      attr_accessor :gapi

      ##
      # @private Create an empty Table object.
      def initialize
        @connection = nil
        @gapi = {}
      end

      ##
      # A unique ID for this table.
      # The ID must contain only letters (a-z, A-Z), numbers (0-9),
      # or underscores (_). The maximum length is 1,024 characters.
      #
      # @!group Attributes
      #
      def table_id
        @gapi["tableReference"]["tableId"]
      end

      ##
      # The ID of the `Dataset` containing this table.
      #
      # @!group Attributes
      #
      def dataset_id
        @gapi["tableReference"]["datasetId"]
      end

      ##
      # The ID of the `Project` containing this table.
      #
      # @!group Attributes
      #
      def project_id
        @gapi["tableReference"]["projectId"]
      end

      ##
      # @private
      # The gapi fragment containing the Project ID, Dataset ID, and Table ID as
      # a camel-cased hash.
      def table_ref
        table_ref = @gapi["tableReference"]
        table_ref = table_ref.to_hash if table_ref.respond_to? :to_hash
        table_ref
      end

      ##
      # The name of the table.
      #
      # @!group Attributes
      #
      def name
        @gapi["friendlyName"]
      end

      ##
      # Updates the name of the table.
      #
      # @!group Lifecycle
      #
      def name= new_name
        patch_gapi! name: new_name
      end

      ##
      # A string hash of the dataset.
      #
      # @!group Attributes
      #
      def etag
        ensure_full_data!
        @gapi["etag"]
      end

      ##
      # A URL that can be used to access the dataset using the REST API.
      #
      # @!group Attributes
      #
      def api_url
        ensure_full_data!
        @gapi["selfLink"]
      end

      ##
      # The description of the table.
      #
      # @!group Attributes
      #
      def description
        ensure_full_data!
        @gapi["description"]
      end

      ##
      # Updates the description of the table.
      #
      # @!group Lifecycle
      #
      def description= new_description
        patch_gapi! description: new_description
      end

      ##
      # The time when this table was created.
      #
      # @!group Attributes
      #
      def created_at
        ensure_full_data!
        Time.at(@gapi["creationTime"] / 1000.0)
      end

      ##
      # The time when this table expires.
      # If not present, the table will persist indefinitely.
      # Expired tables will be deleted and their storage reclaimed.
      #
      # @!group Attributes
      #
      def expires_at
        ensure_full_data!
        return nil if @gapi["expirationTime"].nil?
        Time.at(@gapi["expirationTime"] / 1000.0)
      end

      ##
      # The date when this table was last modified.
      #
      # @!group Attributes
      #
      def modified_at
        ensure_full_data!
        Time.at(@gapi["lastModifiedTime"] / 1000.0)
      end

      ##
      # Checks if the table's type is "TABLE".
      #
      # @!group Attributes
      #
      def table?
        @gapi["type"] == "TABLE"
      end

      ##
      # Checks if the table's type is "VIEW".
      #
      # @!group Attributes
      #
      def view?
        @gapi["type"] == "VIEW"
      end

      ##
      # The geographic location where the table should reside. Possible
      # values include EU and US. The default value is US.
      #
      # @!group Attributes
      #
      def location
        ensure_full_data!
        @gapi["location"]
      end

      ##
      # The schema of the table.
      #
      # @!group Attributes
      #
      def schema
        ensure_full_data!
        s = @gapi["schema"]
        s = s.to_hash if s.respond_to? :to_hash
        s = {} if s.nil?
        s
      end

      ##
      # The fields of the table.
      #
      # @!group Attributes
      #
      def fields
        f = schema["fields"]
        f = f.to_hash if f.respond_to? :to_hash
        f = [] if f.nil?
        f
      end

      ##
      # The names of the columns in the table.
      #
      # @!group Attributes
      #
      def headers
        fields.map { |f| f["name"] }
      end

      ##
      # The query that executes each time the view is loaded.
      #
      # @!group Attributes
      #
      def query
        @gapi["view"]["query"] if @gapi["view"]
      end

      ##
      # Updates the query that executes each time the view is loaded.
      #
      # @see https://cloud.google.com/bigquery/query-reference BigQuery Query
      #   Reference
      #
      # @param [String] new_query The query that defines the view.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   view = dataset.table "my_view"
      #
      #   view.query = "SELECT first_name FROM [my_project:my_dataset.my_table]"
      #
      # @!group Lifecycle
      #
      def query= new_query
        patch_gapi! query: new_query
      end

      ##
      # Runs a query to retrieve all data from the view.
      #
      # @param [Integer] max The maximum number of rows of data to return per
      #   page of results. Setting this flag to a small value such as 1000 and
      #   then paging through results might improve reliability when the query
      #   result set is large. In addition to this limit, responses are also
      #   limited to 10 MB. By default, there is no maximum row count, and only
      #   the byte limit applies.
      # @param [Integer] timeout How long to wait for the query to complete, in
      #   milliseconds, before the request times out and returns. Note that this
      #   is only a timeout for the request, not the query. If the query takes
      #   longer to run than the timeout value, the call returns without any
      #   results and with QueryData#complete? set to false. The default value
      #   is 10000 milliseconds (10 seconds).
      # @param [Boolean] cache Whether to look for the result in the query
      #   cache. The query cache is a best-effort cache that will be flushed
      #   whenever tables in the query are modified. The default value is true.
      #   For more information, see [query
      #   caching](https://developers.google.com/bigquery/querying-data).
      # @param [Boolean] dryrun If set to `true`, BigQuery doesn't run the job.
      #   Instead, if the query is valid, BigQuery returns statistics about the
      #   job such as how many bytes would be processed. If the query is
      #   invalid, an error returns. The default value is `false`.
      #
      # @return [Gcloud::Bigquery::QueryData]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   view = dataset.table "my_view"
      #
      #   data = view.data
      #   data.each do |row|
      #     puts row["first_name"]
      #   end
      #   more_data = data.next if data.next?
      #
      # @!group Data
      #
      def data max: nil, timeout: nil, cache: nil, dryrun: nil
        sql = "SELECT * FROM #{@gapi['id']}"
        ensure_connection!
        options = { max: max, timeout: timeout, cache: cache, dryrun: dryrun }
        resp = connection.query sql, options
        if resp.success?
          QueryData.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Permanently deletes the table.
      #
      # @return [Boolean] Returns `true` if the table was deleted.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #
      #   table.delete
      #
      # @!group Lifecycle
      #
      def delete
        ensure_connection!
        resp = connection.delete_table dataset_id, table_id
        if resp.success?
          true
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Reloads the table with current data from the BigQuery service.
      #
      # @!group Lifecycle
      #
      def reload!
        ensure_connection!
        resp = connection.get_table dataset_id, table_id
        if resp.success?
          @gapi = resp.data
        else
          fail ApiError.from_response(resp)
        end
      end
      alias_method :refresh!, :reload!

      ##
      # @private New Table from a Google API Client object.
      def self.from_gapi gapi, conn
        new.tap do |f|
          f.gapi = gapi
          f.connection = conn
        end
      end

      protected

      ##
      # Raise an error unless an active connection is available.
      def ensure_connection!
        fail "Must have active connection" unless connection
      end

      def patch_gapi! options = {}
        ensure_connection!
        resp = connection.patch_table dataset_id, table_id, options
        if resp.success?
          @gapi = resp.data
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Load the complete representation of the table if it has been
      # only partially loaded by a request to the API list method.
      def ensure_full_data!
        reload_gapi! unless data_complete?
      end

      def reload_gapi!
        ensure_connection!
        resp = connection.get_table dataset_id, table_id
        if resp.success?
          @gapi = resp.data
        else
          fail ApiError.from_response(resp)
        end
      end

      def data_complete?
        !@gapi["creationTime"].nil?
      end
    end
  end
end
