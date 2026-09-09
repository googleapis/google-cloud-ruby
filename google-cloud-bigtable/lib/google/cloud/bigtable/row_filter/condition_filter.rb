# frozen_string_literal: true

# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


module Google
  module Cloud
    module Bigtable
      module RowFilter
        ##
        # # ConditionFilter
        #
        # A RowFilter that evaluates one of two possible RowFilters, depending on
        # whether or not a predicate RowFilter outputs any cells from the input row.
        #
        # IMPORTANT NOTE: The predicate filter does not execute atomically with the
        # true and false filters, which may lead to inconsistent or unexpected
        # results. Additionally, condition filters have poor performance, especially
        # when filters are set for the false condition.
        #
        # If `predicate_filter` outputs any cells, then `true_filter` will be
        # evaluated on the input row. Otherwise, `false_filter` will be evaluated.
        #
        # @example
        #   predicate = Google::Cloud::Bigtable::RowFilter.key "user-*"
        #
        #   label = Google::Cloud::Bigtable::RowFilter.label "user"
        #   strip_value = Google::Cloud::Bigtable::RowFilter.strip_value
        #
        #   Google::Cloud::Bigtable::RowFilter.condition(predicate).on_match(label).otherwise(strip_value)
        #
        class ConditionFilter
          # @private
          # Creates a condition filter instance.
          #
          # @param predicate [SimpleFilter, ChainFilter, InterleaveFilter, ConditionFilter]
          #
          def initialize predicate
            @grpc = Google::Cloud::Bigtable::V2::RowFilter::Condition.new
            @grpc.predicate_filter = predicate.to_grpc
          end

          ##
          # Sets a true filter on predicate-filter match.
          #
          # The filter to apply to the input row if `predicate_filter` returns any
          # results. If not provided, no results will be returned in the true case.
          #
          # @param filter [SimpleFilter, ChainFilter, InterleaveFilter, ConditionFilter]
          # @return [Google::Cloud::Bigtable::RowFilter::ConditionFilter]
          #
          # @example
          #   require "google/cloud/bigtable"
          #   predicate = Google::Cloud::Bigtable::RowFilter.key "user-*"
          #
          #   label = Google::Cloud::Bigtable::RowFilter.label "user"
          #   strip_value = Google::Cloud::Bigtable::RowFilter.strip_value
          #
          #   Google::Cloud::Bigtable::RowFilter.condition(predicate).on_match(label).otherwise(strip_value)
          #
          def on_match filter
            @grpc.true_filter = filter.to_grpc
            self
          end

          ##
          # Set otherwise(false) filter.
          #
          # The filter to apply to the input row if `predicate_filter` does not
          # return any results. If not provided, no results will be returned in the
          # false case.
          #
          # @param filter [SimpleFilter, ChainFilter, InterleaveFilter, ConditionFilter]
          # @return [Google::Cloud::Bigtable::RowFilter::ConditionFilter]
          #
          # @example
          #   require "google/cloud/bigtable"
          #
          #   predicate = Google::Cloud::Bigtable::RowFilter.key "user-*"
          #
          #   label = Google::Cloud::Bigtable::RowFilter.label "user"
          #   strip_value = Google::Cloud::Bigtable::RowFilter.strip_value
          #
          #   Google::Cloud::Bigtable::RowFilter.condition(predicate).on_match(label).otherwise(strip_value)
          #
          def otherwise filter
            @grpc.false_filter = filter.to_grpc
            self
          end

          # @private
          # Gets the row-filter gRPC instance.
          # @return [Google::Cloud::Bigtable::V2::RowFilter]
          #
          def to_grpc
            Google::Cloud::Bigtable::V2::RowFilter.new condition: @grpc
          end
        end
      end
    end
  end
end
