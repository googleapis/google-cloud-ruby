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

describe "Cross-Language Create Tests", :mock_firestore do
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
    create_json = "{\"a\": 1}"
    create_data = JSON.parse create_json

    create_writes = [
      Google::Firestore::V1beta1::Write.new(
        update: Google::Firestore::V1beta1::Document.new(
          name: "projects/projectID/databases/(default)/documents/C/d",
          fields: {
            "a" => Google::Firestore::V1beta1::Value.new(integer_value: 1)
          }
        ),
        current_document: Google::Firestore::V1beta1::Precondition.new(
          exists: false)
      )
    ]

    firestore_mock.expect :commit, commit_resp, [database_path, create_writes, options: default_options]

    firestore.batch { |b| b.create document_path, create_data }
  end

  it "complex" do
    create_json = "{\"a\": [1, 2.5], \"b\": {\"c\": [\"three\", {\"d\": true}]}}"
    create_data = JSON.parse create_json

    create_writes = [
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
        ),
        current_document: Google::Firestore::V1beta1::Precondition.new(
          exists: false)
      )
    ]

    firestore_mock.expect :commit, commit_resp, [database_path, create_writes, options: default_options]

    firestore.batch { |b| b.create document_path, create_data }
  end

  it "creating or setting an empty map" do
    create_json = "{}"
    create_data = JSON.parse create_json

    create_writes = [
      Google::Firestore::V1beta1::Write.new(
        update: Google::Firestore::V1beta1::Document.new(
          name: "projects/projectID/databases/(default)/documents/C/d",
        ),
        current_document: Google::Firestore::V1beta1::Precondition.new(
          exists: false)
      )
    ]

    firestore_mock.expect :commit, commit_resp, [database_path, create_writes, options: default_options]

    firestore.batch { |b| b.create document_path, create_data }
  end

  it "don't split on dots" do
    create_json = "{ \"a.b\": { \"c.d\": 1 }, \"e\": 2 }"
    create_data = JSON.parse create_json

    create_writes = [
      Google::Firestore::V1beta1::Write.new(
        update: Google::Firestore::V1beta1::Document.new(
          name: "projects/projectID/databases/(default)/documents/C/d",
          fields: {
            "a.b" => Google::Firestore::V1beta1::Value.new(map_value: Google::Firestore::V1beta1::MapValue.new(fields: {
              "c.d" => Google::Firestore::V1beta1::Value.new(integer_value: 1)
            })),
            "e" => Google::Firestore::V1beta1::Value.new(integer_value: 2)
          }
        ),
        current_document: Google::Firestore::V1beta1::Precondition.new(
          exists: false)
      )
    ]

    firestore_mock.expect :commit, commit_resp, [database_path, create_writes, options: default_options]

    firestore.batch { |b| b.create document_path, create_data }
  end

  it "non-alpha characters in map keys" do
    create_json = "{ \"*\": { \".\": 1 }, \"~\": 2 }"
    create_data = JSON.parse create_json

    create_writes = [
      Google::Firestore::V1beta1::Write.new(
        update: Google::Firestore::V1beta1::Document.new(
          name: "projects/projectID/databases/(default)/documents/C/d",
          fields: {
            "*" => Google::Firestore::V1beta1::Value.new(map_value: Google::Firestore::V1beta1::MapValue.new(fields: {
              "." => Google::Firestore::V1beta1::Value.new(integer_value: 1)
            })),
            "~" => Google::Firestore::V1beta1::Value.new(integer_value: 2)
          }
        ),
        current_document: Google::Firestore::V1beta1::Precondition.new(
          exists: false)
      )
    ]

    firestore_mock.expect :commit, commit_resp, [database_path, create_writes, options: default_options]

    firestore.batch { |b| b.create document_path, create_data }
  end

  describe :field_delete do
    it "DELETE cannot appear in data" do
      create_data = { a: 1, b: firestore.field_delete}

      error = expect do
        firestore.batch { |b| b.create document_path, create_data }
      end.must_raise ArgumentError
      error.message.must_equal "DELETE not allowed on create"
    end
  end

  describe :field_server_time do

    it "SERVER_TIME alone" do
      create_data = { a: firestore.field_server_time }

      create_writes = [
        Google::Firestore::V1beta1::Write.new(
          transform: Google::Firestore::V1beta1::DocumentTransform.new(
            document: "projects/projectID/databases/(default)/documents/C/d",
            field_transforms: [
              Google::Firestore::V1beta1::DocumentTransform::FieldTransform.new(
                field_path: "a",
                set_to_server_value: :REQUEST_TIME
              )
            ]
          ),
          current_document: Google::Firestore::V1beta1::Precondition.new(
            exists: false)
        )
      ]

      firestore_mock.expect :commit, commit_resp, [database_path, create_writes, options: default_options]

      firestore.batch { |b| b.create document_path, create_data }
    end

    it "multiple SERVER_TIME fields" do
      create_data = { a: 1, b: firestore.field_server_time, c: { d: firestore.field_server_time } }

      create_writes = [
        Google::Firestore::V1beta1::Write.new(
          update: Google::Firestore::V1beta1::Document.new(
            name: "projects/projectID/databases/(default)/documents/C/d",
            fields: {
              "a" => Google::Firestore::V1beta1::Value.new(integer_value: 1)
            }
          ),
          current_document: Google::Firestore::V1beta1::Precondition.new(
            exists: false)
        ),
        Google::Firestore::V1beta1::Write.new(
          transform: Google::Firestore::V1beta1::DocumentTransform.new(
            document: "projects/projectID/databases/(default)/documents/C/d",
            field_transforms: [
              Google::Firestore::V1beta1::DocumentTransform::FieldTransform.new(
                field_path: "b",
                set_to_server_value: :REQUEST_TIME
              ),
              Google::Firestore::V1beta1::DocumentTransform::FieldTransform.new(
                field_path: "c.d",
                set_to_server_value: :REQUEST_TIME
              )
            ]
          )
        )
      ]

      firestore_mock.expect :commit, commit_resp, [database_path, create_writes, options: default_options]

      firestore.batch { |b| b.create document_path, create_data }
    end

    it "nested SERVER_TIME field" do
      create_data = { a: 1, b: { c: firestore.field_server_time } }

      create_writes = [
        Google::Firestore::V1beta1::Write.new(
          update: Google::Firestore::V1beta1::Document.new(
            name: "projects/projectID/databases/(default)/documents/C/d",
            fields: {
              "a" => Google::Firestore::V1beta1::Value.new(integer_value: 1)
            }
          ),
          current_document: Google::Firestore::V1beta1::Precondition.new(
            exists: false)
        ),
        Google::Firestore::V1beta1::Write.new(
          transform: Google::Firestore::V1beta1::DocumentTransform.new(
            document: "projects/projectID/databases/(default)/documents/C/d",
            field_transforms: [
              Google::Firestore::V1beta1::DocumentTransform::FieldTransform.new(
                field_path: "b.c",
                set_to_server_value: :REQUEST_TIME
              )
            ]
          )
        )
      ]

      firestore_mock.expect :commit, commit_resp, [database_path, create_writes, options: default_options]

      firestore.batch { |b| b.create document_path, create_data }
    end

    it "SERVER_TIME cannot be anywhere inside an array value" do
      create_data = { a: [1, { b: firestore.field_server_time }] }

      error = expect do
        firestore.batch { |b| b.create document_path, create_data }
      end.must_raise ArgumentError
      error.message.must_equal "cannot nest server_time under arrays"
    end

    it "SERVER_TIME cannot be in an array value" do
      create_data = { a: [1, 2, firestore.field_server_time] }

      error = expect do
        firestore.batch { |b| b.create document_path, create_data }
      end.must_raise ArgumentError
      error.message.must_equal "cannot nest server_time under arrays"
    end

    it "SERVER_TIME with data" do
      create_data = { a: 1, b: firestore.field_server_time }

      create_writes = [
        Google::Firestore::V1beta1::Write.new(
          update: Google::Firestore::V1beta1::Document.new(
            name: "projects/projectID/databases/(default)/documents/C/d",
            fields: {
              "a" => Google::Firestore::V1beta1::Value.new(integer_value: 1)
            }
          ),
          current_document: Google::Firestore::V1beta1::Precondition.new(
            exists: false)
        ),
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

      firestore_mock.expect :commit, commit_resp, [database_path, create_writes, options: default_options]

      firestore.batch { |b| b.create document_path, create_data }
    end
  end
end
