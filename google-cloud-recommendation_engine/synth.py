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
    "recommendationengine", "v1beta1",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-recommendation_engine",
        "ruby-cloud-title": "Recommendations AI",
        "ruby-cloud-description": "Recommendations AI enables you to build an end-to-end personalized recommendation system based on state-of-the-art deep learning ML models, without a need for expertise in ML or recommendation systems.",
        "ruby-cloud-env-prefix": "RECOMMENDATION_ENGINE",
        "ruby-cloud-wrapper-of": "v1beta1:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/recommendations-ai/",
        "ruby-cloud-api-id": "recommendationengine.googleapis.com",
        "ruby-cloud-api-shortname": "recommendationengine",
    }
)

s.copy(library, merge=ruby.global_merge)
