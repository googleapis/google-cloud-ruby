# Copyright 2019 Google LLC
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
        # @private Create an empty Table object.
        def initialize
          @service = nil
          @gapi = nil
        end

        ##
        # A unique ID for this routine.
        #
        # @return [String] The dataset ID.
        #
        # @!group Attributes
        #
        def routine_id
          @gapi.routine_reference.routine_id
        end
        # TODO: when creating, have the following documentation for choosing this value:
        #   The ID must contain only letters (a-z, A-Z), numbers
        #   (0-9), or underscores (_). The maximum length is 256 characters.

        ##
        # The ID of the `Dataset` containing this routine.
        #
        # @return [String] The dataset ID.
        #
        # @!group Attributes
        #
        def dataset_id
          @gapi.routine_reference.dataset_id
        end

        ##
        # The ID of the `Project` containing this routine.
        #
        # @return [String] The project ID.
        #
        # @!group Attributes
        #
        def project_id
          @gapi.routine_reference.project_id
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
          @gapi.etag
        end

        ###
        # The description of the routine (if defined).
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
          @gapi.description = new_description
          patch_gapi! :description
        end

        ###
        # DOCS
        #
        # @return [TYPE] DESC
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
          @gapi.return_type
        end

        ##
        # DOCS
        #
        # @param [TYPE] new_return_type DESC
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine"
        #
        #   routine.return_type # ORIGINALVALUE
        #   routine.return_type = UPDATEDVALUE
        #
        # @!group Attributes
        #
        def return_type= new_return_type
          @gapi.return_type = new_return_type
          patch_gapi! :return_type
        end

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
        # Corresponds to the JSON property `returnType`
        # @return [StandardSql::DataTypee]
        attr_accessor :return_type

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
        # Corresponds to the JSON property `definitionBody`
        #
        #
        #
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
        #
        #
        # @return [String]
        attr_accessor :definition_body

        # Optional. [Experimental] The description of the routine if defined.
        # Corresponds to the JSON property `description`
        # @return [String]
        attr_accessor :description

        # Optional. If language = "JAVASCRIPT", this field stores the path of the
        # imported JAVASCRIPT libraries.
        # Corresponds to the JSON property `importedLibraries`
        # @return [Array<String>]
        attr_accessor :imported_libraries

        # Optional. Defaults to "SQL".
        # Corresponds to the JSON property `language`
        # @return [String]
        attr_accessor :language
        # SQL  SQL language.
        # JAVASCRIPT  JavaScript language.

        # Required. Reference describing the ID of this routine.
        # Corresponds to the JSON property `routineReference`
        # @return [Google::Apis::BigqueryV2::RoutineReference]
        attr_accessor :routine_reference

        # Required. The type of routine.
        # Corresponds to the JSON property `routineType`
        # @return [String]
        attr_accessor :routine_type
        # SCALAR_FUNCTION  Non-builtin permanent scalar function.
        # PROCEDURE  Stored procedure.

        ###
        # DOCS
        #
        # @return [TYPE] DESC
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine"
        #
        #   routine.NAME # ORIGINALVALUE
        #
        # @!group Attributes
        #
        def NAME
          @gapi.NAME
        end

        ##
        # DOCS
        #
        # @param [TYPE] new_NAME DESC
        #
        # @example
        #   require "google/cloud/bigquery"
        #
        #   bigquery = Google::Cloud::Bigquery.new
        #   dataset = bigquery.dataset "my_dataset"
        #   routine = dataset.routine "my_routine"
        #
        #   routine.NAME # ORIGINALVALUE
        #   routine.NAME = UPDATEDVALUE
        #
        # @!group Attributes
        #
        def NAME= new_NAME
          @gapi.NAME = new_NAME
          patch_gapi! :NAME
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
          # always return frozen arguments
          Array(@gapi.arguments).map { |arg| Argument.from_gapi(arg).freeze }.freeze
        end
        # Optional.
        # Corresponds to the JSON property `arguments`
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
          @gapi.update! arguments: new_arguments.map(&:to_gapi)
          patch_gapi! :arguments
        end

        ##
        # The time when this routine was created.
        #
        # @return [Time, nil] The creation time.
        #
        # @!group Attributes
        #
        def created_at
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
          Convert.millis_to_time @gapi.last_modified_time
        end

        protected

        def frozen_check!
          return unless frozen?
          raise ArgumentError, "Cannot modify a frozen schema"
        end

        def add_argument _name, _type, description: nil, mode: :nullable
          frozen_check!
          # ...
        end

        ##
        # Yielded to a block to accumulate changes for a patch request.
        class Updater < Routine
          ##
          # A list of attributes that were updated.
          attr_reader :updates

          ##
          # Create an Updater object.
          def initialize gapi
            @updates = []
            @gapi = gapi.dup
            @original_imported_libraries = Array(@gapi.imported_libraries).map(&:freeze).freeze
            @imported_libraries = Array(@gapi.imported_libraries)
            @original_arguments = Array(@gapi.fields).map { |arg| Argument.from_gapi(arg).freeze }.freeze
            @arguments = Array(@gapi.arguments).map { |arg| Argument.from_gapi arg }
          end

          def imported_libraries
            @imported_libraries
          end

          def imported_libraries= new_imported_libraries
            @imported_libraries = new_imported_libraries
          end

          def arguments
            @arguments
          end

          def arguments= new_arguments
            @arguments = new_arguments
          end

          ##
          # Make sure any imported_libraries or arguments changes are saved.
          def check_for_mutated_values!
            if @original_imported_libraries != @imported_libraries
              @gapi.update! imported_libraries: @imported_libraries
              patch_gapi! :imported_libraries
            end
            if @original_arguments.map(&:to_gapi).map(&:to_h) != @arguments.map(&:to_gapi).map(&:to_h)
              @gapi.update! arguments: @arguments.map(&:to_gapi)
              patch_gapi! :arguments
            end
          end

          def to_gapi
            check_for_mutated_values!
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

      class RoutineReference
        include Google::Apis::Core::Hashable

        # [Required] The ID of the dataset containing this routine.
        # Corresponds to the JSON property `datasetId`
        # @return [String]
        attr_accessor :dataset_id

        # [Required] The ID of the project containing this routine.
        # Corresponds to the JSON property `projectId`
        # @return [String]
        attr_accessor :project_id

        # [Required] The ID of the routine. The ID must contain only letters (a-z, A-Z),
        # numbers (0-9), or underscores (_). The maximum length is 256 characters.
        # Corresponds to the JSON property `routineId`
        # @return [String]
        attr_accessor :routine_id

        def initialize **args
          update!(**args)
        end

        # Update properties of this object
        def update! **args
          @dataset_id = args[:dataset_id] if args.key? :dataset_id
          @project_id = args[:project_id] if args.key? :project_id
          @routine_id = args[:routine_id] if args.key? :routine_id
        end
      end
    end
  end
end
