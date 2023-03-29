# Copyright 2023 Google LLC
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

require "google/cloud/datastore/v1"

module Google
  module Cloud
    module Datastore
      ##
      # Filter
      #
      # Represents the filter criteria for a datastore query.
      #
      # @example Run a query with a simple property filter.
      #   require "google/cloud/datastore"
      #
      #   datastore = Google::Cloud::Datastore.new
      #
      #   filter = Google::Cloud::Datastore::Filter.new("done", "=", "false")
      #
      #   query = Google::Cloud::Datastore::Query.new
      #   query.kind("Task")
      #        .where(filter)
      #
      #   tasks = datastore.run query
      #
      # @example Construct a composite filter with a logical OR.
      #   require "google/cloud/datastore"
      #
      #   datastore = Google::Cloud::Datastore.new
      #
      #   filter = Google::Cloud::Datastore::Filter.new("done", "=", "false")
      #                                            .or("priority", ">=", "4")
      #
      #   query = Google::Cloud::Datastore::Query.new
      #   query.kind("Task")
      #        .where(filter)
      #
      #   tasks = datastore.run query
      #
      # @example Construct a composite filter by combining multiple filters.
      #   require "google/cloud/datastore"
      #
      #   datastore = Google::Cloud::Datastore.new
      #
      #   filter_1 = Google::Cloud::Datastore::Filter.new("done", "=", "false")
      #   filter_2 = Google::Cloud::Datastore::Filter.new("priority", ">=", "4")
      #   filter = filter_1.or(filter_2)
      #
      #   query = Google::Cloud::Datastore::Query.new
      #   query.kind("Task")
      #        .where(filter)
      #
      #   tasks = datastore.run query
      #
      class Filter
        ##
        # @private Object of type
        # Google::Cloud::Datastore::V1::Filter
        attr_accessor :grpc

        ##
        # Creates a new Filter.
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   filter = Google::Cloud::Datastore::Filter.new("done", "=", "false")
        #
        def initialize name, operator, value
          @grpc = create_property_filter name, operator, value
        end

        ##
        # Joins two filters with an AND operator.
        #
        # @overload and(name, operator, value)
        #   Joins the filter with a property filter
        #   @param name [String]
        #   @param operator [String]
        #   @param value
        #
        # @overload and(filter)
        #   Joins the filter with a Filter object
        #   @param flter [Filter]
        #
        # @example Join the filter with a property filter
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   filter = Google::Cloud::Filter.new("done", "=", false)
        #                                 .and("priority", ">=", 4)
        #
        # @example Join the filter with a filter object
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   filter_1 = Google::Cloud::Filter.new("done", "=", false)
        #   filter_2 = Google::Cloud::Filter.new("priority", ">=", 4)
        #
        #   filter = filter_1.and(filter_2)
        #
        def and name_or_filter, operator = nil, value = nil
          combine_filters composite_filter_and, name_or_filter, operator, value
        end

        ##
        # Joins two filters with an OR operator.
        #
        # @overload or(name, operator, value)
        #   Joins the filter with a property filter
        #   @param name [String]
        #   @param operator [String]
        #   @param value
        #
        # @overload or(filter)
        #   Joins the filter with a Filter object
        #   @param flter [Filter]
        #
        # @example Join the filter with a property filter
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   filter = Google::Cloud::Filter.new("done", "=", false)
        #                                 .or("priority", ">=", 4)
        #
        # @example Join the filter with a filter object
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   filter_1 = Google::Cloud::Filter.new("done", "=", false)
        #   filter_2 = Google::Cloud::Filter.new("priority", ">=", 4)
        #
        #   filter = filter_1.or(filter_2)
        #
        def or name_or_filter, operator = nil, value = nil
          combine_filters composite_filter_or, name_or_filter, operator, value
        end

        # @private
        def to_grpc
          @grpc
        end

        private

        def combine_filters composite_filter, name_or_filter, operator, value
          composite_filter.composite_filter.filters << to_grpc
          composite_filter.composite_filter.filters << if name_or_filter.is_a? Google::Cloud::Datastore::Filter
                                                         name_or_filter.to_grpc
                                                       else
                                                         create_property_filter name_or_filter, operator, value
                                                       end
          self.class.new("", "", "").tap do |f|
            f.grpc = composite_filter
          end
        end

        def composite_filter_and
          Google::Cloud::Datastore::V1::Filter.new(
            composite_filter: Google::Cloud::Datastore::V1::CompositeFilter.new(op: :AND)
          )
        end

        def composite_filter_or
          Google::Cloud::Datastore::V1::Filter.new(
            composite_filter: Google::Cloud::Datastore::V1::CompositeFilter.new(op: :OR)
          )
        end

        def create_property_filter name, operator, value
          Google::Cloud::Datastore::V1::Filter.new(
            property_filter: Google::Cloud::Datastore::V1::PropertyFilter.new(
              property: Google::Cloud::Datastore::V1::PropertyReference.new(
                name: name
              ),
              op: Convert.to_prop_filter_op(operator),
              value: Convert.to_value(value)
            )
          )
        end
      end
    end
  end
end
