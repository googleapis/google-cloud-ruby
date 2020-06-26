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
    "recommender", "v1",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-recommender",
        "ruby-cloud-title": "Recommender",
        "ruby-cloud-description": "Recommender is a service on Google Cloud that provides usage recommendations for Cloud products and services.",
        "ruby-cloud-env-prefix": "RECOMMENDER",
        "ruby-cloud-wrapper-of": "v1:0.1",
        "ruby-cloud-product-url": "https://cloud.google.com/recommender",
        "ruby-cloud-api-id": "recommender.googleapis.com",
        "ruby-cloud-api-shortname": "recommender",
        "ruby-cloud-factory-method-suffix": "_service",
    }
)

s.copy(library, merge=ruby.global_merge)
