# Copyright 2017 Google LLC
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

module Google
  module Datastore
    module V1
      # A partition ID identifies a grouping of entities. The grouping is always
      # by project and namespace, however the namespace ID may be empty.
      #
      # A partition ID contains several dimensions:
      # project ID and namespace ID.
      #
      # Partition dimensions:
      #
      # * May be +""+.
      # * Must be valid UTF-8 bytes.
      # * Must have values that match regex +[A-Za-z\d\.\-_]{1,100}+
      #   If the value of any dimension matches regex +__.*__+, the partition is
      #   reserved/read-only.
      #   A reserved/read-only partition ID is forbidden in certain documented
      #   contexts.
      #
      # Foreign partition IDs (in which the project ID does
      # not match the context project ID ) are discouraged.
      # Reads and writes of foreign partition IDs may fail if the project is not in an active state.
      # @!attribute [rw] project_id
      #   @return [String]
      #     The ID of the project to which the entities belong.
      # @!attribute [rw] namespace_id
      #   @return [String]
      #     If not empty, the ID of the namespace to which the entities belong.
      class PartitionId; end

      # A unique identifier for an entity.
      # If a key's partition ID or any of its path kinds or names are
      # reserved/read-only, the key is reserved/read-only.
      # A reserved/read-only key is forbidden in certain documented contexts.
      # @!attribute [rw] partition_id
      #   @return [Google::Datastore::V1::PartitionId]
      #     Entities are partitioned into subsets, currently identified by a project
      #     ID and namespace ID.
      #     Queries are scoped to a single partition.
      # @!attribute [rw] path
      #   @return [Array<Google::Datastore::V1::Key::PathElement>]
      #     The entity path.
      #     An entity path consists of one or more elements composed of a kind and a
      #     string or numerical identifier, which identify entities. The first
      #     element identifies a _root entity_, the second element identifies
      #     a _child_ of the root entity, the third element identifies a child of the
      #     second entity, and so forth. The entities identified by all prefixes of
      #     the path are called the element's _ancestors_.
      #
      #     An entity path is always fully complete: *all* of the entity's ancestors
      #     are required to be in the path along with the entity identifier itself.
      #     The only exception is that in some documented cases, the identifier in the
      #     last path element (for the entity) itself may be omitted. For example,
      #     the last path element of the key of +Mutation.insert+ may have no
      #     identifier.
      #
      #     A path can never be empty, and a path can have at most 100 elements.
      class Key
        # A (kind, ID/name) pair used to construct a key path.
        #
        # If either name or ID is set, the element is complete.
        # If neither is set, the element is incomplete.
        # @!attribute [rw] kind
        #   @return [String]
        #     The kind of the entity.
        #     A kind matching regex +__.*__+ is reserved/read-only.
        #     A kind must not contain more than 1500 bytes when UTF-8 encoded.
        #     Cannot be +""+.
        # @!attribute [rw] id
        #   @return [Integer]
        #     The auto-allocated ID of the entity.
        #     Never equal to zero. Values less than zero are discouraged and may not
        #     be supported in the future.
        # @!attribute [rw] name
        #   @return [String]
        #     The name of the entity.
        #     A name matching regex +__.*__+ is reserved/read-only.
        #     A name must not be more than 1500 bytes when UTF-8 encoded.
        #     Cannot be +""+.
        class PathElement; end
      end

      # An array value.
      # @!attribute [rw] values
      #   @return [Array<Google::Datastore::V1::Value>]
      #     Values in the array.
      #     The order of this array may not be preserved if it contains a mix of
      #     indexed and unindexed values.
      class ArrayValue; end

      # A message that can hold any of the supported value types and associated
      # metadata.
      # @!attribute [rw] null_value
      #   @return [Google::Protobuf::NullValue]
      #     A null value.
      # @!attribute [rw] boolean_value
      #   @return [true, false]
      #     A boolean value.
      # @!attribute [rw] integer_value
      #   @return [Integer]
      #     An integer value.
      # @!attribute [rw] double_value
      #   @return [Float]
      #     A double value.
      # @!attribute [rw] timestamp_value
      #   @return [Google::Protobuf::Timestamp]
      #     A timestamp value.
      #     When stored in the Datastore, precise only to microseconds;
      #     any additional precision is rounded down.
      # @!attribute [rw] key_value
      #   @return [Google::Datastore::V1::Key]
      #     A key value.
      # @!attribute [rw] string_value
      #   @return [String]
      #     A UTF-8 encoded string value.
      #     When +exclude_from_indexes+ is false (it is indexed) , may have at most 1500 bytes.
      #     Otherwise, may be set to at least 1,000,000 bytes.
      # @!attribute [rw] blob_value
      #   @return [String]
      #     A blob value.
      #     May have at most 1,000,000 bytes.
      #     When +exclude_from_indexes+ is false, may have at most 1500 bytes.
      #     In JSON requests, must be base64-encoded.
      # @!attribute [rw] geo_point_value
      #   @return [Google::Type::LatLng]
      #     A geo point value representing a point on the surface of Earth.
      # @!attribute [rw] entity_value
      #   @return [Google::Datastore::V1::Entity]
      #     An entity value.
      #
      #     * May have no key.
      #     * May have a key with an incomplete key path.
      #     * May have a reserved/read-only key.
      # @!attribute [rw] array_value
      #   @return [Google::Datastore::V1::ArrayValue]
      #     An array value.
      #     Cannot contain another array value.
      #     A +Value+ instance that sets field +array_value+ must not set fields
      #     +meaning+ or +exclude_from_indexes+.
      # @!attribute [rw] meaning
      #   @return [Integer]
      #     The +meaning+ field should only be populated for backwards compatibility.
      # @!attribute [rw] exclude_from_indexes
      #   @return [true, false]
      #     If the value should be excluded from all indexes including those defined
      #     explicitly.
      class Value; end

      # A Datastore data object.
      #
      # An entity is limited to 1 megabyte when stored. That _roughly_
      # corresponds to a limit of 1 megabyte for the serialized form of this
      # message.
      # @!attribute [rw] key
      #   @return [Google::Datastore::V1::Key]
      #     The entity's key.
      #
      #     An entity must have a key, unless otherwise documented (for example,
      #     an entity in +Value.entity_value+ may have no key).
      #     An entity's kind is its key path's last element's kind,
      #     or null if it has no key.
      # @!attribute [rw] properties
      #   @return [Hash{String => Google::Datastore::V1::Value}]
      #     The entity's properties.
      #     The map's keys are property names.
      #     A property name matching regex +__.*__+ is reserved.
      #     A reserved property name is forbidden in certain documented contexts.
      #     The name must not contain more than 500 characters.
      #     The name cannot be +""+.
      class Entity; end
    end
  end
end