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
    routine_sql = <<~SQL
    CREATE FUNCTION `#{routine_id}`(
        arr ARRAY<STRUCT<name STRING, val INT64>>
    ) AS (
        (SELECT SUM(IF(elem.name = "foo",elem.val,null)) FROM UNNEST(arr) AS elem)
    )
    SQL
  end

  it "can create from SQL, list, read, update, and delete an SQL routine" do
    # create from sql
    job = dataset.query_job routine_sql
    job.wait_until_done!
    _(job).wont_be :failed?
    _(job.ddl_operation_performed).must_equal "CREATE"
    routine = job.ddl_target_routine
    _(routine).must_be_kind_of Google::Cloud::Bigquery::Routine
    _(routine.reference?).must_equal true
    _(routine.project_id).must_equal bigquery.project
    _(routine.dataset_id).must_equal dataset.dataset_id
    _(routine.routine_id).must_equal routine_id

    # list
    _(dataset.routines.all.map(&:routine_id)).must_include routine_id

    # list with filter
    _(dataset.routines(filter: "routineType:SCALAR_FUNCTION").all.map(&:routine_id)).must_include routine_id

    # list with filter
    _(dataset.routines(filter: "routineType:PROCEDURE").all.map(&:routine_id)).wont_include routine_id

    # get
    routine = dataset.routine routine_id
    _(routine).must_be_kind_of Google::Cloud::Bigquery::Routine
    _(routine.project_id).must_equal bigquery.project
    _(routine.dataset_id).must_equal dataset.dataset_id
    _(routine.routine_id).must_equal routine_id

    _(routine.description).must_be :nil?
    _(routine.routine_type).must_equal "SCALAR_FUNCTION"
    _(routine.language).must_equal "SQL"
    _(routine.body).must_equal "(SELECT SUM(IF(elem.name = \"foo\",elem.val,null)) FROM UNNEST(arr) AS elem)"

    arguments = routine.arguments
    _(arguments).must_be_kind_of Array
    _(arguments.size).must_equal 1

    argument = arguments.first
    _(argument).must_be_kind_of Google::Cloud::Bigquery::Argument
    _(argument.argument_kind).must_be :nil?
    _(argument.fixed_type?).must_equal true
    _(argument.any_type?).must_equal false
    _(argument.mode).must_be :nil?
    _(argument.in?).must_equal false
    _(argument.out?).must_equal false
    _(argument.inout?).must_equal false
    _(argument.name).must_equal "arr"

    data_type = argument.data_type
    _(data_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(data_type.type_kind).must_equal "ARRAY"
    _(data_type.struct_type).must_be :nil?
    _(data_type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(data_type.array_element_type.type_kind).must_equal "STRUCT"
    _(data_type.array_element_type.struct_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::StructType

    struct_fields = data_type.array_element_type.struct_type.fields
    _(struct_fields).must_be_kind_of Array
    _(struct_fields.size).must_equal 2
    _(struct_fields[0]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(struct_fields[0].name).must_equal "name"
    _(struct_fields[0].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(struct_fields[0].type.type_kind).must_equal "STRING"
    _(struct_fields[1]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(struct_fields[1].name).must_equal "val"
    _(struct_fields[1].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(struct_fields[1].type.type_kind).must_equal "INT64"

    # update
    new_description = "Routine was updated #{Time.now}"
    routine.description = new_description
    routine.refresh!
    _(routine.description).must_equal new_description

    # delete
    _(routine.delete).must_equal true

    _(dataset.routine(routine_id)).must_be_nil
  end

  it "can create, update and delete an SQL routine" do
    # create
    routine = dataset.create_routine routine_id do |r|
      r.routine_type = "SCALAR_FUNCTION"
      r.language = :SQL
      r.arguments = [
        Google::Cloud::Bigquery::Argument.new(name: "x", data_type: "INT64")
      ]
      r.body = "x * 3"
      r.description = "my description"
    end

    _(routine).must_be_kind_of Google::Cloud::Bigquery::Routine
    _(routine.project_id).must_equal bigquery.project
    _(routine.dataset_id).must_equal dataset.dataset_id
    _(routine.routine_id).must_equal routine_id

    _(routine.routine_type).must_equal "SCALAR_FUNCTION"
    _(routine.language).must_equal "SQL"
    _(routine.body).must_equal "x * 3"
    _(routine.description).must_equal "my description"

    arguments = routine.arguments
    _(arguments).must_be_kind_of Array
    _(arguments.size).must_equal 1

    argument = arguments.first
    _(argument).must_be_kind_of Google::Cloud::Bigquery::Argument
    _(argument.argument_kind).must_be :nil?
    _(argument.mode).must_be :nil?
    _(argument.name).must_equal "x"

    data_type = argument.data_type
    _(data_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(data_type.type_kind).must_equal "INT64"
    _(data_type.array_element_type).must_be :nil?
    _(data_type.struct_type).must_be :nil?
 
    # update 
    new_body = "(SELECT SUM(IF(elem.name = \"foo\",elem.val,null)) FROM UNNEST(arr) AS elem)"
    new_arguments = [
      Google::Cloud::Bigquery::Argument.new(
        name: "arr",
        argument_kind: "FIXED_TYPE",
        data_type: Google::Cloud::Bigquery::StandardSql::DataType.new(
          type_kind: "ARRAY",
          array_element_type: Google::Cloud::Bigquery::StandardSql::DataType.new(
            type_kind: "STRUCT",
            struct_type: Google::Cloud::Bigquery::StandardSql::StructType.new(
              fields: [
                Google::Cloud::Bigquery::StandardSql::Field.new(
                  name: "name",
                  type: Google::Cloud::Bigquery::StandardSql::DataType.new(type_kind: "STRING")
                ),
                Google::Cloud::Bigquery::StandardSql::Field.new(
                  name: "val",
                  type: Google::Cloud::Bigquery::StandardSql::DataType.new(type_kind: "INT64")
                )
              ]
            )
          )
        )
      )
    ]

    routine.update do |r|
      r.body = new_body
      r.arguments = new_arguments
    end

    _(routine.body).must_equal new_body

    arguments = routine.arguments
    _(arguments).must_be_kind_of Array
    _(arguments.size).must_equal 1

    argument = arguments.first
    _(argument).must_be_kind_of Google::Cloud::Bigquery::Argument
    _(argument.argument_kind).must_equal "FIXED_TYPE"
    _(argument.mode).must_be :nil?
    _(argument.name).must_equal "arr"

    data_type = argument.data_type
    _(data_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(data_type.type_kind).must_equal "ARRAY"
    _(data_type.struct_type).must_be :nil?
    _(data_type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(data_type.array_element_type.type_kind).must_equal "STRUCT"
    _(data_type.array_element_type.struct_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::StructType

    struct_fields = data_type.array_element_type.struct_type.fields
    _(struct_fields).must_be_kind_of Array
    _(struct_fields.size).must_equal 2
    _(struct_fields[0]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(struct_fields[0].name).must_equal "name"
    _(struct_fields[0].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(struct_fields[0].type.type_kind).must_equal "STRING"
    _(struct_fields[1]).must_be_kind_of Google::Cloud::Bigquery::StandardSql::Field
    _(struct_fields[1].name).must_equal "val"
    _(struct_fields[1].type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(struct_fields[1].type.type_kind).must_equal "INT64"

    # get
    routine.reload!
    _(routine.body).must_equal new_body
    _(routine.arguments.first.data_type.array_element_type.struct_type.fields.last.type.type_kind).must_equal "INT64"

    # delete
    _(routine.delete).must_equal true

    _(dataset.routine(routine_id)).must_be_nil
  end

  it "can create and delete a JavaScript routine" do
    # create
    routine = dataset.create_routine routine_id do |r|
      r.routine_type = "SCALAR_FUNCTION"
      r.language = :JAVASCRIPT
      r.arguments = [
        Google::Cloud::Bigquery::Argument.new(name: "x", data_type: "INT64")
      ]
      r.body = "return x * 3;"
      r.return_type = "INT64"
      r.description = "my description"
      r.determinism_level = "DETERMINISTIC"
    end

    _(routine).must_be_kind_of Google::Cloud::Bigquery::Routine
    _(routine.project_id).must_equal bigquery.project
    _(routine.dataset_id).must_equal dataset.dataset_id
    _(routine.routine_id).must_equal routine_id

    _(routine.routine_type).must_equal "SCALAR_FUNCTION"
    _(routine.language).must_equal "JAVASCRIPT"
    _(routine.body).must_equal "return x * 3;"
    _(routine.description).must_equal "my description"
    _(routine.determinism_level).must_equal "DETERMINISTIC"
    _(routine.determinism_level_deterministic?).must_equal true
    _(routine.determinism_level_not_deterministic?).must_equal false

    arguments = routine.arguments
    _(arguments).must_be_kind_of Array
    _(arguments.size).must_equal 1

    argument = arguments.first
    _(argument).must_be_kind_of Google::Cloud::Bigquery::Argument
    _(argument.argument_kind).must_be :nil?
    _(argument.mode).must_be :nil?
    _(argument.name).must_equal "x"

    data_type = argument.data_type
    _(data_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(data_type.type_kind).must_equal "INT64"
    _(data_type.array_element_type).must_be :nil?
    _(data_type.struct_type).must_be :nil?

    # delete
    _(routine.delete).must_equal true

    _(dataset.routine(routine_id)).must_be_nil
  end
end
