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
    "monitoring", "v3",
    proto_path="google/monitoring/v3",
    extra_proto_files=["google/cloud/common_resources.proto"],
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-monitoring-v3",
        "ruby-cloud-title": "Cloud Monitoring V3",
        "ruby-cloud-description": "Cloud Monitoring collects metrics, events, and metadata from Google Cloud, Amazon Web Services (AWS), hosted uptime probes, and application instrumentation.",
        "ruby-cloud-env-prefix": "MONITORING",
        "ruby-cloud-grpc-service-config": "google/monitoring/v3/monitoring_grpc_service_config.json",
        "ruby-cloud-product-url": "https://cloud.google.com/monitoring",
        "ruby-cloud-api-id": "monitoring.googleapis.com",
        "ruby-cloud-api-shortname": "monitoring",
    }
)

s.copy(library, merge=ruby.global_merge)

# Temporary: Remove docs for the obsolete ServiceTier module which contain
# broken links.
s.replace(
    'proto_docs/google/monitoring/v3/common.rb',
    '(\n        #[^\n]*)+\n        module ServiceTier\n',
    '\n        # Obsolete.\n        module ServiceTier\n'
)
s.replace(
    'proto_docs/google/monitoring/v3/common.rb',
    '(\n          #[^\n]*)+\n          SERVICE_TIER_',
    '\n          # Obsolete.\n          SERVICE_TIER_'
)
