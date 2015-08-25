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

require "gcloud/bigquery/view"
require "gcloud/bigquery/data"
require "gcloud/bigquery/table/list"
require "gcloud/bigquery/errors"
require "gcloud/bigquery/insert_response"
require "gcloud/upload"

module Gcloud
  module Bigquery
    ##
    # = Table
    #
    # A named resource representing a BigQuery table that holds zero or more
    # records. Every table is defined by a schema
    # that may contain nested and repeated fields. (For more information
    # about nested and repeated fields, see {Preparing Data for
    # BigQuery}[https://cloud.google.com/bigquery/preparing-data-for-bigquery].)
    #
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
    #         "name" => "cities_lived",
    #         "type" => "RECORD",
    #         "mode" => "REPEATED",
    #         "fields" => [
    #           {
    #             "name" => "place",
    #             "type" => "STRING",
    #             "mode" => "REQUIRED"
    #           },
    #           {
    #             "name" => "number_of_years",
    #             "type" => "INTEGER",
    #             "mode" => "REQUIRED"
    #           }
    #         ]
    #       }
    #     ]
    #   }
    #   table.schema = schema
    #
    #   row = {
    #     "first_name" => "Alice",
    #     "cities_lived" => [
    #       {
    #         "place": "Seattle",
    #         "number_of_years": 5
    #       },
    #       {
    #         "place": "Stockholm",
    #         "number_of_years": 6
    #       }
    #     ]
    #   }
    #   table.insert row
    #
    class Table
      ##
      # The Connection object.
      attr_accessor :connection #:nodoc:

      ##
      # The Google API Client object.
      attr_accessor :gapi #:nodoc:

      ##
      # Create an empty Table object.
      def initialize #:nodoc:
        @connection = nil
        @gapi = {}
      end

      ##
      # A unique ID for this table.
      # The ID must contain only letters (a-z, A-Z), numbers (0-9),
      # or underscores (_). The maximum length is 1,024 characters.
      #
      # :category: Attributes
      #
      def table_id
        @gapi["tableReference"]["tableId"]
      end

      ##
      # The ID of the +Dataset+ containing this table.
      #
      # :category: Attributes
      #
      def dataset_id
        @gapi["tableReference"]["datasetId"]
      end

      ##
      # The ID of the +Project+ containing this table.
      #
      # :category: Attributes
      #
      def project_id
        @gapi["tableReference"]["projectId"]
      end

      ##
      # The combined Project ID, Dataset ID, and Table ID for this table, in the
      # format specified by the {Query
      # Reference}[https://cloud.google.com/bigquery/query-reference#from]:
      # +project_name:datasetId.tableId+. Surrounded by square brackets if the
      # Project ID contains dashes. Useful in queries.
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #
      #   data = bigquery.query "SELECT name FROM #{table.id}"
      #
      # :category: Attributes
      #
      def id
        id_str = "#{project_id}:#{dataset_id}.#{table_id}"
        project_id["-"] ? "[#{id_str}]" : id_str
      end

      ##
      # The name of the table.
      #
      # :category: Attributes
      #
      def name
        @gapi["friendlyName"]
      end

      ##
      # Updates the name of the table.
      #
      # :category: Attributes
      #
      def name= new_name
        patch_gapi! name: new_name
      end

      ##
      # A string hash of the dataset.
      #
      # :category: Attributes
      #
      def etag
        ensure_full_data!
        @gapi["etag"]
      end

      ##
      # A URL that can be used to access the dataset using the REST API.
      #
      # :category: Attributes
      #
      def url
        ensure_full_data!
        @gapi["selfLink"]
      end

      ##
      # The description of the table.
      #
      # :category: Attributes
      #
      def description
        ensure_full_data!
        @gapi["description"]
      end

      ##
      # Updates the description of the table.
      #
      # :category: Attributes
      #
      def description= new_description
        patch_gapi! description: new_description
      end

      ##
      # The number of bytes in the table.
      #
      # :category: Data
      #
      def bytes_count
        ensure_full_data!
        @gapi["numBytes"]
      end

      ##
      # The number of rows in the table.
      #
      # :category: Data
      #
      def rows_count
        ensure_full_data!
        @gapi["numRows"]
      end

      ##
      # The time when this table was created.
      #
      # :category: Attributes
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
      # :category: Attributes
      #
      def expires_at
        ensure_full_data!
        return nil if @gapi["expirationTime"].nil?
        Time.at(@gapi["expirationTime"] / 1000.0)
      end

      ##
      # The date when this table was last modified.
      #
      # :category: Attributes
      #
      def modified_at
        ensure_full_data!
        Time.at(@gapi["lastModifiedTime"] / 1000.0)
      end

      ##
      # Checks if the table's type is "TABLE".
      #
      # :category: Attributes
      #
      def table?
        @gapi["type"] == "TABLE"
      end

      ##
      # Checks if the table's type is "VIEW".
      #
      # :category: Attributes
      #
      def view?
        @gapi["type"] == "VIEW"
      end

      ##
      # The geographic location where the table should reside. Possible
      # values include EU and US. The default value is US.
      #
      # :category: Attributes
      #
      def location
        ensure_full_data!
        @gapi["location"]
      end

      ##
      # The schema of the table.
      #
      # :category: Attributes
      #
      def schema
        ensure_full_data!
        s = @gapi["schema"]
        s = s.to_hash if s.respond_to? :to_hash
        s = {} if s.nil?
        s
      end

      ##
      # Updates the schema of the table.
      #
      # === Example
      #
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
      # :category: Attributes
      #
      def schema= new_schema
        patch_gapi! schema: new_schema
      end

      ##
      # The fields of the table.
      #
      # :category: Attributes
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
      # :category: Attributes
      #
      def headers
        fields.map { |f| f["name"] }
      end

      ##
      # Retrieves data from the table.
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
      #
      # === Returns
      #
      # Gcloud::Bigquery::Data
      #
      # === Example
      #
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
      # :category: Data
      #
      def data options = {}
        ensure_connection!
        resp = connection.list_tabledata dataset_id, table_id, options
        if resp.success?
          Data.from_response resp, self
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Copies the data from the table to another table.
      #
      # === Parameters
      #
      # +destination_table+::
      #   The destination for the copied data. (+Table+)
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:create]</code>::
      #   Specifies whether the job is allowed to create new tables. (+String+)
      #
      #   The following values are supported:
      #   * +needed+ - Create the table if it does not exist.
      #   * +never+ - The table must already exist. A 'notFound' error is
      #     raised if the table does not exist.
      # <code>options[:write]</code>::
      #   Specifies how to handle data already present in the destination table.
      #   The default value is +empty+. (+String+)
      #
      #   The following values are supported:
      #   * +truncate+ - BigQuery overwrites the table data.
      #   * +append+ - BigQuery appends the data to the table.
      #   * +empty+ - An error will be returned if the destination table already
      #     contains data.
      #
      # === Returns
      #
      # Gcloud::Bigquery::CopyJob
      #
      # === Example
      #
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
      # :category: Data
      #
      def copy destination_table, options = {}
        ensure_connection!
        resp = connection.copy_table gapi, destination_table.gapi, options
        if resp.success?
          Job.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Links the table to a source table identified by a URI.
      #
      # === Parameters
      #
      # +source_url+::
      #   The URI of source table to link. (+String+)
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:create]</code>::
      #   Specifies whether the job is allowed to create new tables. (+String+)
      #
      #   The following values are supported:
      #   * +needed+ - Create the table if it does not exist.
      #   * +never+ - The table must already exist. A 'notFound' error is
      #     raised if the table does not exist.
      # <code>options[:write]</code>::
      #   Specifies how to handle data already present in the table.
      #   The default value is +empty+. (+String+)
      #
      #   The following values are supported:
      #   * +truncate+ - BigQuery overwrites the table data.
      #   * +append+ - BigQuery appends the data to the table.
      #   * +empty+ - An error will be returned if the table already contains
      #     data.
      #
      # === Returns
      #
      # Gcloud::Bigquery::Job
      #
      # :category: Data
      #
      def link source_url, options = {} #:nodoc:
        ensure_connection!
        resp = connection.link_table gapi, source_url, options
        if resp.success?
          Job.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Extract the data from the table to a Google Cloud Storage file. For
      # more information, see {Exporting Data From BigQuery
      # }[https://cloud.google.com/bigquery/exporting-data-from-bigquery].
      #
      # === Parameters
      #
      # +extract_url+::
      #   The Google Storage file or file URI pattern(s) to which BigQuery
      #   should extract the table data.
      #   (+Gcloud::Storage::File+ or +String+ or +Array+)
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:format]</code>::
      #   The exported file format. The default value is +csv+. (+String+)
      #
      #   The following values are supported:
      #   * +csv+ - CSV
      #   * +json+ - {Newline-delimited JSON}[http://jsonlines.org/]
      #   * +avro+ - {Avro}[http://avro.apache.org/]
      #
      # === Returns
      #
      # Gcloud::Bigquery::ExtractJob
      #
      # === Example
      #
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
      # :category: Data
      #
      def extract extract_url, options = {}
        ensure_connection!
        resp = connection.extract_table gapi, extract_url, options
        if resp.success?
          Job.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Loads data into the table.
      #
      # === Parameters
      #
      # +file+::
      #   A file or the URI of a Google Cloud Storage file containing
      #   data to load into the table.
      #   (+File+ or +Gcloud::Storage::File+ or +String+)
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:format]</code>::
      #   The exported file format. The default value is +csv+. (+String+)
      #
      #   The following values are supported:
      #   * +csv+ - CSV
      #   * +json+ - {Newline-delimited JSON}[http://jsonlines.org/]
      #   * +avro+ - {Avro}[http://avro.apache.org/]
      #   * +datastore_backup+ - Cloud Datastore backup
      # <code>options[:create]</code>::
      #   Specifies whether the job is allowed to create new tables. (+String+)
      #
      #   The following values are supported:
      #   * +needed+ - Create the table if it does not exist.
      #   * +never+ - The table must already exist. A 'notFound' error is
      #     raised if the table does not exist.
      # <code>options[:write]</code>::
      #   Specifies how to handle data already present in the table.
      #   The default value is +empty+. (+String+)
      #
      #   The following values are supported:
      #   * +truncate+ - BigQuery overwrites the table data.
      #   * +append+ - BigQuery appends the data to the table.
      #   * +empty+ - An error will be returned if the table already contains
      #     data.
      # <code>options[:projection_fields]</code>::
      #   If the +format+ option is set to +datastore_backup+, indicates which
      #   entity properties to load from a Cloud Datastore backup. Property
      #   names are case sensitive and must be top-level properties. If not set,
      #   BigQuery loads all properties. If any named property isn't found in
      #   the Cloud Datastore backup, an invalid error is returned. (+Array+)
      #
      # === Returns
      #
      # Gcloud::Bigquery::LoadJob
      #
      # === Examples
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #
      #   load_job = table.load "gs://my-bucket/file-name.csv"
      #
      # You can also pass a gcloud storage file instance.
      #
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
      # Or, you can upload a smaller file directly.
      # See {Loading Data with a POST Request}[
      # https://cloud.google.com/bigquery/loading-data-post-request#multipart].
      #
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
      # :category: Data
      #
      def load file, options = {}
        ensure_connection!
        if storage_url? file
          load_storage file, options
        elsif local_file? file
          load_local file, options
        else
          fail Gcloud::Bigquery::Error, "Don't know how to load #{file}"
        end
      end

      ##
      # Inserts data into the table for near-immediate querying, without the
      # need to complete a #load operation before the data can appear in query
      # results. See {Streaming Data Into BigQuery
      # }[https://cloud.google.com/bigquery/streaming-data-into-bigquery].
      #
      # === Parameters
      #
      # +rows+::
      #   A hash object or array of hash objects containing the data.
      #   (+Array+ or +Hash+)
      # +options+::
      #   An optional Hash for controlling additional behavior. (+Hash+)
      # <code>options[:skip_invalid]</code>::
      #   Insert all valid rows of a request, even if invalid rows exist. The
      #   default value is +false+, which causes the entire request to fail if
      #   any invalid rows exist. (+Boolean+)
      # <code>options[:ignore_unknown]</code>::
      #   Accept rows that contain values that do not match the schema. The
      #   unknown values are ignored. Default is false, which treats unknown
      #   values as errors. (+Boolean+)
      #
      # === Returns
      #
      # Gcloud::Bigquery::InsertResponse
      #
      # === Example
      #
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
      # :category: Data
      #
      def insert rows, options = {}
        rows = [rows] if rows.is_a? Hash
        ensure_connection!
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
      # === Returns
      #
      # +true+ if the table was deleted.
      #
      # === Example
      #
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   bigquery = gcloud.bigquery
      #   dataset = bigquery.dataset "my_dataset"
      #   table = dataset.table "my_table"
      #
      #   table.delete
      #
      # :category: Lifecycle
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
      # New Table from a Google API Client object.
      def self.from_gapi gapi, conn #:nodoc:
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

        resp = connection.load_table gapi, file, options
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
        resp = connection.load_resumable gapi, file, chunk_size, options
        if resp.success?
          Job.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      def load_multipart file, options = {}
        resp = connection.load_multipart gapi, file, options
        if resp.success?
          Job.from_gapi resp.data, connection
        else
          fail ApiError.from_response(resp)
        end
      end

      ##
      # Determines if a resumable upload should be used.
      def resumable_upload? file #:nodoc:
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
    end
  end
end
