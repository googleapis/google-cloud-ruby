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
    "vpcaccess", "v1",
    proto_path="google/cloud/vpcaccess/v1",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-vpc_access",
        "ruby-cloud-title": "Serverless VPC Access",
        "ruby-cloud-description": "Serverless VPC Access enables you to connect from a serverless environment on Google Cloud (Cloud Run, Cloud Functions, or the App Engine standard environment) directly to your VPC network. This connection makes it possible for your serverless environment to access Compute Engine VM instances, Memorystore instances, and any other resources with an internal IP address.",
        "ruby-cloud-env-prefix": "VPC_ACCESS",
        "ruby-cloud-wrapper-of": "v1:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/vpc/docs/serverless-vpc-access",
        "ruby-cloud-api-id": "vpcaccess.googleapis.com",
        "ruby-cloud-api-shortname": "vpcaccess",
    }
)

s.copy(library, merge=ruby.global_merge)
