# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a extract of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Bigquery::StandardSql, :value do
  describe "immutable constructors" do
    # TODO: move these tests someplace more logical...
    it "takes DataType as an argument" do
      parent = Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: "STRING"
      data_type = Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: "ARRAY", array_element_type: parent

      _(data_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
      _(data_type.type_kind).must_equal "ARRAY"
      _(data_type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
      _(data_type.array_element_type.type_kind).must_equal "STRING"
    end

    it "takes Hash as an argument" do
      data_type = Google::Cloud::Bigquery::StandardSql::DataType.new type_kind: "ARRAY", array_element_type: "STRING"

      _(data_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
      _(data_type.type_kind).must_equal "ARRAY"
      _(data_type.array_element_type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
      _(data_type.array_element_type.type_kind).must_equal "STRING"
    end
  end

  it "represents a INT64 field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.new name: "int_col", type: "INT64"

    _(field.name).must_equal "int_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "INT64"
    _(field.type.array_element_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).must_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :bignumeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).wont_be :array?
    _(field.type).wont_be :struct?
  end

  it "represents a FLOAT64 field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.new name: "float_col", type: "FLOAT64"

    _(field.name).must_equal "float_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "FLOAT64"
    _(field.type.array_element_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).must_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :bignumeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).wont_be :array?
    _(field.type).wont_be :struct?
  end

  it "represents a NUMERIC field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.new name: "num_col", type: "NUMERIC"

    _(field.name).must_equal "num_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "NUMERIC"
    _(field.type.array_element_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).must_be :numeric?
    _(field.type).wont_be :bignumeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).wont_be :array?
    _(field.type).wont_be :struct?
  end

  it "represents a BIGNUMERIC field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.new name: "bignumeric_col", type: "BIGNUMERIC"

    _(field.name).must_equal "bignumeric_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "BIGNUMERIC"
    _(field.type.array_element_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).must_be :bignumeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).wont_be :array?
    _(field.type).wont_be :struct?
  end

  it "represents a BOOL field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.new name: "bool_col", type: "BOOL"

    _(field.name).must_equal "bool_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "BOOL"
    _(field.type.array_element_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :bignumeric?
    _(field.type).must_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).wont_be :array?
    _(field.type).wont_be :struct?
  end

  it "represents a STRING field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.new name: "str_col", type: "STRING"

    _(field.name).must_equal "str_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "STRING"
    _(field.type.array_element_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :bignumeric?
    _(field.type).wont_be :boolean?
    _(field.type).must_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).wont_be :array?
    _(field.type).wont_be :struct?
  end

  it "represents a BYTES field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.new name: "bytes_col", type: "BYTES"

    _(field.name).must_equal "bytes_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "BYTES"
    _(field.type.array_element_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :bignumeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).must_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).wont_be :array?
    _(field.type).wont_be :struct?
  end

  it "represents a DATE field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.new name: "date_col", type: "DATE"

    _(field.name).must_equal "date_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "DATE"
    _(field.type.array_element_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :bignumeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).must_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).wont_be :array?
    _(field.type).wont_be :struct?
  end

  it "represents a DATETIME field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.new name: "datetime_col", type: "DATETIME"

    _(field.name).must_equal "datetime_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "DATETIME"
    _(field.type.array_element_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :bignumeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).must_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).wont_be :array?
    _(field.type).wont_be :struct?
  end

  it "represents a GEOGRAPHY field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.new name: "geo_col", type: "GEOGRAPHY"

    _(field.name).must_equal "geo_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "GEOGRAPHY"
    _(field.type.array_element_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :bignumeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).must_be :geography?
    _(field.type).wont_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).wont_be :array?
    _(field.type).wont_be :struct?
  end

  it "represents a TIME field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.new name: "time_col", type: "TIME"

    _(field.name).must_equal "time_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "TIME"
    _(field.type.array_element_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :bignumeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).must_be :time?
    _(field.type).wont_be :timestamp?
    _(field.type).wont_be :array?
    _(field.type).wont_be :struct?
  end

  it "represents a TIMESTAMP field" do
    field = Google::Cloud::Bigquery::StandardSql::Field.new name: "ts_col", type: "TIMESTAMP"

    _(field.name).must_equal "ts_col"

    _(field.type).must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    _(field.type.type_kind).must_equal "TIMESTAMP"
    _(field.type.array_element_type).must_be_nil
    _(field.type.struct_type).must_be_nil

    _(field.type).wont_be :int?
    _(field.type).wont_be :float?
    _(field.type).wont_be :numeric?
    _(field.type).wont_be :bignumeric?
    _(field.type).wont_be :boolean?
    _(field.type).wont_be :string?
    _(field.type).wont_be :bytes?
    _(field.type).wont_be :date?
    _(field.type).wont_be :datetime?
    _(field.type).wont_be :geography?
    _(field.type).wont_be :time?
    _(field.type).must_be :timestamp?
    _(field.type).wont_be :array?
    _(field.type).wont_be :struct?
  end
end
