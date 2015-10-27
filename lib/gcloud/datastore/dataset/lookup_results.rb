#--
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
      # LookupResults is a special case Array with additional values.
      # A LookupResults object is returned from Dataset#find_all and
      # contains the entities as well as the Keys that were deferred from
      # the results and the Entities that were missing in the dataset.
      #
      #   entities = dataset.find_all key1, key2, key3
      #   entities.size #=> 3
      #   entities.deferred #=> []
      #   entities.missing #=> []
      #
      # Please be cautious when treating the LookupResults as an Array. Many
      # common Array methods will return a new Array instance.
      #
      #   entities = dataset.find_all key1, key2, key3
      #   entities.size #=> 3
      #   entities.deferred #=> []
      #   entities.missing #=> []
      #   names = entities.map { |e| e["name"] }
      #   names.size #=> 3
      #   names.deferred #=> NoMethodError
      #   names.missing #=> NoMethodError
      #
      class LookupResults < DelegateClass(::Array)
        ##
        # Keys that were not looked up due to resource constraints.
        attr_accessor :deferred

        ##
        # Entities not found, with only the key populated.
        attr_accessor :missing

        ##
        # Create a new LookupResults with an array of values.
        def initialize arr = [], deferred = [], missing = []
          super arr
          @deferred = deferred
          @missing = missing
        end
      end
    end
  end
end
