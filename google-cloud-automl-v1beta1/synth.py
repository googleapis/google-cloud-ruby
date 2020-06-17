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
    "automl", "v1beta1",
    extra_proto_files=["google/cloud/common_resources.proto"],
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-automl-v1beta1",
        "ruby-cloud-title": "Cloud AutoML V1beta1",
        "ruby-cloud-description": "AutoML makes the power of machine learning available to you even if you have limited knowledge of machine learning. You can use AutoML to build on Google's machine learning capabilities to create your own custom machine learning models that are tailored to your business needs, and then integrate those models into your applications and web sites.",
        "ruby-cloud-env-prefix": "AUTOML",
        "ruby-cloud-grpc-service-config": "google/cloud/automl/v1beta1/automl_grpc_service_config.json",
        "ruby-cloud-path-override": "auto_ml=automl",
        "ruby-cloud-namespace-override": "AutoMl=AutoML",
        "ruby-cloud-product-url": "https://cloud.google.com/automl",
        "ruby-cloud-api-id": "automl.googleapis.com",
        "ruby-cloud-api-shortname": "automl",
    }
)

s.copy(library, merge=ruby.global_merge)

# Fixes for some misformatted markdown links.
# See internal issue b/153077040.
s.replace(
    "proto_docs/google/cloud/automl/v1beta1/io.rb",
    "https:\n\\s+# //",
    "https://")
