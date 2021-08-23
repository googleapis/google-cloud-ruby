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
    "metastore", "v1",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-metastore",
        "ruby-cloud-title": "Dataproc Metastore",
        "ruby-cloud-description": "Dataproc Metastore is a fully managed, highly available within a region, autohealing serverless Apache Hive metastore (HMS) on Google Cloud for data analytics products. It supports HMS and serves as a critical component for managing the metadata of relational entities and provides interoperability between data processing applications in the open source data ecosystem.",
        "ruby-cloud-env-prefix": "METASTORE",
        "ruby-cloud-wrapper-of": "v1:0.0;v1beta:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/dataproc-metastore/",
        "ruby-cloud-api-id": "metastore.googleapis.com",
        "ruby-cloud-api-shortname": "metastore",
    }
)

s.copy(library, merge=ruby.global_merge)
