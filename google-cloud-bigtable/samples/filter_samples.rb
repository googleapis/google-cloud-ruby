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

# [START bigtable_filters_print]

# Import google bigtable client lib
require "google/cloud/bigtable"

# Write your code here.
# [START_EXCLUDE]

def filter_limit_row_sample instance_id, table_id
  # [START bigtable_filters_limit_row_sample]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  filter = Google::Cloud::Bigtable::RowFilter.sample 0.75
  read_with_filter instance_id, table_id, filter
  # [END bigtable_filters_limit_row_sample]
end

def filter_limit_row_regex instance_id, table_id
  # [START bigtable_filters_limit_row_regex]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  filter = Google::Cloud::Bigtable::RowFilter.key ".*#20190501$"
  read_with_filter instance_id, table_id, filter
  # [END bigtable_filters_limit_row_regex]
end

def filter_limit_cells_per_col instance_id, table_id
  # [START bigtable_filters_limit_cells_per_col]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  filter = Google::Cloud::Bigtable::RowFilter.cells_per_column 2
  read_with_filter instance_id, table_id, filter
  # [END bigtable_filters_limit_cells_per_col]
end

def filter_limit_cells_per_row instance_id, table_id
  # [START bigtable_filters_limit_cells_per_row]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  filter = Google::Cloud::Bigtable::RowFilter.cells_per_row 2
  read_with_filter instance_id, table_id, filter
  # [END bigtable_filters_limit_cells_per_row]
end

def filter_limit_cells_per_row_offset instance_id, table_id
  # [START bigtable_filters_limit_cells_per_row_offset]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  filter = Google::Cloud::Bigtable::RowFilter.cells_per_row_offset 2
  read_with_filter instance_id, table_id, filter
  # [END bigtable_filters_limit_cells_per_row_offset]
end

def filter_limit_col_family_regex instance_id, table_id
  # [START bigtable_filters_limit_col_family_regex]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  filter = Google::Cloud::Bigtable::RowFilter.family "stats_.*$"
  read_with_filter instance_id, table_id, filter
  # [END bigtable_filters_limit_col_family_regex]
end

def filter_limit_col_qualifier_regex instance_id, table_id
  # [START bigtable_filters_limit_col_qualifier_regex]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  filter = Google::Cloud::Bigtable::RowFilter.qualifier "connected_.*$"
  read_with_filter instance_id, table_id, filter
  # [END bigtable_filters_limit_col_qualifier_regex]
end

def filter_limit_col_range instance_id, table_id
  # [START bigtable_filters_limit_col_range]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  range = Google::Cloud::Bigtable::ColumnRange.new("cell_plan").from("data_plan_01gb").to("data_plan_10gb")
  filter = Google::Cloud::Bigtable::RowFilter.column_range range
  read_with_filter instance_id, table_id, filter
  # [END bigtable_filters_limit_col_range]
end

def filter_limit_value_range instance_id, table_id
  # [START bigtable_filters_limit_value_range]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  range = Google::Cloud::Bigtable::ValueRange.new.from("PQ2A.190405").to("PQ2A.190406")
  filter = Google::Cloud::Bigtable::RowFilter.value_range range
  read_with_filter instance_id, table_id, filter
  # [END bigtable_filters_limit_value_range]
end

def filter_limit_value_regex instance_id, table_id
  # [START bigtable_filters_limit_value_regex]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  filter = Google::Cloud::Bigtable::RowFilter.value "PQ2A.*$"
  read_with_filter instance_id, table_id, filter
  # [END bigtable_filters_limit_value_regex]
end

def filter_limit_timestamp_range instance_id, table_id
  # [START bigtable_filters_limit_timestamp_range]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  timestamp_minus_hr = (Time.now.to_f * 1_000_000).round(-3) - (60 * 60 * 1000 * 1000)
  puts timestamp_minus_hr
  filter = Google::Cloud::Bigtable::RowFilter.timestamp_range from: 0, to: timestamp_minus_hr

  read_with_filter instance_id, table_id, filter
  # [END bigtable_filters_limit_timestamp_range]
end

def filter_limit_block_all instance_id, table_id
  # [START bigtable_filters_limit_block_all]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  filter = Google::Cloud::Bigtable::RowFilter.block
  read_with_filter instance_id, table_id, filter
  # [END bigtable_filters_limit_block_all]
end

def filter_limit_pass_all instance_id, table_id
  # [START bigtable_filters_limit_pass_all]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  filter = Google::Cloud::Bigtable::RowFilter.pass
  read_with_filter instance_id, table_id, filter
  # [END bigtable_filters_limit_pass_all]
end

def filter_modify_strip_value instance_id, table_id
  # [START bigtable_filters_modify_strip_value]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  filter = Google::Cloud::Bigtable::RowFilter.strip_value
  read_with_filter instance_id, table_id, filter
  # [END bigtable_filters_modify_strip_value]
end

def filter_modify_apply_label instance_id, table_id
  # [START bigtable_filters_modify_apply_label]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  filter = Google::Cloud::Bigtable::RowFilter.label "labelled"
  read_with_filter instance_id, table_id, filter
  # [END bigtable_filters_modify_apply_label]
end

def filter_composing_chain instance_id, table_id
  # [START bigtable_filters_composing_chain]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  filter = Google::Cloud::Bigtable::RowFilter.chain.cells_per_column(1).family("cell_plan")
  read_with_filter instance_id, table_id, filter
  # [END bigtable_filters_composing_chain]
end

def filter_composing_interleave instance_id, table_id
  # [START bigtable_filters_composing_interleave]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  filter = Google::Cloud::Bigtable::RowFilter.interleave.value("true").qualifier("os_build")
  read_with_filter instance_id, table_id, filter
  # [END bigtable_filters_composing_interleave]
end

def filter_composing_condition instance_id, table_id
  # [START bigtable_filters_composing_condition]
  # instance_id = "my-instance"
  # table_id    = "my-table"
  filter = Google::Cloud::Bigtable::RowFilter.condition(
    Google::Cloud::Bigtable::RowFilter.chain.qualifier("data_plan_10gb").value("true")
  )
                                             .on_match(Google::Cloud::Bigtable::RowFilter.label("passed-filter"))
                                             .otherwise(Google::Cloud::Bigtable::RowFilter.label("filtered-out"))
  read_with_filter instance_id, table_id, filter
  # [END bigtable_filters_composing_condition]
end


# [END_EXCLUDE]


def read_with_filter instance_id, table_id, filter
  bigtable = Google::Cloud::Bigtable.new
  table = bigtable.table instance_id, table_id

  table.read_rows(filter: filter).each do |row|
    print_row row
  end
end

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

# [END bigtable_filters_print]
