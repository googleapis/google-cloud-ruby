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
    "phishingprotection", "v1beta1",
    extra_proto_files=["google/cloud/common_resources.proto"],
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-phishing_protection-v1beta1",
        "ruby-cloud-title": "Phishing Protection V1beta1",
        "ruby-cloud-description": "Phishing Protection helps prevent users from accessing phishing sites by identifying various signals associated with malicious content, including the use of your brand assets, classifying malicious content that uses your brand and reporting the unsafe URLs to Google Safe Browsing.",
        "ruby-cloud-env-prefix": "PHISHING_PROTECTION",
        "ruby-cloud-grpc-service-config": "google/cloud/phishingprotection/v1beta1/phishingprotection_grpc_service_config.json",
        "ruby-cloud-product-url": "https://cloud.google.com/phishing-protection",
        "ruby-cloud-api-id": "phishingprotection.googleapis.com",
        "ruby-cloud-api-shortname": "phishingprotection",
        "ruby-cloud-service-override": "PhishingProtectionServiceV1Beta1=PhishingProtectionService",
    }
)

s.copy(library, merge=ruby.global_merge)
