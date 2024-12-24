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

describe "#disable_regional_secret_version_with_etag", :regional_secret_manager_snippet do
  it "disables the regional secret version with the etag" do
    sample = SampleLoader.load "disable_regional_secret_version_with_etag.rb"

    refute_nil secret_version

    assert_output(/Disabled regional secret version/) do
      sample.run project_id: project_id, location_id: location_id, secret_id: secret_id, version_id: version_id, etag: etag
    end

    n_version = client.get_secret_version name: version_name
    refute_nil n_version
    assert_equal "disabled", n_version.state.to_s.downcase
  end
end
