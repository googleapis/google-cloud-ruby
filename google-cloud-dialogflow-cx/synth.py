# Copyright 2021 Google LLC
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
    "dialogflow/cx", "v3",
    proto_path="google/cloud/dialogflow/cx/v3",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-dialogflow-cx",
        "ruby-cloud-title": "Dialogflow CX",
        "ruby-cloud-description": "Dialogflow is an end-to-end, build-once deploy-everywhere development suite for creating conversational interfaces for websites, mobile applications, popular messaging platforms, and IoT devices. You can use it to build interfaces (such as chatbots and conversational IVR) that enable natural and rich interactions between your users and your business. This client is for Dialogflow CX, providing an advanced agent type suitable for large or very complex agents.",
        "ruby-cloud-env-prefix": "DIALOGFLOW",
        "ruby-cloud-wrapper-of": "v3:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/dialogflow",
        "ruby-cloud-api-id": "dialogflow.googleapis.com",
        "ruby-cloud-api-shortname": "dialogflow",
        "ruby-cloud-namespace-override": "Cx=CX",
    }
)

s.copy(library, merge=ruby.global_merge)
