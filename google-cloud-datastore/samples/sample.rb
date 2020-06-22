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

require "google/cloud/datastore"

def incomplete_key
  datastore = Google::Cloud::Datastore.new

  # [START datastore_incomplete_key]
  task_key = datastore.key "Task"
  # [END datastore_incomplete_key]
end

def named_key task_name:
  datastore = Google::Cloud::Datastore.new

  # [START datastore_named_key]
  # task_name = "sampleTask"
  task_key = datastore.key "Task", task_name
  # [END datastore_named_key]
end

def key_with_parent task_list_name:, task_name:
  datastore = Google::Cloud::Datastore.new

  # [START datastore_key_with_parent]
  # task_list_name = "default"
  # task_name = "sampleTask"
  task_key = datastore.key [["TaskList", task_list_name], ["Task", task_name]]
  # [END datastore_key_with_parent]

  task_key
end

def key_with_multilevel_parent user_name:, task_list_name:, task_name:
  datastore = Google::Cloud::Datastore.new

  # [START datastore_key_with_multilevel_parent]
  # user_name = "alice"
  # task_list_name = "default"
  # task_name = "sampleTask"
  task_key = datastore.key([
                             ["User", user_name],
                             ["TaskList", task_list_name],
                             ["Task", task_name]
                           ])
  # [END datastore_key_with_multilevel_parent]

  task_key
end

def entity_with_parent task_list_name:, task_name:
  datastore = Google::Cloud::Datastore.new

  # [START datastore_entity_with_parent]
  # task_list_name = "default"
  # task_name = "sampleTask"
  task_key = datastore.key [["TaskList", task_list_name], ["Task", task_name]]

  task = datastore.entity task_key do |t|
    t["category"] = "Personal"
    t["done"] = false
    t["priority"] = 4
    t["description"] = "Learn Cloud Datastore"
  end
  # [END datastore_entity_with_parent]

  task
end

def properties
  datastore = Google::Cloud::Datastore.new

  # [START datastore_properties]
  task = datastore.entity "Task" do |t|
    t["category"] = "Personal"
    t["created"] = Time.now
    t["done"] = false
    t["priority"] = 4
    t["percent_complete"] = 10.0
    t["description"] = "Learn Cloud Datastore"
    t.exclude_from_indexes! "description", true
  end
  # [END datastore_properties]

  task
end

def array_value task_name:
  datastore = Google::Cloud::Datastore.new

  # [START datastore_array_value]
  # task_name = "sampleTask"
  task = datastore.entity "Task", task_name do |t|
    t["tags"] = ["fun", "programming"]
    t["collaborators"] = ["alice", "bob"]
  end
  # [END datastore_array_value]
end

def basic_entity
  datastore = Google::Cloud::Datastore.new

  # [START datastore_basic_entity]
  task = datastore.entity "Task" do |t|
    t["category"] = "Personal"
    t["done"] = false
    t["priority"] = 4
    t["description"] = "Learn Cloud Datastore"
  end
  # [END datastore_basic_entity]

  task
end

def upsert task_name:
  datastore = Google::Cloud::Datastore.new

  # [START datastore_upsert]
  # task_name = "sampleTask"
  task = datastore.entity "Task", task_name do |t|
    t["category"] = "Personal"
    t["done"] = false
    t["priority"] = 4
    t["description"] = "Learn Cloud Datastore"
  end
  datastore.save task
  # [END datastore_upsert]

  task
end

def insert
  task = nil
  datastore = Google::Cloud::Datastore.new

  # [START datastore_insert]
  datastore.transaction do |_tx|
    task = datastore.entity "Task" do |t|
      t["category"] = "Personal"
      t["done"] = false
      t["priority"] = 4
      t["description"] = "Learn Cloud Datastore"
    end
    datastore.save task
  end
  # [END datastore_insert]

  task
end

def lookup task_name:
  datastore = Google::Cloud::Datastore.new

  # [START datastore_lookup]
  # task_name = "sampleTask"
  task_key = datastore.key "Task", task_name
  task = datastore.find task_key
  # [END datastore_lookup]

  task
end

def update task_name:
  datastore = Google::Cloud::Datastore.new

  task = datastore.entity "Task", task_name do |t|
    t["category"] = "Personal"
    t["done"] = false
    t["priority"] = 4
    t["description"] = "Learn Cloud Datastore"
  end
  datastore.save task

  # [START datastore_update]
  # task_name = "sampleTask"
  datastore.transaction do |_tx|
    task = datastore.find "Task", task_name
    task["priority"] = 5
    datastore.save task
  end
  # [END datastore_update]

  task
end

def delete task_name:
  datastore = Google::Cloud::Datastore.new

  # [START datastore_delete]
  # task_name = "sampleTask"
  task_key = datastore.key "Task", task_name
  datastore.delete task_key
  # [END datastore_delete]

  task_key
end

def batch_upsert
  datastore = Google::Cloud::Datastore.new

  # [START datastore_batch_upsert]
  task_1 = datastore.entity "Task" do |t|
    t["category"] = "Personal"
    t["done"] = false
    t["priority"] = 4
    t["description"] = "Learn Cloud Datastore"
  end

  task_2 = datastore.entity "Task" do |t|
    t["category"] = "Personal"
    t["done"] = false
    t["priority"] = 5
    t["description"] = "Integrate Cloud Datastore"
  end

  tasks = datastore.save task_1, task_2
  task_key_1 = tasks[0].key
  task_key_2 = tasks[1].key
  # [END datastore_batch_upsert]

  [task_key_1, task_key_2]
end

def batch_lookup task_name_1:, task_name_2:
  datastore = Google::Cloud::Datastore.new

  # [START datastore_batch_lookup]
  # task_name_1 = "sampleTask1"
  # task_name_2 = "sampleTask2"
  task_key_1 = datastore.key "Task", task_name_1
  task_key_2 = datastore.key "Task", task_name_2
  tasks = datastore.find_all task_key_1, task_key_2
  # [END datastore_batch_lookup]
end

def batch_delete task_name_1:, task_name_2:
  datastore = Google::Cloud::Datastore.new

  # [START datastore_batch_delete]
  # task_name_1 = "sampleTask1"
  # task_name_2 = "sampleTask2"
  task_key_1 = datastore.key "Task", task_name_1
  task_key_2 = datastore.key "Task", task_name_2
  datastore.delete task_key_1, task_key_2
  # [END datastore_batch_delete]

  [task_key_1, task_key_2]
end

def basic_query
  datastore = Google::Cloud::Datastore.new

  # [START datastore_basic_query]
  query = datastore.query("Task")
                   .where("done", "=", false)
                   .where("priority", ">=", 4)
                   .order("priority", :desc)
  # [END datastore_basic_query]

  # [START datastore_run_query]
  tasks = datastore.run query
  # [END datastore_run_query]
end

def property_filter
  datastore = Google::Cloud::Datastore.new

  # [START datastore_property_filter]
  query = datastore.query("Task")
                   .where("done", "=", false)
  # [END datastore_property_filter]
end

def composite_filter
  datastore = Google::Cloud::Datastore.new

  # [START datastore_composite_filter]
  query = datastore.query("Task")
                   .where("done", "=", false)
                   .where("priority", "=", 4)
  # [END datastore_composite_filter]
end

def key_filter
  datastore = Google::Cloud::Datastore.new

  # [START datastore_key_filter]
  query = datastore.query("Task")
                   .where("__key__", ">", datastore.key("Task", "someTask"))
  # [END datastore_key_filter]
end

def ascending_sort
  datastore = Google::Cloud::Datastore.new

  # [START datastore_ascending_sort]
  query = datastore.query("Task")
                   .order("created", :asc)
  # [END datastore_ascending_sort]
end

def descending_sort
  datastore = Google::Cloud::Datastore.new

  # [START datastore_descending_sort]
  query = datastore.query("Task")
                   .order("created", :desc)
  # [END datastore_descending_sort]
end

def multi_sort
  datastore = Google::Cloud::Datastore.new

  # [START datastore_multi_sort]
  query = datastore.query("Task")
                   .order("priority", :desc)
                   .order("created", :asc)
  # [END datastore_multi_sort]
end

def kindless_query
  datastore = Google::Cloud::Datastore.new

  last_seen_key = datastore.key "Task", "a"
  # [START datastore_kindless_query]
  query = Google::Cloud::Datastore::Query.new
  query.where "__key__", ">", last_seen_key
  # [END datastore_kindless_query]

  query
end

def ancestor_query task_list_name:
  datastore = Google::Cloud::Datastore.new

  # [START datastore_ancestor_query]
  # task_list_name = "default"
  ancestor_key = datastore.key "TaskList", task_list_name

  query = datastore.query("Task")
                   .ancestor(ancestor_key)
  # [END datastore_ancestor_query]
end

def projection_query
  datastore = Google::Cloud::Datastore.new

  # [START datastore_projection_query]
  query = datastore.query("Task")
                   .select("priority", "percent_complete")
  # [END datastore_projection_query]

  # [START datastore_run_query_projection]
  priorities = []
  percent_completes = []
  datastore.run(query).each do |task|
    priorities << task["priority"]
    percent_completes << task["percent_complete"]
  end
  # [END datastore_run_query_projection]

  [priorities, percent_completes]
end

def keys_only_query
  datastore = Google::Cloud::Datastore.new

  # [START datastore_keys_only_query]
  query = datastore.query("Task")
                   .select("__key__")
  # [END datastore_keys_only_query]

  keys = datastore.run(query).map(&:key)
end

def distinct_on_query
  datastore = Google::Cloud::Datastore.new

  # [START datastore_distinct_on_query]
  query = datastore.query("Task")
                   .select("category", "priority")
                   .distinct_on("category")
                   .order("category")
                   .order("priority")
  # [END datastore_distinct_on_query]
end

def array_value_inequality_range
  datastore = Google::Cloud::Datastore.new

  # [START datastore_array_value_inequality_range]
  query = datastore.query("Task")
                   .where("tag", ">", "learn")
                   .where("tag", "<", "math")
  # [END datastore_array_value_inequality_range]
end

def array_value_equality
  datastore = Google::Cloud::Datastore.new

  # [START datastore_array_value_equality]
  query = datastore.query("Task")
                   .where("tag", "=", "fun")
                   .where("tag", "=", "programming")
  # [END datastore_array_value_equality]
end

def inequality_range
  datastore = Google::Cloud::Datastore.new

  # [START datastore_inequality_range]
  query = datastore.query("Task")
                   .where("created", ">=", Time.utc(1990, 1, 1))
                   .where("created", "<", Time.utc(2000, 1, 1))
  # [END datastore_inequality_range]
end

def inequality_invalid
  datastore = Google::Cloud::Datastore.new

  # [START datastore_inequality_invalid]
  query = datastore.query("Task")
                   .where("created", ">=", Time.utc(1990, 1, 1))
                   .where("priority", ">", 3)
  # [END datastore_inequality_invalid]
end

def equal_and_inequality_range
  datastore = Google::Cloud::Datastore.new

  # [START datastore_equal_and_inequality_range]
  query = datastore.query("Task")
                   .where("done", "=", false)
                   .where("priority", "=", 4)
                   .where("created", ">=", Time.utc(1990, 1, 1))
                   .where("created", "<", Time.utc(2000, 1, 1))
  # [END datastore_equal_and_inequality_range]
end

def inequality_sort
  datastore = Google::Cloud::Datastore.new

  # [START datastore_inequality_sort]
  query = datastore.query("Task")
                   .where("priority", ">", 3)
                   .order("priority")
                   .order("created")
  # [END datastore_inequality_sort]
end

def inequality_sort_invalid_not_same
  datastore = Google::Cloud::Datastore.new

  # [START datastore_inequality_sort_invalid_not_same]
  query = datastore.query("Task")
                   .where("priority", ">", 3)
                   .order("created")
  # [END datastore_inequality_sort_invalid_not_same]
end

def inequality_sort_invalid_not_first
  datastore = Google::Cloud::Datastore.new

  # [START datastore_inequality_sort_invalid_not_first]
  query = datastore.query("Task")
                   .where("priority", ">", 3)
                   .order("created")
                   .order("priority")
  # [END datastore_inequality_sort_invalid_not_first]
end

def limit
  datastore = Google::Cloud::Datastore.new

  # [START datastore_limit]
  query = datastore.query("Task")
                   .limit(5)
  # [END datastore_limit]
end

def cursor_paging
  datastore = Google::Cloud::Datastore.new

  # [START datastore_cursor_paging]
  page_size = 2
  query = datastore.query("Task")
                   .limit(page_size)
  tasks = datastore.run query

  page_cursor = tasks.cursor

  query = datastore.query("Task")
                   .limit(page_size)
                   .start(page_cursor)
  # [END datastore_cursor_paging]
end

def eventual_consistent_query task_list_name:
  # [START datastore_eventual_consistent_query]
  # task_list_name = "default"
  ancestor_key = datastore.key "TaskList", task_list_name

  query = datastore.query("Task")
                   .ancestor(ancestor_key)

  tasks = datastore.run query, consistency: :eventual
  # [END datastore_eventual_consistent_query]

  tasks
end

def unindexed_property_query
  datastore = Google::Cloud::Datastore.new

  # [START datastore_unindexed_property_query]
  query = datastore.query("Task")
                   .where("description", "=", "A task description.")
  # [END datastore_unindexed_property_query]
end

def exploding_properties
  datastore = Google::Cloud::Datastore.new

  # [START datastore_exploding_properties]
  task = datastore.entity "Task" do |t|
    t["tags"] = ["fun", "programming", "learn"]
    t["collaborators"] = ["alice", "bob", "charlie"]
    t["created"] = Time.now
  end
  # [END datastore_exploding_properties]
end

# [START datastore_transactional_update]
def transfer_funds from_key, to_key, amount
  datastore.transaction do |tx|
    from = tx.find from_key
    from["balance"] -= amount
    to = tx.find to_key
    to["balance"] += amount
    tx.save from, to
  end
end
# [END datastore_transactional_update]

def transactional_retry from_key, to_key, amount
  # [START datastore_transactional_retry]
  (1..5).each do |i|
    begin
      return transfer_funds from_key, to_key, amount
    rescue Google::Cloud::Error => e
      raise e if i == 5
    end
  end
  # [END datastore_transactional_retry]
end

def transactional_get_or_create task_key
  # [START datastore_transactional_get_or_create]
  task = nil
  datastore.transaction do |tx|
    task = tx.find task_key
    if task.nil?
      task = datastore.entity task_key do |t|
        t["category"] = "Personal"
        t["done"] = false
        t["priority"] = 4
        t["description"] = "Learn Cloud Datastore"
      end
      tx.save task
    end
  end
  # [END datastore_transactional_get_or_create]
  task
end

def transactional_single_entity_group_read_only task_list_name:
  tasks_in_list = nil
  # [START datastore_transactional_single_entity_group_read_only]
  # task_list_name = "default"
  task_list_key = datastore.key "TaskList", task_list_name
  datastore.read_only_transaction do |tx|
    task_list = tx.find task_list_key
    query = datastore.query("Task").ancestor(task_list)
    tasks_in_list = tx.run query
  end
  # [END datastore_transactional_single_entity_group_read_only]
  tasks_in_list
end

def namespace_run_query
  datastore = Google::Cloud::Datastore.new

  # [START datastore_namespace_run_query]
  query = datastore.query("__namespace__")
                   .select("__key__")
                   .where("__key__", ">=", datastore.key("__namespace__", "g"))
                   .where("__key__", "<", datastore.key("__namespace__", "h"))

  namespaces = datastore.run(query).map do |entity|
    entity.key.name
  end
  # [END datastore_namespace_run_query]
end

def kind_run_query
  datastore = Google::Cloud::Datastore.new

  # [START datastore_kind_run_query]
  query = datastore.query("__kind__")
                   .select("__key__")

  kinds = datastore.run(query).map do |entity|
    entity.key.name
  end
  # [END datastore_kind_run_query]
end

def property_run_query
  datastore = Google::Cloud::Datastore.new

  # [START datastore_property_run_query]
  query = datastore.query("__property__")
                   .select("__key__")

  entities = datastore.run query
  properties_by_kind = entities.each_with_object({}) do |entity, memo|
    kind = entity.key.parent.name
    prop = entity.key.name
    memo[kind] ||= []
    memo[kind] << prop
  end
  # [END datastore_property_run_query]
end

def property_by_kind_run_query
  datastore = Google::Cloud::Datastore.new

  # [START datastore_property_by_kind_run_query]
  ancestor_key = datastore.key "__kind__", "Task"
  query = datastore.query("__property__")
                   .ancestor(ancestor_key)

  entities = datastore.run query
  representations = entities.each_with_object({}) do |entity, memo|
    property_name = entity.key.name
    property_types = entity["property_representation"]
    memo[property_name] = property_types
  end
  # [END datastore_property_by_kind_run_query]
end

def property_filtering_run_query
  datastore = Google::Cloud::Datastore.new

  # [START datastore_property_filtering_run_query]
  start_key = datastore.key [["__kind__", "Task"], ["__property__", "priority"]]
  query = datastore.query("__property__")
                   .select("__key__")
                   .where("__key__", ">=", start_key)

  entities = datastore.run query
  properties_by_kind = entities.each_with_object({}) do |entity, memo|
    kind = entity.key.parent.name
    prop = entity.key.name
    memo[kind] ||= []
    memo[kind] << prop
  end
  # [END datastore_property_filtering_run_query]
end
