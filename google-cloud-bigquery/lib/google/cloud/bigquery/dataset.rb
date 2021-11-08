# Copyright 2015 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
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
require "google/cloud/bigquery/model"
require "google/cloud/bigquery/routine"
require "google/cloud/bigquery/external"
require "google/cloud/bigquery/dataset/list"
require "google/cloud/bigquery/dataset/access"
require "google/cloud/bigquery/convert"
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
        # @private A Google API Client Dataset Reference object.
        attr_reader :reference

        ##
        # @private Create an empty Dataset object.
        def initialize
          @service = nil
          @gapi = nil
          @reference = nil
        end

        ##
        # A unique ID for this dataset, without the project name.
        #
        # @return [String] The ID must contain only letters (`[A-Za-z]`), numbers
        #   (`[0-9]`), or underscores (`_`). The maximum length is 1,024 characters.
        #
        # @!group Attributes
        #
        def dataset_id
          return reference.dataset_id if reference?
          @gapi.dataset_reference.dataset_id
        end

        ##
        # The ID of the project containing this dataset.
        #
        # @return [String] The project ID.
        #
        # @!group Attributes
        #
        def project_id
          return reference.project_id if reference?
          @gapi.dataset_reference.project_id
        end

        ##
        # @private
        # The gapi fragment containing the Project ID and Dataset ID as a
        # camel-cased hash.
        def dataset_ref
          dataset_ref = reference? ? reference : @gapi.dataset_reference
          dataset_ref = dataset_ref.to_h if dataset_ref.respond_to? :to_h
          dataset_ref
        end

        ##
        # A descriptive name for the dataset.
        #
        # @return [String, nil] The friendly name, or `nil` if the object is
        #   a reference (see {#reference?}).
        #
        # @!group Attributes
        #
        def name
          return nil if reference?
          @gapi.friendly_name
        end

        ##
        # Updates the descriptive name for the dataset.
        #
        # If the dataset is not a full resource representation (see
        # {#resource_full?}), the full representation will be retrieved before
        # the update to comply with ETag-based optimistic concurrency control.
        #
        # @param [String] new_name The new friendly name, or `nil` if the object
        #   is a reference (see {#reference?}).
        #
        # @!group Attributes
        #
        def name= new_name
          reload! unless resource_full?
          @gapi.update! friendly_name: new_name
          patch_gapi! :friendly_name
        end

        ##
        # The ETag hash of the dataset.
        #
        # @return [String, nil] The ETag hash, or `nil` if the object is a
        #   reference (see {#reference?}).
        #
        # @!group Attributes
        #
        def etag
          return nil if reference?
          ensure_full_data!
          @gapi.etag
        end

        ##
        # A URL that can be used to access the dataset using the REST API.
        #
        # @return [String, nil] A REST URL for the resource, or `nil` if the
        #   object is a reference (see {#reference?}).
        #
        # @!group Attributes
        #
        def api_url
          return nil if reference?
          ensure_full_data!
          @gapi.self_link
        end

        ##
        # A user-friendly description of the dataset.
        #
        # @return [String, nil] The description, or `nil` if the object is a
        #   reference (see {#reference?}).
        #
        # @!group Attributes
        #
        def description
          return nil if reference?
          ensure_full_data!
          @gapi.description
        end

        ##
        # Updates the user-friendly description of the dataset.
        #
        # If the dataset is not a full resource representation (see
        # {#resource_full?}), the full representation will be retrieved before
        # the update to comply with ETag-based optimistic concurrency control.
        #
        # @param [String] new_description The new description for the dataset.
        #
        # @!group Attributes
        #
        def description= new_description
          reload! unless resource_full?
          @gapi.update! description: new_description
          patch_gapi! :description
        end

        ##
        # The default lifetime of all tables in the dataset, in milliseconds.
        #
        # @return [Integer, nil] The default table expiration in milliseconds,
        #   or `nil` if not present or the object is a reference (see
        #   {#reference?}).
        #
        # @!group Attributes
        #
        def default_expiration
          return nil if reference?
          ensure_full_data!
          begin
            Integer @gapi.default_table_expiration_ms
          rescue StandardError
            nil
          end
        end

        ##
        # Updates the default lifetime of all tables in the dataset, in
        # milliseconds.
        #
        # If the dataset is not a full resource representation (see
        # {#resource_full?}), the full representation will be retrieved before
        # the update to comply with ETag-based optimistic concurrency control.
        #
        # @param [Integer] new_default_expiration The new default table
        #   expiration in milliseconds.
        #
        # @!group Attributes
        #
        def default_expiration= new_default_expiration
          reload! unless resource_full?
          @gapi.update! default_table_expiration_ms: new_default_expiration
          patch_gapi! :default_table_expiration_ms
        end

        ##
        # The time when this dataset was created.
        #
        # @return [Time, nil] The creation time, or `nil` if not present or the
        #   object is a reference (see {#reference?}).
        #
        # @!group Attributes
        #
        def created_at
          return nil if reference?
          ensure_full_data!
          Convert.millis_to_time @gapi.creation_time
        end

        ##
        # The date when this dataset or any of its tables was last modified.
        #
        # @return [Time, nil] The last modified time, or `nil` if not present or
        #   the object is a reference (see {#reference?}).
        #
        # @!group Attributes
        #
        def modified_at
          return nil if reference?
          ensure_full_data!
          Convert.millis_to_time @gapi.last_modified_time
        end

        ##
        # The geographic location where the dataset should reside. Possible
        # values include `EU` and `US`. The default value is `US`.
        #
        # @return [String, nil] The geographic location, or `nil` if the object
        #   is a reference (see {#reference?}).
        #
        # @!group Attributes
        #
        def location
          return nil if reference?
          ensure_full_data!
          @gapi.location
        end

        ##
        # A hash of user-provided labels associated with this dataset. Labels
        # are used to organize and group datasets. See [Using
        # Labels](https://cloud.google.com/bigquery/docs/labels).
        #
        # The returned hash is frozen and changes are not allowed. Use
        # {#labels=} to replace the entire hash.
        #
        # @return [Hash<String, String>, nil] A hash containing key/value pairs,
        #   or `nil` if the object is a reference (see {#reference?}).
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   labels = dataset.labels
        #   labels["department"] #=> "shipping"
        #
        # @!group Attributes
        #
        def labels
          return nil if reference?
          m = @gapi.labels
          m = m.to_h if m.respond_to? :to_h
          m.dup.freeze
        end

        ##
        # Updates the hash of user-provided labels associated with this dataset.
        # Labels are used to organize and group datasets. See [Using
        # Labels](https://cloud.google.com/bigquery/docs/labels).
        #
        # If the dataset is not a full resource representation (see
        # {#resource_full?}), the full representation will be retrieved before
        # the update to comply with ETag-based optimistic concurrency control.
        #
        # @param [Hash<String, String>] labels A hash containing key/value
        #   pairs.
        #
        #   The labels applied to a resource must meet the following requirements:
        #
        #   * Each resource can have multiple labels, up to a maximum of 64.
        #   * Each label must be a key-value pair.
        #   * Keys have a minimum length of 1 character and a maximum length of
        #     63 characters, and cannot be empty. Values can be empty, and have
        #     a maximum length of 63 characters.
        #   * Keys and values can contain only lowercase letters, numeric characters,
        #     underscores, and dashes. All characters must use UTF-8 encoding, and
        #     international characters are allowed.
        #   * The key portion of a label must be unique. However, you can use the
        #     same key with multiple resources.
        #   * Keys must start with a lowercase letter or international character.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   dataset.labels = { "department" => "shipping" }
        #
        # @!group Attributes
        #
        def labels= labels
          reload! unless resource_full?
          @gapi.labels = labels
          patch_gapi! :labels
        end

        ##
        # The {EncryptionConfiguration} object that represents the default
        # encryption method for all tables and models in the dataset. Once this
        # property is set, all newly-created partitioned tables and models in
        # the dataset will have their encryption set to this value, unless table
        # creation request (or query) overrides it.
        #
        # Present only if this dataset is using custom default encryption.
        #
        # @see https://cloud.google.com/bigquery/docs/customer-managed-encryption
        #   Protecting Data with Cloud KMS Keys
        #
        # @return [EncryptionConfiguration, nil] The default encryption
        #   configuration.
        #
        #   @!group Attributes
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   encrypt_config = dataset.default_encryption
        #
        # @!group Attributes
        #
        def default_encryption
          return nil if reference?
          ensure_full_data!
          return nil if @gapi.default_encryption_configuration.nil?
          EncryptionConfiguration.from_gapi(@gapi.default_encryption_configuration).freeze
        end

        ##
        # Set the {EncryptionConfiguration} object that represents the default
        # encryption method for all tables and models in the dataset. Once this
        # property is set, all newly-created partitioned tables and models in
        # the dataset will have their encryption set to this value, unless table
        # creation request (or query) overrides it.
        #
        # If the dataset is not a full resource representation (see
        # {#resource_full?}), the full representation will be retrieved before
        # the update to comply with ETag-based optimistic concurrency control.
        #
        # @see https://cloud.google.com/bigquery/docs/customer-managed-encryption
        #   Protecting Data with Cloud KMS Keys
        #
        # @param [EncryptionConfiguration] value The new encryption config.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   key_name = "projects/a/locations/b/keyRings/c/cryptoKeys/d"
        #   encrypt_config = bigquery.encryption kms_key: key_name
        #
        #   dataset.default_encryption = encrypt_config
        #
        # @!group Attributes
        #
        def default_encryption= value
          ensure_full_data!
          @gapi.default_encryption_configuration = value.to_gapi
          patch_gapi! :default_encryption_configuration
        end

        ##
        # Retrieves the access rules for a Dataset. The rules can be updated
        # when passing a block, see {Dataset::Access} for all the methods
        # available.
        #
        # If the dataset is not a full resource representation (see
        # {#resource_full?}), the full representation will be retrieved before
        # the update to comply with ETag-based optimistic concurrency control.
        #
        # @see https://cloud.google.com/bigquery/access-control BigQuery Access
        #   Control
        #
        # @yield [access] a block for setting rules
        # @yieldparam [Dataset::Access] access the object accepting rules
        #
        # @return [Google::Cloud::Bigquery::Dataset::Access] The access object.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   access = dataset.access
        #   access.writer_user? "reader@example.com" #=> false
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
          reload! unless resource_full?
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
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   dataset.delete
        #
        # @!group Lifecycle
        #
        def delete force: nil
          ensure_service!
          service.delete_dataset dataset_id, force
          # Set flag for #exists?
          @exists = false
          true
        end

        ##
        # Creates a new table. If you are adapting existing code that was
        # written for the [Rest API
        # ](https://cloud.google.com/bigquery/docs/reference/v2/tables#resource),
        # you can pass the table's schema as a hash (see example.)
        #
        # @param [String] table_id The ID of the table. The ID must contain only
        #   letters (`[A-Za-z]`), numbers (`[0-9]`), or underscores (`_`). The maximum
        #   length is 1,024 characters.
        # @param [String] name A descriptive name for the table.
        # @param [String] description A user-friendly description of the table.
        # @yield [table] a block for setting the table
        # @yieldparam [Google::Cloud::Bigquery::Table::Updater] table An updater
        #   to set additional properties on the table in the API request to
        #   create it.
        #
        # @return [Google::Cloud::Bigquery::Table] A new table object.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   table = dataset.create_table "my_table"
        #
        # @example You can also pass name and description options.
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   table = dataset.create_table "my_table",
        #                                name: "My Table",
        #                                description: "A description of table."
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
        #
        #   table = dataset.create_table "my_table" do |t|
        #     t.name = "My Table"
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
        # @example With time partitioning and clustering.
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   table = dataset.create_table "my_table" do |t|
        #     t.schema do |schema|
        #       schema.timestamp "dob", mode: :required
        #       schema.string "first_name", mode: :required
        #       schema.string "last_name", mode: :required
        #     end
        #     t.time_partitioning_type  = "DAY"
        #     t.time_partitioning_field = "dob"
        #     t.clustering_fields = ["last_name", "first_name"]
        #   end
        #
        # @example With range partitioning.
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   table = dataset.create_table "my_table" do |t|
        #     t.schema do |schema|
        #       schema.integer "my_table_id", mode: :required
        #       schema.string "my_table_data", mode: :required
        #     end
        #     t.range_partitioning_field = "my_table_id"
        #     t.range_partitioning_start = 0
        #     t.range_partitioning_interval = 10
        #     t.range_partitioning_end = 100
        #   end
        #
        # @!group Table
        #
        def create_table table_id, name: nil, description: nil
          ensure_service!
          new_tb = Google::Apis::BigqueryV2::Table.new(
            table_reference: Google::Apis::BigqueryV2::TableReference.new(
              project_id: project_id, dataset_id: dataset_id,
              table_id: table_id
            )
          )
          updater = Table::Updater.new(new_tb).tap do |tb|
            tb.name = name unless name.nil?
            tb.description = description unless description.nil?
          end

          yield updater if block_given?

          gapi = service.insert_table dataset_id, updater.to_gapi
          Table.from_gapi gapi, service
        end

        ##
        # Creates a new view, which is a virtual table defined by the given SQL query.
        #
        # With BigQuery's logical views, the query that defines the view is re-executed
        # every time the view is queried. Queries are billed according to the total amount
        # of data in all table fields referenced directly or indirectly by the
        # top-level query. (See {Table#view?} and {Table#query}.)
        #
        # For materialized views, see {#create_materialized_view}.
        #
        # @see https://cloud.google.com/bigquery/docs/views Creating views
        #
        # @param [String] table_id The ID of the view table. The ID must contain
        #   only letters (`[A-Za-z]`), numbers (`[0-9]`), or underscores (`_`). The
        #   maximum length is 1,024 characters.
        # @param [String] query The query that BigQuery executes when the view
        #   is referenced.
        # @param [String] name A descriptive name for the table.
        # @param [String] description A user-friendly description of the table.
        # @param [Boolean] standard_sql Specifies whether to use BigQuery's
        #   [standard
        #   SQL](https://cloud.google.com/bigquery/docs/reference/standard-sql/)
        #   dialect. Optional. The default value is true.
        # @param [Boolean] legacy_sql Specifies whether to use BigQuery's
        #   [legacy
        #   SQL](https://cloud.google.com/bigquery/docs/reference/legacy-sql)
        #   dialect. Optional. The default value is false.
        # @param [Array<String>, String] udfs User-defined function resources
        #   used in a legacy SQL query. May be either a code resource to load from
        #   a Google Cloud Storage URI (`gs://bucket/path`), or an inline resource
        #   that contains code for a user-defined function (UDF). Providing an
        #   inline code resource is equivalent to providing a URI for a file
        #   containing the same code.
        #
        #   This parameter is used for defining User Defined Function (UDF)
        #   resources only when using legacy SQL. Users of standard SQL should
        #   leverage either DDL (e.g. `CREATE [TEMPORARY] FUNCTION ...`) or the
        #   Routines API to define UDF resources.
        #
        #   For additional information on migrating, see: [Migrating to
        #   standard SQL - Differences in user-defined JavaScript
        #   functions](https://cloud.google.com/bigquery/docs/reference/standard-sql/migrating-from-legacy-sql#differences_in_user-defined_javascript_functions)
        #
        # @return [Google::Cloud::Bigquery::Table] A new table object.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   view = dataset.create_view "my_view",
        #                              "SELECT name, age FROM proj.dataset.users"
        #
        # @example A name and description can be provided:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   view = dataset.create_view "my_view",
        #                              "SELECT name, age FROM proj.dataset.users",
        #                              name: "My View", description: "This is my view"
        #
        # @!group Table
        #
        def create_view table_id,
                        query,
                        name: nil,
                        description: nil,
                        standard_sql: nil,
                        legacy_sql: nil,
                        udfs: nil
          use_legacy_sql = Convert.resolve_legacy_sql standard_sql, legacy_sql
          new_view_opts = {
            table_reference: Google::Apis::BigqueryV2::TableReference.new(
              project_id: project_id,
              dataset_id: dataset_id,
              table_id:   table_id
            ),
            friendly_name:   name,
            description:     description,
            view:            Google::Apis::BigqueryV2::ViewDefinition.new(
              query:                           query,
              use_legacy_sql:                  use_legacy_sql,
              user_defined_function_resources: udfs_gapi(udfs)
            )
          }.delete_if { |_, v| v.nil? }
          new_view = Google::Apis::BigqueryV2::Table.new(**new_view_opts)

          gapi = service.insert_table dataset_id, new_view
          Table.from_gapi gapi, service
        end

        ##
        # Creates a new materialized view.
        #
        # Materialized views are precomputed views that periodically cache results of a query for increased performance
        # and efficiency. BigQuery leverages precomputed results from materialized views and whenever possible reads
        # only delta changes from the base table to compute up-to-date results.
        #
        # Queries that use materialized views are generally faster and consume less resources than queries that retrieve
        # the same data only from the base table. Materialized views are helpful to significantly boost performance of
        # workloads that have the characteristic of common and repeated queries.
        #
        # For logical views, see {#create_view}.
        #
        # @see https://cloud.google.com/bigquery/docs/materialized-views-intro Introduction to materialized views
        #
        # @param [String] table_id The ID of the materialized view table. The ID must contain only letters (`[A-Za-z]`),
        #   numbers (`[0-9]`), or underscores (`_`). The maximum length is 1,024 characters.
        # @param [String] query The query that BigQuery executes when the materialized view is referenced.
        # @param [String] name A descriptive name for the table.
        # @param [String] description A user-friendly description of the table.
        # @param [Boolean] enable_refresh Enable automatic refresh of the materialized view when the base table is
        #   updated. Optional. The default value is true.
        # @param [Integer] refresh_interval_ms The maximum frequency in milliseconds at which this materialized view
        #   will be refreshed. Optional. The default value is `1_800_000` (30 minutes).
        #
        # @return [Google::Cloud::Bigquery::Table] A new table object.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   materialized_view = dataset.create_materialized_view "my_materialized_view",
        #                                                        "SELECT name, age FROM proj.dataset.users"
        #
        # @example Automatic refresh can be disabled:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   materialized_view = dataset.create_materialized_view "my_materialized_view",
        #                                                        "SELECT name, age FROM proj.dataset.users",
        #                                                        enable_refresh: false
        #
        # @!group Table
        #
        def create_materialized_view table_id,
                                     query,
                                     name: nil,
                                     description: nil,
                                     enable_refresh: nil,
                                     refresh_interval_ms: nil
          new_view_opts = {
            table_reference:   Google::Apis::BigqueryV2::TableReference.new(
              project_id: project_id,
              dataset_id: dataset_id,
              table_id:   table_id
            ),
            friendly_name:     name,
            description:       description,
            materialized_view: Google::Apis::BigqueryV2::MaterializedViewDefinition.new(
              enable_refresh:      enable_refresh,
              query:               query,
              refresh_interval_ms: refresh_interval_ms
            )
          }.delete_if { |_, v| v.nil? }
          new_view = Google::Apis::BigqueryV2::Table.new(**new_view_opts)

          gapi = service.insert_table dataset_id, new_view
          Table.from_gapi gapi, service
        end

        ##
        # Retrieves an existing table by ID.
        #
        # @param [String] table_id The ID of a table.
        # @param [Boolean] skip_lookup Optionally create just a local reference
        #   object without verifying that the resource exists on the BigQuery
        #   service. Calls made on this object will raise errors if the resource
        #   does not exist. Default is `false`. Optional.
        #
        # @return [Google::Cloud::Bigquery::Table, nil] Returns `nil` if the
        #   table does not exist.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   table = dataset.table "my_table"
        #   puts table.name
        #
        # @example Avoid retrieving the table resource with `skip_lookup`:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   table = dataset.table "my_table", skip_lookup: true
        #
        # @!group Table
        #
        def table table_id, skip_lookup: nil
          ensure_service!
          return Table.new_reference project_id, dataset_id, table_id, service if skip_lookup
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
        # @return [Array<Google::Cloud::Bigquery::Table>] An array of tables
        #   (See {Google::Cloud::Bigquery::Table::List})
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
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
        #
        #   tables = dataset.tables
        #   tables.all do |table|
        #     puts table.name
        #   end
        #
        # @!group Table
        #
        def tables token: nil, max: nil
          ensure_service!
          gapi = service.list_tables dataset_id, token: token, max: max
          Table::List.from_gapi gapi, service, dataset_id, max
        end

        ##
        # Retrieves an existing model by ID.
        #
        # @param [String] model_id The ID of a model.
        # @param [Boolean] skip_lookup Optionally create just a local reference
        #   object without verifying that the resource exists on the BigQuery
        #   service. Calls made on this object will raise errors if the resource
        #   does not exist. Default is `false`. Optional.
        #
        # @return [Google::Cloud::Bigquery::Model, nil] Returns `nil` if the
        #   model does not exist.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   model = dataset.model "my_model"
        #   puts model.model_id
        #
        # @example Avoid retrieving the model resource with `skip_lookup`:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   model = dataset.model "my_model", skip_lookup: true
        #
        # @!group Model
        #
        def model model_id, skip_lookup: nil
          ensure_service!
          return Model.new_reference project_id, dataset_id, model_id, service if skip_lookup
          gapi = service.get_model dataset_id, model_id
          Model.from_gapi_json gapi, service
        rescue Google::Cloud::NotFoundError
          nil
        end

        ##
        # Retrieves the list of models belonging to the dataset.
        #
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of models to return.
        #
        # @return [Array<Google::Cloud::Bigquery::Model>] An array of models
        #   (See {Google::Cloud::Bigquery::Model::List})
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   models = dataset.models
        #   models.each do |model|
        #     puts model.model_id
        #   end
        #
        # @example Retrieve all models: (See {Model::List#all})
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   models = dataset.models
        #   models.all do |model|
        #     puts model.model_id
        #   end
        #
        # @!group Model
        #
        def models token: nil, max: nil
          ensure_service!
          gapi = service.list_models dataset_id, token: token, max: max
          Model::List.from_gapi gapi, service, dataset_id, max
        end

        ##
        # Creates a new routine. The following attributes may be set in the yielded block:
        # {Routine::Updater#routine_type=}, {Routine::Updater#language=}, {Routine::Updater#arguments=},
        # {Routine::Updater#return_type=}, {Routine::Updater#imported_libraries=}, {Routine::Updater#body=}, and
        # {Routine::Updater#description=}.
        #
        # @param [String] routine_id The ID of the routine. The ID must contain only
        #   letters (`[A-Za-z]`), numbers (`[0-9]`), or underscores (`_`). The maximum length
        #   is 256 characters.
        # @yield [routine] A block for setting properties on the routine.
        # @yieldparam [Google::Cloud::Bigquery::Routine::Updater] routine An updater to set additional properties on the
        #   routine.
        #
        # @return [Google::Cloud::Bigquery::Routine] A new routine object.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   routine = dataset.create_routine "my_routine" do |r|
        #     r.routine_type = "SCALAR_FUNCTION"
        #     r.language = "SQL"
        #     r.arguments = [
        #       Google::Cloud::Bigquery::Argument.new(name: "x", data_type: "INT64")
        #     ]
        #     r.body = "x * 3"
        #     r.description = "My routine description"
        #   end
        #
        #   puts routine.routine_id
        #
        # @example Extended example:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.create_routine "my_routine" do |r|
        #     r.routine_type = "SCALAR_FUNCTION"
        #     r.language = :SQL
        #     r.body = "(SELECT SUM(IF(elem.name = \"foo\",elem.val,null)) FROM UNNEST(arr) AS elem)"
        #     r.arguments = [
        #       Google::Cloud::Bigquery::Argument.new(
        #         name: "arr",
        #         argument_kind: "FIXED_TYPE",
        #         data_type: Google::Cloud::Bigquery::StandardSql::DataType.new(
        #           type_kind: "ARRAY",
        #           array_element_type: Google::Cloud::Bigquery::StandardSql::DataType.new(
        #             type_kind: "STRUCT",
        #             struct_type: Google::Cloud::Bigquery::StandardSql::StructType.new(
        #               fields: [
        #                 Google::Cloud::Bigquery::StandardSql::Field.new(
        #                   name: "name",
        #                   type: Google::Cloud::Bigquery::StandardSql::DataType.new(type_kind: "STRING")
        #                 ),
        #                 Google::Cloud::Bigquery::StandardSql::Field.new(
        #                   name: "val",
        #                   type: Google::Cloud::Bigquery::StandardSql::DataType.new(type_kind: "INT64")
        #                 )
        #               ]
        #             )
        #           )
        #         )
        #       )
        #     ]
        #   end
        #
        # @!group Routine
        #
        def create_routine routine_id
          ensure_service!
          new_tb = Google::Apis::BigqueryV2::Routine.new(
            routine_reference: Google::Apis::BigqueryV2::RoutineReference.new(
              project_id: project_id, dataset_id: dataset_id, routine_id: routine_id
            )
          )
          updater = Routine::Updater.new new_tb

          yield updater if block_given?

          gapi = service.insert_routine dataset_id, updater.to_gapi
          Routine.from_gapi gapi, service
        end

        ##
        # Retrieves an existing routine by ID.
        #
        # @param [String] routine_id The ID of a routine.
        # @param [Boolean] skip_lookup Optionally create just a local reference
        #   object without verifying that the resource exists on the BigQuery
        #   service. Calls made on this object will raise errors if the resource
        #   does not exist. Default is `false`. Optional.
        #
        # @return [Google::Cloud::Bigquery::Routine, nil] Returns `nil` if the
        #   routine does not exist.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   routine = dataset.routine "my_routine"
        #   puts routine.routine_id
        #
        # @example Avoid retrieving the routine resource with `skip_lookup`:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   routine = dataset.routine "my_routine", skip_lookup: true
        #
        # @!group Routine
        #
        def routine routine_id, skip_lookup: nil
          ensure_service!
          return Routine.new_reference project_id, dataset_id, routine_id, service if skip_lookup
          gapi = service.get_routine dataset_id, routine_id
          Routine.from_gapi gapi, service
        rescue Google::Cloud::NotFoundError
          nil
        end

        ##
        # Retrieves the list of routines belonging to the dataset.
        #
        # @param [String] token A previously-returned page token representing
        #   part of the larger set of results to view.
        # @param [Integer] max Maximum number of routines to return.
        # @param [String] filter If set, then only the routines matching this filter are returned. The current supported
        #   form is `routineType:`, with a {Routine#routine_type} enum value. Example: `routineType:SCALAR_FUNCTION`.
        #
        # @return [Array<Google::Cloud::Bigquery::Routine>] An array of routines
        #   (See {Google::Cloud::Bigquery::Routine::List})
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   routines = dataset.routines
        #   routines.each do |routine|
        #     puts routine.routine_id
        #   end
        #
        # @example Retrieve all routines: (See {Routine::List#all})
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   routines = dataset.routines
        #   routines.all do |routine|
        #     puts routine.routine_id
        #   end
        #
        # @!group Routine
        #
        def routines token: nil, max: nil, filter: nil
          ensure_service!
          gapi = service.list_routines dataset_id, token: token, max: max, filter: filter
          Routine::List.from_gapi gapi, service, dataset_id, max, filter: filter
        end

        ##
        # Queries data by creating a [query
        # job](https://cloud.google.com/bigquery/docs/query-overview#query_jobs).
        #
        # Sets the current dataset as the default dataset in the query. Useful
        # for using unqualified table names.
        #
        # The geographic location for the job ("US", "EU", etc.) can be set via
        # {QueryJob::Updater#location=} in a block passed to this method. If the
        # dataset is a full resource representation (see {#resource_full?}), the
        # location of the job will be automatically set to the location of the
        # dataset.
        #
        # @param [String] query A query string, following the BigQuery [query
        #   syntax](https://cloud.google.com/bigquery/query-reference), of the
        #   query to execute. Example: "SELECT count(f1) FROM
        #   [myProjectId:myDatasetId.myTableId]".
        # @param [Array, Hash] params Standard SQL only. Used to pass query arguments when the `query` string contains
        #   either positional (`?`) or named (`@myparam`) query parameters. If value passed is an array `["foo"]`, the
        #   query must use positional query parameters. If value passed is a hash `{ myparam: "foo" }`, the query must
        #   use named query parameters. When set, `legacy_sql` will automatically be set to false and `standard_sql` to
        #   true.
        #
        #   BigQuery types are converted from Ruby types as follows:
        #
        #   | BigQuery     | Ruby                                 | Notes                                              |
        #   |--------------|--------------------------------------|----------------------------------------------------|
        #   | `BOOL`       | `true`/`false`                       |                                                    |
        #   | `INT64`      | `Integer`                            |                                                    |
        #   | `FLOAT64`    | `Float`                              |                                                    |
        #   | `NUMERIC`    | `BigDecimal`                         | `BigDecimal` values will be rounded to scale 9.    |
        #   | `BIGNUMERIC` | `BigDecimal`                         | NOT AUTOMATIC: Must be mapped using `types`, below.|
        #   | `STRING`     | `String`                             |                                                    |
        #   | `DATETIME`   | `DateTime`                           | `DATETIME` does not support time zone.             |
        #   | `DATE`       | `Date`                               |                                                    |
        #   | `GEOGRAPHY`  | `String` (WKT or GeoJSON)            | NOT AUTOMATIC: Must be mapped using `types`, below.|
        #   | `TIMESTAMP`  | `Time`                               |                                                    |
        #   | `TIME`       | `Google::Cloud::BigQuery::Time`      |                                                    |
        #   | `BYTES`      | `File`, `IO`, `StringIO`, or similar |                                                    |
        #   | `ARRAY`      | `Array`                              | Nested arrays, `nil` values are not supported.     |
        #   | `STRUCT`     | `Hash`                               | Hash keys may be strings or symbols.               |
        #
        #   See [Data Types](https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types) for an overview
        #   of each BigQuery data type, including allowed values. For the `GEOGRAPHY` type, see [Working with BigQuery
        #   GIS data](https://cloud.google.com/bigquery/docs/gis-data).
        # @param [Array, Hash] types Standard SQL only. Types of the SQL parameters in `params`. It is not always
        #   possible to infer the right SQL type from a value in `params`. In these cases, `types` must be used to
        #   specify the SQL type for these values.
        #
        #   Arguments must match the value type passed to `params`. This must be an `Array` when the query uses
        #   positional query parameters. This must be an `Hash` when the query uses named query parameters. The values
        #   should be BigQuery type codes from the following list:
        #
        #   * `:BOOL`
        #   * `:INT64`
        #   * `:FLOAT64`
        #   * `:NUMERIC`
        #   * `:BIGNUMERIC`
        #   * `:STRING`
        #   * `:DATETIME`
        #   * `:DATE`
        #   * `:GEOGRAPHY`
        #   * `:TIMESTAMP`
        #   * `:TIME`
        #   * `:BYTES`
        #   * `Array` - Lists are specified by providing the type code in an array. For example, an array of integers
        #     are specified as `[:INT64]`.
        #   * `Hash` - Types for STRUCT values (`Hash` objects) are specified using a `Hash` object, where the keys
        #     match the `params` hash, and the values are the types value that matches the data.
        #
        #   Types are optional.
        # @param [Hash<String|Symbol, External::DataSource>] external A Hash
        #   that represents the mapping of the external tables to the table
        #   names used in the SQL query. The hash keys are the table names, and
        #   the hash values are the external table objects. See {Dataset#query}.
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
        #   new tables. The default value is `needed`.
        #
        #   The following values are supported:
        #
        #   * `needed` - Create the table if it does not exist.
        #   * `never` - The table must already exist. A 'notFound' error is
        #     raised if the table does not exist.
        # @param [String] write Specifies the action that occurs if the
        #   destination table already exists. The default value is `empty`.
        #
        #   The following values are supported:
        #
        #   * `truncate` - BigQuery overwrites the table data.
        #   * `append` - BigQuery appends the data to the table.
        #   * `empty` - A 'duplicate' error is returned in the job result if the
        #     table exists and contains data.
        # @param [Boolean] dryrun If set to true, BigQuery doesn't run the job.
        #   Instead, if the query is valid, BigQuery returns statistics about
        #   the job such as how many bytes would be processed. If the query is
        #   invalid, an error returns. The default value is false.
        # @param [Boolean] standard_sql Specifies whether to use BigQuery's
        #   [standard
        #   SQL](https://cloud.google.com/bigquery/docs/reference/standard-sql/)
        #   dialect for this query. If set to true, the query will use standard
        #   SQL rather than the [legacy
        #   SQL](https://cloud.google.com/bigquery/docs/reference/legacy-sql)
        #   dialect. Optional. The default value is true.
        # @param [Boolean] legacy_sql Specifies whether to use BigQuery's
        #   [legacy
        #   SQL](https://cloud.google.com/bigquery/docs/reference/legacy-sql)
        #   dialect for this query. If set to false, the query will use
        #   BigQuery's [standard
        #   SQL](https://cloud.google.com/bigquery/docs/reference/standard-sql/)
        #   dialect. Optional. The default value is false.
        # @param [Boolean] large_results This option is specific to Legacy SQL.
        #   If `true`, allows the query to produce arbitrarily large result
        #   tables at a slight cost in performance. Requires `table` parameter
        #   to be set.
        # @param [Boolean] flatten This option is specific to Legacy SQL.
        #   Flattens all nested and repeated fields in the query results. The
        #   default value is `true`. `large_results` parameter must be `true` if
        #   this is set to `false`.
        # @param [Integer] maximum_billing_tier Limits the billing tier for this
        #   job. Queries that have resource usage beyond this tier will fail
        #   (without incurring a charge). WARNING: The billed byte amount can be
        #   multiplied by an amount up to this number! Most users should not need
        #   to alter this setting, and we recommend that you avoid introducing new
        #   uses of it. Deprecated.
        # @param [Integer] maximum_bytes_billed Limits the bytes billed for this
        #   job. Queries that will have bytes billed beyond this limit will fail
        #   (without incurring a charge). Optional. If unspecified, this will be
        #   set to your project default.
        # @param [String] job_id A user-defined ID for the query job. The ID
        #   must contain only letters (`[A-Za-z]`), numbers (`[0-9]`), underscores
        #   (`_`), or dashes (`-`). The maximum length is 1,024 characters. If
        #   `job_id` is provided, then `prefix` will not be used.
        #
        #   See [Generating a job
        #   ID](https://cloud.google.com/bigquery/docs/managing-jobs#generate-jobid).
        # @param [String] prefix A string, usually human-readable, that will be
        #   prepended to a generated value to produce a unique job ID. For
        #   example, the prefix `daily_import_job_` can be given to generate a
        #   job ID such as `daily_import_job_12vEDtMQ0mbp1Mo5Z7mzAFQJZazh`. The
        #   prefix must contain only letters (`[A-Za-z]`), numbers (`[0-9]`),
        #   underscores (`_`), or dashes (`-`). The maximum length of the entire ID
        #   is 1,024 characters. If `job_id` is provided, then `prefix` will not
        #   be used.
        # @param [Hash] labels A hash of user-provided labels associated with
        #   the job. You can use these to organize and group your jobs.
        #
        #   The labels applied to a resource must meet the following requirements:
        #
        #   * Each resource can have multiple labels, up to a maximum of 64.
        #   * Each label must be a key-value pair.
        #   * Keys have a minimum length of 1 character and a maximum length of
        #     63 characters, and cannot be empty. Values can be empty, and have
        #     a maximum length of 63 characters.
        #   * Keys and values can contain only lowercase letters, numeric characters,
        #     underscores, and dashes. All characters must use UTF-8 encoding, and
        #     international characters are allowed.
        #   * The key portion of a label must be unique. However, you can use the
        #     same key with multiple resources.
        #   * Keys must start with a lowercase letter or international character.
        # @param [Array<String>, String] udfs User-defined function resources
        #   used in a legacy SQL query. May be either a code resource to load from
        #   a Google Cloud Storage URI (`gs://bucket/path`), or an inline resource
        #   that contains code for a user-defined function (UDF). Providing an
        #   inline code resource is equivalent to providing a URI for a file
        #   containing the same code.
        #
        #   This parameter is used for defining User Defined Function (UDF)
        #   resources only when using legacy SQL. Users of standard SQL should
        #   leverage either DDL (e.g. `CREATE [TEMPORARY] FUNCTION ...`) or the
        #   Routines API to define UDF resources.
        #
        #   For additional information on migrating, see: [Migrating to
        #   standard SQL - Differences in user-defined JavaScript
        #   functions](https://cloud.google.com/bigquery/docs/reference/standard-sql/migrating-from-legacy-sql#differences_in_user-defined_javascript_functions)
        # @param [Boolean] create_session If true, creates a new session, where the
        #   session ID will be a server generated random id. If false, runs query
        #   with an existing session ID when one is provided in the `session_id`
        #   param, otherwise runs query in non-session mode. See {Job#session_id}.
        #   The default value is false.
        # @param [String] session_id The ID of an existing session. See also the
        #   `create_session` param and {Job#session_id}.
        # @yield [job] a job configuration object
        # @yieldparam [Google::Cloud::Bigquery::QueryJob::Updater] job a job
        #   configuration object for setting additional options for the query.
        #
        # @return [Google::Cloud::Bigquery::QueryJob] A new query job object.
        #
        # @example Query using standard SQL:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   job = dataset.query_job "SELECT name FROM my_table"
        #
        #   job.wait_until_done!
        #   if !job.failed?
        #     job.data.each do |row|
        #       puts row[:name]
        #     end
        #   end
        #
        # @example Query using legacy SQL:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   job = dataset.query_job "SELECT name FROM my_table",
        #                           legacy_sql: true
        #
        #   job.wait_until_done!
        #   if !job.failed?
        #     job.data.each do |row|
        #       puts row[:name]
        #     end
        #   end
        #
        # @example Query using positional query parameters:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   job = dataset.query_job "SELECT name FROM my_table WHERE id = ?",
        #                           params: [1]
        #
        #   job.wait_until_done!
        #   if !job.failed?
        #     job.data.each do |row|
        #       puts row[:name]
        #     end
        #   end
        #
        # @example Query using named query parameters:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   job = dataset.query_job "SELECT name FROM my_table WHERE id = @id",
        #                           params: { id: 1 }
        #
        #   job.wait_until_done!
        #   if !job.failed?
        #     job.data.each do |row|
        #       puts row[:name]
        #     end
        #   end
        #
        # @example Query using named query parameters with types:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   job = dataset.query_job "SELECT name FROM my_table WHERE id IN UNNEST(@ids)",
        #                           params: { ids: [] },
        #                           types: { ids: [:INT64] }
        #
        #   job.wait_until_done!
        #   if !job.failed?
        #     job.data.each do |row|
        #       puts row[:name]
        #     end
        #   end
        #
        # @example Execute a DDL statement:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   job = dataset.query_job "CREATE TABLE my_table (x INT64)"
        #
        #   job.wait_until_done!
        #   if !job.failed?
        #     table_ref = job.ddl_target_table # Or ddl_target_routine for CREATE/DROP FUNCTION/PROCEDURE
        #   end
        #
        # @example Execute a DML statement:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   job = dataset.query_job "UPDATE my_table SET x = x + 1 WHERE x IS NOT NULL"
        #
        #   job.wait_until_done!
        #   if !job.failed?
        #     puts job.num_dml_affected_rows
        #   end
        #
        # @example Run query in a session:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   job = dataset.query_job "CREATE TEMPORARY TABLE temptable AS SELECT 17 as foo", create_session: true
        #
        #   job.wait_until_done!
        #
        #   session_id = job.session_id
        #   data = dataset.query "SELECT * FROM temptable", session_id: session_id
        #
        # @example Query using external data source, set destination:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   csv_url = "gs://bucket/path/to/data.csv"
        #   csv_table = dataset.external csv_url do |csv|
        #     csv.autodetect = true
        #     csv.skip_leading_rows = 1
        #   end
        #
        #   job = dataset.query_job "SELECT * FROM my_ext_table" do |query|
        #     query.external = { my_ext_table: csv_table }
        #     query.table = dataset.table "my_table", skip_lookup: true
        #   end
        #
        #   job.wait_until_done!
        #   if !job.failed?
        #     job.data.each do |row|
        #       puts row[:name]
        #     end
        #   end
        #
        # @!group Data
        #
        def query_job query,
                      params: nil,
                      types: nil,
                      external: nil,
                      priority: "INTERACTIVE",
                      cache: true,
                      table: nil,
                      create: nil,
                      write: nil,
                      dryrun: nil,
                      standard_sql: nil,
                      legacy_sql: nil,
                      large_results: nil,
                      flatten: nil,
                      maximum_billing_tier: nil,
                      maximum_bytes_billed: nil,
                      job_id: nil,
                      prefix: nil,
                      labels: nil,
                      udfs: nil,
                      create_session: nil,
                      session_id: nil
          ensure_service!
          options = {
            params: params,
            types: types,
            external: external,
            priority: priority,
            cache: cache,
            table: table,
            create: create,
            write: write,
            dryrun: dryrun,
            standard_sql: standard_sql,
            legacy_sql: legacy_sql,
            large_results: large_results,
            flatten: flatten,
            maximum_billing_tier: maximum_billing_tier,
            maximum_bytes_billed: maximum_bytes_billed,
            job_id: job_id,
            prefix: prefix,
            labels: labels,
            udfs: udfs,
            create_session: create_session,
            session_id: session_id
          }

          updater = QueryJob::Updater.from_options service, query, options
          updater.dataset = self
          updater.location = location if location # may be dataset reference

          yield updater if block_given?

          gapi = service.query_job updater.to_gapi
          Job.from_gapi gapi, service
        end

        ##
        # Queries data and waits for the results. In this method, a {QueryJob}
        # is created and its results are saved to a temporary table, then read
        # from the table. Timeouts and transient errors are generally handled
        # as needed to complete the query. When used for executing DDL/DML
        # statements, this method does not return row data.
        #
        # Sets the current dataset as the default dataset in the query. Useful
        # for using unqualified table names.
        #
        # The geographic location for the job ("US", "EU", etc.) can be set via
        # {QueryJob::Updater#location=} in a block passed to this method. If the
        # dataset is a full resource representation (see {#resource_full?}), the
        # location of the job will be automatically set to the location of the
        # dataset.
        #
        # @see https://cloud.google.com/bigquery/querying-data Querying Data
        #
        # @param [String] query A query string, following the BigQuery [query
        #   syntax](https://cloud.google.com/bigquery/query-reference), of the
        #   query to execute. Example: "SELECT count(f1) FROM
        #   [myProjectId:myDatasetId.myTableId]".
        # @param [Array, Hash] params Standard SQL only. Used to pass query arguments when the `query` string contains
        #   either positional (`?`) or named (`@myparam`) query parameters. If value passed is an array `["foo"]`, the
        #   query must use positional query parameters. If value passed is a hash `{ myparam: "foo" }`, the query must
        #   use named query parameters. When set, `legacy_sql` will automatically be set to false and `standard_sql` to
        #   true.
        #
        #   BigQuery types are converted from Ruby types as follows:
        #
        #   | BigQuery     | Ruby                                 | Notes                                              |
        #   |--------------|--------------------------------------|----------------------------------------------------|
        #   | `BOOL`       | `true`/`false`                       |                                                    |
        #   | `INT64`      | `Integer`                            |                                                    |
        #   | `FLOAT64`    | `Float`                              |                                                    |
        #   | `NUMERIC`    | `BigDecimal`                         | `BigDecimal` values will be rounded to scale 9.    |
        #   | `BIGNUMERIC` | `BigDecimal`                         | NOT AUTOMATIC: Must be mapped using `types`, below.|
        #   | `STRING`     | `String`                             |                                                    |
        #   | `DATETIME`   | `DateTime`                           | `DATETIME` does not support time zone.             |
        #   | `DATE`       | `Date`                               |                                                    |
        #   | `GEOGRAPHY`  | `String` (WKT or GeoJSON)            | NOT AUTOMATIC: Must be mapped using `types`, below.|
        #   | `TIMESTAMP`  | `Time`                               |                                                    |
        #   | `TIME`       | `Google::Cloud::BigQuery::Time`      |                                                    |
        #   | `BYTES`      | `File`, `IO`, `StringIO`, or similar |                                                    |
        #   | `ARRAY`      | `Array`                              | Nested arrays, `nil` values are not supported.     |
        #   | `STRUCT`     | `Hash`                               | Hash keys may be strings or symbols.               |
        #
        #   See [Data Types](https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types) for an overview
        #   of each BigQuery data type, including allowed values. For the `GEOGRAPHY` type, see [Working with BigQuery
        #   GIS data](https://cloud.google.com/bigquery/docs/gis-data).
        # @param [Array, Hash] types Standard SQL only. Types of the SQL parameters in `params`. It is not always
        #   possible to infer the right SQL type from a value in `params`. In these cases, `types` must be used to
        #   specify the SQL type for these values.
        #
        #   Arguments must match the value type passed to `params`. This must be an `Array` when the query uses
        #   positional query parameters. This must be an `Hash` when the query uses named query parameters. The values
        #   should be BigQuery type codes from the following list:
        #
        #   * `:BOOL`
        #   * `:INT64`
        #   * `:FLOAT64`
        #   * `:NUMERIC`
        #   * `:BIGNUMERIC`
        #   * `:STRING`
        #   * `:DATETIME`
        #   * `:DATE`
        #   * `:GEOGRAPHY`
        #   * `:TIMESTAMP`
        #   * `:TIME`
        #   * `:BYTES`
        #   * `Array` - Lists are specified by providing the type code in an array. For example, an array of integers
        #     are specified as `[:INT64]`.
        #   * `Hash` - Types for STRUCT values (`Hash` objects) are specified using a `Hash` object, where the keys
        #     match the `params` hash, and the values are the types value that matches the data.
        #
        #   Types are optional.
        # @param [Hash<String|Symbol, External::DataSource>] external A Hash
        #   that represents the mapping of the external tables to the table
        #   names used in the SQL query. The hash keys are the table names, and
        #   the hash values are the external table objects. See {Dataset#query}.
        # @param [Integer] max The maximum number of rows of data to return per
        #   page of results. Setting this flag to a small value such as 1000 and
        #   then paging through results might improve reliability when the query
        #   result set is large. In addition to this limit, responses are also
        #   limited to 10 MB. By default, there is no maximum row count, and
        #   only the byte limit applies.
        # @param [Boolean] cache Whether to look for the result in the query
        #   cache. The query cache is a best-effort cache that will be flushed
        #   whenever tables in the query are modified. The default value is
        #   true. For more information, see [query
        #   caching](https://developers.google.com/bigquery/querying-data).
        # @param [Boolean] standard_sql Specifies whether to use BigQuery's
        #   [standard
        #   SQL](https://cloud.google.com/bigquery/docs/reference/standard-sql/)
        #   dialect for this query. If set to true, the query will use standard
        #   SQL rather than the [legacy
        #   SQL](https://cloud.google.com/bigquery/docs/reference/legacy-sql)
        #   dialect. When set to true, the values of `large_results` and
        #   `flatten` are ignored; the query will be run as if `large_results`
        #   is true and `flatten` is false. Optional. The default value is
        #   true.
        # @param [Boolean] legacy_sql Specifies whether to use BigQuery's
        #   [legacy
        #   SQL](https://cloud.google.com/bigquery/docs/reference/legacy-sql)
        #   dialect for this query. If set to false, the query will use
        #   BigQuery's [standard
        #   SQL](https://cloud.google.com/bigquery/docs/reference/standard-sql/)
        #   When set to false, the values of `large_results` and `flatten` are
        #   ignored; the query will be run as if `large_results` is true and
        #   `flatten` is false. Optional. The default value is false.
        # @param [String] session_id The ID of an existing session. See the
        #   `create_session` param in {#query_job} and {Job#session_id}.
        # @yield [job] a job configuration object
        # @yieldparam [Google::Cloud::Bigquery::QueryJob::Updater] job a job
        #   configuration object for setting additional options for the query.
        #
        # @return [Google::Cloud::Bigquery::Data] A new data object.
        #
        # @example Query using standard SQL:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   data = dataset.query "SELECT name FROM my_table"
        #
        #   # Iterate over the first page of results
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #   # Retrieve the next page of results
        #   data = data.next if data.next?
        #
        # @example Query using legacy SQL:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   data = dataset.query "SELECT name FROM my_table",
        #                        legacy_sql: true
        #
        #   # Iterate over the first page of results
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #   # Retrieve the next page of results
        #   data = data.next if data.next?
        #
        # @example Query using positional query parameters:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   data = dataset.query "SELECT name FROM my_table WHERE id = ?",
        #                        params: [1]
        #
        #   # Iterate over the first page of results
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #   # Retrieve the next page of results
        #   data = data.next if data.next?
        #
        # @example Query using named query parameters:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   data = dataset.query "SELECT name FROM my_table WHERE id = @id",
        #                        params: { id: 1 }
        #
        #   # Iterate over the first page of results
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #   # Retrieve the next page of results
        #   data = data.next if data.next?
        #
        # @example Query using named query parameters with types:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   data = dataset.query "SELECT name FROM my_table WHERE id IN UNNEST(@ids)",
        #                        params: { ids: [] },
        #                        types: { ids: [:INT64] }
        #
        #   # Iterate over the first page of results
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #   # Retrieve the next page of results
        #   data = data.next if data.next?
        #
        # @example Execute a DDL statement:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   data = dataset.query "CREATE TABLE my_table (x INT64)"
        #
        #   table_ref = data.ddl_target_table # Or ddl_target_routine for CREATE/DROP FUNCTION/PROCEDURE
        #
        # @example Execute a DML statement:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   data = dataset.query "UPDATE my_table SET x = x + 1 WHERE x IS NOT NULL"
        #
        #   puts data.num_dml_affected_rows
        #
        # @example Run query in a session:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   job = dataset.query_job "CREATE TEMPORARY TABLE temptable AS SELECT 17 as foo", create_session: true
        #
        #   job.wait_until_done!
        #
        #   session_id = job.session_id
        #   data = dataset.query "SELECT * FROM temptable", session_id: session_id
        #
        # @example Query using external data source, set destination:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   csv_url = "gs://bucket/path/to/data.csv"
        #   csv_table = dataset.external csv_url do |csv|
        #     csv.autodetect = true
        #     csv.skip_leading_rows = 1
        #   end
        #
        #   data = dataset.query "SELECT * FROM my_ext_table" do |query|
        #     query.external = { my_ext_table: csv_table }
        #     query.table = dataset.table "my_table", skip_lookup: true
        #   end
        #
        #   # Iterate over the first page of results
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #   # Retrieve the next page of results
        #   data = data.next if data.next?
        #
        # @!group Data
        #
        def query query,
                  params: nil,
                  types: nil,
                  external: nil,
                  max: nil,
                  cache: true,
                  standard_sql: nil,
                  legacy_sql: nil,
                  session_id: nil,
                  &block
          job = query_job query,
                          params: params,
                          types: types,
                          external: external,
                          cache: cache,
                          standard_sql: standard_sql,
                          legacy_sql: legacy_sql,
                          session_id: session_id,
                          &block
          job.wait_until_done!
          ensure_job_succeeded! job

          job.data max: max
        end

        ##
        # Creates a new External::DataSource (or subclass) object that
        # represents the external data source that can be queried from directly,
        # even though the data is not stored in BigQuery. Instead of loading or
        # streaming the data, this object references the external data source.
        #
        # @see https://cloud.google.com/bigquery/external-data-sources Querying
        #   External Data Sources
        #
        # @param [String, Array<String>] url The fully-qualified URL(s) that
        #   point to your data in Google Cloud. An attempt will be made to
        #   derive the format from the URLs provided.
        # @param [String|Symbol] format The data format. This value will be used
        #   even if the provided URLs are recognized as a different format.
        #   Optional.
        #
        #   The following values are supported:
        #
        #   * `csv` - CSV
        #   * `json` - [Newline-delimited JSON](http://jsonlines.org/)
        #   * `avro` - [Avro](http://avro.apache.org/)
        #   * `sheets` - Google Sheets
        #   * `datastore_backup` - Cloud Datastore backup
        #   * `bigtable` - Bigtable
        #
        # @return [External::DataSource] External data source.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   csv_url = "gs://bucket/path/to/data.csv"
        #   csv_table = dataset.external csv_url do |csv|
        #     csv.autodetect = true
        #     csv.skip_leading_rows = 1
        #   end
        #
        #   data = dataset.query "SELECT * FROM my_ext_table",
        #                         external: { my_ext_table: csv_table }
        #
        #   data.each do |row|
        #     puts row[:name]
        #   end
        #
        def external url, format: nil
          ext = External.from_urls url, format
          yield ext if block_given?
          ext
        end

        ##
        # Loads data into the provided destination table using an asynchronous
        # method. In this method, a {LoadJob} is immediately returned. The
        # caller may poll the service by repeatedly calling {Job#reload!} and
        # {Job#done?} to detect when the job is done, or simply block until the
        # job is done by calling #{Job#wait_until_done!}. See also {#load}.
        #
        # For the source of the data, you can pass a google-cloud storage file
        # path or a google-cloud-storage `File` instance. Or, you can upload a
        # file directly. See [Loading Data with a POST
        # Request](https://cloud.google.com/bigquery/loading-data-post-request#multipart).
        #
        # The geographic location for the job ("US", "EU", etc.) can be set via
        # {LoadJob::Updater#location=} in a block passed to this method. If the
        # dataset is a full resource representation (see {#resource_full?}), the
        # location of the job will be automatically set to the location of the
        # dataset.
        #
        # @param [String] table_id The destination table to load the data into.
        # @param [File, Google::Cloud::Storage::File, String, URI,
        #   Array<Google::Cloud::Storage::File, String, URI>] files
        #   A file or the URI of a Google Cloud Storage file, or an Array of
        #   those, containing data to load into the table.
        # @param [String] format The exported file format. The default value is
        #   `csv`.
        #
        #   The following values are supported:
        #
        #   * `csv` - CSV
        #   * `json` - [Newline-delimited JSON](http://jsonlines.org/)
        #   * `avro` - [Avro](http://avro.apache.org/)
        #   * `orc` - [ORC](https://cloud.google.com/bigquery/docs/loading-data-cloud-storage-orc)
        #   * `parquet` - [Parquet](https://parquet.apache.org/)
        #   * `datastore_backup` - Cloud Datastore backup
        # @param [String] create Specifies whether the job is allowed to create
        #   new tables. The default value is `needed`.
        #
        #   The following values are supported:
        #
        #   * `needed` - Create the table if it does not exist.
        #   * `never` - The table must already exist. A 'notFound' error is
        #     raised if the table does not exist.
        # @param [String] write Specifies how to handle data already present in
        #   the table. The default value is `append`.
        #
        #   The following values are supported:
        #
        #   * `truncate` - BigQuery overwrites the table data.
        #   * `append` - BigQuery appends the data to the table.
        #   * `empty` - An error will be returned if the table already contains
        #     data.
        # @param [Array<String>] projection_fields If the `format` option is set
        #   to `datastore_backup`, indicates which entity properties to load
        #   from a Cloud Datastore backup. Property names are case sensitive and
        #   must be top-level properties. If not set, BigQuery loads all
        #   properties. If any named property isn't found in the Cloud Datastore
        #   backup, an invalid error is returned.
        # @param [Boolean] jagged_rows Accept rows that are missing trailing
        #   optional columns. The missing values are treated as nulls. If
        #   `false`, records with missing trailing columns are treated as bad
        #   records, and if there are too many bad records, an invalid error is
        #   returned in the job result. The default value is `false`. Only
        #   applicable to CSV, ignored for other formats.
        # @param [Boolean] quoted_newlines Indicates if BigQuery should allow
        #   quoted data sections that contain newline characters in a CSV file.
        #   The default value is `false`.
        # @param [Boolean] autodetect Indicates if BigQuery should
        #   automatically infer the options and schema for CSV and JSON sources.
        #   The default value is `false`.
        # @param [String] encoding The character encoding of the data. The
        #   supported values are `UTF-8` or `ISO-8859-1`. The default value is
        #   `UTF-8`.
        # @param [String] delimiter Specifices the separator for fields in a CSV
        #   file. BigQuery converts the string to `ISO-8859-1` encoding, and
        #   then uses the first byte of the encoded string to split the data in
        #   its raw, binary state. Default is <code>,</code>.
        # @param [Boolean] ignore_unknown Indicates if BigQuery should allow
        #   extra values that are not represented in the table schema. If true,
        #   the extra values are ignored. If false, records with extra columns
        #   are treated as bad records, and if there are too many bad records,
        #   an invalid error is returned in the job result. The default value is
        #   `false`.
        #
        #   The `format` property determines what BigQuery treats as an extra
        #   value:
        #
        #   * `CSV`: Trailing columns
        #   * `JSON`: Named values that don't match any column names
        # @param [Integer] max_bad_records The maximum number of bad records
        #   that BigQuery can ignore when running the job. If the number of bad
        #   records exceeds this value, an invalid error is returned in the job
        #   result. The default value is `0`, which requires that all records
        #   are valid.
        # @param [String] null_marker Specifies a string that represents a null
        #   value in a CSV file. For example, if you specify `\N`, BigQuery
        #   interprets `\N` as a null value when loading a CSV file. The default
        #   value is the empty string. If you set this property to a custom
        #   value, BigQuery throws an error if an empty string is present for
        #   all data types except for STRING and BYTE. For STRING and BYTE
        #   columns, BigQuery interprets the empty string as an empty value.
        # @param [String] quote The value that is used to quote data sections in
        #   a CSV file. BigQuery converts the string to ISO-8859-1 encoding, and
        #   then uses the first byte of the encoded string to split the data in
        #   its raw, binary state. The default value is a double-quote
        #   <code>"</code>. If your data does not contain quoted sections, set
        #   the property value to an empty string. If your data contains quoted
        #   newline characters, you must also set the allowQuotedNewlines
        #   property to true.
        # @param [Integer] skip_leading The number of rows at the top of a CSV
        #   file that BigQuery will skip when loading the data. The default
        #   value is `0`. This property is useful if you have header rows in the
        #   file that should be skipped.
        # @param [Google::Cloud::Bigquery::Schema] schema The schema for the
        #   destination table. Optional. The schema can be omitted if the
        #   destination table already exists, or if you're loading data from a
        #   Google Cloud Datastore backup.
        #
        #   See {Project#schema} for the creation of the schema for use with
        #   this option. Also note that for most use cases, the block yielded by
        #   this method is a more convenient way to configure the schema.
        # @param [String] job_id A user-defined ID for the load job. The ID
        #   must contain only letters (`[A-Za-z]`), numbers (`[0-9]`), underscores
        #   (`_`), or dashes (`-`). The maximum length is 1,024 characters. If
        #   `job_id` is provided, then `prefix` will not be used.
        #
        #   See [Generating a job
        #   ID](https://cloud.google.com/bigquery/docs/managing-jobs#generate-jobid).
        # @param [String] prefix A string, usually human-readable, that will be
        #   prepended to a generated value to produce a unique job ID. For
        #   example, the prefix `daily_import_job_` can be given to generate a
        #   job ID such as `daily_import_job_12vEDtMQ0mbp1Mo5Z7mzAFQJZazh`. The
        #   prefix must contain only letters (`[A-Za-z]`), numbers (`[0-9]`),
        #   underscores (`_`), or dashes (`-`). The maximum length of the entire ID
        #   is 1,024 characters. If `job_id` is provided, then `prefix` will not
        #   be used.
        # @param [Hash] labels A hash of user-provided labels associated with
        #   the job. You can use these to organize and group your jobs.
        #
        #   The labels applied to a resource must meet the following requirements:
        #
        #   * Each resource can have multiple labels, up to a maximum of 64.
        #   * Each label must be a key-value pair.
        #   * Keys have a minimum length of 1 character and a maximum length of
        #     63 characters, and cannot be empty. Values can be empty, and have
        #     a maximum length of 63 characters.
        #   * Keys and values can contain only lowercase letters, numeric characters,
        #     underscores, and dashes. All characters must use UTF-8 encoding, and
        #     international characters are allowed.
        #   * The key portion of a label must be unique. However, you can use the
        #     same key with multiple resources.
        #   * Keys must start with a lowercase letter or international character.
        # @yield [updater] A block for setting the schema and other
        #   options for the destination table. The schema can be omitted if the
        #   destination table already exists, or if you're loading data from a
        #   Google Cloud Datastore backup.
        # @yieldparam [Google::Cloud::Bigquery::LoadJob::Updater] updater An
        #   updater to modify the load job and its schema.
        # @param [Boolean] dryrun  If set, don't actually run this job. Behavior
        #   is undefined however for non-query jobs and may result in an error.
        #   Deprecated.
        #
        # @return [Google::Cloud::Bigquery::LoadJob] A new load job object.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   gs_url = "gs://my-bucket/file-name.csv"
        #   load_job = dataset.load_job "my_new_table", gs_url do |schema|
        #     schema.string "first_name", mode: :required
        #     schema.record "cities_lived", mode: :repeated do |nested_schema|
        #       nested_schema.string "place", mode: :required
        #       nested_schema.integer "number_of_years", mode: :required
        #     end
        #   end
        #
        # @example Pass a google-cloud-storage `File` instance:
        #   require "google/cloud/bigquery"
        #   require "google/cloud/storage"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   storage = Google::Cloud::Storage.new
        #   bucket = storage.bucket "my-bucket"
        #   file = bucket.file "file-name.csv"
        #   load_job = dataset.load_job "my_new_table", file do |schema|
        #     schema.string "first_name", mode: :required
        #     schema.record "cities_lived", mode: :repeated do |nested_schema|
        #       nested_schema.string "place", mode: :required
        #       nested_schema.integer "number_of_years", mode: :required
        #     end
        #   end
        #
        # @example Pass a list of google-cloud-storage files:
        #   require "google/cloud/bigquery"
        #   require "google/cloud/storage"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   storage = Google::Cloud::Storage.new
        #   bucket = storage.bucket "my-bucket"
        #   file = bucket.file "file-name.csv"
        #   list = [file, "gs://my-bucket/file-name2.csv"]
        #   load_job = dataset.load_job "my_new_table", list do |schema|
        #     schema.string "first_name", mode: :required
        #     schema.record "cities_lived", mode: :repeated do |nested_schema|
        #       nested_schema.string "place", mode: :required
        #       nested_schema.integer "number_of_years", mode: :required
        #     end
        #   end
        #
        # @example Upload a file directly:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   file = File.open "my_data.csv"
        #   load_job = dataset.load_job "my_new_table", file do |schema|
        #     schema.string "first_name", mode: :required
        #     schema.record "cities_lived", mode: :repeated do |nested_schema|
        #       nested_schema.string "place", mode: :required
        #       nested_schema.integer "number_of_years", mode: :required
        #     end
        #   end
        #
        # @example Schema is not required with a Cloud Datastore backup:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   load_job = dataset.load_job(
        #                "my_new_table",
        #                "gs://my-bucket/xxxx.kind_name.backup_info") do |j|
        #     j.format = "datastore_backup"
        #   end
        #
        # @!group Data
        #
        def load_job table_id, files, format: nil, create: nil, write: nil, projection_fields: nil, jagged_rows: nil,
                     quoted_newlines: nil, encoding: nil, delimiter: nil, ignore_unknown: nil, max_bad_records: nil,
                     quote: nil, skip_leading: nil, schema: nil, job_id: nil, prefix: nil, labels: nil, autodetect: nil,
                     null_marker: nil, dryrun: nil
          ensure_service!

          updater = load_job_updater table_id,
                                     format: format, create: create, write: write, projection_fields: projection_fields,
                                     jagged_rows: jagged_rows, quoted_newlines: quoted_newlines, encoding: encoding,
                                     delimiter: delimiter, ignore_unknown: ignore_unknown,
                                     max_bad_records: max_bad_records, quote: quote, skip_leading: skip_leading,
                                     dryrun: dryrun, schema: schema, job_id: job_id, prefix: prefix, labels: labels,
                                     autodetect: autodetect, null_marker: null_marker

          yield updater if block_given?

          load_local_or_uri files, updater
        end

        ##
        # Loads data into the provided destination table using a synchronous
        # method that blocks for a response. Timeouts and transient errors are
        # generally handled as needed to complete the job. See also
        # {#load_job}.
        #
        # For the source of the data, you can pass a google-cloud storage file
        # path or a google-cloud-storage `File` instance. Or, you can upload a
        # file directly. See [Loading Data with a POST
        # Request](https://cloud.google.com/bigquery/loading-data-post-request#multipart).
        #
        # The geographic location for the job ("US", "EU", etc.) can be set via
        # {LoadJob::Updater#location=} in a block passed to this method. If the
        # dataset is a full resource representation (see {#resource_full?}), the
        # location of the job will be automatically set to the location of the
        # dataset.
        #
        # @param [String] table_id The destination table to load the data into.
        # @param [File, Google::Cloud::Storage::File, String, URI,
        #   Array<Google::Cloud::Storage::File, String, URI>] files
        #   A file or the URI of a Google Cloud Storage file, or an Array of
        #   those, containing data to load into the table.
        # @param [String] format The exported file format. The default value is
        #   `csv`.
        #
        #   The following values are supported:
        #
        #   * `csv` - CSV
        #   * `json` - [Newline-delimited JSON](http://jsonlines.org/)
        #   * `avro` - [Avro](http://avro.apache.org/)
        #   * `orc` - [ORC](https://cloud.google.com/bigquery/docs/loading-data-cloud-storage-orc)
        #   * `parquet` - [Parquet](https://parquet.apache.org/)
        #   * `datastore_backup` - Cloud Datastore backup
        # @param [String] create Specifies whether the job is allowed to create
        #   new tables. The default value is `needed`.
        #
        #   The following values are supported:
        #
        #   * `needed` - Create the table if it does not exist.
        #   * `never` - The table must already exist. A 'notFound' error is
        #     raised if the table does not exist.
        # @param [String] write Specifies how to handle data already present in
        #   the table. The default value is `append`.
        #
        #   The following values are supported:
        #
        #   * `truncate` - BigQuery overwrites the table data.
        #   * `append` - BigQuery appends the data to the table.
        #   * `empty` - An error will be returned if the table already contains
        #     data.
        # @param [Array<String>] projection_fields If the `format` option is set
        #   to `datastore_backup`, indicates which entity properties to load
        #   from a Cloud Datastore backup. Property names are case sensitive and
        #   must be top-level properties. If not set, BigQuery loads all
        #   properties. If any named property isn't found in the Cloud Datastore
        #   backup, an invalid error is returned.
        # @param [Boolean] jagged_rows Accept rows that are missing trailing
        #   optional columns. The missing values are treated as nulls. If
        #   `false`, records with missing trailing columns are treated as bad
        #   records, and if there are too many bad records, an invalid error is
        #   returned in the job result. The default value is `false`. Only
        #   applicable to CSV, ignored for other formats.
        # @param [Boolean] quoted_newlines Indicates if BigQuery should allow
        #   quoted data sections that contain newline characters in a CSV file.
        #   The default value is `false`.
        # @param [Boolean] autodetect Indicates if BigQuery should
        #   automatically infer the options and schema for CSV and JSON sources.
        #   The default value is `false`.
        # @param [String] encoding The character encoding of the data. The
        #   supported values are `UTF-8` or `ISO-8859-1`. The default value is
        #   `UTF-8`.
        # @param [String] delimiter Specifices the separator for fields in a CSV
        #   file. BigQuery converts the string to `ISO-8859-1` encoding, and
        #   then uses the first byte of the encoded string to split the data in
        #   its raw, binary state. Default is <code>,</code>.
        # @param [Boolean] ignore_unknown Indicates if BigQuery should allow
        #   extra values that are not represented in the table schema. If true,
        #   the extra values are ignored. If false, records with extra columns
        #   are treated as bad records, and if there are too many bad records,
        #   an invalid error is returned in the job result. The default value is
        #   `false`.
        #
        #   The `format` property determines what BigQuery treats as an extra
        #   value:
        #
        #   * `CSV`: Trailing columns
        #   * `JSON`: Named values that don't match any column names
        # @param [Integer] max_bad_records The maximum number of bad records
        #   that BigQuery can ignore when running the job. If the number of bad
        #   records exceeds this value, an invalid error is returned in the job
        #   result. The default value is `0`, which requires that all records
        #   are valid.
        # @param [String] null_marker Specifies a string that represents a null
        #   value in a CSV file. For example, if you specify `\N`, BigQuery
        #   interprets `\N` as a null value when loading a CSV file. The default
        #   value is the empty string. If you set this property to a custom
        #   value, BigQuery throws an error if an empty string is present for
        #   all data types except for STRING and BYTE. For STRING and BYTE
        #   columns, BigQuery interprets the empty string as an empty value.
        # @param [String] quote The value that is used to quote data sections in
        #   a CSV file. BigQuery converts the string to ISO-8859-1 encoding, and
        #   then uses the first byte of the encoded string to split the data in
        #   its raw, binary state. The default value is a double-quote
        #   <code>"</code>. If your data does not contain quoted sections, set
        #   the property value to an empty string. If your data contains quoted
        #   newline characters, you must also set the allowQuotedNewlines
        #   property to true.
        # @param [Integer] skip_leading The number of rows at the top of a CSV
        #   file that BigQuery will skip when loading the data. The default
        #   value is `0`. This property is useful if you have header rows in the
        #   file that should be skipped.
        # @param [Google::Cloud::Bigquery::Schema] schema The schema for the
        #   destination table. Optional. The schema can be omitted if the
        #   destination table already exists, or if you're loading data from a
        #   Google Cloud Datastore backup.
        #
        #   See {Project#schema} for the creation of the schema for use with
        #   this option. Also note that for most use cases, the block yielded by
        #   this method is a more convenient way to configure the schema.
        #
        # @yield [updater] A block for setting the schema of the destination
        #   table and other options for the load job. The schema can be omitted
        #   if the destination table already exists, or if you're loading data
        #   from a Google Cloud Datastore backup.
        # @yieldparam [Google::Cloud::Bigquery::LoadJob::Updater] updater An
        #   updater to modify the load job and its schema.
        #
        # @return [Boolean] Returns `true` if the load job was successful.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   gs_url = "gs://my-bucket/file-name.csv"
        #   dataset.load "my_new_table", gs_url do |schema|
        #     schema.string "first_name", mode: :required
        #     schema.record "cities_lived", mode: :repeated do |nested_schema|
        #       nested_schema.string "place", mode: :required
        #       nested_schema.integer "number_of_years", mode: :required
        #     end
        #   end
        #
        # @example Pass a google-cloud-storage `File` instance:
        #   require "google/cloud/bigquery"
        #   require "google/cloud/storage"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   storage = Google::Cloud::Storage.new
        #   bucket = storage.bucket "my-bucket"
        #   file = bucket.file "file-name.csv"
        #   dataset.load "my_new_table", file do |schema|
        #     schema.string "first_name", mode: :required
        #     schema.record "cities_lived", mode: :repeated do |nested_schema|
        #       nested_schema.string "place", mode: :required
        #       nested_schema.integer "number_of_years", mode: :required
        #     end
        #   end
        #
        # @example Pass a list of google-cloud-storage files:
        #   require "google/cloud/bigquery"
        #   require "google/cloud/storage"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   storage = Google::Cloud::Storage.new
        #   bucket = storage.bucket "my-bucket"
        #   file = bucket.file "file-name.csv"
        #   list = [file, "gs://my-bucket/file-name2.csv"]
        #   dataset.load "my_new_table", list do |schema|
        #     schema.string "first_name", mode: :required
        #     schema.record "cities_lived", mode: :repeated do |nested_schema|
        #       nested_schema.string "place", mode: :required
        #       nested_schema.integer "number_of_years", mode: :required
        #     end
        #   end
        #
        # @example Upload a file directly:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   file = File.open "my_data.csv"
        #   dataset.load "my_new_table", file do |schema|
        #     schema.string "first_name", mode: :required
        #     schema.record "cities_lived", mode: :repeated do |nested_schema|
        #       nested_schema.string "place", mode: :required
        #       nested_schema.integer "number_of_years", mode: :required
        #     end
        #   end
        #
        # @example Schema is not required with a Cloud Datastore backup:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   dataset.load "my_new_table",
        #                "gs://my-bucket/xxxx.kind_name.backup_info" do |j|
        #     j.format = "datastore_backup"
        #   end
        #
        # @!group Data
        #
        def load table_id, files, format: nil, create: nil, write: nil, projection_fields: nil, jagged_rows: nil,
                 quoted_newlines: nil, encoding: nil, delimiter: nil, ignore_unknown: nil, max_bad_records: nil,
                 quote: nil, skip_leading: nil, schema: nil, autodetect: nil, null_marker: nil, &block
          job = load_job table_id, files,
                         format: format, create: create, write: write, projection_fields: projection_fields,
                         jagged_rows: jagged_rows, quoted_newlines: quoted_newlines, encoding: encoding,
                         delimiter: delimiter, ignore_unknown: ignore_unknown, max_bad_records: max_bad_records,
                         quote: quote, skip_leading: skip_leading, schema: schema, autodetect: autodetect,
                         null_marker: null_marker, &block

          job.wait_until_done!
          ensure_job_succeeded! job
          true
        end

        ##
        # Reloads the dataset with current data from the BigQuery service.
        #
        # @return [Google::Cloud::Bigquery::Dataset] Returns the reloaded
        #   dataset.
        #
        # @example Skip retrieving the dataset from the service, then load it:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset", skip_lookup: true
        #   dataset.reload!
        #
        def reload!
          ensure_service!
          @gapi = service.get_dataset dataset_id
          @reference = nil
          @exists = nil
          self
        end
        alias refresh! reload!

        ##
        # Determines whether the dataset exists in the BigQuery service. The
        # result is cached locally. To refresh state, set `force` to `true`.
        #
        # @param [Boolean] force Force the latest resource representation to be
        #   retrieved from the BigQuery service when `true`. Otherwise the
        #   return value of this method will be memoized to reduce the number of
        #   API calls made to the BigQuery service. The default is `false`.
        #
        # @return [Boolean] `true` when the dataset exists in the BigQuery
        #   service, `false` otherwise.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset", skip_lookup: true
        #   dataset.exists? # true
        #
        def exists? force: false
          return gapi_exists? if force
          # If we have a memoized value, return it
          return @exists unless @exists.nil?
          # Always true if we have a gapi object
          return true if resource?
          gapi_exists?
        end

        ##
        # Whether the dataset was created without retrieving the resource
        # representation from the BigQuery service.
        #
        # @return [Boolean] `true` when the dataset is just a local reference
        #   object, `false` otherwise.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset", skip_lookup: true
        #
        #   dataset.reference? # true
        #   dataset.reload!
        #   dataset.reference? # false
        #
        def reference?
          @gapi.nil?
        end

        ##
        # Whether the dataset was created with a resource representation from
        # the BigQuery service.
        #
        # @return [Boolean] `true` when the dataset was created with a resource
        #   representation, `false` otherwise.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset", skip_lookup: true
        #
        #   dataset.resource? # false
        #   dataset.reload!
        #   dataset.resource? # true
        #
        def resource?
          !@gapi.nil?
        end

        ##
        # Whether the dataset was created with a partial resource representation
        # from the BigQuery service by retrieval through {Project#datasets}.
        # See [Datasets: list
        # response](https://cloud.google.com/bigquery/docs/reference/rest/v2/datasets/list#response)
        # for the contents of the partial representation. Accessing any
        # attribute outside of the partial representation will result in loading
        # the full representation.
        #
        # @return [Boolean] `true` when the dataset was created with a partial
        #   resource representation, `false` otherwise.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.datasets.first
        #
        #   dataset.resource_partial? # true
        #   dataset.description # Loads the full resource.
        #   dataset.resource_partial? # false
        #
        def resource_partial?
          @gapi.is_a? Google::Apis::BigqueryV2::DatasetList::Dataset
        end

        ##
        # Whether the dataset was created with a full resource representation
        # from the BigQuery service.
        #
        # @return [Boolean] `true` when the dataset was created with a full
        #   resource representation, `false` otherwise.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   dataset.resource_full? # true
        #
        def resource_full?
          @gapi.is_a? Google::Apis::BigqueryV2::Dataset
        end

        ##
        # @private New Dataset from a Google API Client object.
        def self.from_gapi gapi, conn
          new.tap do |f|
            f.gapi = gapi
            f.service = conn
          end
        end

        ##
        # @private New lazy Dataset object without making an HTTP request, for use with the skip_lookup option.
        def self.new_reference project_id, dataset_id, service
          raise ArgumentError, "dataset_id is required" unless dataset_id
          new.tap do |b|
            reference_gapi = Google::Apis::BigqueryV2::DatasetReference.new \
              project_id: project_id, dataset_id: dataset_id
            b.service = service
            b.instance_variable_set :@reference, reference_gapi
          end
        end

        ##
        # Inserts data into the given table for near-immediate querying, without
        # the need to complete a load operation before the data can appear in
        # query results.
        #
        # Simple Ruby types are generally accepted per JSON rules, along with the following support for BigQuery's more
        # complex types:
        #
        # | BigQuery     | Ruby                                 | Notes                                              |
        # |--------------|--------------------------------------|----------------------------------------------------|
        # | `NUMERIC`    | `BigDecimal`                         | `BigDecimal` values will be rounded to scale 9.    |
        # | `BIGNUMERIC` | `String`                             | Pass as `String` to avoid rounding to scale 9.     |
        # | `DATETIME`   | `DateTime`                           | `DATETIME` does not support time zone.             |
        # | `DATE`       | `Date`                               |                                                    |
        # | `GEOGRAPHY`  | `String`                             |                                                    |
        # | `TIMESTAMP`  | `Time`                               |                                                    |
        # | `TIME`       | `Google::Cloud::BigQuery::Time`      |                                                    |
        # | `BYTES`      | `File`, `IO`, `StringIO`, or similar |                                                    |
        # | `ARRAY`      | `Array`                              | Nested arrays, `nil` values are not supported.     |
        # | `STRUCT`     | `Hash`                               | Hash keys may be strings or symbols.               |
        #
        # Because BigQuery's streaming API is designed for high insertion rates,
        # modifications to the underlying table metadata are eventually
        # consistent when interacting with the streaming system. In most cases
        # metadata changes are propagated within minutes, but during this period
        # API responses may reflect the inconsistent state of the table.
        #
        # @see https://cloud.google.com/bigquery/streaming-data-into-bigquery
        #   Streaming Data Into BigQuery
        #
        # @see https://cloud.google.com/bigquery/troubleshooting-errors#metadata-errors-for-streaming-inserts
        #   BigQuery Troubleshooting: Metadata errors for streaming inserts
        #
        # @param [String] table_id The ID of the destination table.
        # @param [Hash, Array<Hash>] rows A hash object or array of hash objects
        #   containing the data. Required. `BigDecimal` values will be rounded to
        #   scale 9 to conform with the BigQuery `NUMERIC` data type. To avoid
        #   rounding `BIGNUMERIC` type values with scale greater than 9, use `String`
        #   instead of `BigDecimal`.
        # @param [Array<String|Symbol>, Symbol] insert_ids A unique ID for each row. BigQuery uses this property to
        #   detect duplicate insertion requests on a best-effort basis. For more information, see [data
        #   consistency](https://cloud.google.com/bigquery/streaming-data-into-bigquery#dataconsistency). Optional. If
        #   not provided, the client library will assign a UUID to each row before the request is sent.
        #
        #  The value `:skip` can be provided to skip the generation of IDs for all rows, or to skip the generation of an
        #  ID for a specific row in the array.
        # @param [Boolean] skip_invalid Insert all valid rows of a request, even
        #   if invalid rows exist. The default value is `false`, which causes
        #   the entire request to fail if any invalid rows exist.
        # @param [Boolean] ignore_unknown Accept rows that contain values that
        #   do not match the schema. The unknown values are ignored. Default is
        #   false, which treats unknown values as errors.
        # @param [Boolean] autocreate Specifies whether the method should create
        #   a new table with the given `table_id`, if no table is found for
        #   `table_id`. The default value is false.
        #
        # @yield [table] a block for setting the table
        # @yieldparam [Google::Cloud::Bigquery::Table::Updater] table An updater
        #   to set additional properties on the table in the API request to
        #   create it. Only used when `autocreate` is set and the table does not
        #   already exist.
        #
        # @return [Google::Cloud::Bigquery::InsertResponse] An insert response
        #   object.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   rows = [
        #     { "first_name" => "Alice", "age" => 21 },
        #     { "first_name" => "Bob", "age" => 22 }
        #   ]
        #   dataset.insert "my_table", rows
        #
        # @example Avoid retrieving the dataset with `skip_lookup`:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset", skip_lookup: true
        #
        #   rows = [
        #     { "first_name" => "Alice", "age" => 21 },
        #     { "first_name" => "Bob", "age" => 22 }
        #   ]
        #   dataset.insert "my_table", rows
        #
        # @example Using `autocreate` to create a new table if none exists.
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   rows = [
        #     { "first_name" => "Alice", "age" => 21 },
        #     { "first_name" => "Bob", "age" => 22 }
        #   ]
        #   dataset.insert "my_table", rows, autocreate: true do |t|
        #     t.schema.string "first_name", mode: :required
        #     t.schema.integer "age", mode: :required
        #   end
        #
        # @example Pass `BIGNUMERIC` value as a string to avoid rounding to scale 9 in the conversion from `BigDecimal`:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #
        #   row = {
        #     "my_numeric" => BigDecimal("123456798.987654321"),
        #     "my_bignumeric" => "123456798.98765432100001" # BigDecimal would be rounded, use String instead!
        #   }
        #   dataset.insert "my_table", row
        #
        # @!group Data
        #
        def insert table_id, rows, insert_ids: nil, skip_invalid: nil, ignore_unknown: nil, autocreate: nil, &block
          rows = [rows] if rows.is_a? Hash
          raise ArgumentError, "No rows provided" if rows.empty?

          insert_ids = Array.new(rows.count) { :skip } if insert_ids == :skip
          insert_ids = Array insert_ids
          if insert_ids.count.positive? && insert_ids.count != rows.count
            raise ArgumentError, "insert_ids must be the same size as rows"
          end

          if autocreate
            insert_data_with_autocreate table_id, rows, skip_invalid: skip_invalid, ignore_unknown: ignore_unknown,
                                                        insert_ids: insert_ids, &block
          else
            insert_data table_id, rows, skip_invalid: skip_invalid, ignore_unknown: ignore_unknown,
                                        insert_ids: insert_ids
          end
        end

        ##
        # Create an asynchronous inserter object used to insert rows in batches.
        #
        # @param [String] table_id The ID of the table to insert rows into.
        # @param [Boolean] skip_invalid Insert all valid rows of a request, even
        #   if invalid rows exist. The default value is `false`, which causes
        #   the entire request to fail if any invalid rows exist.
        # @param [Boolean] ignore_unknown Accept rows that contain values that
        #   do not match the schema. The unknown values are ignored. Default is
        #   false, which treats unknown values as errors.
        # @attr_reader [Integer] max_bytes The maximum size of rows to be
        #   collected before the batch is published. Default is 10,000,000
        #   (10MB).
        # @param [Integer] max_rows The maximum number of rows to be collected
        #   before the batch is published. Default is 500.
        # @attr_reader [Numeric] interval The number of seconds to collect
        #   messages before the batch is published. Default is 10.
        # @attr_reader [Numeric] threads The number of threads used to insert
        #   batches of rows. Default is 4.
        # @yield [response] the callback for when a batch of rows is inserted
        # @yieldparam [Table::AsyncInserter::Result] result the result of the
        #   asynchronous insert
        #
        # @return [Table::AsyncInserter] Returns an inserter object.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   inserter = dataset.insert_async "my_table" do |result|
        #     if result.error?
        #       log_error result.error
        #     else
        #       log_insert "inserted #{result.insert_count} rows " \
        #         "with #{result.error_count} errors"
        #     end
        #   end
        #
        #   rows = [
        #     { "first_name" => "Alice", "age" => 21 },
        #     { "first_name" => "Bob", "age" => 22 }
        #   ]
        #   inserter.insert rows
        #
        #   inserter.stop.wait!
        #
        def insert_async table_id, skip_invalid: nil, ignore_unknown: nil, max_bytes: 10_000_000, max_rows: 500,
                         interval: 10, threads: 4, &block
          ensure_service!

          # Get table, don't use Dataset#table which handles NotFoundError
          gapi = service.get_table dataset_id, table_id
          table = Table.from_gapi gapi, service
          # Get the AsyncInserter from the table
          table.insert_async skip_invalid: skip_invalid,
                             ignore_unknown: ignore_unknown,
                             max_bytes: max_bytes, max_rows: max_rows,
                             interval: interval, threads: threads, &block
        end

        protected

        def insert_data_with_autocreate table_id, rows, skip_invalid: nil, ignore_unknown: nil, insert_ids: nil
          insert_data table_id, rows, skip_invalid: skip_invalid, ignore_unknown: ignore_unknown, insert_ids: insert_ids
        rescue Google::Cloud::NotFoundError
          sleep rand(1..60)
          begin
            create_table table_id do |tbl_updater|
              yield tbl_updater if block_given?
            end
          rescue Google::Cloud::AlreadyExistsError
            # Do nothing if it already exists
          end
          sleep 60
          retry
        end

        def insert_data table_id, rows, skip_invalid: nil, ignore_unknown: nil, insert_ids: nil
          rows = [rows] if rows.is_a? Hash
          raise ArgumentError, "No rows provided" if rows.empty?
          ensure_service!
          gapi = service.insert_tabledata dataset_id, table_id, rows, skip_invalid:   skip_invalid,
                                                                      ignore_unknown: ignore_unknown,
                                                                      insert_ids:     insert_ids
          InsertResponse.from_gapi rows, gapi
        end

        ##
        # Raise an error unless an active service is available.
        def ensure_service!
          raise "Must have active connection" unless service
        end

        ##
        # Ensures the Google::Apis::BigqueryV2::Dataset object has been loaded
        # from the service.
        def ensure_gapi!
          ensure_service!
          return unless reference?
          reload!
        end

        ##
        # Fetch gapi and memoize whether resource exists.
        def gapi_exists?
          reload!
          @exists = true
        rescue Google::Cloud::NotFoundError
          @exists = false
        end

        def patch_gapi! *attributes
          return if attributes.empty?
          ensure_service!
          patch_args = Hash[attributes.map { |attr| [attr, @gapi.send(attr)] }]
          patch_gapi = Google::Apis::BigqueryV2::Dataset.new(**patch_args)
          patch_gapi.etag = etag if etag
          @gapi = service.patch_dataset dataset_id, patch_gapi
        end

        ##
        # Load the complete representation of the dataset if it has been
        # only partially loaded by a request to the API list method.
        def ensure_full_data!
          reload! unless resource_full?
        end

        def ensure_job_succeeded! job
          return unless job.failed?
          begin
            # raise to activate ruby exception cause handling
            raise job.gapi_error
          rescue StandardError => e
            # wrap Google::Apis::Error with Google::Cloud::Error
            raise Google::Cloud::Error.from_error(e)
          end
        end

        def load_job_gapi table_id, dryrun, job_id: nil, prefix: nil
          job_ref = service.job_ref_from job_id, prefix
          Google::Apis::BigqueryV2::Job.new(
            job_reference: job_ref,
            configuration: Google::Apis::BigqueryV2::JobConfiguration.new(
              load:    Google::Apis::BigqueryV2::JobConfigurationLoad.new(
                destination_table: Google::Apis::BigqueryV2::TableReference.new(
                  project_id: @service.project,
                  dataset_id: dataset_id,
                  table_id:   table_id
                )
              ),
              dry_run: dryrun
            )
          )
        end

        def load_job_csv_options! job, jagged_rows: nil, quoted_newlines: nil, delimiter: nil, quote: nil,
                                  skip_leading: nil, null_marker: nil
          job.jagged_rows = jagged_rows unless jagged_rows.nil?
          job.quoted_newlines = quoted_newlines unless quoted_newlines.nil?
          job.delimiter = delimiter unless delimiter.nil?
          job.null_marker = null_marker unless null_marker.nil?
          job.quote = quote unless quote.nil?
          job.skip_leading = skip_leading unless skip_leading.nil?
        end

        def load_job_file_options! job, format: nil, projection_fields: nil, jagged_rows: nil, quoted_newlines: nil,
                                   encoding: nil, delimiter: nil, ignore_unknown: nil, max_bad_records: nil, quote: nil,
                                   skip_leading: nil, null_marker: nil
          job.format = format unless format.nil?
          job.projection_fields = projection_fields unless projection_fields.nil?
          job.encoding = encoding unless encoding.nil?
          job.ignore_unknown = ignore_unknown unless ignore_unknown.nil?
          job.max_bad_records = max_bad_records unless max_bad_records.nil?
          load_job_csv_options! job, jagged_rows:     jagged_rows,
                                     quoted_newlines: quoted_newlines,
                                     delimiter:       delimiter,
                                     quote:           quote,
                                     skip_leading:    skip_leading,
                                     null_marker:     null_marker
        end

        def load_job_updater table_id, format: nil, create: nil, write: nil, projection_fields: nil, jagged_rows: nil,
                             quoted_newlines: nil, encoding: nil, delimiter: nil, ignore_unknown: nil,
                             max_bad_records: nil, quote: nil, skip_leading: nil, dryrun: nil, schema: nil, job_id: nil,
                             prefix: nil, labels: nil, autodetect: nil, null_marker: nil
          new_job = load_job_gapi table_id, dryrun, job_id: job_id, prefix: prefix
          LoadJob::Updater.new(new_job).tap do |job|
            job.location = location if location # may be dataset reference
            job.create = create unless create.nil?
            job.write = write unless write.nil?
            job.schema = schema unless schema.nil?
            job.autodetect = autodetect unless autodetect.nil?
            job.labels = labels unless labels.nil?
            load_job_file_options! job, format:            format,
                                        projection_fields: projection_fields,
                                        jagged_rows:       jagged_rows,
                                        quoted_newlines:   quoted_newlines,
                                        encoding:          encoding,
                                        delimiter:         delimiter,
                                        ignore_unknown:    ignore_unknown,
                                        max_bad_records:   max_bad_records,
                                        quote:             quote,
                                        skip_leading:      skip_leading,
                                        null_marker:       null_marker
          end
        end

        def load_storage urls, job_gapi
          # Convert to storage URL
          urls = [urls].flatten.map do |url|
            if url.respond_to? :to_gs_url
              url.to_gs_url
            elsif url.is_a? URI
              url.to_s
            else
              url
            end
          end

          unless urls.nil?
            job_gapi.configuration.load.update! source_uris: urls
            if job_gapi.configuration.load.source_format.nil?
              source_format = Convert.derive_source_format_from_list urls
              job_gapi.configuration.load.source_format = source_format unless source_format.nil?
            end
          end

          gapi = service.load_table_gs_url job_gapi
          Job.from_gapi gapi, service
        end

        def load_local file, job_gapi
          path = Pathname(file).to_path
          if job_gapi.configuration.load.source_format.nil?
            source_format = Convert.derive_source_format path
            job_gapi.configuration.load.source_format = source_format unless source_format.nil?
          end

          gapi = service.load_table_file file, job_gapi
          Job.from_gapi gapi, service
        end

        def load_local_or_uri file, updater
          job_gapi = updater.to_gapi
          if local_file? file
            load_local file, job_gapi
          else
            load_storage file, job_gapi
          end
        end

        def storage_url? files
          [files].flatten.all? do |file|
            file.respond_to?(:to_gs_url) ||
              (file.respond_to?(:to_str) && file.to_str.downcase.start_with?("gs://")) ||
              (file.is_a?(URI) && file.to_s.downcase.start_with?("gs://"))
          end
        end

        def local_file? file
          ::File.file? file
        rescue StandardError
          false
        end

        def udfs_gapi array_or_str
          return [] if array_or_str.nil?
          Array(array_or_str).map do |uri_or_code|
            resource = Google::Apis::BigqueryV2::UserDefinedFunctionResource.new
            if uri_or_code.start_with? "gs://"
              resource.resource_uri = uri_or_code
            else
              resource.inline_code = uri_or_code
            end
            resource
          end
        end

        ##
        # Yielded to a block to accumulate changes for a create request. See {Project#create_dataset}.
        class Updater < Dataset
          ##
          # @private A list of attributes that were updated.
          attr_reader :updates

          ##
          # @private Create an Updater object.
          def initialize gapi
            super()
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

          # rubocop:disable Style/MethodDefParentheses

          ##
          # @raise [RuntimeError] not implemented
          def delete(*)
            raise "not implemented in #{self.class}"
          end

          ##
          # @raise [RuntimeError] not implemented
          def create_table(*)
            raise "not implemented in #{self.class}"
          end

          ##
          # @raise [RuntimeError] not implemented
          def create_view(*)
            raise "not implemented in #{self.class}"
          end

          ##
          # @raise [RuntimeError] not implemented
          def create_materialized_view(*)
            raise "not implemented in #{self.class}"
          end

          ##
          # @raise [RuntimeError] not implemented
          def table(*)
            raise "not implemented in #{self.class}"
          end

          ##
          # @raise [RuntimeError] not implemented
          def tables(*)
            raise "not implemented in #{self.class}"
          end

          ##
          # @raise [RuntimeError] not implemented
          def model(*)
            raise "not implemented in #{self.class}"
          end

          ##
          # @raise [RuntimeError] not implemented
          def models(*)
            raise "not implemented in #{self.class}"
          end

          ##
          # @raise [RuntimeError] not implemented
          def create_routine(*)
            raise "not implemented in #{self.class}"
          end

          ##
          # @raise [RuntimeError] not implemented
          def routine(*)
            raise "not implemented in #{self.class}"
          end

          ##
          # @raise [RuntimeError] not implemented
          def routines(*)
            raise "not implemented in #{self.class}"
          end

          ##
          # @raise [RuntimeError] not implemented
          def query_job(*)
            raise "not implemented in #{self.class}"
          end

          ##
          # @raise [RuntimeError] not implemented
          def query(*)
            raise "not implemented in #{self.class}"
          end

          ##
          # @raise [RuntimeError] not implemented
          def external(*)
            raise "not implemented in #{self.class}"
          end

          ##
          # @raise [RuntimeError] not implemented
          def load_job(*)
            raise "not implemented in #{self.class}"
          end

          ##
          # @raise [RuntimeError] not implemented
          def load(*)
            raise "not implemented in #{self.class}"
          end

          ##
          # @raise [RuntimeError] not implemented
          def reload!
            raise "not implemented in #{self.class}"
          end
          alias refresh! reload!

          # rubocop:enable Style/MethodDefParentheses

          ##
          # @private Make sure any access changes are saved
          def check_for_mutated_access!
            return if @access.nil?
            return unless @access.changed?
            @gapi.update! access: @access.to_gapi
            patch_gapi! :access
          end

          ##
          # @private
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
