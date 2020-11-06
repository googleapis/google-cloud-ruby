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
    "iam", "v1beta",
    proto_path="google/iam/v1beta",
    generator_args={
        "ruby-cloud-gem-name": "google-iam-v1beta",
        "ruby-cloud-title": "Google IAM V1beta",
        "ruby-cloud-description": "Pre-release client for the WorkloadIdentityPools service.",
        "ruby-cloud-env-prefix": "IAM",
        "ruby-cloud-grpc-service-config": "google/iam/v1beta/iam_grpc_service_config.json",
        "ruby-cloud-api-id": "iam.googleapis.com",
        "ruby-cloud-api-shortname": "iam",
    }
)

s.copy(library, merge=ruby.global_merge)
