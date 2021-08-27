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
    "clouddms", "v1",
    proto_path="google/cloud/clouddms/v1",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-cloud_dms",
        "ruby-cloud-title": "Cloud Database Migration Service",
        "ruby-cloud-description": "Database Migration Service makes it easier for you to migrate your data to Google Cloud. Database Migration Service helps you lift and shift your MySQL and PostgreSQL workloads into Cloud SQL. Database Migration Service streamlines networking workflow, manages the initial snapshot and ongoing replication, and provides a status of the migration operation.",
        "ruby-cloud-env-prefix": "DATABASE_MIGRATION",
        "ruby-cloud-wrapper-of": "v1:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/database-migration/",
        "ruby-cloud-api-id": "datamigration.googleapis.com",
        "ruby-cloud-api-shortname": "datamigration",
        "ruby-cloud-namespace-override": "CloudDms=CloudDMS",
    }
)

s.copy(library, merge=ruby.global_merge)
