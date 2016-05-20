# Copyright 2014 Google Inc. All rights reserved.
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


require "delegate"

module Gcloud
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
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   datastore = gcloud.datastore
      #
      #   query = datastore.query("Task")
      #   tasks = datastore.run query
      #
      #   tasks.size #=> 3
      #   tasks.cursor #=> Gcloud::Datastore::Cursor(c3VwZXJhd2Vzb21lIQ)
      #
      # @example Caution, many Array methods will return a new Array instance:
      #   require "gcloud"
      #
      #   gcloud = Gcloud.new
      #   datastore = gcloud.datastore
      #
      #   query = datastore.query("Task")
      #   tasks = datastore.run query
      #
      #   tasks.size #=> 3
      #   tasks.end_cursor #=> Gcloud::Datastore::Cursor(c3VwZXJhd2Vzb21lIQ)
      #   descriptions = tasks.map { |task| task["description"] }
      #   descriptions.size #=> 3
      #   descriptions.cursor #=> NoMethodError
      #
      class QueryResults < DelegateClass(::Array)
        ##
        # The end_cursor of the QueryResults.
        #
        # @return [Gcloud::Datastore::Cursor]
        attr_reader :end_cursor
        alias_method :cursor, :end_cursor

        ##
        # The state of the query after the current batch.
        #
        # Expected values are:
        #
        # * `:NOT_FINISHED`
        # * `:MORE_RESULTS_AFTER_LIMIT`
        # * `:MORE_RESULTS_AFTER_CURSOR`
        # * `:NO_MORE_RESULTS`
        attr_reader :more_results

        ##
        # @private
        attr_accessor :service, :namespace, :query

        ##
        # @private
        attr_writer :end_cursor, :more_results

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
        # Create a new QueryResults with an array of values.
        def initialize arr = []
          super arr
        end

        ##
        # Whether there are more results available for subsequent API calls.
        # Tests the value of {#more_results}.
        #
        def next?
          !no_more?
        end

        ##
        # Retrieves the next page of results by making an API call with the
        # value stored in {#cursor} if there are more results available.
        #
        # @example
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   datastore = gcloud.datastore
        #
        #   query = datastore.query("Task")
        #   tasks = datastore.run query
        #
        #   loop do
        #     tasks.each do |t|
        #       puts t["description"]
        #     end
        #     break unless tasks.next?
        #     tasks = tasks.next
        #   end
        #
        def next
          return nil unless next?
          return nil if end_cursor.nil?
          ensure_service!
          query.start_cursor = cursor.to_grpc # should always be a Cursor...
          query_res = service.run_query query, namespace
          self.class.from_grpc query_res, service, namespace, query
        rescue GRPC::BadStatus => e
          raise Gcloud::Error.from_error(e)
        end

        ##
        # Retrieves all query results by repeatedly loading {#next} until
        # {#next?} returns `false`. Returns the list instance for method
        # chaining.
        #
        # This method may make several API calls until all query results are
        # retrieved. Be sure to use as narrow a search criteria as possible.
        # Please use with caution.
        #
        # @example
        #   require "gcloud"
        #
        #   gcloud = Gcloud.new
        #   datastore = gcloud.datastore
        #   query = datastore.query("Task")
        #   all_tasks = datastore.run(query).all
        #
        def all
          while next?
            next_records = self.next
            push(*next_records)
            self.end_cursor = next_records.end_cursor
            self.more_results = next_records.more_results
            self.service = next_records.service
            self.namespace = next_records.namespace
            self.query = next_records.query
          end
          self
        end

        ##
        # @private New Dataset::QueryResults from a
        # Google::Dataset::V1beta3::RunQueryResponse object.
        def self.from_grpc query_res, service, namespace, query
          entities = Array(query_res.batch.entity_results).map do |result|
            # TODO: Make this return an EntityResult with cursor...
            Entity.from_grpc result.entity
          end
          new(entities).tap do |qr|
            qr.end_cursor = Cursor.from_grpc query_res.batch.end_cursor
            qr.more_results = query_res.batch.more_results
            qr.service = service
            qr.namespace = namespace
            qr.query = query_res.query || query
          end
        end

        protected

        ##
        # @private Raise an error unless an active connection to the service is
        # available.
        def ensure_service!
          msg = "Must have active connection to datastore service to get next"
          fail msg if @service.nil? || @query.nil?
        end
      end
    end
  end
end
