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
require_relative "../storage_disable_bucket_lifecycle_management.rb"

describe "disable_bucket_lifecycle_management" do
  let(:bucket) { create_bucket_helper "ruby_storage_sample_#{SecureRandom.hex}" }
  after { delete_bucket_helper bucket.name }

  it "can disable bucket lifecycle management" do
    bucket.lifecycle do |l|
      l.add_delete_rule age: 2
    end

    out, _err = capture_io do
      updated_bucket = disable_bucket_lifecycle_management bucket_name: bucket.name
      assert_empty updated_bucket.lifecycle
    end

    assert_includes out, "Lifecycle management is disabled"
  end
end
