# Copyright 2021 Google LLC
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

# Import google bigtable client lib
require "google/cloud/bigtable"

def run_table_operations instance_id, table_id
  bigtable = Google::Cloud::Bigtable.new
  puts "Checking if table exists"
  table = bigtable.table instance_id, table_id, perform_lookup: true

  if table
    puts "Table exists"
  else
    puts "Table does not exist. Creating table #{table_id}"
    # [START bigtable_create_table]
    # instance_id = "my-instance"
    # table_id    = "my-table"
    table = bigtable.create_table instance_id, table_id
    puts "Table created #{table.name}"
    # [END bigtable_create_table]
  end

  puts "Listing tables in instance"
  # [START bigtable_list_tables]
  # instance_id = "my-instance"
  bigtable.tables(instance_id).all.each do |t|
    puts "Table: #{t.name}"
  end
  # [END bigtable_list_tables]

  puts "Get table and print details:"
  # [START bigtable_get_table_metadata]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  table = bigtable.table(
    instance_id,
    table_id,
    view:           :FULL,
    perform_lookup: true
  )
  puts "Cluster states:"
  table.cluster_states.each do |stats|
    p stats
  end
  # [END bigtable_get_table_metadata]

  puts "Timestamp granularity: #{table.granularity}"
  puts "1. Creating column family cf1 with max age GC rule"
  # [START bigtable_create_family_gc_max_age]
  # Create a column family with GC policy : maximum age
  # where age = current time minus cell timestamp
  # NOTE: Age value must be atleast 1 millisecond
  max_age_rule = Google::Cloud::Bigtable::GcRule.max_age 60 * 60 * 24 * 5
  column_families = table.column_families do |cfs|
    cfs.add "cf1", gc_rule: max_age_rule
  end
  family = column_families["cf1"]
  # [END bigtable_create_family_gc_max_age]
  puts "Created column family with max age GC rule: #{family.name}"

  puts "2. Creating column family cf2 with max versions GC rule"
  # [START bigtable_create_family_gc_max_versions]
  # Create a column family with GC policy : most recent N versions
  # where 1 = most recent version
  max_versions_rule = Google::Cloud::Bigtable::GcRule.max_versions 2
  column_families = table.column_families do |cfs|
    cfs.add "cf2", gc_rule: max_versions_rule
  end
  family = column_families["cf2"]
  # [END bigtable_create_family_gc_max_versions]
  puts "Created column family with max versions GC rule: #{family.name}"

  puts "3. Creating column family cf3 with union GC rule"
  # [START bigtable_create_family_gc_union]
  # Create a column family with GC policy to drop data that matches at least
  # one condition
  max_age_rule = Google::Cloud::Bigtable::GcRule.max_age 60 * 60 * 24 * 5
  max_versions_rule = Google::Cloud::Bigtable::GcRule.max_versions 2
  union_gc_rule = Google::Cloud::Bigtable::GcRule.union max_age_rule, max_versions_rule
  column_families = table.column_families do |cfs|
    cfs.add "cf3", gc_rule: union_gc_rule
  end
  family = column_families["cf3"]
  # [END bigtable_create_family_gc_union]
  puts "Created column family with union GC rule: #{family.name}"

  puts "4. Creating column family cf4 with intersect GC rule"
  # [START bigtable_create_family_gc_intersection]
  # Create a column family with GC policy to drop data that matches at least
  # one condition
  max_age_rule = Google::Cloud::Bigtable::GcRule.max_age 60 * 60 * 24 * 5
  max_versions_rule = Google::Cloud::Bigtable::GcRule.max_versions 2
  intersection_gc_rule = Google::Cloud::Bigtable::GcRule.intersection max_age_rule, max_versions_rule
  column_families = table.column_families do |cfs|
    cfs.add "cf4", gc_rule: intersection_gc_rule
  end
  family = column_families["cf4"]
  # [END bigtable_create_family_gc_intersection]
  puts "Created column family with intersect GC rule: #{family.name}"

  puts "5. Creating column family cf5 with a nested GC rule"
  # [START bigtable_create_family_gc_nested]
  # Create a nested GC rule:
  # Drop cells that are either older than the 10 recent versions
  # OR
  # Drop cells that are older than a month AND older than the 2 recent versions
  max_versions_rule1 = Google::Cloud::Bigtable::GcRule.max_versions 10
  max_age_rule = Google::Cloud::Bigtable::GcRule.max_age 60 * 60 * 24 * 5
  max_versions_rule2 = Google::Cloud::Bigtable::GcRule.max_versions 2
  intersection_gc_rule = Google::Cloud::Bigtable::GcRule.intersection max_age_rule, max_versions_rule2
  nested_gc_rule = Google::Cloud::Bigtable::GcRule.union max_versions_rule1, intersection_gc_rule
  # [END bigtable_create_family_gc_nested]
  column_families = table.column_families do |cfs|
    cfs.add "cf5", gc_rule: nested_gc_rule
  end
  family = column_families["cf5"]
  puts "Created column family with a nested GC rule: #{family.name}"

  puts "Printing name and GC Rule for all column families"
  # [START bigtable_list_column_families]
  table = bigtable.table(
    instance_id,
    table_id,
    view:           :FULL,
    perform_lookup: true
  )
  table.column_families.each do |name, family|
    puts "Column family name: #{name}"
    puts "GC Rule:"
    p family.gc_rule
  end
  # [END bigtable_list_column_families]

  puts "Updating column family cf1 GC rule"
  # [START bigtable_update_gc_rule]
  gc_rule = Google::Cloud::Bigtable::GcRule.max_versions 1
  column_families = table.column_families do |cfs|
    cfs.update "cf1", gc_rule: gc_rule
  end
  p column_families["cf1"]
  # [END bigtable_update_gc_rule]
  puts "Updated max version GC rule of column_family: cf1"

  puts "Print updated column family cf1 GC rule"
  # [START bigtable_family_get_gc_rule]
  family = table.column_families["cf1"]
  # [END bigtable_family_get_gc_rule]
  p family

  puts "Delete a column family cf2"
  # [START bigtable_delete_family]
  column_families = table.column_families do |cfs|
    cfs.delete "cf2"
  end
  # [END bigtable_delete_family]
  puts "Deleted column family: cf2"
end

def delete_table instance_id, table_id
  bigtable = Google::Cloud::Bigtable.new

  puts "Delete the table."
  # [START bigtable_delete_table]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  table = bigtable.table instance_id, table_id
  table.delete
  #  [END bigtable_delete_table]

  puts "Table deleted: #{table.name}"
end

if $PROGRAM_NAME == __FILE__
  case ARGV.shift
  when "run"
    run_table_operations ARGV.shift, ARGV.shift
  when "delete"
    delete_table ARGV.shift, ARGV.shift
  else
    puts <<~USAGE
      Perform Bigtable Table admin operations
      Usage: bundle exec ruby tableadmin.rb [command] [arguments]

      Commands:
        run          <instance_id> <table_id>     Create a table (if does not exist) and run basic table operations
        delete       <instance_id> <table_id>     Delete table

      Environment variables:
        GOOGLE_CLOUD_BIGTABLE_PROJECT or GOOGLE_CLOUD_PROJECT must be set to your Google Cloud project ID
    USAGE
  end
end
