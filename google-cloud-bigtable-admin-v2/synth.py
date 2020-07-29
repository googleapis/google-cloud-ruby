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
    "bigtable/admin", "v2",
    proto_path="google/bigtable/admin/v2",
    extra_proto_files=[
        "google/cloud/common_resources.proto",
        "google/iam/v1/iam_policy.proto"
    ],
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-bigtable-admin-v2",
        "ruby-cloud-title": "Cloud Bigtable Admin V2",
        "ruby-cloud-description": "Cloud Bigtable is a fully managed, scalable NoSQL database service for large analytical and operational workloads.",
        "ruby-cloud-env-prefix": "BIGTABLE",
        "ruby-cloud-grpc-service-config": "google/bigtable/admin/v2/bigtableadmin_grpc_service_config.json",
        "ruby-cloud-common-services": "google.iam.v1.IAMPolicy=google.bigtable.admin.v2.BigtableInstanceAdmin",
        "ruby-cloud-product-url": "https://cloud.google.com/bigtable",
        "ruby-cloud-api-id": "bigtable.googleapis.com",
        "ruby-cloud-api-shortname": "bigtable",
    }
)

s.copy(library, merge=ruby.global_merge)

# Disable Style/AsciiComments due to the following failure in
# lib/google/cloud/bigtable/admin/v2/bigtable_table_admin/client.rb:1582:54:
# C: Style/AsciiComments: Use only ascii symbols in comments.
# #     <, >, <=, >=, !=, =, or :. Colon ‘:’ represents a HAS operator which is
s.replace(
    '.rubocop.yml',
    'Style/CaseEquality:\n  Enabled: false\n',
    'Style/AsciiComments:\n  Enabled: false\nStyle/CaseEquality:\n  Enabled: false\n'
)
