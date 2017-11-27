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
    # # Ruby Client for Google Cloud Natural Language API ([Alpha](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))
    #
    # [Google Cloud Natural Language API][Product Documentation]:
    # Google Cloud Natural Language API provides natural language understanding
    # technologies to developers. Examples include sentiment analysis, entity
    # recognition, and text annotations.
    # - [Product Documentation][]
    #
    # ## Quick Start
    # In order to use this library, you first need to go through the following
    # steps:
    #
    # 1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
    # 2. [Enable the Google Cloud Natural Language API.](https://console.cloud.google.com/apis/api/language)
    # 3. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)
    #
    # ### Installation
    # ```
    # $ gem install google-cloud-language
    # ```
    #
    # ### Preview
    # #### LanguageServiceClient
    # ```rb
    # require "google/cloud/language"
    #
    # language_service_client = Google::Cloud::Language.new
    # content = "Hello, world!"
    # type = :PLAIN_TEXT
    # document = { content: content, type: type }
    # response = language_service_client.analyze_sentiment(document)
    # ```
    #
    # ### Next Steps
    # - Read the [Google Cloud Natural Language API Product documentation][Product Documentation]
    #   to learn more about the product and see How-to Guides.
    # - View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
    #   to see the full list of Cloud APIs that we cover.
    #
    # [Product Documentation]: https://cloud.google.com/natural-language
    #
    #
    module Language
      module V1
      end
    end
  end
end
