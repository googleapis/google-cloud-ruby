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
    "bigtable", "v2",
    proto_path="google/bigtable/v2",
    extra_proto_files=[
        "google/cloud/common_resources.proto"
    ],
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-bigtable-v2",
        "ruby-cloud-title": "Cloud Bigtable V2",
        "ruby-cloud-description": "Cloud Bigtable is a fully managed, scalable NoSQL database service for large analytical and operational workloads.",
        "ruby-cloud-env-prefix": "BIGTABLE",
        "ruby-cloud-grpc-service-config": "google/bigtable/v2/bigtable_grpc_service_config.json",
        "ruby-cloud-product-url": "https://cloud.google.com/bigtable",
        "ruby-cloud-api-id": "bigtable.googleapis.com",
        "ruby-cloud-api-shortname": "bigtable",
    }
)

s.copy(library, merge=ruby.global_merge)
