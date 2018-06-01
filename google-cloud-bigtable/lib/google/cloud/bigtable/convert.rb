# frozen_string_literal: true

# Copyright 2018 Google LLC
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


require "time"
require "date"

module Google
  module Cloud
    module Bigtable
      # @private
      # Helper module for converting Bigtable values.
      module Convert
        module_function

        # Convert number to protobuf duration.
        #
        # @param number [Float] Seconds with nano seconds
        # @return [Google::Protobuf::Duration, nil]
        def number_to_duration number
          return unless number

          Google::Protobuf::Duration.new(
            seconds: number.to_i,
            nanos: (number.remainder(1) * 1000000000).round
          )
        end

        # Convert protobuf durations to float.
        #
        # @param duration [Google::Protobuf::Duration, nil]
        # @return [Float, Integer, nil] Seconds with nano seconds
        def duration_to_number duration
          return unless duration
          return duration.seconds if duration.nanos.zero?

          duration.seconds + (duration.nanos / 1000000000.0)
        end

        # Convert protobuf timestamp to Time object.
        #
        # @param timestamp [Google::Protobuf::Timestamp]
        # @return [Time, nil]
        def timestamp_to_time timestamp
          return unless timestamp

          Time.at(timestamp.seconds, timestamp.nanos / 1000.0)
        end

        # Convert time to timestamp protobuf object.
        #
        # @param time [Time]
        # @return [Google::Protobuf::Timestamp, nil]
        def time_to_timestamp time
          return unless time

          Google::Protobuf::Timestamp.new(seconds: time.to_i, nanos: time.nsec)
        end
      end
    end
  end
end
