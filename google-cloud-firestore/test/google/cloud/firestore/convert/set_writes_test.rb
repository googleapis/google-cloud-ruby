# Copyright 2017, Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Firestore::Convert, :set_writes do
  # These tests are a sanity check on the implementation of the conversion methods.
  # These tests are testing private methods and this is generally not a great idea.
  # But these conversions are so important that it was decided to do it anyway.

  let(:document_path) { "projects/projectID/databases/(default)/documents/C/d" }

  it "basic set" do
    data = { a: 1 }

    expected_writes = [
      Google::Firestore::V1beta1::Write.new(
        update: Google::Firestore::V1beta1::Document.new(
          name: document_path,
          fields: {
            "a" => Google::Firestore::V1beta1::Value.new(integer_value: 1)
          }
        )
      )
    ]

    actual_writes = Google::Cloud::Firestore::Convert.set_writes document_path, data

    actual_writes.must_equal expected_writes
  end

  it "complex set" do
    data = { a: [1, 2.5], b: { c: ["three", { d: true }] } }

    expected_writes = [
      Google::Firestore::V1beta1::Write.new(
        update: Google::Firestore::V1beta1::Document.new(
          name: document_path,
          fields: {
            "a" => Google::Firestore::V1beta1::Value.new(array_value: Google::Firestore::V1beta1::ArrayValue.new(values: [
              Google::Firestore::V1beta1::Value.new(integer_value: 1),
              Google::Firestore::V1beta1::Value.new(double_value: 2.5)
            ])),
            "b" => Google::Firestore::V1beta1::Value.new(map_value: Google::Firestore::V1beta1::MapValue.new(fields: {
              "c" => Google::Firestore::V1beta1::Value.new(array_value: Google::Firestore::V1beta1::ArrayValue.new(values: [
                Google::Firestore::V1beta1::Value.new(string_value: "three"),
                Google::Firestore::V1beta1::Value.new(map_value: Google::Firestore::V1beta1::MapValue.new(fields: {
                  "d" => Google::Firestore::V1beta1::Value.new(boolean_value: true)
                }))
              ]))
            }))
          }
        )
      )
    ]

    actual_writes = Google::Cloud::Firestore::Convert.set_writes document_path, data

    actual_writes.must_equal expected_writes
  end

  it "setting empty data" do
    data = {}

    expected_writes = [
      Google::Firestore::V1beta1::Write.new(
        update: Google::Firestore::V1beta1::Document.new(name: document_path)
      )
    ]

    actual_writes = Google::Cloud::Firestore::Convert.set_writes document_path, data

    actual_writes.must_equal expected_writes
  end

  it "don't split on dots" do
    data = { "a.b" => { "c.d" => 1 }, "e" => 2 }

    expected_writes = [
      Google::Firestore::V1beta1::Write.new(
        update: Google::Firestore::V1beta1::Document.new(
          name: "projects/projectID/databases/(default)/documents/C/d",
          fields: {
            "a.b" => Google::Firestore::V1beta1::Value.new(map_value: Google::Firestore::V1beta1::MapValue.new(fields: {
              "c.d" => Google::Firestore::V1beta1::Value.new(integer_value: 1),
            })),
            "e" => Google::Firestore::V1beta1::Value.new(integer_value: 2)
          }
        )
      )
    ]

    actual_writes = Google::Cloud::Firestore::Convert.set_writes document_path, data

    actual_writes.must_equal expected_writes
  end

  it "DELETE cannot be anywhere inside an array value" do
    data = { a: [1, { b: :DELETE }] }

    error = expect do
      Google::Cloud::Firestore::Convert.set_writes document_path, data
    end.must_raise ArgumentError
    error.message.must_equal "cannot nest DELETE under arrays"
  end

  it "DELETE cannot be in an array value" do
    data = { a: [1, 2, :DELETE] }

    error = expect do
      Google::Cloud::Firestore::Convert.set_writes document_path, data
    end.must_raise ArgumentError
    error.message.must_equal "cannot nest DELETE under arrays"
  end

  it "DELETE cannot appear in data" do
    data = { a: 1, b: :DELETE }

    error = expect do
      Google::Cloud::Firestore::Convert.set_writes document_path, data
    end.must_raise ArgumentError
    error.message.must_equal "DELETE not allowed on set"
  end

  describe "merge: []" do
    it "merges with a field" do
      data = { a: 1, b: 2 }

      expected_writes = [
        Google::Firestore::V1beta1::Write.new(
          update: Google::Firestore::V1beta1::Document.new(
            name: "projects/projectID/databases/(default)/documents/C/d",
            fields: {
              "a" => Google::Firestore::V1beta1::Value.new(integer_value: 1)
            }
          ),
          update_mask: Google::Firestore::V1beta1::DocumentMask.new(
            field_paths: ["a"]
          )
        )
      ]

      actual_writes = Google::Cloud::Firestore::Convert.set_writes document_path, data, merge: "a"

      actual_writes.must_equal expected_writes
    end

    it "merges with FieldPaths (array)" do
      data = { "*" => { "~" => true } }

      expected_writes = [
        Google::Firestore::V1beta1::Write.new(
          update: Google::Firestore::V1beta1::Document.new(
            name: "projects/projectID/databases/(default)/documents/C/d",
            fields: {
              "*" => Google::Firestore::V1beta1::Value.new(map_value: Google::Firestore::V1beta1::MapValue.new(fields: {
                "~" => Google::Firestore::V1beta1::Value.new(boolean_value: true)
              }))
            }
          ),
          update_mask: Google::Firestore::V1beta1::DocumentMask.new(
            field_paths: ["`*`.`~`"]
          )
        )
      ]

      actual_writes = Google::Cloud::Firestore::Convert.set_writes document_path, data, merge: [["*", "~"]]

      actual_writes.must_equal expected_writes
    end

    it "merges with FieldPaths (string)" do
      data = { "*" => { "~" => true } }

      expected_writes = [
        Google::Firestore::V1beta1::Write.new(
          update: Google::Firestore::V1beta1::Document.new(
            name: "projects/projectID/databases/(default)/documents/C/d",
            fields: {
              "*" => Google::Firestore::V1beta1::Value.new(map_value: Google::Firestore::V1beta1::MapValue.new(fields: {
                "~" => Google::Firestore::V1beta1::Value.new(boolean_value: true)
              }))
            }
          ),
          update_mask: Google::Firestore::V1beta1::DocumentMask.new(
            field_paths: ["`*`.`~`"]
          )
        )
      ]

      actual_writes = Google::Cloud::Firestore::Convert.set_writes document_path, data, merge: "`*`.`~`"

      actual_writes.must_equal expected_writes
    end

    it "merges a nested field (array)" do
      data = { h: { g: 4, f: 5 } }

      expected_writes = [
        Google::Firestore::V1beta1::Write.new(
          update: Google::Firestore::V1beta1::Document.new(
            name: "projects/projectID/databases/(default)/documents/C/d",
            fields: {
              "h" => Google::Firestore::V1beta1::Value.new(map_value: Google::Firestore::V1beta1::MapValue.new(fields: {
                "g" => Google::Firestore::V1beta1::Value.new(integer_value: 4)
              }))
            }
          ),
          update_mask: Google::Firestore::V1beta1::DocumentMask.new(
            field_paths: ["h.g"]
          )
        )
      ]

      actual_writes = Google::Cloud::Firestore::Convert.set_writes document_path, data, merge: [["h", "g"]]

      actual_writes.must_equal expected_writes
    end

    it "merges a nested field (string)" do
      data = { h: { g: 4, f: 5 } }

      expected_writes = [
        Google::Firestore::V1beta1::Write.new(
          update: Google::Firestore::V1beta1::Document.new(
            name: "projects/projectID/databases/(default)/documents/C/d",
            fields: {
              "h" => Google::Firestore::V1beta1::Value.new(map_value: Google::Firestore::V1beta1::MapValue.new(fields: {
                "g" => Google::Firestore::V1beta1::Value.new(integer_value: 4)
              }))
            }
          ),
          update_mask: Google::Firestore::V1beta1::DocumentMask.new(
            field_paths: ["h.g"]
          )
        )
      ]

      actual_writes = Google::Cloud::Firestore::Convert.set_writes document_path, data, merge: ["h.g"]

      actual_writes.must_equal expected_writes
    end

    it "merges field when not a leaf" do
      data = { h: { g: 5, f: 6 }, e: 7 }

      expected_writes = [
        Google::Firestore::V1beta1::Write.new(
          update: Google::Firestore::V1beta1::Document.new(
            name: "projects/projectID/databases/(default)/documents/C/d",
            fields: {
              "h" => Google::Firestore::V1beta1::Value.new(map_value: Google::Firestore::V1beta1::MapValue.new(fields: {
                "g" => Google::Firestore::V1beta1::Value.new(integer_value: 5),
                "f" => Google::Firestore::V1beta1::Value.new(integer_value: 6)
              }))
            }
          ),
          update_mask: Google::Firestore::V1beta1::DocumentMask.new(
            field_paths: ["h"]
          )
        )
      ]

      actual_writes = Google::Cloud::Firestore::Convert.set_writes document_path, data, merge: [:h]

      actual_writes.must_equal expected_writes
    end

    it "does not write data when field is not provided" do
      data = { a: 1, b: :SERVER_TIME }

      expected_writes = [
        Google::Firestore::V1beta1::Write.new(
          transform: Google::Firestore::V1beta1::DocumentTransform.new(
            document: "projects/projectID/databases/(default)/documents/C/d",
            field_transforms: [
              Google::Firestore::V1beta1::DocumentTransform::FieldTransform.new(
                field_path: "b",
                set_to_server_value: :REQUEST_TIME
              )
            ]
          )
        )
      ]

      actual_writes = Google::Cloud::Firestore::Convert.set_writes document_path, data, merge: :b

      actual_writes.must_equal expected_writes
    end

    it "fields must all be present in data" do
      data = { a: 1 }

      error = expect do
        Google::Cloud::Firestore::Convert.set_writes document_path, data, merge: ["b", "a"]
      end.must_raise ArgumentError
      error.message.must_equal "all fields must be in data"
    end

    it "DELETE cannot appear in an unmerged field" do
      data = { a: 1, b: :DELETE }

      error = expect do
        Google::Cloud::Firestore::Convert.set_writes document_path, data, merge: [:a]
      end.must_raise ArgumentError
      error.message.must_equal "DELETE not allowed on set"
    end
  end

  describe "merge: true" do
    it "merges all" do
      data = { a: 1, b: 2 }

      expected_writes = [
        Google::Firestore::V1beta1::Write.new(
          update: Google::Firestore::V1beta1::Document.new(
            name: "projects/projectID/databases/(default)/documents/C/d",
            fields: {
              "a" => Google::Firestore::V1beta1::Value.new(integer_value: 1),
              "b" => Google::Firestore::V1beta1::Value.new(integer_value: 2)
            }
          ),
          update_mask: Google::Firestore::V1beta1::DocumentMask.new(
            field_paths: ["a", "b"]
          )
        )
      ]

      actual_writes = Google::Cloud::Firestore::Convert.set_writes document_path, data, merge: true

      actual_writes.must_equal expected_writes
    end

    it "merges with nested fields" do
      data = { h: { g: 3, f: 4 } }

      expected_writes = [
        Google::Firestore::V1beta1::Write.new(
          update: Google::Firestore::V1beta1::Document.new(
            name: "projects/projectID/databases/(default)/documents/C/d",
            fields: {
              "h" => Google::Firestore::V1beta1::Value.new(map_value: Google::Firestore::V1beta1::MapValue.new(fields: {
                "g" => Google::Firestore::V1beta1::Value.new(integer_value: 3),
                "f" => Google::Firestore::V1beta1::Value.new(integer_value: 4)
              }))
            }
          ),
          update_mask: Google::Firestore::V1beta1::DocumentMask.new(
            field_paths: ["h.g", "h.f"]
          )
        )
      ]

      actual_writes = Google::Cloud::Firestore::Convert.set_writes document_path, data, merge: true

      actual_writes.must_equal expected_writes
    end

    it "cannot be specified with empty data" do
      data = {}

      error = expect do
        Google::Cloud::Firestore::Convert.set_writes document_path, data, merge: true
      end.must_raise ArgumentError
      error.message.must_equal "data required for merge: true"
    end
  end
end
