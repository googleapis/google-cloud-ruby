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
    "dataflow", "v1beta3",
    proto_path="google/dataflow/v1beta3",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-dataflow",
        "ruby-cloud-title": "Dataflow",
        "ruby-cloud-description": "Dataflow is a managed service for executing a wide variety of data processing patterns.",
        "ruby-cloud-env-prefix": "DATAFLOW",
        "ruby-cloud-wrapper-of": "v1beta3:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/dataflow",
        "ruby-cloud-api-id": "dataflow.googleapis.com",
        "ruby-cloud-api-shortname": "dataflow",
        "ruby-cloud-service-override": "JobsV1Beta3=Jobs;MessagesV1Beta3=Messages;MetricsV1Beta3=Metrics;SnapshotsV1Beta3=Snapshots",
    }
)

s.copy(library, merge=ruby.global_merge)
