# Copyright 2021 Google LLC
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

require "bigquery_helper"

describe Google::Cloud::Bigquery::Table, :materialized_view, :bigquery do
  let(:dataset_id) { "#{prefix}_dataset" }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      d = bigquery.create_dataset dataset_id
    end
    d
  end
  let(:table_id) { "materialized_view_source_table_#{SecureRandom.hex(16)}" }
  let(:create_table_query) do
    <<~SQL
      CREATE TABLE #{dataset_id}.#{table_id}
        (
          sample_value INT64,
          groupid STRING,
        )
      AS
      SELECT
        CAST(RAND() * 100 AS INT64),
        CONCAT("group", CAST(CAST(RAND()*10 AS INT64) AS STRING))
      FROM
        UNNEST(GENERATE_ARRAY(0,999))
    SQL
  end
  let(:sum_query) do
    <<~SQL
      SELECT
        SUM(sample_value) as total,
        groupid
      FROM
      #{dataset_id}.#{table_id}
      GROUP BY
        groupid
    SQL
  end
  let(:sum_query_2) do
    <<~SQL
      SELECT
        SUM(sample_value) as total,
        groupid
      FROM
      #{dataset_id}.#{table_id}
      GROUP BY
        groupid
      LIMIT 5
    SQL
  end
  let(:materialized_view_id) { "materialized_view_#{SecureRandom.hex(16)}" }

  it "creates, gets, updates and deletes a materialized view" do
    create_job = dataset.query_job create_table_query
    create_job.wait_until_done!
    _(create_job).wont_be :failed?
    assert_table_ref create_job.ddl_target_table, dataset_id, table_id

    # create
    materialized_view = dataset.create_materialized_view materialized_view_id,
                                                         sum_query,
                                                         enable_refresh: false,
                                                         refresh_interval_ms: 3_600_000

    _(materialized_view).must_be_kind_of  Google::Cloud::Bigquery::Table
    _(materialized_view.id).must_equal "#{bigquery.project}:#{dataset.dataset_id}.#{materialized_view.table_id}"

    # get
    materialized_view = dataset.table materialized_view.table_id
    _(materialized_view).must_be_kind_of  Google::Cloud::Bigquery::Table

    _(materialized_view.project_id).must_equal bigquery.project
    _(materialized_view.id).must_equal "#{bigquery.project}:#{dataset.dataset_id}.#{materialized_view.table_id}"
    _(materialized_view.query_id).must_equal "`#{bigquery.project}.#{dataset.dataset_id}.#{materialized_view.table_id}`"
    _(materialized_view.etag).wont_be :nil?
    _(materialized_view.api_url).wont_be :nil?
    _(materialized_view.query_id).must_equal materialized_view.query_id
    _(materialized_view.created_at).must_be_kind_of Time
    _(materialized_view.expires_at).must_be :nil?
    _(materialized_view.modified_at).must_be_kind_of Time
    _(materialized_view.table?).must_equal false
    _(materialized_view.view?).must_equal false

    _(materialized_view.materialized_view?).must_equal true
    _(materialized_view.enable_refresh?).must_equal false
    _(materialized_view.last_refresh_time).must_be :nil?
    _(materialized_view.query).must_equal sum_query
    _(materialized_view.refresh_interval_ms).must_equal 3_600_000
    
    # update

    materialized_view.enable_refresh = true

    materialized_view.reload!
    _(materialized_view.table_id).must_equal materialized_view_id
    _(materialized_view.enable_refresh?).must_equal true

    materialized_view.refresh_interval_ms = 1_800_000

    materialized_view.reload!
    _(materialized_view.refresh_interval_ms).must_equal 1_800_000

    # delete
    materialized_view.delete
  end
end
