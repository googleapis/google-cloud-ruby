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
    ##
    # List is a special case Array with cursor.
    #
    #   entities = Gcloud::Datastore::List.new [entity1, entity2, entity3]
    #   entities.cursor = "c3VwZXJhd2Vzb21lIQ"
    class List < DelegateClass(::Array)
      attr_accessor :cursor

      def initialize arr = [], cursor = nil
        super arr
        @cursor = cursor
      end
    end
  end
end
