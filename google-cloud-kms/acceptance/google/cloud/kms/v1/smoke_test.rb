# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "simplecov"

require "minitest/autorun"
require "minitest/spec"

require "google/cloud/kms"

describe "KMS V1 smoke test" do
  it "calls list_key_rings" do
    kms = Google::Cloud::Kms.new version: :v1
    key_ring_parent = kms.class.location_path ENV["KMS_PROJECT"], "us-central1"
    key_rings = kms.list_key_rings(key_ring_parent).to_a
    key_rings.size.must_equal 1
    key_rings[0].name.must_match %r{keyRings/ruby-test$}
  end
end
