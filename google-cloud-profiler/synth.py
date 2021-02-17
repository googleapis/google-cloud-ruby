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
    "profiler", "v2",
    proto_path="google/devtools/cloudprofiler/v2",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-profiler",
        "ruby-cloud-title": "Cloud Profiler",
        "ruby-cloud-description": "Cloud Profiler is a statistical, low-overhead profiler that continuously gathers CPU usage and memory-allocation information from your production applications. It attributes that information to the application's source code, helping you identify the parts of the application consuming the most resources, and otherwise illuminating the performance characteristics of the code.",
        "ruby-cloud-env-prefix": "PROFILER",
        "ruby-cloud-wrapper-of": "v2:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/profiler/",
        "ruby-cloud-api-id": "cloudprofiler.googleapis.com",
        "ruby-cloud-api-shortname": "cloudprofiler",
    }
)

s.copy(library, merge=ruby.global_merge)
