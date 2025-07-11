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


require "delegate"

module Google
  module Cloud
    module Datastore
      class Dataset
        ##
        # QueryResults is a special case Array with additional values.
        # A QueryResults object is returned from Dataset#run and contains
        # the Entities from the query as well as the query's cursor and
        # more_results value.
        #
        # Please be cautious when treating the QueryResults as an Array.
        # Many common Array methods will return a new Array instance.
        #
        # @example
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = datastore.query("Task")
        #   tasks = datastore.run query
        #
        #   tasks.size #=> 3
        #   tasks.cursor.to_s #=> "c2Vjb25kLXBhZ2UtY3Vyc29y"
        #
        # @example Caution, many Array methods will return a new Array instance:
        #   require "google/cloud/datastore"
        #
        #   datastore = Google::Cloud::Datastore.new
        #
        #   query = datastore.query("Task")
        #   tasks = datastore.run query
        #
        #   tasks.size #=> 3
        #   tasks.cursor.to_s #=> "c2Vjb25kLXBhZ2UtY3Vyc29y"
        #   descriptions = tasks.map { |t| t["description"] }
        #   descriptions.size #=> 3
        #   descriptions.cursor #=> raise NoMethodError
        #
        class QueryResults < DelegateClass(::Array)
          ##
          # The end_cursor of the QueryResults.
          #
          # @return [Google::Cloud::Datastore::Cursor]
          attr_reader :end_cursor
          alias cursor end_cursor

          ##
          # The state of the query after the current batch.
          #
          # Expected values are:
          #
          # * `:NOT_FINISHED`
          # * `:MORE_RESULTS_AFTER_LIMIT`
          # * `:MORE_RESULTS_AFTER_CURSOR`
          # * `:NO_MORE_RESULTS`
          # @return [Symbol]
          attr_reader :more_results

          ##
          # Read timestamp this batch was returned from.
          # This applies to the range of results from the query's `start_cursor` (or
          # the beginning of the query if no cursor was given) to this batch's
          # `end_cursor` (not the query's `end_cursor`).
          #
          # In a single transaction, subsequent query result batches for the same query
          # can have a greater timestamp. Each batch's read timestamp
          # is valid for all preceding batches.
          # This value will not be set for eventually consistent queries in Cloud
          # Datastore.
          # @return [Time, nil]
          attr_reader :batch_read_time

          # Query explain metrics. This is only present when the
          # [RunQueryRequest.explain_options][google.datastore.v1.RunQueryRequest.explain_options]
          # is provided, and it is sent only once with the last QueryResult batch.
          # @return [Google::Cloud::Datastore::V1::ExplainMetrics, nil]
          attr_reader :explain_metrics

          ##
          # Time at which the entities are being read. This would not be
          # older than 270 seconds.
          # @return [Time, DateTime, Google::Protobuf::Timestamp, nil]
          attr_reader :read_time

          ##
          # The options for query explanation.
          # @return [Google::Cloud::Datastore::V1::ExplainOptions, nil]
          attr_reader :explain_options

          ##
          # @private
          attr_accessor :service, :namespace, :cursors, :query

          ##
          # @private
          attr_writer :end_cursor, :more_results, :explain_metrics, :read_time, :batch_read_time, :explain_options

          ##

          ##
          # Convenience method for determining if the `more_results` value
          # is `:NOT_FINISHED`
          def not_finished?
            more_results == :NOT_FINISHED
          end

          ##
          # Convenience method for determining if the `more_results` value
          # is `:MORE_RESULTS_AFTER_LIMIT`
          def more_after_limit?
            more_results == :MORE_RESULTS_AFTER_LIMIT
          end

          ##
          # Convenience method for determining if the `more_results` value
          # is `:MORE_RESULTS_AFTER_CURSOR`
          def more_after_cursor?
            more_results == :MORE_RESULTS_AFTER_CURSOR
          end

          ##
          # Convenience method for determining if the `more_results` value
          # is `:NO_MORE_RESULTS`
          def no_more?
            more_results == :NO_MORE_RESULTS
          end

          ##
          # @private Create a new QueryResults with an array of values.
          def initialize arr = []
            super arr
          end

          ##
          # Whether there are more results available.
          #
          # @return [Boolean]
          #
          # @example
          #   require "google/cloud/datastore"
          #
          #   datastore = Google::Cloud::Datastore.new
          #
          #   query = datastore.query "Task"
          #   tasks = datastore.run query
          #
          #   if tasks.next?
          #     next_tasks = tasks.next
          #   end
          #
          def next?
            not_finished?
          end

          # rubocop:disable Metrics/AbcSize

          ##
          # Retrieve the next page of results.
          #
          # @return [QueryResults]
          #
          # @example
          #   require "google/cloud/datastore"
          #
          #   datastore = Google::Cloud::Datastore.new
          #
          #   query = datastore.query "Task"
          #   tasks = datastore.run query
          #
          #   if tasks.next?
          #     next_tasks = tasks.next
          #   end
          #
          def next
            return nil unless next?
            return nil if end_cursor.nil?
            ensure_service!
            query.start_cursor = cursor.to_grpc # should always be a Cursor...
            query.offset = 0 # Never carry an offset across batches
            unless query.limit.nil?
              # Reduce the limit by the number of entities returned in the current batch
              query.limit.value -= count
            end
            query_res = service.run_query query, namespace, read_time: read_time, explain_options: explain_options
            self.class.from_grpc query_res, service, namespace, query, read_time, explain_options
          end

          # rubocop:enable Metrics/AbcSize

          ##
          # Retrieve the {Cursor} for the provided result.
          #
          # @param [Entity] result The entity object to get a cursor for.
          #
          # @return [Cursor]
          #
          # @example
          #   require "google/cloud/datastore"
          #
          #   datastore = Google::Cloud::Datastore.new
          #
          #   query = datastore.query "Task"
          #   tasks = datastore.run query
          #
          #   first_task = tasks.first
          #   first_cursor = tasks.cursor_for first_task
          #
          def cursor_for result
            cursor_index = index result
            return nil if cursor_index.nil?
            cursors[cursor_index]
          end

          ##
          # Calls the given block once for each result and cursor combination,
          # which are passed as parameters.
          #
          # An Enumerator is returned if no block is given.
          #
          # @yield [result, cursor] The block for accessing each query result
          #   and cursor.
          # @yieldparam [Entity] result The query result object.
          # @yieldparam [Cursor] cursor The cursor object.
          #
          # @return [Enumerator]
          #
          # @example
          #   require "google/cloud/datastore"
          #
          #   datastore = Google::Cloud::Datastore.new
          #
          #   query = datastore.query "Task"
          #   tasks = datastore.run query
          #   tasks.each_with_cursor do |task, cursor|
          #     puts "Task #{task.key.id} (#cursor)"
          #   end
          #
          def each_with_cursor
            return enum_for :each_with_cursor unless block_given?
            zip(cursors).each { |r, c| yield [r, c] }
          end

          ##
          # Retrieves all query results by repeatedly loading {#next} until
          # {#next?} returns `false`. Calls the given block once for each query
          # result, which is passed as the parameter.
          #
          # An Enumerator is returned if no block is given.
          #
          # This method may make several API calls until all query results are
          # retrieved. Be sure to use as narrow a search criteria as possible.
          # Please use with caution.
          #
          # @param [Integer] request_limit The upper limit of API requests to
          #   make to load all query results. Default is no limit.
          # @yield [result] The block for accessing each query result.
          # @yieldparam [Entity] result The query result object.
          #
          # @return [Enumerator]
          #
          # @example Iterating each query result by passing a block:
          #   require "google/cloud/datastore"
          #
          #   datastore = Google::Cloud::Datastore.new
          #
          #   query = datastore.query "Task"
          #   tasks = datastore.run query
          #   tasks.all do |t|
          #     puts "Task #{t.key.id} (#cursor)"
          #   end
          #
          # @example Using the enumerator by not passing a block:
          #   require "google/cloud/datastore"
          #
          #   datastore = Google::Cloud::Datastore.new
          #
          #   query = datastore.query "Task"
          #   tasks = datastore.run query
          #   tasks.all.map(&:key).each do |key|
          #     puts "Key #{key.id}"
          #   end
          #
          # @example Limit the number of API calls made:
          #   require "google/cloud/datastore"
          #
          #   datastore = Google::Cloud::Datastore.new
          #
          #   query = datastore.query "Task"
          #   tasks = datastore.run query
          #   tasks.all(request_limit: 10) do |t|
          #     puts "Task #{t.key.id} (#cursor)"
          #   end
          #
          def all request_limit: nil, &block
            request_limit = request_limit.to_i if request_limit
            unless block_given?
              return enum_for :all, request_limit: request_limit
            end
            results = self
            loop do
              results.each(&block)
              if request_limit
                request_limit -= 1
                break if request_limit.negative?
              end
              break unless results.next?
              results = results.next
            end
          end

          ##
          # Retrieves all query results and cursors by repeatedly loading
          # {#next} until {#next?} returns `false`. Calls the given block once
          # for each result and cursor combination, which are passed as
          # parameters.
          #
          # An Enumerator is returned if no block is given.
          #
          # This method may make several API calls until all query results are
          # retrieved. Be sure to use as narrow a search criteria as possible.
          # Please use with caution.
          #
          # @param [Integer] request_limit The upper limit of API requests to
          #   make to load all tables. Default is no limit.
          # @yield [result, cursor] The block for accessing each query result
          #   and cursor.
          # @yieldparam [Entity] result The query result object.
          # @yieldparam [Cursor] cursor The cursor object.
          #
          # @return [Enumerator]
          #
          # @example Iterating all results and cursors by passing a block:
          #   require "google/cloud/datastore"
          #
          #   datastore = Google::Cloud::Datastore.new
          #
          #   query = datastore.query "Task"
          #   tasks = datastore.run query
          #   tasks.all_with_cursor do |task, cursor|
          #     puts "Task #{task.key.id} (#cursor)"
          #   end
          #
          # @example Using the enumerator by not passing a block:
          #   require "google/cloud/datastore"
          #
          #   datastore = Google::Cloud::Datastore.new
          #
          #   query = datastore.query "Task"
          #   tasks = datastore.run query
          #   tasks.all_with_cursor.count # number of result/cursor pairs
          #
          # @example Limit the number of API calls made:
          #   require "google/cloud/datastore"
          #
          #   datastore = Google::Cloud::Datastore.new
          #
          #   query = datastore.query "Task"
          #   tasks = datastore.run query
          #   tasks.all_with_cursor(request_limit: 10) do |task, cursor|
          #     puts "Task #{task.key.id} (#cursor)"
          #   end
          #
          def all_with_cursor request_limit: nil, &block
            request_limit = request_limit.to_i if request_limit
            unless block_given?
              return enum_for :all_with_cursor, request_limit: request_limit
            end
            results = self

            loop do
              results.zip(results.cursors).each(&block)
              if request_limit
                request_limit -= 1
                break if request_limit.negative?
              end
              break unless results.next?
              results = results.next
            end
          end

          # rubocop:disable Metrics/AbcSize

          ##
          # @private New Dataset::QueryResults from a
          # Google::Dataset::V1::RunQueryResponse object.
          def self.from_grpc query_res, service, namespace, query, read_time = nil, explain_options = nil
            if query_res.batch
              r, c = Array(query_res.batch.entity_results).map do |result|
                [Entity.from_grpc(result.entity), Cursor.from_grpc(result.cursor)]
              end.transpose
            end
            r ||= []
            c ||= []

            next_more_results = query_res.batch.more_results if query_res.batch
            next_more_results ||= :NO_MORE_RESULTS

            new(r).tap do |qr|
              qr.cursors = c
              qr.explain_metrics = query_res.explain_metrics
              qr.end_cursor = Cursor.from_grpc query_res.batch.end_cursor if query_res.batch
              qr.more_results = next_more_results
              qr.read_time = read_time
              qr.batch_read_time = query_res.batch.read_time if query_res.batch
              qr.explain_options = explain_options
              qr.service = service
              qr.namespace = namespace
              qr.query = query_res.query || query
            end
          end

          # rubocop:enable Metrics/AbcSize

          protected

          ##
          # @private Raise an error unless an active connection to the service
          # is available.
          def ensure_service!
            msg = "Must have active connection to datastore service to get next"
            raise msg if @service.nil? || @query.nil?
          end
        end
      end
    end
  end
end
