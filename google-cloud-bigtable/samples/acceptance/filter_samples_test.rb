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

require_relative "helper"
require_relative "../filter_samples"

describe Google::Cloud::Bigtable, "Filter Samples", :bigtable do
  include Minitest::Hooks
  before(:all) do
    @table_id = "mobile-time-series-#{SecureRandom.hex 8}"
    bigtable = Google::Cloud::Bigtable.new

    column_families = Google::Cloud::Bigtable::ColumnFamilyMap.new
    column_families.add "stats_summary", gc_rule: nil
    column_families.add "cell_plan", gc_rule: nil

    @table = bigtable.create_table bigtable_instance_id, @table_id, column_families: column_families

    @timestamp = (Time.now.to_f * 1_000_000).round(-3)
    @timestamp_minus_hr = (Time.now.to_f * 1_000_000).round(-3) - 60 * 60 * 1000 * 1000

    entries = []
    entries <<
        @table.new_mutation_entry("phone#4c410523#20190501").set_cell("stats_summary", "connected_cell", "1", timestamp: @timestamp)
            .set_cell("stats_summary", "connected_wifi", "1", timestamp: @timestamp)
            .set_cell("stats_summary", "os_build", "PQ2A.190405.003", timestamp: @timestamp)
            .set_cell("cell_plan", "data_plan_01gb", "true", timestamp: @timestamp_minus_hr)
            .set_cell("cell_plan", "data_plan_01gb", "false", timestamp: @timestamp)
            .set_cell("cell_plan", "data_plan_05gb", "true", timestamp: @timestamp) <<
        @table.new_mutation_entry("phone#4c410523#20190502").set_cell("stats_summary", "connected_cell", "1", timestamp: @timestamp)
            .set_cell("stats_summary", "connected_wifi", "1", timestamp: @timestamp)
            .set_cell("stats_summary", "os_build", "PQ2A.190405.004", timestamp: @timestamp)
            .set_cell("cell_plan", "data_plan_05gb", "true", timestamp: @timestamp) <<
        @table.new_mutation_entry("phone#4c410523#20190505").set_cell("stats_summary", "connected_cell", "0", timestamp: @timestamp)
            .set_cell("stats_summary", "connected_wifi", "1", timestamp: @timestamp)
            .set_cell("stats_summary", "os_build", "PQ2A.190406.000", timestamp: @timestamp)
            .set_cell("cell_plan", "data_plan_05gb", "true", timestamp: @timestamp) <<
        @table.new_mutation_entry("phone#5c10102#20190501").set_cell("stats_summary", "connected_cell", "1", timestamp: @timestamp)
            .set_cell("stats_summary", "connected_wifi", "1", timestamp: @timestamp)
            .set_cell("stats_summary", "os_build", "PQ2A.190401.002", timestamp: @timestamp)
            .set_cell("cell_plan", "data_plan_10gb", "true", timestamp: @timestamp) <<
        @table.new_mutation_entry("phone#5c10102#20190502").set_cell("stats_summary", "connected_cell", "1", timestamp: @timestamp)
            .set_cell("stats_summary", "connected_wifi", "0", timestamp: @timestamp)
            .set_cell("stats_summary", "os_build", "PQ2A.190406.000", timestamp: @timestamp)
            .set_cell("cell_plan", "data_plan_10gb", "true", timestamp: @timestamp)

    @table.mutate_rows entries
  end

  after(:all) do
    @table.delete if @table
  end

  it 'filter_limit_row_regex' do
    out, _err = capture_io do
      filter_limit_row_regex bigtable_instance_id, @table_id
    end
    expected = <<~OUTPUT
      Reading data for phone#4c410523#20190501:
      Column Family cell_plan
      \tdata_plan_01gb: false @#{@timestamp}
      \tdata_plan_01gb: true @#{@timestamp_minus_hr}
      \tdata_plan_05gb: true @#{@timestamp}
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp}
      \tconnected_wifi: 1 @#{@timestamp}
      \tos_build: PQ2A.190405.003 @#{@timestamp}

      Reading data for phone#5c10102#20190501:
      Column Family cell_plan
      \tdata_plan_10gb: true @#{@timestamp}
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp}
      \tconnected_wifi: 1 @#{@timestamp}
      \tos_build: PQ2A.190401.002 @#{@timestamp}

    OUTPUT

    assert_match expected, out
  end

  it 'filter_limit_cells_per_col' do
    out, _err = capture_io do
      filter_limit_cells_per_col bigtable_instance_id, @table_id
    end
    expected = <<~OUTPUT
      Reading data for phone#4c410523#20190501:
      Column Family cell_plan
      \tdata_plan_01gb: false @#{@timestamp}
      \tdata_plan_01gb: true @#{@timestamp_minus_hr}
      \tdata_plan_05gb: true @#{@timestamp}
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp}
      \tconnected_wifi: 1 @#{@timestamp}
      \tos_build: PQ2A.190405.003 @#{@timestamp}

      Reading data for phone#4c410523#20190502:
      Column Family cell_plan
      \tdata_plan_05gb: true @#{@timestamp}
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp}
      \tconnected_wifi: 1 @#{@timestamp}
      \tos_build: PQ2A.190405.004 @#{@timestamp}

      Reading data for phone#4c410523#20190505:
      Column Family cell_plan
      \tdata_plan_05gb: true @#{@timestamp}
      Column Family stats_summary
      \tconnected_cell: 0 @#{@timestamp}
      \tconnected_wifi: 1 @#{@timestamp}
      \tos_build: PQ2A.190406.000 @#{@timestamp}

      Reading data for phone#5c10102#20190501:
      Column Family cell_plan
      \tdata_plan_10gb: true @#{@timestamp}
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp}
      \tconnected_wifi: 1 @#{@timestamp}
      \tos_build: PQ2A.190401.002 @#{@timestamp}

      Reading data for phone#5c10102#20190502:
      Column Family cell_plan
      \tdata_plan_10gb: true @#{@timestamp}
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp}
      \tconnected_wifi: 0 @#{@timestamp}
      \tos_build: PQ2A.190406.000 @#{@timestamp}

    OUTPUT

    assert_match expected, out
  end

  it 'filter_limit_cells_per_row' do
    out, _err = capture_io do
      filter_limit_cells_per_row bigtable_instance_id, @table_id
    end
    expected = <<~OUTPUT
      Reading data for phone#4c410523#20190501:
      Column Family cell_plan
      \tdata_plan_01gb: false @#{@timestamp}
      \tdata_plan_01gb: true @#{@timestamp_minus_hr}

      Reading data for phone#4c410523#20190502:
      Column Family cell_plan
      \tdata_plan_05gb: true @#{@timestamp}
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp}

      Reading data for phone#4c410523#20190505:
      Column Family cell_plan
      \tdata_plan_05gb: true @#{@timestamp}
      Column Family stats_summary
      \tconnected_cell: 0 @#{@timestamp}

      Reading data for phone#5c10102#20190501:
      Column Family cell_plan
      \tdata_plan_10gb: true @#{@timestamp}
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp}

      Reading data for phone#5c10102#20190502:
      Column Family cell_plan
      \tdata_plan_10gb: true @#{@timestamp}
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp}

    OUTPUT

    assert_match expected, out
  end

  it 'filter_limit_cells_per_row_offset' do
    out, _err = capture_io do
      filter_limit_cells_per_row_offset bigtable_instance_id, @table_id
    end
    expected = <<~OUTPUT
      Reading data for phone#4c410523#20190501:
      Column Family cell_plan
      \tdata_plan_05gb: true @#{@timestamp}
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp}
      \tconnected_wifi: 1 @#{@timestamp}
      \tos_build: PQ2A.190405.003 @#{@timestamp}

      Reading data for phone#4c410523#20190502:
      Column Family stats_summary
      \tconnected_wifi: 1 @#{@timestamp}
      \tos_build: PQ2A.190405.004 @#{@timestamp}

      Reading data for phone#4c410523#20190505:
      Column Family stats_summary
      \tconnected_wifi: 1 @#{@timestamp}
      \tos_build: PQ2A.190406.000 @#{@timestamp}

      Reading data for phone#5c10102#20190501:
      Column Family stats_summary
      \tconnected_wifi: 1 @#{@timestamp}
      \tos_build: PQ2A.190401.002 @#{@timestamp}

      Reading data for phone#5c10102#20190502:
      Column Family stats_summary
      \tconnected_wifi: 0 @#{@timestamp}
      \tos_build: PQ2A.190406.000 @#{@timestamp}

    OUTPUT

    assert_match expected, out
  end

  it 'filter_limit_col_family_regex' do
    out, _err = capture_io do
      filter_limit_col_family_regex bigtable_instance_id, @table_id
    end
    expected = <<~OUTPUT
      Reading data for phone#4c410523#20190501:
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp}
      \tconnected_wifi: 1 @#{@timestamp}
      \tos_build: PQ2A.190405.003 @#{@timestamp}

      Reading data for phone#4c410523#20190502:
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp}
      \tconnected_wifi: 1 @#{@timestamp}
      \tos_build: PQ2A.190405.004 @#{@timestamp}

      Reading data for phone#4c410523#20190505:
      Column Family stats_summary
      \tconnected_cell: 0 @#{@timestamp}
      \tconnected_wifi: 1 @#{@timestamp}
      \tos_build: PQ2A.190406.000 @#{@timestamp}

      Reading data for phone#5c10102#20190501:
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp}
      \tconnected_wifi: 1 @#{@timestamp}
      \tos_build: PQ2A.190401.002 @#{@timestamp}

      Reading data for phone#5c10102#20190502:
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp}
      \tconnected_wifi: 0 @#{@timestamp}
      \tos_build: PQ2A.190406.000 @#{@timestamp}

    OUTPUT

    assert_match expected, out
  end

  it 'filter_limit_col_qualifier_regex' do
    out, _err = capture_io do
      filter_limit_col_qualifier_regex bigtable_instance_id, @table_id
    end
    expected = <<~OUTPUT
      Reading data for phone#4c410523#20190501:
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp}
      \tconnected_wifi: 1 @#{@timestamp}

      Reading data for phone#4c410523#20190502:
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp}
      \tconnected_wifi: 1 @#{@timestamp}

      Reading data for phone#4c410523#20190505:
      Column Family stats_summary
      \tconnected_cell: 0 @#{@timestamp}
      \tconnected_wifi: 1 @#{@timestamp}

      Reading data for phone#5c10102#20190501:
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp}
      \tconnected_wifi: 1 @#{@timestamp}

      Reading data for phone#5c10102#20190502:
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp}
      \tconnected_wifi: 0 @#{@timestamp}

    OUTPUT

    assert_match expected, out
  end

  it 'filter_limit_col_range' do
    out, _err = capture_io do
      filter_limit_col_range bigtable_instance_id, @table_id
    end
    expected = <<~OUTPUT
      Reading data for phone#4c410523#20190501:
      Column Family cell_plan
      \tdata_plan_01gb: false @#{@timestamp}
      \tdata_plan_01gb: true @#{@timestamp_minus_hr}
      \tdata_plan_05gb: true @#{@timestamp}

      Reading data for phone#4c410523#20190502:
      Column Family cell_plan
      \tdata_plan_05gb: true @#{@timestamp}

      Reading data for phone#4c410523#20190505:
      Column Family cell_plan
      \tdata_plan_05gb: true @#{@timestamp}

    OUTPUT

    assert_match expected, out
  end

  it 'filter_limit_value_range' do
    out, _err = capture_io do
      filter_limit_value_range bigtable_instance_id, @table_id
    end
    expected = <<~OUTPUT
      Reading data for phone#4c410523#20190501:
      Column Family stats_summary
      \tos_build: PQ2A.190405.003 @#{@timestamp}

      Reading data for phone#4c410523#20190502:
      Column Family stats_summary
      \tos_build: PQ2A.190405.004 @#{@timestamp}

    OUTPUT

    assert_match expected, out
  end

  it 'filter_limit_value_regex' do
    out, _err = capture_io do
      filter_limit_value_regex bigtable_instance_id, @table_id
    end
    expected = <<~OUTPUT
      Reading data for phone#4c410523#20190501:
      Column Family stats_summary
      \tos_build: PQ2A.190405.003 @#{@timestamp}

      Reading data for phone#4c410523#20190502:
      Column Family stats_summary
      \tos_build: PQ2A.190405.004 @#{@timestamp}

      Reading data for phone#4c410523#20190505:
      Column Family stats_summary
      \tos_build: PQ2A.190406.000 @#{@timestamp}

      Reading data for phone#5c10102#20190501:
      Column Family stats_summary
      \tos_build: PQ2A.190401.002 @#{@timestamp}

      Reading data for phone#5c10102#20190502:
      Column Family stats_summary
      \tos_build: PQ2A.190406.000 @#{@timestamp}

    OUTPUT

    assert_match expected, out
  end

  it 'filter_limit_timestamp_range' do
    out, _err = capture_io do
      filter_limit_timestamp_range bigtable_instance_id, @table_id
    end
    expected = <<~OUTPUT
      Reading data for phone#4c410523#20190501:
      Column Family cell_plan
      \tdata_plan_01gb: true @#{@timestamp_minus_hr}

    OUTPUT

    assert_match expected, out
  end

  it 'filter_limit_block_all' do
    out, _err = capture_io do
      filter_limit_block_all bigtable_instance_id, @table_id
    end

    assert_match "", out
  end

  it 'filter_limit_pass_all' do
    out, _err = capture_io do
      filter_limit_pass_all bigtable_instance_id, @table_id
    end
    expected = <<~OUTPUT
      Reading data for phone#4c410523#20190501:
      Column Family cell_plan
      \tdata_plan_01gb: false @#{@timestamp}
      \tdata_plan_01gb: true @#{@timestamp_minus_hr}
      \tdata_plan_05gb: true @#{@timestamp}
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp}
      \tconnected_wifi: 1 @#{@timestamp}
      \tos_build: PQ2A.190405.003 @#{@timestamp}

      Reading data for phone#4c410523#20190502:
      Column Family cell_plan
      \tdata_plan_05gb: true @#{@timestamp}
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp}
      \tconnected_wifi: 1 @#{@timestamp}
      \tos_build: PQ2A.190405.004 @#{@timestamp}

      Reading data for phone#4c410523#20190505:
      Column Family cell_plan
      \tdata_plan_05gb: true @#{@timestamp}
      Column Family stats_summary
      \tconnected_cell: 0 @#{@timestamp}
      \tconnected_wifi: 1 @#{@timestamp}
      \tos_build: PQ2A.190406.000 @#{@timestamp}

      Reading data for phone#5c10102#20190501:
      Column Family cell_plan
      \tdata_plan_10gb: true @#{@timestamp}
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp}
      \tconnected_wifi: 1 @#{@timestamp}
      \tos_build: PQ2A.190401.002 @#{@timestamp}

      Reading data for phone#5c10102#20190502:
      Column Family cell_plan
      \tdata_plan_10gb: true @#{@timestamp}
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp}
      \tconnected_wifi: 0 @#{@timestamp}
      \tos_build: PQ2A.190406.000 @#{@timestamp}

    OUTPUT

    assert_match expected, out
  end

  it 'filter_modify_strip_value' do
    out, _err = capture_io do
      filter_modify_strip_value bigtable_instance_id, @table_id
    end
    expected = <<~OUTPUT
      Reading data for phone#4c410523#20190501:
      Column Family cell_plan
      \tdata_plan_01gb:  @#{@timestamp}
      \tdata_plan_01gb:  @#{@timestamp_minus_hr}
      \tdata_plan_05gb:  @#{@timestamp}
      Column Family stats_summary
      \tconnected_cell:  @#{@timestamp}
      \tconnected_wifi:  @#{@timestamp}
      \tos_build:  @#{@timestamp}

      Reading data for phone#4c410523#20190502:
      Column Family cell_plan
      \tdata_plan_05gb:  @#{@timestamp}
      Column Family stats_summary
      \tconnected_cell:  @#{@timestamp}
      \tconnected_wifi:  @#{@timestamp}
      \tos_build:  @#{@timestamp}

      Reading data for phone#4c410523#20190505:
      Column Family cell_plan
      \tdata_plan_05gb:  @#{@timestamp}
      Column Family stats_summary
      \tconnected_cell:  @#{@timestamp}
      \tconnected_wifi:  @#{@timestamp}
      \tos_build:  @#{@timestamp}

      Reading data for phone#5c10102#20190501:
      Column Family cell_plan
      \tdata_plan_10gb:  @#{@timestamp}
      Column Family stats_summary
      \tconnected_cell:  @#{@timestamp}
      \tconnected_wifi:  @#{@timestamp}
      \tos_build:  @#{@timestamp}

      Reading data for phone#5c10102#20190502:
      Column Family cell_plan
      \tdata_plan_10gb:  @#{@timestamp}
      Column Family stats_summary
      \tconnected_cell:  @#{@timestamp}
      \tconnected_wifi:  @#{@timestamp}
      \tos_build:  @#{@timestamp}

    OUTPUT

    assert_match expected, out
  end

  it 'filter_modify_apply_label' do
    out, _err = capture_io do
      filter_modify_apply_label bigtable_instance_id, @table_id
    end
    expected = <<~OUTPUT
      Reading data for phone#4c410523#20190501:
      Column Family cell_plan
      \tdata_plan_01gb: false @#{@timestamp} [labelled]
      \tdata_plan_01gb: true @#{@timestamp_minus_hr} [labelled]
      \tdata_plan_05gb: true @#{@timestamp} [labelled]
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp} [labelled]
      \tconnected_wifi: 1 @#{@timestamp} [labelled]
      \tos_build: PQ2A.190405.003 @#{@timestamp} [labelled]

      Reading data for phone#4c410523#20190502:
      Column Family cell_plan
      \tdata_plan_05gb: true @#{@timestamp} [labelled]
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp} [labelled]
      \tconnected_wifi: 1 @#{@timestamp} [labelled]
      \tos_build: PQ2A.190405.004 @#{@timestamp} [labelled]

      Reading data for phone#4c410523#20190505:
      Column Family cell_plan
      \tdata_plan_05gb: true @#{@timestamp} [labelled]
      Column Family stats_summary
      \tconnected_cell: 0 @#{@timestamp} [labelled]
      \tconnected_wifi: 1 @#{@timestamp} [labelled]
      \tos_build: PQ2A.190406.000 @#{@timestamp} [labelled]

      Reading data for phone#5c10102#20190501:
      Column Family cell_plan
      \tdata_plan_10gb: true @#{@timestamp} [labelled]
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp} [labelled]
      \tconnected_wifi: 1 @#{@timestamp} [labelled]
      \tos_build: PQ2A.190401.002 @#{@timestamp} [labelled]

      Reading data for phone#5c10102#20190502:
      Column Family cell_plan
      \tdata_plan_10gb: true @#{@timestamp} [labelled]
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp} [labelled]
      \tconnected_wifi: 0 @#{@timestamp} [labelled]
      \tos_build: PQ2A.190406.000 @#{@timestamp} [labelled]

    OUTPUT

    assert_match expected, out
  end

  it 'filter_composing_chain' do
    out, _err = capture_io do
      filter_composing_chain bigtable_instance_id, @table_id
    end
    expected = <<~OUTPUT
      Reading data for phone#4c410523#20190501:
      Column Family cell_plan
      \tdata_plan_01gb: false @#{@timestamp}
      \tdata_plan_05gb: true @#{@timestamp}

      Reading data for phone#4c410523#20190502:
      Column Family cell_plan
      \tdata_plan_05gb: true @#{@timestamp}

      Reading data for phone#4c410523#20190505:
      Column Family cell_plan
      \tdata_plan_05gb: true @#{@timestamp}

      Reading data for phone#5c10102#20190501:
      Column Family cell_plan
      \tdata_plan_10gb: true @#{@timestamp}

      Reading data for phone#5c10102#20190502:
      Column Family cell_plan
      \tdata_plan_10gb: true @#{@timestamp}
    OUTPUT
  end

  it 'filter_composing_interleave' do
    out, _err = capture_io do
      filter_composing_interleave bigtable_instance_id, @table_id
    end
    expected = <<~OUTPUT
      Reading data for phone#4c410523#20190501:
      Column Family cell_plan
      \tdata_plan_01gb: true @#{@timestamp_minus_hr}
      \tdata_plan_05gb: true @#{@timestamp}
      Column Family stats_summary
      \tos_build: PQ2A.190405.003 @#{@timestamp}

      Reading data for phone#4c410523#20190502:
      Column Family cell_plan
      \tdata_plan_05gb: true @#{@timestamp}
      Column Family stats_summary
      \tos_build: PQ2A.190405.004 @#{@timestamp}

      Reading data for phone#4c410523#20190505:
      Column Family cell_plan
      \tdata_plan_05gb: true @#{@timestamp}
      Column Family stats_summary
      \tos_build: PQ2A.190406.000 @#{@timestamp}

      Reading data for phone#5c10102#20190501:
      Column Family cell_plan
      \tdata_plan_10gb: true @#{@timestamp}
      Column Family stats_summary
      \tos_build: PQ2A.190401.002 @#{@timestamp}

      Reading data for phone#5c10102#20190502:
      Column Family cell_plan
      \tdata_plan_10gb: true @#{@timestamp}
      Column Family stats_summary
      \tos_build: PQ2A.190406.000 @#{@timestamp}

    OUTPUT

    assert_match expected, out
  end

  it 'filter_composing_condition' do
    out, _err = capture_io do
      filter_composing_condition bigtable_instance_id, @table_id
    end
    expected = <<~OUTPUT
      Reading data for phone#4c410523#20190501:
      Column Family cell_plan
      \tdata_plan_01gb: false @#{@timestamp} [filtered-out]
      \tdata_plan_01gb: true @#{@timestamp_minus_hr} [filtered-out]
      \tdata_plan_05gb: true @#{@timestamp} [filtered-out]
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp} [filtered-out]
      \tconnected_wifi: 1 @#{@timestamp} [filtered-out]
      \tos_build: PQ2A.190405.003 @#{@timestamp} [filtered-out]

      Reading data for phone#4c410523#20190502:
      Column Family cell_plan
      \tdata_plan_05gb: true @#{@timestamp} [filtered-out]
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp} [filtered-out]
      \tconnected_wifi: 1 @#{@timestamp} [filtered-out]
      \tos_build: PQ2A.190405.004 @#{@timestamp} [filtered-out]

      Reading data for phone#4c410523#20190505:
      Column Family cell_plan
      \tdata_plan_05gb: true @#{@timestamp} [filtered-out]
      Column Family stats_summary
      \tconnected_cell: 0 @#{@timestamp} [filtered-out]
      \tconnected_wifi: 1 @#{@timestamp} [filtered-out]
      \tos_build: PQ2A.190406.000 @#{@timestamp} [filtered-out]

      Reading data for phone#5c10102#20190501:
      Column Family cell_plan
      \tdata_plan_10gb: true @#{@timestamp} [passed-filter]
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp} [passed-filter]
      \tconnected_wifi: 1 @#{@timestamp} [passed-filter]
      \tos_build: PQ2A.190401.002 @#{@timestamp} [passed-filter]

      Reading data for phone#5c10102#20190502:
      Column Family cell_plan
      \tdata_plan_10gb: true @#{@timestamp} [passed-filter]
      Column Family stats_summary
      \tconnected_cell: 1 @#{@timestamp} [passed-filter]
      \tconnected_wifi: 0 @#{@timestamp} [passed-filter]
      \tos_build: PQ2A.190406.000 @#{@timestamp} [passed-filter]

    OUTPUT

    assert_match expected, out
  end
end

