# Copyright 2014 Google Inc. All rights reserved.
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
    # Represents the search criteria against a Datastore.
    #
    # @example
    #   query = Gcloud::Datastore::Query.new
    #   query.kind("Task").
    #     where("completed", "=", true)
    #
    #   entities = dataset.run query
    #
    class Query
      ##
      # Returns a new query object.
      #
      # @example
      #   query = Gcloud::Datastore::Query.new
      #
      def initialize
        @grpc = Google::Datastore::V1beta3::Query.new
      end

      ##
      # Add the kind of entities to query.
      #
      # @example
      #   query = Gcloud::Datastore::Query.new
      #   query.kind "Task"
      #
      #   all_tasks = dataset.run query
      #
      def kind *kinds
        kinds.each do |kind|
          grpc_kind = Google::Datastore::V1beta3::KindExpression.new(name: kind)
          @grpc.kind << grpc_kind
        end

        self
      end

      ##
      # Add a property filter to the query.
      #
      # @example
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     where("completed", "=", true)
      #
      #   completed_tasks = dataset.run query
      #
      def where name, operator, value
        @grpc.filter ||= Google::Datastore::V1beta3::Filter.new(
          composite_filter: Google::Datastore::V1beta3::CompositeFilter.new
        )
        @grpc.filter.composite_filter.filters << \
          Google::Datastore::V1beta3::Filter.new(
            property_filter: Google::Datastore::V1beta3::PropertyFilter.new(
              property: Google::Datastore::V1beta3::PropertyReference.new(
                name: name),
              op: GRPCUtils.to_prop_filter_op(operator),
              value: GRPCUtils.to_value(value)
            )
          )

        self
      end
      alias_method :filter, :where

      ##
      # Add a filter for entities that inherit from a key.
      #
      # @example
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     ancestor(parent.key)
      #
      #   completed_tasks = dataset.run query
      #
      def ancestor parent
        # Use key if given an entity
        parent = parent.key if parent.respond_to? :key
        where "__key__", "~", parent
      end

      ##
      # Sort the results by a property name.
      # By default, an ascending sort order will be used.
      # To sort in descending order, provide a second argument
      # of a string or symbol that starts with "d".
      #
      # @example
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     order("due", :desc)
      #
      #   sorted_tasks = dataset.run query
      #
      def order name, direction = :asc
        @grpc.order << Google::Datastore::V1beta3::PropertyOrder.new(
          property: Google::Datastore::V1beta3::PropertyReference.new(
            name: name),
          direction: prop_order_direction(direction)
        )

        self
      end

      ##
      # Set a limit on the number of results to be returned.
      #
      # @example
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     limit(10)
      #
      #   paginated_tasks = dataset.run query
      #
      def limit num
        @grpc.limit = Google::Protobuf::Int32Value.new(value: num)

        self
      end

      ##
      # Set an offset for the results to be returned.
      #
      # @example
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     limit(10).
      #     offset(20)
      #
      #   paginated_tasks = dataset.run query
      #
      def offset num
        @grpc.offset = num

        self
      end

      ##
      # Set the cursor to start the results at.
      #
      # @example
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     limit(10).
      #     cursor(task_cursor)
      #
      #   paginated_tasks = dataset.run query
      #
      def start cursor
        @grpc.start_cursor = GRPCUtils.decode_bytes cursor

        self
      end
      alias_method :cursor, :start

      ##
      # Retrieve only select properties from the matched entities.
      #
      # @example
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     select("completed", "due")
      #
      #   partial_tasks = dataset.run query
      #
      def select *names
        names.each do |name|
          grpc_projection = Google::Datastore::V1beta3::Projection.new(
            property: Google::Datastore::V1beta3::PropertyReference.new(
              name: name))
          @grpc.projection << grpc_projection
        end

        self
      end
      alias_method :projection, :select

      ##
      # Group results by a list of properties.
      #
      # @example
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     group_by("completed")
      #
      #   grouped_tasks = dataset.run query
      #
      def group_by *names
        names.each do |name|
          grpc_property = Google::Datastore::V1beta3::PropertyReference.new(
            name: name)
          @grpc.distinct_on << grpc_property
        end

        self
      end
      alias_method :distinct_on, :group_by

      # @private
      def to_grpc
        @grpc
      end

      protected

      ##
      # @private Get the property order direction for a string.
      def prop_order_direction direction
        if direction.to_s.downcase.start_with? "a"
          :ASCENDING
        elsif direction.to_s.downcase.start_with? "d"
          :DESCENDING
        else
          :DIRECTION_UNSPECIFIED
        end
      end
    end
  end
end
