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
    "accessapproval", "v1",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-access_approval",
        "ruby-cloud-title": "Access Approval",
        "ruby-cloud-description": "An API for controlling access to data by Google personnel.",
        "ruby-cloud-env-prefix": "ACCESS_APPROVAL",
        "ruby-cloud-wrapper-of": "v1:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/access-approval/",
        "ruby-cloud-api-id": "accessapproval.googleapis.com",
        "ruby-cloud-api-shortname": "accessapproval",
    }
)

s.copy(library, merge=ruby.global_merge)