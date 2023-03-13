require "google/cloud/datastore/v1"

module Google
  module Cloud
    module Datastore
      class Filter

        ##
        # @private Object of type
        # Google::Cloud::Firestore::V1::StructuredQuery::Filter
        attr_accessor :filter

        ##
        # @private Creates a new Filter.
        def initialize filter
          @filter = filter
        end

        def self.create name, operator, value
          new create_filter(name, operator, value)
        end

        def self.and filter
        end

        def self.or filter
        end

        def and filter
        end

        def or filter
        end

        def self.create_filter(name, operator, value)
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