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

gapic = gcp.GAPICBazel()
library = gapic.ruby_library(
    "automl", "v1",
    proto_path="google/cloud/automl/v1",
    bazel_target="//google/cloud/automl/v1:google-cloud-automl-v1-ruby",
)

s.copy(library, merge=ruby.global_merge)

# Fixes for some misformatted markdown links.
# See internal issue b/153077040.
s.replace(
    "proto_docs/google/cloud/automl/v1/io.rb",
    "https:\n\\s+# //",
    "https://")

# See internal issue b/158466893
s.replace(
    "proto_docs/google/cloud/automl/v1/io.rb",
    "\\[display_name-s\\]\\[google\\.cloud\\.automl\\.v1\\.ColumnSpec\\.display_name\\]",
    "display_name-s")
