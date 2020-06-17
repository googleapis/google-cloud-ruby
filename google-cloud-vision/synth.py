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
    "vision", "v1",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-vision",
        "ruby-cloud-title": "Cloud Vision",
        "ruby-cloud-description": "Cloud Vision API allows developers to easily integrate vision detection features within applications, including image labeling, face and landmark detection, optical character recognition (OCR), and tagging of explicit content.",
        "ruby-cloud-env-prefix": "VISION",
        "ruby-cloud-wrapper-of": "v1:0.0;v1p3beta1:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/vision",
        "ruby-cloud-api-id": "vision.googleapis.com",
        "ruby-cloud-api-shortname": "vision",
        "ruby-cloud-migration-version": "1.0",
    }
)

s.copy(library, merge=ruby.global_merge)

# TEMP: Remove when microgenerator 0.5.2 is live.
s.replace(
    '.rubocop.yml',
    'samples/acceptance/\\*\\.rb',
    'samples/**/acceptance/*.rb'
)
