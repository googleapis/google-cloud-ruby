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
        # @private Create a new Schema instance.
        def initialize grpc, service, view: nil
          @grpc = grpc
          @service = service
          @exists = nil
          @view = view || :FULL
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
        # @return [String, nil] The upper-case type name.
        #
        def type
          return nil if reference?
          @grpc.type
        end

        ##
        # The definition of the schema. This should be a string representing the full definition of the schema that is a
        # valid schema definition of the type specified in {#type}.
        #
        # @return [String, nil] The schema definition.
        #
        def definition
          return nil if reference?
          @grpc.definition if @grpc.definition && !@grpc.definition.empty?
        end

        ##
        # The revision ID of the schema.
        #
        # @return [String] The revision id.
        # @return [nil] If this object is a reference.
        #
        def revision_id
          return nil if reference?
          @grpc.revision_id if @grpc.revision_id && !@grpc.revision_id.empty?
        end

        ##
        # Validates a message against a schema.
        #
        # @param message_data [String] Message to validate against the provided `schema_spec`.
        # @param message_encoding [Symbol, String] The encoding of the message validated against the schema. Values
        #   include:
        #
        #   * `JSON` - JSON encoding.
        #   * `BINARY` - Binary encoding, as defined by the schema type. For some schema types, binary encoding may not
        #     be available.
        #
        # @return [Boolean] Returns `true` if the message validiation succeeds, `false` otherwise.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #   schema = pubsub.schema "my-schema"
        #
        #   message_data = { "name" => "Alaska", "post_abbr" => "AK" }.to_json
        #   schema.validate_message message_data, :json
        #
        def validate_message message_data, message_encoding
          message_encoding = message_encoding.to_s.upcase
          service.validate_message message_data, message_encoding, schema_name: name
          true
        rescue Google::Cloud::InvalidArgumentError
          false
        end

        ##
        # Removes the schema, if it exists.
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
        # Reloads the schema with current data from the Pub/Sub service.
        #
        # @param view [Symbol, String, nil] The set of fields to return in the response. Possible values:
        #   * `BASIC` - Include the `name` and `type` of the schema, but not the `definition`.
        #   * `FULL` - Include all Schema object fields.
        #
        #   Optional. If not provided or `nil`, the last non-nil `view` argument to this method will be used if one has
        #   been given, othewise `FULL` will be used.
        #
        # @return [Google::Cloud::PubSub::Schema] Returns the reloaded schema.
        #
        # @example Skip retrieving the schema from the service, then load it:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #   schema = pubsub.schema "my-schema", skip_lookup: true
        #
        #   schema.reload!
        #
        # @example Use the `view` option to load the basic or full resource:
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #   schema = pubsub.schema "my-schema", view: :basic
        #   schema.resource_partial? #=> true
        #
        #   schema.reload! view: :full
        #   schema.resource_partial? #=> false
        #
        # @!group Lifecycle
        #
        def reload! view: nil
          ensure_service!
          @view = view || @view
          @grpc = service.get_schema name, @view
          @reference = nil
          @exists = nil
          self
        end
        alias refresh! reload!

        ##
        # Determines whether the schema exists in the Pub/Sub service.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   schema = pubsub.schema "my-schema"
        #   schema.exists? #=> true
        #
        def exists?
          # Always true if the object is not set as reference
          return true unless reference?
          # If we have a value, return it
          return @exists unless @exists.nil?
          ensure_grpc!
          @exists = true
        rescue Google::Cloud::NotFoundError
          @exists = false
        end

        ##
        # Commits a new schema revision to an existing schema.
        #
        # @param definition [String] The definition of the schema. This should
        #   contain a string representing the full definition of the schema that
        #   is a valid schema definition of the type specified in `type`. See
        #   https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.schemas#Schema
        #   for details.
        # @param type [String, Symbol] The type of the schema. Possible values are
        #   case-insensitive and include:
        #
        #     * `PROTOCOL_BUFFER` - A Protocol Buffer schema definition.
        #     * `AVRO` - An Avro schema definition.
        #
        # @return [Google::Cloud::PubSub::Schema]
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   schema = pubsub.schema "my-schema"
        #
        #   definition = File.read /path/to/file
        #
        #   revision_schema = schema.commit definition, type: :protocol_buffer
        #
        def commit definition, type
          type = type.to_s.upcase
          grpc = service.commit_schema name, definition, type
          Schema.from_grpc grpc, service, view: @view
        end

        ##
        # Determines whether the schema object was created without retrieving the
        # resource representation from the Pub/Sub service.
        #
        # @return [Boolean] `true` when the schema was created without a resource
        #   representation, `false` otherwise.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   schema = pubsub.schema "my-schema", skip_lookup: true
        #   schema.reference? #=> true
        #
        def reference?
          @grpc.type.nil? || @grpc.type == :TYPE_UNSPECIFIED
        end

        ##
        # Determines whether the schema object was created with a resource
        # representation from the Pub/Sub service.
        #
        # @return [Boolean] `true` when the schema was created with a resource
        #   representation, `false` otherwise.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #
        #   schema = pubsub.schema "my-schema"
        #   schema.resource? #=> true
        #
        def resource?
          !reference?
        end

        ##
        # Whether the schema was created with a partial resource representation
        # from the Pub/Sub service.
        #
        # @return [Boolean] `true` when the schema was created with a partial
        #   resource representation, `false` otherwise.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #   schema = pubsub.schema "my-schema", view: :basic
        #
        #   schema.resource_partial? #=> true
        #   schema.reload! view: :full # Loads the full resource.
        #   schema.resource_partial? #=> false
        #
        def resource_partial?
          resource? && !resource_full?
        end

        ##
        # Whether the schema was created with a full resource representation
        # from the Pub/Sub service.
        #
        # @return [Boolean] `true` when the schema was created with a full
        #   resource representation, `false` otherwise.
        #
        # @example
        #   require "google/cloud/pubsub"
        #
        #   pubsub = Google::Cloud::PubSub.new
        #   schema = pubsub.schema "my-schema"
        #
        #   schema.resource_full? #=> true
        #
        def resource_full?
          resource? && @grpc.definition && !@grpc.definition.empty?
        end

        ##
        # @private New Schema from a Google::Cloud::PubSub::V1::Schema object.
        def self.from_grpc grpc, service, view: nil
          new grpc, service, view: view
        end

        ##
        # @private New reference Schema object without making an HTTP request.
        def self.from_name name, view, service, options = {}
          grpc = Google::Cloud::PubSub::V1::Schema.new name: service.schema_path(name, options)
          from_grpc grpc, service, view: view
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is available.
        def ensure_service!
          raise "Must have active connection to service" unless service
        end

        ##
        # Ensures a Google::Cloud::PubSub::V1::Schema object exists.
        def ensure_grpc!
          ensure_service!
          reload! if reference?
        end
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
