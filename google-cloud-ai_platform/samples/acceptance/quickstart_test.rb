# Copyright 2023 Google, Inc
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

require "google/cloud/ai_platform"

require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"

require_relative "../../../.toys/.lib/sample_loader"

describe "Vertex AI Quickstart" do
  let(:project_id) { ENV["GOOGLE_CLOUD_PROJECT"] || raise("missing GOOGLE_CLOUD_PROJECT") }
  let(:location_id) { "us-central1" }
  let(:publisher) { "google" }
  let(:model) { "text-bison@001" }

  it "generates text" do
    sample = SampleLoader.load "quickstart.rb"

    assert_output(/\S/) do
      sample.run project_id: project_id, location_id: location_id, publisher: publisher, model: model
    end
  end
end
