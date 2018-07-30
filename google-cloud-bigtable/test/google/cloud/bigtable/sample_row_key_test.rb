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

describe Google::Cloud::Bigtable::SampleRowKey, :simple_row_key, :mock_bigtable do
  it "create instance from grpc instance with row key and offset" do
    row_key = "test-row-key"
    offset = 1000
    grpc = Google::Bigtable::V2::SampleRowKeysResponse.new(row_key: row_key, offset_bytes: offset)

    sample_row_key = Google::Cloud::Bigtable::SampleRowKey.from_grpc(grpc)

    sample_row_key.must_be_kind_of Google::Cloud::Bigtable::SampleRowKey
    sample_row_key.key.must_equal row_key
    sample_row_key.offset.must_equal offset
  end
end
