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
require "gcloud/datastore/key"

describe Gcloud::Datastore::Key do

  it "behaves correctly when empty" do
    key = Gcloud::Datastore::Key.new
    key.kind.must_be :nil?
    key.id.must_be :nil?
    key.name.must_be :nil?
    key.partition_id.must_be :nil?
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

  it "returns a correct protocol buffer object" do
    key = Gcloud::Datastore::Key.new "ThisThing", 1234
    proto = key.to_proto
    proto.path_element.count.must_equal 1
    proto.path_element.last.kind.must_equal "ThisThing"
    proto.path_element.last.id.must_equal 1234
    proto.path_element.last.name.must_be :nil?

    key = Gcloud::Datastore::Key.new "ThisThing", "charlie"
    proto = key.to_proto
    proto.path_element.count.must_equal 1
    proto.path_element.last.kind.must_equal "ThisThing"
    proto.path_element.last.id.must_be :nil?
    proto.path_element.last.name.must_equal "charlie"
  end

  it "can be created with a protocol buffer object" do
    proto = Gcloud::Datastore::Proto::Key.new
    proto.path_element = [Gcloud::Datastore::Proto::Key::PathElement.new]
    proto.path_element.first.kind = "AnotherThing"
    proto.path_element.first.id = 56789
    key = Gcloud::Datastore::Key.from_proto proto

    key.kind.must_equal "AnotherThing"
    key.id.must_equal 56789
    key.name.must_be :nil?
  end
end
