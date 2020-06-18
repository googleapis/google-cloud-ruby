# Copyright 2018 Google LLC
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
    "iot", "v1",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-iot",
        "ruby-cloud-title": "Cloud IoT",
        "ruby-cloud-description": "Registers and manages IoT (Internet of Things) devices that connect to the Google Cloud Platform.",
        "ruby-cloud-env-prefix": "IOT",
        "ruby-cloud-wrapper-of": "v1:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/iot",
        "ruby-cloud-api-id": "cloudiot.googleapis.com",
        "ruby-cloud-api-shortname": "cloudiot",
    }
)

s.copy(library, merge=ruby.global_merge)
