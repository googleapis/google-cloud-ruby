# Copyright 2017 Google LLC
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


require "simplecov"
require "minitest/autorun"

require "google/cloud/dlp"

class DlpServiceSmokeTest < Minitest::Test
  def test_inspect_content
    unless ENV["DLP_TEST_PROJECT"]
      fail "Usage: DLP_TEST_PROJECT=<project_id> ruby #{$0}"
    end
    project_id = ENV["DLP_TEST_PROJECT"].freeze

    dlp_service_client = Google::Cloud::Dlp.dlp_service version: :v2
    type = { name: "PHONE_NUMBER" }
    inspect_config = { info_types: [type], min_likelihood: :POSSIBLE }
    item = { value: "my phone number is 215-512-1212" }
    response = dlp_service_client.inspect_content(parent: "projects/#{project_id}", inspect_config: inspect_config, item: item)
  end
end
