# frozen_string_literal: true

# Copyright 2025 Google LLC
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

# Auto-generated by gapic-generator-ruby. DO NOT EDIT!


module Google
  module Ads
    module AdManager
      module V1
        module AdBreakService
          # Path helper methods for the AdBreakService API.
          module Paths
            ##
            # Create a fully-qualified AdBreak resource string.
            #
            # The resource will be in the following format:
            #
            # `networks/{network_code}/liveStreamEventsByAssetKey/{asset_key}/adBreaks/{ad_break}`
            #
            # @param network_code [String]
            # @param asset_key [String]
            # @param ad_break [String]
            #
            # @return [::String]
            def ad_break_path network_code:, asset_key:, ad_break:
              raise ::ArgumentError, "network_code cannot contain /" if network_code.to_s.include? "/"
              raise ::ArgumentError, "asset_key cannot contain /" if asset_key.to_s.include? "/"

              "networks/#{network_code}/liveStreamEventsByAssetKey/#{asset_key}/adBreaks/#{ad_break}"
            end

            ##
            # Create a fully-qualified LiveStreamEvent resource string.
            #
            # The resource will be in the following format:
            #
            # `networks/{network_code}/liveStreamEvents/{live_stream_event}`
            #
            # @param network_code [String]
            # @param live_stream_event [String]
            #
            # @return [::String]
            def live_stream_event_path network_code:, live_stream_event:
              raise ::ArgumentError, "network_code cannot contain /" if network_code.to_s.include? "/"

              "networks/#{network_code}/liveStreamEvents/#{live_stream_event}"
            end

            extend self
          end
        end
      end
    end
  end
end
