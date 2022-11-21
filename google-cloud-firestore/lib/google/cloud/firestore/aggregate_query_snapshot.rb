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

require 'debug'

module Google
  module Cloud
    module Firestore      
      class AggregateQuerySnapshot
  
        # def initialize results
        #   @results = results
        # end

        def get aggregate_alias
          if @results.key?(aggregate_alias)
            @results[aggregate_alias][:integer_value]
          else
            nil
          end
        end

        def self.from_run_aggregate_query_response response
          # binding.break
          elems = []
          response.each { |res| elems << res }

          # convert from protobuf to ruby map
          aggregate_fields = elems[0].result.aggregate_fields.to_h
          # { |k, v| [String(k), String(v)] }

          new.tap do |s|
            s.instance_variable_set :@results, aggregate_fields
          end
        end

        def self.from_transaction_aggregate_query_response result
          aggregate_fields = result.result.aggregate_fields.to_h
          # { |k, v| [String(k), String(v)] }

          new.tap do |s|
            s.instance_variable_set :@results, aggregate_fields
          end

        end
      end
    end
  end
end