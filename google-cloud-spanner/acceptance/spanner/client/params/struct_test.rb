# Copyright 2017 Google LLC
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

require "spanner_helper"

describe "Spanner Client", :params, :struct, :spanner do
  let(:db) { spanner_client }

  describe "Struct Parameters Query Examples" do
    # Simple field access.
    # [parameters=STRUCT<threadf INT64, userf STRING>(1,"bob") AS struct_param, 10 as p4]
    # SELECT @struct_param.userf, @p4;
    it "Simple field access" do
      results = db.execute "SELECT @struct_param.userf, @p4",
                           params: { struct_param: { threadf: 1, userf: "bob" }, p4: 10 }

      results.must_be_kind_of Google::Cloud::Spanner::Results
      results.fields.to_h.must_equal({ userf: :STRING, 1 => :INT64 })
      results.rows.first.to_h.must_equal({ userf: "bob", 1 => 10 })
    end

    # # Simple field access on NULL struct value.
    # [parameters=CAST(NULL AS STRUCT<threadf INT64, userf STRING>) AS struct_param]
    # SELECT @struct_param.userf;
    it "Simple field access on NULL struct value" do
      struct_type = db.fields(threadf: :INT64, userf: :STRING)
      results = db.execute "SELECT @struct_param.userf",
                           params: { struct_param: nil },
                           types:  { struct_param: struct_type }

      results.must_be_kind_of Google::Cloud::Spanner::Results
      results.fields.to_h.must_equal({ userf: :STRING })
      results.rows.first.to_h.must_equal({ userf: nil })
    end

    # # Nested struct field access.
    # [parameters=STRUCT<structf STRUCT<nestedf STRING>> (STRUCT<nestedf STRING>("bob")) AS struct_param]
    # SELECT @struct_param.structf.nestedf;
    it "Nested struct field access" do
      results = db.execute "SELECT @struct_param.structf.nestedf",
                           params: { struct_param: { structf: { nestedf: "bob" } } }

      results.must_be_kind_of Google::Cloud::Spanner::Results
      results.fields.to_h.must_equal({ nestedf: :STRING })
      results.rows.first.to_h.must_equal({ nestedf: "bob" })
    end

    # # Nested struct field access on NULL struct value.
    # [parameters=CAST(STRUCT(null) AS STRUCT<structf STRUCT<nestedf STRING>>) AS  struct_param]
    # SELECT @struct_param.structf.nestedf;
    it "Nested struct field access on NULL struct value" do
      struct_type = db.fields(structf: db.fields(nestedf: :STRING))
      results = db.execute "SELECT @struct_param.structf.nestedf",
                           params: { struct_param: nil },
                           types:  { struct_param: struct_type }

      results.must_be_kind_of Google::Cloud::Spanner::Results
      results.fields.to_h.must_equal({ nestedf: :STRING })
      results.rows.first.to_h.must_equal({ nestedf: nil })
    end

    # # Non-NULL struct with no fields (empty struct).
    # [parameters=CAST(STRUCT() AS STRUCT<>) AS struct_param]
    # SELECT @struct_param IS NULL;
    it "Non-NULL struct with no fields (empty struct)" do
      results = db.execute "SELECT @struct_param IS NULL",
                           params: { struct_param: {} }

      results.must_be_kind_of Google::Cloud::Spanner::Results
      results.fields.to_h.must_equal({ 0 => :BOOL })
      results.rows.first.to_h.must_equal({ 0 => false })
    end

    # # NULL struct with no fields.
    # [parameters=CAST(NULL AS STRUCT<>) AS struct_param]
    # SELECT @struct_param IS NULL
    it "NULL struct with no fields" do
      struct_type = db.fields({})
      results = db.execute "SELECT @struct_param IS NULL",
                           params: { struct_param: nil },
                           types:  { struct_param: struct_type }

      results.must_be_kind_of Google::Cloud::Spanner::Results
      results.fields.to_h.must_equal({ 0 => :BOOL })
      results.rows.first.to_h.must_equal({ 0 => true })
    end

    # # Struct with single NULL field.
    # [parameters=STRUCT<f1 INT64>(NULL) AS struct_param]
    # SELECT @struct_param.f1;
    it "Struct with single NULL field" do
      struct_type = db.fields(f1: :INT64)
      results = db.execute "SELECT @struct_param.f1",
                           params: { struct_param: { f1: nil } },
                           types:  { struct_param: struct_type }

      results.must_be_kind_of Google::Cloud::Spanner::Results
      results.fields.to_h.must_equal({ f1: :INT64 })
      results.rows.first.to_h.must_equal({ f1: nil })
    end

    # # Equality check.
    # [parameters=STRUCT<threadf INT64, userf STRING>(1,"bob") AS struct_param]
    # SELECT @struct_param=STRUCT<threadf INT64, userf STRING>(1,"bob");
    it "Equality check" do
      struct_value = db.fields(threadf: :INT64, userf: :STRING).struct([1, "bob"])
      results = db.execute "SELECT @struct_param=STRUCT<threadf INT64, userf STRING>(1,\"bob\")",
                           params: { struct_param: struct_value }

      results.must_be_kind_of Google::Cloud::Spanner::Results
      results.fields.to_h.must_equal({ 0 => :BOOL })
      results.rows.first.to_h.must_equal({ 0 => true })
    end

    # # Nullness check.
    # [parameters=ARRAY<STRUCT<threadf INT64, userf STRING>> [(1,"bob")] AS struct_arr_param]
    # SELECT @struct_arr_param IS NULL;
    it "Nullness check" do
      struct_value = db.fields(threadf: :INT64, userf: :STRING).struct([1, "bob"])
      results = db.execute "SELECT @struct_arr_param IS NULL",
                           params: { struct_arr_param: [struct_value] }
                           # params: { struct_arr_param: [{ threadf: 1, userf: "bob" }] }

      results.must_be_kind_of Google::Cloud::Spanner::Results
      results.fields.to_h.must_equal({ 0 => :BOOL })
      results.rows.first.to_h.must_equal({ 0 => false })
    end

    # # Null array of struct field.
    # [parameters=STRUCT<intf INT64, arraysf ARRAY<STRUCT<threadid INT64>>> (10,CAST(NULL AS ARRAY<STRUCT<threadid INT64>>)) AS struct_param]
    # SELECT a.threadid FROM UNNEST(@struct_param.arraysf) a;
    it "Null array of struct field" do
      struct_value = db.fields(intf: :INT64, arraysf: [db.fields(threadid: :INT64)]).struct([10, nil])
      results = db.execute "SELECT a.threadid FROM UNNEST(@struct_param.arraysf) a",
                           params: { struct_param: struct_value }

      results.must_be_kind_of Google::Cloud::Spanner::Results
      results.fields.to_h.must_equal({ threadid: :INT64 })
      results.rows.count.must_equal 0
    end

    # # Null array of struct.
    # [parameters=CAST(NULL AS ARRAY<STRUCT<threadid INT64>>) as struct_arr_param]
    # SELECT a.threadid FROM UNNEST(@struct_arr_param) a;
    it "Null array of struct" do
      struct_type = db.fields(threadid: :INT64)
      results = db.execute "SELECT a.threadid FROM UNNEST(@struct_arr_param) a",
                           params: { struct_arr_param: nil },
                           types:  { struct_arr_param: [struct_type] }

      results.must_be_kind_of Google::Cloud::Spanner::Results
      results.fields.to_h.must_equal({ threadid: :INT64 })
      results.rows.count.must_equal 0
    end
  end

  it "queries and returns a struct parameter" do
    results = db.execute "SELECT ARRAY(SELECT AS STRUCT message, repeat FROM (SELECT @value.message AS message, @value.repeat AS repeat)) AS value", params: { value: { message: "hello", repeat: 1 } }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ value: [db.fields(message: :STRING, repeat: :INT64)] })
    results.rows.first.to_h.must_equal({ value: [{ message: "hello", repeat: 1 }] })
  end

  it "queries a struct parameter and returns string and integer" do
    results = db.execute "SELECT @value.message AS message, @value.repeat AS repeat", params: { value: { message: "hello", repeat: 1 } }

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ message: :STRING, repeat: :INT64 })
    results.rows.first.to_h.must_equal({ message: "hello", repeat: 1 })
  end

  it "queries and returns a struct array" do
    struct_sql = "SELECT ARRAY(SELECT AS STRUCT message, repeat FROM (SELECT 'hello' AS message, 1 AS repeat UNION ALL SELECT 'hola' AS message, 2 AS repeat))"
    results = db.execute struct_sql

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ 0 => [db.fields(message: :STRING, repeat: :INT64)] })
    results.rows.first.to_h.must_equal({ 0 => [{ message: "hello", repeat: 1 }, { message: "hola", repeat: 2 }] })
  end

  it "queries and returns an empty struct array" do
    struct_sql = "SELECT ARRAY(SELECT AS STRUCT * FROM (SELECT 'empty', 0) WHERE 0 = 1)"
    results = db.execute struct_sql

    results.must_be_kind_of Google::Cloud::Spanner::Results
    results.fields.to_h.must_equal({ 0 => [db.fields(0 => :STRING, 1 => :INT64)] })
    results.rows.first.to_h.must_equal({ 0 => [] })
  end

end
