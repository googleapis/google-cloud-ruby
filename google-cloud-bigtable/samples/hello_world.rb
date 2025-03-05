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

def hello_world instance_id, table_id, column_family, column_qualifier
  # [START bigtable_hw_imports]
  require "google/cloud/bigtable"
  # [END bigtable_hw_imports]

  # [START bigtable_hw_connect]
  # These variables are used in the sample code below.
  # instance_id      = "my-instance"
  # table_id         = "my-table"
  # column_family    = "cf"
  # column_qualifier = "greeting"

  bigtable = Google::Cloud::Bigtable.new
  table_client = bigtable.table_admin_client
  # [END bigtable_hw_connect]

  # [START bigtable_hw_create_table]
  # This is the full resource name for the table. Use this name to make admin
  # calls for the table, such as reading or deleting the resource.
  table_name = table_client.table_path project: bigtable.project_id,
                                       instance: instance_id,
                                       table: table_id
  begin
    # Attempt to get the table to see if it already exists
    table_client.get_table name: table_name
    puts "#{table_id} is already exists."
    exit 0
  rescue Google::Cloud::NotFoundError
    # The table doesn't exist, so let's create it.
    # The following is the resource name for the table's instance.
    instance_name = table_client.instance_path project: bigtable.project_id,
                                               instance: instance_id
    # This is the configuration of the table's column families.
    table_config = {
      column_families: {
        column_family => {
          gc_rule: Google::Cloud::Bigtable::Admin::V2::GcRule.max_num_versions(1)
        }
      }
    }
    # Now call the API to create the table.
    table_client.create_table parent: instance_name,
                              table_id: table_id,
                              table: table_config
    puts "Table #{table_id} created."
  end
  # [END bigtable_hw_create_table]

  # [START bigtable_hw_write_rows]
  puts "Write some greetings to the table #{table_id}"
  greetings = ["Hello World!", "Hello Bigtable!", "Hello Ruby!"]

  # Get a table data object for the new table we created.
  table = bigtable.table instance_id, table_id

  # Insert rows one by one
  # Note: To perform multiple mutation on multiple rows use `mutate_rows`.
  greetings.each_with_index do |value, i|
    puts " Writing,  Row key: greeting#{i}, Value: #{value}"

    entry = table.new_mutation_entry "greeting#{i}"
    entry.set_cell(
      column_family,
      column_qualifier,
      value,
      timestamp: (Time.now.to_f * 1_000_000).round(-3)
    )

    table.mutate_row entry
  end
  # [END bigtable_hw_write_rows]

  # [START bigtable_hw_create_filter]
  # Only retrieve the most recent version of the cell.
  filter = Google::Cloud::Bigtable::RowFilter.cells_per_column 1
  # [END bigtable_hw_create_filter]

  # [START bigtable_hw_get_with_filter]
  puts "Reading a single row by row key"
  row = table.read_row "greeting0", filter: filter
  puts "Row key: #{row.key}, Value: #{row.cells[column_family].first.value}"
  # [END bigtable_hw_get_with_filter]

  # [START bigtable_hw_scan_with_filter]
  puts "Reading the entire table"
  table.read_rows.each do |row|
    puts "Row key: #{row.key}, Value: #{row.cells[column_family].first.value}"
  end
  # [END bigtable_hw_scan_with_filter]

  # [START bigtable_hw_delete_table]
  puts "Deleting the table #{table_id}"
  # Call the admin API to delete the table given its full resource path.
  table_client.delete_table name: table_name
  # [END bigtable_hw_delete_table]
end
