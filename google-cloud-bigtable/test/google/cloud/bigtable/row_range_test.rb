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

describe Google::Cloud::Bigtable::RowRange, :row_range, :mock_bigtable do
  describe "#from" do
    it "create inclusive from range instance" do
      from_key = "from-key-inclusive"
      range = Google::Cloud::Bigtable::RowRange.new.from(from_key)

      range.must_be_kind_of Google::Cloud::Bigtable::RowRange

      grpc = range.to_grpc
      grpc.must_be_kind_of Google::Bigtable::V2::RowRange
      grpc.start_key_closed.must_equal from_key
    end

    it "create exclusive from range instance" do
      from_key = "from-key-exclusive"
      range = Google::Cloud::Bigtable::RowRange.new.from(from_key, inclusive: false)

      range.must_be_kind_of Google::Cloud::Bigtable::RowRange

      grpc = range.to_grpc
      grpc.must_be_kind_of Google::Bigtable::V2::RowRange
      grpc.start_key_open.must_equal from_key
    end

    it "create instance with from and to range" do
      from_key = "from-key"
      to_key = "to-key"
      range = Google::Cloud::Bigtable::RowRange.new.from(from_key).to(to_key)

      range.must_be_kind_of Google::Cloud::Bigtable::RowRange

      grpc = range.to_grpc
      grpc.must_be_kind_of Google::Bigtable::V2::RowRange
      grpc.start_key_closed.must_equal from_key
      grpc.end_key_open.must_equal to_key
    end
  end

  describe "#to" do
    it "create exclusive to range instance" do
      to_key = "to-key-inclusive"
      range = Google::Cloud::Bigtable::RowRange.new.to(to_key)

      range.must_be_kind_of Google::Cloud::Bigtable::RowRange

      grpc = range.to_grpc
      grpc.must_be_kind_of Google::Bigtable::V2::RowRange
      grpc.end_key_open.must_equal to_key
    end

    it "create inclusive to range instance" do
      to_key = "to-key-exclusive"
      range = Google::Cloud::Bigtable::RowRange.new.to(to_key, inclusive: true)

      range.must_be_kind_of Google::Cloud::Bigtable::RowRange

      grpc = range.to_grpc
      grpc.must_be_kind_of Google::Bigtable::V2::RowRange
      grpc.end_key_closed.must_equal to_key
    end

    it "create instance with from and to range" do
      from_key = "from-key"
      to_key = "to-key"
      range = Google::Cloud::Bigtable::RowRange.new.to(to_key).from(from_key)

      range.must_be_kind_of Google::Cloud::Bigtable::RowRange

      grpc = range.to_grpc
      grpc.must_be_kind_of Google::Bigtable::V2::RowRange
      grpc.start_key_closed.must_equal from_key
      grpc.end_key_open.must_equal to_key
    end
  end

  it "create instance using between" do
    from_key = "from-key"
    to_key = "to-key"
    range = Google::Cloud::Bigtable::RowRange.new.between(from_key, to_key)

    range.must_be_kind_of Google::Cloud::Bigtable::RowRange

    grpc = range.to_grpc
    grpc.must_be_kind_of Google::Bigtable::V2::RowRange
    grpc.start_key_closed.must_equal from_key
    grpc.end_key_closed.must_equal to_key
  end

  it "create instance using of" do
    from_key = "from-key"
    to_key = "to-key"
    range = Google::Cloud::Bigtable::RowRange.new.of(from_key, to_key)

    range.must_be_kind_of Google::Cloud::Bigtable::RowRange

    grpc = range.to_grpc
    grpc.must_be_kind_of Google::Bigtable::V2::RowRange
    grpc.start_key_closed.must_equal from_key
    grpc.end_key_open.must_equal to_key
  end
end
