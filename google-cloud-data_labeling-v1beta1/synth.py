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
    "datalabeling", "v1beta1",
    extra_proto_files=["google/cloud/common_resources.proto"],
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-data_labeling-v1beta1",
        "ruby-cloud-title": "AI Platform Data Labeling Service V1beta1",
        "ruby-cloud-description": "AI Platform Data Labeling Service lets you work with human labelers to generate highly accurate labels for a collection of data that you can use in machine learning models.",
        "ruby-cloud-env-prefix": "DATA_LABELING",
        "ruby-cloud-grpc-service-config": "google/cloud/datalabeling/v1beta1/datalabeling_grpc_service_config.json",
        "ruby-cloud-product-url": "https://cloud.google.com/ai-platform/data-labeling/docs",
        "ruby-cloud-api-id": "datalabeling.googleapis.com",
        "ruby-cloud-api-shortname": "datalabeling",
    }
)

s.copy(library, merge=ruby.global_merge)
