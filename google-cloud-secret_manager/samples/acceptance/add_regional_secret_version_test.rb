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

describe "#add_regional_secret_version", :regional_secret_manager_snippet do
  it "adds a secret version" do
    sample = SampleLoader.load "add_regional_secret_version.rb"

    o_list = client.list_secret_versions(parent: secret.name).to_a
    assert_empty o_list

    out, _err = capture_io do
      sample.run project_id: project_id, location_id: location_id, secret_id: secret_id
    end
    assert_match(/Added regional secret version: \S+/, out)
    version = /Added regional secret version: (\S+)/.match(out)[1]

    n_list = client.list_secret_versions(parent: secret.name).to_a
    assert_includes n_list.map(&:name), version
  end
end
