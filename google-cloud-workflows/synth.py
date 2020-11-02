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

# Wrapper for workflows
library = gapic.ruby_library(
    "workflows", "v1beta",
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-workflows",
        "ruby-cloud-title": "Workflows",
        "ruby-cloud-description": "Workflows link series of serverless tasks together in an order you define. Combine the power of Google Cloud's APIs, serverless products like Cloud Functions and Cloud Run, and calls to external APIs to create flexible serverless applications. Workflows requires no infrastructure management and scales seamlessly with demand, including scaling down to zero..",
        "ruby-cloud-env-prefix": "WORKFLOWS",
        "ruby-cloud-wrapper-of": "v1beta:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/workflows",
        "ruby-cloud-api-id": "workflows.googleapis.com",
        "ruby-cloud-api-shortname": "workflows",
    }
)
s.copy(library, merge=ruby.global_merge)

# Wrapper for workflows-executions
library2 = gapic.ruby_library(
    "workflows/executions", "v1beta",
    extra_proto_files=["google/cloud/common_resources.proto"],
    generator_args={
        "ruby-cloud-gem-name": "google-cloud-workflows-executions",
        "ruby-cloud-title": "Workflows Executions",
        "ruby-cloud-description": "Workflows link series of serverless tasks together in an order you define. Combine the power of Google Cloud's APIs, serverless products like Cloud Functions and Cloud Run, and calls to external APIs to create flexible serverless applications. Workflows requires no infrastructure management and scales seamlessly with demand, including scaling down to zero..",
        "ruby-cloud-env-prefix": "WORKFLOWS",
        "ruby-cloud-wrapper-of": "v1beta:0.0",
        "ruby-cloud-product-url": "https://cloud.google.com/workflows/",
        "ruby-cloud-api-id": "workflowexecutions.googleapis.com",
        "ruby-cloud-api-shortname": "workflowexecutions",
    }
)
s.copy(library2 / "lib/google/cloud/workflows/executions.rb", merge=ruby.global_merge)
s.copy(library2 / "test/google/cloud/workflows/executions/client_test.rb", merge=ruby.global_merge)

# Ensure the gemspec includes workflows-executions, and the entrypoint references it.
s.replace(
    "lib/google-cloud-workflows.rb",
    '\nrequire "google/cloud/workflows" unless defined\\? Google::Cloud::Workflows::VERSION\n',
    '\nrequire "google/cloud/workflows" unless defined? Google::Cloud::Workflows::VERSION\nrequire "google/cloud/workflows/executions" unless defined? Google::Cloud::Workflows::Executions::VERSION\n'
)
s.replace(
    "google-cloud-workflows.gemspec",
    '\n  gem.add_dependency "google-cloud-workflows-v1beta", "~> 0.0"\n\n',
    '\n  gem.add_dependency "google-cloud-workflows-v1beta", "~> 0.0"\n  gem.add_dependency "google-cloud-workflows-executions-v1beta", "~> 0.0"\n\n',
)
s.replace(
    "Gemfile",
    '\ngem "google-cloud-workflows-v1beta", path: "../google-cloud-workflows-v1beta"\n',
    '\ngem "google-cloud-workflows-v1beta", path: "../google-cloud-workflows-v1beta"\ngem "google-cloud-workflows-executions-v1beta", path: "../google-cloud-workflows-executions-v1beta"\n',
)
