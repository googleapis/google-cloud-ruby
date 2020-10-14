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
import shutil

logging.basicConfig(level=logging.DEBUG)

gapic = gcp.GAPICMicrogenerator()
library = gapic.ruby_library(
    "containeranalysis", "v1",
    proto_path="google/devtools/containeranalysis/v1",
    extra_proto_files=[
        "google/cloud/common_resources.proto",
        "grafeas/v1/common.proto",
        "grafeas/v1/cvss.proto",
        "grafeas/v1/package.proto",
        "grafeas/v1/vulnerability.proto",
    ],
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-container_analysis-v1",
        "ruby-cloud-title": "Container Analysis V1",
        "ruby-cloud-description": "The Container Analysis API is an implementation of Grafeas. It stores, and enables querying and retrieval of, critical metadata about all of your software artifacts.",
        "ruby-cloud-env-prefix": "CONTAINER_ANALYSIS",
        "ruby-cloud-grpc-service-config": "google/devtools/containeranalysis/v1/containeranalysis_grpc_service_config.json",
        "ruby-cloud-product-url": "https://cloud.google.com/container-registry/docs/container-analysis",
        "ruby-cloud-api-id": "containeranalysis.googleapis.com",
        "ruby-cloud-api-shortname": "containeranalysis",
        "ruby-cloud-extra-dependencies": "grafeas-v1=~> 0.0",
    }
)

# Remove grafeas protos since they will be brought in via the grafeas-v1 gem
shutil.rmtree(library / "lib/grafeas")

s.copy(library, merge=ruby.global_merge)

# Include the local (git master) copy of grafeas-v1 in the bundle for now.
# This should remain here until the integration between the grafeas and
# container_analysis clients is stable, or until the two clients are split into
# separate repos, whichever comes first.
s.replace(
    'Gemfile',
    '\ngemspec\n',
    '\ngemspec\ngem "grafeas-v1", path: "../grafeas-v1"\n'
)
