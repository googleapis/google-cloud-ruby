# Copyright 2015 Google Inc. All rights reserved.
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
  module Bigquery
    class Dataset
      ##
      # Dataset::List is a special case Array with additional values.
      class List < DelegateClass(::Array)
        ##
        # If not empty, indicates that there are more records that match
        # the request and this value should be passed to continue.
        attr_accessor :token

        # A hash of this page of results.
        attr_accessor :etag

        ##
        # Create a new Dataset::List with an array of datasets.
        def initialize arr = []
          super arr
        end

        ##
        # @private New Dataset::List from a response object.
        def self.from_response resp, conn
          datasets = List.new(Array(resp.data["datasets"]).map do |gapi_object|
            Dataset.from_gapi gapi_object, conn
          end)
          datasets.instance_variable_set "@token", resp.data["nextPageToken"]
          datasets.instance_variable_set "@etag",  resp.data["etag"]
          datasets
        end
      end
    end
  end
end
