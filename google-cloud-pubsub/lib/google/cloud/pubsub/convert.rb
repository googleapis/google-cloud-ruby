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
    module PubSub
      ##
      # @private Helper module for converting Pub/Sub values.
      module Convert
        module ClassMethods
          def time_to_timestamp time
            return nil if time.nil?

            # Force the object to be a Time object.
            time = time.to_time

            Google::Protobuf::Timestamp.new seconds: time.to_i, nanos: time.nsec
          end

          def timestamp_to_time timestamp
            return nil if timestamp.nil?

            Time.at timestamp.seconds, Rational(timestamp.nanos, 1000)
          end

          def number_to_duration number
            return nil if number.nil?

            Google::Protobuf::Duration.new seconds: number.to_i, nanos: (number.remainder(1) * 1_000_000_000).round
          end

          def duration_to_number duration
            return nil if duration.nil?

            return duration.seconds if duration.nanos.zero?

            duration.seconds + (duration.nanos / 1_000_000_000.0)
          end

          def pubsub_message data, attributes, ordering_key, extra_attrs
            # TODO: allow data to be a Message object,
            # then ensure attributes and ordering_key are nil
            if data.is_a?(::Hash) && (attributes.nil? || attributes.empty?)
              attributes = data.merge extra_attrs
              data = nil
            else
              attributes = Hash(attributes).merge extra_attrs
            end
            # Convert IO-ish objects to strings
            if data.respond_to?(:read) && data.respond_to?(:rewind)
              data.rewind
              data = data.read
            end
            # Convert data to encoded byte array to match the protobuf defn
            data_bytes = String(data).dup.force_encoding(Encoding::ASCII_8BIT).freeze

            # Convert attributes to strings to match the protobuf definition
            attributes = Hash[attributes.map { |k, v| [String(k), String(v)] }]

            # Ordering Key must always be a string
            ordering_key = String(ordering_key).freeze

            Google::Cloud::PubSub::V1::PubsubMessage.new(
              data:         data_bytes,
              attributes:   attributes,
              ordering_key: ordering_key
            )
          end
        end

        extend ClassMethods
      end
    end

    Pubsub = PubSub unless const_defined? :Pubsub
  end
end
