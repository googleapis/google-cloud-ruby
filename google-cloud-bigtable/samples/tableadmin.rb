# frozen_string_literal: true

# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


require 'commander/import'

# Import google bigtable client lib
require "google-cloud-bigtable"

def run_table_operations instance_id, table_id
  bigtable = Google::Cloud.new.bigtable
  instance = bigtable.instance(instance_id)

  puts "==> Checking if table exists"
  table = instance.table(table_id)

  if table
    puts "==> Table exists"
  else
    puts "==> Table does not exist. Creating table `#{table_id}`"
    # [START bigtable_create_table]
    table = instance.create_table(table_id)
    puts "==> Table created #{table.name}\n"
    # [END bigtable_create_table]
  end

  puts "==> Listing tables in instance"
  # [START bigtable_list_tables]
  instance.tables.all.each do |table|
    p table.name
  end
  # [END bigtable_list_tables]
  puts "\n"

  puts "==> Get table and print details:"
  # [START bigtable_get_table_metadata]
  table = instance.table(table_id, view: :FULL)
  puts "Cluster states:"
  table.cluster_states.each{ |s| p s }
  # [END bigtable_get_table_metadata]
  puts "Timestamp granularity: #{table.granularity}"
  puts ""

  puts "==> 1. Creating column family `cf1` with max age GC rule"
  # [START bigtable_create_family_gc_max_age]
  # Create a column family with GC policy : maximum age
  # where age = current time minus cell timestamp
  # NOTE: Age value must be atleast 1 millisecond
  gc_rule = Google::Cloud::Bigtable::GcRule.max_age(60 * 60 * 24 * 5)
  family = table.column_families.create("cf1", gc_rule: gc_rule)
  # [END bigtable_create_family_gc_max_age]
  puts "==> Created column family: `#{family.name}`"
  puts ""

  puts "==> 2. Creating column family cf2 with max versions GC rule"
  # [START bigtable_create_family_gc_max_versions]
  # Create a column family with GC policy : most recent N versions
  # where 1 = most recent version
  gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(3)
  family = table.column_families.create("cf2", gc_rule: gc_rule)
  # [END bigtable_create_family_gc_max_versions]
  puts "==> Created column family: `#{family.name}`"
  puts ""

  puts "==> 3. Creating column family cf3 with union GC rule"
  # [START bigtable_create_family_gc_union]
  # Create a column family with GC policy to drop data that matches at least
  # one condition
  gc_rule = Google::Cloud::Bigtable::GcRule.max_age(60 * 60 * 24 * 5)
  union_gc_rule = Google::Cloud::Bigtable::GcRule.union(gc_rule)
  family = table.column_families.create("cf3", gc_rule: union_gc_rule)
  # [END bigtable_create_family_gc_union]
  puts "==> Created column family: `#{family.name}`"
  puts ""

  puts "==> 4. Creating column family cf4 with intersect GC rule"
  # [START bigtable_create_family_gc_intersection]
  # Create a column family with GC policy to drop data that matches at least
  # one condition
  gc_rule = Google::Cloud::Bigtable::GcRule.max_age(60 * 60 * 24 * 5)
  intersection_gc_rule = Google::Cloud::Bigtable::GcRule.union(gc_rule)
  family = table.column_families.create("cf4", gc_rule: intersection_gc_rule)
  # [END bigtable_create_family_gc_intersection]
  puts "==> Created column family: `#{family.name}`"
  puts ""

  puts "==> 5. Creating column family cf5 with a nested GC rule"
  # [START bigtable_create_family_gc_nested]
  # Create a nested GC rule:
  # Drop cells that are either older than the 10 recent versions
  # OR
  # Drop cells that are older than a month AND older than the 2 recent versions
  gc_rule_1 = Google::Cloud::Bigtable::GcRule.max_age(60 * 60 * 24 * 30)
  gc_rule_2 = Google::Cloud::Bigtable::GcRule.max_versions(2)
  nested_gc_rule = Google::Cloud::Bigtable::GcRule.union(gc_rule_1, gc_rule_2)
  # [END bigtable_create_family_gc_nested]
  family = table.column_families.create("cf5", gc_rule: gc_rule)
  puts "==> Created column family: `#{family.name}`"
  puts ""

  puts "==> Printing name and GC Rule for all column families"
  # [START bigtable_list_column_families]
  table = instance.table(table_id, view: :FULL)
  table.column_families.each do |family|
    p "Column family name: #{family.name}"
    p "GC Rule:"
    p family.gc_rule
  end
  # [END bigtable_list_column_families]

  puts ""
  puts "==> Updating column family cf1 GC rule"
  # [START bigtable_update_gc_rule]
  family = table.column_families.find_by_name("cf1")
  family.gc_rule = Google::Cloud::Bigtable::GcRule.max_versions(1)
  updated_family = family.save
  # [END bigtable_update_gc_rule]
  puts "==> Updated GC rule."
  puts ""

  puts "==> Print updated column family cf1 GC rule"
  # [START bigtable_family_get_gc_rule]
  family = table.column_families.find_by_name("cf1")
  # [END bigtable_family_get_gc_rule]
  p family

  puts ""
  puts "==> Delete a column family cf2"
  # [START bigtable_delete_family]
  family = table.column_families.find_by_name("cf2")
  family.delete
  # [END bigtable_delete_family]
  puts "==> #{family.name} deleted successfully"

  puts ""
  puts "===> Run `bundle exec tableadmin.rb delete instance_id table_id` to delete the table"
end

def delete_table instance_id, table_id
  bigtable = Google::Cloud.new.bigtable
  instance = bigtable.instance(instance_id)

  puts "==> Delete the table."
  #  [START bigtable_delete_table]
  table = instance.table(table_id)
  #  [END bigtable_delete_table]
  table.delete

  puts "==> Table deleted: #{table.name}"
  puts "\n"
end

program :version, "0.0.1"
program :name, "tableadmin"
program :description, <<-EOS
Perform Bigtable Table admin operations

bundle exec ruby tableadmin.rb <command> <instance_id> <table_id>
EOS

command "run" do |c|
  c.syntax = "run <instance_id> <table_id>"
  c.description = "Create a table (if does not exist) and run basic table operations"
  c.action do |args, options|
    instance_id, table_id = args

    if instance_id && table_id
      run_table_operations(instance_id, table_id)
    else
      command(:help).run
    end
  end
end

command "delete" do |c|
  c.syntax = "delete <instance_id> <table_id>"
  c.description = "Delete table"
  c.action do |args, options|
    instance_id, table_id = args

    if instance_id && table_id
      delete_table(instance_id, table_id)
    else
      command(:help).run
    end
  end
end

default_command :help
