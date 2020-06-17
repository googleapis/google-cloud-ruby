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
    "dataproc", "v1",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-dataproc",
        "ruby-cloud-title": "Cloud Dataproc",
        "ruby-cloud-description": "Manages Hadoop-based clusters and jobs on Google Cloud Platform.",
        "ruby-cloud-env-prefix": "DATAPROC",
        "ruby-cloud-wrapper-of": "v1:0.0;v1beta2:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/dataproc",
        "ruby-cloud-api-id": "dataproc.googleapis.com",
        "ruby-cloud-api-shortname": "dataproc",
        "ruby-cloud-migration-version": "1.0",
    }
)

s.copy(library, merge=ruby.global_merge)
