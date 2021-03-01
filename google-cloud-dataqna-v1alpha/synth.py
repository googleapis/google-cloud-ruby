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
    "dataqna", "v1alpha",
    extra_proto_files=[
        "google/cloud/common_resources.proto",
    ],
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-dataqna-v1alpha",
        "ruby-cloud-title": "BigQuery Data QnA V1alpha",
        "ruby-cloud-description": "Data QnA is a natural language question and answer service for BigQuery data.",
        "ruby-cloud-env-prefix": "BIGQUERY_DATAQNA",
        "ruby-cloud-grpc-service-config": "google/cloud/dataqna/v1alpha/dataqna_grpc_service_config.json",
        "ruby-cloud-path-override": "data_qn_a=dataqna",
        "ruby-cloud-namespace-override": "Dataqna=DataQnA",
        "ruby-cloud-product-url": "https://cloud.google.com/bigquery/docs/dataqna/",
        "ruby-cloud-api-id": "dataqna.googleapis.com",
        "ruby-cloud-api-shortname": "dataqna",
    }
)

s.copy(library, merge=ruby.global_merge)
