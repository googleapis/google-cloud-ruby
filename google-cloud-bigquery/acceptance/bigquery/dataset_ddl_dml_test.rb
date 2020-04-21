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
  let(:table_id_2) { "dataset_ddl_table_#{SecureRandom.hex(16)}" }

  it "creates and populates and drops a table with ddl/dml query jobs" do
    create_job = dataset.query_job "CREATE TABLE #{table_id} (x INT64)"
    create_job.wait_until_done!
    _(create_job).wont_be :failed?

    _(create_job.statement_type).must_equal "CREATE_TABLE"
    _(create_job.ddl_operation_performed).must_equal "CREATE"
    assert_table_ref create_job.ddl_target_table, table_id
    _(create_job.num_dml_affected_rows).must_be :nil?

    insert_job = dataset.query_job "INSERT #{table_id} (x) VALUES(101),(102)"
    insert_job.wait_until_done!
    _(insert_job).wont_be :failed?
    _(insert_job.statement_type).must_equal "INSERT"
    _(insert_job.num_dml_affected_rows).must_equal 2

    update_job = dataset.query_job "UPDATE #{table_id} SET x = x + 1 WHERE x IS NOT NULL"
    update_job.wait_until_done!
    _(update_job).wont_be :failed?
    _(update_job.statement_type).must_equal "UPDATE"
    _(update_job.num_dml_affected_rows).must_equal 2

    delete_job = dataset.query_job "DELETE #{table_id} WHERE x = 103"
    delete_job.wait_until_done!
    _(delete_job).wont_be :failed?
    _(delete_job.statement_type).must_equal "DELETE"
    _(delete_job.num_dml_affected_rows).must_equal 1

    drop_job = dataset.query_job "DROP TABLE #{table_id}"
    drop_job.wait_until_done!
    _(drop_job).wont_be :failed?
    _(drop_job.statement_type).must_equal "DROP_TABLE"
    _(drop_job.ddl_operation_performed).must_equal "DROP"
    assert_table_ref drop_job.ddl_target_table, table_id, exists: false
    _(drop_job.num_dml_affected_rows).must_be :nil?
  end

  it "creates and populates and drops a table with ddl/dml queries" do
    create_data = dataset.query "CREATE TABLE #{table_id_2} (x INT64)"
    assert_table_ref create_data.ddl_target_table, table_id_2
    _(create_data.statement_type).must_equal "CREATE_TABLE"
    _(create_data.ddl?).must_equal true
    _(create_data.dml?).must_equal false
    _(create_data.ddl_operation_performed).must_equal "CREATE"
    _(create_data.num_dml_affected_rows).must_be :nil?
    _(create_data.total).must_be :nil?
    _(create_data.next?).must_equal false
    _(create_data.next).must_be :nil?
    _(create_data.all).must_be_kind_of Enumerator
    _(create_data.count).must_equal 0
    _(create_data.to_a).must_equal []

    insert_data = dataset.query "INSERT #{table_id_2} (x) VALUES(101),(102)"
    _(insert_data.ddl_target_table).must_be :nil?
    _(insert_data.statement_type).must_equal "INSERT"
    _(insert_data.ddl?).must_equal false
    _(insert_data.dml?).must_equal true
    _(insert_data.ddl_operation_performed).must_be :nil?
    _(insert_data.num_dml_affected_rows).must_equal 2
    _(insert_data.total).must_be :nil?
    _(insert_data.next?).must_equal false
    _(insert_data.next).must_be :nil?
    _(insert_data.all).must_be_kind_of Enumerator
    _(insert_data.count).must_equal 0
    _(insert_data.to_a).must_equal []

    update_data = dataset.query "UPDATE #{table_id_2} SET x = x + 1 WHERE x IS NOT NULL"
    _(update_data.statement_type).must_equal "UPDATE"
    _(update_data.num_dml_affected_rows).must_equal 2

    delete_data = dataset.query "DELETE #{table_id_2} WHERE x = 103"
    _(delete_data.statement_type).must_equal "DELETE"
    _(delete_data.num_dml_affected_rows).must_equal 1

    drop_data = dataset.query "DROP TABLE #{table_id_2}"
    _(drop_data.statement_type).must_equal "DROP_TABLE"
    _(drop_data.ddl_operation_performed).must_equal "DROP"
    _(drop_data.num_dml_affected_rows).must_be :nil?
    assert_table_ref drop_data.ddl_target_table, table_id_2, exists: false
  end

  def assert_table_ref table_ref, table_id, exists: true
    _(table_ref).must_be_kind_of Google::Cloud::Bigquery::Table
    _(table_ref.project_id).must_equal bigquery.project
    _(table_ref.dataset_id).must_equal dataset_id
    _(table_ref.table_id).must_equal table_id
    _(table_ref.reference?).must_equal true
    _(table_ref.exists?).must_equal exists
  end
end
