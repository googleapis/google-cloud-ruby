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
    "orgpolicy", "v2",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-org_policy",
        "ruby-cloud-title": "Organization Policy",
        "ruby-cloud-description": "The Cloud Org Policy service provides a simple mechanism for organizations to restrict the allowed configurations across their entire Cloud Resource hierarchy.",
        "ruby-cloud-env-prefix": "ORG_POLICY",
        "ruby-cloud-wrapper-of": "v2:0.2",
        "ruby-cloud-product-url": "https://cloud.google.com/resource-manager/docs/organization-policy/overview",
        "ruby-cloud-api-id": "orgpolicy.googleapis.com",
        "ruby-cloud-api-shortname": "orgpolicy",
    }
)

s.copy(library, merge=ruby.global_merge)
