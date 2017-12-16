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

describe Google::Cloud::Datastore::Key, :mock_datastore do

  it "behaves correctly when empty" do
    key = Google::Cloud::Datastore::Key.new
    key.kind.must_be :nil?
    key.id.must_be :nil?
    key.name.must_be :nil?
    key.project.must_be :nil?
    key.namespace.must_be :nil?
  end

  it "creates instances with .new" do
    key = Google::Cloud::Datastore::Key.new "ThisThing", 1234
    key.kind.must_equal "ThisThing"
    key.id.must_equal 1234
    key.name.must_be :nil?

    key = Google::Cloud::Datastore::Key.new "ThisThing", "charlie"
    key.kind.must_equal "ThisThing"
    key.id.must_be :nil?
    key.name.must_equal "charlie"
  end

  it "can set a parent" do
    key = Google::Cloud::Datastore::Key.new "ThisThing", 1234
    key.kind.must_equal "ThisThing"
    key.id.must_equal 1234
    key.name.must_be :nil?

    key.parent.must_be :nil?
    key.parent = Google::Cloud::Datastore::Key.new "ThatThing", 6789
    key.parent.wont_be :nil?
    key.parent.kind.must_equal "ThatThing"
    key.parent.id.must_equal 6789
    key.parent.name.must_be :nil?
  end

  it "can set a project" do
    key = Google::Cloud::Datastore::Key.new "ThisThing", 1234
    key.kind.must_equal "ThisThing"
    key.id.must_equal 1234
    key.name.must_be :nil?

    key.project.must_be :nil?
    key.project = "custom-ds"
    key.project.wont_be :nil?
    key.project.must_equal "custom-ds"
  end

  it "can set a dataset_id as an alias of project" do
    key = Google::Cloud::Datastore::Key.new "ThisThing", 1234
    key.kind.must_equal "ThisThing"
    key.id.must_equal 1234
    key.name.must_be :nil?

    key.project.must_be :nil?
    key.dataset_id.must_be :nil?
    key.dataset_id = "custom-ds"
    key.dataset_id.wont_be :nil?
    key.project.wont_be :nil?
    key.dataset_id.must_equal "custom-ds"
    key.project.must_equal "custom-ds"
  end

  it "can set a namespace" do
    key = Google::Cloud::Datastore::Key.new "ThisThing", 1234
    key.kind.must_equal "ThisThing"
    key.id.must_equal 1234
    key.name.must_be :nil?

    key.namespace.must_be :nil?
    key.namespace = "custom-ns"
    key.namespace.wont_be :nil?
    key.namespace.must_equal "custom-ns"
  end

  describe "path" do
    it "returns kind and id" do
      key = Google::Cloud::Datastore::Key.new "Task", 123456
      key.path.must_equal [["Task", 123456]]
    end
    it "returns kind and name" do
      key = Google::Cloud::Datastore::Key.new "Task", "todos"
      key.path.must_equal [["Task", "todos"]]
    end
    it "returns parent when present" do
      key = Google::Cloud::Datastore::Key.new "Task", "todos"
      key.parent = Google::Cloud::Datastore::Key.new "User", "username"
      key.path.must_equal [["User", "username"], ["Task", "todos"]]
    end
    it "returns all parents using references" do
      key = Google::Cloud::Datastore::Key.new "Task", "todos"
      key.parent = Google::Cloud::Datastore::Key.new "User", "username"
      key.parent.parent = Google::Cloud::Datastore::Key.new "Org", "company"
      key.path.must_equal [["Org", "company"], ["User", "username"], ["Task", "todos"]]
    end
  end

  it "knows if it is complete or not" do
    key = Google::Cloud::Datastore::Key.new "Task"
    key.id.must_be :nil?
    key.name.must_be :nil?
    key.wont_be :complete?
    key.must_be :incomplete?

    key.id = 123455
    key.id.wont_be :nil?
    key.name.must_be :nil?
    key.must_be :complete?
    key.wont_be :incomplete?

    key.name = "description"
    key.id.must_be :nil?
    key.name.wont_be :nil?
    key.must_be :complete?
    key.wont_be :incomplete?
  end

  it "isn't complete is missing kind" do
    key = Google::Cloud::Datastore::Key.new "Task"
    key.kind = nil
    key.kind.must_be :nil?
    key.id.must_be :nil?
    key.name.must_be :nil?
    key.wont_be :complete?
    key.must_be :incomplete?

    key.id = 123455
    key.kind.must_be :nil?
    key.id.wont_be :nil?
    key.name.must_be :nil?
    key.wont_be :complete?
    key.must_be :incomplete?

    key.name = "description"
    key.kind.must_be :nil?
    key.id.must_be :nil?
    key.name.wont_be :nil?
    key.wont_be :complete?
    key.must_be :incomplete?
  end

  it "returns a correct GRPC object" do
    key = Google::Cloud::Datastore::Key.new "ThisThing", 1234
    grpc = key.to_grpc
    grpc.path.count.must_equal 1
    grpc.path.last.kind.must_equal "ThisThing"
    grpc.path.last.id_type.must_equal :id
    grpc.path.last.id.must_equal 1234
    grpc.partition_id.must_be :nil?

    key = Google::Cloud::Datastore::Key.new "ThisThing", "charlie"
    key.parent = Google::Cloud::Datastore::Key.new "ThatThing", "henry"
    key.project = "custom-ds"
    key.namespace = "custom-ns"
    grpc = key.to_grpc
    grpc.path.count.must_equal 2
    grpc.path.first.kind.must_equal "ThatThing"
    grpc.path.first.id_type.must_equal :name
    grpc.path.first.name.must_equal "henry"
    grpc.path.last.kind.must_equal "ThisThing"
    grpc.path.last.id_type.must_equal :name
    grpc.path.last.name.must_equal "charlie"
    grpc.partition_id.project_id.must_equal "custom-ds"
    grpc.partition_id.namespace_id.must_equal "custom-ns"
  end

  it "can be created with a GRPC object" do
    grpc = Google::Datastore::V1::Key.new
    grpc.path << Google::Datastore::V1::Key::PathElement.new(
      kind: "AnotherThing", id: 56789
    )
    grpc.partition_id = Google::Datastore::V1::PartitionId.new(
      project_id: "custom-ds", namespace_id: "custom-ns"
    )
    key = Google::Cloud::Datastore::Key.from_grpc grpc

    key.wont_be :nil?
    key.kind.must_equal "AnotherThing"
    key.id.must_equal 56789
    key.name.must_be :nil?
    key.project.must_equal "custom-ds"
    key.namespace.must_equal "custom-ns"
    key.must_be :frozen?
  end

  it "returns nil when the GRPC object is nil" do
    # This is important because embedded entities don't have a key
    grpc = nil
    key = Google::Cloud::Datastore::Key.from_grpc grpc

    key.must_be :nil?
  end

  it "knows its serialized side" do
    # Don't care about the exact value, just want a number and no error
    key = Google::Cloud::Datastore::Key.new "ThisThing", 1234
    key.serialized_size.must_be_kind_of Integer
  end
end
