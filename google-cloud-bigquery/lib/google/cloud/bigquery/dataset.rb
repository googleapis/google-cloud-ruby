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


require "json"
require "google/cloud/errors"
require "google/cloud/bigquery/service"
require "google/cloud/bigquery/table"
require "google/cloud/bigquery/dataset/list"
require "google/cloud/bigquery/dataset/access"
require "google/apis/bigquery_v2"

module Google
  module Cloud
    module Bigquery
      ##
      # # Dataset
      #
      # Represents a Dataset. A dataset is a grouping mechanism that holds zero
      # or more tables. Datasets are the lowest level unit of access control;
      # you cannot control access at the table level. A dataset is contained
      # within a specific project.
      #
      # @example
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::Bigquery.new
      #
      #   dataset = bigquery.create_dataset "my_dataset",
      #                                     name: "My Dataset",
      #                                     description: "This is my Dataset"
      #
      class Dataset
        ##
        # @private The Connection object.
        attr_accessor :service

        ##
        # @private The Google API Client object.
        attr_accessor :gapi

        ##
        # @private Create an empty Dataset object.
        def initialize
          @service = nil
          @gapi = {}
        end

        ##
        # A unique ID for this dataset, without the project name.
        # The ID must contain only letters (a-z, A-Z), numbers (0-9),
        # or underscores (_). The maximum length is 1,024 characters.
        #
        # @!group Attributes
        #
        def dataset_id
          @gapi.dataset_reference.dataset_id
        end

        ##
        # The ID of the project containing this dataset.
        #
        # @!group Attributes
        #
        def project_id
          @gapi.dataset_reference.project_id
        end

        ##
        # @private
        # The gapi fragment containing the Project ID and Dataset ID as a
        # camel-cased hash.
        def dataset_ref
          dataset_ref = @gapi.dataset_reference
          dataset_ref = dataset_ref.to_h if dataset_ref.respond_to? :to_h
          dataset_ref
        end

        ##
        # A descriptive name for the dataset.
        #
        # @!group Attributes
        #
        def name
          @gapi.friendly_name
        end

        ##
        # Updates the descriptive name for the dataset.
        #
        # @!group Attributes
        #
        def name= new_name
          @gapi.update! friendly_name: new_name
          patch_gapi! :friendly_name
        end

        ##
        # A string hash of the dataset.
        #
        # @!group Attributes
        #
        def etag
          ensure_full_data!
          @gapi.etag
        end

        ##
        # A URL that can be used to access the dataset using the REST API.
        #
        # @!group Attributes
        #
        def api_url
          ensure_full_data!
          @gapi.self_link
        end

        ##
        # A user-friendly description of the dataset.
        #
        # @!group Attributes
        #
        def description
          ensure_full_data!
          @gapi.description
        end

        ##
        # Updates the user-friendly description of the dataset.
        #
        # @!group Attributes
        #
        def description= new_description
          @gapi.update! description: new_description
          patch_gapi! :description
        end

        ##
        # The default lifetime of all tables in the dataset, in milliseconds.
        #
        # @!group Attributes
        #
        def default_expiration
          ensure_full_data!
          begin
            Integer @gapi.default_table_expiration_ms
          rescue
            nil
          end
        end

        ##
        # Updates the default lifetime of all tables in the dataset, in
        # milliseconds.
        #
        # @!group Attributes
        #
        def default_expiration= new_default_expiration
          @gapi.update! default_table_expiration_ms: new_default_expiration
          patch_gapi! :default_table_expiration_ms
        end

        ##
        # The time when this dataset was created.
        #
        # @!group Attributes
        #
        def created_at
          ensure_full_data!
          begin
            Time.at(Integer(@gapi.creation_time) / 1000.0)
          rescue
            nil
          end
        end

        ##
        # The date when this dataset or any of its tables was last modified.
        #
        # @!group Attributes
        #
        def modified_at
          ensure_full_data!
          begin
            Time.at(Integer(@gapi.last_modified_time) / 1000.0)
          rescue
            nil
          end
        end

        ##
        # The geographic location where the dataset should reside. Possible
        # values include EU and US. The default value is US.
        #
        # @!group Attributes
        #
        def location
          ensure_full_data!
          @gapi.location
        end

        ##
        # Retrieves the access rules for a Dataset. The rules can be updated
        # when passing a block, see {Dataset::Access} for all the methods
        # available.
        #
        # @see https://cloud.google.com/bigquery/access-control BigQuery Access
        #   Control
        #
        # @yield [access] a block for setting rules
        # @yieldparam [Dataset::Access] access the object accepting rules
        #
        # @return [Google::Cloud::Bigquery::Dataset::Access]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   dataset.access #=> [{"role"=>"OWNER",
        #                  #     "specialGroup"=>"projectOwners"},
        #                  #    {"role"=>"WRITER",
        #                  #     "specialGroup"=>"projectWriters"},
        #                  #    {"role"=>"READER",
        #                  #     "specialGroup"=>"projectReaders"},
        #                  #    {"role"=>"OWNER",
        #                  #     "userByEmail"=>"123456789-...com"}]
        #
        # @example Manage the access rules by passing a block:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   dataset.access do |access|
        #     access.add_owner_group "owners@example.com"
        #     access.add_writer_user "writer@example.com"
        #     access.remove_writer_user "readers@example.com"
        #     access.add_reader_special :all
        #     access.add_reader_view other_dataset_view_object
        #   end
        #
        def access
          ensure_full_data!
          access_builder = Access.from_gapi @gapi
          if block_given?
            yield access_builder
            if access_builder.changed?
              @gapi.update! access: access_builder.to_gapi
              patch_gapi! :access
            end
          end
          access_builder.freeze
        end

        ##
        # Permanently deletes the dataset. The dataset must be empty before it
        # can be deleted unless the `force` option is set to `true`.
        #
        # @param [Boolean] force If `true`, delete all the tables in the
        #   dataset. If `false` and the dataset contains tables, the request
        #   will fail. Default is `false`.
        #
        # @return [Boolean] Returns `true` if the dataset was deleted.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset"
        #   dataset.delete
        #
        # @!group Lifecycle
        #
        def delete force: nil
          ensure_service!
          service.delete_dataset dataset_id, force
          true
        end

        ##
        # Creates a new table. If you are adapting existing code that was
        # written for the [Rest API
        # ](https://cloud.google.com/bigquery/docs/reference/v2/tables#resource),
        # you can pass the table's schema as a hash (see example.)
        #
        # @param [String] table_id The ID of the table. The ID must contain only
        #   letters (a-z, A-Z), numbers (0-9), or underscores (_). The maximum
        #   length is 1,024 characters.
        # @param [String] name A descriptive name for the table.
        # @param [String] description A user-friendly description of the table.
        # @param [Array<Schema::Field>] fields An array of Schema::Field objects
        #   specifying the schema's data types for the table. The schema may
        #   also be configured when passing a block.
        # @yield [table] a block for setting the table
        # @yieldparam [Table] table the table object to be updated
        #
        # @return [Google::Cloud::Bigquery::Table]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.create_table "my_table"
        #
        # @example You can also pass name and description options.
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.create_table "my_table"
        #                                name: "My Table",
        #                                description: "A description of table."
        #
        # @example The table's schema fields can be passed as an argument.
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   schema_fields = [
        #     Google::Cloud::Bigquery::Schema::Field.new(
        #       "first_name", :string, mode: :required),
        #     Google::Cloud::Bigquery::Schema::Field.new(
        #       "cities_lived", :record, mode: :repeated
        #       fields: [
        #         Google::Cloud::Bigquery::Schema::Field.new(
        #           "place", :string, mode: :required),
        #         Google::Cloud::Bigquery::Schema::Field.new(
        #           "number_of_years", :integer, mode: :required),
        #         ])
        #   ]
        #   table = dataset.create_table "my_table", fields: schema_fields
        #
        # @example Or the table's schema can be configured with the block.
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   table = dataset.create_table "my_table" do |t|
        #     t.schema.string "first_name", mode: :required
        #     t.schema.record "cities_lived", mode: :required do |s|
        #       s.string "place", mode: :required
        #       s.integer "number_of_years", mode: :required
        #     end
        #   end
        #
        # @example You can define the schema using a nested block.
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.create_table "my_table" do |t|
        #     t.name = "My Table",
        #     t.description = "A description of my table."
        #     t.schema do |s|
        #       s.string "first_name", mode: :required
        #       s.record "cities_lived", mode: :repeated do |r|
        #         r.string "place", mode: :required
        #         r.integer "number_of_years", mode: :required
        #       end
        #     end
        #   end
        #
        # @!group Table
        #
        def create_table table_id, name: nil, description: nil, fields: nil
          ensure_service!
          new_tb = Google::Apis::BigqueryV2::Table.new(
            table_reference: Google::Apis::BigqueryV2::TableReference.new(
              project_id: project_id, dataset_id: dataset_id,
              table_id: table_id))
          updater = Table::Updater.new(new_tb).tap do |tb|
            tb.name = name unless name.nil?
            tb.description = description unless description.nil?
            tb.schema.fields = fields unless fields.nil?
          end

          yield updater if block_given?

          gapi = service.insert_table dataset_id, updater.to_gapi
          Table.from_gapi gapi, service
        end

        ##
        # Creates a new view table from the given query.
        #
        # @param [String] table_id The ID of the view table. The ID must contain
        #   only letters (a-z, A-Z), numbers (0-9), or underscores (_). The
        #   maximum length is 1,024 characters.
        # @param [String] query The query that BigQuery executes when the view
        #   is referenced.
        # @param [String] name A descriptive name for the table.
        # @param [String] description A user-friendly description of the table.
        #
        # @return [Google::Cloud::Bigquery::View]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   view = dataset.create_view "my_view",
        #             "SELECT name, age FROM [proj:dataset.users]"
        #
        # @example A name and description can be provided:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   view = dataset.create_view "my_view",
        #             "SELECT name, age FROM [proj:dataset.users]",
        #             name: "My View", description: "This is my view"
        #
        # @!group Table
        #
        def create_view table_id, query, name: nil, description: nil
          new_view_opts = {
            table_reference: Google::Apis::BigqueryV2::TableReference.new(
              project_id: project_id, dataset_id: dataset_id, table_id: table_id
            ),
            friendly_name: name,
            description: description,
            view: Google::Apis::BigqueryV2::ViewDefinition.new(
              query: query
            )
          }.delete_if { |_, v| v.nil? }
          new_view = Google::Apis::BigqueryV2::Table.new new_view_opts

          gapi = service.insert_table dataset_id, new_view
          Table.from_gapi gapi, service
        end

        ##
        # Retrieves an existing table by ID.
        #
        # @param [String] table_id The ID of a table.
        #
        # @return [Google::Cloud::Bigquery::Table,
        #   Google::Cloud::Bigquery::View, nil] Returns `nil` if the table does
        #   not exist
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   table = dataset.table "my_table"
        #   puts table.name
        #
        # @!group Table
        #
        def table table_id
          ensure_service!
          gapi = service.get_table dataset_id, table_id
          Table.from_gapi gapi, service
        rescue Google::Cloud::NotFoundError
          nil
        end

        ##
        # Retrieves the list of tables belonging to the dataset.
        #
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of tables to return.
        #
        # @return [Array<Google::Cloud::Bigquery::Table>,
        #   Array<Google::Cloud::Bigquery::View>] (See
        #   {Google::Cloud::Bigquery::Table::List})
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   tables = dataset.tables
        #   tables.each do |table|
        #     puts table.name
        #   end
        #
        # @example Retrieve all tables: (See {Table::List#all})
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   tables = dataset.tables
        #   tables.all do |table|
        #     puts table.name
        #   end
        #
        # @!group Table
        #
        def tables token: nil, max: nil
          ensure_service!
          options = { token: token, max: max }
          gapi = service.list_tables dataset_id, options
          Table::List.from_gapi gapi, service, dataset_id, max
        end

        ##
        # Queries data using the [asynchronous
        # method](https://cloud.google.com/bigquery/querying-data).
        #
        # Sets the current dataset as the default dataset in the query. Useful
        # for using unqualified table names.
        #
        # @param [String] query A query string, following the BigQuery [query
        #   syntax](https://cloud.google.com/bigquery/query-reference), of the
        #   query to execute. Example: "SELECT count(f1) FROM
        #   [myProjectId:myDatasetId.myTableId]".
        # @param [String] priority Specifies a priority for the query. Possible
        #   values include `INTERACTIVE` and `BATCH`. The default value is
        #   `INTERACTIVE`.
        # @param [Boolean] cache Whether to look for the result in the query
        #   cache. The query cache is a best-effort cache that will be flushed
        #   whenever tables in the query are modified. The default value is
        #   true. For more information, see [query
        #   caching](https://developers.google.com/bigquery/querying-data).
        # @param [Table] table The destination table where the query results
        #   should be stored. If not present, a new table will be created to
        #   store the results.
        # @param [String] create Specifies whether the job is allowed to create
        #   new tables.
        #
        #   The following values are supported:
        #
        #   * `needed` - Create the table if it does not exist.
        #   * `never` - The table must already exist. A 'notFound' error is
        #     raised if the table does not exist.
        # @param [String] write Specifies the action that occurs if the
        #   destination table already exists.
        #
        #   The following values are supported:
        #
        #   * `truncate` - BigQuery overwrites the table data.
        #   * `append` - BigQuery appends the data to the table.
        #   * `empty` - A 'duplicate' error is returned in the job result if the
        #     table exists and contains data.
        # @param [Boolean] large_results If `true`, allows the query to produce
        #   arbitrarily large result tables at a slight cost in performance.
        #   Requires `table` parameter to be set.
        # @param [Boolean] flatten Flattens all nested and repeated fields in
        #   the query results. The default value is `true`. `large_results`
        #   parameter must be `true` if this is set to `false`.
        #
        # @return [Google::Cloud::Bigquery::QueryJob]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   job = bigquery.query_job "SELECT name FROM my_table"
        #
        #   job.wait_until_done!
        #   if !job.failed?
        #     job.query_results.each do |row|
        #       puts row["name"]
        #     end
        #   end
        #
        # @!group Data
        #
        def query_job query, priority: "INTERACTIVE", cache: true, table: nil,
                      create: nil, write: nil, large_results: nil, flatten: nil,
                      use_legacy_sql: true
          options = { priority: priority, cache: cache, table: table,
                      create: create, write: write,
                      large_results: large_results, flatten: flatten,
                      use_legacy_sql: use_legacy_sql }
          options[:dataset] ||= self
          ensure_service!
          gapi = service.query_job query, options
          Job.from_gapi gapi, service
        end

        ##
        # Queries data using the [synchronous
        # method](https://cloud.google.com/bigquery/querying-data).
        #
        # Sets the current dataset as the default dataset in the query. Useful
        # for using unqualified table names.
        #
        # @param [String] query A query string, following the BigQuery [query
        #   syntax](https://cloud.google.com/bigquery/query-reference), of the
        #   query to execute. Example: "SELECT count(f1) FROM
        #   [myProjectId:myDatasetId.myTableId]".
        # @param [Integer] max The maximum number of rows of data to return per
        #   page of results. Setting this flag to a small value such as 1000 and
        #   then paging through results might improve reliability when the query
        #   result set is large. In addition to this limit, responses are also
        #   limited to 10 MB. By default, there is no maximum row count, and
        #   only the byte limit applies.
        # @param [Integer] timeout How long to wait for the query to complete,
        #   in milliseconds, before the request times out and returns. Note that
        #   this is only a timeout for the request, not the query. If the query
        #   takes longer to run than the timeout value, the call returns without
        #   any results and with QueryData#complete? set to false. The default
        #   value is 10000 milliseconds (10 seconds).
        # @param [Boolean] dryrun If set to `true`, BigQuery doesn't run the
        #   job. Instead, if the query is valid, BigQuery returns statistics
        #   about the job such as how many bytes would be processed. If the
        #   query is invalid, an error returns. The default value is `false`.
        # @param [Boolean] cache Whether to look for the result in the query
        #   cache. The query cache is a best-effort cache that will be flushed
        #   whenever tables in the query are modified. The default value is
        #   true. For more information, see [query
        #   caching](https://developers.google.com/bigquery/querying-data).
        #
        # @return [Google::Cloud::Bigquery::QueryData]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   data = bigquery.query "SELECT name FROM my_table"
        #   data.each do |row|
        #     puts row["name"]
        #   end
        #
        # @!group Data
        #
        def query query, max: nil, timeout: 10000, dryrun: nil, cache: true,
                  use_legacy_sql: true
          options = { max: max, timeout: timeout, dryrun: dryrun, cache: cache,
                      use_legacy_sql: use_legacy_sql }
          options[:dataset] ||= dataset_id
          options[:project] ||= project_id
          ensure_service!
          gapi = service.query query, options
          QueryData.from_gapi gapi, service
        end

        ##
        # @private New Dataset from a Google API Client object.
        def self.from_gapi gapi, conn
          new.tap do |f|
            f.gapi = gapi
            f.service = conn
          end
        end

        protected

        ##
        # Raise an error unless an active service is available.
        def ensure_service!
          fail "Must have active connection" unless service
        end

        def patch_gapi! *attributes
          return if attributes.empty?
          ensure_service!
          patch_args = Hash[attributes.map do |attr|
            [attr, @gapi.send(attr)]
          end]
          patch_gapi = Google::Apis::BigqueryV2::Dataset.new patch_args
          @gapi = service.patch_dataset dataset_id, patch_gapi
        end

        ##
        # Load the complete representation of the dataset if it has been
        # only partially loaded by a request to the API list method.
        def ensure_full_data!
          reload_gapi! unless data_complete?
        end

        def reload_gapi!
          ensure_service!
          gapi = service.get_dataset dataset_id
          @gapi = gapi
        end

        def data_complete?
          @gapi.is_a? Google::Apis::BigqueryV2::Dataset
        end

        ##
        # Yielded to a block to accumulate changes for a patch request.
        class Updater < Dataset
          ##
          # A list of attributes that were updated.
          attr_reader :updates

          ##
          # Create an Updater object.
          def initialize gapi
            @updates = []
            @gapi = gapi
          end

          def access
            # TODO: make sure to call ensure_full_data! on Dataset#update
            @access ||= Access.from_gapi @gapi
            if block_given?
              yield @access
              check_for_mutated_access!
            end
            # Same as Dataset#access, but not frozen
            @access
          end

          ##
          # Make sure any access changes are saved
          def check_for_mutated_access!
            return if @access.nil?
            return unless @access.changed?
            @gapi.update! access: @access.to_gapi
            patch_gapi! :access
          end

          def to_gapi
            check_for_mutated_access!
            @gapi
          end

          protected

          ##
          # Queue up all the updates instead of making them.
          def patch_gapi! attribute
            @updates << attribute
            @updates.uniq!
          end
        end
      end
    end
  end
end
