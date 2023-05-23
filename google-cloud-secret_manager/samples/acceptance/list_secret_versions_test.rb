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

describe "#list_secret_versions", :secret_manager_snippet do
  it "lists the secret versions" do
    sample = SampleLoader.load "list_secret_versions.rb"

    refute_nil secret
    refute_nil secret_version

    assert_output(/Got secret version \S+#{Regexp.escape version_id}/) do
      sample.run project_id: project_id, secret_id: secret_id
    end
  end
end
