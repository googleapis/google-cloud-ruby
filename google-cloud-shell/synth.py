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
    "shell", "v1",
    proto_path="google/cloud/shell/v1",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-shell",
        "ruby-cloud-title": "Cloud Shell",
        "ruby-cloud-description": "Cloud Shell is an interactive shell environment for Google Cloud that makes it easy for you to learn and experiment with Google Cloud and manage your projects and resources from your web browser.",
        "ruby-cloud-env-prefix": "CLOUD_SHELL",
        "ruby-cloud-wrapper-of": "v1:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/shell/",
        "ruby-cloud-api-id": "cloudshell.googleapis.com",
        "ruby-cloud-api-shortname": "cloudshell",
    }
)

s.copy(library, merge=ruby.global_merge)
