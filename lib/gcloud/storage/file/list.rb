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
    class File
      class List < DelegateClass(::Array)
        ##
        # If not empty, indicates that there are more buckets
        # that match the request and this value should be passed to
        # the next Gcloud::Storage::Bucket#files to continue.
        attr_accessor :token

        # The list of prefixes of objects matching-but-not-listed up
        # to and including the requested delimiter.
        attr_accessor :prefixes

        ##
        # Create a new File::List with an array of values.
        def initialize arr = [], token = nil, prefixes = []
          super arr
          @token = token
          @prefixes = prefixes
        end

        ##
        # New File::List from a response object.
        def self.from_resp resp, conn #:nodoc:
          buckets = Array(resp.data["items"]).map do |gapi_object|
            File.from_gapi gapi_object, conn
          end
          token = resp.data["nextPageToken"]
          prefixes = Array resp.data["prefixes"]
          new buckets, token, prefixes
        end
      end
    end
  end
end
