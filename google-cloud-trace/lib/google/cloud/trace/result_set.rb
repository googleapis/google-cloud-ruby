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


module Google
  module Cloud
    module Trace
      ##
      # ResultSet represents the results of a `list_traces` request. It is
      # an enumerable of the traces found, plus information about the request
      # and a token to get the next page of results.
      #
      class ResultSet
        include Enumerable

        ##
        # Create a new ResultSet given an enumerable of result Trace objects,
        # a next page token (or nil if this is the last page), and all the
        # query parameters.
        #
        # @private
        #
        def initialize service, project,
                       results, next_page_token,
                       start_time, end_time,
                       filter: nil,
                       order_by: nil,
                       view: nil,
                       page_size: nil,
                       page_token: nil
          @service = service
          @project = project
          @results = results
          @next_page_token = next_page_token
          @view = view
          @page_size = page_size
          @start_time = start_time
          @end_time = end_time
          @filter = filter
          @order_by = order_by
          @page_token = page_token
        end

        ##
        # An `each` method that supports the Enumerable module. Iterates over
        # the results and yields each, as a {Google::Cloud::Trace::TraceRecord}
        # object, to the given block. If no block is provided, returns an
        # Enumerator.
        #
        def each &block
          @results.each(&block)
        end

        ##
        # Returns the number of traces in this page of results.
        #
        # @return [Integer]
        #
        def size
          @results.size
        end

        ##
        # The trace service client that obtained this result set
        # @private
        attr_reader :service

        ##
        # The project ID string.
        #
        # @return [String]
        #
        attr_reader :project

        ##
        # The token to pass to `list_traces` to get the next page, or nil if
        # this is the last page.
        #
        # @return [String, nil]
        #
        attr_reader :next_page_token

        ##
        # The `view` query parameter.
        #
        # @return [Symbol, nil]
        #
        attr_reader :view

        ##
        # The `page_size` query parameter.
        #
        # @return [Integer, nil]
        #
        attr_reader :page_size

        ##
        # The `start_time` query parameter.
        #
        # @return [Time, nil]
        #
        attr_reader :start_time

        ##
        # The `end_time` query parameter.
        #
        # @return [Time, nil]
        #
        attr_reader :end_time

        ##
        # The `filter` query parameter.
        #
        # @return [String, nil]
        #
        attr_reader :filter

        ##
        # The `order_by` query parameter.
        #
        # @return [String, nil]
        #
        attr_reader :order_by

        ##
        # The page token used to obtain this page of results.
        #
        # @return [String, nil]
        #
        attr_reader :page_token

        ##
        # Returns true if at least one more page of results can be retrieved.
        #
        # @return [Boolean]
        #
        def results_pending?
          !next_page_token.nil?
        end

        ##
        # Queries the service for the next page of results and returns a new
        # ResultSet for that page. Returns `nil` if there are no more results.
        #
        # @return [Google::Cloud::Trace::ResultSet]
        #
        def next_page
          return nil unless results_pending?
          service.list_traces \
            project, start_time, end_time,
            filter: filter,
            order_by: order_by,
            view: view,
            page_size: page_size,
            page_token: next_page_token
        end

        ##
        # Create a new ResultSet given a Google::Gax::PagedEnumerable::Page,
        # and all the query parameters.
        #
        # @private
        #
        def self.from_gax_page service, project_id,
                               page, start_time, end_time,
                               filter: nil,
                               order_by: nil,
                               view: nil,
                               page_size: nil,
                               page_token: nil
          next_page_token = page.next_page_token
          next_page_token = nil unless page.next_page_token?
          results = page.map do |proto|
            Google::Cloud::Trace::TraceRecord.from_grpc proto
          end
          new service, project_id,
              results, next_page_token,
              start_time, end_time,
              filter: filter,
              order_by: order_by,
              view: view,
              page_size: page_size,
              page_token: page_token
        end
      end
    end
  end
end
