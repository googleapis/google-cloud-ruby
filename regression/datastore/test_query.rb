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

describe "Datastore Query", :datastore do
  it "can query by kind and filter" do
    kind = "Task REGRESSION TEST (#{Time.now.to_s})"

    count_query = Gcloud::Datastore::Query.new
    count_query.kind kind

    connection.run(count_query).count.must_equal 0

    entity = Gcloud::Datastore::Entity.new
    entity.key = Gcloud::Datastore::Key.new kind
    entity["description"] = "Get started with Devserver"
    entity["completed"] = false
    entity["due"] = Time.new(2014, 6, 1, 0, 0, 0, 0)
    connection.save entity

    connection.run(count_query).count.must_equal 1

    complete_query = Gcloud::Datastore::Query.new
    complete_query.kind kind
    complete_query.filter "completed", "=", true

    incomplete_query = Gcloud::Datastore::Query.new
    incomplete_query.kind kind
    incomplete_query.filter "completed", "=", false

    connection.run(complete_query).count.must_equal 0
    connection.run(incomplete_query).count.must_equal 1

    entity["completed"] = true
    connection.save entity

    connection.run(complete_query).count.must_equal 1
    connection.run(incomplete_query).count.must_equal 0

    composite_query = Gcloud::Datastore::Query.new
    composite_query.kind kind
    composite_query.filter "completed", "=", true
    composite_query.filter "due", :>, Time.new(2014, 7, 1, 0, 0, 0, 0)

    connection.run(composite_query).count.must_equal 0

    entity["due"] = Time.new(2014, 8, 1, 0, 0, 0, 0)
    connection.save entity

    connection.run(composite_query).count.must_equal 1

    connection.delete entity
  end

  it "can sort results" do
    kind = "Task ORDER REGRESSION TEST (#{Time.now.to_s})"

    count_query = Gcloud::Datastore::Query.new
    count_query.kind kind

    connection.run(count_query).count.must_equal 0

    create_five_entities kind

    connection.run(count_query).count.must_equal 5

    complete_query = Gcloud::Datastore::Query.new
    complete_query.kind kind
    complete_query.filter "completed", "=", true
    complete_query.order "due"

    incomplete_query = Gcloud::Datastore::Query.new
    incomplete_query.kind kind
    incomplete_query.filter "completed", "=", false
    incomplete_query.order "due", :desc

    complete_results   = connection.run complete_query
    incomplete_results = connection.run incomplete_query

    complete_results.count.must_equal 2
    incomplete_results.count.must_equal 3

    complete_results.first.key.name.must_equal "two"
    complete_results.last.key.name.must_equal "four"

    incomplete_results.first.key.name.must_equal "five"
    incomplete_results.last.key.name.must_equal "one"

    connection.delete(*(complete_results + incomplete_results))
  end

  it "can limit and offset results" do
    kind = "Task LIMIT/OFFSET REGRESSION TEST (#{Time.now.to_s})"

    all_query = Gcloud::Datastore::Query.new
    all_query.kind kind

    connection.run(all_query).count.must_equal 0

    create_five_entities kind

    connection.run(all_query).count.must_equal 5

    limit_query = Gcloud::Datastore::Query.new
    limit_query.kind kind
    limit_query.filter "completed", "=", false
    limit_query.order "due", :desc
    limit_query.limit 1
    limit_query.offset 1

    limit_results = connection.run limit_query
    limit_results.count.must_equal 1
    limit_results.first.key.name.must_equal "three"

    all_results = connection.run all_query

    connection.delete(*all_results)
  end

  it "can select properties to return" do
    kind = "Task SELECT REGRESSION TEST (#{Time.now.to_s})"

    all_query = Gcloud::Datastore::Query.new
    all_query.kind kind

    connection.run(all_query).count.must_equal 0

    create_five_entities kind

    connection.run(all_query).count.must_equal 5

    one = connection.find kind, "one"
    one.wont_be :nil?
    one["completed"].must_equal false
    one["due"].wont_be :nil?

    select_query = Gcloud::Datastore::Query.new
    select_query.kind kind
    select_query.select "completed"

    selected_entries = connection.run select_query
    selected_entries.count.must_equal 5

    selected_entry = selected_entries.find { |e| e.key.name == one.key.name }
    selected_entry.wont_be :nil?
    selected_entry["completed"].must_equal one["completed"]
    selected_entry["due"].must_be :nil?
    selected_entry["due"].wont_equal one["due"]

    all_results = connection.run all_query

    connection.delete(*all_results)
  end

  it "can group on properties" do
    kind = "Task GROUP BY REGRESSION TEST (#{Time.now.to_s})"

    all_query = Gcloud::Datastore::Query.new
    all_query.kind kind

    connection.run(all_query).count.must_equal 0

    create_five_entities kind

    connection.run(all_query).count.must_equal 5

    group_query = Gcloud::Datastore::Query.new
    group_query.kind kind
    group_query.select "completed"
    group_query.group_by "completed"

    # Grouped to two entries, one completed false, the other true
    connection.run(group_query).count.must_equal 2

    all_results = connection.run all_query

    connection.delete(*all_results)
  end

  def create_five_entities kind
    one = Gcloud::Datastore::Entity.new
    one.key = Gcloud::Datastore::Key.new kind, "one"
    one["description"] = "Get started with Devserver (one)"
    one["completed"] = false
    one["due"] = Time.new(2014, 6, 1, 0, 0, 0, 0)

    two = Gcloud::Datastore::Entity.new
    two.key = Gcloud::Datastore::Key.new kind, "two"
    two["description"] = "Get started with Devserver (two)"
    two["completed"] = true
    two["due"] = Time.new(2014, 6, 2, 0, 0, 0, 0)

    three = Gcloud::Datastore::Entity.new
    three.key = Gcloud::Datastore::Key.new kind, "three"
    three["description"] = "Get started with Devserver (three)"
    three["completed"] = false
    three["due"] = Time.new(2014, 6, 3, 0, 0, 0, 0)

    four = Gcloud::Datastore::Entity.new
    four.key = Gcloud::Datastore::Key.new kind, "four"
    four["description"] = "Get started with Devserver (four)"
    four["completed"] = true
    four["due"] = Time.new(2014, 6, 4, 0, 0, 0, 0)

    five = Gcloud::Datastore::Entity.new
    five.key = Gcloud::Datastore::Key.new kind, "five"
    five["description"] = "Get started with Devserver (five)"
    five["completed"] = false
    five["due"] = Time.new(2014, 6, 5, 0, 0, 0, 0)
    connection.save one, two, three, four, five
  end
end
