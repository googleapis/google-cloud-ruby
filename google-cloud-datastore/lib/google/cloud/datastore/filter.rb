require "google/cloud/datastore/v1"

module Google
  module Cloud
    module Datastore
      class Filter
        ##
        # @private Object of type
        # Google::Cloud::Datastore::V1::Filter
        attr_reader :grpc

        ##
        # Creates a new Filter.
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   filter = Google::Cloud::Datastore::Filter.new("done", "=", "false")
        #
        #   query = Google::Cloud::Datastore::Query.new
        #   query.kind("Task")
        #        .where(filter)
        #
        #   tasks = datastore.run query
        #
        def initialize name_or_filter, operator = nil, value = nil
          @grpc = if name_or_filter.is_a? Google::Cloud::Datastore::V1::Filter
                    name_or_filter
                  else
                    create_property_filter name_or_filter, operator, value
                  end
        end

        def and *args
          combine_filters composite_filter_and, args
        end

        def or *args
          combine_filters composite_filter_or, args
        end

        def to_grpc
          @grpc
        end

        private

        def combine_filters composite_filter, args
          composite_filter.composite_filter.filters << to_grpc
          if args.all? { |arg| arg.is_a? Google::Cloud::Datastore::Filter }
            composite_filter.composite_filter.filters.concat args.map(&:to_grpc)
          else
            name, operator, value = args
            composite_filter.composite_filter.filters << create_property_filter(name, operator, value)
          end
          self.class.new composite_filter
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
