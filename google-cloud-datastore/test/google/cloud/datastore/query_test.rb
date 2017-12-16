# Copyright 2014 Google LLC
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

describe Google::Cloud::Datastore::Query, :mock_datastore do
  let(:query) { Google::Cloud::Datastore::Query.new }
  it "can query on kind" do
    query.kind "Task"

    grpc = query.to_grpc
    grpc.kind.map(&:name).must_include "Task"
    grpc.kind.map(&:name).wont_include "User"

    # Add a second kind to the query
    query.kind "User"

    grpc = query.to_grpc
    grpc.kind.map(&:name).must_include "Task"
    grpc.kind.map(&:name).must_include "User"
  end

  it "can filter properties" do
    query.kind "Task"
    query.where "completed", "=", true

    grpc = query.to_grpc
    grpc.filter.wont_be :nil?
    grpc.filter.filter_type.must_equal :composite_filter
    grpc.filter.property_filter.must_be :nil?
    grpc.filter.composite_filter.wont_be :nil?
    grpc.filter.composite_filter.op.must_equal :AND
    grpc.filter.composite_filter.filters.count.must_equal 1

    new_filter = grpc.filter.composite_filter.filters.first
    new_filter.property_filter.property.name.must_equal "completed"
    new_filter.property_filter.op.must_equal :EQUAL
    Google::Cloud::Datastore::Convert.from_value(new_filter.property_filter.value).must_equal true

    # Add a second filter and generate new grpcbuf
    # Use the filter alias to add the second filter
    query.filter "due", :>, Time.new(2014, 1, 1, 0, 0, 0, 0)
    grpc = query.to_grpc
    grpc.filter.composite_filter.filters.count.must_equal 2

    first_filter = grpc.filter.composite_filter.filters.first
    first_filter.property_filter.wont_be :nil?
    first_filter.composite_filter.must_be :nil?
    first_filter.property_filter.property.name.must_equal "completed"
    first_filter.property_filter.op.must_equal :EQUAL
    Google::Cloud::Datastore::Convert.from_value(first_filter.property_filter.value).must_equal true

    second_filter = grpc.filter.composite_filter.filters.last
    second_filter.property_filter.wont_be :nil?
    second_filter.composite_filter.must_be :nil?
    second_filter.property_filter.property.name.must_equal "due"
    second_filter.property_filter.op.must_equal :GREATER_THAN
    Google::Cloud::Datastore::Convert.from_value(second_filter.property_filter.value).must_equal Time.new(2014, 1, 1, 0, 0, 0, 0)
  end

  it "can order results" do
    query.kind "Task"
    query.order "due"

    grpc = query.to_grpc
    order = order_as_arrays grpc
    order.must_include [ "due",       :ASCENDING ]
    order.wont_include [ "completed", :DESCENDING ]

    # Add a second kind to the query
    query.order "completed", :desc

    grpc = query.to_grpc
    order = order_as_arrays grpc
    order.must_include [ "due",       :ASCENDING ]
    order.must_include [ "completed", :DESCENDING ]
  end

  it "accepts any string that starts with 'd' for DESCENDING" do
    query.kind "Task"
    query.order "completed", "DOWN"

    grpc = query.to_grpc
    order = order_as_arrays grpc

    order.must_include [ "completed", :DESCENDING ]
  end

  it "can limit and offset" do
    query.kind "Task"

    grpc = query.to_grpc
    grpc.limit.must_be :nil?

    query.limit 10

    grpc = query.to_grpc
    grpc.limit.must_equal Google::Protobuf::Int32Value.new(value: 10)

    grpc.offset.must_equal 0

    query.offset 20

    grpc = query.to_grpc
    grpc.offset.must_equal 20
  end

  it "can specify a cursor" do
    raw_cursor = "\x13\xE0\x01\x00\xEB".force_encoding Encoding::ASCII_8BIT
    encoded_cursor = "E+ABAOs="

    query.kind "Task"

    grpc = query.to_grpc
    grpc.start_cursor.must_be :empty?

    query.cursor encoded_cursor

    grpc = query.to_grpc
    grpc.start_cursor.must_equal raw_cursor
  end

  it "can select the properties to return" do
    query.kind "Task"

    grpc = query.to_grpc
    grpc.projection.must_be :empty?

    query.select "completed"

    grpc = query.to_grpc
    grpc.projection.wont_be :empty?
    grpc.projection.count.must_equal 1
    grpc.projection.first.property.name.must_equal "completed"
  end

  it "can select the properties using projection alias" do
    query.kind "Task"

    grpc = query.to_grpc
    grpc.projection.must_be :empty?

    # Use projection instead of select
    query.projection "completed"

    grpc = query.to_grpc
    grpc.projection.wont_be :empty?
    grpc.projection.count.must_equal 1
    grpc.projection.first.property.name.must_equal "completed"
  end

  it "can group on properties" do
    query.kind "Task"

    grpc = query.to_grpc
    grpc.distinct_on.must_be :empty?

    query.group_by "completed"

    grpc = query.to_grpc
    grpc.distinct_on.wont_be :empty?
    grpc.distinct_on.count.must_equal 1
    grpc.distinct_on.first.name.must_equal "completed"
  end

  it "can group on properties using distinct_on" do
    query.kind "Task"

    grpc = query.to_grpc
    grpc.distinct_on.must_be :empty?

    query.distinct_on "completed"

    grpc = query.to_grpc
    grpc.distinct_on.wont_be :empty?
    grpc.distinct_on.count.must_equal 1
    grpc.distinct_on.first.name.must_equal "completed"
  end

  it "can query ancestor" do
    ancestor_key = Google::Cloud::Datastore::Key.new("User", "username")
    query.kind "Task"
    query.ancestor ancestor_key

    grpc = query.to_grpc

    grpc.filter.composite_filter.filters.count.must_equal 1

    ancestor_filter = grpc.filter.composite_filter.filters.first
    ancestor_filter.property_filter.property.name.must_equal "__key__"
    ancestor_filter.property_filter.op.must_equal :HAS_ANCESTOR
    key = Google::Cloud::Datastore::Convert.from_value(ancestor_filter.property_filter.value)
    key.kind.must_equal ancestor_key.kind
    key.id.must_be :nil?
    key.name.must_equal ancestor_key.name
  end

  it "can manually filter on ancestor" do
    ancestor_key = Google::Cloud::Datastore::Key.new("User", "username")
    query.kind "Task"
    query.filter "__key__", "~", ancestor_key

    grpc = query.to_grpc

    grpc.filter.composite_filter.filters.count.must_equal 1

    ancestor_filter = grpc.filter.composite_filter.filters.first
    ancestor_filter.property_filter.property.name.must_equal "__key__"
    ancestor_filter.property_filter.op.must_equal :HAS_ANCESTOR
    key = Google::Cloud::Datastore::Convert.from_value(ancestor_filter.property_filter.value)
    key.kind.must_equal ancestor_key.kind
    key.id.must_be :nil?
    key.name.must_equal ancestor_key.name
  end

  it "can chain query methods" do
    q2 = query.kind("Task").select("due", "completed").
      where("completed", "=", true).group_by("completed").
      order("due", :desc).limit(10).offset(20)

    q2.must_equal query
    q2.to_grpc.must_equal query.to_grpc

    grpc = query.to_grpc

    grpc.kind.map(&:name).must_include "Task"

    grpc.projection.wont_be :nil?
    grpc.projection.count.must_equal 2
    grpc.projection.first.property.name.must_equal "due"
    grpc.projection.last.property.name.must_equal "completed"

    filter = grpc.filter.composite_filter.filters.first
    filter.property_filter.property.name.must_equal "completed"
    filter.property_filter.op.must_equal :EQUAL
    Google::Cloud::Datastore::Convert.from_value(filter.property_filter.value).must_equal true

    grpc.distinct_on.wont_be :empty?
    grpc.distinct_on.count.must_equal 1
    grpc.distinct_on.first.name.must_equal "completed"

    order = order_as_arrays grpc
    order.must_include [ "due", :DESCENDING ]

    grpc.limit.must_equal Google::Protobuf::Int32Value.new(value: 10)

    grpc.offset.must_equal 20
  end

  def order_as_arrays grpc
    grpc.order.map do |o|
      [o.property.name, o.direction]
    end
  end
end
