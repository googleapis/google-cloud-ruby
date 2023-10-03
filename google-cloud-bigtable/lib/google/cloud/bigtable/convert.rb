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
require "gapic/protobuf"
require "gapic/call_options"
require "gapic/headers"
require "google/cloud/bigtable/version"
require "google/cloud/bigtable/v2/version"
require "google/bigtable/v2/bigtable_pb"
require "google/cloud/bigtable/admin/v2"

module Google
  module Cloud
    module Bigtable
      # @private
      # Helper module for converting Bigtable values.
      module Convert
        module_function

        ##
        # Convert number to protobuf duration.
        #
        # @param number [Float] Seconds with nano seconds
        # @return [Google::Protobuf::Duration, nil]
        #
        def number_to_duration number
          return unless number

          Google::Protobuf::Duration.new(
            seconds: number.to_i,
            nanos:   (number.remainder(1) * 1_000_000_000).round
          )
        end

        ##
        # Convert protobuf durations to float.
        #
        # @param duration [Google::Protobuf::Duration, nil]
        # @return [Float, Integer, nil] Seconds with nano seconds
        #
        def duration_to_number duration
          return unless duration
          return duration.seconds if duration.nanos.zero?

          duration.seconds + (duration.nanos / 1_000_000_000.0)
        end

        ##
        # Convert protobuf timestamp to Time object.
        #
        # @param timestamp [Google::Protobuf::Timestamp]
        # @return [Time, nil]
        #
        def timestamp_to_time timestamp
          return unless timestamp

          Time.at timestamp.seconds, timestamp.nanos / 1000.0
        end

        ##
        # Convert time to timestamp protobuf object.
        #
        # @param time [Time]
        # @return [Google::Protobuf::Timestamp, nil]
        #
        def time_to_timestamp time
          return unless time

          Google::Protobuf::Timestamp.new seconds: time.to_i, nanos: time.nsec
        end

        ##
        # Converts an Integer to 64-bit signed big-endian integer data.
        # Returns a string argument unchanged.
        #
        # @param value [String, Integer]
        # @return [String]
        #
        def integer_to_signed_be_64 value
          return [value].pack "q>" if value.is_a? Integer
          value
        end

        def ping_and_warm_request table_path, app_profile_id, timeout
          request = {
            name: table_path.split("/").slice(0, 4).join("/"),
            app_profile_id: app_profile_id
          }
          request = ::Gapic::Protobuf.coerce request, to: ::Google::Cloud::Bigtable::V2::PingAndWarmRequest

          header_params = {}
          if request.name && %r{^projects/[^/]+/instances/[^/]+/?$}.match?(request.name)
            header_params["name"] = request.name
          end
          if request.app_profile_id && !request.app_profile_id.empty?
            header_params["app_profile_id"] = request.app_profile_id
          end
          request_params_header = URI.encode_www_form header_params
          metadata = {
            "x-goog-request-params": request_params_header,
            "x-goog-api-client":
              ::Gapic::Headers.x_goog_api_client(lib_name: "gccl",
                                                 lib_version: ::Google::Cloud::Bigtable::VERSION,
                                                 gapic_version: ::Google::Cloud::Bigtable::V2::VERSION),
            "google-cloud-resource-prefix": "projects/#{table_path.split('/')[1]}"
          }
          options = ::Gapic::CallOptions.new timeout: timeout, metadata: metadata
          [request, options]
        end
      end
    end
  end
end
