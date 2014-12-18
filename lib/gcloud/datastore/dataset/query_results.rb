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

module Gcloud
  module Datastore
    class Dataset
      ##
      # QueryResults is a special case Array with additional values.
      # A QueryResults object is returned from Dataset#run and contains
      # the Entities from the query as well as the query's cursor and
      # more_results value.
      #
      #   entities = dataset.run query
      #   entities.size #=> 3
      #   entities.cursor #=> "c3VwZXJhd2Vzb21lIQ"
      #
      # Please be cautious when treating the QueryResults as an Array.
      # Many common Array methods will return a new Array instance.
      #
      #   entities = dataset.run query
      #   entities.size #=> 3
      #   entities.cursor #=> "c3VwZXJhd2Vzb21lIQ"
      #   names = entities.map { |e| e.name }
      #   names.size #=> 3
      #   names.cursor #=> NoMethodError
      #
      class QueryResults < DelegateClass(::Array)
        ##
        # The cursor of the QueryResults.
        attr_reader :cursor

        ##
        # Create a new QueryResults with an array of values.
        def initialize arr = [], cursor = nil
          super arr
          @cursor = cursor
        end
      end
    end
  end
end
