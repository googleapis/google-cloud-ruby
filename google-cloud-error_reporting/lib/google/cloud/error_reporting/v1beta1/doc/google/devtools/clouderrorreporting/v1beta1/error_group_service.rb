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
  module Devtools
    module Clouderrorreporting
      ##
      # # Stackdriver Error Reporting API Contents
      #
      # | Class | Description |
      # | ----- | ----------- |
      # | [ErrorGroupServiceClient][] | Service for retrieving and updating individual error groups. |
      # | [Data Types][] | Data types for Google::Cloud::ErrorReporting::V1beta1 |
      #
      # [ErrorGroupServiceClient]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-error_reporting/latest/google/devtools/clouderrorreporting/v1beta1/errorgroupserviceclient
      # [Data Types]: https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-error_reporting/latest/google/devtools/clouderrorreporting/v1beta1/datatypes
      #
      module V1beta1
        # A request to return an individual group.
        # @!attribute [rw] group_name
        #   @return [String]
        #     [Required] The group resource name. Written as
        #     <code>projects/<var>projectID</var>/groups/<var>group_name</var></code>.
        #     Call
        #     <a href="/error-reporting/reference/rest/v1beta1/projects.groupStats/list">
        #     <code>groupStats.list</code></a> to return a list of groups belonging to
        #     this project.
        #
        #     Example: <code>projects/my-project-123/groups/my-group</code>
        class GetGroupRequest; end

        # A request to replace the existing data for the given group.
        # @!attribute [rw] group
        #   @return [Google::Devtools::Clouderrorreporting::V1beta1::ErrorGroup]
        #     [Required] The group which replaces the resource on the server.
        class UpdateGroupRequest; end
      end
    end
  end
end