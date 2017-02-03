# Copyright 2016 Google Inc. All rights reserved.
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


require "google/cloud/spanner/convert"

module Google
  module Cloud
    module Spanner
      ##
      # # Results
      #
      class Results
        ##
        # @private The gRPC Service object.
        attr_accessor :grpc

        def types
          row_types = @grpc.metadata.row_type.fields
          Hash[row_types.map do |field|
            # raise field.inspect
            if field.type.code == :ARRAY
              [field.name.to_sym, [field.type.array_element_type.code]]
            else
              [field.name.to_sym, field.type.code]
            end
          end]
        end

        def rows
          @rows ||= @grpc.rows.map do |row|
            Convert.row_to_raw grpc.metadata.row_type.fields, row.values
          end
        end

        # @private
        def self.from_grpc grpc
          results = new
          results.instance_variable_set :@grpc, grpc
          results
        end
      end
    end
  end
end
