# Copyright 2016 Google LLC
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


require "google/cloud/datastore/entity"
require "google/cloud/datastore/key"

module Google
  module Cloud
    module Datastore
      ##
      # # GqlQuery
      #
      # Represents a GQL query.
      #
      # GQL is a SQL-like language for retrieving entities or keys from
      # Datastore.
      #
      # @see https://cloud.google.com/datastore/docs/apis/gql/gql_reference GQL
      #   Reference
      #
      # @example
      #   require "google/cloud/datastore"
      #
      #   datastore = Google::Cloud::Datastore.new
      #
      #   gql_query = Google::Cloud::Datastore::GqlQuery.new
      #   gql_query.query_string = "SELECT * FROM Task ORDER BY created ASC"
      #   tasks = datastore.run gql_query
      #
      class GqlQuery
        ##
        # Returns a new GqlQuery instance.
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   gql_query = Google::Cloud::Datastore::GqlQuery.new
        #
        def initialize
          @grpc = Google::Datastore::V1::GqlQuery.new
        end

        ##
        # The GQL query string for the query. The string may contain named or
        # positional argument binding sites that start with `@`. Corresponding
        # binding values should be set with {#named_bindings=} or
        # {#positional_bindings=}.
        #
        # @return [String] a GQL statement
        #
        def query_string
          gql = @grpc.query_string.dup
          gql.freeze
          gql
        end

        ##
        # Sets the GQL query string for the query. The string may contain named
        # or positional argument binding sites that start with `@`.
        # Corresponding binding values should be set with {#named_bindings=} or
        # {#positional_bindings=}.
        #
        # See the [GQL
        # Reference](https://cloud.google.com/datastore/docs/apis/gql/gql_reference).
        #
        # @param [String] new_query_string a valid GQL statement
        #
        # @example
        #   gql_query = Google::Cloud::Datastore::GqlQuery.new
        #   gql_query.query_string = "SELECT * FROM Task " \
        #                            "WHERE done = @done " \
        #                            "AND priority = @priority"
        #   gql_query.named_bindings = {done: false, priority: 4}
        #
        def query_string= new_query_string
          @grpc.query_string = new_query_string.to_s
        end

        ##
        # Whether the query may contain literal values. When false, the query
        # string must not contain any literals and instead must bind all values
        # using {#named_bindings=} or {#positional_bindings=}.
        #
        # @return [Boolean] `true` if the query may contain literal values
        #
        def allow_literals
          @grpc.allow_literals
        end

        ##
        # Sets whether the query may contain literal values. When false, the
        # query string must not contain any literals and instead must bind all
        # values using {#named_bindings=} or {#positional_bindings=}.
        #
        # @param [Boolean] new_allow_literals `true` if the query may contain
        #   literal values
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   gql_query = Google::Cloud::Datastore::GqlQuery.new
        #   gql_query.query_string = "SELECT * FROM Task " \
        #                            "WHERE completed = false AND priority = 4"
        #   gql_query.allow_literals = true
        #
        def allow_literals= new_allow_literals
          @grpc.allow_literals = new_allow_literals
        end

        ##
        # The named binding values for a query that contains named argument
        # binding sites that start with `@`.
        #
        # @return [Hash] a frozen hash that maps the binding site names in the
        #   query string to valid GQL arguments
        #
        def named_bindings
          bindings = Hash[@grpc.named_bindings.map do |name, gql_query_param|
            if gql_query_param.parameter_type == :cursor
              [name, Cursor.from_grpc(gql_query_param.cursor)]
            else
              [name, Convert.from_value(gql_query_param.value)]
            end
          end]
          bindings.freeze
          bindings
        end

        ##
        # Sets named binding values for a query that contains named argument
        # binding sites that start with `@`.
        #
        # @param [Hash] new_named_bindings a hash that maps the binding site
        #   names in the query string to valid GQL arguments
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   gql_query = Google::Cloud::Datastore::GqlQuery.new
        #   gql_query.query_string = "SELECT * FROM Task " \
        #                            "WHERE done = @done " \
        #                            "AND priority = @priority"
        #   gql_query.named_bindings = {done: false, priority: 4}
        #
        def named_bindings= new_named_bindings
          @grpc.named_bindings.clear
          new_named_bindings.map do |name, value|
            if value.is_a? Google::Cloud::Datastore::Cursor
              @grpc.named_bindings[name.to_s] = \
                Google::Datastore::V1::GqlQueryParameter.new(
                  cursor: value.to_grpc
                )
            else
              @grpc.named_bindings[name.to_s] = \
                Google::Datastore::V1::GqlQueryParameter.new(
                  value: Convert.to_value(value)
                )
            end
          end
        end

        ##
        # The binding values for a query that contains numbered argument binding
        # sites that start with `@`.
        #
        # @return [Array] a frozen array containing the query arguments in the
        #   order of the numbered binding sites in the query string
        #
        def positional_bindings
          bindings = @grpc.positional_bindings.map do |gql_query_param|
            if gql_query_param.parameter_type == :cursor
              Cursor.from_grpc gql_query_param.cursor
            else
              Convert.from_value gql_query_param.value
            end
          end
          bindings.freeze
          bindings
        end

        ##
        # Sets the binding values for a query that contains numbered argument
        # binding sites that start with `@`.
        #
        # @param [Array] new_positional_bindings query arguments in the order
        #   of the numbered binding sites in the query string
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   gql_query = Google::Cloud::Datastore::GqlQuery.new
        #   gql_query.query_string = "SELECT * FROM Task" \
        #                            "WHERE completed = @1 AND priority = @2"
        #   gql_query.positional_bindings = [false, 4]
        #
        def positional_bindings= new_positional_bindings
          @grpc.positional_bindings.clear
          new_positional_bindings.map do |value|
            if value.is_a? Google::Cloud::Datastore::Cursor
              @grpc.positional_bindings << \
                Google::Datastore::V1::GqlQueryParameter.new(
                  cursor: value.to_grpc
                )
            else
              @grpc.positional_bindings << \
                Google::Datastore::V1::GqlQueryParameter.new(
                  value: Convert.to_value(value)
                )
            end
          end
        end

        # @private
        def to_grpc
          @grpc
        end
      end
    end
  end
end
