# Copyright 2017, Google LLC All rights reserved.
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

module Google
  module Cloud
    # rubocop:disable LineLength

    ##
    # # Ruby Client for Stackdriver Logging API ([Alpha](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))
    #
    # [Stackdriver Logging API][Product Documentation]:
    # Writes log entries and manages your Stackdriver Logging configuration.
    # - [Product Documentation][]
    #
    # ## Quick Start
    # In order to use this library, you first need to go through the following
    # steps:
    #
    # 1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
    # 2. [Enable the Stackdriver Logging API.](https://console.cloud.google.com/apis/api/logging)
    # 3. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)
    #
    # ### Installation
    # ```
    # $ gem install google-cloud-logging
    # ```
    #
    # ### Preview
    # #### LoggingServiceV2Client
    # ```rb
    # require "google/cloud/logging"
    #
    # logging_service_v2_client = Google::Cloud::Logging::Logging.new
    # formatted_log_name = Google::Cloud::Logging::V2::LoggingServiceV2Client.log_path(project_id, "test-" + Time.new.to_i.to_s)
    # resource = {}
    # labels = {}
    # entries = []
    # response = logging_service_v2_client.write_log_entries(entries, log_name: formatted_log_name, resource: resource, labels: labels)
    # ```
    #
    # ### Next Steps
    # - Read the [Stackdriver Logging API Product documentation][Product Documentation]
    #   to learn more about the product and see How-to Guides.
    # - View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
    #   to see the full list of Cloud APIs that we cover.
    #
    # [Product Documentation]: https://cloud.google.com/logging
    #
    #
    module Logging
      module V2
      end
    end
  end
end