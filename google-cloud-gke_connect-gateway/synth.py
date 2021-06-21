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
    "gkeconnect/gateway", "v1beta1",
    proto_path="google/cloud/gkeconnect/gateway/v1beta1",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-gke_connect-gateway",
        "ruby-cloud-title": "Connect Gateway",
        "ruby-cloud-description": "The Connect gateway builds on the power of fleets to let Anthos users connect to and run commands against registered Anthos clusters in a simple, consistent, and secured way, whether the clusters are on Google Cloud, other public clouds, or on premises, and makes it easier to automate DevOps processes across all your clusters. Note that google-cloud-gke_connect-gateway-v1beta1 is a version-specific client library. For most uses, we recommend installing the main client library google-cloud-gke_connect-gateway instead. See the readme for more details.",
        "ruby-cloud-env-prefix": "GKE_CONNECT_GATEWAY",
        "ruby-cloud-wrapper-of": "v1beta1:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/anthos/multicluster-management/gateway/",
        "ruby-cloud-api-id": "connectgateway.googleapis.com",
        "ruby-cloud-api-shortname": "connectgateway",
    }
)

s.copy(library, merge=ruby.global_merge)
