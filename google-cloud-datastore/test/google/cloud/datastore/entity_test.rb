# Copyright 2014 Google LLC
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

describe Google::Cloud::Datastore::Entity, :mock_datastore do

  let(:entity) do
    Google::Cloud::Datastore::Entity.new.tap do |ent|
      ent.key = Google::Cloud::Datastore::Key.new "User", "username"
      ent["name"] = "User McUser"
      ent["email"] = "user@example.net"
    end
  end

  it "creates instances with .new" do
    # Calling entity here creates by calling new
    entity.wont_be :nil?
    entity.properties["name"].must_equal "User McUser"
    entity.properties["email"].must_equal "user@example.net"
  end

  it "allows properties to be accessed by strings or symbols" do
    # Calling entity here creates by calling new
    entity.wont_be :nil?
    entity.properties["name"].must_equal "User McUser"
    entity.properties["email"].must_equal "user@example.net"

    entity.properties[:name].must_equal "User McUser"
    entity.properties[:email].must_equal "user@example.net"

    entity[:age] = 29
    entity.properties[:age].must_equal 29
    entity.properties["age"].must_equal 29
  end

  it "returns a correct GRPC object" do
    grpc = entity.to_grpc

    # Key values
    grpc.key.path.count.must_equal 1
    grpc.key.path.last.kind.must_equal "User"
    grpc.key.path.last.id_type.must_equal :name
    grpc.key.path.last.name.must_equal "username"

    # Property values
    grpc.properties.count.must_equal 2
    grpc.properties["name"].string_value.must_equal entity["name"]
    grpc.properties["email"].string_value.must_equal entity["email"]
  end

  it "returns a correct GRPC object when key is nil" do
    # This is important because embedded entities don't have a key
    entity.key = nil
    grpc = entity.to_grpc

    # Key values
    grpc.key.must_be :nil?

    # Property values
    grpc.properties.count.must_equal 2
    grpc.properties["name"].string_value.must_equal entity["name"]
    grpc.properties["email"].string_value.must_equal entity["email"]
  end

  it "can be created with a GRPC object" do
    grpc = Google::Datastore::V1::Entity.new
    grpc.key = Google::Datastore::V1::Key.new
    grpc.key.path << Google::Datastore::V1::Key::PathElement.new
    grpc.key.path.first.kind = "User"
    grpc.key.path.first.id = 123456
    grpc.properties["name"] = Google::Cloud::Datastore::Convert.to_value "User McNumber"
    grpc.properties["email"] = Google::Cloud::Datastore::Convert.to_value "number@example.net"
    grpc.properties["avatar"] = Google::Cloud::Datastore::Convert.to_value nil

    entity_from_grpc = Google::Cloud::Datastore::Entity.from_grpc grpc

    entity_from_grpc.key.kind.must_equal "User"
    entity_from_grpc.key.id.must_equal 123456
    entity_from_grpc.key.name.must_be :nil?
    entity_from_grpc.properties["name"].must_equal "User McNumber"
    entity_from_grpc.properties["email"].must_equal "number@example.net"
    entity_from_grpc.properties.exist?("avatar").must_equal true
    entity_from_grpc.properties["avatar"].must_be :nil?
  end

  it "can store other entities as properties" do
    task1 = Google::Cloud::Datastore::Entity.new.tap do |t|
      t.key = Google::Cloud::Datastore::Key.new "Task", 1111
      t["description"] = "can persist entities"
      t["completed"] = true
    end
    task2 = Google::Cloud::Datastore::Entity.new.tap do |t|
      t.key = Google::Cloud::Datastore::Key.new "Task", 2222
      t["description"] = "can persist lists"
      t["completed"] = true
    end
    entity["tasks"] = [task1, task2]

    grpc = entity.to_grpc

    task_property = grpc.properties["tasks"]
    task_property.array_value.values.wont_be :empty?
    task_property.array_value.values.count.must_equal 2
    grpc_task_1 = task_property.array_value.values.first
    grpc_task_2 = task_property.array_value.values.last
    grpc_task_1.wont_be :nil?
    grpc_task_2.wont_be :nil?
    grpc_task_1.entity_value.wont_be :nil?
    grpc_task_2.entity_value.wont_be :nil?
    grpc_task_1.entity_value.properties["description"].string_value.must_equal "can persist entities"
    grpc_task_2.entity_value.properties["description"].string_value.must_equal "can persist lists"
  end

  it "can store keys as properties" do
    list = Google::Cloud::Datastore::Entity.new.tap do |t|
      t.key = Google::Cloud::Datastore::Key.new "List", 1111
      t["description"] = "can persist keys"
    end
    key1 = Google::Cloud::Datastore::Key.new "Task", 1111

    list["head"] = key1

    # Do this multiple times to make sure the call to Key.from_grpc
    # isn't modifying the original key stored in the entity's property.
    5.times do
      assert_equal key1.path, list["head"].path
    end

    grpc = list.to_grpc

    key_property = grpc.properties["head"]

    key_value = key_property.key_value
    key_value.wont_be :nil?
    key_value.must_equal                    key1.to_grpc
    key_value.path.first.kind.must_equal    key1.to_grpc.path.last.kind
    key_value.path.first.id_type.must_equal key1.to_grpc.path.last.id_type
    key_value.path.first.name.must_equal    key1.to_grpc.path.last.name
    key_value.path.first.id.must_equal      key1.to_grpc.path.last.id
  end

  it "raises when setting an unsupported property type" do
    error = assert_raises Google::Cloud::Datastore::PropertyError do
      entity["thing"] = OpenStruct.new
    end
    error.message.must_equal "A property of type OpenStruct is not supported."
  end

  it "raises when setting a key when persisted" do
    grpc = Google::Datastore::V1::Entity.new
    grpc.key = Google::Datastore::V1::Key.new
    grpc.key.path << Google::Datastore::V1::Key::PathElement.new(kind: "User", id: 123456)
    grpc.properties["name"] = Google::Cloud::Datastore::Convert.to_value "User McNumber"
    grpc.properties["email"] = Google::Cloud::Datastore::Convert.to_value "number@example.net"

    entity_from_grpc = Google::Cloud::Datastore::Entity.from_grpc grpc

    entity_from_grpc.must_be :persisted?
    entity_from_grpc.key.must_be :frozen?

    assert_raises RuntimeError do
      entity_from_grpc.key = Google::Cloud::Datastore::Key.new "User", 456789
    end

    assert_raises RuntimeError do
      entity_from_grpc.key.id = 456789
    end
  end

  it "knows its serialized side" do
    # Don't care about the exact value, just want a number and no error
    entity.serialized_size.must_be_kind_of Integer
  end
end
