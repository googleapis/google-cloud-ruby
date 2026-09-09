# Copyright 2025 Google, Inc
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

describe "#disable_secret_delayed_destroy", :secret_manager_snippet do
  it "disables the secret delayed destroy" do
    sample = SampleLoader.load "disable_secret_delayed_destroy.rb"

    refute_nil secret_version

    assert_output(/Disabled secret delayed destroy/) do
      sample.run project_id: project_id, secret_id: secret_id
    end

    n_version = client.get_secret name: secret_name
    refute_nil n_version
    assert_nil n_version.version_destroy_ttl, "Expected versionDestroyTtl to be nil"
  end
end
