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

# [START bigtable_reads_print]
# Import google bigtable client lib
require "google/cloud/bigtable"
# Write your code here.
# [START_EXCLUDE]

def reads_row instance_id, table_id
  # [START bigtable_reads_row]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  bigtable = Google::Cloud::Bigtable.new
  table = bigtable.table instance_id, table_id

  row = table.read_row "phone#4c410523#20190501"
  print_row row
end

# [END bigtable_reads_row]

def reads_row_partial instance_id, table_id
  # [START bigtable_reads_row_partial]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  bigtable = Google::Cloud::Bigtable.new
  table = bigtable.table instance_id, table_id
  filter = Google::Cloud::Bigtable::RowFilter.qualifier "os_build"

  row = table.read_row "phone#4c410523#20190501", filter: filter
  print_row row
end

# [END bigtable_reads_row_partial]

def reads_rows instance_id, table_id
  # [START bigtable_reads_rows]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  bigtable = Google::Cloud::Bigtable.new
  table = bigtable.table instance_id, table_id

  table.read_rows(keys: ["phone#4c410523#20190501", "phone#4c410523#20190502"]).each do |row|
    print_row row
  end
  # [END bigtable_reads_rows]
end

def reads_row_range instance_id, table_id
  # [START bigtable_reads_row_range]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  bigtable = Google::Cloud::Bigtable.new
  table = bigtable.table instance_id, table_id

  range = table.new_row_range.between "phone#4c410523#20190501", "phone#4c410523#201906201"
  table.read_rows(ranges: range).each do |row|
    print_row row
  end
  # [END bigtable_reads_row_range]
end

def reads_row_ranges instance_id, table_id
  # [START bigtable_reads_row_ranges]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  bigtable = Google::Cloud::Bigtable.new
  table = bigtable.table instance_id, table_id

  ranges = []
  ranges <<
    table.new_row_range.between("phone#4c410523#20190501", "phone#4c410523#201906201") <<
    table.new_row_range.between("phone#5c10102#20190501", "phone#5c10102#201906201")
  table.read_rows(ranges: ranges).each do |row|
    print_row row
  end
  # [END bigtable_reads_row_ranges]
end

def reads_prefix instance_id, table_id
  # [START bigtable_reads_prefix]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  bigtable = Google::Cloud::Bigtable.new
  table = bigtable.table instance_id, table_id

  prefix = "phone#"
  end_key = prefix[0...-1] + prefix[-1].next
  range = table.new_row_range.between prefix, end_key
  table.read_rows(ranges: range).each do |row|
    print_row row
  end
  # [END bigtable_reads_prefix]
end

def reads_filter instance_id, table_id
  # [START bigtable_reads_filter]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  bigtable = Google::Cloud::Bigtable.new
  table = bigtable.table instance_id, table_id

  filter = Google::Cloud::Bigtable::RowFilter.value "PQ2A.*$"
  table.read_rows(filter: filter).each do |row|
    print_row row
  end
  # [END bigtable_reads_filter]
end

# [END_EXCLUDE]
def print_row row
  puts "Reading data for #{row.key}:"

  row.cells.each do |column_family, data|
    puts "Column Family #{column_family}"
    data.each do |cell|
      labels = !cell.labels.empty? ? " [#{cell.labels.join ','}]" : ""
      puts "\t#{cell.qualifier}: #{cell.value} @#{cell.timestamp}#{labels}"
    end
  end
  puts "\n"
end

# [END bigtable_reads_print]
