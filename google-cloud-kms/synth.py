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
    "kms", "v1",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-kms",
        "ruby-cloud-title": "Cloud Key Management Service (KMS)",
        "ruby-cloud-description": "Manages keys and performs cryptographic operations in a central cloud service, for direct use by other cloud resources and applications.",
        "ruby-cloud-env-prefix": "KMS",
        "ruby-cloud-wrapper-of": "v1:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/kms",
        "ruby-cloud-api-id": "cloudkms.googleapis.com",
        "ruby-cloud-api-shortname": "cloudkms",
        "ruby-cloud-migration-version": "2.0",
    }
)

s.copy(library, merge=ruby.global_merge)
