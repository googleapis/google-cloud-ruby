# Copyright 2014 Google LLC
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
      #   require "google/cloud/datastore"
      #
      #   datastore = Google::Cloud::Datastore.new
      #
      #   query = Google::Cloud::Datastore::Query.new
      #   query.kind("Task").
      #     where("done", "=", false).
      #     where("priority", ">=", 4).
      #     order("priority", :desc)
      #
      #   tasks = datastore.run query
      #
      # @example Run the query within a namespace with the `namespace` option:
      #   require "google/cloud/datastore"
      #
      #   datastore = Google::Cloud::Datastore.new
      #
      #   query = datastore.query("Task").
      #     where("done", "=", false)
      #   tasks = datastore.run query, namespace: "example-ns"
      #
      class Query
        ##
        # Returns a new query object.
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   query = Google::Cloud::Datastore::Query.new
        #
        def initialize
          @grpc = Google::Datastore::V1::Query.new
        end

        ##
        # Add the kind of entities to query.
        #
        # Special entity kinds such as `__namespace__`, `__kind__`, and
        # `__property__` can be used for [metadata
        # queries](https://cloud.google.com/datastore/docs/concepts/metadataqueries).
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = Google::Cloud::Datastore::Query.new
        #   query.kind "Task"
        #
        #   tasks = datastore.run query
        #
        def kind *kinds
          kinds.each do |kind|
            grpc_kind = Google::Datastore::V1::KindExpression.new(
              name: kind
            )
            @grpc.kind << grpc_kind
          end

          self
        end

        ##
        # Add a property filter to the query.
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = Google::Cloud::Datastore::Query.new
        #   query.kind("Task").
        #     where("done", "=", false)
        #
        #   tasks = datastore.run query
        #
        # @example Add a composite property filter:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = Google::Cloud::Datastore::Query.new
        #   query.kind("Task").
        #     where("done", "=", false).
        #     where("priority", ">=", 4)
        #
        #   tasks = datastore.run query
        #
        # @example Add an inequality filter on a **single** property only:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = Google::Cloud::Datastore::Query.new
        #   query.kind("Task").
        #     where("created", ">=", Time.utc(1990, 1, 1)).
        #     where("created", "<", Time.utc(2000, 1, 1))
        #
        #   tasks = datastore.run query
        #
        # @example Add a composite filter on an array property:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = Google::Cloud::Datastore::Query.new
        #   query.kind("Task").
        #     where("tag", "=", "fun").
        #     where("tag", "=", "programming")
        #
        #   tasks = datastore.run query
        #
        # @example Add an inequality filter on an array property :
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = Google::Cloud::Datastore::Query.new
        #   query.kind("Task").
        #     where("tag", ">", "learn").
        #     where("tag", "<", "math")
        #
        #   tasks = datastore.run query
        #
        # @example Add a key filter using the special property `__key__`:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = Google::Cloud::Datastore::Query.new
        #   query.kind("Task").
        #     where("__key__", ">", datastore.key("Task", "someTask"))
        #
        #   tasks = datastore.run query
        #
        # @example Add a key filter to a *kindless* query:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   last_seen_key = datastore.key "Task", "a"
        #   query = Google::Cloud::Datastore::Query.new
        #   query.where("__key__", ">", last_seen_key)
        #
        #   tasks = datastore.run query
        #
        def where name, operator, value
          @grpc.filter ||= Google::Datastore::V1::Filter.new(
            composite_filter: Google::Datastore::V1::CompositeFilter.new(
              op: :AND
            )
          )
          @grpc.filter.composite_filter.filters << \
            Google::Datastore::V1::Filter.new(
              property_filter: Google::Datastore::V1::PropertyFilter.new(
                property: Google::Datastore::V1::PropertyReference.new(
                  name: name
                ),
                op: Convert.to_prop_filter_op(operator),
                value: Convert.to_value(value)
              )
            )

          self
        end
        alias filter where

        ##
        # Add a filter for entities that inherit from a key.
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   task_list_key = datastore.key "TaskList", "default"
        #
        #   query = Google::Cloud::Datastore::Query.new
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
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = Google::Cloud::Datastore::Query.new
        #   query.kind("Task").
        #     order("created")
        #
        #   tasks = datastore.run query
        #
        # @example With descending sort order:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = Google::Cloud::Datastore::Query.new
        #   query.kind("Task").
        #     order("created", :desc)
        #
        #   tasks = datastore.run query
        #
        # @example With multiple sort orders:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = Google::Cloud::Datastore::Query.new
        #   query.kind("Task").
        #     order("priority", :desc).
        #     order("created")
        #
        #   tasks = datastore.run query
        #
        # @example A property used in inequality filter must be ordered first:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = Google::Cloud::Datastore::Query.new
        #   query.kind("Task").
        #     where("priority", ">", 3).
        #     order("priority").
        #     order("created")
        #
        #   tasks = datastore.run query
        #
        def order name, direction = :asc
          @grpc.order << Google::Datastore::V1::PropertyOrder.new(
            property: Google::Datastore::V1::PropertyReference.new(
              name: name
            ),
            direction: prop_order_direction(direction)
          )

          self
        end

        ##
        # Set a limit on the number of results to be returned.
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = Google::Cloud::Datastore::Query.new
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
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = Google::Cloud::Datastore::Query.new
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
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = Google::Cloud::Datastore::Query.new
        #   query.kind("Task").
        #     limit(page_size).
        #     start(page_cursor)
        #
        #   tasks = datastore.run query
        #
        def start cursor
          if cursor.is_a? Cursor
            @grpc.start_cursor = cursor.to_grpc
          elsif cursor.is_a? String
            @grpc.start_cursor = Convert.decode_bytes cursor
          else
            raise ArgumentError, "Can't set a cursor using a #{cursor.class}."
          end

          self
        end
        alias cursor start

        ##
        # Retrieve only select properties from the matched entities.
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = Google::Cloud::Datastore::Query.new
        #   query.kind("Task").
        #     select("priority", "percent_complete")
        #
        #   priorities = []
        #   percent_completes = []
        #   datastore.run(query).each do |t|
        #     priorities << t["priority"]
        #     percent_completes << t["percent_complete"]
        #   end
        #
        # @example A keys-only query using the special property `__key__`:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = Google::Cloud::Datastore::Query.new
        #   query.kind("Task").
        #     select("__key__")
        #
        #   keys = datastore.run(query).map(&:key)
        #
        def select *names
          names.each do |name|
            grpc_projection = Google::Datastore::V1::Projection.new(
              property: Google::Datastore::V1::PropertyReference.new(
                name: name
              )
            )
            @grpc.projection << grpc_projection
          end

          self
        end
        alias projection select

        ##
        # Group results by a list of properties.
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = Google::Cloud::Datastore::Query.new
        #   query.kind("Task").
        #     distinct_on("type", "priority").
        #     order("type").
        #     order("priority")
        #
        #   tasks = datastore.run query
        #
        def group_by *names
          names.each do |name|
            grpc_property = Google::Datastore::V1::PropertyReference.new(
              name: name
            )
            @grpc.distinct_on << grpc_property
          end

          self
        end
        alias distinct_on group_by

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
end
