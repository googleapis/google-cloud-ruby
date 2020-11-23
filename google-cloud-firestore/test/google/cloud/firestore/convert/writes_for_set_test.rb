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

require "helper"

describe Google::Cloud::Firestore::Convert, :write_for_set do
  # These tests are a sanity check on the implementation of the conversion methods.
  # These tests are testing private methods and this is generally not a great idea.
  # But these conversions are so important that it was decided to do it anyway.

  let(:document_path) { "projects/projectID/databases/(default)/documents/C/d" }
  let(:field_delete) { Google::Cloud::Firestore::FieldValue.delete }
  let(:field_server_time) { Google::Cloud::Firestore::FieldValue.server_time }

  it "basic set" do
    data = { a: 1 }

    expected_writes = Google::Cloud::Firestore::V1::Write.new(
      update: Google::Cloud::Firestore::V1::Document.new(
        name: document_path,
        fields: {
          "a" => Google::Cloud::Firestore::V1::Value.new(integer_value: 1)
        }
      )
    )

    actual_writes = Google::Cloud::Firestore::Convert.write_for_set document_path, data

    _(actual_writes).must_equal expected_writes
  end

  it "complex set" do
    data = { a: [1, 2.5], b: { c: ["three", { d: true }] } }

    expected_writes = Google::Cloud::Firestore::V1::Write.new(
      update: Google::Cloud::Firestore::V1::Document.new(
        name: document_path,
        fields: {
          "a" => Google::Cloud::Firestore::V1::Value.new(array_value: Google::Cloud::Firestore::V1::ArrayValue.new(values: [
            Google::Cloud::Firestore::V1::Value.new(integer_value: 1),
            Google::Cloud::Firestore::V1::Value.new(double_value: 2.5)
          ])),
          "b" => Google::Cloud::Firestore::V1::Value.new(map_value: Google::Cloud::Firestore::V1::MapValue.new(fields: {
            "c" => Google::Cloud::Firestore::V1::Value.new(array_value: Google::Cloud::Firestore::V1::ArrayValue.new(values: [
              Google::Cloud::Firestore::V1::Value.new(string_value: "three"),
              Google::Cloud::Firestore::V1::Value.new(map_value: Google::Cloud::Firestore::V1::MapValue.new(fields: {
                "d" => Google::Cloud::Firestore::V1::Value.new(boolean_value: true)
              }))
            ]))
          }))
        }
      )
    )

    actual_writes = Google::Cloud::Firestore::Convert.write_for_set document_path, data

    _(actual_writes).must_equal expected_writes
  end

  it "setting empty data" do
    data = {}

    expected_writes = Google::Cloud::Firestore::V1::Write.new(
      update: Google::Cloud::Firestore::V1::Document.new(name: document_path)
    )

    actual_writes = Google::Cloud::Firestore::Convert.write_for_set document_path, data

    _(actual_writes).must_equal expected_writes
  end

  it "don't split on dots" do
    data = { "a.b" => { "c.d" => 1 }, "e" => 2 }

    expected_writes = Google::Cloud::Firestore::V1::Write.new(
      update: Google::Cloud::Firestore::V1::Document.new(
        name: "projects/projectID/databases/(default)/documents/C/d",
        fields: {
          "a.b" => Google::Cloud::Firestore::V1::Value.new(map_value: Google::Cloud::Firestore::V1::MapValue.new(fields: {
            "c.d" => Google::Cloud::Firestore::V1::Value.new(integer_value: 1),
          })),
          "e" => Google::Cloud::Firestore::V1::Value.new(integer_value: 2)
        }
      )
    )

    actual_writes = Google::Cloud::Firestore::Convert.write_for_set document_path, data

    _(actual_writes).must_equal expected_writes
  end

  it "DELETE cannot be anywhere inside an array value" do
    data = { a: [1, { b: field_delete }] }

    error = expect do
      Google::Cloud::Firestore::Convert.write_for_set document_path, data
    end.must_raise ArgumentError
    _(error.message).must_equal "cannot nest delete under arrays"
  end

  it "DELETE cannot be in an array value" do
    data = { a: [1, 2, field_delete] }

    error = expect do
      Google::Cloud::Firestore::Convert.write_for_set document_path, data
    end.must_raise ArgumentError
    _(error.message).must_equal "cannot nest delete under arrays"
  end

  it "DELETE cannot appear in data" do
    data = { a: 1, b: field_delete }

    error = expect do
      Google::Cloud::Firestore::Convert.write_for_set document_path, data
    end.must_raise ArgumentError
    _(error.message).must_equal "DELETE not allowed on set"
  end

  describe "merge: []" do
    it "merges with a field" do
      data = { a: 1, b: 2 }

      expected_writes = Google::Cloud::Firestore::V1::Write.new(
        update: Google::Cloud::Firestore::V1::Document.new(
          name: "projects/projectID/databases/(default)/documents/C/d",
          fields: {
            "a" => Google::Cloud::Firestore::V1::Value.new(integer_value: 1)
          }
        ),
        update_mask: Google::Cloud::Firestore::V1::DocumentMask.new(
          field_paths: ["a"]
        )
      )

      actual_writes = Google::Cloud::Firestore::Convert.write_for_set document_path, data, merge: "a"

      _(actual_writes).must_equal expected_writes
    end

    it "merges with FieldPaths (array)" do
      data = { "*" => { "~" => true } }

      expected_writes = Google::Cloud::Firestore::V1::Write.new(
        update: Google::Cloud::Firestore::V1::Document.new(
          name: "projects/projectID/databases/(default)/documents/C/d",
          fields: {
            "*" => Google::Cloud::Firestore::V1::Value.new(map_value: Google::Cloud::Firestore::V1::MapValue.new(fields: {
              "~" => Google::Cloud::Firestore::V1::Value.new(boolean_value: true)
            }))
          }
        ),
        update_mask: Google::Cloud::Firestore::V1::DocumentMask.new(
          field_paths: ["`*`.`~`"]
        )
      )

      actual_writes = Google::Cloud::Firestore::Convert.write_for_set document_path, data, merge: [["*", "~"]]

      _(actual_writes).must_equal expected_writes
    end

    it "merges with FieldPaths (FieldPath)" do
      data = { "*" => { "~" => true } }

      expected_writes = Google::Cloud::Firestore::V1::Write.new(
        update: Google::Cloud::Firestore::V1::Document.new(
          name: "projects/projectID/databases/(default)/documents/C/d",
          fields: {
            "*" => Google::Cloud::Firestore::V1::Value.new(map_value: Google::Cloud::Firestore::V1::MapValue.new(fields: {
              "~" => Google::Cloud::Firestore::V1::Value.new(boolean_value: true)
            }))
          }
        ),
        update_mask: Google::Cloud::Firestore::V1::DocumentMask.new(
          field_paths: ["`*`.`~`"]
        )
      )

      merge_field_path = Google::Cloud::Firestore::FieldPath.new "*", "~"
      actual_writes = Google::Cloud::Firestore::Convert.write_for_set document_path, data, merge: merge_field_path

      _(actual_writes).must_equal expected_writes
    end

    it "merges a nested field (array)" do
      data = { h: { g: 4, f: 5 } }

      expected_writes = Google::Cloud::Firestore::V1::Write.new(
        update: Google::Cloud::Firestore::V1::Document.new(
          name: "projects/projectID/databases/(default)/documents/C/d",
          fields: {
            "h" => Google::Cloud::Firestore::V1::Value.new(map_value: Google::Cloud::Firestore::V1::MapValue.new(fields: {
              "g" => Google::Cloud::Firestore::V1::Value.new(integer_value: 4)
            }))
          }
        ),
        update_mask: Google::Cloud::Firestore::V1::DocumentMask.new(
          field_paths: ["h.g"]
        )
      )

      actual_writes = Google::Cloud::Firestore::Convert.write_for_set document_path, data, merge: [["h", "g"]]

      _(actual_writes).must_equal expected_writes
    end

    it "merges a nested field (string)" do
      data = { h: { g: 4, f: 5 } }

      expected_writes = Google::Cloud::Firestore::V1::Write.new(
        update: Google::Cloud::Firestore::V1::Document.new(
          name: "projects/projectID/databases/(default)/documents/C/d",
          fields: {
            "h" => Google::Cloud::Firestore::V1::Value.new(map_value: Google::Cloud::Firestore::V1::MapValue.new(fields: {
              "g" => Google::Cloud::Firestore::V1::Value.new(integer_value: 4)
            }))
          }
        ),
        update_mask: Google::Cloud::Firestore::V1::DocumentMask.new(
          field_paths: ["h.g"]
        )
      )

      actual_writes = Google::Cloud::Firestore::Convert.write_for_set document_path, data, merge: ["h.g"]

      _(actual_writes).must_equal expected_writes
    end

    it "merges field when not a leaf" do
      data = { h: { g: 5, f: 6 }, e: 7 }

      expected_writes = Google::Cloud::Firestore::V1::Write.new(
        update: Google::Cloud::Firestore::V1::Document.new(
          name: "projects/projectID/databases/(default)/documents/C/d",
          fields: {
            "h" => Google::Cloud::Firestore::V1::Value.new(map_value: Google::Cloud::Firestore::V1::MapValue.new(fields: {
              "g" => Google::Cloud::Firestore::V1::Value.new(integer_value: 5),
              "f" => Google::Cloud::Firestore::V1::Value.new(integer_value: 6)
            }))
          }
        ),
        update_mask: Google::Cloud::Firestore::V1::DocumentMask.new(
          field_paths: ["h"]
        )
      )

      actual_writes = Google::Cloud::Firestore::Convert.write_for_set document_path, data, merge: [:h]

      _(actual_writes).must_equal expected_writes
    end

    it "does not write data when field is not provided" do
      data = { a: 1, b: field_server_time }

      expected_writes = Google::Cloud::Firestore::V1::Write.new(
        update: Google::Cloud::Firestore::V1::Document.new(
          name: "projects/projectID/databases/(default)/documents/C/d"
        ),
        update_mask: Google::Cloud::Firestore::V1::DocumentMask.new,
        update_transforms: [
          Google::Cloud::Firestore::V1::DocumentTransform::FieldTransform.new(
            field_path: "b",
            set_to_server_value: :REQUEST_TIME
          )
        ]
      )

      actual_writes = Google::Cloud::Firestore::Convert.write_for_set document_path, data, merge: :b

      _(actual_writes).must_equal expected_writes
    end

    it "fields must all be present in data" do
      data = { a: 1 }

      error = expect do
        Google::Cloud::Firestore::Convert.write_for_set document_path, data, merge: ["b", "a"]
      end.must_raise ArgumentError
      _(error.message).must_equal "all fields must be in data"
    end

    it "DELETE cannot appear in an unmerged field" do
      data = { a: 1, b: field_delete }

      error = expect do
        Google::Cloud::Firestore::Convert.write_for_set document_path, data, merge: [:a]
      end.must_raise ArgumentError
      _(error.message).must_equal "deleted field not included in merge"
    end
  end

  describe "merge: true" do
    it "merges all" do
      data = { a: 1, b: 2 }

      expected_writes = Google::Cloud::Firestore::V1::Write.new(
        update: Google::Cloud::Firestore::V1::Document.new(
          name: "projects/projectID/databases/(default)/documents/C/d",
          fields: {
            "a" => Google::Cloud::Firestore::V1::Value.new(integer_value: 1),
            "b" => Google::Cloud::Firestore::V1::Value.new(integer_value: 2)
          }
        ),
        update_mask: Google::Cloud::Firestore::V1::DocumentMask.new(
          field_paths: ["a", "b"]
        )
      )

      actual_writes = Google::Cloud::Firestore::Convert.write_for_set document_path, data, merge: true

      _(actual_writes).must_equal expected_writes
    end

    it "merges with nested fields" do
      data = { h: { g: 3, f: 4 } }

      expected_writes = Google::Cloud::Firestore::V1::Write.new(
        update: Google::Cloud::Firestore::V1::Document.new(
          name: "projects/projectID/databases/(default)/documents/C/d",
          fields: {
            "h" => Google::Cloud::Firestore::V1::Value.new(map_value: Google::Cloud::Firestore::V1::MapValue.new(fields: {
              "g" => Google::Cloud::Firestore::V1::Value.new(integer_value: 3),
              "f" => Google::Cloud::Firestore::V1::Value.new(integer_value: 4)
            }))
          }
        ),
        update_mask: Google::Cloud::Firestore::V1::DocumentMask.new(
          field_paths: ["h.f", "h.g"]
        )
      )

      actual_writes = Google::Cloud::Firestore::Convert.write_for_set document_path, data, merge: true

      _(actual_writes).must_equal expected_writes
    end

    it "cannot be specified with empty data" do
      data = {}

      error = expect do
        Google::Cloud::Firestore::Convert.write_for_set document_path, data, merge: []
      end.must_raise ArgumentError
      _(error.message).must_equal "data required for set with merge"
    end
  end
end
