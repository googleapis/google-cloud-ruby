# Copyright 2021 Google LLC
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
    "analytics/data", "v1beta",
    proto_path="google/analytics/data/v1beta",
    generator_args={
        "ruby-cloud-gem-name": "google-analytics-data",
        "ruby-cloud-title": "Google Analytics Data",
        "ruby-cloud-description": "The Google Analytics Data API provides programmatic methods to access report data in Google Analytics 4 (GA4) properties. Google Analytics 4 helps you understand how people use your web, iOS, or Android app.",
        "ruby-cloud-env-prefix": "ANALYTICS_DATA",
        "ruby-cloud-wrapper-of": "v1beta:0.0;v1alpha:0.0",
        "ruby-cloud-product-url": "https://developers.google.com/analytics/devguides/reporting/data/v1",
        "ruby-cloud-api-id": "analyticsdata.googleapis.com",
        "ruby-cloud-api-shortname": "analyticsdata",
        "ruby-cloud-service-override": "BetaAnalyticsData=AnalyticsData",
    }
)

s.copy(library, merge=ruby.global_merge)
