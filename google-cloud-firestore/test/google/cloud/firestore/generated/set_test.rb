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

describe "Cross-Language Set Tests", :mock_firestore do
  let(:document_path) { "C/d" }
  let(:database_path) { "projects/#{project}/databases/(default)" }
  let(:documents_path) { "#{database_path}/documents" }

  let(:commit_time) { Time.now }
  let :commit_resp do
    Google::Firestore::V1beta1::CommitResponse.new(
      commit_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time),
      write_results: [Google::Firestore::V1beta1::WriteResult.new(
        update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time))]
      )
  end

  it "basic" do
    set_json = "{\"a\": 1}"
    set_data = JSON.parse set_json

    set_writes = [
      Google::Firestore::V1beta1::Write.new(
        update: Google::Firestore::V1beta1::Document.new(
          name: "projects/projectID/databases/(default)/documents/C/d",
          fields: {
            "a" => Google::Firestore::V1beta1::Value.new(integer_value: 1)
          }
        )
      )
    ]

    firestore_mock.expect :commit, commit_resp, [database_path, set_writes, options: default_options]

    firestore.batch { |b| b.set document_path, set_data }
  end

  it "complex" do
    set_json = "{\"a\": [1, 2.5], \"b\": {\"c\": [\"three\", {\"d\": true}]}}"
    set_data = JSON.parse set_json

    set_writes = [
      Google::Firestore::V1beta1::Write.new(
        update: Google::Firestore::V1beta1::Document.new(
          name: "projects/projectID/databases/(default)/documents/C/d",
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

    firestore_mock.expect :commit, commit_resp, [database_path, set_writes, options: default_options]

    firestore.batch { |b| b.set document_path, set_data }
  end

  it "DELETE cannot be anywhere inside an array value" do
    set_data = { a: [1, { b: firestore.field_delete }] }

    error = expect do
      firestore.batch { |b| b.set document_path, set_data }
    end.must_raise ArgumentError
    error.message.must_equal "cannot nest delete under arrays"
  end

  it "DELETE cannot be in an array value" do
    set_data = { a: [1, 2, firestore.field_delete] }

    error = expect do
      firestore.batch { |b| b.set document_path, set_data }
    end.must_raise ArgumentError
    error.message.must_equal "cannot nest delete under arrays"
  end

  it "DELETE cannot appear in data" do
    set_data = { a: 1, b: firestore.field_delete }

    error = expect do
      firestore.batch { |b| b.set document_path, set_data }
    end.must_raise ArgumentError
    error.message.must_equal "DELETE not allowed on set"
  end

  it "creating or setting an empty map" do
    set_json = "{}"
    set_data = JSON.parse set_json

    set_writes = [
      Google::Firestore::V1beta1::Write.new(
        update: Google::Firestore::V1beta1::Document.new(
          name: "projects/projectID/databases/(default)/documents/C/d",
        )
      )
    ]

    firestore_mock.expect :commit, commit_resp, [database_path, set_writes, options: default_options]

    firestore.batch { |b| b.set document_path, set_data }
  end

  it "don't split on dots" do
    set_json = "{ \"a.b\": { \"c.d\": 1 }, \"e\": 2 }"
    set_data = JSON.parse set_json

    set_writes = [
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

    firestore_mock.expect :commit, commit_resp, [database_path, set_writes, options: default_options]

    firestore.batch { |b| b.set document_path, set_data }
  end

  describe :merge do
    it "DELETE cannot appear in an unmerged field" do
      merge_data = { a: 1, b: firestore.field_delete }

      error = expect do
        firestore.batch { |b| b.set document_path, merge_data, merge: [:a] }
      end.must_raise ArgumentError
      error.message.must_equal "deleted field not included in merge"
    end

    it "Merge with FieldPaths (array)" do
      set_json = "{\"*\": {\"~\": true}}"
      set_data = JSON.parse set_json

      set_writes = [
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

      firestore_mock.expect :commit, commit_resp, [database_path, set_writes, options: default_options]

      firestore.batch { |b| b.set document_path, set_data, merge: [["*", "~"]] }
    end

    it "Merge with FieldPaths (FieldPath)" do
      set_json = "{\"*\": {\"~\": true}}"
      set_data = JSON.parse set_json

      set_writes = [
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

      firestore_mock.expect :commit, commit_resp, [database_path, set_writes, options: default_options]

      firestore.batch { |b| b.set document_path, set_data, merge: firestore.field_path("*", "~") }
    end

    it "Merge with a nested field (array)" do
      set_json = "{\"h\": {\"g\": 4, \"f\": 5}}"
      set_data = JSON.parse set_json

      set_writes = [
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

      firestore_mock.expect :commit, commit_resp, [database_path, set_writes, options: default_options]

      firestore.batch { |b| b.set document_path, set_data, merge: [["h", "g"]] }
    end

    it "Merge with a nested field (FieldPath)" do
      set_json = "{\"h\": {\"g\": 4, \"f\": 5}}"
      set_data = JSON.parse set_json

      set_writes = [
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

      firestore_mock.expect :commit, commit_resp, [database_path, set_writes, options: default_options]

      firestore.batch { |b| b.set document_path, set_data, merge: firestore.field_path("h", "g") }
    end

    it "Merge with a nested field (string)" do
      set_json = "{\"h\": {\"g\": 4, \"f\": 5}}"
      set_data = JSON.parse set_json

      set_writes = [
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

      firestore_mock.expect :commit, commit_resp, [database_path, set_writes, options: default_options]

      firestore.batch { |b| b.set document_path, set_data, merge: ["h.g"] }
    end

    it "Merge field is not a leaf" do
      set_json = "{\"h\": {\"g\": 5, \"f\": 6}, \"e\": 7}"
      set_data = JSON.parse set_json

      set_writes = [
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

      firestore_mock.expect :commit, commit_resp, [database_path, set_writes, options: default_options]

      firestore.batch { |b| b.set document_path, set_data, merge: ["h"] }
    end

    it "If no ordinary values in Merge, no write" do
      set_data = { a: 1, b: firestore.field_server_time }

      set_writes = [
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

      firestore_mock.expect :commit, commit_resp, [database_path, set_writes, options: default_options]

      firestore.batch { |b| b.set document_path, set_data, merge: "b" }
    end

    it "Merge fields must all be present in data" do
      set_json = "{\"a\": 1}"
      set_data = JSON.parse set_json

      error = expect do
        firestore.batch { |b| b.set document_path, set_data, merge: ["b", "a"] }
      end.must_raise ArgumentError
      error.message.must_equal "all fields must be in data"
    end

    it "Merge with a field" do
      set_json = "{\"a\": 1, \"b\": 2}"
      set_data = JSON.parse set_json

      set_writes = [
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

      firestore_mock.expect :commit, commit_resp, [database_path, set_writes, options: default_options]

      firestore.batch { |b| b.set document_path, set_data, merge: "a" }
    end

    it "MergeAll can be specified with empty data" do
      set_json = "{}"
      set_data = JSON.parse set_json

      set_writes = [
        Google::Firestore::V1beta1::Write.new(
          update: Google::Firestore::V1beta1::Document.new(
            name: "projects/projectID/databases/(default)/documents/C/d",
            fields: {}
          ),
          update_mask: Google::Firestore::V1beta1::DocumentMask.new(
            field_paths: []
          )
        )
      ]

      firestore_mock.expect :commit, commit_resp, [database_path, set_writes, options: default_options]

      firestore.batch { |b| b.set document_path, set_data, merge: true }
    end

    it "MergeAll with nested fields" do
      set_json = "{\"h\": { \"g\": 3, \"f\": 4 }}"
      set_data = JSON.parse set_json

      set_writes = [
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
            field_paths: ["h.f", "h.g"]
          )
        )
      ]

      firestore_mock.expect :commit, commit_resp, [database_path, set_writes, options: default_options]

      firestore.batch { |b| b.set document_path, set_data, merge: true }
    end

    it "MergeAll" do
      set_json = "{\"a\": 1, \"b\": 2}"
      set_data = JSON.parse set_json

      set_writes = [
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

      firestore_mock.expect :commit, commit_resp, [database_path, set_writes, options: default_options]

      firestore.batch { |b| b.set document_path, set_data, merge: true }
    end
  end
end
