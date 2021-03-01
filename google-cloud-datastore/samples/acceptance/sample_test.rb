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
require_relative "../sample"

describe "Datastore sample", :datastore do
  let(:datastore) { Google::Cloud::Datastore.new }
  let(:user_name) { "test_user_#{time_plus_random}" }
  let(:task_list_name) { "test_task_list_#{time_plus_random}" }
  let(:task_list_key) { datastore.key "TaskList", task_list_name }
  let(:task_list) { find_or_save_task_list task_list_key }
  let(:task_name) { "test_task_#{time_plus_random}" }
  let(:task_name_1) { "#{task_name}_1" }
  let(:task_name_2) { "#{task_name}_2" }
  let(:list_task_name) { "#{task_name}_in_list" }
  let(:sample_task) { find_or_save_task datastore.key("Task", task_name) }
  let(:sample_task_1) { find_or_save_task datastore.key("Task", task_name_1) }
  let(:sample_task_2) { find_or_save_task datastore.key("Task", task_name_2) }
  let :list_task do
    task_key = datastore.key "Task", list_task_name
    task_key.parent = task_list.key
    find_or_save_task task_key
  end

  before :all do
    sample_task
    sample_task_1
    sample_task_2
    list_task
    sleep 5
  end

  after :all do
    datastore.delete(
      [
        datastore.key("Task", task_name),
        datastore.key("Task", task_name_1),
        datastore.key("Task", task_name_2),
        datastore.key("TaskList", list_task_name)
      ]
    )
  end

  Minitest.after_run do
    datastore = Google::Cloud::Datastore.new
    tasks = datastore.run datastore.query("Task")
    datastore.delete(*tasks.map(&:key)) unless tasks.empty?
    task_lists = datastore.run datastore.query("TaskList")
    datastore.delete(*task_lists.map(&:key)) unless task_lists.empty?
    accounts = datastore.run datastore.query("Account")
    datastore.delete(*accounts.map(&:key)) unless accounts.empty?
  end

  it "supports incomplete_key" do
    task_key = incomplete_key

    assert_equal "Task", task_key.kind
    refute task_key.name
  end

  it "supports named_key" do
    task_key = named_key task_name: sample_task.key.name

    assert_equal "Task", task_key.kind
    assert_equal task_name, task_key.name
  end

  it "supports key_with_parent" do
    task_key = key_with_parent task_list_name: list_task.key.parent.name, task_name: sample_task.key.name

    assert_equal "Task", task_key.kind
    assert_equal task_name, task_key.name
    assert_equal [["TaskList", task_list_name], ["Task", task_name]], task_key.path
  end

  it "supports key_with_multilevel_parent" do
    task_key = key_with_multilevel_parent user_name:      user_name,
                                          task_list_name: list_task.key.parent.name,
                                          task_name:      sample_task.key.name

    assert_equal "Task", task_key.kind
    assert_equal task_name, task_key.name
    assert_equal [["User", user_name], ["TaskList", task_list_name], ["Task", task_name]], task_key.path
  end

  it "supports entity_with_parent" do
    task = entity_with_parent task_list_name: list_task.key.parent.name, task_name: sample_task.key.name

    assert_equal task_name, task.key.name
    assert_equal [["TaskList", task_list_name], ["Task", task_name]], task.key.path
    refute task.persisted?
    assert_basic_task task
  end

  it "supports properties" do
    time_now = Time.now
    Time.stub :now, time_now do
      task = properties

      refute task.persisted?
      assert_equal 6, task.properties.to_h.size
      assert_basic_task task
      assert_equal time_now, task["created"]
      assert_equal 4, task["priority"]
      assert_equal 10.0, task["percent_complete"]
      assert_equal "Learn Cloud Datastore", task["description"]
    end
  end

  it "supports array_value" do
    task = array_value task_name: sample_task.key.name

    assert_equal 2, task.properties.to_h.size
    assert_equal ["fun", "programming"], task["tags"]
    assert_equal ["alice", "bob"], task["collaborators"]
  end

  it "supports basic_entity" do
    task = basic_entity

    refute task.persisted?
    assert_basic_task task
  end

  it "supports upsert" do
    task = upsert task_name: sample_task.key.name

    assert task.key.id.nil?
    assert_equal task_name, task.key.name
    assert task.persisted?
    assert_basic_task task
  end

  it "supports insert" do
    task = insert

    refute task.key.id.nil?
    assert task.key.name.nil?
    assert task.persisted?
    assert_basic_task task
  end

  it "supports update" do
    task = update task_name: sample_task.key.name

    assert task.persisted?
    assert_equal 4, task.properties.to_h.size
    assert_equal "Personal", task["category"]
    refute task["done"]
    assert_equal 5, task["priority"]
    assert_equal "Learn Cloud Datastore", task["description"]
  end

  it "supports delete" do
    task_key = delete task_name: sample_task.key.name

    assert_equal task_name, task_key.name
    task = datastore.find task_key
    assert task.nil?
  end

  it "supports batch_upsert" do
    task_key1, task_key2 = batch_upsert

    refute task_key1.id.nil?
    assert task_key1.frozen?
    refute task_key2.id.nil?
    assert task_key2.frozen?
  end

  it "supports batch_delete" do
    task_key1, task_key2 = batch_delete task_name_1: sample_task_1.key.name, task_name_2: sample_task_2.key.name

    assert_equal task_name_1, task_key1.name
    assert_equal task_name_2, task_key2.name
    tasks = datastore.find_all task_key1, task_key2
    assert tasks.empty?
  end

  it "supports exploding_properties" do
    time_now = Time.now
    Time.stub :now, time_now do
      task = exploding_properties

      assert_equal ["fun", "programming", "learn"], task["tags"]
      assert_equal ["alice", "bob", "charlie"], task["collaborators"]
      assert_equal time_now, task["created"]
    end
  end

  it "supports transactional_update" do
    from_account = datastore.entity "Account" do |a|
      a["balance"] = 20.0
    end
    to_account = datastore.entity "Account" do |a|
      a["balance"] = 20.0
    end
    datastore.save from_account, to_account
    amount = 10.0

    success = transfer_funds from_account.key, to_account.key, amount

    assert success
    from_account = datastore.find from_account.key
    to_account = datastore.find to_account.key
    assert_equal 30.0, to_account["balance"]
    assert_equal 10.0, from_account["balance"]
  end

  it "supports transactional_retry" do
    from_account = datastore.entity "Account" do |a|
      a["balance"] = 20.0
    end
    to_account = datastore.entity "Account" do |a|
      a["balance"] = 20.0
    end
    datastore.save from_account, to_account
    amount = 10.0

    success = transactional_retry from_account.key, to_account.key, amount

    assert success
  end

  it "supports transactional_get_or_create" do
    task_key = datastore.key "Task", task_name

    task = transactional_get_or_create task_key

    assert task.key.id.nil?
    assert_equal task_name, task.key.name
    assert task.persisted?
    assert_basic_task task
  end

  def assert_basic_task task
    assert_equal "Task", task.key.kind
    assert_equal "Personal", task["category"]
    assert_equal false, task["done"]
  end
end
