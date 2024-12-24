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

describe "#get_regional_secret_version", :regional_secret_manager_snippet do
  it "gets the regional secret version" do
    sample = SampleLoader.load "get_regional_secret_version.rb"

    refute_nil secret_version

    escaped_name = Regexp.escape secret_version.name
    assert_output(/Got regional secret version #{escaped_name} with state enabled/) do
      sample.run project_id: project_id, location_id: location_id, secret_id: secret_id, version_id: version_id
    end
  end
end
