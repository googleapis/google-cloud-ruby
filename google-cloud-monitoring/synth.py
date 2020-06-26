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
import os

logging.basicConfig(level=logging.DEBUG)

# Wrapper for monitoring V3
gapic = gcp.GAPICMicrogenerator()
library = gapic.ruby_library(
    "monitoring", "v3",
    proto_path="google/monitoring/v3",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-monitoring",
        "ruby-cloud-title": "Cloud Monitoring",
        "ruby-cloud-description": "Cloud Monitoring collects metrics, events, and metadata from Google Cloud, Amazon Web Services (AWS), hosted uptime probes, and application instrumentation.",
        "ruby-cloud-env-prefix": "MONITORING",
        "ruby-cloud-wrapper-of": "v3:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/monitoring",
        "ruby-cloud-api-id": "monitoring.googleapis.com",
        "ruby-cloud-api-shortname": "monitoring",
        "ruby-cloud-migration-version": "1.0",
    }
)
s.copy(library, merge=ruby.global_merge)

# Generate the wrapper for monitoring-dashboard, and copy only the factory methods and tests
library2 = gapic.ruby_library(
    "monitoring/dashboard", "v1",
    proto_path="google/monitoring/dashboard/v1",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-monitoring-dashboard",
        "ruby-cloud-title": "Cloud Monitoring Dashboards",
        "ruby-cloud-description": "Cloud Monitoring collects metrics, events, and metadata from Google Cloud, Amazon Web Services (AWS), hosted uptime probes, and application instrumentation.",
        "ruby-cloud-env-prefix": "MONITORING_DASHBOARD",
        "ruby-cloud-wrapper-of": "v1:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/monitoring",
        "ruby-cloud-api-id": "monitoring.googleapis.com",
        "ruby-cloud-api-shortname": "monitoring",
        "ruby-cloud-migration-version": "1.0",
    }
)
s.copy(library2 / "lib/google/cloud/monitoring/dashboard.rb", merge=ruby.global_merge)
s.copy(library2 / "test/google/cloud/monitoring/dashboard/client_test.rb", merge=ruby.global_merge)

# Ensure the gemspec includes monitoring-dashboard, and the entrypoint references it.
s.replace(
    "lib/google-cloud-monitoring.rb",
    '\nrequire "google/cloud/monitoring" unless defined\\? Google::Cloud::Monitoring::VERSION\n',
    '\nrequire "google/cloud/monitoring" unless defined? Google::Cloud::Monitoring::VERSION\nrequire "google/cloud/monitoring/dashboard" unless defined? Google::Cloud::Monitoring::Dashboard::VERSION\n'
)
s.replace(
    "google-cloud-monitoring.gemspec",
    '\n  gem.add_dependency "google-cloud-monitoring-v3", "~> 0.0"\n\n',
    '\n  gem.add_dependency "google-cloud-monitoring-v3", "~> 0.0"\n  gem.add_dependency "google-cloud-monitoring-dashboard-v1", "~> 0.0"\n\n',
)
s.replace(
    "Gemfile",
    '\ngem "google-cloud-monitoring-v3", path: "../google-cloud-monitoring-v3"\n',
    '\ngem "google-cloud-monitoring-v3", path: "../google-cloud-monitoring-v3"\ngem "google-cloud-monitoring-dashboard-v1", path: "../google-cloud-monitoring-dashboard-v1"\n',
)
