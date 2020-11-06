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
    "websecurityscanner", "v1",
    extra_proto_files=["google/cloud/common_resources.proto"],
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-web_security_scanner-v1",
        "ruby-cloud-title": "Web Security Scanner V1",
        "ruby-cloud-description": "Web Security Scanner scans your Compute and App Engine apps for common web vulnerabilities.",
        "ruby-cloud-env-prefix": "WEB_SECURITY_SCANNER",
        "ruby-cloud-grpc-service-config": "google/cloud/websecurityscanner/v1/websecurityscanner_grpc_service_config.json",
        "ruby-cloud-product-url": "https://cloud.google.com/security-command-center/docs/concepts-web-security-scanner-overview/",
        "ruby-cloud-api-id": "websecurityscanner.googleapis.com",
        "ruby-cloud-api-shortname": "websecurityscanner",
    }
)

s.copy(library, merge=ruby.global_merge)
