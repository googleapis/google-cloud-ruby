# Copyright 2022 Google, Inc
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

require "uri"

require_relative "helper"

describe "#create_ummr_secret", :secret_manager_snippet do
  it "creates a secret with user managed replication" do
    sample = SampleLoader.load "create_ummr_secret.rb"

    out, _err = capture_io do
      sample.run project_id: project_id, secret_id: secret_id,
                 locations: ["us-east1", "us-east4", "us-west1"]
    end
    secret_id_regex = Regexp.quote secret_id
    assert_match %r{Created secret with user managed replication: \S+/#{secret_id_regex}}, out
  end
end
