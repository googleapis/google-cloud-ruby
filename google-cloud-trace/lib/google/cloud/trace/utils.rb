# Copyright 2014 Google LLC
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
    module Trace
      ##
      # Utils provides some internal utility methods for Trace.
      #
      # @private
      #
      module Utils
        ##
        # Convert a Ruby Time object to a timestamp proto object.
        #
        # @private
        #
        def self.time_to_grpc time
          return nil if time.nil?

          # This is called with different types of objects. Extract
          # the nanoseconds appropriately.
          nanos = case
                  when time.is_a?(Time)
                    time.nsec
                  when time.is_a?(Float)
                    # Float only appear to have 6 digits of precision. Toss the rest. :shrug:
                    (time.modulo(1) * 1_000_000).truncate * 1_000
                  else
                    0
                  end

          Google::Protobuf::Timestamp.new seconds: time.to_i,
                                          nanos: nanos
        end

        ##
        # Convert a Timestamp proto object to a Ruby Time object.
        #
        # @private
        #
        def self.grpc_to_time grpc
          Time.at(grpc.seconds, Rational(grpc.nanos, 1000)).utc
        end
      end
    end
  end
end
