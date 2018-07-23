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

describe Google::Cloud::Bigtable::ColumnRange, :column_range, :mock_bigtable do
  it "create empty instance with only column family" do
    family_name = "cf"
    range = Google::Cloud::Bigtable::ColumnRange.new(family_name)
    grpc = range.to_grpc
    grpc.must_be_kind_of Google::Bigtable::V2::ColumnRange
    grpc.family_name.must_equal family_name
  end

  describe "#from" do
    it "create inclusive from range instance" do
      from_qualifier = "from-qual-inclusive"
      range = Google::Cloud::Bigtable::ColumnRange.new("cf").from(from_qualifier)
      range.must_be_kind_of Google::Cloud::Bigtable::ColumnRange
      grpc = range.to_grpc
      grpc.start_qualifier_closed.must_equal from_qualifier
    end

    it "create exclusive from range instance" do
      from_qualifier = "from-qual-exclusive"
      range = Google::Cloud::Bigtable::ColumnRange.new("cf").from(from_qualifier, inclusive: false)
      range.must_be_kind_of Google::Cloud::Bigtable::ColumnRange
      grpc = range.to_grpc
      grpc.start_qualifier_open.must_equal from_qualifier
    end

    it "create instance with from and to range" do
      from_qualifier = "from-qual"
      to_qualifier = "to-qualifier"
      range = Google::Cloud::Bigtable::ColumnRange.new("cf").from(from_qualifier).to(to_qualifier)
      range.must_be_kind_of Google::Cloud::Bigtable::ColumnRange
      grpc = range.to_grpc
      grpc.start_qualifier_closed.must_equal from_qualifier
      grpc.end_qualifier_open.must_equal to_qualifier
    end
  end

  describe "#to" do
    it "create exclusive to range instance" do
      to_qualifier = "to-qualifier-inclusive"
      range = Google::Cloud::Bigtable::ColumnRange.new("cf").to(to_qualifier)
      range.must_be_kind_of Google::Cloud::Bigtable::ColumnRange
      grpc = range.to_grpc
      grpc.end_qualifier_open.must_equal to_qualifier
    end

    it "create inclusive to range instance" do
      to_qualifier = "to-qualifier-exclusive"
      range = Google::Cloud::Bigtable::ColumnRange.new("cf").to(to_qualifier, inclusive: true)
      range.must_be_kind_of Google::Cloud::Bigtable::ColumnRange
      grpc = range.to_grpc
      grpc.end_qualifier_closed.must_equal to_qualifier
    end

    it "create instance with from and to range" do
      from_qualifier = "from-qual"
      to_qualifier = "to-qualifier"
      range = Google::Cloud::Bigtable::ColumnRange.new("cf").to(to_qualifier).from(from_qualifier)
      range.must_be_kind_of Google::Cloud::Bigtable::ColumnRange
      grpc = range.to_grpc
      grpc.start_qualifier_closed.must_equal from_qualifier
      grpc.end_qualifier_open.must_equal to_qualifier
    end
  end

  it "create instance using 'between'" do
    from_qualifier = "from-qual"
    to_qualifier = "to-qualifier"
    range = Google::Cloud::Bigtable::ColumnRange.new("cf").between(from_qualifier, to_qualifier)
    range.must_be_kind_of Google::Cloud::Bigtable::ColumnRange
    grpc = range.to_grpc
    grpc.start_qualifier_closed.must_equal from_qualifier
    grpc.end_qualifier_closed.must_equal to_qualifier
  end

  it "create instance using 'of'" do
    from_qualifier = "from-qual"
    to_qualifier = "to-qualifier"
    range = Google::Cloud::Bigtable::ColumnRange.new("cf").of(from_qualifier, to_qualifier)
    range.must_be_kind_of Google::Cloud::Bigtable::ColumnRange
    grpc = range.to_grpc
    grpc.start_qualifier_closed.must_equal from_qualifier
    grpc.end_qualifier_open.must_equal to_qualifier
  end
end
