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

describe Google::Cloud::Datastore::Entity, :exclude_from_indexes, :mock_datastore do

  let(:entity) do
    Google::Cloud::Datastore::Entity.new.tap do |ent|
      ent.key = Google::Cloud::Datastore::Key.new "User", "username"
      ent["name"] = "User McUser"
      ent["email"] = "user@example.net"
    end
  end

  it "converts indexed value to not excluded from a GRPC object" do
    grpc = Google::Datastore::V1::Entity.new
    grpc.key = Google::Datastore::V1::Key.new
    grpc.key.path << Google::Datastore::V1::Key::PathElement.new(kind: "User", id: 123456)
    grpc.properties["name"] = Google::Cloud::Datastore::Convert.to_value "User McNumber"

    entity_from_grpc = Google::Cloud::Datastore::Entity.from_grpc grpc
    entity_from_grpc.exclude_from_indexes?("name").must_equal false
  end

  it "converts indexed list to not excluded from a GRPC object" do
    grpc = Google::Datastore::V1::Entity.new
    grpc.key = Google::Datastore::V1::Key.new
    grpc.key.path << Google::Datastore::V1::Key::PathElement.new(kind: "User", id: 123456)
    grpc.properties["tags"] = Google::Cloud::Datastore::Convert.to_value ["ruby", "code"]

    entity_from_grpc = Google::Cloud::Datastore::Entity.from_grpc grpc
    entity_from_grpc.exclude_from_indexes?("tags").must_equal [false, false]
  end

  it "doesn't exclude from indexes by default" do
    refute entity.exclude_from_indexes?("name")
    refute entity.exclude_from_indexes?("email")

    grpc = entity.to_grpc

    grpc.properties["name"].exclude_from_indexes.must_equal false
    grpc.properties["email"].exclude_from_indexes.must_equal false
  end

  it "excludes when setting a boolean" do
    entity["age"] = 21
    entity.exclude_from_indexes! "age", true

    entity.exclude_from_indexes?("age").must_equal true

    grpc = entity.to_grpc

    grpc.properties["age"].exclude_from_indexes.must_equal true
  end

  it "excludes when setting a Proc" do
    entity["age"] = 21
    entity.exclude_from_indexes! "age" do |age|
      age > 18
    end

    entity.exclude_from_indexes?("age").must_equal true

    grpc = entity.to_grpc

    grpc.properties["age"].exclude_from_indexes.must_equal true

    # And now the inverse, the Proc evaluates to false

    entity.exclude_from_indexes! "age" do |age|
      age < 18
    end

    entity.exclude_from_indexes?("age").must_equal false

    grpc = entity.to_grpc

    grpc.properties["age"].exclude_from_indexes.must_equal false
  end

  it "excludes when setting an Array on a non array value" do
    entity["age"] = 21
    entity.exclude_from_indexes! "age", [true, false, true, false]

    entity.exclude_from_indexes?("age").must_equal true

    grpc = entity.to_grpc

    grpc.properties["age"].exclude_from_indexes.must_equal true

    # And now the inverse, the first value is false

    entity.exclude_from_indexes! "age", [false, true, false, true]

    entity.exclude_from_indexes?("age").must_equal false

    grpc = entity.to_grpc

    grpc.properties["age"].exclude_from_indexes.must_equal false
  end

  describe Array do
    it "doesn't exclude Array values from indexes by default" do
      entity["tags"] = ["ruby", "code"]

      entity.exclude_from_indexes?("tags").must_equal [false, false]

      grpc = entity.to_grpc

      tag_grpc = grpc.properties["tags"]
      tag_grpc.exclude_from_indexes.must_equal false
        tag_grpc.array_value.values.map(&:exclude_from_indexes).must_equal [false, false]
    end

    it "excludes an Array when setting a boolean" do
      entity["tags"] = ["ruby", "code"]
      entity.exclude_from_indexes! "tags", true

      entity.exclude_from_indexes?("tags").must_equal [true, true]

      grpc = entity.to_grpc

      tag_grpc = grpc.properties["tags"]
      tag_grpc.exclude_from_indexes.must_equal false
      tag_grpc.array_value.values.map(&:exclude_from_indexes).must_equal [true, true]
    end

    it "excludes an Array when setting a Proc" do
      entity["tags"] = ["ruby", "code"]
      entity.exclude_from_indexes! "tags" do |tag|
        tag =~ /r/
      end

      entity.exclude_from_indexes?("tags").must_equal [true, false]

      grpc = entity.to_grpc

      tag_grpc = grpc.properties["tags"]
      tag_grpc.exclude_from_indexes.must_equal false
      tag_grpc.array_value.values.map(&:exclude_from_indexes).must_equal [true, false]

      # And now the inverse, the Proc evaluates to false

      entity["tags"] = ["ruby", "code"]
      entity.exclude_from_indexes! "tags" do |tag|
        tag =~ /c/
      end

      entity.exclude_from_indexes?("tags").must_equal [false, true]

      grpc = entity.to_grpc

      tag_grpc = grpc.properties["tags"]
      tag_grpc.exclude_from_indexes.must_equal false
      tag_grpc.array_value.values.map(&:exclude_from_indexes).must_equal [false, true]
    end

    it "excludes an Array when setting an Array" do
      entity["tags"] = ["ruby", "code"]
      entity.exclude_from_indexes! "tags", [true, false]

      entity.exclude_from_indexes?("tags").must_equal [true, false]

      grpc = entity.to_grpc

      tag_grpc = grpc.properties["tags"]
      tag_grpc.exclude_from_indexes.must_equal false
      tag_grpc.array_value.values.map(&:exclude_from_indexes).must_equal [true, false]
    end

    it "excludes an Array when setting an Array that is too small" do
      entity["tags"] = ["ruby", "code", "google", "cloud"]
      entity.exclude_from_indexes! "tags", [true, false]

      # the default is to not exclude when the array is too small
      entity.exclude_from_indexes?("tags").must_equal [true, false, false, false]

      grpc = entity.to_grpc

      tag_grpc = grpc.properties["tags"]
      tag_grpc.exclude_from_indexes.must_equal false
      tag_grpc.array_value.values.map(&:exclude_from_indexes).must_equal [true, false, false, false]
    end

    it "excludes an Array when setting an Array that is too big" do
      entity["tags"] = ["ruby", "code"]
      entity.exclude_from_indexes! "tags", [true, false, true, false, true, false]

      entity.exclude_from_indexes?("tags").must_equal [true, false]

      grpc = entity.to_grpc

      tag_grpc = grpc.properties["tags"]
      tag_grpc.exclude_from_indexes.must_equal false
      tag_grpc.array_value.values.map(&:exclude_from_indexes).must_equal [true, false]

      # Now add to the entity and get the previously stored exclude values

      entity["tags"] = ["ruby", "code", "google", "cloud"]

      entity.exclude_from_indexes?("tags").must_equal [true, false, true, false]

      grpc = entity.to_grpc

      tag_grpc = grpc.properties["tags"]
      tag_grpc.exclude_from_indexes.must_equal false
      tag_grpc.array_value.values.map(&:exclude_from_indexes).must_equal [true, false, true, false]
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
