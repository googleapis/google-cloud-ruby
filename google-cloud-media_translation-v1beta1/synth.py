# Copyright 2020 Google LLC
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

"""This script is used to synthesize generated parts of this library."""

import synthtool as s
import synthtool.gcp as gcp
import synthtool.languages.ruby as ruby
import logging


logging.basicConfig(level=logging.DEBUG)

gapic = gcp.GAPICMicrogenerator()
library = gapic.ruby_library(
    "mediatranslation", "v1beta1",
    extra_proto_files=["google/cloud/common_resources.proto"],
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-media_translation-v1beta1",
        "ruby-cloud-title": "Media Translation V1beta1",
        "ruby-cloud-description": "Media Translation API delivers real-time speech translation to your content and applications directly from your audio data. Leveraging Google’s machine learning technologies, the API offers enhanced accuracy and simplified integration while equipping you with a comprehensive set of features to further refine your translation results. Improve user experience with low-latency streaming translation and scale quickly with straightforward internationalization.",
        "ruby-cloud-env-prefix": "MEMCACHE",
        "ruby-cloud-grpc-service-config": "google/cloud/mediatranslation/v1beta1/mediatranslation_grpc_service_config.json",
        "ruby-cloud-product-url": "https://cloud.google.com/media-translation/",
        "ruby-cloud-api-id": "mediatranslation.googleapis.com",
        "ruby-cloud-api-shortname": "mediatranslation",
    }
)

s.copy(library, merge=ruby.global_merge)
