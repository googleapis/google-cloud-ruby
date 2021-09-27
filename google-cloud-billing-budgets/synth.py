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
    "billing/budgets", "v1",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-billing-budgets",
        "ruby-cloud-title": "Billing Budgets",
        "ruby-cloud-description": "Provides methods to view, create, and manage Cloud Billing budgets programmatically at scale.",
        "ruby-cloud-env-prefix": "BILLING_BUDGETS",
        "ruby-cloud-wrapper-of": "v1:0.0;v1beta1:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/billing/docs/how-to/budget-api-overview",
        "ruby-cloud-api-id": "billingbudgets.googleapis.com",
        "ruby-cloud-api-shortname": "billingbudgets",
    }
)

s.copy(library, merge=ruby.global_merge)
