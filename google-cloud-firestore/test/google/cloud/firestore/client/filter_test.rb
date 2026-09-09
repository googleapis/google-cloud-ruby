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

describe Google::Cloud::Firestore::Client, :doc, :mock_firestore do
  it "creates a filter" do
    expected_filter = Google::Cloud::Firestore::V1::StructuredQuery::Filter.new(
      field_filter: Google::Cloud::Firestore::V1::StructuredQuery::FieldFilter.new(
        field: Google::Cloud::Firestore::V1::StructuredQuery::FieldReference.new(field_path: "foo"),
        op: :EQUAL,
        value: Google::Cloud::Firestore::V1::Value.new(integer_value: 42)
      )
    )

    generated_filter = firestore.filter(:foo, :==, 42)
    _(generated_filter.filter).must_equal expected_filter
  end
end
