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

describe Google::Cloud::Firestore::DocumentReference, :values, :mock_firestore do
  let(:document_path) { "users/mike" }
  let(:document) { Google::Cloud::Firestore::DocumentReference.from_path "#{documents_path}/#{document_path}", firestore }

  let(:document_path) { "users/mike" }
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

  def update_write field
    [Google::Firestore::V1beta1::Write.new(
      update: Google::Firestore::V1beta1::Document.new(
        name: "#{documents_path}/#{document_path}",
        fields: {
          "val" => field
        }
      ),
      update_mask: Google::Firestore::V1beta1::DocumentMask.new(
        field_paths: ["val"]
      ),
      current_document: Google::Firestore::V1beta1::Precondition.new(
        exists: true)
    )]
  end

  it "updates a document data with a nil" do
    field = Google::Firestore::V1beta1::Value.new null_value: :NULL_VALUE

    firestore_mock.expect :commit, commit_resp, [database_path, update_write(field), options: default_options]

    resp = document.update({ val: nil })

    resp.must_be_kind_of Google::Cloud::Firestore::CommitResponse::WriteResult
    resp.update_time.must_equal commit_time
  end

  it "updates a document data with a true" do
    field = Google::Firestore::V1beta1::Value.new boolean_value: true
    firestore_mock.expect :commit, commit_resp, [database_path, update_write(field), options: default_options]

    resp = document.update({ val: true })

    resp.must_be_kind_of Google::Cloud::Firestore::CommitResponse::WriteResult
    resp.update_time.must_equal commit_time
  end

  it "updates a document data with a false" do
    field = Google::Firestore::V1beta1::Value.new boolean_value: false
    firestore_mock.expect :commit, commit_resp, [database_path, update_write(field), options: default_options]

    resp = document.update({ val: false })

    resp.must_be_kind_of Google::Cloud::Firestore::CommitResponse::WriteResult
    resp.update_time.must_equal commit_time
  end

  it "updates a document data with a nan" do
    field = Google::Firestore::V1beta1::Value.new double_value: Float::NAN
    firestore_mock.expect :commit, commit_resp, [database_path, update_write(field), options: default_options]

    resp = document.update({ val: Float::NAN })

    resp.must_be_kind_of Google::Cloud::Firestore::CommitResponse::WriteResult
    resp.update_time.must_equal commit_time
  end

  it "updates a document data with infinity" do
    field = Google::Firestore::V1beta1::Value.new double_value: Float::INFINITY
    firestore_mock.expect :commit, commit_resp, [database_path, update_write(field), options: default_options]

    resp = document.update({ val: Float::INFINITY })

    resp.must_be_kind_of Google::Cloud::Firestore::CommitResponse::WriteResult
    resp.update_time.must_equal commit_time
  end

  it "updates a document data with an int" do
    field = Google::Firestore::V1beta1::Value.new integer_value: 42
    firestore_mock.expect :commit, commit_resp, [database_path, update_write(field), options: default_options]

    resp = document.update({ val: 42 })

    resp.must_be_kind_of Google::Cloud::Firestore::CommitResponse::WriteResult
    resp.update_time.must_equal commit_time
  end

  it "updates a document data with a float" do
    field = Google::Firestore::V1beta1::Value.new double_value: 3.14
    firestore_mock.expect :commit, commit_resp, [database_path, update_write(field), options: default_options]

    resp = document.update({ val: 3.14 })

    resp.must_be_kind_of Google::Cloud::Firestore::CommitResponse::WriteResult
    resp.update_time.must_equal commit_time
  end

  it "updates a document data with a time" do
    field = Google::Firestore::V1beta1::Value.new timestamp_value: Google::Cloud::Firestore::Convert.time_to_timestamp(commit_time)
    firestore_mock.expect :commit, commit_resp, [database_path, update_write(field), options: default_options]

    resp = document.update({ val: commit_time })

    resp.must_be_kind_of Google::Cloud::Firestore::CommitResponse::WriteResult
    resp.update_time.must_equal commit_time
  end

  it "updates a document data with a string" do
    field = Google::Firestore::V1beta1::Value.new string_value: "hello"
    firestore_mock.expect :commit, commit_resp, [database_path, update_write(field), options: default_options]

    resp = document.update({ val: "hello" })

    resp.must_be_kind_of Google::Cloud::Firestore::CommitResponse::WriteResult
    resp.update_time.must_equal commit_time
  end

  it "updates a document data with a IO" do
    field = Google::Firestore::V1beta1::Value.new bytes_value: "world"
    firestore_mock.expect :commit, commit_resp, [database_path, update_write(field), options: default_options]

    resp = document.update({ val: StringIO.new("world") })

    resp.must_be_kind_of Google::Cloud::Firestore::CommitResponse::WriteResult
    resp.update_time.must_equal commit_time
  end

  it "updates a document data with a doc ref" do
    field = Google::Firestore::V1beta1::Value.new reference_value: "projects/projectID/databases/(default)/documents/C/d"
    firestore_mock.expect :commit, commit_resp, [database_path, update_write(field), options: default_options]

    resp = document.update({ val: firestore.doc("C/d") })

    resp.must_be_kind_of Google::Cloud::Firestore::CommitResponse::WriteResult
    resp.update_time.must_equal commit_time
  end

  it "updates a document data with a geo point" do
    field = Google::Firestore::V1beta1::Value.new geo_point_value: Google::Type::LatLng.new(latitude: -122.947778, longitude: 50.1430847)
    firestore_mock.expect :commit, commit_resp, [database_path, update_write(field), options: default_options]

    resp = document.update({ val: { longitude: 50.1430847, latitude: -122.947778 } })

    resp.must_be_kind_of Google::Cloud::Firestore::CommitResponse::WriteResult
    resp.update_time.must_equal commit_time
  end

  it "updates a document data with an array" do
    field = Google::Firestore::V1beta1::Value.new(
      array_value: Google::Firestore::V1beta1::ArrayValue.new(
        values: [
          Google::Firestore::V1beta1::Value.new(integer_value: 1),
          Google::Firestore::V1beta1::Value.new(double_value: 2.0),
          Google::Firestore::V1beta1::Value.new(string_value: "3")
        ]
      )
    )
    firestore_mock.expect :commit, commit_resp, [database_path, update_write(field), options: default_options]

    resp = document.update({ val: [1, 2.0, "3"] })

    resp.must_be_kind_of Google::Cloud::Firestore::CommitResponse::WriteResult
    resp.update_time.must_equal commit_time
  end

  it "updates a document data with a hash" do
    field = Google::Firestore::V1beta1::Value.new(
      map_value: Google::Firestore::V1beta1::MapValue.new(
        fields: {
            "hello" => Google::Firestore::V1beta1::Value.new(string_value: "word")
          }
      )
    )
    firestore_mock.expect :commit, commit_resp, [database_path, update_write(field), options: default_options]

    resp = document.update({ val: { hello: "word" } })

    resp.must_be_kind_of Google::Cloud::Firestore::CommitResponse::WriteResult
    resp.update_time.must_equal commit_time
  end
end
