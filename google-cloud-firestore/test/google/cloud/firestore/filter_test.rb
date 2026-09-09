# Copyright 2023 Google LLC
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

describe Google::Cloud::Firestore::Filter do
  let(:query) { Google::Cloud::Firestore::Query.start nil, "#{firestore.path}/documents", firestore }

  it "using =" do
    expected_filter = Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
      field_filter: Google::Cloud::Firestore::V1::StructuredQuery::FieldFilter.new(
        field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "foo"),
        op: :EQUAL,
        value: Google::Cloud::Firestore::V1::Value.new(integer_value: 42)
      )
    )

    generated_filter = Google::Cloud::Firestore::Filter.new(:foo, "=", 42)
    _(generated_filter.filter).must_equal expected_filter
  end

  it "using ==" do
    expected_filter = Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
      field_filter: Google::Cloud::Firestore::V1::StructuredQuery::FieldFilter.new(
        field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "foo"),
        op: :EQUAL,
        value: Google::Cloud::Firestore::V1::Value.new(integer_value: 42)
      )
    )

    generated_filter = Google::Cloud::Firestore::Filter.new(:foo, :==, 42)
    _(generated_filter.filter).must_equal expected_filter
  end

  it "with Float::NAN" do
    expected_filter = Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
      unary_filter: Google::Cloud::Firestore::V1::StructuredQuery::UnaryFilter.new(
        op: :IS_NAN,
        field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "foo")
      )
    )

    generated_filter = Google::Cloud::Firestore::Filter.new(:foo, :==, Float::NAN)
    _(generated_filter.filter).must_equal expected_filter
  end

  it "with :null" do
    expected_filter = Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
      unary_filter: Google::Cloud::Firestore::V1::StructuredQuery::UnaryFilter.new(
        op: :IS_NULL,
        field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "foo")
      )
    )

    generated_filter = Google::Cloud::Firestore::Filter.new(:foo, :==, :null)
    _(generated_filter.filter).must_equal expected_filter
  end

  it "with complex composite filters" do
    expected_filter = Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
      composite_filter: Google::Cloud::Firestore::V1::StructuredQuery::CompositeFilter.new(
        op: :AND,
        filters: [
          Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
            composite_filter: Google::Cloud::Firestore::V1::StructuredQuery::CompositeFilter.new(
              op: :OR,
              filters: [
                Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
                  field_filter: Google::Cloud::Firestore::V1::StructuredQuery::FieldFilter.new(
                    field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "foo"),
                    op: :EQUAL,
                    value: Google::Cloud::Firestore::V1::Value.new(integer_value: 42)
                  )
                ),
                Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
                  field_filter: Google::Cloud::Firestore::V1::StructuredQuery::FieldFilter.new(
                    field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "bar"),
                    op: :EQUAL,
                    value: Google::Cloud::Firestore::V1::Value.new(string_value: "baz")
                  )
                )
              ]
            )
          ),
          Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
            field_filter: Google::Cloud::Firestore::V1::StructuredQuery::FieldFilter.new(
              field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "bar"),
              op: :EQUAL,
              value: Google::Cloud::Firestore::V1::Value.new(string_value: "bar")
            )
          )
        ]
      )
    )

    filter_1 = Google::Cloud::Firestore::Filter.new(:bar, :==, "bar")
    generated_filter = Google::Cloud::Firestore::Filter.new(:foo, :==, 42).or(:bar, :==, "baz").and(filter_1)
    _(generated_filter.filter).must_equal expected_filter
  end

  it "does not mutate existing filter objects on .and method" do
    expected_filter = Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
      composite_filter: Google::Cloud::Firestore::V1::StructuredQuery::CompositeFilter.new(
        op: :AND,
        filters: [
          Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
            field_filter: Google::Cloud::Firestore::V1::StructuredQuery::FieldFilter.new(
              field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "a"),
              op: :EQUAL,
              value: Google::Cloud::Firestore::V1::Value.new(integer_value: 3)
            )
          ),
          Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
            field_filter: Google::Cloud::Firestore::V1::StructuredQuery::FieldFilter.new(
              field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "b"),
              op: :GREATER_THAN,
              value: Google::Cloud::Firestore::V1::Value.new(integer_value: 4)
            )
          )
        ]
      )
    )
    filter_1 = Google::Cloud::Firestore::Filter.new(:a, :==, 3)
    filter_2 = Google::Cloud::Firestore::Filter.new(:b, :>, 4)
    filter_3 = filter_1.and(filter_2)
    _(filter_3.filter).must_equal expected_filter
    _(filter_1.filter).must_equal Google::Cloud::Firestore::Filter.new(:a, :==, 3).filter
    _(filter_2.filter).must_equal Google::Cloud::Firestore::Filter.new(:b, :>, 4).filter
  end

  it "does not mutate existing filter objects on .or method" do
    expected_filter = Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
      composite_filter: Google::Cloud::Firestore::V1::StructuredQuery::CompositeFilter.new(
        op: :OR,
        filters: [
          Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
            field_filter: Google::Cloud::Firestore::V1::StructuredQuery::FieldFilter.new(
              field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "a"),
              op: :EQUAL,
              value: Google::Cloud::Firestore::V1::Value.new(integer_value: 3)
            )
          ),
          Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
            field_filter: Google::Cloud::Firestore::V1::StructuredQuery::FieldFilter.new(
              field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "b"),
              op: :GREATER_THAN,
              value: Google::Cloud::Firestore::V1::Value.new(integer_value: 4)
            )
          )
        ]
      )
    )
    filter_1 = Google::Cloud::Firestore::Filter.new(:a, :==, 3)
    filter_2 = Google::Cloud::Firestore::Filter.new(:b, :>, 4)
    filter_3 = filter_1.or(filter_2)
    _(filter_3.filter).must_equal expected_filter
    _(filter_1.filter).must_equal Google::Cloud::Firestore::Filter.new(:a, :==, 3).filter
    _(filter_2.filter).must_equal Google::Cloud::Firestore::Filter.new(:b, :>, 4).filter
  end
end
