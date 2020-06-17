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
    "oslogin", "v1",
    extra_proto_files=[
      "google/cloud/common_resources.proto",
      "google/cloud/oslogin/common/common.proto"
    ],
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-os_login-v1",
        "ruby-cloud-title": "Cloud OS Login V1",
        "ruby-cloud-description": "Use OS Login to manage SSH access to your instances using IAM without having to create and manage individual SSH keys. OS Login maintains a consistent Linux user identity across VM instances and is the recommended way to manage many users across multiple instances or projects.",
        "ruby-cloud-env-prefix": "OS_LOGIN",
        "ruby-cloud-grpc-service-config": "google/cloud/oslogin/v1/oslogin_grpc_service_config.json",
        "ruby-cloud-product-url": "https://cloud.google.com/compute/docs/oslogin",
        "ruby-cloud-api-id": "oslogin.googleapis.com",
        "ruby-cloud-api-shortname": "oslogin",
    }
)

s.copy(library, merge=ruby.global_merge)
