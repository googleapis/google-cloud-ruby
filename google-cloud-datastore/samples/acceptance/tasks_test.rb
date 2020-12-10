# Copyright 2020 Google LLC
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

require_relative "helper"
require_relative "../tasks"

describe "Datastore task list" do
  let(:datastore) { Google::Cloud::Datastore.new }

  before do
    delete_tasks
  end

  def delete_tasks
    tasks = datastore.run datastore.query("Task")
    datastore.delete(*tasks.map(&:key)) unless tasks.empty?
  end

  it "creates a task" do
    desc = "Test description."
    id = nil
    capture_io do
      id = add_task desc
    end
    task = datastore.find "Task", id
    assert task
    assert_equal desc, task["description"]
  end

  it "marks done" do
    task = datastore.entity "Task" do |t|
      t["done"] = false
    end
    datastore.save task
    id = task.key.id
    wait_until { datastore.find "Task", id }

    mark_done id
    task = datastore.find "Task", id
    assert_equal true, task["done"]
  end

  it "list_tasks" do
    task1 = task_entity "Task"
    task2 = task_entity "Task"
    datastore.save task1, task2

    query = datastore.query("Task").order "created"
    wait_until { datastore.run(query).any? }

    assert_output(/ID:/) do
      list_tasks
    end
  end

  it "deletes tasks" do
    task = datastore.entity "Task" do |t|
      t["description"] = "Test 1."
      t["created"]     = Time.now
      t["done"]        = false
      t.exclude_from_indexes! "description", true
    end
    datastore.save task
    id = task.key.id
    wait_until { datastore.find "Task", id }

    delete_task id
    task = datastore.find "Task", id
    refute task
  end
end
