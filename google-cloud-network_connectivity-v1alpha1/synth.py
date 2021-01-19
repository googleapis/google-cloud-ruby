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
    "networkconnectivity", "v1alpha1",
    extra_proto_files=[
        "google/cloud/common_resources.proto",
    ],
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-network_connectivity-v1alpha1",
        "ruby-cloud-title": "Network Connectivity V1alpha1",
        "ruby-cloud-description": "Network Connectivity is Google's suite of products that provide enterprise connectivity from your on-premises network or from another cloud provider to your Virtual Private Cloud (VPC) network.",
        "ruby-cloud-env-prefix": "NETWORK_CONNECTIVITY",
        "ruby-cloud-grpc-service-config": "google/cloud/networkconnectivity/v1alpha1/networkconnectivity_grpc_service_config.json",
        "ruby-cloud-product-url": "cloud.google.com/network-connectivity/",
        "ruby-cloud-api-id": "networkconnectivity.googleapis.com",
        "ruby-cloud-api-shortname": "networkconnectivity",
    }
)

s.copy(library, merge=ruby.global_merge)
