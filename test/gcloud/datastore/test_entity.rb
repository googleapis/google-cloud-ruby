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

describe Gcloud::Datastore::Entity do

  let(:entity) do
    Gcloud::Datastore::Entity.new.tap do |entity|
      entity.key = Gcloud::Datastore::Key.new "User", "username"
      entity["name"] = "User McUser"
      entity["email"] = "user@example.net"
    end
  end

  it "creates instances with .new" do
    # Calling entity here creates by calling new
    entity.wont_be :nil?
    entity.properties.must_include ["name", "User McUser"]
    entity.properties.must_include ["email", "user@example.net"]
  end

  it "returns a correct protocol buffer object" do
    proto = entity.to_proto

    # Key values
    proto.key.path_element.count.must_equal 1
    proto.key.path_element.last.kind.must_equal "User"
    proto.key.path_element.last.id.must_be :nil?
    proto.key.path_element.last.name.must_equal "username"

    # Property values
    proto.property.count.must_equal 2
    proto.property.find { |p| p.name == "name" }.value.string_value.must_equal entity["name"]
    proto.property.find { |p| p.name == "email" }.value.string_value.must_equal entity["email"]
  end

  it "can be created with a protocol buffer object" do
    proto = Gcloud::Datastore::Proto::Entity.new
    proto.key = Gcloud::Datastore::Proto::Key.new
    proto.key.path_element = [Gcloud::Datastore::Proto::Key::PathElement.new]
    proto.key.path_element.first.kind = "User"
    proto.key.path_element.first.id = 123456
    proto.property = [Gcloud::Datastore::Proto::Property.new,
                      Gcloud::Datastore::Proto::Property.new]
    proto.property.first.name = "name"
    proto.property.first.value = Gcloud::Datastore::Proto.to_proto_value "User McNumber"
    proto.property.last.name = "email"
    proto.property.last.value = Gcloud::Datastore::Proto.to_proto_value "number@example.net"

    entity_from_proto = Gcloud::Datastore::Entity.from_proto proto

    entity_from_proto.key.kind.must_equal "User"
    entity_from_proto.key.id.must_equal 123456
    entity_from_proto.key.name.must_be :nil?
    entity_from_proto.properties.must_include ["name", "User McNumber"]
    entity_from_proto.properties.must_include ["email", "number@example.net"]
  end
end
