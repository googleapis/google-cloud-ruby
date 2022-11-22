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
    assert_table_ref create_job.ddl_target_table, dataset_id, table_id
    _(create_job.num_dml_affected_rows).must_be :nil?
    _(create_job.deleted_row_count).must_be :nil?
    _(create_job.inserted_row_count).must_be :nil?
    _(create_job.updated_row_count).must_be :nil?

    alter_job = dataset.query_job "ALTER TABLE #{table_id} ADD COLUMN y STRING"
    alter_job.wait_until_done!
    _(alter_job).wont_be :failed?
    _(alter_job.statement_type).must_equal "ALTER_TABLE"
    # _(alter_job.ddl_operation_performed).must_equal "ALTER" # Fails with nil value. See https://github.com/googleapis/google-cloud-ruby/issues/16097#issuecomment-983961475
    assert_table_ref alter_job.ddl_target_table, dataset_id, table_id
    _(alter_job.num_dml_affected_rows).must_be :nil?
    _(alter_job.deleted_row_count).must_be :nil?
    _(alter_job.inserted_row_count).must_be :nil?
    _(alter_job.updated_row_count).must_be :nil?

    insert_job = dataset.query_job "INSERT #{table_id} (x) VALUES(101),(102)"
    insert_job.wait_until_done!
    _(insert_job).wont_be :failed?
    _(insert_job.statement_type).must_equal "INSERT"
    _(insert_job.num_dml_affected_rows).must_equal 2
    _(insert_job.deleted_row_count).must_be :nil?
    _(insert_job.inserted_row_count).must_equal 2
    _(insert_job.updated_row_count).must_be :nil?

    update_job = dataset.query_job "UPDATE #{table_id} SET x = x + 1 WHERE x IS NOT NULL"
    update_job.wait_until_done!
    _(update_job).wont_be :failed?
    _(update_job.statement_type).must_equal "UPDATE"
    _(update_job.num_dml_affected_rows).must_equal 2
    _(update_job.deleted_row_count).must_be :nil?
    _(update_job.inserted_row_count).must_be :nil?
    _(update_job.updated_row_count).must_equal 2

    delete_job = dataset.query_job "DELETE #{table_id} WHERE x = 103"
    delete_job.wait_until_done!
    _(delete_job).wont_be :failed?
    _(delete_job.statement_type).must_equal "DELETE"
    _(delete_job.num_dml_affected_rows).must_equal 1
    _(delete_job.deleted_row_count).must_equal 1
    _(delete_job.inserted_row_count).must_be :nil?
    _(delete_job.updated_row_count).must_be :nil?

    truncate_job = dataset.query_job "TRUNCATE TABLE #{table_id}"
    truncate_job.wait_until_done!
    _(truncate_job).wont_be :failed?
    _(truncate_job.statement_type).must_equal "TRUNCATE_TABLE"
    _(truncate_job.num_dml_affected_rows).must_equal 1
    _(truncate_job.deleted_row_count).must_equal 1
    _(truncate_job.inserted_row_count).must_be :nil?
    _(truncate_job.updated_row_count).must_be :nil?

    drop_job = dataset.query_job "DROP TABLE #{table_id}"
    drop_job.wait_until_done!
    _(drop_job).wont_be :failed?
    _(drop_job.statement_type).must_equal "DROP_TABLE"
    _(drop_job.ddl_operation_performed).must_equal "DROP"
    assert_table_ref drop_job.ddl_target_table, dataset_id, table_id, exists: false
    _(drop_job.num_dml_affected_rows).must_be :nil?
    _(drop_job.deleted_row_count).must_be :nil?
    _(drop_job.inserted_row_count).must_be :nil?
    _(drop_job.updated_row_count).must_be :nil?
  end

  it "creates and populates and drops a table with ddl/dml queries" do
    create_data = dataset.query "CREATE TABLE #{table_id_2} (x INT64)"
    assert_table_ref create_data.ddl_target_table, dataset_id, table_id_2
    _(create_data.statement_type).must_equal "CREATE_TABLE"
    _(create_data.ddl?).must_equal true
    _(create_data.dml?).must_equal false
    _(create_data.ddl_operation_performed).must_equal "CREATE"
    _(create_data.num_dml_affected_rows).must_be :nil?
    _(create_data.deleted_row_count).must_be :nil?
    _(create_data.inserted_row_count).must_be :nil?
    _(create_data.updated_row_count).must_be :nil?
    _(create_data.total).must_be :nil?
    _(create_data.next?).must_equal false
    _(create_data.next).must_be :nil?
    _(create_data.all).must_be_kind_of Enumerator
    _(create_data.count).must_equal 0
    _(create_data.to_a).must_equal []

    alter_data = dataset.query "ALTER TABLE #{table_id_2} ADD COLUMN y STRING"
    assert_table_ref alter_data.ddl_target_table, dataset_id, table_id_2
    _(alter_data.statement_type).must_equal "ALTER_TABLE"
    if false # Alter data has incorrect info; see https://github.com/googleapis/google-cloud-ruby/issues/16097
      _(alter_data.ddl?).must_equal true
      _(alter_data.dml?).must_equal false
      _(alter_data.ddl_operation_performed).must_equal "ALTER"
      _(alter_data.num_dml_affected_rows).must_be :nil?
      _(alter_data.deleted_row_count).must_be :nil?
      _(alter_data.inserted_row_count).must_be :nil?
      _(alter_data.updated_row_count).must_be :nil?
      _(alter_data.total).must_equal 0
      _(alter_data.next?).must_equal false
      _(alter_data.next).must_be :nil?
      _(alter_data.all).must_be_kind_of Enumerator
      _(alter_data.count).must_equal 0
      _(alter_data.to_a).must_equal []
    end

    insert_data = dataset.query "INSERT #{table_id_2} (x) VALUES(101),(102)"
    _(insert_data.ddl_target_table).must_be :nil?
    _(insert_data.statement_type).must_equal "INSERT"
    _(insert_data.ddl?).must_equal false
    _(insert_data.dml?).must_equal true
    _(insert_data.ddl_operation_performed).must_be :nil?
    _(insert_data.num_dml_affected_rows).must_equal 2
    _(insert_data.deleted_row_count).must_be :nil?
    _(insert_data.inserted_row_count).must_equal 2
    _(insert_data.updated_row_count).must_be :nil?
    _(insert_data.total).must_be :nil?
    _(insert_data.next?).must_equal false
    _(insert_data.next).must_be :nil?
    _(insert_data.all).must_be_kind_of Enumerator
    _(insert_data.count).must_equal 0
    _(insert_data.to_a).must_equal []

    update_data = dataset.query "UPDATE #{table_id_2} SET x = x + 1 WHERE x IS NOT NULL"
    _(update_data.statement_type).must_equal "UPDATE"
    _(update_data.num_dml_affected_rows).must_equal 2
    _(update_data.deleted_row_count).must_be :nil?
    _(update_data.inserted_row_count).must_be :nil?
    _(update_data.updated_row_count).must_equal 2

    delete_data = dataset.query "DELETE #{table_id_2} WHERE x = 103"
    _(delete_data.statement_type).must_equal "DELETE"
    _(delete_data.num_dml_affected_rows).must_equal 1
    _(delete_data.deleted_row_count).must_equal 1
    _(delete_data.inserted_row_count).must_be :nil?
    _(delete_data.updated_row_count).must_be :nil?

    truncate_data = dataset.query "TRUNCATE TABLE #{table_id_2}"
    _(truncate_data.statement_type).must_equal "TRUNCATE_TABLE"
    _(truncate_data.num_dml_affected_rows).must_equal 1
    _(truncate_data.deleted_row_count).must_equal 1
    _(truncate_data.inserted_row_count).must_be :nil?
    _(truncate_data.updated_row_count).must_be :nil?

    drop_data = dataset.query "DROP TABLE #{table_id_2}"
    _(drop_data.statement_type).must_equal "DROP_TABLE"
    _(drop_data.ddl_operation_performed).must_equal "DROP"
    _(drop_data.num_dml_affected_rows).must_be :nil?
    _(drop_data.deleted_row_count).must_be :nil?
    _(drop_data.inserted_row_count).must_be :nil?
    _(drop_data.updated_row_count).must_be :nil?
    assert_table_ref drop_data.ddl_target_table, dataset_id, table_id_2, exists: false
  end
end
