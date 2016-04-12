# Copyright 2016 Google Inc. All rights reserved.
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


require "gcloud/datastore/entity"
require "gcloud/datastore/key"

module Gcloud
  module Datastore
    ##
    # # Query
    #
    # Represents a GQL query against a Datastore.
    #
    # @see https://cloud.google.com/datastore/docs/apis/gql/gql_reference GQL
    #   Reference
    #
    # @example
    #   gql = Gcloud::Datastore::GqlQuery.new
    #   gql.query_string = "SELECT * FROM Task WHERE done = @done"
    #   gql.named_bindings = {done: false}
    #   tasks = dataset.run gql
    #
    class GqlQuery
      ##
      # Returns a new gql object.
      #
      # @example
      #   gql = Gcloud::Datastore::GqlQuery.new
      #
      def initialize
        @grpc = Google::Datastore::V1beta3::GqlQuery.new
      end

      def query_string
        gql = @grpc.query_string.dup
        gql.freeze
        gql
      end

      def query_string= new_query_string
        @grpc.query_string = new_query_string.to_s
      end

      def allow_literals
        @grpc.allow_literals
      end

      def allow_literals= new_allow_literals
        @grpc.allow_literals = new_allow_literals
      end

      def named_bindings
        bindings = Hash[@grpc.named_bindings.map do |name, gql_query_param|
          if gql_query_param.cursor
            [name, Cursor.from_grpc(gql_query_param.cursor)]
          else
            [name, GRPCUtils.from_value(gql_query_param.value)]
          end
        end]
        bindings.freeze
        bindings
      end

      def named_bindings= new_named_bindings
        @grpc.named_bindings.clear
        new_named_bindings.map do |name, value|
          if value.is_a? Gcloud::Datastore::Cursor
            @grpc.named_bindings[name.to_s] = \
              Google::Datastore::V1beta3::GqlQueryParameter.new(
                cursor: value.to_grpc)
          else
            @grpc.named_bindings[name.to_s] = \
              Google::Datastore::V1beta3::GqlQueryParameter.new(
                value: GRPCUtils.to_value(value))
          end
        end
      end

      def positional_bindings
        bindings = @grpc.positional_bindings.map do |gql_query_param|
          if gql_query_param.cursor
            Cursor.from_grpc gql_query_param.cursor
          else
            GRPCUtils.from_value gql_query_param.value
          end
        end
        bindings.freeze
        bindings
      end

      def positional_bindings= new_positional_bindings
        @grpc.positional_bindings.clear
        new_positional_bindings.map do |value|
          if value.is_a? Gcloud::Datastore::Cursor
            @grpc.positional_bindings << \
              Google::Datastore::V1beta3::GqlQueryParameter.new(
                cursor: value.to_grpc)
          else
            @grpc.positional_bindings << \
              Google::Datastore::V1beta3::GqlQueryParameter.new(
                value: GRPCUtils.to_value(value))
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
