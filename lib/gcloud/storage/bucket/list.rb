#--
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

module Gcloud
  module Storage
    class Bucket
      ##
      # Bucket::List is a special case Array with additional values.
      class List < DelegateClass(::Array)
        ##
        # If not empty, indicates that there are more buckets
        # that match the request and this value should be passed to
        # the next Gcloud::Storage::Project#buckets to continue.
        attr_accessor :token

        ##
        # Create a new Bucket::List with an array of values.
        def initialize arr = [], token = nil
          super arr
          @token = token
        end

        ##
        # New Bucket::List from a response object.
        def self.from_response resp, conn #:nodoc:
          buckets = Array(resp.data["items"]).map do |gapi_object|
            Bucket.from_gapi gapi_object, conn
          end
          new buckets, resp.data["nextPageToken"]
        end
      end
    end
  end
end
