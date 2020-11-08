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
    "servicecontrol", "v1",
    proto_path="google/api/servicecontrol/v1",
    extra_proto_files=["google/cloud/common_resources.proto"],
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-service_control-v1",
        "ruby-cloud-title": "Service Control API V1",
        "ruby-cloud-description": "The Service Control API provides control plane functionality to managed services, such as logging, monitoring, and status checks.",
        "ruby-cloud-env-prefix": "SERVICE_CONTROL",
        "ruby-cloud-product-url": "https://cloud.google.com/service-infrastructure/docs/overview/",
        "ruby-cloud-api-id": "servicecontrol.googleapis.com",
        "ruby-cloud-api-shortname": "servicecontrol",
    }
)

s.copy(library, merge=ruby.global_merge)
