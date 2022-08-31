# frozen_string_literal: true

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "minitest/autorun"
require "securerandom"

$temp_instances = []

def random_instance_name
  "rubysamplestest-i-#{SecureRandom.hex 6}"
end

def random_bucket_name
  "rubysamplestest-b-#{SecureRandom.hex 10}"
end

def random_firewall_name
  "rubysamplestest-f-#{SecureRandom.hex 10}"
end

def project
  ENV["GOOGLE_CLOUD_PROJECT"] || raise("No project defined. Set `GOOGLE_CLOUD_PROJECT` env var to your_project_name")
end

def zone
  ENV["GOOGLE_CLOUD_ZONE"] || "us-central1-c"
end
