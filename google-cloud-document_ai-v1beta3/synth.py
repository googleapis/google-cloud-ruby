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
    "documentai", "v1beta3",
    extra_proto_files=["google/cloud/common_resources.proto"],
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-document_ai-v1beta3",
        "ruby-cloud-title": "Document AI V1beta3",
        "ruby-cloud-description": "Document AI uses machine learning on a single cloud-based platform to automatically classify, extract, and enrich data within your documents to unlock insights.",
        "ruby-cloud-env-prefix": "DOCUMENT_AI",
        "ruby-cloud-grpc-service-config": "google/cloud/documentai/v1beta3/documentai_v1beta3_grpc_service_config.json",
        "ruby-cloud-product-url": "https://cloud.google.com/document-ai/",
        "ruby-cloud-api-id": "us-documentai.googleapis.com",
        "ruby-cloud-api-shortname": "documentai",
    }
)

s.copy(library, merge=ruby.global_merge)
