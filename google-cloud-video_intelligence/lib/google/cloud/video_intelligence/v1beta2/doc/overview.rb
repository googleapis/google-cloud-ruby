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
    # # Ruby Client for Google Cloud Video Intelligence API ([Alpha](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))
    #
    # [Google Cloud Video Intelligence API][Product Documentation]:
    # Google Cloud Video Intelligence API.
    # - [Product Documentation][]
    #
    # ## Quick Start
    # In order to use this library, you first need to go through the following
    # steps:
    #
    # 1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
    # 2. [Enable the Google Cloud Video Intelligence API.](https://console.cloud.google.com/apis/api/video-intelligence)
    # 3. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)
    #
    # ### Installation
    # ```
    # $ gem install google-cloud-video_intelligence
    # ```
    #
    # ### Preview
    # #### VideoIntelligenceServiceClient
    # ```rb
    # require "google/cloud/video_intelligence"
    #
    # video_intelligence_service_client = Google::Cloud::VideoIntelligence.new
    # input_uri = "gs://cloud-ml-sandbox/video/chicago.mp4"
    # features_element = :LABEL_DETECTION
    # features = [features_element]
    #
    # # Register a callback during the method call.
    # operation = video_intelligence_service_client.annotate_video(input_uri: input_uri, features: features) do |op|
    #   raise op.results.message if op.error?
    #   op_results = op.results
    #   # Process the results.
    #
    #   metadata = op.metadata
    #   # Process the metadata.
    # end
    #
    # # Or use the return value to register a callback.
    # operation.on_done do |op|
    #   raise op.results.message if op.error?
    #   op_results = op.results
    #   # Process the results.
    #
    #   metadata = op.metadata
    #   # Process the metadata.
    # end
    #
    # # Manually reload the operation.
    # operation.reload!
    #
    # # Or block until the operation completes, triggering callbacks on
    # # completion.
    # operation.wait_until_done!
    # ```
    #
    # ### Next Steps
    # - Read the [Google Cloud Video Intelligence API Product documentation][Product Documentation]
    #   to learn more about the product and see How-to Guides.
    # - View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
    #   to see the full list of Cloud APIs that we cover.
    #
    # [Product Documentation]: https://cloud.google.com/video-intelligence
    #
    #
    module VideoIntelligence
      module V1beta2
      end
    end
  end
end
