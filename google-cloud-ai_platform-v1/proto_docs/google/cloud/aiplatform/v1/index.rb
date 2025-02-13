# frozen_string_literal: true

# Copyright 2022 Google LLC
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

# Auto-generated by gapic-generator-ruby. DO NOT EDIT!


module Google
  module Cloud
    module AIPlatform
      module V1
        # A representation of a collection of database items organized in a way that
        # allows for approximate nearest neighbor (a.k.a ANN) algorithms search.
        # @!attribute [r] name
        #   @return [::String]
        #     Output only. The resource name of the Index.
        # @!attribute [rw] display_name
        #   @return [::String]
        #     Required. The display name of the Index.
        #     The name can be up to 128 characters long and can consist of any UTF-8
        #     characters.
        # @!attribute [rw] description
        #   @return [::String]
        #     The description of the Index.
        # @!attribute [rw] metadata_schema_uri
        #   @return [::String]
        #     Immutable. Points to a YAML file stored on Google Cloud Storage describing
        #     additional information about the Index, that is specific to it. Unset if
        #     the Index does not have any additional information. The schema is defined
        #     as an OpenAPI 3.0.2 [Schema
        #     Object](https://github.com/OAI/OpenAPI-Specification/blob/main/versions/3.0.2.md#schemaObject).
        #     Note: The URI given on output will be immutable and probably different,
        #     including the URI scheme, than the one given on input. The output URI will
        #     point to a location where the user only has a read access.
        # @!attribute [rw] metadata
        #   @return [::Google::Protobuf::Value]
        #     An additional information about the Index; the schema of the metadata can
        #     be found in
        #     {::Google::Cloud::AIPlatform::V1::Index#metadata_schema_uri metadata_schema}.
        # @!attribute [r] deployed_indexes
        #   @return [::Array<::Google::Cloud::AIPlatform::V1::DeployedIndexRef>]
        #     Output only. The pointers to DeployedIndexes created from this Index.
        #     An Index can be only deleted if all its DeployedIndexes had been undeployed
        #     first.
        # @!attribute [rw] etag
        #   @return [::String]
        #     Used to perform consistent read-modify-write updates. If not set, a blind
        #     "overwrite" update happens.
        # @!attribute [rw] labels
        #   @return [::Google::Protobuf::Map{::String => ::String}]
        #     The labels with user-defined metadata to organize your Indexes.
        #
        #     Label keys and values can be no longer than 64 characters
        #     (Unicode codepoints), can only contain lowercase letters, numeric
        #     characters, underscores and dashes. International characters are allowed.
        #
        #     See https://goo.gl/xmQnxf for more information and examples of labels.
        # @!attribute [r] create_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. Timestamp when this Index was created.
        # @!attribute [r] update_time
        #   @return [::Google::Protobuf::Timestamp]
        #     Output only. Timestamp when this Index was most recently updated.
        #     This also includes any update to the contents of the Index.
        #     Note that Operations working on this Index may have their
        #     [Operations.metadata.generic_metadata.update_time]
        #     [google.cloud.aiplatform.v1.GenericOperationMetadata.update_time] a little
        #     after the value of this timestamp, yet that does not mean their results are
        #     not already reflected in the Index. Result of any successfully completed
        #     Operation on the Index is reflected in it.
        # @!attribute [r] index_stats
        #   @return [::Google::Cloud::AIPlatform::V1::IndexStats]
        #     Output only. Stats of the index resource.
        # @!attribute [rw] index_update_method
        #   @return [::Google::Cloud::AIPlatform::V1::Index::IndexUpdateMethod]
        #     Immutable. The update method to use with this Index. If not set,
        #     BATCH_UPDATE will be used by default.
        # @!attribute [rw] encryption_spec
        #   @return [::Google::Cloud::AIPlatform::V1::EncryptionSpec]
        #     Immutable. Customer-managed encryption key spec for an Index. If set, this
        #     Index and all sub-resources of this Index will be secured by this key.
        # @!attribute [r] satisfies_pzs
        #   @return [::Boolean]
        #     Output only. Reserved for future use.
        # @!attribute [r] satisfies_pzi
        #   @return [::Boolean]
        #     Output only. Reserved for future use.
        class Index
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # @!attribute [rw] key
          #   @return [::String]
          # @!attribute [rw] value
          #   @return [::String]
          class LabelsEntry
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # The update method of an Index.
          module IndexUpdateMethod
            # Should not be used.
            INDEX_UPDATE_METHOD_UNSPECIFIED = 0

            # BatchUpdate: user can call UpdateIndex with files on Cloud Storage of
            # Datapoints to update.
            BATCH_UPDATE = 1

            # StreamUpdate: user can call UpsertDatapoints/DeleteDatapoints to update
            # the Index and the updates will be applied in corresponding
            # DeployedIndexes in nearly real-time.
            STREAM_UPDATE = 2
          end
        end

        # A datapoint of Index.
        # @!attribute [rw] datapoint_id
        #   @return [::String]
        #     Required. Unique identifier of the datapoint.
        # @!attribute [rw] feature_vector
        #   @return [::Array<::Float>]
        #     Required. Feature embedding vector for dense index. An array of numbers
        #     with the length of [NearestNeighborSearchConfig.dimensions].
        # @!attribute [rw] sparse_embedding
        #   @return [::Google::Cloud::AIPlatform::V1::IndexDatapoint::SparseEmbedding]
        #     Optional. Feature embedding vector for sparse index.
        # @!attribute [rw] restricts
        #   @return [::Array<::Google::Cloud::AIPlatform::V1::IndexDatapoint::Restriction>]
        #     Optional. List of Restrict of the datapoint, used to perform "restricted
        #     searches" where boolean rule are used to filter the subset of the database
        #     eligible for matching. This uses categorical tokens. See:
        #     https://cloud.google.com/vertex-ai/docs/matching-engine/filtering
        # @!attribute [rw] numeric_restricts
        #   @return [::Array<::Google::Cloud::AIPlatform::V1::IndexDatapoint::NumericRestriction>]
        #     Optional. List of Restrict of the datapoint, used to perform "restricted
        #     searches" where boolean rule are used to filter the subset of the database
        #     eligible for matching. This uses numeric comparisons.
        # @!attribute [rw] crowding_tag
        #   @return [::Google::Cloud::AIPlatform::V1::IndexDatapoint::CrowdingTag]
        #     Optional. CrowdingTag of the datapoint, the number of neighbors to return
        #     in each crowding can be configured during query.
        class IndexDatapoint
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods

          # Feature embedding vector for sparse index. An array of numbers whose values
          # are located in the specified dimensions.
          # @!attribute [rw] values
          #   @return [::Array<::Float>]
          #     Required. The list of embedding values of the sparse vector.
          # @!attribute [rw] dimensions
          #   @return [::Array<::Integer>]
          #     Required. The list of indexes for the embedding values of the sparse
          #     vector.
          class SparseEmbedding
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # Restriction of a datapoint which describe its attributes(tokens) from each
          # of several attribute categories(namespaces).
          # @!attribute [rw] namespace
          #   @return [::String]
          #     The namespace of this restriction. e.g.: color.
          # @!attribute [rw] allow_list
          #   @return [::Array<::String>]
          #     The attributes to allow in this namespace. e.g.: 'red'
          # @!attribute [rw] deny_list
          #   @return [::Array<::String>]
          #     The attributes to deny in this namespace. e.g.: 'blue'
          class Restriction
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end

          # This field allows restricts to be based on numeric comparisons rather
          # than categorical tokens.
          # @!attribute [rw] value_int
          #   @return [::Integer]
          #     Represents 64 bit integer.
          #
          #     Note: The following fields are mutually exclusive: `value_int`, `value_float`, `value_double`. If a field in that set is populated, all other fields in the set will automatically be cleared.
          # @!attribute [rw] value_float
          #   @return [::Float]
          #     Represents 32 bit float.
          #
          #     Note: The following fields are mutually exclusive: `value_float`, `value_int`, `value_double`. If a field in that set is populated, all other fields in the set will automatically be cleared.
          # @!attribute [rw] value_double
          #   @return [::Float]
          #     Represents 64 bit float.
          #
          #     Note: The following fields are mutually exclusive: `value_double`, `value_int`, `value_float`. If a field in that set is populated, all other fields in the set will automatically be cleared.
          # @!attribute [rw] namespace
          #   @return [::String]
          #     The namespace of this restriction. e.g.: cost.
          # @!attribute [rw] op
          #   @return [::Google::Cloud::AIPlatform::V1::IndexDatapoint::NumericRestriction::Operator]
          #     This MUST be specified for queries and must NOT be specified for
          #     datapoints.
          class NumericRestriction
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods

            # Which comparison operator to use.  Should be specified for queries only;
            # specifying this for a datapoint is an error.
            #
            # Datapoints for which Operator is true relative to the query's Value
            # field will be allowlisted.
            module Operator
              # Default value of the enum.
              OPERATOR_UNSPECIFIED = 0

              # Datapoints are eligible iff their value is < the query's.
              LESS = 1

              # Datapoints are eligible iff their value is <= the query's.
              LESS_EQUAL = 2

              # Datapoints are eligible iff their value is == the query's.
              EQUAL = 3

              # Datapoints are eligible iff their value is >= the query's.
              GREATER_EQUAL = 4

              # Datapoints are eligible iff their value is > the query's.
              GREATER = 5

              # Datapoints are eligible iff their value is != the query's.
              NOT_EQUAL = 6
            end
          end

          # Crowding tag is a constraint on a neighbor list produced by nearest
          # neighbor search requiring that no more than some value k' of the k
          # neighbors returned have the same value of crowding_attribute.
          # @!attribute [rw] crowding_attribute
          #   @return [::String]
          #     The attribute value used for crowding.  The maximum number of neighbors
          #     to return per crowding attribute value
          #     (per_crowding_attribute_num_neighbors) is configured per-query. This
          #     field is ignored if per_crowding_attribute_num_neighbors is larger than
          #     the total number of neighbors to return for a given query.
          class CrowdingTag
            include ::Google::Protobuf::MessageExts
            extend ::Google::Protobuf::MessageExts::ClassMethods
          end
        end

        # Stats of the Index.
        # @!attribute [r] vectors_count
        #   @return [::Integer]
        #     Output only. The number of dense vectors in the Index.
        # @!attribute [r] sparse_vectors_count
        #   @return [::Integer]
        #     Output only. The number of sparse vectors in the Index.
        # @!attribute [r] shards_count
        #   @return [::Integer]
        #     Output only. The number of shards in the Index.
        class IndexStats
          include ::Google::Protobuf::MessageExts
          extend ::Google::Protobuf::MessageExts::ClassMethods
        end
      end
    end
  end
end
