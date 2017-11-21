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
    # # Ruby Client for DLP API ([Alpha](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))
    #
    # [DLP API][Product Documentation]:
    # The Google Data Loss Prevention API provides methods for detection of
    # privacy-sensitive fragments in text, images, and Google Cloud Platform
    # storage repositories.
    # - [Product Documentation][]
    #
    # ## Quick Start
    # In order to use this library, you first need to go through the following
    # steps:
    #
    # 1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
    # 2. [Enable the DLP API.](https://console.cloud.google.com/apis/api/dlp)
    # 3. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)
    #
    # ### Installation
    # ```
    # $ gem install google-cloud-dlp
    # ```
    #
    # ### Preview
    # #### DlpServiceClient
    # ```rb
    # require "google/cloud/dlp"
    #
    # dlp_service_client = Google::Cloud::Dlp.new
    # min_likelihood = :POSSIBLE
    # inspect_config = { min_likelihood: min_likelihood }
    # type = "text/plain"
    # value = "my phone number is 215-512-1212"
    # items_element = { type: type, value: value }
    # items = [items_element]
    # response = dlp_service_client.inspect_content(inspect_config, items)
    # ```
    #
    # ### Next Steps
    # - Read the [DLP API Product documentation][Product Documentation]
    #   to learn more about the product and see How-to Guides.
    # - View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
    #   to see the full list of Cloud APIs that we cover.
    #
    # [Product Documentation]: https://cloud.google.com/dlp
    #
    #
    module Dlp
      module V2beta1
      end
    end
  end
end