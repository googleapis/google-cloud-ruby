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
    "containeranalysis", "v1",
    proto_path="google/devtools/containeranalysis/v1",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-container_analysis",
        "ruby-cloud-title": "Container Analysis",
        "ruby-cloud-description": "The Container Analysis API is an implementation of Grafeas. It stores, and enables querying and retrieval of, critical metadata about all of your software artifacts.",
        "ruby-cloud-env-prefix": "CONTAINER_ANALYSIS",
        "ruby-cloud-wrapper-of": "v1:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/container-registry/docs/container-analysis",
        "ruby-cloud-api-id": "containeranalysis.googleapis.com",
        "ruby-cloud-api-shortname": "containeranalysis",
        "ruby-cloud-migration-version": "1.0",
    }
)

s.copy(library, merge=ruby.global_merge)

# Include the local (git master) copy of grafeas-v1 in the bundle for now.
# This should remain here until the integration between the grafeas and
# container_analysis clients is stable, or until the two clients are split into
# separate repos, whichever comes first.
s.replace(
    'Gemfile',
    '\ngem "google-cloud-container_analysis-v1", path: "\\.\\./google-cloud-container_analysis-v1"\n',
    '\ngem "google-cloud-container_analysis-v1", path: "../google-cloud-container_analysis-v1"\ngem "grafeas-v1", path: "../grafeas-v1"\n'
)
