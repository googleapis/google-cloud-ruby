## Generated from datastore_v1.proto for api.services.datastore
require "beefcake"

module Gcloud
  module Datastore
    module Proto

      class PartitionId
        include Beefcake::Message
      end

      class Key
        include Beefcake::Message

        class PathElement
          include Beefcake::Message
        end
      end

      class Value
        include Beefcake::Message
      end

      class Property
        include Beefcake::Message
      end

      class Entity
        include Beefcake::Message
      end

      class EntityResult
        include Beefcake::Message

        module ResultType
          FULL = 1
          PROJECTION = 2
          KEY_ONLY = 3
        end
      end

      class Query
        include Beefcake::Message
      end

      class KindExpression
        include Beefcake::Message
      end

      class PropertyReference
        include Beefcake::Message
      end

      class PropertyExpression
        include Beefcake::Message

        module AggregationFunction
          FIRST = 1
        end
      end

      class PropertyOrder
        include Beefcake::Message

        module Direction
          ASCENDING = 1
          DESCENDING = 2
        end
      end

      class Filter
        include Beefcake::Message
      end

      class CompositeFilter
        include Beefcake::Message

        module Operator
          AND = 1
        end
      end

      class PropertyFilter
        include Beefcake::Message

        module Operator
          LESS_THAN = 1
          LESS_THAN_OR_EQUAL = 2
          GREATER_THAN = 3
          GREATER_THAN_OR_EQUAL = 4
          EQUAL = 5
          HAS_ANCESTOR = 11
        end
      end

      class GqlQuery
        include Beefcake::Message
      end

      class GqlQueryArg
        include Beefcake::Message
      end

      class QueryResultBatch
        include Beefcake::Message

        module MoreResultsType
          NOT_FINISHED = 1
          MORE_RESULTS_AFTER_LIMIT = 2
          NO_MORE_RESULTS = 3
        end
      end

      class Mutation
        include Beefcake::Message
      end

      class MutationResult
        include Beefcake::Message
      end

      class ReadOptions
        include Beefcake::Message

        module ReadConsistency
          DEFAULT = 0
          STRONG = 1
          EVENTUAL = 2
        end
      end

      class LookupRequest
        include Beefcake::Message
      end

      class LookupResponse
        include Beefcake::Message
      end

      class RunQueryRequest
        include Beefcake::Message
      end

      class RunQueryResponse
        include Beefcake::Message
      end

      class BeginTransactionRequest
        include Beefcake::Message

        module IsolationLevel
          SNAPSHOT = 0
          SERIALIZABLE = 1
        end
      end

      class BeginTransactionResponse
        include Beefcake::Message
      end

      class RollbackRequest
        include Beefcake::Message
      end

      class RollbackResponse
        include Beefcake::Message
      end

      class CommitRequest
        include Beefcake::Message

        module Mode
          TRANSACTIONAL = 1
          NON_TRANSACTIONAL = 2
        end
      end

      class CommitResponse
        include Beefcake::Message
      end

      class AllocateIdsRequest
        include Beefcake::Message
      end

      class AllocateIdsResponse
        include Beefcake::Message
      end

      class PartitionId
        optional :dataset_id, :string, 3
        optional :namespace, :string, 4
      end

      class Key

        class PathElement
          required :kind, :string, 1
          optional :id, :int64, 2
          optional :name, :string, 3
        end
        optional :partition_id, PartitionId, 1
        repeated :path_element, Key::PathElement, 2
      end

      class Value
        optional :boolean_value, :bool, 1
        optional :integer_value, :int64, 2
        optional :double_value, :double, 3
        optional :timestamp_microseconds_value, :int64, 4
        optional :key_value, Key, 5
        optional :blob_key_value, :string, 16
        optional :string_value, :string, 17
        optional :blob_value, :bytes, 18
        optional :entity_value, Entity, 6
        repeated :list_value, Value, 7
        optional :meaning, :int32, 14
        optional :indexed, :bool, 15, :default => true
      end

      class Property
        required :name, :string, 1
        required :value, Value, 4
      end

      class Entity
        optional :key, Key, 1
        repeated :property, Property, 2
      end

      class EntityResult
        required :entity, Entity, 1
      end

      class Query
        repeated :projection, PropertyExpression, 2
        repeated :kind, KindExpression, 3
        optional :filter, Filter, 4
        repeated :order, PropertyOrder, 5
        repeated :group_by, PropertyReference, 6
        optional :start_cursor, :bytes, 7
        optional :end_cursor, :bytes, 8
        optional :offset, :int32, 10, :default => 0
        optional :limit, :int32, 11
      end

      class KindExpression
        required :name, :string, 1
      end

      class PropertyReference
        required :name, :string, 2
      end

      class PropertyExpression
        required :property, PropertyReference, 1
        optional :aggregation_function, PropertyExpression::AggregationFunction, 2
      end

      class PropertyOrder
        required :property, PropertyReference, 1
        optional :direction, PropertyOrder::Direction, 2, :default => PropertyOrder::Direction::ASCENDING
      end

      class Filter
        optional :composite_filter, CompositeFilter, 1
        optional :property_filter, PropertyFilter, 2
      end

      class CompositeFilter
        required :operator, CompositeFilter::Operator, 1
        repeated :filter, Filter, 2
      end

      class PropertyFilter
        required :property, PropertyReference, 1
        required :operator, PropertyFilter::Operator, 2
        required :value, Value, 3
      end

      class GqlQuery
        required :query_string, :string, 1
        optional :allow_literal, :bool, 2, :default => false
        repeated :name_arg, GqlQueryArg, 3
        repeated :number_arg, GqlQueryArg, 4
      end

      class GqlQueryArg
        optional :name, :string, 1
        optional :value, Value, 2
        optional :cursor, :bytes, 3
      end

      class QueryResultBatch
        required :entity_result_type, EntityResult::ResultType, 1
        repeated :entity_result, EntityResult, 2
        optional :end_cursor, :bytes, 4
        required :more_results, QueryResultBatch::MoreResultsType, 5
        optional :skipped_results, :int32, 6
      end

      class Mutation
        repeated :upsert, Entity, 1
        repeated :update, Entity, 2
        repeated :insert, Entity, 3
        repeated :insert_auto_id, Entity, 4
        repeated :delete, Key, 5
        optional :force, :bool, 6
      end

      class MutationResult
        required :index_updates, :int32, 1
        repeated :insert_auto_id_key, Key, 2
      end

      class ReadOptions
        optional :read_consistency, ReadOptions::ReadConsistency, 1, :default => ReadOptions::ReadConsistency::DEFAULT
        optional :transaction, :bytes, 2
      end

      class LookupRequest
        optional :read_options, ReadOptions, 1
        repeated :key, Key, 3
      end

      class LookupResponse
        repeated :found, EntityResult, 1
        repeated :missing, EntityResult, 2
        repeated :deferred, Key, 3
      end

      class RunQueryRequest
        optional :read_options, ReadOptions, 1
        optional :partition_id, PartitionId, 2
        optional :query, Query, 3
        optional :gql_query, GqlQuery, 7
      end

      class RunQueryResponse
        optional :batch, QueryResultBatch, 1
      end

      class BeginTransactionRequest
        optional :isolation_level, BeginTransactionRequest::IsolationLevel, 1, :default => BeginTransactionRequest::IsolationLevel::SNAPSHOT
      end

      class BeginTransactionResponse
        optional :transaction, :bytes, 1
      end

      class RollbackRequest
        required :transaction, :bytes, 1
      end

      class RollbackResponse
      end

      class CommitRequest
        optional :transaction, :bytes, 1
        optional :mutation, Mutation, 2
        optional :mode, CommitRequest::Mode, 5, :default => CommitRequest::Mode::TRANSACTIONAL
      end

      class CommitResponse
        optional :mutation_result, MutationResult, 1
      end

      class AllocateIdsRequest
        repeated :key, Key, 1
      end

      class AllocateIdsResponse
        repeated :key, Key, 1
      end
    end
  end
end
