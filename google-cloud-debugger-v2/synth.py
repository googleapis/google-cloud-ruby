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
    "debugger", "v2",
    proto_path="google/devtools/clouddebugger/v2",
    extra_proto_files=[
        "google/cloud/common_resources.proto",
        "google/devtools/source/v1/source_context.proto",
    ],
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-debugger-v2",
        "ruby-cloud-title": "Cloud Debugger V2",
        "ruby-cloud-description": "The Cloud Debugger API allows applications to interact with the Google Cloud Debugger backends. It provides two interfaces: the Debugger interface and the Controller interface. The Controller interface allows you to implement an agent that sends state data -- for example, the value of program variables and the call stack -- to Cloud Debugger when the application is running. The Debugger interface allows you to implement a Cloud Debugger client that allows users to set and delete the breakpoints at which the state data is collected, as well as read the data that is captured.",
        "ruby-cloud-env-prefix": "DEBUGGER",
        "ruby-cloud-grpc-service-config": "google/devtools/clouddebugger/v2/clouddebugger_grpc_service_config.json",
        "ruby-cloud-product-url": "https://cloud.google.com/debugger",
        "ruby-cloud-api-id": "clouddebugger.googleapis.com",
        "ruby-cloud-api-shortname": "clouddebugger",
        "ruby-cloud-service-override": "Controller2=Controller;Debugger2=Debugger",
    }
)

s.copy(library, merge=ruby.global_merge)
