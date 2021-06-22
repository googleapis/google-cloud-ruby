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
    "apigateway", "v1",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-api_gateway",
        "ruby-cloud-title": "API Gateway",
        "ruby-cloud-description": "API Gateway enables you to provide secure access to your backend services through a well-defined REST API that is consistent across all of your services, regardless of the service implementation. Clients consume your REST APIS to implement standalone apps for a mobile device or tablet, through apps running in a browser, or through any other type of app that can make a request to an HTTP endpoint.",
        "ruby-cloud-env-prefix": "API_GATEWAY",
        "ruby-cloud-wrapper-of": "v1:0.1",
        "ruby-cloud-product-url": "https://cloud.google.com/api-gateway/",
        "ruby-cloud-api-id": "apigateway.googleapis.com",
        "ruby-cloud-api-shortname": "apigateway",
    }
)

s.copy(library, merge=ruby.global_merge)
