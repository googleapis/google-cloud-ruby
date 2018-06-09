# frozen_string_literal: true

# Copyright 2017 Google LLC
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

module Google
  module Cloud
    module Pubsub
      ##
      # @private Helper module for converting Pub/Sub values.
      module Convert
        module ClassMethods
          def time_to_timestamp time
            return nil if time.nil?

            # Force the object to be a Time object.
            time = time.to_time

            Google::Protobuf::Timestamp.new \
              seconds: time.to_i,
              nanos: time.nsec
          end

          def timestamp_to_time timestamp
            return nil if timestamp.nil?

            Time.at timestamp.seconds, Rational(timestamp.nanos, 1000)
          end

          def number_to_duration number
            return nil if number.nil?

            Google::Protobuf::Duration.new \
              seconds: number.to_i,
              nanos: (number.remainder(1) * 1000000000).round
          end

          def duration_to_number duration
            return nil if duration.nil?

            return duration.seconds if duration.nanos.zero?

            duration.seconds + (duration.nanos / 1000000000.0)
          end
        end

        extend ClassMethods
      end
    end
  end
end
