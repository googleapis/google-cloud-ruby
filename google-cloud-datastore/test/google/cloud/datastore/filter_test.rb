# Copyright 2023 Google LLC
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

describe Google::Cloud::Datastore::Filter, :mock_datastore do
  it "creates simple property filter" do
    filter = Google::Cloud::Datastore::Filter.new("a", "=", 3)
    grpc = filter.to_grpc
    _(grpc).must_be_kind_of Google::Cloud::Datastore::V1::Filter
    _(grpc.filter_type).must_equal :property_filter
    _(grpc.composite_filter).must_be :nil?
    _(grpc.property_filter).wont_be :nil?
    _(grpc.property_filter.property.name).must_equal "a"
    _(grpc.property_filter.op).must_equal :EQUAL
    _(Google::Cloud::Datastore::Convert.from_value(grpc.property_filter.value)).must_equal 3
  end

  it "creates a composite OR filter by passing a raw condition" do
    filter = Google::Cloud::Datastore::Filter.new("a", "=", 3)
                                             .or("b", ">", 4)
    grpc = filter.to_grpc
    _(grpc).must_be_kind_of Google::Cloud::Datastore::V1::Filter
    _(grpc.filter_type).must_equal :composite_filter
    _(grpc.composite_filter).wont_be :nil?
    _(grpc.property_filter).must_be :nil?
    _(grpc.composite_filter.op).must_equal :OR 
    _(grpc.composite_filter.filters.count).must_equal 2

    filter_1 = grpc.composite_filter.filters.first
    _(filter_1.filter_type).must_equal :property_filter
    _(filter_1.composite_filter).must_be :nil?
    _(filter_1.property_filter).wont_be :nil?
    _(filter_1.property_filter.property.name).must_equal "a"
    _(filter_1.property_filter.op).must_equal :EQUAL
    _(Google::Cloud::Datastore::Convert.from_value(filter_1.property_filter.value)).must_equal 3

    filter_2 = grpc.composite_filter.filters.last
    _(filter_2.filter_type).must_equal :property_filter
    _(filter_2.composite_filter).must_be :nil?
    _(filter_2.property_filter).wont_be :nil?
    _(filter_2.property_filter.property.name).must_equal "b"
    _(filter_2.property_filter.op).must_equal :GREATER_THAN
    _(Google::Cloud::Datastore::Convert.from_value(filter_2.property_filter.value)).must_equal 4
  end

  it "creates a composite AND filter by passing a raw condition" do
    filter = Google::Cloud::Datastore::Filter.new("a", "=", 3)
                                             .and("b", ">", 4)
    grpc = filter.to_grpc
    _(grpc).must_be_kind_of Google::Cloud::Datastore::V1::Filter
    _(grpc.filter_type).must_equal :composite_filter
    _(grpc.composite_filter).wont_be :nil?
    _(grpc.property_filter).must_be :nil?
    _(grpc.composite_filter.op).must_equal :AND 
    _(grpc.composite_filter.filters.count).must_equal 2

    filter_1 = grpc.composite_filter.filters.first
    _(filter_1.filter_type).must_equal :property_filter
    _(filter_1.composite_filter).must_be :nil?
    _(filter_1.property_filter).wont_be :nil?
    _(filter_1.property_filter.property.name).must_equal "a"
    _(filter_1.property_filter.op).must_equal :EQUAL
    _(Google::Cloud::Datastore::Convert.from_value(filter_1.property_filter.value)).must_equal 3

    filter_2 = grpc.composite_filter.filters.last
    _(filter_2.filter_type).must_equal :property_filter
    _(filter_2.composite_filter).must_be :nil?
    _(filter_2.property_filter).wont_be :nil?
    _(filter_2.property_filter.property.name).must_equal "b"
    _(filter_2.property_filter.op).must_equal :GREATER_THAN
    _(Google::Cloud::Datastore::Convert.from_value(filter_2.property_filter.value)).must_equal 4
  end

  it "creates a composite OR filter by passing a filter object" do
    filter = Google::Cloud::Datastore::Filter.new("a", "=", 3)
                                             .or(Google::Cloud::Datastore::Filter.new("b", ">", 4))
    grpc = filter.to_grpc
    _(grpc).must_be_kind_of Google::Cloud::Datastore::V1::Filter
    _(grpc.filter_type).must_equal :composite_filter
    _(grpc.composite_filter).wont_be :nil?
    _(grpc.property_filter).must_be :nil?
    _(grpc.composite_filter.op).must_equal :OR 
    _(grpc.composite_filter.filters.count).must_equal 2

    filter_1 = grpc.composite_filter.filters.first
    _(filter_1.filter_type).must_equal :property_filter
    _(filter_1.composite_filter).must_be :nil?
    _(filter_1.property_filter).wont_be :nil?
    _(filter_1.property_filter.property.name).must_equal "a"
    _(filter_1.property_filter.op).must_equal :EQUAL
    _(Google::Cloud::Datastore::Convert.from_value(filter_1.property_filter.value)).must_equal 3

    filter_2 = grpc.composite_filter.filters.last
    _(filter_2.filter_type).must_equal :property_filter
    _(filter_2.composite_filter).must_be :nil?
    _(filter_2.property_filter).wont_be :nil?
    _(filter_2.property_filter.property.name).must_equal "b"
    _(filter_2.property_filter.op).must_equal :GREATER_THAN
    _(Google::Cloud::Datastore::Convert.from_value(filter_2.property_filter.value)).must_equal 4
  end

  it "creates a composite AND filter by passing a filter object" do
    filter = Google::Cloud::Datastore::Filter.new("a", "=", 3)
                                             .and(Google::Cloud::Datastore::Filter.new("b", ">", 4))
    grpc = filter.to_grpc
    _(grpc).must_be_kind_of Google::Cloud::Datastore::V1::Filter
    _(grpc.filter_type).must_equal :composite_filter
    _(grpc.composite_filter).wont_be :nil?
    _(grpc.property_filter).must_be :nil?
    _(grpc.composite_filter.op).must_equal :AND 
    _(grpc.composite_filter.filters.count).must_equal 2

    filter_1 = grpc.composite_filter.filters.first
    _(filter_1.filter_type).must_equal :property_filter
    _(filter_1.composite_filter).must_be :nil?
    _(filter_1.property_filter).wont_be :nil?
    _(filter_1.property_filter.property.name).must_equal "a"
    _(filter_1.property_filter.op).must_equal :EQUAL
    _(Google::Cloud::Datastore::Convert.from_value(filter_1.property_filter.value)).must_equal 3

    filter_2 = grpc.composite_filter.filters.last
    _(filter_2.filter_type).must_equal :property_filter
    _(filter_2.composite_filter).must_be :nil?
    _(filter_2.property_filter).wont_be :nil?
    _(filter_2.property_filter.property.name).must_equal "b"
    _(filter_2.property_filter.op).must_equal :GREATER_THAN
    _(Google::Cloud::Datastore::Convert.from_value(filter_2.property_filter.value)).must_equal 4
  end

  it "creates nested filters" do
    part_1 = Google::Cloud::Datastore::Filter.new("a", "=", 3)
                                             .or("b", ">", 4)
    part_2 = Google::Cloud::Datastore::Filter.new("c", "<", 10)
                                             .or("d", ">", 11)
    filter = part_1.and(part_2)

    grpc = filter.to_grpc
    _(grpc).must_be_kind_of Google::Cloud::Datastore::V1::Filter
    _(grpc.filter_type).must_equal :composite_filter
    _(grpc.composite_filter).wont_be :nil?
    _(grpc.property_filter).must_be :nil?
    _(grpc.composite_filter.op).must_equal :AND 
    _(grpc.composite_filter.filters.count).must_equal 2

    filter_1 = grpc.composite_filter.filters.first
    _(filter_1.filter_type).must_equal :composite_filter
    _(filter_1.composite_filter).wont_be :nil?
    _(filter_1.property_filter).must_be :nil?
    _(filter_1.composite_filter.op).must_equal :OR 
    _(filter_1.composite_filter.filters.count).must_equal 2

    filter_11 = filter_1.composite_filter.filters.first
    _(filter_11.filter_type).must_equal :property_filter
    _(filter_11.composite_filter).must_be :nil?
    _(filter_11.property_filter).wont_be :nil?
    _(filter_11.property_filter.property.name).must_equal "a"
    _(filter_11.property_filter.op).must_equal :EQUAL
    _(Google::Cloud::Datastore::Convert.from_value(filter_11.property_filter.value)).must_equal 3

    filter_12 = filter_1.composite_filter.filters.last
    _(filter_12.filter_type).must_equal :property_filter
    _(filter_12.composite_filter).must_be :nil?
    _(filter_12.property_filter).wont_be :nil?
    _(filter_12.property_filter.property.name).must_equal "b"
    _(filter_12.property_filter.op).must_equal :GREATER_THAN
    _(Google::Cloud::Datastore::Convert.from_value(filter_12.property_filter.value)).must_equal 4

    filter_2 = grpc.composite_filter.filters.last
    _(filter_2.filter_type).must_equal :composite_filter
    _(filter_2.composite_filter).wont_be :nil?
    _(filter_2.property_filter).must_be :nil?
    _(filter_2.composite_filter.op).must_equal :OR 
    _(filter_2.composite_filter.filters.count).must_equal 2

    filter_21 = filter_2.composite_filter.filters.first
    _(filter_21.filter_type).must_equal :property_filter
    _(filter_21.composite_filter).must_be :nil?
    _(filter_21.property_filter).wont_be :nil?
    _(filter_21.property_filter.property.name).must_equal "c"
    _(filter_21.property_filter.op).must_equal :LESS_THAN
    _(Google::Cloud::Datastore::Convert.from_value(filter_21.property_filter.value)).must_equal 10

    filter_22 = filter_2.composite_filter.filters.last
    _(filter_22.filter_type).must_equal :property_filter
    _(filter_22.composite_filter).must_be :nil?
    _(filter_22.property_filter).wont_be :nil?
    _(filter_22.property_filter.property.name).must_equal "d"
    _(filter_22.property_filter.op).must_equal :GREATER_THAN
    _(Google::Cloud::Datastore::Convert.from_value(filter_22.property_filter.value)).must_equal 11
  end

  it "does not mutate existing filter objects on .and() method" do
    filter_1 = Google::Cloud::Datastore::Filter.new("a", "=", 3)
    filter_2 = Google::Cloud::Datastore::Filter.new("b", ">", 4)
    filter_3 = filter_1.and(filter_2)
    _(filter_1.to_grpc).must_equal Google::Cloud::Datastore::Filter.new("a", "=", 3).to_grpc
    _(filter_2.to_grpc).must_equal Google::Cloud::Datastore::Filter.new("b", ">", 4).to_grpc
  end

  it "does not mutate existing filter objects on .or() method" do
    filter_1 = Google::Cloud::Datastore::Filter.new("a", "=", 3)
    filter_2 = Google::Cloud::Datastore::Filter.new("b", ">", 4)
    filter_3 = filter_1.or(filter_2)
    _(filter_1.to_grpc).must_equal Google::Cloud::Datastore::Filter.new("a", "=", 3).to_grpc
    _(filter_2.to_grpc).must_equal Google::Cloud::Datastore::Filter.new("b", ">", 4).to_grpc
  end
end
