# Copyright 2019 Google LLC
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
    "translate", "v3",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-translate",
        "ruby-cloud-title": "Cloud Translation",
        "ruby-cloud-description": "Cloud Translation can dynamically translate text between thousands of language pairs. Translation lets websites and programs programmatically integrate with the translation service.",
        "ruby-cloud-env-prefix": "TRANSLATE",
        "ruby-cloud-wrapper-of": "v3:0.0;v2:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/translate",
        "ruby-cloud-api-id": "translate.googleapis.com",
        "ruby-cloud-api-shortname": "translate",
        "ruby-cloud-migration-version": "3.0",
    }
)

s.copy(library, merge=ruby.global_merge)
