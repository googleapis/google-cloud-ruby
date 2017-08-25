# Copyright 2017 Google Inc. All rights reserved.
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


require "error_reporting_helper"

describe Google::Cloud::ErrorReporting, :error_reporting do
  it "creates error events" do
    token = rand 0x10000000000000000
    service_name = "acceptance_test"
    service_version = token.to_s

    # Submit error event
    begin
      fail "Acceptance test error message with token: #{token}"
    rescue => exception
      Google::Cloud::ErrorReporting.report exception, service_name: service_name,
                                           service_version: service_version
    end

    # Query for error group
    project_id = Google::Cloud::ErrorReporting.send(:default_client).error_reporting.project
    formatted_project = Google::Cloud::ErrorReporting::V1beta1::ErrorStatsServiceClient.project_path project_id
    v1beta1 = Google::Devtools::Clouderrorreporting::V1beta1
    time_range = v1beta1::QueryTimeRange.new period: v1beta1::QueryTimeRange::Period::PERIOD_1_HOUR
    sort_order = v1beta1::ErrorGroupOrder::LAST_SEEN_DESC
    service_filter = v1beta1::ServiceContextFilter.new service: service_name,
                                                       version: service_version

    error_group_stats = nil
    wait_until do
      response = @error_stats_vtk_client.list_group_stats formatted_project,
                                                          time_range,
                                                          order: sort_order,
                                                          service_filter: service_filter
      error_group_stats = response.page.response.error_group_stats
      !error_group_stats.empty?
    end

    # Use error group id to query for actual error event that was submitted.
    error_group = error_group_stats.first.group
    error_group_id = error_group.group_id

    error_event = nil
    wait_until do
      response = @error_stats_vtk_client.list_events formatted_project,
                                                     error_group_id
      error_events = response.page.response.error_events

      error_event = error_events.find do |event|
        event.service_context.version == service_version
      end
    end

    error_event.service_context.service.must_equal service_name
    error_event.service_context.version.must_equal service_version
    error_event.message.must_match token.to_s
  end
end
