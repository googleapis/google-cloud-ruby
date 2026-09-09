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

require "helper"

describe Google::Cloud::Firestore::Query, :where, :not_equal, :mock_firestore do
  let(:query) { Google::Cloud::Firestore::Query.start nil, "#{firestore.path}/documents", firestore }

  it "using !=" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      where: Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
        field_filter: Google::Cloud::Firestore::V1::StructuredQuery::FieldFilter.new(
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "foo"),
          op: :NOT_EQUAL,
          value: Google::Cloud::Firestore::V1::Value.new(integer_value: 42)
        )
      )
    )

    generated_query = query.where(:foo, :!=, 42).query
    _(generated_query).must_equal expected_query
  end

  it "with multiple values" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      where: Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
        composite_filter: Google::Cloud::Firestore::V1::StructuredQuery::CompositeFilter.new(
          op: :AND,
          filters: [
            Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
              field_filter: Google::Cloud::Firestore::V1::StructuredQuery::FieldFilter.new(
                field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "foo"),
                op: :NOT_EQUAL,
                value: Google::Cloud::Firestore::V1::Value.new(integer_value: 42)
              )
            ),
            Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
              field_filter: Google::Cloud::Firestore::V1::StructuredQuery::FieldFilter.new(
                field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "bar"),
                op: :NOT_EQUAL,
                value: Google::Cloud::Firestore::V1::Value.new(string_value: "baz")
              )
            )
          ]
        )
      )
    )

    generated_query = query.where(:foo, :!=, 42).where(:bar, :!=, "baz").query
    _(generated_query).must_equal expected_query
  end

  it "with nil" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      where: Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
        unary_filter: Google::Cloud::Firestore::V1::StructuredQuery::UnaryFilter.new(
          op: :IS_NOT_NULL,
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "foo")
        )
      )
    )

    generated_query = query.where(:foo, :!=, nil).query
    _(generated_query).must_equal expected_query
  end

  it "with :nil" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      where: Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
        unary_filter: Google::Cloud::Firestore::V1::StructuredQuery::UnaryFilter.new(
          op: :IS_NOT_NULL,
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "foo")
        )
      )
    )

    generated_query = query.where(:foo, :!=, :nil).query
    _(generated_query).must_equal expected_query
  end

  it "with :null" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      where: Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
        unary_filter: Google::Cloud::Firestore::V1::StructuredQuery::UnaryFilter.new(
          op: :IS_NOT_NULL,
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "foo")
        )
      )
    )

    generated_query = query.where(:foo, :!=, :null).query
    _(generated_query).must_equal expected_query
  end

  it "with :nan" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      where: Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
        unary_filter: Google::Cloud::Firestore::V1::StructuredQuery::UnaryFilter.new(
          op: :IS_NOT_NAN,
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "foo")
        )
      )
    )

    generated_query = query.where(:foo, :!=, :nan).query
    _(generated_query).must_equal expected_query
  end

  it "with Float::NAN" do
    expected_query = Google::Cloud::Firestore::V1::StructuredQuery.new(
      where: Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
        unary_filter: Google::Cloud::Firestore::V1::StructuredQuery::UnaryFilter.new(
          op: :IS_NOT_NAN,
          field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "foo")
        )
      )
    )

    generated_query = query.where(:foo, :!=, Float::NAN).query
    _(generated_query).must_equal expected_query
  end
end
