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
  module Storage
    class File
      ##
      # File::List is a special case Array with additional values.
      class List < DelegateClass(::Array)
        ##
        # If not empty, indicates that there are more files that match the
        # request and this value should be passed to the next
        # {Gcloud::Storage::Bucket#files} to continue.
        attr_accessor :token

        # The list of prefixes of objects matching-but-not-listed up to and
        # including the requested delimiter.
        attr_accessor :prefixes

        ##
        # @private Create a new File::List with an array of values.
        def initialize arr = []
          super arr
        end

        ##
        # Whether there a next page of files.
        def next?
          !token.nil?
        end

        ##
        # Retrieve the next page of files.
        def next
          return nil unless next?
          ensure_connection!
          options = {
            prefix: @prefix, delimiter: @delimiter, token: @token, max: @max,
            versions: @versions
          }
          resp = @connection.list_files @bucket, options
          fail ApiError.from_response(resp) unless resp.success?
          File::List.from_response resp, @connection, @bucket, @prefix,
                                   @delimiter, @max, @versions
        end

        ##
        # @private New File::List from a response object.
        def self.from_response resp, conn, bucket = nil, prefix = nil,
                               delimiter = nil, max = nil, versions = nil
          files = new(Array(resp.data["items"]).map do |gapi_object|
            File.from_gapi gapi_object, conn
          end)
          files.instance_variable_set "@token", resp.data["nextPageToken"]
          files.instance_variable_set "@prefixes", Array(resp.data["prefixes"])
          files.instance_variable_set "@connection", conn
          files.instance_variable_set "@bucket", bucket
          files.instance_variable_set "@prefix", prefix
          files.instance_variable_set "@delimiter", delimiter
          files.instance_variable_set "@max", max
          files.instance_variable_set "@versions", versions
          files
        end

        protected

        ##
        # Raise an error unless an active connection is available.
        def ensure_connection!
          fail "Must have active connection" unless @connection
        end
      end
    end
  end
end
