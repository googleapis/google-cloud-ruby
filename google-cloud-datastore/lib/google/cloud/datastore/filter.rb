require "google/cloud/datastore/v1"

module Google
  module Cloud
    module Datastore
      class Filter
        ##
        # @private Object of type
        # Google::Cloud::Datastore::V1::Filter
        attr_accessor :filter

        ##
        # @private Creates a new Filter.
        def initialize name_or_filter, operator = nil, value = nil
          if name_or_filter.is_a? Google::Cloud::Datastore::V1::Filter
            @filter = name_or_filter
          else
            @filter = create_property_filter(name_or_filter, operator, value)
          end
        end

        def and *args
          combine_filters composite_filter_and, args
        end

        def or *args
          combine_filters composite_filter_or, args
        end

        private

        def combine_filters(composite_filter, args)
          composite_filter.composite_filter.filters << filter
          if args[0].is_a? Google::Cloud::Datastore::Filter
            args.each do |f|
              composite_filter.composite_filter.filters << f.filter
            end
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
