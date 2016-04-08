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
    # @see https://cloud.google.com/datastore/docs/concepts/queries Datastore
    #   Queries
    # @see https://cloud.google.com/datastore/docs/concepts/metadataqueries
    #   Datastore Metadata
    #
    # @example
    #   query = Gcloud::Datastore::Query.new
    #   query.kind("Task").
    #     where("done", "=", false).
    #     where("priority", ">=", 4).
    #     order("priority", :desc)
    #
    #   tasks = datastore.run query
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
      # Special entity kinds such as `__namespace__`, `__kind__`, and
      # `__property__` can be used for [metadata
      # queries](https://cloud.google.com/datastore/docs/concepts/metadataqueries).
      #
      # @example
      #   query = Gcloud::Datastore::Query.new
      #   query.kind "Task"
      #
      #   tasks = datastore.run query
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
      #     where("done", "=", false)
      #
      #   tasks = datastore.run query
      #
      # @example Add a composite property filter:
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     where("done", "=", false).
      #     where("priority", ">=", 4)
      #
      #   tasks = datastore.run query
      #
      # @example Add an inequality filter on a **single** property only:
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     where("created", ">=", Date.new(1990,1,1)).
      #     where("created", "<", Date.new(2000,1,1))
      #
      # @example Add a composite filter on an array property:
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     where("tag", "=", "fun").
      #     where("tag", "=", "programming")
      #
      #   tasks = datastore.run query
      #
      # @example Add an inequality filter on an array property :
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     where("tag", ">", "learn").
      #     where("tag", "<", "math")
      #
      #   tasks = datastore.run query
      #
      # @example Add a key filter using the special property `__key__`:
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     where("__key__", ">", datastore.key("Task", "someTask"))
      #
      #   tasks = datastore.run query
      #
      # @example Add a key filter to a *kindless* query:
      #   query = Gcloud::Datastore::Query.new
      #   query.where("__key__", ">", last_seen_key)
      #
      #   tasks = datastore.run query
      #
      def where name, operator, value
        @grpc.filter ||= Google::Datastore::V1beta3::Filter.new(
          composite_filter: Google::Datastore::V1beta3::CompositeFilter.new(
            op: :AND
          )
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
      #   task_list_key = datastore.key "TaskList", "default"
      #
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     ancestor(task_list_key)
      #
      #   tasks = datastore.run query
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
      # @example With ascending sort order:
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     order("created")
      #
      #   tasks = datastore.run query
      #
      # @example With descending sort order:
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     order("created", :desc)
      #
      #   tasks = datastore.run query
      #
      # @example With multiple sort orders:
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     order("priority", :desc).
      #     order("created")
      #
      #   tasks = datastore.run query
      #
      # @example A property used in an inequality filter must be ordered first:
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     where("priority", ">", 3).
      #     order("priority").
      #     order("created")
      #
      #   tasks = datastore.run query
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
      #     limit(5)
      #
      #   tasks = datastore.run query
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
      #     limit(5).
      #     offset(10)
      #
      #   tasks = datastore.run query
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
      #     limit(page_size).
      #     start(page_cursor)
      #
      #   tasks = datastore.run query
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
      #     select("priority", "percent_complete")
      #
      #   priorities = []
      #   percent_completes = []
      #   datastore.run(query).each do |task|
      #     priorities << task["priority"]
      #     percent_completes << task["percent_complete"]
      #   end
      #
      # @example A keys-only query using the special property `__key__`:
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     select("__key__")
      #
      #   keys = datastore.run(query).map &:key
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
      #     group_by("type", "priority").
      #     order("type").
      #     order("priority")
      #
      #   tasks = datastore.run query
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
