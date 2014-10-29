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

require "datastore_helper"

describe "Datastore CRUD", :datastore do
  it "creates, reads, updates, and deletes" do
    entity = Gcloud::Datastore::Entity.new
    entity.key = Gcloud::Datastore::Key.new "Task CRUD #{Time.now}"
    entity["description"] = "Get started with Devserver"
    entity["completed"] = false

    entity.key.id.must_be :nil?
    connection.save entity
    entity.key.id.wont_be :nil?

    refresh = connection.find entity.key.kind, entity.key.id
    refresh.wont_be :nil?
    refute entity["completed"]

    entity["completed"] = true
    connection.save entity

    refresh = connection.find entity.key.kind, entity.key.id
    refresh.wont_be :nil?
    assert entity["completed"]

    connection.delete entity

    refresh = connection.find entity.key.kind, entity.key.id
    refresh.must_be :nil?
  end
end
