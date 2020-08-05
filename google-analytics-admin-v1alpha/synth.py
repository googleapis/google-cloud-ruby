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
    "analytics/admin", "v1alpha",
    proto_path="google/analytics/admin/v1alpha",
    generator_args={
        "ruby-cloud-gem-name": "google-analytics-admin-v1alpha",
        "ruby-cloud-title": "Google Analytics Admin V1alpha",
        "ruby-cloud-description": "The Analytics Admin API allows for programmatic access to the Google Analytics App+Web configuration data. You can use the Google Analytics Admin API to manage accounts and App+Web properties.",
        "ruby-cloud-env-prefix": "ANALYTICS_ADMIN",
        "ruby-cloud-grpc-service-config": "google/analytics/admin/v1alpha/admin_grpc_service_config.json",
        "ruby-cloud-api-id": "analyticsadmin.googleapis.com",
        "ruby-cloud-api-shortname": "analyticsadmin",
    }
)

s.copy(library, merge=ruby.global_merge)
