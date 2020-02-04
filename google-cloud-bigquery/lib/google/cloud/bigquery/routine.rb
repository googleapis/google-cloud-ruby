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
      # A user-defined function or a stored procedure.
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
        # @return [String] The ID must contain only letters (a-z, A-Z), numbers (0-9), or underscores (_). The maximum
        #   length is 256 characters.
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
        # @return [String] The ETag hash.
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

        # Required. The type of routine.
        # @return [String]
        # SCALAR_FUNCTION  Non-builtin permanent scalar function.
        # PROCEDURE  Stored procedure.
        def routine_type
          return nil if reference?
          @gapi.routine_type
        end

        # Required. The type of routine.
        # @return [String]
        # SCALAR_FUNCTION  Non-builtin permanent scalar function.
        # PROCEDURE  Stored procedure.
        def routine_type= new_routine_type
          ensure_full_data!
          @gapi.routine_type = new_routine_type
          update_gapi!
        end

        ##
        # Checks if the value of {#routine_type} is `PROCEDURE`. The default is `false`.
        #
        # @return [Boolean] `true` when `PROCEDURE`, `false` otherwise.
        #
        def procedure?
          @gapi.routine_type == "PROCEDURE"
        end

        ##
        # Checks if the value of {#routine_type} is `SCALAR_FUNCTION`. The default is `true`.
        #
        # @return [Boolean] `true` when `SCALAR_FUNCTION`, `false` otherwise.
        #
        def scalar_function?
          @gapi.routine_type == "SCALAR_FUNCTION"
        end

        ##
        # The time when this routine was created.
        #
        # @return [Time, nil] The creation time.
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
        # @return [Time, nil] The last modified time.
        #
        # @!group Attributes
        #
        def modified_at
          return nil if reference?
          Convert.millis_to_time @gapi.last_modified_time
        end

        # Optional. Defaults to "SQL".
        # @return [String]
        # SQL  SQL language.
        # JAVASCRIPT  JavaScript language.
        def language
          return nil if reference?
          @gapi.language
        end

        # Optional. Defaults to "SQL".
        # @return [String]
        # SQL  SQL language.
        # JAVASCRIPT  JavaScript language.
        def language= new_language
          ensure_full_data!
          @gapi.language = new_language
          update_gapi!
        end

        ##
        # Checks if the value of {#language} is JAVASCRIPT. The default is `false`.
        #
        # @return [Boolean] `true` when `JAVASCRIPT`, `false` otherwise.
        #
        def javascript?
          @gapi.language == "JAVASCRIPT"
        end

        ##
        # Checks if the value of {#language} is `SQL`. The default is `true`.
        #
        # @return [Boolean] `true` when `SQL` or `nil`, `false` otherwise.
        #
        def sql?
          return true if @gapi.language.nil?
          @gapi.language == "SQL"
        end

        ##
        # The input/output arguments of the routine.
        #
        # @return [Array<Argument>] An array of argument objects.
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
        def arguments
          return nil if reference?
          ensure_full_data!
          # always return frozen arguments
          Array(@gapi.arguments).map { |a| Argument.from_gapi a }.freeze
        end
        # Optional.
        # @return [Array<Google::Apis::BigqueryV2::Argument>]
        # attr_accessor :arguments

        ##
        # Updates the input/output arguments of the routine.
        #
        # @param [Array<Argument>] new_arguments The new arguments.
        #
        # @!group Attributes
        #
        def arguments= new_arguments
          ensure_full_data!
          @gapi.update! arguments: new_arguments.map(&:to_gapi)
          update_gapi!
        end

        ###
        # The type of a variable, e.g., a function argument.
        #
        # Examples:
        # INT64: `type_kind="INT64"`
        # ARRAY<STRING>: `type_kind="ARRAY", array_element_type="STRING"`
        # STRUCT<x STRING, y ARRAY<DATE>>:
        # `type_kind="STRUCT",
        # struct_type=`fields=[
        # `name="x", type=`type_kind="STRING"``,
        # `name="y", type=`type_kind="ARRAY", array_element_type="DATE"``
        # ]``
        # @return [Google::Cloud::Bigquery::StandardSql::DataType]
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine"
        #
        #   routine.return_type # ORIGINALVALUE
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
        # DOCS
        #
        # @param [Google::Cloud::Bigquery::StandardSql::DataType] new_return_type DESC
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine"
        #
        #   routine.return_type.type_kind #=> "INT64"
        #   routine.return_type = Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: "STRING"
        #
        # @!group Attributes
        #
        def return_type= new_return_type
          ensure_full_data!
          @gapi.return_type = new_return_type&.to_gapi
          update_gapi!
        end

        ##
        # If {#language} is `JAVASCRIPT`, a list of the Google Cloud Storage URIs of imported JavaScript libraries.
        #
        # @return [Array<String>, nil] A frozen array of Google Cloud Storage URIs, e.g.
        #   `["gs://cloud-samples-data/bigquery/udfs/max-value.js"]`.
        #
        def imported_libraries
          return nil if reference?
          ensure_full_data!
          @gapi.imported_libraries.freeze
        end

        ##
        # If {#language} is `JAVASCRIPT`, a list of the Google Cloud Storage URIs of imported JavaScript libraries.
        #
        # @param [Array<String>, nil] new_imported_libraries An array of Google Cloud Storage URIs, e.g.
        #   `["gs://cloud-samples-data/bigquery/udfs/max-value.js"]`.
        #
        def imported_libraries= new_imported_libraries
          ensure_full_data!
          @gapi.imported_libraries = new_imported_libraries
          update_gapi!
        end

        ##
        # The body of the routine.
        #
        # For functions {#scalar_function?}, this is the expression in the `AS` clause.
        #
        # When the routine is a SQL function {#sql?}, it is the substring inside (but excluding) the parentheses. For
        # example, for the function created with the following statement:
        # `CREATE FUNCTION JoinLines(x string, y string) as (concat(x, "\n", y))`
        # The definition_body is `concat(x, "\n", y)` (\n is not replaced with
        # linebreak). ((RUN THIS AND GET THE ACTUAL VALUE FOR THIS))
        #
        # When the routine is a JavaScript function {#javascript?}, it is the evaluated string in the `AS` clause.
        # For example, for the function created with the following statement:
        # `CREATE FUNCTION f() RETURNS STRING LANGUAGE js AS 'return "\n";\n'`
        # The definition_body is
        # `"return \"\n\";\n"` ((RUN THIS AND GET THE ACTUAL VALUE FOR THIS))
        # Note that both \n are replaced with linebreaks.
        #
        # For functions {sql?}, this is the expression in the `AS` clause. It is the substring inside (but excluding)
        # the parentheses. For example, for the function created with the following statement: `CREATE FUNCTION
        # JoinLines(x string, y string) as (concat(x, "\n", y))` The definition_body is `"concat(x, \"\n\", y)""`.
        #
        # If language=JAVASCRIPT, it is the evaluated string in the AS clause.
        # For example, for the function created with the following statement:
        # `CREATE FUNCTION f() RETURNS STRING LANGUAGE js AS 'return "\n";\n'`
        # The definition_body is
        # `"return \"\n\";\n"`
        #
        # @return [String]
        #
        def body
          return nil if reference?
          ensure_full_data!
          @gapi.definition_body
        end

        ##
        # The body of the routine.
        #
        # For functions {#scalar_function?}, this is the expression in the `AS` clause.
        #
        # When the routine is a SQL function {#sql?}, it is the substring inside (but excluding) the
        # parentheses. For example, for the function created with the following
        # statement:
        # `CREATE FUNCTION JoinLines(x string, y string) as (concat(x, "\n", y))`
        # The definition_body is `concat(x, "\n", y)` (\n is not replaced with
        # linebreak). ((RUN THIS AND GET THE ACTUAL VALUE FOR THIS))
        #
        # When the routine is a JavaScript function {#javascript?}, it is the evaluated string in the `AS` clause.
        # For example, for the function created with the following statement:
        # `CREATE FUNCTION f() RETURNS STRING LANGUAGE js AS 'return "\n";\n'`
        # The definition_body is
        # `"return \"\n\";\n"` ((RUN THIS AND GET THE ACTUAL VALUE FOR THIS))
        # Note that both \n are replaced with linebreaks.
        #
        # For functions {sql?}, this is the expression in the `AS` clause. It is the substring inside (but excluding)
        # the parentheses. For example, for the function created with the following statement: `CREATE FUNCTION
        # JoinLines(x string, y string) as (concat(x, "\n", y))` The definition_body is `"concat(x, \"\n\", y)""`.
        #
        # If language=JAVASCRIPT, it is the evaluated string in the AS clause.
        # For example, for the function created with the following statement:
        # `CREATE FUNCTION f() RETURNS STRING LANGUAGE js AS 'return "\n";\n'`
        # The definition_body is
        # `"return \"\n\";\n"`
        #
        # @return [String]
        #
        def body= new_body
          ensure_full_data!
          @gapi.definition_body = new_body
          update_gapi!
        end

        ###
        # Optional. [Experimental] The description of the routine if defined.
        #
        # @return [String] The routine description.
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine"
        #
        #   routine.description # "My routine description"
        #
        # @!group Attributes
        #
        def description
          return nil if reference?
          ensure_full_data!
          @gapi.description
        end

        ##
        # Updates the description of the routine.
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
        #   routine.description # "My routine description"
        #   routine.description = "My updated routine description"
        #
        # @!group Attributes
        #
        def description= new_description
          ensure_full_data!
          @gapi.description = new_description
          update_gapi!
        end

        ##
        # Updates the routine with changes made in the given block in a single update request. The following attributes
        # may be set: {#routine_type=}, {#language=}, {#arguments=}, {#return_type=}, {#imported_libraries=}, {#body=},
        # and {#description=}.
        #
        # @yield [routine] a block yielding a delegate object for updating the routine
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
        #     r.description = "my new description"
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
        def exists? force: nil
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
        #   routine.resource_partial? # true
        #   routine.description # Loads the full resource.
        #   routine.resource_partial? # false
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
        #   routine.resource_full? # true
        #
        def resource_full?
          resource? && @gapi.description
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

          new.tap do |r|
            reference_gapi = Google::Apis::BigqueryV2::RoutineReference.new(
              project_id: project_id,
              dataset_id: dataset_id,
              routine_id: routine_id
            )
            r.service = service
            r.instance_variable_set :@reference, reference_gapi
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
        # Yielded to a block to accumulate changes. See Dataset#create_routine and Routine#update.
        class Updater < Routine
          ##
          # Create an Updater object.
          def initialize gapi
            @original_gapi = gapi
            @gapi = gapi.dup
          end

          def routine_type= new_routine_type
            @gapi.routine_type = new_routine_type
          end

          def language= new_language
            @gapi.language = new_language
          end

          def arguments= new_arguments
            @gapi.arguments = new_arguments.map(&:to_gapi)
          end

          def return_type= new_return_type
            @gapi.return_type = StandardSql::DataType.gapi_from_string_or_data_type new_return_type
          end

          def imported_libraries= new_imported_libraries
            @gapi.imported_libraries = new_imported_libraries
          end

          def body= new_body
            @gapi.definition_body = new_body
          end

          def description= new_description
            @gapi.description = new_description
          end

          # rubocop:disable Style/CaseEquality
          def updates?
            !(@gapi === @original_gapi)
          end
          # rubocop:enable Style/CaseEquality

          def to_gapi
            @gapi
          end
        end
      end
    end
  end
end
