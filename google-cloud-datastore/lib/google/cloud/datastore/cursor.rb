# Copyright 2016 Google LLC
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
    module Datastore
      ##
      # # Cursor
      #
      # Cursor is a point in query results. Cursors are returned in
      # QueryResults.
      #
      # @example
      #   require "google/cloud/datastore"
      #
      #   datastore = Google::Cloud::Datastore.new
      #
      #   query = datastore.query("Task").
      #     where("done", "=", false)
      #
      #   tasks = datastore.run query
      #   tasks.cursor.to_s #=> "c2Vjb25kLXBhZ2UtY3Vyc29y"
      #
      class Cursor
        # Base64 encoded array of bytes
        def initialize cursor
          @cursor = cursor
        end

        # Base64 encoded array of bytes
        def to_s
          @cursor
        end

        # @private
        def inspect
          "#{self.class}(#{@cursor})"
        end

        # @private
        def == other
          return false unless other.is_a? Cursor
          @cursor == other.to_s
        end

        # @private
        def <=> other
          return -1 unless other.is_a? Cursor
          @cursor <=> other.to_s
        end

        # @private byte array as a string
        def to_grpc
          Convert.decode_bytes(@cursor)
        end

        # @private byte array as a string
        def self.from_grpc grpc
          grpc = String grpc
          return nil if grpc.empty?
          new Convert.encode_bytes(grpc)
        end
      end
    end
  end
end
