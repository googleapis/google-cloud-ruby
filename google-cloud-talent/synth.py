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
    "talent", "v4",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-talent",
        "ruby-cloud-title": "Cloud Talent Solution",
        "ruby-cloud-description": "Transform your job search and candidate matching capabilities with Cloud Talent Solution, designed to support enterprise talent acquisition technology and evolve with your growing needs. This AI solution includes features such as Job Search and Profile Search (Beta) to provide candidates and employers with an enhanced talent acquisition experience.",
        "ruby-cloud-env-prefix": "TALENT",
        "ruby-cloud-wrapper-of": "v4:0.2;v4beta1:0.2",
        "ruby-cloud-product-url": "https://cloud.google.com/solutions/talent-solution",
        "ruby-cloud-api-id": "jobs.googleapis.com",
        "ruby-cloud-api-shortname": "jobs",
        "ruby-cloud-migration-version": "0.20",
    }
)

s.copy(library, merge=ruby.global_merge)
