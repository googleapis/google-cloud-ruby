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
    "datastream", "v1alpha1",
    proto_path="google/cloud/datastream/v1alpha1",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-datastream",
        "ruby-cloud-title": "Datastream",
        "ruby-cloud-description": "Datastream is a serverless and easy-to-use change data capture (CDC) and replication service. It allows you to synchronize data across heterogeneous databases and applications reliably, and with minimal latency and downtime.",
        "ruby-cloud-wrapper-of": "v1alpha1:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/datastream/",
        "ruby-cloud-api-id": "datastream.googleapis.com",
        "ruby-cloud-api-shortname": "datastream",
    }
)

s.copy(library, merge=ruby.global_merge)
