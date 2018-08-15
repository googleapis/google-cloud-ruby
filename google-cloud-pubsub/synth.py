# Copyright 2018 Google LLC
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
import logging
import os

logging.basicConfig(level=logging.DEBUG)

gapic = gcp.GAPICGenerator()

v1_library = gapic.ruby_library(
    'pubsub', 'v1',
    config_path='/google/pubsub/artman_pubsub.yaml',
    artman_output_name='google-cloud-ruby/google-cloud-pubsub'
)
s.copy(v1_library / 'lib/google/cloud/pubsub/v1')
s.copy(v1_library / 'lib/google/pubsub/v1')

# Omitting lib/google/cloud/pusbusb/v1.rb for now because we are not exposing
# the low-level API.

# PERMANENT: We don't want the generated overview.rb file because we have our
# own toplevel docs for the handwritten layer.
os.remove('lib/google/cloud/pubsub/v1/doc/overview.rb')

# https://github.com/googleapis/gapic-generator/issues/2124
s.replace(
    'lib/google/cloud/pubsub/v1/credentials.rb',
    'SCOPE = \[[^\]]+\]\.freeze',
    'SCOPE = ["https://www.googleapis.com/auth/pubsub"].freeze')
