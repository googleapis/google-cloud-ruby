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

describe Gcloud::Datastore::Entity, :exclude_from_indexes do

  let(:entity) do
    Gcloud::Datastore::Entity.new.tap do |entity|
      entity.key = Gcloud::Datastore::Key.new "User", "username"
      entity["name"] = "User McUser"
      entity["email"] = "user@example.net"
    end
  end

  it "doesn't exclude from indexes by default" do
    refute entity.exclude_from_indexes?("name")
    refute entity.exclude_from_indexes?("email")

    proto = entity.to_proto

    assert proto.property.find { |p| p.name == "name"  }.value.indexed.must_equal true
    assert proto.property.find { |p| p.name == "email" }.value.indexed.must_equal true
  end

  it "excludes when setting a boolean" do
    entity["age"] = 21
    entity.exclude_from_indexes! "age", true

    entity.exclude_from_indexes?("age").must_equal true

    proto = entity.to_proto

    proto.property.find { |p| p.name == "age"  }.value.indexed.must_equal false
  end

  it "excludes when setting a Proc" do
    entity["age"] = 21
    entity.exclude_from_indexes! "age" do |age|
      age > 18
    end

    entity.exclude_from_indexes?("age").must_equal true

    proto = entity.to_proto

    proto.property.find { |p| p.name == "age"  }.value.indexed.must_equal false

    # And now the inverse, the Proc evaluates to false

    entity.exclude_from_indexes! "age" do |age|
      age < 18
    end

    entity.exclude_from_indexes?("age").must_equal false

    proto = entity.to_proto

    proto.property.find { |p| p.name == "age"  }.value.indexed.must_equal true
  end

  it "excludes when setting an Array on a non array value" do
    entity["age"] = 21
    entity.exclude_from_indexes! "age", [true, false, true, false]

    entity.exclude_from_indexes?("age").must_equal true

    proto = entity.to_proto

    proto.property.find { |p| p.name == "age"  }.value.indexed.must_equal false

    # And now the inverse, the first value is false

    entity.exclude_from_indexes! "age", [false, true, false, true]

    entity.exclude_from_indexes?("age").must_equal false

    proto = entity.to_proto

    proto.property.find { |p| p.name == "age"  }.value.indexed.must_equal true
  end

  describe Array do
    it "doesn't exclude Array values from indexes by default" do
      entity["tags"] = ["ruby", "code"]

      entity.exclude_from_indexes?("tags").must_equal [false, false]

      proto = entity.to_proto

      tag_proto = proto.property.find { |p| p.name == "tags"  }.value
      tag_proto.indexed.must_be :nil? # list values must always be unset
      tag_proto.list_value.map { |value| value.indexed }.must_equal [true, true]
    end

    it "excludes an Array when setting a boolean" do
      entity["tags"] = ["ruby", "code"]
      entity.exclude_from_indexes! "tags", true

      entity.exclude_from_indexes?("tags").must_equal [true, true]

      proto = entity.to_proto

      tag_proto = proto.property.find { |p| p.name == "tags"  }.value
      tag_proto.indexed.must_be :nil? # list values must always be unset
      tag_proto.list_value.map { |value| value.indexed }.must_equal [false, false]
    end

    it "excludes an Array when setting a Proc" do
      entity["tags"] = ["ruby", "code"]
      entity.exclude_from_indexes! "tags" do |tag|
        tag =~ /r/
      end

      entity.exclude_from_indexes?("tags").must_equal [true, false]

      proto = entity.to_proto

      tag_proto = proto.property.find { |p| p.name == "tags"  }.value
      tag_proto.indexed.must_be :nil? # list values must always be unset
      tag_proto.list_value.map { |value| value.indexed }.must_equal [false, true]

      # And now the inverse, the Proc evaluates to false

      entity["tags"] = ["ruby", "code"]
      entity.exclude_from_indexes! "tags" do |tag|
        tag =~ /c/
      end

      entity.exclude_from_indexes?("tags").must_equal [false, true]

      proto = entity.to_proto

      tag_proto = proto.property.find { |p| p.name == "tags"  }.value
      tag_proto.indexed.must_be :nil? # list values must always be unset
      tag_proto.list_value.map { |value| value.indexed }.must_equal [true, false]
    end

    it "excludes an Array when setting an Array" do
      entity["tags"] = ["ruby", "code"]
      entity.exclude_from_indexes! "tags", [true, false]

      entity.exclude_from_indexes?("tags").must_equal [true, false]

      proto = entity.to_proto

      tag_proto = proto.property.find { |p| p.name == "tags"  }.value
      tag_proto.indexed.must_be :nil? # list values must always be unset
      tag_proto.list_value.map { |value| value.indexed }.must_equal [false, true]
    end

    it "excludes an Array when setting an Array that is too small" do
      entity["tags"] = ["ruby", "code", "google", "cloud"]
      entity.exclude_from_indexes! "tags", [true, false]

      # the default is to not exclude when the array is too small
      entity.exclude_from_indexes?("tags").must_equal [true, false, false, false]

      proto = entity.to_proto

      tag_proto = proto.property.find { |p| p.name == "tags"  }.value
      tag_proto.indexed.must_be :nil? # list values must always be unset
      tag_proto.list_value.map { |value| value.indexed }.must_equal [false, true, true, true]
    end

    it "excludes an Array when setting an Array that is too big" do
      entity["tags"] = ["ruby", "code"]
      entity.exclude_from_indexes! "tags", [true, false, true, false, true, false]

      entity.exclude_from_indexes?("tags").must_equal [true, false]

      proto = entity.to_proto

      tag_proto = proto.property.find { |p| p.name == "tags"  }.value
      tag_proto.indexed.must_be :nil? # list values must always be unset
      tag_proto.list_value.map { |value| value.indexed }.must_equal [false, true]

      # Now add to the entity and get the previously stored exclude values

      entity["tags"] = ["ruby", "code", "google", "cloud"]

      entity.exclude_from_indexes?("tags").must_equal [true, false, true, false]

      proto = entity.to_proto

      tag_proto = proto.property.find { |p| p.name == "tags"  }.value
      tag_proto.indexed.must_be :nil? # list values must always be unset
      tag_proto.list_value.map { |value| value.indexed }.must_equal [false, true, false, true]
    end
  end

  describe "Edge Cases" do
    it "recalculates when changing from a single value to an array" do
      entity["tags"] = "ruby"

      entity.exclude_from_indexes?("tags").must_equal false

      entity.exclude_from_indexes! "tags", true

      entity.exclude_from_indexes?("tags").must_equal true

      entity["tags"] = ["ruby", "code"]

      entity.exclude_from_indexes?("tags").must_equal [true, true]

      entity.exclude_from_indexes! "tags", [false, false]

      entity["tags"] = "ruby"

      entity.exclude_from_indexes?("tags").must_equal false
    end
  end
end
