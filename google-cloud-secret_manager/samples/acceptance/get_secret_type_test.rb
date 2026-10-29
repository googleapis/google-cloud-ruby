# Copyright 2026 Google, Inc
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

describe "#get_secret_type", :secret_manager_snippet do
  it "gets the secret's type" do
    create_sample = SampleLoader.load "create_secret_with_type.rb"
    get_sample = SampleLoader.load "get_secret_type.rb"

    capture_io do
      create_sample.run project_id: project_id, secret_id: secret_id, secret_type: :ACCESS_KEY
    end

    out, _err = capture_io do
      get_sample.run project_id: project_id, secret_id: secret_id
    end
    assert_match(/with secret type ACCESS_KEY/, out)
  end
end
