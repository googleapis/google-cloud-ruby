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

require_relative "regional_helper"

describe "#update_regional_secret", :secret_manager_snippet do
  it "updates the secret" do
    sample = SampleLoader.load "update_regional_secret.rb"

    refute_nil secret

    out, _err = capture_io do
      sample.run project_id: project_id, location_id: location_id, secret_id: secret_id
    end

    assert_match(/Updated regional secret/, out)
    assert_match(/New label: rocks/, out)
  end
end
