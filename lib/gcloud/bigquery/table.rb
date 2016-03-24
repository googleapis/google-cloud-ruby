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


require "gcloud/bigquery/view"
require "gcloud/bigquery/data"
require "gcloud/bigquery/table/list"
require "gcloud/bigquery/table/schema"
require "gcloud/bigquery/errors"
require "gcloud/bigquery/insert_response"
require "gcloud/upload"

module Gcloud
  module Bigquery
    ##
    # # Table
    #
    # A named resource representing a BigQuery table that holds zero or more
    # records. Every table is defined by a schema that may contain nested and
    # repeated fields.
    #
    # @see https://cloud.google.com/bigquery/preparing-data-for-bigquery
    #   Preparing Data for BigQuery
    #
    # @example
    #   require "gcloud"
    #
    #   gcloud = Gcloud.new
    #   bigquery = gcloud.bigquery
    #   dataset = bigquery.dataset "my_dataset"
    #
    #   table = dataset.create_table "my_table" do |schema|
    #     schema.string "first_name", mode: :required
    #     schema.record "cities_lived", mode: :repeated do |nested_schema|
    #       nested_schema.string "place", mode: :required
    #       nested_schema.integer "number_of_years", mode: :required
    #     end
    #   end
    #
    #   row = {
    #     "first_name" => "Alice",
    #     "cities_lived" => [
    #       {
    #         "place" => "Seattle",
    #         "number_of_years" => 5
    #       },
    #       {
    #         "place" => "Stockholm",
    #         "number_of_years" => 6
    #       }
    #     ]
    #   }
    #   table.insert row
    #
    class Table
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
      # The combined Project ID, Dataset ID, and Table ID for this table, in the
      # format specified by the [Query
      # Reference](https://cloud.google.com/bigquery/query-reference#from):
      # `project_name:datasetId.tableId`. To use this value in queries see
      # {#query_id}.
      #
      # @!group Attributes
      #
      def id
        @gapi["id"]
      end

      ##
      # The value returned by {#id}, wrapped in square brackets if the Project
      # ID contains dashes, as specified by the [Query
      # Reference](https://cloud.google.com/bigquery/query-reference#from).
      # Useful in queries.
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #
      #   data = bigquery.query "SELECT name FROM #{table.query_id}"
      #
      # @!group Attributes
      #
      def query_id
        project_id["-"] ? "[#{id}]" : id
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
      # @!group Attributes
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
      # @!group Attributes
      #
      def description= new_description
        patch_gapi! description: new_description
      end

      ##
      # The number of bytes in the table.
      #
      # @!group Data
      #
      def bytes_count
        ensure_full_data!
        @gapi["numBytes"]
      end

      ##
      # The number of rows in the table.
      #
      # @!group Data
      #
      def rows_count
        ensure_full_data!
        @gapi["numRows"]
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
      # Returns the table's schema as hash containing the keys and values
      # returned by the Google Cloud BigQuery [Rest API
      # ](https://cloud.google.com/bigquery/docs/reference/v2/tables#resource).
      # This method can also be used to set, replace, or add to the schema by
      # passing a block. See {Table::Schema} for available methods. To set the
      # schema by passing a hash instead, use {#schema=}.
      #
      # @param [Boolean] replace Whether to replace the existing schema with the
      #   new schema. If `true`, the fields will replace the existing schema. If
      #   `false`, the fields will be added to the existing schema. When a table
      #   already contains data, schema changes must be additive. Thus, the
      #   default value is `false`.
      # @yield [schema] a block for setting the schema
      # @yieldparam [Table::Schema] schema the object accepting the schema
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.create_table "my_table"
      #
      #   table.schema do |schema|
      #     schema.string "first_name", mode: :required
      #     schema.record "cities_lived", mode: :repeated do |nested_schema|
      #       nested_schema.string "place", mode: :required
      #       nested_schema.integer "number_of_years", mode: :required
      #     end
      #   end
      #
      # @!group Attributes
      #
      def schema replace: false
        ensure_full_data!
        g = @gapi
        g = g.to_hash if g.respond_to? :to_hash
        s = g["schema"] ||= {}
        return s unless block_given?
        s = nil if replace
        schema_builder = Schema.new s
        yield schema_builder
        self.schema = schema_builder.schema if schema_builder.changed?
      end

      ##
      # Updates the schema of the table.
      # To update the schema using a block instead, use #schema.
      #
      # @param [Hash] new_schema A hash containing keys and values as specified
      #   by the Google Cloud BigQuery [Rest API
      #   ](https://cloud.google.com/bigquery/docs/reference/v2/tables#resource)
      #   .
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.create_table "my_table"
      #
      #   schema = {
      #     "fields" => [
      #       {
      #         "name" => "first_name",
      #         "type" => "STRING",
      #         "mode" => "REQUIRED"
      #       },
      #       {
      #         "name" => "age",
      #         "type" => "INTEGER",
      #         "mode" => "REQUIRED"
      #       }
      #     ]
      #   }
      #   table.schema = schema
      #
      # @!group Attributes
      #
      def schema= new_schema
        patch_gapi! schema: new_schema
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
      # Retrieves data from the table.
      #
      # @param [String] token Page token, returned by a previous call,
      #   identifying the result set.
      #
      # @param [Integer] max Maximum number of results to return.
      # @param [Integer] start Zero-based index of the starting row to read.
      #
      # @return [Gcloud::Bigquery::Data]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #
      #   data = table.data
      #   data.each do |row|
      #     puts row["first_name"]
      #   end
      #   more_data = table.data token: data.token
      #
      # @!group Data
      #
      def data token: nil, max: nil, start: nil
        ensure_connection!
        options = { token: token, max: max, start: start }
        resp = connection.list_tabledata dataset_id, table_id, options
        if resp.success?
          Data.from_response resp, self
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Copies the data from the table to another table.
      # The destination table argument can also be a string identifier as
      # specified by the [Query
      # Reference](https://cloud.google.com/bigquery/query-reference#from):
      # `project_name:datasetId.tableId`. This is useful for referencing tables
      # in other projects and datasets.
      #
      # @param [Table, String] destination_table The destination for the copied
      #   data.
      # @param [String] create Specifies whether the job is allowed to create
      #   new tables.
      #
      #   The following values are supported:
      #
      #   * `needed` - Create the table if it does not exist.
      #   * `never` - The table must already exist. A 'notFound' error is
      #     raised if the table does not exist.
      # @param [String] write Specifies how to handle data already present in
      #   the destination table. The default value is `empty`.
      #
      #   The following values are supported:
      #
      #   * `truncate` - BigQuery overwrites the table data.
      #   * `append` - BigQuery appends the data to the table.
      #   * `empty` - An error will be returned if the destination table already
      #     contains data.
      #
      # @return [Gcloud::Bigquery::CopyJob]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #   destination_table = dataset.table "my_destination_table"
      #
      #   copy_job = table.copy destination_table
      #
      # @example Passing a string identifier for the destination table:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #
      #   copy_job = table.copy "other-project:other_dataset.other_table"
      #
      # @!group Data
      #
      def copy destination_table, create: nil, write: nil, dryrun: nil
        ensure_connection!
        options = { create: create, write: write, dryrun: dryrun }
        resp = connection.copy_table table_ref,
                                     get_table_ref(destination_table),
                                     options
        if resp.success?
          Job.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # @private
      # Links the table to a source table identified by a URI.
      #
      # @param [String] source_url The URI of source table to link.
      # @param [String] create Specifies whether the job is allowed to create
      #   new tables.
      #
      #   The following values are supported:
      #
      #   * `needed` - Create the table if it does not exist.
      #   * `never` - The table must already exist. A 'notFound' error is
      #     raised if the table does not exist.
      # @param [String] write Specifies how to handle data already present in
      #   the destination table. The default value is `empty`.
      #
      #   The following values are supported:
      #
      #   * `truncate` - BigQuery overwrites the table data.
      #   * `append` - BigQuery appends the data to the table.
      #   * `empty` - An error will be returned if the destination table already
      #     contains data.
      #
      # @return [Gcloud::Bigquery::Job]
      #
      # @!group Data
      #
      def link source_url, create: nil, write: nil, dryrun: nil
        ensure_connection!
        options = { create: create, write: write, dryrun: dryrun }
        resp = connection.link_table table_ref, source_url, options
        if resp.success?
          Job.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Extract the data from the table to a Google Cloud Storage file.
      #
      # @see https://cloud.google.com/bigquery/exporting-data-from-bigquery
      #   Exporting Data From BigQuery
      #
      # @param [Gcloud::Storage::File, String, Array<String>] extract_url The
      #   Google Storage file or file URI pattern(s) to which BigQuery should
      #   extract the table data.
      # @param [String] format The exported file format. The default value is
      #   `csv`.
      #
      #   The following values are supported:
      #
      #   * `csv` - CSV
      #   * `json` - [Newline-delimited JSON](http://jsonlines.org/)
      #   * `avro` - [Avro](http://avro.apache.org/)
      # @param [String] compression The compression type to use for exported
      #   files. Possible values include `GZIP` and `NONE`. The default value is
      #   `NONE`.
      # @param [String] delimiter Delimiter to use between fields in the
      #   exported data. Default is <code>,</code>.
      # @param [Boolean] header Whether to print out a header row in the
      #   results. Default is `true`.
      #
      #
      # @return [Gcloud::Bigquery::ExtractJob]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #
      #   extract_job = table.extract "gs://my-bucket/file-name.json",
      #                               format: "json"
      #
      # @!group Data
      #
      def extract extract_url, format: nil, compression: nil, delimiter: nil,
                  header: nil, dryrun: nil
        ensure_connection!
        options = { format: format, compression: compression,
                    delimiter: delimiter, header: header, dryrun: dryrun }
        resp = connection.extract_table table_ref, extract_url, options
        if resp.success?
          Job.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Loads data into the table. You can pass a gcloud storage file path or
      # a gcloud storage file instance. Or, you can upload a file directly.
      # See [Loading Data with a POST Request](
      # https://cloud.google.com/bigquery/loading-data-post-request#multipart).
      #
      # @param [File, Gcloud::Storage::File, String] file A file or the URI of a
      #   Google Cloud Storage file containing data to load into the table.
      # @param [String] format The exported file format. The default value is
      #   `csv`.
      #
      #   The following values are supported:
      #
      #   * `csv` - CSV
      #   * `json` - [Newline-delimited JSON](http://jsonlines.org/)
      #   * `avro` - [Avro](http://avro.apache.org/)
      #   * `datastore_backup` - Cloud Datastore backup
      # @param [String] create Specifies whether the job is allowed to create
      #   new tables.
      #
      #   The following values are supported:
      #
      #   * `needed` - Create the table if it does not exist.
      #   * `never` - The table must already exist. A 'notFound' error is
      #     raised if the table does not exist.
      # @param [String] write Specifies how to handle data already present in
      #   the table. The default value is `empty`.
      #
      #   The following values are supported:
      #
      #   * `truncate` - BigQuery overwrites the table data.
      #   * `append` - BigQuery appends the data to the table.
      #   * `empty` - An error will be returned if the table already contains
      #     data.
      # @param [Array<String>] projection_fields If the `format` option is set
      #   to `datastore_backup`, indicates which entity properties to load from
      #   a Cloud Datastore backup. Property names are case sensitive and must
      #   be top-level properties. If not set, BigQuery loads all properties. If
      #   any named property isn't found in the Cloud Datastore backup, an
      #   invalid error is returned.
      # @param [Boolean] jagged_rows Accept rows that are missing trailing
      #   optional columns. The missing values are treated as nulls. If `false`,
      #   records with missing trailing columns are treated as bad records, and
      #   if there are too many bad records, an invalid error is returned in the
      #   job result. The default value is `false`. Only applicable to CSV,
      #   ignored for other formats.
      # @param [Boolean] quoted_newlines Indicates if BigQuery should allow
      #   quoted data sections that contain newline characters in a CSV file.
      #   The default value is `false`.
      # @param [String] encoding The character encoding of the data. The
      #   supported values are `UTF-8` or `ISO-8859-1`. The default value is
      #   `UTF-8`.
      # @param [String] delimiter Specifices the separator for fields in a CSV
      #   file. BigQuery converts the string to `ISO-8859-1` encoding, and then
      #   uses the first byte of the encoded string to split the data in its
      #   raw, binary state. Default is <code>,</code>.
      # @param [Boolean] ignore_unknown Indicates if BigQuery should allow extra
      #   values that are not represented in the table schema. If true, the
      #   extra values are ignored. If false, records with extra columns are
      #   treated as bad records, and if there are too many bad records, an
      #   invalid error is returned in the job result. The default value is
      #   `false`.
      #
      #   The `format` property determines what BigQuery treats as an extra
      #   value:
      #
      #   * `CSV`: Trailing columns
      #   * `JSON`: Named values that don't match any column names
      # @param [Integer] max_bad_records The maximum number of bad records that
      #   BigQuery can ignore when running the job. If the number of bad records
      #   exceeds this value, an invalid error is returned in the job result.
      #   The default value is `0`, which requires that all records are valid.
      # @param [String] quote The value that is used to quote data sections in a
      #   CSV file. BigQuery converts the string to ISO-8859-1 encoding, and
      #   then uses the first byte of the encoded string to split the data in
      #   its raw, binary state. The default value is a double-quote
      #   <code>"</code>. If your data does not contain quoted sections, set the
      #   property value to an empty string. If your data contains quoted
      #   newline characters, you must also set the allowQuotedNewlines property
      #   to true.
      # @param [Integer] skip_leading The number of rows at the top of a CSV
      #   file that BigQuery will skip when loading the data. The default value
      #   is `0`. This property is useful if you have header rows in the file
      #   that should be skipped.
      #
      # @return [Gcloud::Bigquery::LoadJob]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #
      #   load_job = table.load "gs://my-bucket/file-name.csv"
      #
      # @example Pass a gcloud storage file instance:
      #   require "gcloud"
      #   require "gcloud/storage"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #
      #   storage = gcloud.storage
      #   bucket = storage.bucket "my-bucket"
      #   file = bucket.file "file-name.csv"
      #   load_job = table.load file
      #
      # @example Upload a file directly:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #
      #   file = File.open "my_data.csv"
      #   load_job = table.load file
      #
      # ### A note about large direct uploads
      #
      # You may encounter a Broken pipe (Errno::EPIPE) error when attempting to
      # upload large files. To avoid this problem, add the
      # [httpclient](https://rubygems.org/gems/httpclient) gem to your project,
      # and the line (or lines) of configuration shown below. These lines must
      # execute after you require gcloud but before you make your first gcloud
      # connection. The first statement configures
      # [Faraday](https://rubygems.org/gems/faraday) to use httpclient. The
      # second statement, which should only be added if you are using a version
      # of Faraday at or above 0.9.2, is a workaround for [this gzip
      # issue](https://github.com/GoogleCloudPlatform/gcloud-ruby/issues/367).
      #
      # @example
      #   require "gcloud"
      #
      #   # Use httpclient to avoid broken pipe errors with large uploads
      #   Faraday.default_adapter = :httpclient
      #
      #   # Only add the following statement if using Faraday >= 0.9.2
      #   # Override gzip middleware with no-op for httpclient
      #   Faraday::Response.register_middleware :gzip =>
      #                                           Faraday::Response::Middleware
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #
      # @!group Data
      #
      def load file, format: nil, create: nil, write: nil,
               projection_fields: nil, jagged_rows: nil, quoted_newlines: nil,
               encoding: nil, delimiter: nil, ignore_unknown: nil,
               max_bad_records: nil, quote: nil, skip_leading: nil, dryrun: nil
        ensure_connection!
        options = { format: format, create: create, write: write,
                    projection_fields: projection_fields,
                    jagged_rows: jagged_rows, quoted_newlines: quoted_newlines,
                    encoding: encoding, delimiter: delimiter,
                    ignore_unknown: ignore_unknown,
                    max_bad_records: max_bad_records, quote: quote,
                    skip_leading: skip_leading, dryrun: dryrun }
        return load_storage(file, options) if storage_url? file
        return load_local(file, options) if local_file? file
        fail Gcloud::Bigquery::Error, "Don't know how to load #{file}"
      end

      ##
      # Inserts data into the table for near-immediate querying, without the
      # need to complete a #load operation before the data can appear in query
      # results.
      #
      # @see https://cloud.google.com/bigquery/streaming-data-into-bigquery
      #   Streaming Data Into BigQuery
      #
      # @param [Hash, Array<Hash>] rows A hash object or array of hash objects
      #   containing the data.
      # @param [Boolean] skip_invalid Insert all valid rows of a request, even
      #   if invalid rows exist. The default value is `false`, which causes the
      #   entire request to fail if any invalid rows exist.
      # @param [Boolean] ignore_unknown Accept rows that contain values that do
      #   not match the schema. The unknown values are ignored. Default is
      #   false, which treats unknown values as errors.
      #
      # @return [Gcloud::Bigquery::InsertResponse]
      #
      # @example
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #
      #   rows = [
      #     { "first_name" => "Alice", "age" => 21 },
      #     { "first_name" => "Bob", "age" => 22 }
      #   ]
      #   table.insert rows
      #
      # @!group Data
      #
      def insert rows, skip_invalid: nil, ignore_unknown: nil
        rows = [rows] if rows.is_a? Hash
        ensure_connection!
        options = { skip_invalid: skip_invalid, ignore_unknown: ignore_unknown }
        resp = connection.insert_tabledata dataset_id, table_id, rows, options
        if resp.success?
          InsertResponse.from_gapi rows, resp.data
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
        klass = class_for gapi
        klass.new.tap do |f|
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

      def self.class_for gapi
        return View if gapi["type"] == "VIEW"
        self
      end

      def load_storage file, options = {}
        # Convert to storage URL
        file = file.to_gs_url if file.respond_to? :to_gs_url

        resp = connection.load_table table_ref, file, options
        if resp.success?
          Job.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      def load_local file, options = {}
        if resumable_upload? file
          load_resumable file, options
        else
          load_multipart file, options
        end
      end

      def load_resumable file, options = {}
        chunk_size = verify_chunk_size! options[:chunk_size]
        resp = connection.load_resumable table_ref, file, chunk_size, options
        if resp.success?
          Job.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      def load_multipart file, options = {}
        resp = connection.load_multipart table_ref, file, options
        if resp.success?
          Job.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # @private Determines if a resumable upload should be used.
      def resumable_upload? file
        ::File.size?(file).to_i > Upload.resumable_threshold
      end

      def storage_url? file
        file.respond_to?(:to_gs_url) ||
          (file.respond_to?(:to_str) &&
          file.to_str.downcase.start_with?("gs://"))
      end

      def local_file? file
        ::File.file? file
      rescue
        false
      end

      ##
      # Determines if a chunk_size is valid.
      def verify_chunk_size! chunk_size
        chunk_size = chunk_size.to_i
        chunk_mod = 256 * 1024 # 256KB
        if (chunk_size.to_i % chunk_mod) != 0
          chunk_size = (chunk_size / chunk_mod) * chunk_mod
        end
        return if chunk_size.zero?
        chunk_size
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

      private

      def get_table_ref table
        if table.respond_to? :table_ref
          table.table_ref
        else
          Connection.table_ref_from_s table, table_ref
        end
      end
    end
  end
end
