# Copyright 2014 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"
require "gcloud/datastore"

describe Gcloud::Datastore::Query, :proto do
  it "can query on kind" do
    query = Gcloud::Datastore::Query.new
    query.kind "Task"

    proto = query.to_proto
    proto.kind.name.must_include "Task"
    proto.kind.name.wont_include "User"

    # Add a second kind to the query
    query.kind "User"

    proto = query.to_proto
    proto.kind.name.must_include "Task"
    proto.kind.name.must_include "User"
  end

  it "can filter properties" do
    query = Gcloud::Datastore::Query.new
    query.kind "Task"
    query.where "completed", "=", true

    proto = query.to_proto
    refute_nil proto.filter
    assert_nil proto.filter.property_filter
    refute_nil proto.filter.composite_filter
    assert_equal Gcloud::Datastore::Proto::CompositeFilter::Operator::AND,
                 proto.filter.composite_filter.operator
    assert_equal 1, proto.filter.composite_filter.filter.count

    new_filter = proto.filter.composite_filter.filter.first
    assert_equal "completed", new_filter.property_filter.property.name
    assert_equal Gcloud::Datastore::Proto::PropertyFilter::Operator::EQUAL,
                 new_filter.property_filter.operator
    assert_equal true, Gcloud::Datastore::Proto.from_proto_value(new_filter.property_filter.value)

    # Add a second filter and generate new protobuf
    # Use the filter alias to add the second filter
    query.filter "due", :>, Time.new(2014, 1, 1, 0, 0, 0, 0)
    proto = query.to_proto
    assert_equal 2, proto.filter.composite_filter.filter.count

    first_filter = proto.filter.composite_filter.filter.first
    refute_nil first_filter.property_filter
    assert_nil first_filter.composite_filter
    assert_equal "completed", first_filter.property_filter.property.name
    assert_equal Gcloud::Datastore::Proto::PropertyFilter::Operator::EQUAL,
                 first_filter.property_filter.operator
    assert_equal true, Gcloud::Datastore::Proto.from_proto_value(first_filter.property_filter.value)

    second_filter = proto.filter.composite_filter.filter.last
    refute_nil second_filter.property_filter
    assert_nil second_filter.composite_filter
    assert_equal "due", second_filter.property_filter.property.name
    assert_equal Gcloud::Datastore::Proto::PropertyFilter::Operator::GREATER_THAN,
                 second_filter.property_filter.operator
    assert_equal Time.new(2014, 1, 1, 0, 0, 0, 0),
                 Gcloud::Datastore::Proto.from_proto_value(second_filter.property_filter.value)
  end

  it "can order results" do
    query = Gcloud::Datastore::Query.new
    query.kind "Task"
    query.order "due"

    proto = query.to_proto
    order = order_as_arrays proto
    order.must_include [ "due",       :asc ]
    order.wont_include [ "completed", :desc ]

    # Add a second kind to the query
    query.order "completed", :desc

    proto = query.to_proto
    order = order_as_arrays proto
    order.must_include [ "due",       :asc ]
    order.must_include [ "completed", :desc ]
  end

  it "accepts any string that starts with 'd' for DESCENDING" do
    query = Gcloud::Datastore::Query.new
    query.kind "Task"
    query.order "completed", "DOWN"

    proto = query.to_proto
    order = order_as_arrays proto

    order.must_include [ "completed", :desc ]
  end

  it "can limit and offset" do
    query = Gcloud::Datastore::Query.new
    query.kind "Task"

    proto = query.to_proto
    proto.limit.must_be :nil?

    query.limit 10

    proto = query.to_proto
    proto.limit.must_equal 10

    proto.offset.must_be :nil?

    query.offset 20

    proto = query.to_proto
    proto.offset.must_equal 20
  end

  it "can specify a cursor" do
    raw_cursor = "\x13\xE0\x01\x00\xEB".force_encoding Encoding::ASCII_8BIT
    encoded_cursor = "E+ABAOs="

    query = Gcloud::Datastore::Query.new
    query.kind "Task"

    proto = query.to_proto
    proto.start_cursor.must_be :nil?

    query.cursor encoded_cursor

    proto = query.to_proto
    proto.start_cursor.must_equal raw_cursor
  end

  it "can select the properties to return" do
    query = Gcloud::Datastore::Query.new
    query.kind "Task"

    proto = query.to_proto
    proto.projection.must_be :nil?

    query.select "completed"

    proto = query.to_proto
    proto.projection.wont_be :nil?
    proto.projection.count.must_equal 1
    proto.projection.first.property.name.must_equal "completed"
  end

  it "can select the properties using projection alias" do
    query = Gcloud::Datastore::Query.new
    query.kind "Task"

    proto = query.to_proto
    proto.projection.must_be :nil?

    # Use projection instead of select
    query.projection "completed"

    proto = query.to_proto
    proto.projection.wont_be :nil?
    proto.projection.count.must_equal 1
    proto.projection.first.property.name.must_equal "completed"
  end

  it "can group on properties" do
    query = Gcloud::Datastore::Query.new
    query.kind "Task"

    proto = query.to_proto
    proto.group_by.must_be :nil?

    query.group_by "completed"

    proto = query.to_proto
    proto.group_by.wont_be :nil?
    proto.group_by.count.must_equal 1
    proto.group_by.first.name.must_equal "completed"
  end

  it "can query ancestor" do
    ancestor_key = Gcloud::Datastore::Key.new("User", "username")
    query = Gcloud::Datastore::Query.new
    query.kind "Task"
    query.ancestor ancestor_key

    proto = query.to_proto

    assert_equal 1, proto.filter.composite_filter.filter.count

    ancestor_filter = proto.filter.composite_filter.filter.first
    assert_equal "__key__", ancestor_filter.property_filter.property.name
    assert_equal Gcloud::Datastore::Proto::PropertyFilter::Operator::HAS_ANCESTOR,
                 ancestor_filter.property_filter.operator
    key = Gcloud::Datastore::Proto.from_proto_value(ancestor_filter.property_filter.value)
    key.kind.must_equal ancestor_key.kind
    key.id.must_equal   ancestor_key.id
    key.name.must_equal ancestor_key.name
  end

  it "can manually filter on ancestor" do
    ancestor_key = Gcloud::Datastore::Key.new("User", "username")
    query = Gcloud::Datastore::Query.new
    query.kind "Task"
    query.filter "__key__", "~", ancestor_key

    proto = query.to_proto

    assert_equal 1, proto.filter.composite_filter.filter.count

    ancestor_filter = proto.filter.composite_filter.filter.first
    assert_equal "__key__", ancestor_filter.property_filter.property.name
    assert_equal Gcloud::Datastore::Proto::PropertyFilter::Operator::HAS_ANCESTOR,
                 ancestor_filter.property_filter.operator
    key = Gcloud::Datastore::Proto.from_proto_value(ancestor_filter.property_filter.value)
    key.kind.must_equal ancestor_key.kind
    key.id.must_equal   ancestor_key.id
    key.name.must_equal ancestor_key.name
  end

  it "can chain query methods" do
    query = Gcloud::Datastore::Query.new
    q2 = query.kind("Task").select("due", "completed").
      where("completed", "=", true).group_by("completed").
      order("due", :desc).limit(10).offset(20)

    q2.must_equal query
    q2.to_proto.must_equal query.to_proto

    proto = query.to_proto

    proto.kind.name.must_include "Task"

    proto.projection.wont_be :nil?
    proto.projection.count.must_equal 2
    proto.projection.first.property.name.must_equal "due"
    proto.projection.last.property.name.must_equal "completed"

    filter = proto.filter.composite_filter.filter.first
    filter.property_filter.property.name.must_equal "completed"
    filter.property_filter.operator.must_equal Gcloud::Datastore::Proto::PropertyFilter::Operator::EQUAL
    Gcloud::Datastore::Proto.from_proto_value(filter.property_filter.value).must_equal true

    proto.group_by.wont_be :nil?
    proto.group_by.count.must_equal 1
    proto.group_by.first.name.must_equal "completed"

    order = order_as_arrays proto
    order.must_include [ "due", :desc ]

    proto.limit.must_equal 10

    proto.offset.must_equal 20
  end

  def order_as_arrays proto
    proto.order.map do |o|
      [o.property.name,
      (o.direction == Gcloud::Datastore::Proto::PropertyOrder::Direction::DESCENDING) ? :desc : :asc]
    end
  end
end
