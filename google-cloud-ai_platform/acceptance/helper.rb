# frozen_string_literal: true

# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if ENV["CI"] || ENV["KOKORO_JOB_NAME"]
  # Load JUnit XML formatter from googleapis/ruby-common-tools for Kokoro/Sponge.
  begin
    require "gapic/minitest_junit_preloader"
  rescue LoadError
    # Ignored for local runs without ruby-common-tools on $LOAD_PATH.
  end
end

require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"

require "google/cloud/ai_platform"

##
# Shared helpers for google-cloud-ai_platform acceptance smoke tests.
#
module AcceptanceHelper
  ##
  # Returns the GCP project ID configured for acceptance tests.
  #
  # @return [String]
  #
  def self.project_id
    ENV["GOOGLE_CLOUD_PROJECT"] ||
      ENV["GOOGLE_CLOUD_TEST_PROJECT"] ||
      ENV["GCLOUD_TEST_PROJECT"] ||
      raise("missing GOOGLE_CLOUD_PROJECT, GOOGLE_CLOUD_TEST_PROJECT, or GCLOUD_TEST_PROJECT")
  end

  ##
  # Instantiates a versioned AIPlatform service client for the given location and transport.
  #
  # @param service [Symbol] Factory method name on {Google::Cloud::AIPlatform}.
  # @param location [String] Vertex AI location (e.g. "global", "us-central1", "us-east1").
  # @param transport [Symbol] RPC transport (`:grpc` or `:rest`).
  #
  # @return [Object]
  #
  def self.client service, location:, transport: :grpc
    endpoint = location == "global" ? "aiplatform.googleapis.com" : "#{location}-aiplatform.googleapis.com"
    Google::Cloud::AIPlatform.public_send service, version: :v1, transport: transport do |config|
      config.endpoint = endpoint
    end
  end
end
