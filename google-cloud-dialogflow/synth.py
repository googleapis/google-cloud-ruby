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
    "dialogflow", "v2",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-dialogflow",
        "ruby-cloud-title": "Dialogflow",
        "ruby-cloud-description": "Dialogflow is an end-to-end, build-once deploy-everywhere development suite for creating conversational interfaces for websites, mobile applications, popular messaging platforms, and IoT devices. You can use it to build interfaces (such as chatbots and conversational IVR) that enable natural and rich interactions between your users and your business. This client is for Dialogflow ES, providing the standard agent type suitable for small and simple agents.",
        "ruby-cloud-env-prefix": "DIALOGFLOW",
        "ruby-cloud-wrapper-of": "v2:0.8",
        "ruby-cloud-product-url": "https://cloud.google.com/dialogflow",
        "ruby-cloud-api-id": "dialogflow.googleapis.com",
        "ruby-cloud-api-shortname": "dialogflow",
        "ruby-cloud-migration-version": "1.0",
    }
)

s.copy(library, merge=ruby.global_merge)
