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


module Google
  module Monitoring
    module V3
      # The protocol for the `ListUptimeCheckConfigs` request.
      # @!attribute [rw] parent
      #   @return [String]
      #     The project whose uptime check configurations are listed. The format
      #       is `projects/[PROJECT_ID]`.
      # @!attribute [rw] page_size
      #   @return [Integer]
      #     The maximum number of results to return in a single response. The server
      #     may further constrain the maximum number of results returned in a single
      #     page. If the page_size is <=0, the server will decide the number of results
      #     to be returned.
      # @!attribute [rw] page_token
      #   @return [String]
      #     If this field is not empty then it must contain the `nextPageToken` value
      #     returned by a previous call to this method.  Using this field causes the
      #     method to return more results from the previous method call.
      class ListUptimeCheckConfigsRequest; end

      # The protocol for the `ListUptimeCheckConfigs` response.
      # @!attribute [rw] uptime_check_configs
      #   @return [Array<Google::Monitoring::V3::UptimeCheckConfig>]
      #     The returned uptime check configurations.
      # @!attribute [rw] next_page_token
      #   @return [String]
      #     This field represents the pagination token to retrieve the next page of
      #     results. If the value is empty, it means no further results for the
      #     request. To retrieve the next page of results, the value of the
      #     next_page_token is passed to the subsequent List method call (in the
      #     request message's page_token field).
      # @!attribute [rw] total_size
      #   @return [Integer]
      #     The total number of uptime check configurations for the project,
      #     irrespective of any pagination.
      class ListUptimeCheckConfigsResponse; end

      # The protocol for the `GetUptimeCheckConfig` request.
      # @!attribute [rw] name
      #   @return [String]
      #     The uptime check configuration to retrieve. The format
      #       is `projects/[PROJECT_ID]/uptimeCheckConfigs/[UPTIME_CHECK_ID]`.
      class GetUptimeCheckConfigRequest; end

      # The protocol for the `CreateUptimeCheckConfig` request.
      # @!attribute [rw] parent
      #   @return [String]
      #     The project in which to create the uptime check. The format
      #       is `projects/[PROJECT_ID]`.
      # @!attribute [rw] uptime_check_config
      #   @return [Google::Monitoring::V3::UptimeCheckConfig]
      #     The new uptime check configuration.
      class CreateUptimeCheckConfigRequest; end

      # The protocol for the `UpdateUptimeCheckConfig` request.
      # @!attribute [rw] update_mask
      #   @return [Google::Protobuf::FieldMask]
      #     Optional. If present, only the listed fields in the current uptime check
      #     configuration are updated with values from the new configuration. If this
      #     field is empty, then the current configuration is completely replaced with
      #     the new configuration.
      # @!attribute [rw] uptime_check_config
      #   @return [Google::Monitoring::V3::UptimeCheckConfig]
      #     Required. If an `"updateMask"` has been specified, this field gives
      #     the values for the set of fields mentioned in the `"updateMask"`. If an
      #     `"updateMask"` has not been given, this uptime check configuration replaces
      #     the current configuration. If a field is mentioned in `"updateMask"` but
      #     the corresonding field is omitted in this partial uptime check
      #     configuration, it has the effect of deleting/clearing the field from the
      #     configuration on the server.
      #
      #     The following fields can be updated: `display_name`,
      #     `http_check`, `tcp_check`, `timeout`, `content_matchers`, and
      #     `selected_regions`.
      class UpdateUptimeCheckConfigRequest; end

      # The protocol for the `DeleteUptimeCheckConfig` request.
      # @!attribute [rw] name
      #   @return [String]
      #     The uptime check configuration to delete. The format
      #       is `projects/[PROJECT_ID]/uptimeCheckConfigs/[UPTIME_CHECK_ID]`.
      class DeleteUptimeCheckConfigRequest; end

      # The protocol for the `ListUptimeCheckIps` request.
      # @!attribute [rw] page_size
      #   @return [Integer]
      #     The maximum number of results to return in a single response. The server
      #     may further constrain the maximum number of results returned in a single
      #     page. If the page_size is <=0, the server will decide the number of results
      #     to be returned.
      #     NOTE: this field is not yet implemented
      # @!attribute [rw] page_token
      #   @return [String]
      #     If this field is not empty then it must contain the `nextPageToken` value
      #     returned by a previous call to this method.  Using this field causes the
      #     method to return more results from the previous method call.
      #     NOTE: this field is not yet implemented
      class ListUptimeCheckIpsRequest; end

      # The protocol for the `ListUptimeCheckIps` response.
      # @!attribute [rw] uptime_check_ips
      #   @return [Array<Google::Monitoring::V3::UptimeCheckIp>]
      #     The returned list of IP addresses (including region and location) that the
      #     checkers run from.
      # @!attribute [rw] next_page_token
      #   @return [String]
      #     This field represents the pagination token to retrieve the next page of
      #     results. If the value is empty, it means no further results for the
      #     request. To retrieve the next page of results, the value of the
      #     next_page_token is passed to the subsequent List method call (in the
      #     request message's page_token field).
      #     NOTE: this field is not yet implemented
      class ListUptimeCheckIpsResponse; end
    end
  end
end