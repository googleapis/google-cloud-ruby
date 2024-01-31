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


require "google/cloud/firestore/v1"
require "google/cloud/firestore/document_snapshot"
require "google/cloud/firestore/query_listener"
require "google/cloud/firestore/convert"
require "google/cloud/firestore/aggregate_query"
require "google/cloud/firestore/filter"
require "json"

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
      # @example Listen to a query for changes:
      #   require "google/cloud/firestore"
      #
      #   firestore = Google::Cloud::Firestore.new
      #
      #   # Create a query
      #   query = firestore.col(:cities).order(:population, :desc)
      #
      #   listener = query.listen do |snapshot|
      #     puts "The query snapshot has #{snapshot.docs.count} documents "
      #     puts "and has #{snapshot.changes.count} changes."
      #   end
      #
      #   # When ready, stop the listen operation and close the stream.
      #   listener.stop
      #
      class Query
        ##
        # @private The parent path for the query.
        attr_accessor :parent_path

        ##
        # @private The type for limit queries.
        attr_reader :limit_type

        ##
        # @private The Google::Cloud::Firestore::V1::StructuredQuery object.
        attr_accessor :query

        ##
        # @private The firestore client object.
        attr_accessor :client

        ##
        # @private Creates a new Query.
        def initialize query, parent_path, client, limit_type: nil
          query ||= StructuredQuery.new
          @query = query
          @parent_path = parent_path
          @limit_type = limit_type
          @client = client
        end

        ##
        # Restricts documents matching the query to return only data for the
        # provided fields.
        #
        # @param [FieldPath, String, Symbol, Array<FieldPath|String|Symbol>]
        #   fields A field path to filter results with and return only the
        #   specified fields. One or more field paths can be specified.
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

          fields = Array(fields).flatten.compact
          fields = [FieldPath.document_id] if fields.empty?
          field_refs = fields.flatten.compact.map do |field|
            field = FieldPath.parse field unless field.is_a? FieldPath
            StructuredQuery::FieldReference.new \
              field_path: field.formatted_string
          end

          new_query.select = StructuredQuery::Projection.new
          field_refs.each do |field_ref|
            new_query.select.fields << field_ref
          end

          Query.start new_query, parent_path, client, limit_type: limit_type
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
            raise "missing collection_id to specify descendants"
          end

          new_query.from.last.all_descendants = true

          Query.start new_query, parent_path, client, limit_type: limit_type
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
            raise "missing collection_id to specify descendants"
          end

          new_query.from.last.all_descendants = false

          Query.start new_query, parent_path, client, limit_type: limit_type
        end

        ##
        # Adds filter to the where clause
        #
        # @overload where(filter)
        #   Pass Firestore::Filter to `where` via field_or_filter argument.
        #
        #  @param filter [::Google::Cloud::Firestore::Filter]
        #
        # @overload where(field, operator, value)
        #   Pass arguments to `where` via positional arguments.
        #
        #   @param field [FieldPath, String, Symbol] A field path to filter
        #     results with.
        #     If a {FieldPath} object is not provided then the field will be
        #     treated as a dotted string, meaning the string represents individual
        #     fields joined by ".". Fields containing `~`, `*`, `/`, `[`, `]`, and
        #     `.` cannot be in a dotted string, and should provided using a
        #     {FieldPath} object instead.
        #
        #   @param operator [String, Symbol] The operation to compare the field
        #     to. Acceptable values include:
        #     * less than: `<`, `lt`
        #     * less than or equal: `<=`, `lte`
        #     * greater than: `>`, `gt`
        #     * greater than or equal: `>=`, `gte`
        #     * equal: `=`, `==`, `eq`, `eql`, `is`
        #     * not equal: `!=`
        #     * in: `in`
        #     * not in: `not-in`, `not_in`
        #     * array contains: `array-contains`, `array_contains`
        #
        #   @param value [Object] The value to compare the property to. Defaults to nil.
        #     Possible values are:
        #     * Integer
        #     * Float/BigDecimal
        #     * String
        #     * Boolean
        #     * Array
        #     * Date/Time
        #     * StringIO
        #     * Google::Cloud::Datastore::Key
        #     * Google::Cloud::Datastore::Entity
        #     * nil
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
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Create a filter
        #   filter = Filter.create(:population, :>=, 1000000)
        #
        #   # Add filter to where clause
        #   query = query.where filter
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def where filter_or_field = nil, operator = nil, value = nil
          if query_has_cursors?
            raise "cannot call where after calling " \
                  "start_at, start_after, end_before, or end_at"
          end

          new_query = @query.dup
          new_query ||= StructuredQuery.new

          if filter_or_field.is_a? Google::Cloud::Firestore::Filter
            new_query.where = filter_or_field.filter
          else
            new_filter = Google::Cloud::Firestore::Filter.new filter_or_field, operator, value
            add_filters_to_query new_query, new_filter.filter
          end

          Query.start new_query, parent_path, client, limit_type: limit_type
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
          if query_has_cursors? || limit_type == :last
            raise "cannot call order after calling limit_to_last, start_at, start_after, end_before, or end_at"
          end

          new_query = @query.dup
          new_query ||= StructuredQuery.new

          field = FieldPath.parse field unless field.is_a? FieldPath

          new_query.order_by << StructuredQuery::Order.new(
            field:     StructuredQuery::FieldReference.new(
              field_path: field.formatted_string
            ),
            direction: order_direction(direction)
          )

          Query.start new_query, parent_path, client, limit_type: limit_type
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

          Query.start new_query, parent_path, client, limit_type: limit_type
        end

        ##
        # Limits a query to return only the first matching documents.
        #
        # If the current query already has a limit set, this will overwrite it.
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
        #   query = cities_col.order(:name, :desc).offset(10).limit(5)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def limit num
          if limit_type == :last
            raise "cannot call limit after calling limit_to_last"
          end

          new_query = @query.dup
          new_query ||= StructuredQuery.new

          new_query.limit = Google::Protobuf::Int32Value.new value: num

          Query.start new_query, parent_path, client, limit_type: :first
        end

        ##
        # Limits a query to return only the last matching documents.
        #
        # You must specify at least one "order by" clause for limitToLast queries.
        # (See {#order}.)
        #
        # Results for `limit_to_last` queries are only available once all documents
        # are received. Hence, `limit_to_last` queries cannot be streamed using
        # {#listen}.
        #
        # @param [Integer] num The maximum number of results to return.
        #
        # @return [Query] New query with `limit_to_last` called on it.
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
        #   query = cities_col.order(:name, :desc).limit_to_last(5)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def limit_to_last num
          new_query = @query.dup

          if new_query.nil? || new_query.order_by.nil? || new_query.order_by.empty?
            raise "specify at least one order clause before calling limit_to_last"
          end

          if limit_type != :last # Don't reverse order_by more than once.
            # Reverse the order_by directions since we want the last results.
            new_query.order_by.each do |order|
              order.direction = order.direction.to_sym == :DESCENDING ? :ASCENDING : :DESCENDING
            end

            # Swap the cursors to match the reversed query ordering.
            new_end_at = new_query.start_at.dup
            new_start_at = new_query.end_at.dup
            if new_end_at
              new_end_at.before = !new_end_at.before
              new_query.end_at = new_end_at
            end
            if new_start_at
              new_start_at.before = !new_start_at.before
              new_query.start_at = new_start_at
            end
          end

          new_query.limit = Google::Protobuf::Int32Value.new value: num

          Query.start new_query, parent_path, client, limit_type: :last
        end

        ##
        # Starts query results at a set of field values. The field values can be
        # specified explicitly as arguments, or can be specified implicitly by
        # providing a {DocumentSnapshot} object instead. The result set will
        # include the document specified by `values`.
        #
        # If the current query already has specified `start_at` or
        # `start_after`, this will overwrite it.
        #
        # The values are associated with the field paths that have been provided
        # to `order`, and must match the same sort order. An ArgumentError will
        # be raised if more explicit values are given than are present in
        # `order`.
        #
        # @param [DocumentSnapshot, Object, Array<Object>] values The field
        #   values to start the query at.
        #
        # @return [Query] New query with `start_at` called on it.
        #
        # @example Starting a query at a document reference id
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #   nyc_doc_id = "NYC"
        #
        #   # Create a query
        #   query = cities_col.order(firestore.document_id)
        #                     .start_at(nyc_doc_id)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        # @example Starting a query at a document reference object
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #   nyc_doc_id = "NYC"
        #   nyc_ref = cities_col.doc nyc_doc_id
        #
        #   # Create a query
        #   query = cities_col.order(firestore.document_id)
        #                     .start_at(nyc_ref)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        # @example Starting a query at multiple explicit values
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Create a query
        #   query = cities_col.order(:population, :desc)
        #                     .order(:name)
        #                     .start_at(1000000, "New York City")
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        # @example Starting a query at a DocumentSnapshot
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Get a document snapshot
        #   nyc_snap = firestore.doc("cities/NYC").get
        #
        #   # Create a query
        #   query = cities_col.order(:population, :desc)
        #                     .order(:name)
        #                     .start_at(nyc_snap)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def start_at *values
          raise ArgumentError, "must provide values" if values.empty?

          if limit_type == :last
            raise "cannot call start_at after calling limit_to_last"
          end

          new_query = @query.dup
          new_query ||= StructuredQuery.new

          cursor = values_to_cursor values, new_query
          cursor.before = true
          new_query.start_at = cursor

          Query.start new_query, parent_path, client, limit_type: limit_type
        end

        ##
        # Starts query results after a set of field values. The field values can
        # be specified explicitly as arguments, or can be specified implicitly
        # by providing a {DocumentSnapshot} object instead. The result set will
        # not include the document specified by `values`.
        #
        # If the current query already has specified `start_at` or
        # `start_after`, this will overwrite it.
        #
        # The values are associated with the field paths that have been provided
        # to `order`, and must match the same sort order. An ArgumentError will
        # be raised if more explicit values are given than are present in
        # `order`.
        #
        # @param [DocumentSnapshot, Object, Array<Object>] values The field
        #   values to start the query after.
        #
        # @return [Query] New query with `start_after` called on it.
        #
        # @example Starting a query after a document reference id
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #   nyc_doc_id = "NYC"
        #
        #   # Create a query
        #   query = cities_col.order(firestore.document_id)
        #                     .start_after(nyc_doc_id)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        # @example Starting a query after a document reference object
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #   nyc_doc_id = "NYC"
        #   nyc_ref = cities_col.doc nyc_doc_id
        #
        #   # Create a query
        #   query = cities_col.order(firestore.document_id)
        #                     .start_after(nyc_ref)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        # @example Starting a query after multiple explicit values
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Create a query
        #   query = cities_col.order(:population, :desc)
        #                     .order(:name)
        #                     .start_after(1000000, "New York City")
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        # @example Starting a query after a DocumentSnapshot
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Get a document snapshot
        #   nyc_snap = firestore.doc("cities/NYC").get
        #
        #   # Create a query
        #   query = cities_col.order(:population, :desc)
        #                     .order(:name)
        #                     .start_after(nyc_snap)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def start_after *values
          raise ArgumentError, "must provide values" if values.empty?

          if limit_type == :last
            raise "cannot call start_after after calling limit_to_last"
          end


          new_query = @query.dup
          new_query ||= StructuredQuery.new

          cursor = values_to_cursor values, new_query
          cursor.before = false
          new_query.start_at = cursor

          Query.start new_query, parent_path, client, limit_type: limit_type
        end

        ##
        # Ends query results before a set of field values. The field values can
        # be specified explicitly as arguments, or can be specified implicitly
        # by providing a {DocumentSnapshot} object instead. The result set will
        # not include the document specified by `values`.
        #
        # If the current query already has specified `end_before` or
        # `end_at`, this will overwrite it.
        #
        # The values are associated with the field paths that have been provided
        # to `order`, and must match the same sort order. An ArgumentError will
        # be raised if more explicit values are given than are present in
        # `order`.
        #
        # @param [DocumentSnapshot, Object, Array<Object>] values The field
        #   values to end the query before.
        #
        # @return [Query] New query with `end_before` called on it.
        #
        # @example Ending a query before a document reference id
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #   nyc_doc_id = "NYC"
        #
        #   # Create a query
        #   query = cities_col.order(firestore.document_id)
        #                     .end_before(nyc_doc_id)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        # @example Ending a query before a document reference object
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #   nyc_doc_id = "NYC"
        #   nyc_ref = cities_col.doc nyc_doc_id
        #
        #   # Create a query
        #   query = cities_col.order(firestore.document_id)
        #                     .end_before(nyc_ref)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        # @example Ending a query before multiple explicit values
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Create a query
        #   query = cities_col.order(:population, :desc)
        #                     .order(:name)
        #                     .end_before(1000000, "New York City")
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        # @example Ending a query before a DocumentSnapshot
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Get a document snapshot
        #   nyc_snap = firestore.doc("cities/NYC").get
        #
        #   # Create a query
        #   query = cities_col.order(:population, :desc)
        #                     .order(:name)
        #                     .end_before(nyc_snap)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def end_before *values
          raise ArgumentError, "must provide values" if values.empty?

          if limit_type == :last
            raise "cannot call end_before after calling limit_to_last"
          end


          new_query = @query.dup
          new_query ||= StructuredQuery.new

          cursor = values_to_cursor values, new_query
          cursor.before = true
          new_query.end_at = cursor

          Query.start new_query, parent_path, client, limit_type: limit_type
        end

        ##
        # Ends query results at a set of field values. The field values can
        # be specified explicitly as arguments, or can be specified implicitly
        # by providing a {DocumentSnapshot} object instead. The result set will
        # include the document specified by `values`.
        #
        # If the current query already has specified `end_before` or
        # `end_at`, this will overwrite it.
        #
        # The values are associated with the field paths that have been provided
        # to `order`, and must match the same sort order. An ArgumentError will
        # be raised if more explicit values are given than are present in
        # `order`.
        #
        # @param [DocumentSnapshot, Object, Array<Object>] values The field
        #   values to end the query at.
        #
        # @return [Query] New query with `end_at` called on it.
        #
        # @example Ending a query at a document reference id
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #   nyc_doc_id = "NYC"
        #
        #   # Create a query
        #   query = cities_col.order(firestore.document_id)
        #                     .end_at(nyc_doc_id)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        # @example Ending a query at a document reference object
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #   nyc_doc_id = "NYC"
        #   nyc_ref = cities_col.doc nyc_doc_id
        #
        #   # Create a query
        #   query = cities_col.order(firestore.document_id)
        #                     .end_at(nyc_ref)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        # @example Ending a query at multiple explicit values
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Create a query
        #   query = cities_col.order(:population, :desc)
        #                     .order(:name)
        #                     .end_at(1000000, "New York City")
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        # @example Ending a query at a DocumentSnapshot
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   cities_col = firestore.col "cities"
        #
        #   # Get a document snapshot
        #   nyc_snap = firestore.doc("cities/NYC").get
        #
        #   # Create a query
        #   query = cities_col.order(:population, :desc)
        #                     .order(:name)
        #                     .end_at(nyc_snap)
        #
        #   query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def end_at *values
          raise ArgumentError, "must provide values" if values.empty?

          if limit_type == :last
            raise "cannot call end_at after calling limit_to_last"
          end


          new_query = @query.dup
          new_query ||= StructuredQuery.new

          cursor = values_to_cursor values, new_query
          cursor.before = false
          new_query.end_at = cursor

          Query.start new_query, parent_path, client, limit_type: limit_type
        end

        ##
        # Retrieves document snapshots for the query.
        #
        # @param [Time] read_time Reads documents as they were at the given time.
        #   This may not be older than 270 seconds. Optional
        #
        # @yield [documents] The block for accessing the document snapshots.
        # @yieldparam [DocumentSnapshot] document A document snapshot.
        #
        # @return [Enumerator<DocumentSnapshot>] A list of document snapshots.
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
        # @example Get query with read time
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
        #   read_time = Time.now
        #
        #   query.get(read_time: read_time) do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def get read_time: nil
          ensure_service!

          return enum_for :get, read_time: read_time unless block_given?

          results = service.run_query parent_path, @query, read_time: read_time

          # Reverse the results for Query#limit_to_last queries since that method reversed the order_by directions.
          results = results.to_a.reverse if limit_type == :last

          results.each do |result|
            next if result.document.nil?
            yield DocumentSnapshot.from_query_result result, client
          end
        end
        alias run get

        ##
        # Creates an AggregateQuery object for the query.
        #
        # @return [AggregateQuery] New empty aggregate query.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Get a collection reference
        #   query = firestore.col "cities"
        #
        #   # Create an aggregate query
        #   aggregate_query = query.aggregate_query
        #
        def aggregate_query
          AggregateQuery.new self, parent_path, client
        end

        ##
        # Listen to this query for changes.
        #
        # @yield [callback] The block for accessing the query snapshot.
        # @yieldparam [QuerySnapshot] snapshot A query snapshot.
        #
        # @return [QueryListener] The ongoing listen operation on the query.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #
        #   # Create a query
        #   query = firestore.col(:cities).order(:population, :desc)
        #
        #   listener = query.listen do |snapshot|
        #     puts "The query snapshot has #{snapshot.docs.count} documents "
        #     puts "and has #{snapshot.changes.count} changes."
        #   end
        #
        #   # When ready, stop the listen operation and close the stream.
        #   listener.stop
        #
        def listen &callback
          raise ArgumentError, "callback required" if callback.nil?

          ensure_service!

          QueryListener.new(self, &callback).start
        end
        alias on_snapshot listen

        ##
        # Serializes the instance to a JSON text string. See also {Query.from_json}.
        #
        # @return [String] A JSON text string.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #   query = firestore.col(:cities).select(:population)
        #
        #   json = query.to_json
        #
        #   new_query = Google::Cloud::Firestore::Query.from_json json, firestore
        #
        #   new_query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def to_json options = nil
          query_json = Google::Cloud::Firestore::V1::StructuredQuery.encode_json query
          {
            "query" => JSON.parse(query_json),
            "parent_path" => parent_path,
            "limit_type" => limit_type
          }.to_json options
        end

        ##
        # Deserializes a JSON text string serialized from this class and returns it as a new instance. See also
        # {#to_json}.
        #
        # @param [String] json A JSON text string serialized using {#to_json}.
        # @param [Google::Cloud::Firestore::Client] client A connected client instance.
        #
        # @return [Query] A new query equal to the original query used to create the JSON text string.
        #
        # @example
        #   require "google/cloud/firestore"
        #
        #   firestore = Google::Cloud::Firestore.new
        #   query = firestore.col(:cities).select(:population)
        #
        #   json = query.to_json
        #
        #   new_query = Google::Cloud::Firestore::Query.from_json json, firestore
        #
        #   new_query.get do |city|
        #     puts "#{city.document_id} has #{city[:population]} residents."
        #   end
        #
        def self.from_json json, client
          raise ArgumentError, "client is required" unless client

          json = JSON.parse json
          query_json = json["query"]
          raise ArgumentError, "Field 'query' is required" unless query_json
          query = Google::Cloud::Firestore::V1::StructuredQuery.decode_json query_json.to_json
          start query, json["parent_path"], client, limit_type: json["limit_type"]&.to_sym
        end

        ##
        # @private Start a new Query.
        def self.start query, parent_path, client, limit_type: nil
          new query, parent_path, client, limit_type: limit_type
        end

        protected

        ##
        # @private
        StructuredQuery = Google::Cloud::Firestore::V1::StructuredQuery

        ##
        # @private
        INEQUALITY_FILTERS = [
          :LESS_THAN,
          :LESS_THAN_OR_EQUAL,
          :GREATER_THAN,
          :GREATER_THAN_OR_EQUAL
        ].freeze

        def value_nil? value
          [nil, :null, :nil].include? value
        end

        def value_nan? value
          # Comparing NaN values raises, so check for #nan? first.
          return true if value.respond_to?(:nan?) && value.nan?
          [:nan].include? value
        end

        def value_unary? value
          value_nil?(value) || value_nan?(value)
        end

        def composite_filter
          StructuredQuery::Filter.new(
            composite_filter: StructuredQuery::CompositeFilter.new(op: :AND)
          )
        end

        def add_filters_to_query query, filter
          if query.where.nil?
            query.where = filter
          elsif query.where.filter_type == :composite_filter
            query.where.composite_filter.filters << filter
          else
            old_filter = query.where
            query.where = composite_filter
            query.where.composite_filter.filters << old_filter
            query.where.composite_filter.filters << filter
          end
        end

        def order_direction direction
          return :DESCENDING if direction.to_s.downcase.start_with? "d"
          :ASCENDING
        end

        def query_has_cursors?
          query.start_at || query.end_at
        end

        def values_to_cursor values, query
          if values.count == 1 && values.first.is_a?(DocumentSnapshot)
            return snapshot_to_cursor values.first, query
          end

          # The *values param in start_at, start_after, etc. will wrap an array argument in an array, so unwrap it here.
          values = values.first if values.count == 1 && values.first.is_a?(Array)

          # pair values with their field_paths to ensure correct formatting
          order_field_paths = order_by_field_paths query
          if values.count > order_field_paths.count
            # raise if too many values provided for the cursor
            raise ArgumentError, "There cannot be more cursor values than order by fields"
          end

          values = values.zip(order_field_paths).map do |value, field_path|
            if field_path == doc_id_path && !value.is_a?(DocumentReference)
              value = document_reference value
            end
            Convert.raw_to_value value
          end

          Google::Cloud::Firestore::V1::Cursor.new values: values
        end

        def snapshot_to_cursor snapshot, query
          if snapshot.parent.path != query_collection_path
            raise ArgumentError, "cursor snapshot must belong to collection"
          end

          # first, add any inequality filters missing from existing order_by
          ensure_inequality_field_paths_in_order_by! query

          # second, make sure __name__ is present in order_by
          ensure_document_id_in_order_by! query

          # lastly, create cursor for all field_paths in order_by
          values = order_by_field_paths(query).map do |field_path|
            if field_path == doc_id_path
              snapshot.ref
            else
              snapshot[field_path]
            end
          end
          values_to_cursor values, query
        end

        def ensure_inequality_field_paths_in_order_by! query
          inequality_paths = inequality_filter_field_paths query
          orig_order = order_by_field_paths query

          inequality_paths.reverse_each do |field_path|
            next if orig_order.include? field_path

            query.order_by.unshift StructuredQuery::Order.new(
              field:     StructuredQuery::FieldReference.new(
                field_path: field_path
              ),
              direction: :ASCENDING
            )
          end
        end

        def ensure_document_id_in_order_by! query
          return if order_by_field_paths(query).include? doc_id_path

          query.order_by.push StructuredQuery::Order.new(
            field:     StructuredQuery::FieldReference.new(
              field_path: doc_id_path
            ),
            direction: last_order_direction(query)
          )
        end

        def inequality_filter_field_paths query
          return [] if query.where.nil?

          # The way we construct a query, where is always a CompositeFilter
          filters = if query.where.filter_type == :composite_filter
                      query.where.composite_filter.filters
                    else
                      [query.where]
                    end
          ineq_filters = filters.select do |filter|
            if filter.filter_type == :field_filter
              INEQUALITY_FILTERS.include? filter.field_filter.op
            end
          end
          ineq_filters.map { |filter| filter.field_filter.field.field_path }
        end

        def order_by_field_paths query
          query.order_by.map { |order_by| order_by.field.field_path }
        end

        def last_order_direction query
          last_order_by = query.order_by.last
          return :ASCENDING if last_order_by.nil?
          last_order_by.direction
        end

        def document_reference document_path
          if document_path.to_s.split("/").count.even?
            raise ArgumentError, "document_path must refer to a document"
          end

          DocumentReference.from_path(
            "#{query_collection_path}/#{document_path}", client
          )
        end

        def query_collection_path
          "#{parent_path}/#{query_collection_id}"
        end

        def query_collection_id
          # We trust that query.from is always set, since Query cannot be
          # created without it.
          return nil if query.from.empty?
          query.from.first.collection_id
        end

        def doc_id_path
          "__name__".freeze
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
