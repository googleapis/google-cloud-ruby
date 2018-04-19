# Copyright 2017 Google LLC
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


require "google/cloud/firestore/v1beta1"
require "google/cloud/firestore/document_snapshot"
require "google/cloud/firestore/convert"

module Google
  module Cloud
    module Firestore
      ##
      # # Query
      #
      # Represents a query to the Firestore API.
      #
      # Instances of this class are immutable. All methods that refine the query
      # return new instances.
      #
      # @example
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      #   # Create a query
      #   query = firestore.col(:cities).select(:population)
      #
      #   query.get do |city|
      #     puts "#{city.document_id} has #{city[:population]} residents."
      #   end
      #
      class Query
        ##
        # @private The parent path for the query.
        attr_accessor :parent_path

        ##
        # @private The Google::Firestore::V1beta1::Query object.
        attr_accessor :query

        ##
        # @private The firestore client object.
        attr_accessor :client

        ##
        # Restricts documents matching the query to return only data for the
        # provided fields.
        #
        # @param [FieldPath, String, Symbol] fields A field path to
        #   filter results with and return only the specified fields. One or
        #   more field paths can be specified.
        #
        #   If a {FieldPath} object is not provided then the field will be
        #   treated as a dotted string, meaning the string represents individual
        #   fields joined by ".". Fields containing `~`, `*`, `/`, `[`, `]`, and
        #   `.` cannot be in a dotted string, and should provided using a
        #   {FieldPath} object instead.
        #
        # @return [Query] New query with `select` called on it.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Create a query
        #   query = cities_col.select(:population)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def select *fields
          new_query = @query.dup
          new_query ||= StructuredQuery.new

          field_refs = fields.flatten.compact.map do |field|
            field = FieldPath.parse field unless field.is_a? FieldPath
            StructuredQuery::FieldReference.new \
              field_path: field.formatted_string
          end

          new_query.select ||= StructuredQuery::Projection.new
          field_refs.each do |field_ref|
            new_query.select.fields << field_ref
          end

          Query.start new_query, parent_path, client
        end

        ##
        # @private This is marked private and can't be removed.
        #
        # Selects documents from all collections, immediate children and nested,
        # of where the query was created from.
        #
        # @return [Query] New query with `all_descendants` called on it.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Create a query
        #   query = cities_col.all_descendants
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def all_descendants
          new_query = @query.dup
          new_query ||= StructuredQuery.new

          if new_query.from.empty?
            raise "missing collection_id to specify descendants."
          end

          new_query.from.last.all_descendants = true

          Query.start new_query, parent_path, client
        end

        ##
        # @private This is marked private and can't be removed.
        #
        # Selects only documents from collections that are immediate children of
        # where the query was created from.
        #
        # @return [Query] New query with `direct_descendants` called on it.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Create a query
        #   query = cities_col.direct_descendants
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def direct_descendants
          new_query = @query.dup
          new_query ||= StructuredQuery.new

          if new_query.from.empty?
            raise "missing collection_id to specify descendants."
          end

          new_query.from.last.all_descendants = false

          Query.start new_query, parent_path, client
        end

        ##
        # Filters the query on a field.
        #
        # @param [FieldPath, String, Symbol] field A field path to filter
        #   results with.
        #
        #   If a {FieldPath} object is not provided then the field will be
        #   treated as a dotted string, meaning the string represents individual
        #   fields joined by ".". Fields containing `~`, `*`, `/`, `[`, `]`, and
        #   `.` cannot be in a dotted string, and should provided using a
        #   {FieldPath} object instead.
        # @param [String, Symbol] operator The operation to compare the field
        #   to. Acceptable values include:
        #
        #   * less than: `<`, `lt`
        #   * less than or equal: `<=`, `lte`
        #   * greater than: `>`, `gt`
        #   * greater than or equal: `>=`, `gte`
        #   * equal: `=`, `==`, `eq`, `eql`, `is`
        # @param [Object] value A value the field is compared to.
        #
        # @return [Query] New query with `where` called on it.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Create a query
        #   query = cities_col.where(:population, :>=, 1000000)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def where field, operator, value
          new_query = @query.dup
          new_query ||= StructuredQuery.new

          field = FieldPath.parse field unless field.is_a? FieldPath

          new_query.where ||= default_filter
          new_query.where.composite_filter.filters << \
            filter(field.formatted_string, operator, value)

          Query.start new_query, parent_path, client
        end

        ##
        # Specifies an "order by" clause on a field.
        #
        # @param [FieldPath, String, Symbol] field A field path to order results
        #   with.
        #
        #   If a {FieldPath} object is not provided then the field will be
        #   treated as a dotted string, meaning the string represents individual
        #   fields joined by ".". Fields containing `~`, `*`, `/`, `[`, `]`, and
        #   `.` cannot be in a dotted string, and should provided using a
        #   {FieldPath} object instead.
        # @param [String, Symbol] direction The direction to order the results
        #   by. Values that start with "a" are considered `ascending`. Values
        #   that start with "d" are considered `descending`. Default is
        #   `ascending`. Optional.
        #
        # @return [Query] New query with `order` called on it.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Create a query
        #   query = cities_col.order(:name)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        # @example Order by name descending:
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Create a query
        #   query = cities_col.order(:name, :desc)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def order field, direction = :asc
          new_query = @query.dup
          new_query ||= StructuredQuery.new

          field = FieldPath.parse field unless field.is_a? FieldPath

          new_query.order_by << StructuredQuery::Order.new(
            field: StructuredQuery::FieldReference.new(
              field_path: field.formatted_string
            ),
            direction: order_direction(direction)
          )

          Query.start new_query, parent_path, client
        end
        alias order_by order

        ##
        # Skips to an offset in a query. If the current query already has
        # specified an offset, this will overwrite it.
        #
        # @param [Integer] num The number of results to skip.
        #
        # @return [Query] New query with `offset` called on it.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Create a query
        #   query = cities_col.limit(5).offset(10)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def offset num
          new_query = @query.dup
          new_query ||= StructuredQuery.new

          new_query.offset = num

          Query.start new_query, parent_path, client
        end

        ##
        # Limits a query to return a fixed number of results. If the current
        # query already has a limit set, this will overwrite it.
        #
        # @param [Integer] num The maximum number of results to return.
        #
        # @return [Query] New query with `limit` called on it.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Create a query
        #   query = cities_col.offset(10).limit(5)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def limit num
          new_query = @query.dup
          new_query ||= StructuredQuery.new

          new_query.limit = Google::Protobuf::Int32Value.new(value: num)

          Query.start new_query, parent_path, client
        end

        ##
        # Starts query results at a set of field values. The result set will
        # include the document specified by `values`.
        #
        # If the current query already has specified `start_at` or
        # `start_after`, this will overwrite it.
        #
        # The values provided here are for the field paths provides to `order`.
        # Values provided to `start_at` without an associated field path
        # provided to `order` will result in an error.
        #
        # @param [Object] values The field value to start the query at.
        #
        # @return [Query] New query with `start_at` called on it.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Create a query
        #   query = cities_col.start_at("NYC").order(firestore.document_id)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def start_at *values
          new_query = @query.dup
          new_query ||= StructuredQuery.new

          values = values.flatten.map { |value| Convert.raw_to_value value }
          new_query.start_at = Google::Firestore::V1beta1::Cursor.new(
            values: values, before: true
          )

          Query.start new_query, parent_path, client
        end

        ##
        # Starts query results after a set of field values. The result set will
        # not include the document specified by `values`.
        #
        # If the current query already has specified `start_at` or
        # `start_after`, this will overwrite it.
        #
        # The values provided here are for the field paths provides to `order`.
        # Values provided to `start_after` without an associated field path
        # provided to `order` will result in an error.
        #
        # @param [Object] values The field value to start the query after.
        #
        # @return [Query] New query with `start_after` called on it.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Create a query
        #   query = cities_col.start_after("NYC").order(firestore.document_id)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def start_after *values
          new_query = @query.dup
          new_query ||= StructuredQuery.new

          values = values.flatten.map { |value| Convert.raw_to_value value }
          new_query.start_at = Google::Firestore::V1beta1::Cursor.new(
            values: values, before: false
          )

          Query.start new_query, parent_path, client
        end

        ##
        # Ends query results before a set of field values. The result set will
        # not include the document specified by `values`.
        #
        # If the current query already has specified `end_before` or
        # `end_at`, this will overwrite it.
        #
        # The values provided here are for the field paths provides to `order`.
        # Values provided to `end_before` without an associated field path
        # provided to `order` will result in an error.
        #
        # @param [Object] values The field value to end the query before.
        #
        # @return [Query] New query with `end_before` called on it.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Create a query
        #   query = cities_col.end_before("NYC").order(firestore.document_id)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def end_before *values
          new_query = @query.dup
          new_query ||= StructuredQuery.new

          values = values.flatten.map { |value| Convert.raw_to_value value }
          new_query.end_at = Google::Firestore::V1beta1::Cursor.new(
            values: values, before: true
          )

          Query.start new_query, parent_path, client
        end

        ##
        # Ends query results at a set of field values. The result set will
        # include the document specified by `values`.
        #
        # If the current query already has specified `end_before` or
        # `end_at`, this will overwrite it.
        #
        # The values provided here are for the field paths provides to `order`.
        # Values provided to `end_at` without an associated field path provided
        # to `order` will result in an error.
        #
        # @param [Object] values The field value to end the query at.
        #
        # @return [Query] New query with `end_at` called on it.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Create a query
        #   query = cities_col.end_at("NYC").order(firestore.document_id)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def end_at *values
          new_query = @query.dup
          new_query ||= StructuredQuery.new

          values = values.flatten.map { |value| Convert.raw_to_value value }
          new_query.end_at = Google::Firestore::V1beta1::Cursor.new(
            values: values, before: false
          )

          Query.start new_query, parent_path, client
        end

        ##
        # Retrieves document snapshots for the query.
        #
        # @yield [documents] The block for accessing the document snapshots.
        # @yieldparam [DocumentReference] document A document snapshot.
        #
        # @return [Enumerator<DocumentReference>] A list of document snapshots.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Create a query
        #   query = cities_col.select(:population)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def get
          ensure_service!

          return enum_for(:run) unless block_given?

          results = service.run_query parent_path, @query
          results.each do |result|
            next if result.document.nil?
            yield DocumentSnapshot.from_query_result(result, client)
          end
        end
        alias run get

        ##
        # @private Start a new Query.
        def self.start query, parent_path, client
          query ||= StructuredQuery.new
          Query.new.tap do |q|
            q.instance_variable_set :@query, query
            q.instance_variable_set :@parent_path, parent_path
            q.instance_variable_set :@client, client
          end
        end

        protected

        ##
        # @private
        StructuredQuery = Google::Firestore::V1beta1::StructuredQuery

        ##
        # @private
        FILTER_OPS = {
          "<"   => :LESS_THAN,
          "lt"  => :LESS_THAN,
          "<="  => :LESS_THAN_OR_EQUAL,
          "lte" => :LESS_THAN_OR_EQUAL,
          ">"   => :GREATER_THAN,
          "gt"  => :GREATER_THAN,
          ">="  => :GREATER_THAN_OR_EQUAL,
          "gte" => :GREATER_THAN_OR_EQUAL,
          "="   => :EQUAL,
          "=="  => :EQUAL,
          "eq"  => :EQUAL,
          "eql" => :EQUAL,
          "is"  => :EQUAL
        }.freeze
        ##
        # @private
        UNARY_NIL_VALUES = [nil, :null, :nil].freeze
        ##
        # @private
        UNARY_NAN_VALUES = [:nan, Float::NAN].freeze
        ##
        # @private
        UNARY_VALUES = (UNARY_NIL_VALUES + UNARY_NAN_VALUES).freeze

        def filter name, op, value
          field = StructuredQuery::FieldReference.new field_path: name.to_s
          op = FILTER_OPS[op.to_s.downcase] || :EQUAL

          is_value_nan = value.respond_to?(:nan?) && value.nan?
          if UNARY_VALUES.include?(value) || is_value_nan
            if op != :EQUAL
              raise ArgumentError,
                    "can only check equality for #{value} values."
            end

            op = :IS_NULL
            op = :IS_NAN if UNARY_NAN_VALUES.include?(value) || is_value_nan

            return StructuredQuery::Filter.new(unary_filter:
              StructuredQuery::UnaryFilter.new(field: field, op: op))
          end

          value = Convert.raw_to_value value
          StructuredQuery::Filter.new(field_filter:
              StructuredQuery::FieldFilter.new(field: field, op: op,
                                               value: value))
        end

        def default_filter
          StructuredQuery::Filter.new(composite_filter:
              StructuredQuery::CompositeFilter.new(op: :AND))
        end

        def order_direction direction
          if direction.to_s.downcase.start_with? "a"
            :ASCENDING
          elsif direction.to_s.downcase.start_with? "d"
            :DESCENDING
          else
            :DIRECTION_UNSPECIFIED
          end
        end

        ##
        # @private Raise an error unless an database available.
        def ensure_client!
          raise "Must have active connection to service" unless client
        end

        ##
        # @private The Service object.
        def service
          ensure_client!

          client.service
        end

        ##
        # @private Raise an error unless an active connection to the service
        # is available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end
      end
    end
  end
end
