# Copyright 2022 Google LLC
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

require "helper"
require "bigdecimal"

describe Google::Cloud::Spanner::Convert, :grpc_type_for_field, :mock_spanner do

  it "converts a BOOL value" do
    field = :BOOL
    type = Google::Cloud::Spanner::Convert.grpc_type_for_field field
    assert_equal type.code, :BOOL
  end

  it "converts a INT64 value" do
    field = :INT64
    type = Google::Cloud::Spanner::Convert.grpc_type_for_field field
    assert_equal type.code, :INT64
  end

  it "converts a FLOAT64 value" do
    field = :FLOAT64
    type = Google::Cloud::Spanner::Convert.grpc_type_for_field field
    assert_equal type.code, :FLOAT64
  end

  it "converts a TIMESTAMP value" do
    field = :TIMESTAMP
    type = Google::Cloud::Spanner::Convert.grpc_type_for_field field
    assert_equal type.code, :TIMESTAMP
  end

  it "converts a DATE value" do
    field = :DATE
    type = Google::Cloud::Spanner::Convert.grpc_type_for_field field
    assert_equal type.code, :DATE
  end

  it "converts a STRING value" do
    field = :STRING
    type = Google::Cloud::Spanner::Convert.grpc_type_for_field field
    assert_equal type.code, :STRING
  end

  it "converts a BYTES value" do
    field = :BYTES
    type = Google::Cloud::Spanner::Convert.grpc_type_for_field field
    assert_equal type.code, :BYTES
  end

  it "converts an ARRAY of INT64 values" do
    field = [:INT64]
    type = Google::Cloud::Spanner::Convert.grpc_type_for_field field
    assert_equal type.code, :ARRAY
    assert_equal type.array_element_type.code, :INT64
  end

  it "converts a STRUCT value" do
    field = :STRUCT
    type = Google::Cloud::Spanner::Convert.grpc_type_for_field field
    assert_equal type.code, :STRUCT
  end

  it "converts a NUMERIC value" do
    field = :NUMERIC
    type = Google::Cloud::Spanner::Convert.grpc_type_for_field field
    assert_equal type.code, :NUMERIC
  end

  it "converts a JSON value" do
    field = :JSON
    type = Google::Cloud::Spanner::Convert.grpc_type_for_field field
    assert_equal type.code, :JSON
  end

  it "converts a PG_JSONB value" do
    field = :PG_JSONB
    type = Google::Cloud::Spanner::Convert.grpc_type_for_field field
    assert_equal type.code, :JSON
    assert_equal type.type_annotation, :PG_JSONB 
  end

  it "converts a PG_NUMERIC value" do
    field = :PG_NUMERIC
    type = Google::Cloud::Spanner::Convert.grpc_type_for_field field
    assert_equal type.code, :NUMERIC
    assert_equal type.type_annotation, :PG_NUMERIC
  end
end
