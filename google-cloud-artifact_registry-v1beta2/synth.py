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
    "artifactregistry", "v1beta2",
    proto_path="google/devtools/artifactregistry/v1beta2",
    extra_proto_files=["google/cloud/common_resources.proto"],
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-artifact_registry-v1beta2",
        "ruby-cloud-title": "Artifact Registry V1beta2",
        "ruby-cloud-description": "Artifact Registry stores and manages build artifacts in a scalable and integrated service built on Google infrastructure.",
        "ruby-cloud-env-prefix": "ARTIFACT_REGISTRY",
        "ruby-cloud-grpc-service-config": "google/devtools/artifactregistry/v1beta2/artifactregistry_grpc_service_config.json",
        "ruby-cloud-product-url": "https://cloud.google.com/artifact-registry/",
        "ruby-cloud-api-id": "artifactregistry.googleapis.com",
        "ruby-cloud-api-shortname": "artifactregistry",
    }
)

s.copy(library, merge=ruby.global_merge)
