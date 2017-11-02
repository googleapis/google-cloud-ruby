# Copyright 2017, Google Inc. All rights reserved.
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
    # # Ruby Client for Google Cloud Pub/Sub API ([Alpha](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))
    #
    # [Google Cloud Pub/Sub API][Product Documentation]:
    # Provides reliable, many-to-many, asynchronous messaging between applications.
    # - [Product Documentation][]
    #
    # ## Quick Start
    # In order to use this library, you first need to go through the following
    # steps:
    #
    # 1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
    # 2. [Enable the Google Cloud Pub/Sub API.](https://console.cloud.google.com/apis/api/pubsub)
    # 3. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)
    #
    # ### Installation
    # ```
    # $ gem install google-cloud-pubsub
    # ```
    #
    # ### Preview
    # #### PublisherClient
    # ```rb
    # require "google/cloud/pubsub"
    #
    # publisher_client = Google::Cloud::Pubsub::Publisher.new
    # formatted_project = Google::Cloud::Pubsub::V1::PublisherClient.project_path(project_id)
    #
    # # Iterate over all results.
    # publisher_client.list_topics(formatted_project).each do |element|
    #   # Process element.
    # end
    #
    # # Or iterate over results one page at a time.
    # publisher_client.list_topics(formatted_project).each_page do |page|
    #   # Process each page at a time.
    #   page.each do |element|
    #     # Process element.
    #   end
    # end
    # ```
    #
    # ### Next Steps
    # - Read the [Google Cloud Pub/Sub API Product documentation][Product Documentation]
    #   to learn more about the product and see How-to Guides.
    # - View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
    #   to see the full list of Cloud APIs that we cover.
    #
    # [Product Documentation]: https://cloud.google.com/pubsub
    #
    #
    module Pubsub
      module V1
      end
    end
  end
end