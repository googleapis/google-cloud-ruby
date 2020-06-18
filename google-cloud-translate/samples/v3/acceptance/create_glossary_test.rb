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

require_relative "helper"
require_relative "../create_glossary"

require "securerandom"

describe "translate_v3_create_glossary", :translate do
  let(:glossary_id) { "glossary-#{SecureRandom.uuid}" }
  let(:location_id) { "us-central1" }
  let(:glossary_name) { client.glossary_path project: project_id, location: location_id, glossary: glossary_id }

  after do
    operation = client.delete_glossary name: glossary_name
    operation.wait_until_done!
  end

  it "creates a glossary" do
    out, _err = capture_io do
      translate_v3_create_glossary project_id: project_id, location_id: location_id, glossary_id: glossary_id
    end
    assert_match(/#{glossary_id}/, out)

    client.get_glossary name: glossary_name
  end
end
