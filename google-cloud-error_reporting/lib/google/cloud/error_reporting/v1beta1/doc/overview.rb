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

module Google
  module Cloud
    # rubocop:disable LineLength

    ##
    # # Ruby Client for Stackdriver Error Reporting API ([Beta](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))
    #
    # [Stackdriver Error Reporting API][Product Documentation]:
    # Stackdriver Error Reporting groups and counts similar errors from cloud
    # services. The Stackdriver Error Reporting API provides a way to report new
    # errors and read access to error groups and their associated errors.
    # - [Product Documentation][]
    #
    # ## Quick Start
    # In order to use this library, you first need to go through the following
    # steps:
    #
    # 1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
    # 2. [Enable the Stackdriver Error Reporting API.](https://console.cloud.google.com/apis/api/error-reporting)
    # 3. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)
    #
    # ### Installation
    # ```
    # $ gem install google-cloud-error_reporting
    # ```
    #
    # ### Preview
    # #### ReportErrorsServiceClient
    # ```rb
    # require "google/cloud/error_reporting"
    #
    # report_errors_service_client = Google::Cloud::ErrorReporting::ReportErrors.new
    # formatted_project_name = Google::Cloud::ErrorReporting::V1beta1::ReportErrorsServiceClient.project_path(project_id)
    # message = "[MESSAGE]"
    # service = "[SERVICE]"
    # service_context = { service: service }
    # file_path = "path/to/file.lang"
    # line_number = 42
    # function_name = "meaningOfLife"
    # report_location = {
    #   file_path: file_path,
    #   line_number: line_number,
    #   function_name: function_name
    # }
    # context = { report_location: report_location }
    # event = {
    #   message: message,
    #   service_context: service_context,
    #   context: context
    # }
    # response = report_errors_service_client.report_error_event(formatted_project_name, event)
    # ```
    #
    # ### Next Steps
    # - Read the [Stackdriver Error Reporting API Product documentation][Product Documentation]
    #   to learn more about the product and see How-to Guides.
    # - View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
    #   to see the full list of Cloud APIs that we cover.
    #
    # [Product Documentation]: https://cloud.google.com/error-reporting
    #
    #
    module ErrorReporting
      module V1beta1
      end
    end
  end
end
