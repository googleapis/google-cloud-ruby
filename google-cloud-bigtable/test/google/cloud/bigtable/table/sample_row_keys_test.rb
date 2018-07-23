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

describe Google::Cloud::Bigtable::Table, :sample_row_keys, :mock_bigtable do
  let(:instance_id) { "test-instance" }
  let(:table_id) { "test-table" }

  it "get sample row keys" do
    mock = Minitest::Mock.new
    bigtable.service.mocked_client = mock
    table = bigtable.table(instance_id, table_id, skip_lookup: true)

    row_key = "user-1"
    offset = 1000
    res = [
      Google::Bigtable::V2::SampleRowKeysResponse.new(row_key: row_key, offset_bytes: offset)
    ]
    mock.expect :sample_row_keys, res, [
      table_path(instance_id, table_id),
      app_profile_id: nil
    ]

    table.sample_row_keys.each do |sample_row|
      sample_row.must_be_kind_of Google::Cloud::Bigtable::SampleRowKey
      sample_row.key.must_equal row_key
      sample_row.offset.must_equal offset
    end
    mock.verify
  end
end
