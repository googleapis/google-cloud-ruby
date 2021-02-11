# Copyright 2021 Google LLC
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


require "google/cloud/pubsub/schema/list"
require "google/cloud/pubsub/v1"

module Google
  module Cloud
    module PubSub
      ##
      # # Schema
      #
      # A schema resource.
      #
      # @example
      #   require "google/cloud/pubsub"
      #
      #   pubsub = Google::Cloud::PubSub.new
      #
      #   schema = pubsub.schema "my-schema"
      #   schema.name #=> "projects/my-project/schemas/my-schema"
      #   schema.type #=> :PROTOCOL_BUFFER
      #
      class Schema
        ##
        # @private The Service object.
        attr_accessor :service

        ##
        # @private The gRPC Google::Cloud::PubSub::V1::Schema object.
        attr_accessor :grpc

        ##
        # @private Create an empty {Schema} object.
        def initialize
          @service = nil
          @grpc = Google::Cloud::PubSub::V1::Schema.new
        end

        ##
        # The name of the schema.
        #
        # @return [String] A fully-qualified schema name in the form `projects/{project_id}/schemas/{schema_id}`.
        #
        def name
          @grpc.name
        end

        ##
        # The type of the schema. Possible values include:
        #
        #   * `PROTOCOL_BUFFER` - A Protocol Buffer schema definition.
        #   * `AVRO` - An Avro schema definition.
        #
        # @return [String] The upper-case type name.
        #
        def type
          @grpc.type
        end

        ##
        # The definition of the schema. This should be a string representing the full definition of the schema that is a
        # valid schema definition of the type specified in {#type}.
        #
        # @return [String] The schema definition.
        #
        def definition
          @grpc.definition
        end

        ##
        # Removes an existing schema.
        #
        # @return [Boolean] Returns `true` if the schema was deleted.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #   schema = pubsub.schema "my-schema"
        #
        #   schema.delete
        #
        def delete
          ensure_service!
          service.delete_schema name
          true
        end

        ##
        # @private New Schema from a Google::Cloud::PubSub::V1::Schema object.
        def self.from_grpc grpc, service
          new.tap do |f|
            f.grpc = grpc
            f.service = service
          end
        end

        ##
        # @private New reference Schema object without making an HTTP request.
        def self.from_name name, service, options = {}
          grpc = Google::Cloud::PubSub::V1::Schema.new name: service.schema_path(name, options)
          from_grpc grpc, service
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
