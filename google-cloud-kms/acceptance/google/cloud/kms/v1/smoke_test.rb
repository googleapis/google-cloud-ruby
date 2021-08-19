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

require "google/cloud/kms"

class KmsServiceSmokeTest < Minitest::Spec
  def test_list_key_rings
    kms = Google::Cloud::Kms.key_management_service version: :v1
    key_ring_parent = kms.location_path project: ENV["KMS_PROJECT"], location: "us-central1"
    key_rings = kms.list_key_rings(parent: key_ring_parent).to_a
    _(key_rings.size).must_equal 1
    _(key_rings[0].name).must_match %r{keyRings/ruby-test$}
  end
end
