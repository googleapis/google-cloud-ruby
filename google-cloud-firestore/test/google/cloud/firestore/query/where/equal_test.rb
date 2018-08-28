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

require "helper"

describe Google::Cloud::Firestore::Query, :where, :equal, :mock_firestore do
  let(:query) { Google::Cloud::Firestore::Query.start nil, "#{firestore.path}/documents", firestore }

  it "using =" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      where: Google::Firestore::V1beta1::StructuredQuery::Filter.new(
        field_filter: Google::Firestore::V1beta1::StructuredQuery::FieldFilter.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "foo"),
          op: :EQUAL,
          value: Google::Firestore::V1beta1::Value.new(integer_value: 42)
        )
      )
    )

    generated_query = query.where(:foo, "=", 42).query
    generated_query.must_equal expected_query
  end

  it "using ==" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      where: Google::Firestore::V1beta1::StructuredQuery::Filter.new(
        field_filter: Google::Firestore::V1beta1::StructuredQuery::FieldFilter.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "foo"),
          op: :EQUAL,
          value: Google::Firestore::V1beta1::Value.new(integer_value: 42)
        )
      )
    )

    generated_query = query.where(:foo, :==, 42).query
    generated_query.must_equal expected_query
  end

  it "using eq" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      where: Google::Firestore::V1beta1::StructuredQuery::Filter.new(
        field_filter: Google::Firestore::V1beta1::StructuredQuery::FieldFilter.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "foo"),
          op: :EQUAL,
          value: Google::Firestore::V1beta1::Value.new(integer_value: 42)
        )
      )
    )

    generated_query = query.where(:foo, :eq, 42).query
    generated_query.must_equal expected_query
  end

  it "using eql" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      where: Google::Firestore::V1beta1::StructuredQuery::Filter.new(
        field_filter: Google::Firestore::V1beta1::StructuredQuery::FieldFilter.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "foo"),
          op: :EQUAL,
          value: Google::Firestore::V1beta1::Value.new(integer_value: 42)
        )
      )
    )

    generated_query = query.where(:foo, :eql, 42).query
    generated_query.must_equal expected_query
  end

  it "using is" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      where: Google::Firestore::V1beta1::StructuredQuery::Filter.new(
        field_filter: Google::Firestore::V1beta1::StructuredQuery::FieldFilter.new(
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "foo"),
          op: :EQUAL,
          value: Google::Firestore::V1beta1::Value.new(integer_value: 42)
        )
      )
    )

    generated_query = query.where(:foo, :is, 42).query
    generated_query.must_equal expected_query
  end

  it "with multiple values" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      where: Google::Firestore::V1beta1::StructuredQuery::Filter.new(
        composite_filter: Google::Firestore::V1beta1::StructuredQuery::CompositeFilter.new(
          op: :AND,
          filters: [
            Google::Firestore::V1beta1::StructuredQuery::Filter.new(
              field_filter: Google::Firestore::V1beta1::StructuredQuery::FieldFilter.new(
                field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "foo"),
                op: :EQUAL,
                value: Google::Firestore::V1beta1::Value.new(integer_value: 42)
              )
            ),
            Google::Firestore::V1beta1::StructuredQuery::Filter.new(
              field_filter: Google::Firestore::V1beta1::StructuredQuery::FieldFilter.new(
                field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "bar"),
                op: :EQUAL,
                value: Google::Firestore::V1beta1::Value.new(string_value: "baz")
              )
            )
          ]
        )
      )
    )

    generated_query = query.where(:foo, :==, 42).where(:bar, :==, "baz").query
    generated_query.must_equal expected_query
  end

  it "with nil" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      where: Google::Firestore::V1beta1::StructuredQuery::Filter.new(
        unary_filter: Google::Firestore::V1beta1::StructuredQuery::UnaryFilter.new(
          op: :IS_NULL,
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "foo")
        )
      )
    )

    generated_query = query.where(:foo, :==, nil).query
    generated_query.must_equal expected_query
  end

  it "with :nil" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      where: Google::Firestore::V1beta1::StructuredQuery::Filter.new(
        unary_filter: Google::Firestore::V1beta1::StructuredQuery::UnaryFilter.new(
          op: :IS_NULL,
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "foo")
        )
      )
    )

    generated_query = query.where(:foo, :==, :nil).query
    generated_query.must_equal expected_query
  end

  it "with :null" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      where: Google::Firestore::V1beta1::StructuredQuery::Filter.new(
        unary_filter: Google::Firestore::V1beta1::StructuredQuery::UnaryFilter.new(
          op: :IS_NULL,
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "foo")
        )
      )
    )

    generated_query = query.where(:foo, :==, :null).query
    generated_query.must_equal expected_query
  end

  it "with :nan" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      where: Google::Firestore::V1beta1::StructuredQuery::Filter.new(
        unary_filter: Google::Firestore::V1beta1::StructuredQuery::UnaryFilter.new(
          op: :IS_NAN,
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "foo")
        )
      )
    )

    generated_query = query.where(:foo, :==, :nan).query
    generated_query.must_equal expected_query
  end

  it "with Float::NAN" do
    expected_query = Google::Firestore::V1beta1::StructuredQuery.new(
      where: Google::Firestore::V1beta1::StructuredQuery::Filter.new(
        unary_filter: Google::Firestore::V1beta1::StructuredQuery::UnaryFilter.new(
          op: :IS_NAN,
          field: Google::Firestore::V1beta1::StructuredQuery::FieldReference.new(field_path: "foo")
        )
      )
    )

    generated_query = query.where(:foo, :==, Float::NAN).query
    generated_query.must_equal expected_query
  end
end
