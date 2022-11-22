# Copyright 2020 Google LLC
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


# require "google/cloud/errors"
require "google/cloud/bigquery/convert"
require "google/cloud/bigquery/service"
require "google/cloud/bigquery/routine/list"
require "google/cloud/bigquery/argument"

module Google
  module Cloud
    module Bigquery
      ##
      # # Routine
      #
      # A user-defined function or a stored procedure.
      #
      # @example Creating a new routine:
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
      # @example Retrieving and updating an existing routine:
      #   require "google/cloud/bigquery"
      #
      #   bigquery = Google::Cloud::Bigquery.new
      #   dataset = bigquery.dataset "my_dataset"
      #   routine = dataset.routine "my_routine"
      #
      #   routine.update do |r|
      #     r.body = "x * 4"
      #     r.description = "My new routine description"
      #   end
      #
      class Routine
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private The Google API Client object.
        attr_accessor :gapi

        ##
        # @private A Google API Client Dataset Reference object.
        attr_reader :reference

        ##
        # @private Creates an empty Routine object.
        def initialize
          @service = nil
          @gapi = nil
          @reference = nil
        end

        ##
        # A unique ID for this routine, without the project name.
        #
        # @return [String] The ID must contain only letters (`[A-Za-z]`), numbers (`[0-9]`), or underscores (`_`). The
        #   maximum length is 256 characters.
        #
        # @!group Attributes
        #
        def routine_id
          return reference.routine_id if reference?
          @gapi.routine_reference.routine_id
        end

        ##
        # The ID of the dataset containing this routine.
        #
        # @return [String] The dataset ID.
        #
        # @!group Attributes
        #
        def dataset_id
          return reference.dataset_id if reference?
          @gapi.routine_reference.dataset_id
        end

        ##
        # The ID of the project containing this routine.
        #
        # @return [String] The project ID.
        #
        # @!group Attributes
        #
        def project_id
          return reference.project_id if reference?
          @gapi.routine_reference.project_id
        end

        ##
        # @private The gapi fragment containing the Project ID, Dataset ID, and Routine ID.
        #
        # @return [Google::Apis::BigqueryV2::RoutineReference]
        #
        def routine_ref
          reference? ? reference : @gapi.routine_reference
        end

        ##
        # The ETag hash of the routine.
        #
        # @return [String, nil] The ETag hash, or `nil` if the object is a reference (see {#reference?}).
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine"
        #
        #   routine.etag # "etag123456789"
        #
        # @!group Attributes
        #
        def etag
          return nil if reference?
          @gapi.etag
        end

        ##
        # The type of routine. Required.
        #
        # * `SCALAR_FUNCTION` - Non-builtin permanent scalar function.
        # * `PROCEDURE` - Stored procedure.
        #
        # @return [String, nil] The type of routine in upper case, or `nil` if the object is a reference (see
        #   {#reference?}).
        #
        # @!group Attributes
        #
        def routine_type
          return nil if reference?
          @gapi.routine_type
        end

        ##
        # Updates the type of routine. Required.
        #
        # * `SCALAR_FUNCTION` - Non-builtin permanent scalar function.
        # * `PROCEDURE` - Stored procedure.
        #
        # @param [String] new_routine_type The new type of the routine in upper case.
        #
        # @!group Attributes
        #
        def routine_type= new_routine_type
          ensure_full_data!
          @gapi.routine_type = new_routine_type
          update_gapi!
        end

        ##
        # Checks if the value of {#routine_type} is `PROCEDURE`. The default is `false`.
        #
        # @return [Boolean] `true` when `PROCEDURE` and the object is not a reference (see {#reference?}), `false`
        #   otherwise.
        #
        # @!group Attributes
        #
        def procedure?
          @gapi.routine_type == "PROCEDURE"
        end

        ##
        # Checks if the value of {#routine_type} is `SCALAR_FUNCTION`. The default is `true`.
        #
        # @return [Boolean] `true` when `SCALAR_FUNCTION` and the object is not a reference (see {#reference?}), `false`
        #   otherwise.
        #
        # @!group Attributes
        #
        def scalar_function?
          @gapi.routine_type == "SCALAR_FUNCTION"
        end

        ##
        # The time when this routine was created.
        #
        # @return [Time, nil] The creation time, or `nil` if the object is a reference (see {#reference?}).
        #
        # @!group Attributes
        #
        def created_at
          return nil if reference?
          Convert.millis_to_time @gapi.creation_time
        end

        ##
        # The time when this routine was last modified.
        #
        # @return [Time, nil] The last modified time, or `nil` if the object is a reference (see {#reference?}).
        #
        # @!group Attributes
        #
        def modified_at
          return nil if reference?
          Convert.millis_to_time @gapi.last_modified_time
        end

        ##
        # The programming language of routine. Optional. Defaults to "SQL".
        #
        # * `SQL` - SQL language.
        # * `JAVASCRIPT` - JavaScript language.
        #
        # @return [String, nil] The language in upper case, or `nil` if the object is a reference (see {#reference?}).
        #
        # @!group Attributes
        #
        def language
          return nil if reference?
          @gapi.language
        end

        ##
        # Updates the programming language of routine. Optional. Defaults to "SQL".
        #
        # * `SQL` - SQL language.
        # * `JAVASCRIPT` - JavaScript language.
        #
        # @param [String] new_language The new language in upper case.
        #
        # @!group Attributes
        #
        def language= new_language
          ensure_full_data!
          @gapi.language = new_language
          update_gapi!
        end

        ##
        # Checks if the value of {#language} is `JAVASCRIPT`. The default is `false`.
        #
        # @return [Boolean] `true` when `JAVASCRIPT` and the object is not a reference (see {#reference?}), `false`
        #   otherwise.
        #
        # @!group Attributes
        #
        def javascript?
          @gapi.language == "JAVASCRIPT"
        end

        ##
        # Checks if the value of {#language} is `SQL`. The default is `true`.
        #
        # @return [Boolean] `true` when `SQL` and the object is not a reference (see {#reference?}), `false`
        #   otherwise.
        #
        # @!group Attributes
        #
        def sql?
          return true if @gapi.language.nil?
          @gapi.language == "SQL"
        end

        ##
        # The input/output arguments of the routine. Optional.
        #
        # @return [Array<Argument>, nil] An array of argument objects, or `nil` if the object is a reference (see
        #   {#reference?}).
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine"
        #
        #   puts "#{routine.routine_id} arguments:"
        #   routine.arguments.each do |arguments|
        #     puts "* #{arguments.name}"
        #   end
        #
        # @!group Attributes
        #
        def arguments
          return nil if reference?
          ensure_full_data!
          # always return frozen arguments
          Array(@gapi.arguments).map { |a| Argument.from_gapi a }.freeze
        end

        ##
        # Updates the input/output arguments of the routine. Optional.
        #
        # @param [Array<Argument>] new_arguments The new arguments.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine"
        #
        #   routine.arguments = [
        #     Google::Cloud::Bigquery::Argument.new(name: "x", data_type: "INT64")
        #   ]
        #
        # @!group Attributes
        #
        def arguments= new_arguments
          ensure_full_data!
          @gapi.update! arguments: new_arguments.map(&:to_gapi)
          update_gapi!
        end

        ##
        # The return type of the routine. Optional if the routine is a SQL function ({#sql?}); required otherwise.
        #
        # If absent, the return type is inferred from {#body} at query time in each query that references this routine.
        # If present, then the evaluated result will be cast to the specified returned type at query time.
        #
        # For example, for the functions created with the following statements:
        #
        # * `CREATE FUNCTION Add(x FLOAT64, y FLOAT64) RETURNS FLOAT64 AS (x + y);`
        # * `CREATE FUNCTION Increment(x FLOAT64) AS (Add(x, 1));`
        # * `CREATE FUNCTION Decrement(x FLOAT64) RETURNS FLOAT64 AS (Add(x, -1));`
        #
        # The returnType is `{typeKind: "FLOAT64"}` for Add and Decrement, and is absent for Increment (inferred as
        # `FLOAT64` at query time).
        #
        # Suppose the function Add is replaced by `CREATE OR REPLACE FUNCTION Add(x INT64, y INT64) AS (x + y);`
        #
        # Then the inferred return type of Increment is automatically changed to `INT64` at query time, while the return
        # type of Decrement remains `FLOAT64`.
        #
        # @return [Google::Cloud::Bigquery::StandardSql::DataType, nil] The return type in upper case, or `nil` if the
        #   object is a reference (see {#reference?}).
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine"
        #
        #   routine.return_type.type_kind #=> "INT64"
        #
        # @!group Attributes
        #
        def return_type
          return nil if reference?
          ensure_full_data!
          return nil unless @gapi.return_type
          StandardSql::DataType.from_gapi @gapi.return_type
        end

        ##
        # Updates the return type of the routine. Optional if the routine is a SQL function ({#sql?}); required
        # otherwise.
        #
        # If absent, the return type is inferred from {#body} at query time in each query that references this routine.
        # If present, then the evaluated result will be cast to the specified returned type at query time.
        #
        # For example, for the functions created with the following statements:
        #
        # * `CREATE FUNCTION Add(x FLOAT64, y FLOAT64) RETURNS FLOAT64 AS (x + y);`
        # * `CREATE FUNCTION Increment(x FLOAT64) AS (Add(x, 1));`
        # * `CREATE FUNCTION Decrement(x FLOAT64) RETURNS FLOAT64 AS (Add(x, -1));`
        #
        # The returnType is `{typeKind: "FLOAT64"}` for Add and Decrement, and is absent for Increment (inferred as
        # `FLOAT64` at query time).
        #
        # Suppose the function Add is replaced by `CREATE OR REPLACE FUNCTION Add(x INT64, y INT64) AS (x + y);`
        #
        # Then the inferred return type of Increment is automatically changed to `INT64` at query time, while the return
        # type of Decrement remains `FLOAT64`.
        #
        # @param [Google::Cloud::Bigquery::StandardSql::DataType, String] new_return_type The new return type for the
        #   routine.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine"
        #
        #   routine.return_type.type_kind #=> "INT64"
        #   routine.return_type = "STRING"
        #
        # @!group Attributes
        #
        def return_type= new_return_type
          ensure_full_data!
          @gapi.return_type = StandardSql::DataType.gapi_from_string_or_data_type new_return_type
          update_gapi!
        end

        ##
        # The list of the Google Cloud Storage URIs of imported JavaScript libraries. Optional. Only used if
        # {#language} is `JAVASCRIPT` ({#javascript?}).
        #
        # @return [Array<String>, nil] A frozen array of Google Cloud Storage URIs, e.g.
        #   `["gs://cloud-samples-data/bigquery/udfs/max-value.js"]`, or `nil` if the object is a reference (see
        #   {#reference?}).
        #
        # @!group Attributes
        #
        def imported_libraries
          return nil if reference?
          ensure_full_data!
          @gapi.imported_libraries.freeze
        end

        ##
        # Updates the list of the Google Cloud Storage URIs of imported JavaScript libraries. Optional. Only used if
        # {#language} is `JAVASCRIPT` ({#javascript?}).
        #
        # @param [Array<String>, nil] new_imported_libraries An array of Google Cloud Storage URIs, e.g.
        #   `["gs://cloud-samples-data/bigquery/udfs/max-value.js"]`.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine"
        #
        #   routine.imported_libraries = [
        #     "gs://cloud-samples-data/bigquery/udfs/max-value.js"
        #   ]
        #
        # @!group Attributes
        #
        def imported_libraries= new_imported_libraries
          ensure_full_data!
          @gapi.imported_libraries = new_imported_libraries
          update_gapi!
        end

        ##
        # The body of the routine. Required.
        #
        # For functions ({#scalar_function?}), this is the expression in the `AS` clause.
        #
        # When the routine is a SQL function ({#sql?}), it is the substring inside (but excluding) the parentheses. For
        # example, for the function created with the following statement:
        # ```
        # CREATE FUNCTION JoinLines(x string, y string) as (concat(x, "\n", y))
        # ```
        # The definition_body is `concat(x, "\n", y)` (`\n` is not replaced with linebreak).
        #
        # When the routine is a JavaScript function ({#javascript?}), it is the evaluated string in the `AS` clause. For
        # example, for the function created with the following statement:
        # ```
        # CREATE FUNCTION f() RETURNS STRING LANGUAGE js AS 'return "\n";\n'
        # ```
        # The definition_body is
        # ```
        # "return \"\n\";\n"`
        # ```
        # Note that both `\n` are replaced with linebreaks.
        #
        # @return [String, nil] The body of the routine, or `nil` if the object is a reference (see {#reference?}).
        #
        # @!group Attributes
        #
        def body
          return nil if reference?
          ensure_full_data!
          @gapi.definition_body
        end

        ##
        # Updates the body of the routine. Required.
        #
        # For functions ({#scalar_function?}), this is the expression in the `AS` clause.
        #
        # When the routine is a SQL function ({#sql?}), it is the substring inside (but excluding) the parentheses. For
        # example, for the function created with the following statement:
        # ```
        # CREATE FUNCTION JoinLines(x string, y string) as (concat(x, "\n", y))
        # ```
        # The definition_body is `concat(x, "\n", y)` (`\n` is not replaced with linebreak).
        #
        # When the routine is a JavaScript function ({#javascript?}), it is the evaluated string in the `AS` clause. For
        # example, for the function created with the following statement:
        # ```
        # CREATE FUNCTION f() RETURNS STRING LANGUAGE js AS 'return "\n";\n'
        # ```
        # The definition_body is
        # ```
        # "return \"\n\";\n"`
        # ```
        # Note that both `\n` are replaced with linebreaks.
        #
        # @param [String] new_body The new body of the routine.
        #
        # @!group Attributes
        #
        def body= new_body
          ensure_full_data!
          @gapi.definition_body = new_body
          update_gapi!
        end

        ###
        # The description of the routine if defined. Optional. [Experimental]
        #
        # @return [String, nil] The routine description, or `nil` if the object is a reference (see {#reference?}).
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine"
        #
        #   routine.description #=> "My routine description"
        #
        # @!group Attributes
        #
        def description
          return nil if reference?
          ensure_full_data!
          @gapi.description
        end

        ##
        # Updates the description of the routine. Optional. [Experimental]
        #
        # @param [String] new_description The new routine description.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine"
        #
        #   routine.description #=> "My routine description"
        #   routine.description = "My updated routine description"
        #
        # @!group Attributes
        #
        def description= new_description
          ensure_full_data!
          @gapi.description = new_description
          update_gapi!
        end

        ###
        # The JavaScript UDF determinism level. Optional.
        #
        # * `DETERMINISTIC` - Deterministic indicates that two calls with the same input to a UDF yield the same output.
        #   If all JavaScript UDFs are `DETERMINISTIC`, the query result is potentially cachable.
        # * `NOT_DETERMINISTIC` - Not deterministic indicates that the output of the UDF is not guaranteed to yield the
        #   same output each time for a given set of inputs. If any JavaScript UDF is `NOT_DETERMINISTIC`, the query
        #   result is not cacheable.
        #
        # Even if a JavaScript UDF is deterministic, many other factors can prevent usage of cached query results.
        # Example factors include but not limited to: DDL/DML, non-deterministic SQL function calls, update of
        # referenced tables/views/UDFs or imported JavaScript libraries. SQL UDFs cannot have determinism specified.
        # Their determinism is automatically determined.
        #
        # @return [String, nil] The routine determinism level in upper case, or `nil` if not set or the object is a
        #   reference (see {#reference?}).
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine"
        #
        #   routine.determinism_level #=> "NOT_DETERMINISTIC"
        #
        # @!group Attributes
        #
        def determinism_level
          return nil if reference?
          ensure_full_data!
          @gapi.determinism_level
        end

        ##
        # Updates the JavaScript UDF determinism level. Optional.
        #
        # * `DETERMINISTIC` - Deterministic indicates that two calls with the same input to a UDF yield the same output.
        #   If all JavaScript UDFs are `DETERMINISTIC`, the query result is potentially cachable.
        # * `NOT_DETERMINISTIC` - Not deterministic indicates that the output of the UDF is not guaranteed to yield the
        #   same output each time for a given set of inputs. If any JavaScript UDF is `NOT_DETERMINISTIC`, the query
        #   result is not cacheable.
        #
        # @param [String, nil] new_determinism_level The new routine determinism level in upper case.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine"
        #
        #   routine.determinism_level #=> "NOT_DETERMINISTIC"
        #   routine.determinism_level = "DETERMINISTIC"
        #
        # @!group Attributes
        #
        def determinism_level= new_determinism_level
          ensure_full_data!
          @gapi.determinism_level = new_determinism_level
          update_gapi!
        end

        ##
        # Checks if the value of {#determinism_level} is `DETERMINISTIC`. The default is `false`.
        #
        # @return [Boolean] `true` when `DETERMINISTIC` and the object is not a reference (see {#reference?}), `false`
        #   otherwise.
        #
        # @!group Attributes
        #
        def determinism_level_deterministic?
          @gapi.determinism_level == "DETERMINISTIC"
        end

        ##
        # Checks if the value of {#determinism_level} is `NOT_DETERMINISTIC`. The default is `false`.
        #
        # @return [Boolean] `true` when `NOT_DETERMINISTIC` and the object is not a reference (see {#reference?}),
        #   `false` otherwise.
        #
        # @!group Attributes
        #
        def determinism_level_not_deterministic?
          @gapi.determinism_level == "NOT_DETERMINISTIC"
        end

        ##
        # Updates the routine with changes made in the given block in a single update request. The following attributes
        # may be set: {Updater#routine_type=}, {Updater#language=}, {Updater#arguments=}, {Updater#return_type=},
        # {Updater#imported_libraries=}, {Updater#body=}, and {Updater#description=}.
        #
        # @yield [routine] A block for setting properties on the routine.
        # @yieldparam [Google::Cloud::Bigquery::Routine::Updater] routine An updater to set additional properties on the
        #   routine.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine"
        #
        #   routine.update do |r|
        #     r.routine_type = "SCALAR_FUNCTION"
        #     r.language = "SQL"
        #     r.arguments = [
        #       Google::Cloud::Bigquery::Argument.new(name: "x", data_type: "INT64")
        #     ]
        #     r.body = "x * 3"
        #     r.description = "My new routine description"
        #   end
        #
        # @!group Lifecycle
        #
        def update
          ensure_full_data!
          updater = Updater.new @gapi
          yield updater
          update_gapi! updater.to_gapi if updater.updates?
        end

        ##
        # Permanently deletes the routine.
        #
        # @return [Boolean] Returns `true` if the routine was deleted.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine"
        #
        #   routine.delete
        #
        # @!group Lifecycle
        #
        def delete
          ensure_service!
          service.delete_routine dataset_id, routine_id
          # Set flag for #exists?
          @exists = false
          true
        end

        ##
        # Reloads the routine with current data from the BigQuery service.
        #
        # @return [Google::Cloud::Bigquery::Routine] Returns the reloaded
        #   routine.
        #
        # @example Skip retrieving the routine from the service, then load it:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine", skip_lookup: true
        #
        #   routine.reload!
        #
        # @!group Lifecycle
        #
        def reload!
          ensure_service!
          @gapi = service.get_routine dataset_id, routine_id
          @reference = nil
          @exists = nil
          self
        end
        alias refresh! reload!

        ##
        # Determines whether the routine exists in the BigQuery service. The
        # result is cached locally. To refresh state, set `force` to `true`.
        #
        # @param [Boolean] force Force the latest resource representation to be
        #   retrieved from the BigQuery service when `true`. Otherwise the
        #   return value of this method will be memoized to reduce the number of
        #   API calls made to the BigQuery service. The default is `false`.
        #
        # @return [Boolean] `true` when the routine exists in the BigQuery
        #   service, `false` otherwise.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine", skip_lookup: true
        #   routine.exists? #=> true
        #
        def exists? force: false
          return resource_exists? if force
          # If we have a value, return it
          return @exists unless @exists.nil?
          # Always true if we have a gapi object
          return true if resource?
          resource_exists?
        end

        ##
        # Whether the routine was created without retrieving the resource
        # representation from the BigQuery service.
        #
        # @return [Boolean] `true` when the routine is just a local reference
        #   object, `false` otherwise.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine", skip_lookup: true
        #
        #   routine.reference? #=> true
        #   routine.reload!
        #   routine.reference? #=> false
        #
        def reference?
          @gapi.nil?
        end

        ##
        # Whether the routine was created with a resource representation from
        # the BigQuery service.
        #
        # @return [Boolean] `true` when the routine was created with a resource
        #   representation, `false` otherwise.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine", skip_lookup: true
        #
        #   routine.resource? #=> false
        #   routine.reload!
        #   routine.resource? #=> true
        #
        def resource?
          !@gapi.nil?
        end

        ##
        # Whether the routine was created with a partial resource representation
        # from the BigQuery service by retrieval through {Dataset#routines}.
        # See [Models: list
        # response](https://cloud.google.com/bigquery/docs/reference/rest/v2/routines/list#response)
        # for the contents of the partial representation. Accessing any
        # attribute outside of the partial representation will result in loading
        # the full representation.
        #
        # @return [Boolean] `true` when the routine was created with a partial
        #   resource representation, `false` otherwise.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routines.first
        #
        #   routine.resource_partial? #=> true
        #   routine.description # Loads the full resource.
        #   routine.resource_partial? #=> false
        #
        def resource_partial?
          resource? && !resource_full?
        end

        ##
        # Whether the routine was created with a full resource representation
        # from the BigQuery service.
        #
        # @return [Boolean] `true` when the routine was created with a full
        #   resource representation, `false` otherwise.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine"
        #
        #   routine.resource_full? #=> true
        #
        def resource_full?
          resource? && !@gapi.definition_body.nil?
        end

        ##
        # @private New Routine from a Google API Client object.
        def self.from_gapi gapi, service
          new.tap do |r|
            r.instance_variable_set :@gapi, gapi
            r.instance_variable_set :@service, service
          end
        end

        ##
        # @private New lazy Routine object without making an HTTP request, for use with the skip_lookup option.
        def self.new_reference project_id, dataset_id, routine_id, service
          raise ArgumentError, "project_id is required" unless project_id
          raise ArgumentError, "dataset_id is required" unless dataset_id
          raise ArgumentError, "routine_id is required" unless routine_id
          raise ArgumentError, "service is required" unless service

          gapi = Google::Apis::BigqueryV2::RoutineReference.new(
            project_id: project_id,
            dataset_id: dataset_id,
            routine_id: routine_id
          )
          new.tap do |r|
            r.service = service
            r.instance_variable_set :@reference, gapi
          end
        end

        ##
        # @private New lazy Routine object from a Google API Client object.
        def self.new_reference_from_gapi gapi, service
          new.tap do |b|
            b.service = service
            b.instance_variable_set :@reference, gapi
          end
        end

        protected

        ##
        # Raise an error unless an active service is available.
        def ensure_service!
          raise "Must have active connection" unless service
        end

        ##
        # Fetch gapi and memoize whether resource exists.
        def resource_exists?
          reload!
          @exists = true
        rescue Google::Cloud::NotFoundError
          @exists = false
        end

        ##
        # Load the complete representation of the routine if it has been
        # only partially loaded by a request to the API list method.
        def ensure_full_data!
          reload! unless resource_full?
        end

        def update_gapi! update_gapi = nil
          update_gapi ||= @gapi
          ensure_service!
          @gapi = service.update_routine dataset_id, routine_id, update_gapi
          self
        end

        ##
        # Yielded to a block to accumulate changes. See {Dataset#create_routine} and {Routine#update}.
        #
        # @example Creating a new routine:
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
        # @example Updating an existing routine:
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine"
        #
        #   routine.update do |r|
        #     r.body = "x * 4"
        #     r.description = "My new routine description"
        #   end
        #
        class Updater < Routine
          ##
          # @private Create an Updater object.
          def initialize gapi
            super()
            @original_gapi = gapi
            @gapi = gapi.dup
          end

          ##
          # Updates the type of routine. Required.
          #
          # * `SCALAR_FUNCTION` - Non-builtin permanent scalar function.
          # * `PROCEDURE` - Stored procedure.
          #
          # @param [String] new_routine_type The new type of the routine.
          #
          def routine_type= new_routine_type
            @gapi.routine_type = new_routine_type
          end

          ##
          # Updates the programming language of routine. Optional. Defaults to "SQL".
          #
          # * `SQL` - SQL language.
          # * `JAVASCRIPT` - JavaScript language.
          #
          # @param [String] new_language The new language in upper case.
          #
          def language= new_language
            @gapi.language = new_language
          end

          ##
          # Updates the input/output arguments of the routine. Optional.
          #
          # @param [Array<Argument>] new_arguments The new arguments.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   routine = dataset.routine "my_routine"
          #
          #   routine.arguments = [
          #     Google::Cloud::Bigquery::Argument.new(name: "x", data_type: "INT64")
          #   ]
          #
          def arguments= new_arguments
            @gapi.arguments = new_arguments.map(&:to_gapi)
          end

          ##
          # Updates the return type of the routine. Optional if the routine is a SQL function ({#sql?}); required
          # otherwise.
          #
          # If absent, the return type is inferred from {#body} at query time in each query that references this
          # routine. If present, then the evaluated result will be cast to the specified returned type at query time.
          #
          # For example, for the functions created with the following statements:
          #
          # * `CREATE FUNCTION Add(x FLOAT64, y FLOAT64) RETURNS FLOAT64 AS (x + y);`
          # * `CREATE FUNCTION Increment(x FLOAT64) AS (Add(x, 1));`
          # * `CREATE FUNCTION Decrement(x FLOAT64) RETURNS FLOAT64 AS (Add(x, -1));`
          #
          # The returnType is `{typeKind: "FLOAT64"}` for Add and Decrement, and is absent for Increment (inferred as
          # `FLOAT64` at query time).
          #
          # Suppose the function Add is replaced by `CREATE OR REPLACE FUNCTION Add(x INT64, y INT64) AS (x + y);`
          #
          # Then the inferred return type of Increment is automatically changed to `INT64` at query time, while the
          # return type of Decrement remains `FLOAT64`.
          #
          # @param [Google::Cloud::Bigquery::StandardSql::DataType, String] new_return_type The new return type for the
          #   routine.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   routine = dataset.routine "my_routine"
          #
          #   routine.return_type.type_kind #=> "INT64"
          #   routine.update do |r|
          #     r.return_type = "STRING"
          #   end
          #
          def return_type= new_return_type
            @gapi.return_type = StandardSql::DataType.gapi_from_string_or_data_type new_return_type
          end

          ##
          # Updates the list of the Google Cloud Storage URIs of imported JavaScript libraries. Optional. Only used if
          # {#language} is `JAVASCRIPT` ({#javascript?}).
          #
          # @param [Array<String>, nil] new_imported_libraries An array of Google Cloud Storage URIs, e.g.
          #   `["gs://cloud-samples-data/bigquery/udfs/max-value.js"]`.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   routine = dataset.routine "my_routine"
          #
          #   routine.update do |r|
          #     r.imported_libraries = [
          #       "gs://cloud-samples-data/bigquery/udfs/max-value.js"
          #     ]
          #   end
          #
          def imported_libraries= new_imported_libraries
            @gapi.imported_libraries = new_imported_libraries
          end

          ##
          # Updates the body of the routine. Required.
          #
          # For functions ({#scalar_function?}), this is the expression in the `AS` clause.
          #
          # When the routine is a SQL function ({#sql?}), it is the substring inside (but excluding) the parentheses.
          # For example, for the function created with the following statement:
          # ```
          # CREATE FUNCTION JoinLines(x string, y string) as (concat(x, "\n", y))
          # ```
          # The definition_body is `concat(x, "\n", y)` (`\n` is not replaced with linebreak).
          #
          # When the routine is a JavaScript function ({#javascript?}), it is the evaluated string in the `AS` clause.
          # For example, for the function created with the following statement:
          # ```
          # CREATE FUNCTION f() RETURNS STRING LANGUAGE js AS 'return "\n";\n'
          # ```
          # The definition_body is
          # ```
          # "return \"\n\";\n"`
          # ```
          # Note that both `\n` are replaced with linebreaks.
          #
          # @param [String] new_body The new body of the routine.
          #
          def body= new_body
            @gapi.definition_body = new_body
          end

          ##
          # Updates the description of the routine. Optional. [Experimental]
          #
          # @param [String] new_description The new routine description.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   routine = dataset.routine "my_routine"
          #
          #   routine.description #=> "My routine description"
          #   routine.update do |r|
          #     r.description = "My updated routine description"
          #   end
          #
          def description= new_description
            @gapi.description = new_description
          end

          ##
          # Updates the JavaScript UDF determinism level. Optional.
          #
          # * `DETERMINISTIC` - Deterministic indicates that two calls with the same input to a UDF yield the same
          #   output. If all JavaScript UDFs are `DETERMINISTIC`, the query result is potentially cachable.
          # * `NOT_DETERMINISTIC` - Not deterministic indicates that the output of the UDF is not guaranteed to yield
          #   the same output each time for a given set of inputs. If any JavaScript UDF is `NOT_DETERMINISTIC`, the
          #   query result is not cacheable.
          #
          # @param [String, nil] new_determinism_level The new routine determinism level in upper case.
          #
          # @example
          #   require "google/cloud/bigquery"
          #
          #   bigquery = Google::Cloud::Bigquery.new
          #   dataset = bigquery.dataset "my_dataset"
          #   routine = dataset.routine "my_routine"
          #
          #   routine.determinism_level #=> "NOT_DETERMINISTIC"
          #   routine.update do |r|
          #     r.determinism_level = "DETERMINISTIC"
          #   end
          #
          # @!group Attributes
          #
          def determinism_level= new_determinism_level
            @gapi.determinism_level = new_determinism_level
          end

          def update
            raise "not implemented in #{self.class}"
          end

          def delete
            raise "not implemented in #{self.class}"
          end

          def reload!
            raise "not implemented in #{self.class}"
          end
          alias refresh! reload!

          # @private
          def updates?
            !(@gapi === @original_gapi)
          end

          # @private
          def to_gapi
            @gapi
          end
        end
      end
    end
  end
end
