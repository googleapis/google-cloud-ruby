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
require "gcloud/datastore/proto"

module Gcloud
  module Datastore
    ##
    # Query represents a query to be made to the Datastore.
    #
    #   query = Gcloud::Datastore::Query.new
    #   query.kind("Task").
    #     where("completed", "=", true)
    #
    #   entities = dataset.run query
    class Query
      ##
      # Returns a new query object.
      #
      #   query = Gcloud::Datastore::Query.new
      def initialize
        @_query = Proto::Query.new
      end

      ##
      # Add the kind of entities to query.
      #
      #   query = Gcloud::Datastore::Query.new
      #   query.kind "Task"
      #
      #   all_tasks = dataset.run query
      def kind *kinds
        @_query.kind ||= Proto::KindExpression.new
        @_query.kind.name ||= []
        @_query.kind.name |= kinds
        self
      end

      ##
      # Add a property filter to the query.
      #
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     where("completed", "=", true)
      #
      #   completed_tasks = dataset.run query
      def where name, operator, value
        # Initialize filter
        @_query.filter ||= Proto.new_filter.tap do |f|
          f.composite_filter = Proto.new_composite_filter
        end
        # Create new property filter
        filter = Proto.new_filter.tap do |f|
          f.property_filter = Proto.new_property_filter name, operator, value
        end
        # Add new property filter to the list
        @_query.filter.composite_filter.filter << filter
        self
      end
      alias_method :filter, :where

      ##
      # Add a filter for entities that inherit from a key.
      #
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     ancestor(parent.key)
      #
      #   completed_tasks = dataset.run query
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
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     order("due", :desc)
      #
      #   sorted_tasks = dataset.run query
      def order name, direction = :asc
        @_query.order ||= []
        po = Proto::PropertyOrder.new
        po.property = Proto::PropertyReference.new
        po.property.name = name
        po.direction = Proto.to_prop_order_direction direction
        @_query.order << po
        self
      end

      ##
      # Set a limit on the number of results to be returned.
      #
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     limit(10)
      #
      #   paginated_tasks = dataset.run query
      def limit num
        @_query.limit = num
        self
      end

      ##
      # Set an offset for the results to be returned.
      #
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     limit(10).
      #     offset(20)
      #
      #   paginated_tasks = dataset.run query
      def offset num
        @_query.offset = num
        self
      end

      ##
      # Set the cursor to start the results at.
      #
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     limit(10).
      #     cursor(task_cursor)
      #
      #   paginated_tasks = dataset.run query
      def start cursor
        @_query.start_cursor = Proto.decode_cursor cursor
        self
      end
      alias_method :cursor, :start

      ##
      # Retrieve only select properties from the matched entities.
      #
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     select("completed", "due")
      #
      #   partial_tasks = dataset.run query
      def select *names
        @_query.projection ||= []
        @_query.projection += Proto.new_property_expressions(*names)
        self
      end
      alias_method :projection, :select

      ##
      # Group results by a list of properties.
      #
      #   query = Gcloud::Datastore::Query.new
      #   query.kind("Task").
      #     group_by("completed")
      #
      #   grouped_tasks = dataset.run query
      def group_by *names
        @_query.group_by ||= []
        @_query.group_by += Proto.new_property_references(*names)
        self
      end

      def to_proto #:nodoc:
        # Disabled rubocop because this implementation will most likely change.
        @_query
      end
    end
  end
end
