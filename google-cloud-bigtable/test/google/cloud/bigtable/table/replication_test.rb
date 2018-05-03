# frozen_string_literal: true

# Copyright 2018 Google LLC
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


require "helper"

describe Google::Cloud::Bigtable::Table, :replication, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }
  let(:cluster_states) { clusters_state_grpc }
  let(:column_families) { column_families_grpc }
  let(:table_grpc) do
    Google::Bigtable::Admin::V2::Table.new(
      table_hash(
        name: table_path(instance_id, table_id),
        cluster_states: cluster_states,
        column_families: column_families,
        granularity: :MILLIS
      )
    )
  end
  let(:table) do
    Google::Cloud::Bigtable::Table.from_grpc(table_grpc, bigtable.service)
  end

  let(:token) { "l947XelENinaxJQP0nnrZJjHnAF7YrwW8HCJLotwrF" }

  it "generate consistency token" do
    get_res = Google::Bigtable::Admin::V2::GenerateConsistencyTokenResponse.new(
      consistency_token: token
    )
    mock = Minitest::Mock.new
    mock.expect :generate_consistency_token, get_res, [table_path(instance_id, table_id)]
    bigtable.service.mocked_tables = mock

    result = table.generate_consistency_token
    result.must_equal token
    mock.verify
  end

  it "check replication consistency of table" do
    get_res = Google::Bigtable::Admin::V2::CheckConsistencyResponse.new(
      consistent: true
    )
    mock = Minitest::Mock.new
    mock.expect :check_consistency, get_res, [table_path(instance_id, table_id), token]
    bigtable.service.mocked_tables = mock

    result = table.check_consistency(token)
    result.must_equal true
    mock.verify
  end

  it "generate token and wait for replication" do
    gen_token_res = Google::Bigtable::Admin::V2::GenerateConsistencyTokenResponse.new(
      consistency_token: token
    )
    check_consistency_res = Google::Bigtable::Admin::V2::CheckConsistencyResponse.new(
      consistent: true
    )

    mock = Minitest::Mock.new
    mock.expect :generate_consistency_token, gen_token_res, [table_path(instance_id, table_id)]
    mock.expect :check_consistency, check_consistency_res, [table_path(instance_id, table_id), token]

    bigtable.service.mocked_tables = mock

    result = table.wait_for_replication
    result.must_equal true
    mock.verify
  end

  it "generate token and wait for replication timeout" do
    gen_token_res = Google::Bigtable::Admin::V2::GenerateConsistencyTokenResponse.new(
      consistency_token: token
    )
    check_consistency_res = Google::Bigtable::Admin::V2::CheckConsistencyResponse.new(
      consistent: false
    )

    mock = Minitest::Mock.new
    mock.expect :generate_consistency_token, gen_token_res, [table_path(instance_id, table_id)]
    3.times do
      mock.expect :check_consistency, check_consistency_res, [table_path(instance_id, table_id), token]
    end

    bigtable.service.mocked_tables = mock

    time_now = Time.now

    result = table.wait_for_replication(timeout: 2, check_interval: 1)
    result.must_equal false
    (Time.now - time_now).must_be :>=, 2
    mock.verify
  end

  it "wait for replication timeout can not be greater then check interval" do
    proc {
      table.wait_for_replication(timeout: 1, check_interval: 2)
    }.must_raise Google::Cloud::InvalidArgumentError
  end
end
