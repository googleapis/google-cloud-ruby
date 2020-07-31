# Copyright 2019 Google LLC
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

describe Google::Cloud::Firestore::CollectionReference, :list_documents, :mock_firestore do
  let(:collection_id) { "messages" }
  let(:collection_path) { "users/mike/#{collection_id}" }
  let(:collection) { Google::Cloud::Firestore::CollectionReference.from_path "projects/#{project}/databases/(default)/documents/#{collection_path}", firestore }

  it "lists documents" do
    num_documents = 3

    list_res = OpenStruct.new(page: OpenStruct.new(response: list_documents_gapi(num_documents)))

    firestore_mock.expect :list_documents, list_res, list_documents_args

    documents = collection.list_documents

    firestore_mock.verify

    documents.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::DocumentReference }
    _(documents.size).must_equal num_documents
  end

  it "paginates documents" do
    first_list_res = OpenStruct.new(page: OpenStruct.new(response: list_documents_gapi(3, "next_page_token")))
    second_list_res = OpenStruct.new(page: OpenStruct.new(response: list_documents_gapi(2)))

    firestore_mock.expect :list_documents, first_list_res, list_documents_args
    firestore_mock.expect :list_documents, second_list_res, list_documents_args(options: token_options("next_page_token"))

    first_documents = collection.list_documents
    second_documents = collection.list_documents token: first_documents.token

    firestore_mock.verify

    first_documents.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::DocumentReference }
    _(first_documents.count).must_equal 3
    _(first_documents.token).wont_be :nil?
    _(first_documents.token).must_equal "next_page_token"

    second_documents.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::DocumentReference }
    _(second_documents.count).must_equal 2
    _(second_documents.token).must_be :nil?
  end

  it "paginates documents using next? and next" do
    first_list_res = OpenStruct.new(page: OpenStruct.new(response: list_documents_gapi(3, "next_page_token")))
    second_list_res = OpenStruct.new(page: OpenStruct.new(response: list_documents_gapi(2)))

    firestore_mock.expect :list_documents, first_list_res, list_documents_args
    firestore_mock.expect :list_documents, second_list_res, list_documents_args(options: token_options("next_page_token"))

    first_documents = collection.list_documents
    second_documents = first_documents.next

    firestore_mock.verify

    first_documents.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::DocumentReference }
    _(first_documents.count).must_equal 3
    _(first_documents.next?).must_equal true #must_be :next?

    second_documents.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::DocumentReference }
    _(second_documents.count).must_equal 2
    _(second_documents.next?).must_equal false #wont_be :next?
  end

  it "paginates documents using all" do
    first_list_res = OpenStruct.new(page: OpenStruct.new(response: list_documents_gapi(3, "next_page_token")))
    second_list_res = OpenStruct.new(page: OpenStruct.new(response: list_documents_gapi(2)))

    firestore_mock.expect :list_documents, first_list_res, list_documents_args
    firestore_mock.expect :list_documents, second_list_res, list_documents_args(options: token_options("next_page_token"))

    all_documents = collection.list_documents.all.to_a

    firestore_mock.verify

    all_documents.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::DocumentReference }
    _(all_documents.count).must_equal 5
  end

  it "paginates documents using all using Enumerator" do
    first_list_res = OpenStruct.new(page: OpenStruct.new(response: list_documents_gapi(3, "next_page_token")))
    second_list_res = OpenStruct.new(page: OpenStruct.new(response: list_documents_gapi(3, "second_page_token")))

    firestore_mock.expect :list_documents, first_list_res, list_documents_args
    firestore_mock.expect :list_documents, second_list_res, list_documents_args(options: token_options("next_page_token"))

    all_documents = collection.list_documents.all.take(5)

    firestore_mock.verify

    all_documents.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::DocumentReference }
    _(all_documents.count).must_equal 5
  end

  it "paginates documents using all with request_limit set" do
    first_list_res = OpenStruct.new(page: OpenStruct.new(response: list_documents_gapi(3, "next_page_token")))
    second_list_res = OpenStruct.new(page: OpenStruct.new(response: list_documents_gapi(3, "second_page_token")))

    firestore_mock.expect :list_documents, first_list_res, list_documents_args
    firestore_mock.expect :list_documents, second_list_res, list_documents_args(options: token_options("next_page_token"))

    all_documents = collection.list_documents.all(request_limit: 1).to_a

    firestore_mock.verify

    all_documents.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::DocumentReference }
    _(all_documents.count).must_equal 6
  end

  it "paginates documents with max set" do
    list_res = OpenStruct.new(page: OpenStruct.new(response: list_documents_gapi(3, "next_page_token")))

    firestore_mock.expect :list_documents, list_res, list_documents_args(page_size: 3)

    documents = collection.list_documents max: 3

    firestore_mock.verify

    documents.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::DocumentReference }
    _(documents.count).must_equal 3
    _(documents.token).wont_be :nil?
    _(documents.token).must_equal "next_page_token"
  end

  it "paginates documents without max set" do
    list_res = OpenStruct.new(page: OpenStruct.new(response: list_documents_gapi(3, "next_page_token")))

    firestore_mock.expect :list_documents, list_res, list_documents_args

    documents = collection.list_documents

    firestore_mock.verify

    documents.each { |m| _(m).must_be_kind_of Google::Cloud::Firestore::DocumentReference }
    _(documents.count).must_equal 3
    _(documents.token).wont_be :nil?
    _(documents.token).must_equal "next_page_token"
  end

  def document_gapi
    Google::Firestore::V1::Document.new(
      name: "projects/#{project}/databases/(default)/documents/my-document",
      fields: {},
      create_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now),
      update_time: Google::Cloud::Firestore::Convert.time_to_timestamp(Time.now)
    )
  end

  def list_documents_gapi count = 2, token = nil
    Google::Firestore::V1::ListDocumentsResponse.new(
      documents: count.times.map { document_gapi },
      next_page_token: token
    )
  end

  def paged_enum_struct response
    OpenStruct.new response: response
  end

  def token_options token
    Google::Gax::CallOptions.new(page_token: token)
  end

  def list_documents_args page_size: nil, options: nil
    ["projects/projectID/databases/(default)/documents/users/mike", "messages", {mask: {field_paths: []}, show_missing: true, page_size: page_size, options: options}]
  end
end
