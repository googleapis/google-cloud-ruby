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

describe "Datastore sample" do
  let(:datastore) { Google::Cloud::Datastore.new }
  let(:user_name) { "test_user_#{time_plus_random}" }
  let(:task_list_name) { "test_task_list_#{time_plus_random}" }
  let(:task_list_key) { datastore.key "TaskList", task_list_name }
  let :task_list do
    tl = datastore.find task_list_key
    if tl.nil?
      tl = datastore.entity task_list_key
      datastore.save tl
    end
    tl
  end
  let(:task_name) { "test_task_#{time_plus_random}" }
  let(:task_name_1) { "#{task_name}_1" }
  let(:task_name_2) { "test_task_#{task_name}_2" }
  let(:sample_task) { find_or_save_task datastore.key("Task", task_name) }
  let(:sample_task_1) { find_or_save_task datastore.key("Task", task_name_1) }
  let(:sample_task_2) { find_or_save_task datastore.key("Task", task_name_2) }
  let :list_task do
    task_key = datastore.key "Task", "listTask"
    task_key.parent = task_list.key
    find_or_save_task task_key
  end

  before do
    sample_task
    sample_task_1
    sample_task_2
    list_task
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
    task_key = named_key task_name: task_name

    assert_equal "Task", task_key.kind
    assert_equal task_name, task_key.name
  end

  it "supports key_with_parent" do
    task_key = key_with_parent task_list_name: task_list_name, task_name: task_name

    assert_equal "Task", task_key.kind
    assert_equal task_name, task_key.name
    assert_equal [["TaskList", task_list_name], ["Task", task_name]], task_key.path
  end

  it "supports key_with_multilevel_parent" do
    task_key = key_with_multilevel_parent user_name: user_name, task_list_name: task_list_name, task_name: task_name

    assert_equal "Task", task_key.kind
    assert_equal task_name, task_key.name
    assert_equal [["User", user_name], ["TaskList", task_list_name], ["Task", task_name]], task_key.path
  end

  it "supports entity_with_parent" do
    task = entity_with_parent task_list_name: task_list_name, task_name: task_name

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
    task = array_value task_name: task_name

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
    task = upsert task_name: task_name

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

  it "supports lookup" do
    task = lookup task_name: task_name

    assert task.key.id.nil?
    assert_equal task_name, task.key.name
    assert task.persisted?
    assert_basic_task task
  end

  it "supports update" do
    task = update task_name: task_name

    assert task.persisted?
    assert_equal 4, task.properties.to_h.size
    assert_equal "Personal", task["category"]
    refute task["done"]
    assert_equal 5, task["priority"]
    assert_equal "Learn Cloud Datastore", task["description"]
  end

  it "supports delete" do
    task_key = delete task_name: task_name

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

  it "supports batch_lookup" do
    tasks = batch_lookup task_name_1: task_name_1, task_name_2: task_name_2

    assert_equal 2, tasks.size
    assert_basic_task tasks.first
  end

  it "supports batch_delete" do
    task_key1, task_key2 = batch_delete task_name_1: task_name_1, task_name_2: task_name_2

    assert_equal task_name_1, task_key1.name
    assert_equal task_name_2, task_key2.name
    tasks = datastore.find_all task_key1, task_key2
    assert tasks.empty?
  end

  it "supports basic_query run_query" do
    tasks = basic_query

    refute tasks.empty?
    tasks.each { |t| assert_basic_task t }
  end

  it "supports property_filter" do
    query = property_filter
    tasks = datastore.run query

    refute tasks.empty?
    tasks.each do |t|
      assert_equal false, t["done"]
    end
  end

  it "supports composite_filter" do
    query = composite_filter
    tasks = datastore.run query

    refute tasks.empty?
    tasks.each { |t| assert_basic_task t }
  end

  it "supports key_filter" do
    query = key_filter
    tasks = datastore.run query

    refute tasks.empty?
    tasks.each { |t| assert_basic_task t }
  end

  it "supports ascending_sort" do
    query = ascending_sort
    tasks = datastore.run query

    refute tasks.empty?
    last_val = nil
    tasks.each do |t|
      assert_operator t["created"], :>=, last_val if last_val
      last_val = t["created"]
    end
  end

  it "supports descending_sort" do
    query = descending_sort
    tasks = datastore.run query

    refute tasks.empty?
    last_val = nil
    tasks.each do |t|
      assert_operator t["created"], :<=, last_val if last_val
      last_val = t["created"]
    end
  end

  it "supports multi_sort" do
    query = multi_sort
    tasks = datastore.run query

    refute tasks.empty?
    tasks.each { |t| assert_basic_task t }
  end

  it "supports kindless_query" do
    query = kindless_query
    entities = datastore.run query

    refute entities.empty?
  end

  it "supports ancestor_query" do
    query = ancestor_query task_list_name: task_list_name
    tasks = datastore.run query

    refute tasks.empty?
    assert_equal "Task", tasks.first.key.kind
    assert_equal "TaskList", tasks.first.key.parent.kind
  end

  it "supports projection_query run_query_projection" do
    priorities, percent_completes = projection_query

    refute priorities.empty?
    assert_equal 4, priorities.first
    refute percent_completes.empty?
    assert_equal 10.0, percent_completes.first
  end

  it "supports keys_only_query" do
    keys = keys_only_query

    refute keys.empty?
    assert_equal "Task", keys.first.kind
  end

  it "supports distinct_on_query" do
    query = distinct_on_query
    tasks = datastore.run query

    refute tasks.empty?
    assert_equal "Task", tasks.first.key.kind
    assert_equal "Personal", tasks.first["category"]
    assert_equal 4, tasks.first["priority"]
    assert_equal 2, tasks.first.properties.to_h.size
  end

  it "supports array_value_inequality_range" do
    query = array_value_inequality_range
    tasks = datastore.run query

    assert tasks.empty?
  end

  it "supports array_value_equality" do
    query = array_value_equality
    tasks = datastore.run query

    refute tasks.empty?
    assert_equal ["fun", "programming"], tasks.first["tag"]
  end

  it "supports inequality_range" do
    query = inequality_range
    tasks = datastore.run query

    refute tasks.empty?
    assert_operator tasks.first["created"], :>=, Time.utc(1990, 1, 1)
    assert_operator tasks.first["created"], :<, Time.utc(2000, 1, 1)
  end

  it "throws when inequality_invalid" do
    query = inequality_invalid

    assert_raises Google::Cloud::InvalidArgumentError do
      datastore.run query
    end
  end

  it "supports equal_and_inequality_range" do
    query = equal_and_inequality_range
    tasks = datastore.run query

    refute tasks.empty?
    assert_equal false, tasks.first["done"]
    assert_equal 4, tasks.first["priority"]
    assert_operator tasks.first["created"], :>=, Time.utc(1990, 1, 1)
    assert_operator tasks.first["created"], :<, Time.utc(2000, 1, 1)
  end

  it "supports inequality_sort" do
    query = inequality_sort
    tasks = datastore.run query

    refute tasks.empty?
    tasks.each { |t| assert_basic_task t }
  end

  it "supports inequality_sort_invalid_not_same" do
    query = inequality_sort_invalid_not_same

    assert_raises Google::Cloud::InvalidArgumentError do
      datastore.run query
    end
  end

  it "supports inequality_sort_invalid_not_first" do
    query = inequality_sort_invalid_not_first

    assert_raises Google::Cloud::InvalidArgumentError do
      datastore.run query
    end
  end

  it "supports limit" do
    query = limit
    tasks = datastore.run query

    refute tasks.empty?
    assert_operator tasks.size, :<=, 5
  end

  it "supports cursor_paging" do
    query = cursor_paging
    tasks = datastore.run query

    refute tasks.empty?
    refute tasks.cursor.nil?
    assert_equal 2, tasks.size
  end

  it "supports eventual_consistent_query" do
    tasks = eventual_consistent_query task_list_name: task_list_name

    refute tasks.empty?
    assert_equal "Task", tasks.first.key.kind
    assert_equal "TaskList", tasks.first.key.parent.kind
  end

  it "supports unindexed_property_query" do
    query = unindexed_property_query
    tasks = datastore.run query

    refute tasks.empty?
    assert_equal "A task description.", tasks.first["description"]
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

  it "supports transactional_single_entity_group_read_only" do
    tasks_in_list = transactional_single_entity_group_read_only task_list_name: task_list_name

    refute tasks_in_list.empty?
    assert_equal "Task", tasks_in_list.first.key.kind
    assert_equal "TaskList", tasks_in_list.first.key.parent.kind
  end

  it "supports namespace_run_query" do
    namespaces = namespace_run_query

    assert namespaces.empty?
  end

  it "supports kind_run_query" do
    kinds = kind_run_query

    assert_includes kinds, "Task"
  end

  it "supports property_run_query" do
    properties_by_kind = property_run_query

    refute properties_by_kind.empty?
    props = ["category", "created", "description", "done", "percent_complete", "priority", "tag"]
    assert_equal props, properties_by_kind["Task"]
  end

  it "supports property_by_kind_run_query" do
    representations = property_by_kind_run_query

    refute representations.empty?
    assert_equal ["INT64"], representations["created"]
    assert_equal ["STRING"], representations["category"]
  end

  it "supports property_filtering_run_query" do
    properties_by_kind = property_filtering_run_query

    refute properties_by_kind.empty?
    assert_includes properties_by_kind["Task"], "priority"
    assert_includes properties_by_kind["Task"], "tag"
  end

  def find_or_save_task task_key
    t = datastore.find task_key
    if t.nil?
      t = task_entity task_key
      datastore.save t
    end
    t
  end

  def task_entity key
    datastore.entity key do |t|
      t["category"] = "Personal"
      t["created"] = Time.utc 1999, 12, rand(1..31)
      t["done"] = false
      t["priority"] = 4
      t["percent_complete"] = 10.0
      t["description"] = "A task description."
      t["tag"] = ["fun", "programming"]
    end
  end

  def assert_basic_task task
    assert_equal "Task", task.key.kind
    assert_equal "Personal", task["category"]
    assert_equal false, task["done"]
  end
end
