# Copyright 2020 Google LLC
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
      # The `CreateService` request.
      # @!attribute [rw] parent
      #   @return [String]
      #     Required. Resource name of the parent workspace.
      #     Of the form `projects/{project_id}`.
      # @!attribute [rw] service_id
      #   @return [String]
      #     Optional. The Service id to use for this Service. If omitted, an id will be
      #     generated instead. Must match the pattern [a-z0-9\-]+
      # @!attribute [rw] service
      #   @return [Google::Monitoring::V3::Service]
      #     Required. The `Service` to create.
      class CreateServiceRequest; end

      # The `GetService` request.
      # @!attribute [rw] name
      #   @return [String]
      #     Required. Resource name of the `Service`.
      #     Of the form `projects/{project_id}/services/{service_id}`.
      class GetServiceRequest; end

      # The `ListServices` request.
      # @!attribute [rw] parent
      #   @return [String]
      #     Required. Resource name of the parent `Workspace`.
      #     Of the form `projects/{project_id}`.
      # @!attribute [rw] filter
      #   @return [String]
      #     A filter specifying what `Service`s to return. The filter currently
      #     supports the following fields:
      #
      #     * `identifier_case`
      #       * `app_engine.module_id`
      #         * `cloud_endpoints.service`
      #         * `cluster_istio.location`
      #         * `cluster_istio.cluster_name`
      #         * `cluster_istio.service_namespace`
      #         * `cluster_istio.service_name`
      #
      #         `identifier_case` refers to which option in the identifier oneof is
      #         populated. For example, the filter `identifier_case = "CUSTOM"` would match
      #         all services with a value for the `custom` field. Valid options are
      #         "CUSTOM", "APP_ENGINE", "CLOUD_ENDPOINTS", and "CLUSTER_ISTIO".
      # @!attribute [rw] page_size
      #   @return [Integer]
      #     A non-negative number that is the maximum number of results to return.
      #     When 0, use default page size.
      # @!attribute [rw] page_token
      #   @return [String]
      #     If this field is not empty then it must contain the `nextPageToken` value
      #     returned by a previous call to this method.  Using this field causes the
      #     method to return additional results from the previous method call.
      class ListServicesRequest; end

      # The `ListServices` response.
      # @!attribute [rw] services
      #   @return [Array<Google::Monitoring::V3::Service>]
      #     The `Service`s matching the specified filter.
      # @!attribute [rw] next_page_token
      #   @return [String]
      #     If there are more results than have been returned, then this field is set
      #     to a non-empty value.  To see the additional results,
      #     use that value as `pageToken` in the next call to this method.
      class ListServicesResponse; end

      # The `UpdateService` request.
      # @!attribute [rw] service
      #   @return [Google::Monitoring::V3::Service]
      #     Required. The `Service` to draw updates from.
      #     The given `name` specifies the resource to update.
      # @!attribute [rw] update_mask
      #   @return [Google::Protobuf::FieldMask]
      #     A set of field paths defining which fields to use for the update.
      class UpdateServiceRequest; end

      # The `DeleteService` request.
      # @!attribute [rw] name
      #   @return [String]
      #     Required. Resource name of the `Service` to delete.
      #     Of the form `projects/{project_id}/services/{service_id}`.
      class DeleteServiceRequest; end

      # The `CreateServiceLevelObjective` request.
      # @!attribute [rw] parent
      #   @return [String]
      #     Required. Resource name of the parent `Service`.
      #     Of the form `projects/{project_id}/services/{service_id}`.
      # @!attribute [rw] service_level_objective_id
      #   @return [String]
      #     Optional. The ServiceLevelObjective id to use for this
      #     ServiceLevelObjective. If omitted, an id will be generated instead. Must
      #     match the pattern [a-z0-9\-]+
      # @!attribute [rw] service_level_objective
      #   @return [Google::Monitoring::V3::ServiceLevelObjective]
      #     Required. The `ServiceLevelObjective` to create.
      #     The provided `name` will be respected if no `ServiceLevelObjective` exists
      #     with this name.
      class CreateServiceLevelObjectiveRequest; end

      # The `GetServiceLevelObjective` request.
      # @!attribute [rw] name
      #   @return [String]
      #     Required. Resource name of the `ServiceLevelObjective` to get.
      #     Of the form
      #     `projects/{project_id}/services/{service_id}/serviceLevelObjectives/{slo_name}`.
      # @!attribute [rw] view
      #   @return [Google::Monitoring::V3::ServiceLevelObjective::View]
      #     View of the `ServiceLevelObjective` to return. If `DEFAULT`, return the
      #     `ServiceLevelObjective` as originally defined. If `EXPLICIT` and the
      #     `ServiceLevelObjective` is defined in terms of a `BasicSli`, replace the
      #     `BasicSli` with a `RequestBasedSli` spelling out how the SLI is computed.
      class GetServiceLevelObjectiveRequest; end

      # The `ListServiceLevelObjectives` request.
      # @!attribute [rw] parent
      #   @return [String]
      #     Required. Resource name of the parent `Service`.
      #     Of the form `projects/{project_id}/services/{service_id}`.
      # @!attribute [rw] filter
      #   @return [String]
      #     A filter specifying what `ServiceLevelObjective`s to return.
      # @!attribute [rw] page_size
      #   @return [Integer]
      #     A non-negative number that is the maximum number of results to return.
      #     When 0, use default page size.
      # @!attribute [rw] page_token
      #   @return [String]
      #     If this field is not empty then it must contain the `nextPageToken` value
      #     returned by a previous call to this method.  Using this field causes the
      #     method to return additional results from the previous method call.
      # @!attribute [rw] view
      #   @return [Google::Monitoring::V3::ServiceLevelObjective::View]
      #     View of the `ServiceLevelObjective`s to return. If `DEFAULT`, return each
      #     `ServiceLevelObjective` as originally defined. If `EXPLICIT` and the
      #     `ServiceLevelObjective` is defined in terms of a `BasicSli`, replace the
      #     `BasicSli` with a `RequestBasedSli` spelling out how the SLI is computed.
      class ListServiceLevelObjectivesRequest; end

      # The `ListServiceLevelObjectives` response.
      # @!attribute [rw] service_level_objectives
      #   @return [Array<Google::Monitoring::V3::ServiceLevelObjective>]
      #     The `ServiceLevelObjective`s matching the specified filter.
      # @!attribute [rw] next_page_token
      #   @return [String]
      #     If there are more results than have been returned, then this field is set
      #     to a non-empty value.  To see the additional results,
      #     use that value as `pageToken` in the next call to this method.
      class ListServiceLevelObjectivesResponse; end

      # The `UpdateServiceLevelObjective` request.
      # @!attribute [rw] service_level_objective
      #   @return [Google::Monitoring::V3::ServiceLevelObjective]
      #     Required. The `ServiceLevelObjective` to draw updates from.
      #     The given `name` specifies the resource to update.
      # @!attribute [rw] update_mask
      #   @return [Google::Protobuf::FieldMask]
      #     A set of field paths defining which fields to use for the update.
      class UpdateServiceLevelObjectiveRequest; end

      # The `DeleteServiceLevelObjective` request.
      # @!attribute [rw] name
      #   @return [String]
      #     Required. Resource name of the `ServiceLevelObjective` to delete.
      #     Of the form
      #     `projects/{project_id}/services/{service_id}/serviceLevelObjectives/{slo_name}`.
      class DeleteServiceLevelObjectiveRequest; end
    end
  end
end