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

require "bigquery_helper"

describe Google::Cloud::Bigquery::Dataset, :ddl_dml, :bigquery do
  let(:dataset_id) { "#{prefix}_dataset" }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      d = bigquery.create_dataset dataset_id
    end
    d
  end
  let(:table_id) { "dataset_ddl_table_#{SecureRandom.hex(16)}" }

  it "creates and drops a table with ddl stats" do
    create_job = dataset.query_job "CREATE TABLE #{table_id} (x INT64)"
    create_job.wait_until_done!
    create_job.wont_be :failed?

    create_job.statement_type.must_equal "CREATE_TABLE"
    create_job.ddl_operation_performed.must_equal "CREATE"
    table_ref = create_job.ddl_target_table
    table_ref.must_be_kind_of Google::Cloud::Bigquery::Table
    table_ref.project_id.must_equal bigquery.project
    table_ref.dataset_id.must_equal dataset_id
    table_ref.table_id.must_equal table_id
    table_ref.reference?.must_equal true
    table_ref.exists?.must_equal true
    create_job.num_dml_affected_rows.must_be :nil?

    insert_job = dataset.query_job "INSERT #{table_id} (x) VALUES(101),(102)"
    insert_job.wait_until_done!
    insert_job.wont_be :failed?
    insert_job.statement_type.must_equal "INSERT"
    insert_job.num_dml_affected_rows.must_equal 2

    update_job = dataset.query_job "UPDATE #{table_id} SET x = x + 1 WHERE x IS NOT NULL"
    update_job.wait_until_done!
    update_job.wont_be :failed?
    update_job.statement_type.must_equal "UPDATE"
    update_job.num_dml_affected_rows.must_equal 2

    delete_job = dataset.query_job "DELETE #{table_id} WHERE x = 103"
    delete_job.wait_until_done!
    delete_job.wont_be :failed?
    delete_job.statement_type.must_equal "DELETE"
    delete_job.num_dml_affected_rows.must_equal 1

    drop_job = dataset.query_job "DROP TABLE #{table_id}"
    drop_job.wait_until_done!
    drop_job.wont_be :failed?
    drop_job.statement_type.must_equal "DROP_TABLE"
    drop_job.ddl_operation_performed.must_equal "DROP"
    table_ref_2 = create_job.ddl_target_table
    table_ref_2.must_be_kind_of Google::Cloud::Bigquery::Table
    table_ref_2.project_id.must_equal bigquery.project
    table_ref_2.dataset_id.must_equal dataset_id
    table_ref_2.table_id.must_equal table_id
    table_ref_2.reference?.must_equal true
    table_ref_2.exists?.must_equal false
    drop_job.num_dml_affected_rows.must_be :nil?
  end
end
