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
    # # LoadJob
    #
    # A {Job} subclass representing a load operation that may be performed
    # on a {Table}. A LoadJob instance is created when you call {Table#load}.
    #
    # @see https://cloud.google.com/bigquery/loading-data-into-bigquery Loading
    #   Data Into BigQuery
    # @see https://cloud.google.com/bigquery/docs/reference/v2/jobs Jobs API
    #   reference
    #
    class LoadJob < Job
      ##
      # The URI or URIs representing the Google Cloud Storage files from which
      # the operation loads data.
      def sources
        Array config["load"]["sourceUris"]
      end

      ##
      # The table into which the operation loads data. This is the table on
      # which {Table#load} was invoked. Returns a {Table} instance.
      def destination
        table = config["load"]["destinationTable"]
        return nil unless table
        retrieve_table table["projectId"],
                       table["datasetId"],
                       table["tableId"]
      end

      ##
      # The delimiter used between fields in the source data. The default is a
      # comma (,).
      def delimiter
        val = config["load"]["fieldDelimiter"]
        val = "," if val.nil?
        val
      end

      ##
      # The number of header rows at the top of a CSV file to skip. The default
      # value is +0+.
      def skip_leading_rows
        val = config["load"]["skipLeadingRows"]
        val = 0 if val.nil?
        val
      end

      ##
      # Checks if the character encoding of the data is UTF-8. This is the
      # default.
      def utf8?
        val = config["load"]["encoding"]
        return true if val.nil?
        val == "UTF-8"
      end

      ##
      # Checks if the character encoding of the data is ISO-8859-1.
      def iso8859_1?
        val = config["load"]["encoding"]
        val == "ISO-8859-1"
      end

      ##
      # The value that is used to quote data sections in a CSV file.
      # The default value is a double-quote (+"+). If your data does not contain
      # quoted sections, the value should be an empty string. If your data
      # contains quoted newline characters, {#quoted_newlines?} should return
      # +true+.
      def quote
        val = config["load"]["quote"]
        val = "\"" if val.nil?
        val
      end

      ##
      # The maximum number of bad records that the load operation can ignore. If
      # the number of bad records exceeds this value, an error is
      # returned. The default value is +0+, which requires that all records be
      # valid.
      def max_bad_records
        val = config["load"]["maxBadRecords"]
        val = 0 if val.nil?
        val
      end

      ##
      # Checks if quoted data sections may contain newline characters in a CSV
      # file. The default is +false+.
      def quoted_newlines?
        val = config["load"]["allowQuotedNewlines"]
        val = true if val.nil?
        val
      end

      ##
      # Checks if the format of the source data is
      # {newline-delimited JSON}[http://jsonlines.org/]. The default is +false+.
      def json?
        val = config["load"]["sourceFormat"]
        val == "NEWLINE_DELIMITED_JSON"
      end

      ##
      # Checks if the format of the source data is CSV. The default is +true+.
      def csv?
        val = config["load"]["sourceFormat"]
        return true if val.nil?
        val == "CSV"
      end

      ##
      # Checks if the source data is a Google Cloud Datastore backup.
      def backup?
        val = config["load"]["sourceFormat"]
        val == "DATASTORE_BACKUP"
      end

      ##
      # Checks if the load operation accepts rows that are missing trailing
      # optional columns. The missing values are treated as nulls. If +false+,
      # records with missing trailing columns are treated as bad records, and
      # if there are too many bad records, an error is returned. The default
      # value is +false+. Only applicable to CSV, ignored for other formats.
      def allow_jagged_rows?
        val = config["load"]["allowJaggedRows"]
        val = false if val.nil?
        val
      end

      ##
      # Checks if the load operation allows extra values that are not
      # represented in the table schema. If +true+, the extra values are
      # ignored. If +false+, records with extra columns are treated as bad
      # records, and if there are too many bad records, an invalid error is
      # returned. The default is +false+.
      def ignore_unknown_values?
        val = config["load"]["ignoreUnknownValues"]
        val = false if val.nil?
        val
      end

      ##
      # The schema for the data. Returns a hash. Can be empty if the table
      # has already has the correct schema (see {Table#schema=} and
      # {Table#schema}), or if the schema can be inferred from the loaded data.
      def schema
        val = config["load"]["schema"]
        val = {} if val.nil?
        val
      end

      ##
      # The number of source files.
      def input_files
        stats["load"]["inputFiles"]
      end

      ##
      # The number of bytes of source data.
      def input_file_bytes
        stats["load"]["inputFileBytes"]
      end

      ##
      # The number of rows that have been loaded into the table. While an
      # import job is in the running state, this value may change.
      def output_rows
        stats["load"]["outputRows"]
      end

      ##
      # The number of bytes that have been loaded into the table. While an
      # import job is in the running state, this value may change.
      def output_bytes
        stats["load"]["outputBytes"]
      end
    end
  end
end
