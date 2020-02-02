# Copyright 2020 Google LLC
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

describe Google::Cloud::Bigquery, :bigquery do
  let(:dataset_id) { "#{prefix}_dataset" }
  let(:dataset) do
    d = bigquery.dataset dataset_id
    if d.nil?
      d = bigquery.create_dataset dataset_id
    end
    d
  end
  let(:routine_id) { "routine_#{SecureRandom.hex(4)}" }
  let :routine_sql do
    routine_sql = <<-MODEL_SQL
    CREATE FUNCTION `#{routine_id}`(
        arr ARRAY<STRUCT<name STRING, val INT64>>
    ) AS (
        (SELECT SUM(IF(elem.name = "foo",elem.val,null)) FROM UNNEST(arr) AS elem)
    )
    MODEL_SQL
  end
  focus
  it "can create from SQL, list, read, update, and delete a routine" do
    job = dataset.query_job routine_sql
    job.wait_until_done!
    job.wont_be :failed?

    # can find the routine in the list of routines
    dataset.routines.all.map(&:routine_id).must_include routine_id

    # can get the routine
    routine = dataset.routine routine_id
    routine.must_be_kind_of Google::Cloud::Bigquery::Routine
    routine.project_id.must_equal bigquery.project
    routine.dataset_id.must_equal dataset.dataset_id
    routine.routine_id.must_equal routine_id

    routine.description.must_be :nil?
    routine.type.must_equal "SCALAR_FUNCTION"
    routine.language.must_equal "SQL"
    routine.body.must_equal "(SELECT SUM(IF(elem.name = \"foo\",elem.val,null)) FROM UNNEST(arr) AS elem)"

    arguments = routine.arguments
    arguments.must_be_kind_of Array
    arguments.size.must_equal 1

    argument = arguments.first
    argument.must_be_kind_of Google::Cloud::Bigquery::Argument
    argument.argument_kind.must_be :nil?
    argument.mode.must_be :nil?
    argument.name.must_equal "arr"

    data_type = argument.data_type
    data_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    data_type.type_kind.must_equal "ARRAY"
    data_type.struct_type.must_be :nil?
    data_type.array_element_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    data_type.array_element_type.type_kind.must_equal "STRUCT"
    data_type.array_element_type.struct_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::StructType

    struct_fields = data_type.array_element_type.struct_type.fields
    struct_fields.must_be_kind_of Array
    struct_fields.size.must_equal 2
    struct_fields[0].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    struct_fields[0].name.must_equal "name"
    struct_fields[0].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    struct_fields[0].type.type_kind.must_equal "STRING"
    struct_fields[1].must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    struct_fields[1].name.must_equal "val"
    struct_fields[1].type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    struct_fields[1].type.type_kind.must_equal "INT64"

    new_description = "Routine was updated #{Time.now}"
    routine.description = new_description
    routine.refresh!
    routine.description.must_equal new_description

    routine.delete.must_equal true

    dataset.routine(routine_id).must_be_nil
  end
  focus
  it "can create and delete a routine" do
    routine = dataset.create_routine routine_id do |r|
      r.description = "my description"
      r.type = "SCALAR_FUNCTION"
      r.language = :SQL
      r.body = "x * 3"
      r.arguments = [
        Google::Cloud::Bigquery::Argument.new(data_type: :INT64, name: "x")
      ]
    end

    routine.must_be_kind_of Google::Cloud::Bigquery::Routine
    routine.project_id.must_equal bigquery.project
    routine.dataset_id.must_equal dataset.dataset_id
    routine.routine_id.must_equal routine_id

    routine.description.must_equal "my description"
    routine.type.must_equal "SCALAR_FUNCTION"
    routine.language.must_equal "SQL"
    routine.body.must_equal "x * 3"

    arguments = routine.arguments
    arguments.must_be_kind_of Array
    arguments.size.must_equal 1

    argument = arguments.first
    argument.must_be_kind_of Google::Cloud::Bigquery::Argument
    argument.argument_kind.must_be :nil?
    argument.mode.must_be :nil?
    argument.name.must_equal "x"

    data_type = argument.data_type
    data_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    data_type.type_kind.must_equal "INT64"
    data_type.array_element_type.must_be :nil?
    data_type.struct_type.must_be :nil?

    routine.delete.must_equal true

    dataset.routine(routine_id).must_be_nil
  end
end
