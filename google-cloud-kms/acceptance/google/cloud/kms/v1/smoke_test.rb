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

require "minitest/autorun"

require "google/cloud/kms"

class KmsServiceSmokeTest < Minitest::Spec
  def test_list_key_rings_grpc
    kms = Google::Cloud::Kms.key_management_service version: :v1, transport: :grpc
    key_ring_parent = kms.location_path project: ENV["KMS_PROJECT"], location: "us-central1"
    key_rings = kms.list_key_rings(parent: key_ring_parent) do |result, operation|
      assert_kind_of ::GRPC::ActiveCall::Operation, operation
    end.to_a
    assert key_rings.any? { |ring| ring.name.end_with? "keyRings/ruby-test" }
  end

  def test_list_locations_grpc
    kms = Google::Cloud::Kms.key_management_service version: :v1, transport: :grpc
    location_client = kms.location_client
    enum = location_client.list_locations(name: "projects/#{ENV['KMS_PROJECT']}")
    assert enum.any? { |loc| loc.name.end_with? "/us-central1" }
  end

  def test_get_iam_policy_grpc
    kms = Google::Cloud::Kms.key_management_service version: :v1, transport: :grpc
    iam_client = kms.iam_policy_client
    name = kms.key_ring_path project: ENV["KMS_PROJECT"], location: "us-central1", key_ring: "ruby-test"
    policy = iam_client.get_iam_policy resource: name
    assert_kind_of Google::Iam::V1::Policy, policy
  end

  def test_list_key_rings_rest
    kms = Google::Cloud::Kms.key_management_service version: :v1, transport: :rest
    key_ring_parent = kms.location_path project: ENV["KMS_PROJECT"], location: "us-central1"
    key_rings = kms.list_key_rings(parent: key_ring_parent) do |result, operation|
      assert_kind_of ::Faraday::Response, operation.underlying_op
    end.to_a
    assert key_rings.any? { |ring| ring.name.end_with? "keyRings/ruby-test" }
  end

  def test_list_locations_rest
    kms = Google::Cloud::Kms.key_management_service version: :v1, transport: :rest
    location_client = kms.location_client
    enum = location_client.list_locations(name: "projects/#{ENV['KMS_PROJECT']}")
    assert enum.any? { |loc| loc.name.end_with? "/us-central1" }
  end

  def test_get_iam_policy_rest
    kms = Google::Cloud::Kms.key_management_service version: :v1, transport: :rest
    iam_client = kms.iam_policy_client
    name = kms.key_ring_path project: ENV["KMS_PROJECT"], location: "us-central1", key_ring: "ruby-test"
    policy = iam_client.get_iam_policy resource: name
    assert_kind_of Google::Iam::V1::Policy, policy
  end
end
