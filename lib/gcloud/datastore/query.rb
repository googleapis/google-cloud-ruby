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

require "gcloud/proto/datastore_v1.pb"
require "gcloud/datastore/entity"
require "gcloud/datastore/key"

module Gcloud
  module Datastore
    ##
    # Datastore Query
    #
    # Represents a query to be made against the datastore.
    #
    #   query = Gcloud::Datastore::Query.new
    #   query.kind("Task").
    #     where("completed", "=", true)
    #
    #   entities = Gcloud::Datastore.connection.run query
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
      #   all_tasks = Gcloud::Datastore.connection.run query
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
      #   completed_tasks = Gcloud::Datastore.connection.run query
      def where name, operator, value
        # Initialize filter
        @_query.filter ||= Proto::Filter.new.tap do |f|
          f.composite_filter = new_composite_filter
        end
        # Create new property filter
        filter = Proto::Filter.new.tap do |f|
          f.property_filter = new_property_filter name, operator, value
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
      #   completed_tasks = Gcloud::Datastore.connection.run query
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
      #   sorted_tasks = Gcloud::Datastore.connection.run query
      def order name, direction = :asc
        @_query.order ||= []
        po = Proto::PropertyOrder.new
        po.property = Proto::PropertyReference.new
        po.property.name = name
        if direction.to_s.downcase.start_with? "d"
          po.direction = Proto::PropertyOrder::Direction::DESCENDING
        end
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
      #   paginated_tasks = Gcloud::Datastore.connection.run query
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
      #   paginated_tasks = Gcloud::Datastore.connection.run query
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
      #   paginated_tasks = Gcloud::Datastore.connection.run query
      def start cursor
        @_query.start_cursor = decode_cursor cursor
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
      #   partial_tasks = Gcloud::Datastore.connection.run query
      def select *names
        @_query.projection ||= []
        @_query.projection += new_property_expressions(*names)
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
      #   grouped_tasks = Gcloud::Datastore.connection.run query
      def group_by *names
        @_query.group_by ||= []
        @_query.group_by += new_property_references(*names)
        self
      end

      # rubocop:disable Style/TrivialAccessors
      def to_proto #:nodoc:
        # Disabled rubocop because this implementation will most likely change.
        @_query
      end
      # rubocop:enable Style/TrivialAccessors

      protected

      def new_composite_filter
        Proto::CompositeFilter.new.tap do |cf|
          cf.operator = Proto::CompositeFilter::Operator::AND
          cf.filter = []
        end
      end

      def new_property_filter name, operator, value
        Proto::PropertyFilter.new.tap do |pf|
          pf.property = new_property_reference name
          pf.operator = to_proto_operator operator
          pf.value = Property.encode value
        end
      end

      def new_property_expressions *names
        names.map do |name|
          new_property_expression name
        end
      end

      def new_property_expression name
        Proto::PropertyExpression.new.tap do |pe|
          pe.property = new_property_reference name
        end
      end

      def new_property_references *names
        names.map do |name|
          new_property_reference name
        end
      end

      def new_property_reference name
        Proto::PropertyReference.new.tap do |pr|
          pr.name = name
        end
      end

      def decode_cursor cursor
        dc = cursor.to_s.unpack("m").first.force_encoding Encoding::ASCII_8BIT
        dc = nil if dc.empty?
        dc
      end

      #:nodoc:
      OPERATORS = {
        "<"   => Proto::PropertyFilter::Operator::LESS_THAN,
        "lt"  => Proto::PropertyFilter::Operator::LESS_THAN,
        "<="  => Proto::PropertyFilter::Operator::LESS_THAN_OR_EQUAL,
        "lte" => Proto::PropertyFilter::Operator::LESS_THAN_OR_EQUAL,
        ">"   => Proto::PropertyFilter::Operator::GREATER_THAN,
        "gt"  => Proto::PropertyFilter::Operator::GREATER_THAN,
        ">="  => Proto::PropertyFilter::Operator::GREATER_THAN_OR_EQUAL,
        "gte" => Proto::PropertyFilter::Operator::GREATER_THAN_OR_EQUAL,
        "="   => Proto::PropertyFilter::Operator::EQUAL,
        "eq"  => Proto::PropertyFilter::Operator::EQUAL,
        "eql" => Proto::PropertyFilter::Operator::EQUAL,
        "~"            => Proto::PropertyFilter::Operator::HAS_ANCESTOR,
        "~>"           => Proto::PropertyFilter::Operator::HAS_ANCESTOR,
        "ancestor"     => Proto::PropertyFilter::Operator::HAS_ANCESTOR,
        "has_ancestor" => Proto::PropertyFilter::Operator::HAS_ANCESTOR,
        "has ancestor" => Proto::PropertyFilter::Operator::HAS_ANCESTOR }

      def to_proto_operator str #:nodoc:
        OPERATORS[str.to_s.downcase] || Proto::PropertyFilter::Operator::EQUAL
      end
    end
  end
end
