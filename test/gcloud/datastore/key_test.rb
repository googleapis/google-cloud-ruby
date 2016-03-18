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

describe Gcloud::Datastore::Key do

  it "behaves correctly when empty" do
    key = Gcloud::Datastore::Key.new
    key.kind.must_be :nil?
    key.id.must_be :nil?
    key.name.must_be :nil?
    key.dataset_id.must_be :nil?
    key.namespace.must_be :nil?
  end

  it "creates instances with .new" do
    key = Gcloud::Datastore::Key.new "ThisThing", 1234
    key.kind.must_equal "ThisThing"
    key.id.must_equal 1234
    key.name.must_be :nil?

    key = Gcloud::Datastore::Key.new "ThisThing", "charlie"
    key.kind.must_equal "ThisThing"
    key.id.must_be :nil?
    key.name.must_equal "charlie"
  end

  it "can set a parent" do
    key = Gcloud::Datastore::Key.new "ThisThing", 1234
    key.kind.must_equal "ThisThing"
    key.id.must_equal 1234
    key.name.must_be :nil?

    key.parent.must_be :nil?
    key.parent = Gcloud::Datastore::Key.new "ThatThing", 6789
    key.parent.wont_be :nil?
    key.parent.kind.must_equal "ThatThing"
    key.parent.id.must_equal 6789
    key.parent.name.must_be :nil?
  end

  it "can set a dataset_id" do
    key = Gcloud::Datastore::Key.new "ThisThing", 1234
    key.kind.must_equal "ThisThing"
    key.id.must_equal 1234
    key.name.must_be :nil?

    key.dataset_id.must_be :nil?
    key.dataset_id = "custom-ds"
    key.dataset_id.wont_be :nil?
    key.dataset_id.must_equal "custom-ds"
  end

  it "can set a namespace" do
    key = Gcloud::Datastore::Key.new "ThisThing", 1234
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
      key = Gcloud::Datastore::Key.new "Task", 123456
      key.path.must_equal [["Task", 123456]]
    end
    it "returns kind and name" do
      key = Gcloud::Datastore::Key.new "Task", "todos"
      key.path.must_equal [["Task", "todos"]]
    end
    it "returns parent when present" do
      key = Gcloud::Datastore::Key.new "Task", "todos"
      key.parent = Gcloud::Datastore::Key.new "User", "username"
      key.path.must_equal [["User", "username"], ["Task", "todos"]]
    end
    it "returns all parents when present" do
      key = Gcloud::Datastore::Key.new "Task", "todos"
      key.parent = Gcloud::Datastore::Key.new "User", "username"
      key.parent.parent = Gcloud::Datastore::Key.new "Org", "company"
      key.path.must_equal [["Org", "company"], ["User", "username"], ["Task", "todos"]]
    end
  end

  it "knows if it is complete or not" do
    key = Gcloud::Datastore::Key.new "Task"
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
    key = Gcloud::Datastore::Key.new "Task"
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

  it "returns a correct protocol buffer object" do
    key = Gcloud::Datastore::Key.new "ThisThing", 1234
    proto = key.to_proto
    proto.path_element.count.must_equal 1
    proto.path_element.last.kind.must_equal "ThisThing"
    proto.path_element.last.id.must_equal 1234
    proto.path_element.last.name.must_be :nil?
    proto.partition_id.dataset_id.must_be :nil?
    proto.partition_id.namespace.must_be :nil?

    key = Gcloud::Datastore::Key.new "ThisThing", "charlie"
    key.parent = Gcloud::Datastore::Key.new "ThatThing", "henry"
    key.dataset_id = "custom-ds"
    key.namespace = "custom-ns"
    proto = key.to_proto
    proto.path_element.count.must_equal 2
    proto.path_element.first.kind.must_equal "ThatThing"
    proto.path_element.first.id.must_be :nil?
    proto.path_element.first.name.must_equal "henry"
    proto.path_element.last.kind.must_equal "ThisThing"
    proto.path_element.last.id.must_be :nil?
    proto.path_element.last.name.must_equal "charlie"
    proto.partition_id.dataset_id.must_equal "custom-ds"
    proto.partition_id.namespace.must_equal "custom-ns"
  end

  it "can be created with a protocol buffer object" do
    proto = Gcloud::Datastore::Proto::Key.new
    proto.path_element = [Gcloud::Datastore::Proto::Key::PathElement.new]
    proto.path_element.first.kind = "AnotherThing"
    proto.path_element.first.id = 56789
    proto.partition_id = Gcloud::Datastore::Proto::PartitionId.new
    proto.partition_id.dataset_id = "custom-ds"
    proto.partition_id.namespace = "custom-ns"
    key = Gcloud::Datastore::Key.from_proto proto

    key.wont_be :nil?
    key.kind.must_equal "AnotherThing"
    key.id.must_equal 56789
    key.name.must_be :nil?
    key.dataset_id.must_equal "custom-ds"
    key.namespace.must_equal "custom-ns"
    key.must_be :frozen?
  end

  it "returns a correct GRPC object" do
    key = Gcloud::Datastore::Key.new "ThisThing", 1234
    grpc = key.to_grpc
    grpc.path.count.must_equal 1
    grpc.path.last.kind.must_equal "ThisThing"
    grpc.path.last.id.must_equal 1234
    grpc.path.last.name.must_be :nil?
    grpc.partition_id.must_be :nil?

    key = Gcloud::Datastore::Key.new "ThisThing", "charlie"
    key.parent = Gcloud::Datastore::Key.new "ThatThing", "henry"
    key.dataset_id = "custom-ds"
    key.namespace = "custom-ns"
    grpc = key.to_grpc
    grpc.path.count.must_equal 2
    grpc.path.first.kind.must_equal "ThatThing"
    grpc.path.first.id.must_be :nil?
    grpc.path.first.name.must_equal "henry"
    grpc.path.last.kind.must_equal "ThisThing"
    grpc.path.last.id.must_be :nil?
    grpc.path.last.name.must_equal "charlie"
    grpc.partition_id.project_id.must_equal "custom-ds"
    grpc.partition_id.namespace_id.must_equal "custom-ns"
  end

  it "can be created with a GRPC object" do
    grpc = Google::Datastore::V1beta3::Key.new
    grpc.path << Google::Datastore::V1beta3::Key::PathElement.new(
      kind: "AnotherThing", id: 56789
    )
    grpc.partition_id = Google::Datastore::V1beta3::PartitionId.new(
      project_id: "custom-ds", namespace_id: "custom-ns"
    )
    key = Gcloud::Datastore::Key.from_grpc grpc

    key.wont_be :nil?
    key.kind.must_equal "AnotherThing"
    key.id.must_equal 56789
    key.name.must_be :nil?
    key.dataset_id.must_equal "custom-ds"
    key.namespace.must_equal "custom-ns"
    key.must_be :frozen?
  end
end
