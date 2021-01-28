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
require_relative "../quickstart.rb"

describe "Datastore Quickstart", :datastore do
  let(:datastore) { Google::Cloud::Datastore.new }
  let(:task_name) { "test_task_#{time_plus_random}" }
  let(:task_key) { datastore.key "Task", task_name }

  before do
    task = datastore.find task_key
    datastore.delete task if task

    refute datastore.find(task_key)
  end

  it "creates a new entity" do
    assert_output "Saved #{task_name}: Buy milk\n" do
      quickstart task_name: task_name
    end

    task = datastore.find task_key
    assert task
    assert_equal "Buy milk", task["description"]
  end
end
