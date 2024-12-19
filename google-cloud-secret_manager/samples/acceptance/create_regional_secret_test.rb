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

describe "#create_regional_secret", :secret_manager_snippet do
  it "creates a regional secret" do
    sample = SampleLoader.load "create_regional_secret.rb"

    out, _err = capture_io do
      sample.run project_id: project_id, location_id: location_id, secret_id: secret_id
    end
    secret_id_regex = Regexp.escape secret_id
    assert_match %r{Created regional secret: projects/\S+locations/\S+/secrets/#{secret_id_regex}}, out
  end
end
