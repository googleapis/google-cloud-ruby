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
    "analytics/data", "v1alpha",
    proto_path="google/analytics/data/v1alpha",
    generator_args={
        "ruby-cloud-gem-name": "google-analytics-data-v1alpha",
        "ruby-cloud-title": "Google Analytics Data V1alpha",
        "ruby-cloud-description": "The Google Analytics Data API provides programmatic methods to access report data in Google Analytics App+Web properties. With the Google Analytics Data API, you can build custom dashboards to display Google Analytics data, automate complex reporting tasks to save time, and integrate your Google Analytics data with other business applications.",
        "ruby-cloud-env-prefix": "ANALYTICS",
        "ruby-cloud-grpc-service-config": "google/analytics/data/v1alpha/analytics_data_grpc_service_config.json",
        "ruby-cloud-api-id": "analyticsdata.googleapis.com",
        "ruby-cloud-api-shortname": "analyticsdata",
        "ruby-cloud-service-override": "AlphaAnalyticsData=AnalyticsData",
    }
)

s.copy(library, merge=ruby.global_merge)
