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
    "google/area120/tables", "v1alpha1",
    proto_path="google/area120/tables/v1alpha1",
    generator_args={
        "ruby-cloud-gem-name": "google-area120-tables",
        "ruby-cloud-title": "Area 120 Tables",
        "ruby-cloud-description": "Using the Area 120 Tables API, you can query for tables, and update/create/delete rows within tables programmatically.",
        "ruby-cloud-env-prefix": "AREA120_TABLES",
        "ruby-cloud-wrapper-of": "v1alpha1:0.0",
        "ruby-cloud-product-url": "https://tables.area120.google.com/u/0/about#/",
        "ruby-cloud-api-id": "area120tables.googleapis.com",
        "ruby-cloud-api-shortname": "area120tables",
    }
)

s.copy(library, merge=ruby.global_merge)
