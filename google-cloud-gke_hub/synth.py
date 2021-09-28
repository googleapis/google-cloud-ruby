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
    "gkehub", "v1",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-gke_hub",
        "ruby-cloud-title": "GKE Hub",
        "ruby-cloud-description": "The GKE Hub API centrally manages features and services on all your Kubernetes clusters running in a variety of environments, including Google cloud, on premises in customer datacenters, or other third party clouds.",
        "ruby-cloud-env-prefix": "GKE_HUB",
        "ruby-cloud-wrapper-of": "v1:0.0;v1beta1:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/anthos/clusters/docs",
        "ruby-cloud-api-id": "gkehub.googleapis.com",
        "ruby-cloud-api-shortname": "gkehub",
    }
)

s.copy(library, merge=ruby.global_merge)
