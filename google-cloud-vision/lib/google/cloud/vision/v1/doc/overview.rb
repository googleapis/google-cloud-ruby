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
    # # Ruby Client for Google Cloud Vision API ([Alpha](https://github.com/GoogleCloudPlatform/google-cloud-ruby#versioning))
    #
    # [Google Cloud Vision API][Product Documentation]:
    # Integrates Google Vision features, including image labeling, face, logo, and
    # landmark detection, optical character recognition (OCR), and detection of
    # explicit content, into applications.
    # - [Product Documentation][]
    #
    # ## Quick Start
    # In order to use this library, you first need to go through the following
    # steps:
    #
    # 1. [Select or create a Cloud Platform project.](https://console.cloud.google.com/project)
    # 2. [Enable the Google Cloud Vision API.](https://console.cloud.google.com/apis/api/vision)
    # 3. [Setup Authentication.](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud/master/guides/authentication)
    #
    # ### Installation
    # ```
    # $ gem install google-cloud-vision
    # ```
    #
    # ### Preview
    # #### ImageAnnotatorClient
    # ```rb
    # require "google/cloud/vision"
    #
    # image_annotator_client = Google::Cloud::Vision.new
    # gcs_image_uri = "gs://gapic-toolkit/President_Barack_Obama.jpg"
    # source = { gcs_image_uri: gcs_image_uri }
    # image = { source: source }
    # type = :FACE_DETECTION
    # features_element = { type: type }
    # features = [features_element]
    # requests_element = { image: image, features: features }
    # requests = [requests_element]
    # response = image_annotator_client.batch_annotate_images(requests)
    # ```
    #
    # ### Next Steps
    # - Read the [Google Cloud Vision API Product documentation][Product Documentation]
    #   to learn more about the product and see How-to Guides.
    # - View this [repository's main README](https://github.com/GoogleCloudPlatform/google-cloud-ruby/blob/master/README.md)
    #   to see the full list of Cloud APIs that we cover.
    #
    # [Product Documentation]: https://cloud.google.com/vision
    #
    #
    module Vision
      module V1
      end
    end
  end
end