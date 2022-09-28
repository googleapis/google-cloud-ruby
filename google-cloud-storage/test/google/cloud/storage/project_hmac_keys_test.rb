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
require "json"

describe Google::Cloud::Storage::Project, :hmac_keys, :mock_storage do
  let(:access_id) { "my-access-id" }
  let(:service_account_email) { "my_service_account@gs-project-accounts.iam.gserviceaccount.com" }
  let(:other_project_id) { "my-other-project" }
  let(:hmac_key_metadata_gapi) do
    Google::Apis::StorageV1::HmacKeyMetadata.new(
      access_id: access_id,
      service_account_email: service_account_email
    )
  end
  let(:hmac_keys_metadata_gapi) do
    Google::Apis::StorageV1::HmacKeysMetadata.new(
      items: [hmac_key_metadata_gapi, hmac_key_metadata_gapi, hmac_key_metadata_gapi]
    )
  end
  let(:hmac_key_gapi) do
    Google::Apis::StorageV1::HmacKey.new(
      secret: "0123456789012345678901234567890123456789",
      metadata: hmac_key_metadata_gapi
    )
  end

  it "creates an HMAC key" do
    mock = Minitest::Mock.new
    mock.expect :create_project_hmac_key, hmac_key_gapi, ["test", service_account_email], user_project: nil, options: {retries: 0}
    storage.service.mocked_service = mock

    hmac_key = storage.create_hmac_key service_account_email

    mock.verify

    _(hmac_key).must_be_kind_of Google::Cloud::Storage::HmacKey
    _(hmac_key.service_account_email).must_equal service_account_email
  end

  it "creates an HMAC key with project_id set to another project ID" do
    mock = Minitest::Mock.new
    hmac_key_gapi.metadata.project_id = other_project_id
    mock.expect :create_project_hmac_key, hmac_key_gapi, [other_project_id, service_account_email], user_project: nil, options: {retries: 0}
    storage.service.mocked_service = mock

    hmac_key = storage.create_hmac_key service_account_email, project_id: other_project_id

    mock.verify

    _(hmac_key).must_be_kind_of Google::Cloud::Storage::HmacKey
    _(hmac_key.project_id).must_equal other_project_id
  end

  it "creates an HMAC key with user_project set to another project ID" do
    mock = Minitest::Mock.new
    mock.expect :create_project_hmac_key, hmac_key_gapi, ["test", service_account_email], user_project: other_project_id, options: {retries: 0}
    storage.service.mocked_service = mock

    hmac_key = storage.create_hmac_key service_account_email, user_project: other_project_id

    mock.verify

    _(hmac_key).must_be_kind_of Google::Cloud::Storage::HmacKey
    _(hmac_key.user_project).must_equal other_project_id
  end

  it "lists HMAC keys" do
    mock = Minitest::Mock.new
    mock.expect :list_project_hmac_keys, hmac_keys_metadata_gapi, [project], max_results: nil, page_token: nil, service_account_email: nil, show_deleted_keys: nil, user_project: nil, options: {}
    storage.service.mocked_service = mock

    hmac_keys = storage.hmac_keys

    mock.verify

    _(hmac_keys.size).must_equal 3
  end

  it "lists HMAC keys with project_id set to another project ID" do
    mock = Minitest::Mock.new
    mock.expect :list_project_hmac_keys, hmac_keys_metadata_gapi, [other_project_id], max_results: nil, page_token: nil, service_account_email: nil, show_deleted_keys: nil, user_project: nil, options: {}
    storage.service.mocked_service = mock

    hmac_keys = storage.hmac_keys project_id: other_project_id

    mock.verify

    _(hmac_keys.size).must_equal 3
  end

  it "lists HMAC keys with service_account_email, show_deleted_keys and user_project options" do
    mock = Minitest::Mock.new
    mock.expect :list_project_hmac_keys, hmac_keys_metadata_gapi, [project], max_results: nil, page_token: nil, service_account_email: service_account_email, show_deleted_keys: true, user_project: other_project_id, options: {}
    storage.service.mocked_service = mock

    hmac_keys = storage.hmac_keys service_account_email: service_account_email, show_deleted_keys: true, user_project: other_project_id

    mock.verify

    _(hmac_keys.size).must_equal 3
  end

  it "paginates HMAC keys with token and max" do
    mock = Minitest::Mock.new
    hmac_keys_metadata_gapi_with_token = hmac_keys_metadata_gapi.dup
    hmac_keys_metadata_gapi_with_token.next_page_token = "next_page_token"
    mock.expect :list_project_hmac_keys, hmac_keys_metadata_gapi_with_token, [project], max_results: 3, page_token: nil, service_account_email: nil, show_deleted_keys: nil, user_project: nil, options: {}
    mock.expect :list_project_hmac_keys, hmac_keys_metadata_gapi, [project], max_results: 3, page_token: "next_page_token", service_account_email: nil, show_deleted_keys: nil, user_project: nil, options: {}
    storage.service.mocked_service = mock

    hmac_keys_1 = storage.hmac_keys max: 3
    hmac_keys_2 = storage.hmac_keys token: hmac_keys_1.token, max: 3

    mock.verify

    _(hmac_keys_1.size).must_equal 3
    _(hmac_keys_1.token).wont_be :nil?
    _(hmac_keys_1.token).must_equal "next_page_token"

    _(hmac_keys_2.count).must_equal 3
    _(hmac_keys_2.token).must_be :nil?
  end

  it "paginates HMAC keys with next? and next" do
    mock = Minitest::Mock.new
    hmac_keys_metadata_gapi_with_token = hmac_keys_metadata_gapi.dup
    hmac_keys_metadata_gapi_with_token.next_page_token = "next_page_token"
    mock.expect :list_project_hmac_keys, hmac_keys_metadata_gapi_with_token, [project], max_results: nil, page_token: nil, service_account_email: nil, show_deleted_keys: nil, user_project: nil, options: {}
    mock.expect :list_project_hmac_keys, hmac_keys_metadata_gapi, [project], max_results: nil, page_token: "next_page_token", service_account_email: nil, show_deleted_keys: nil, user_project: nil, options: {}
    storage.service.mocked_service = mock

    hmac_keys_1 = storage.hmac_keys
    hmac_keys_2 = hmac_keys_1.next

    mock.verify

    _(hmac_keys_1.size).must_equal 3
    _(hmac_keys_1.next?).must_equal true
    _(hmac_keys_1.token).must_equal "next_page_token"

    _(hmac_keys_2.count).must_equal 3
    _(hmac_keys_2.token).must_be :nil?
    _(hmac_keys_2.next?).must_equal false
  end

  it "paginates HMAC keys with all" do
    mock = Minitest::Mock.new
    hmac_keys_metadata_gapi_with_token = hmac_keys_metadata_gapi.dup
    hmac_keys_metadata_gapi_with_token.next_page_token = "next_page_token"
    mock.expect :list_project_hmac_keys, hmac_keys_metadata_gapi_with_token, [project], max_results: nil, page_token: nil, service_account_email: nil, show_deleted_keys: nil, user_project: nil, options: {}
    mock.expect :list_project_hmac_keys, hmac_keys_metadata_gapi, [project], max_results: nil, page_token: "next_page_token", service_account_email: nil, show_deleted_keys: nil, user_project: nil, options: {}
    storage.service.mocked_service = mock

    hmac_keys = storage.hmac_keys.all.to_a

    mock.verify

    _(hmac_keys.size).must_equal 6
  end

  it "iterates HMAC keys with all using Enumerator" do
    mock = Minitest::Mock.new
    hmac_keys_metadata_gapi_with_token = hmac_keys_metadata_gapi.dup
    hmac_keys_metadata_gapi_with_token.next_page_token = "next_page_token"
    mock.expect :list_project_hmac_keys, hmac_keys_metadata_gapi_with_token, [project], max_results: nil, page_token: nil, service_account_email: nil, show_deleted_keys: nil, user_project: nil, options: {}
    mock.expect :list_project_hmac_keys, hmac_keys_metadata_gapi, [project], max_results: nil, page_token: "next_page_token", service_account_email: nil, show_deleted_keys: nil, user_project: nil, options: {}
    storage.service.mocked_service = mock

    hmac_keys = storage.hmac_keys.all.take 5

    mock.verify

    _(hmac_keys.size).must_equal 5
  end

  it "iterates HMAC keys with all and request_limit and user_project set to another project ID" do
    mock = Minitest::Mock.new
    hmac_keys_metadata_gapi_with_token = hmac_keys_metadata_gapi.dup
    hmac_keys_metadata_gapi_with_token.next_page_token = "next_page_token"
    mock.expect :list_project_hmac_keys, hmac_keys_metadata_gapi_with_token, [project], max_results: nil, page_token: nil, service_account_email: nil, show_deleted_keys: nil, user_project: other_project_id, options: {}
    mock.expect :list_project_hmac_keys, hmac_keys_metadata_gapi, [project], max_results: nil, page_token: "next_page_token", service_account_email: nil, show_deleted_keys: nil, user_project: other_project_id, options: {}
    storage.service.mocked_service = mock

    hmac_keys = storage.hmac_keys(user_project: other_project_id).all(request_limit: 1).to_a

    mock.verify

    _(hmac_keys.size).must_equal 6
  end

  it "finds an HMAC key" do
    mock = Minitest::Mock.new
    mock.expect :get_project_hmac_key, hmac_key_metadata_gapi, [project, access_id], user_project: nil, options: {}
    storage.service.mocked_service = mock

    hmac_key = storage.hmac_key access_id

    mock.verify

    _(hmac_key.access_id).must_equal access_id
  end

  it "finds an HMAC key with project_id set to another project ID" do
    mock = Minitest::Mock.new
    hmac_key_metadata_gapi.project_id = other_project_id
    mock.expect :get_project_hmac_key, hmac_key_metadata_gapi, [other_project_id, access_id], user_project: nil, options: {}
    storage.service.mocked_service = mock

    hmac_key = storage.hmac_key access_id, project_id: other_project_id

    mock.verify

    _(hmac_key.project_id).must_equal other_project_id
  end

  it "finds an HMAC key with user_project set to another project ID" do
    mock = Minitest::Mock.new
    mock.expect :get_project_hmac_key, hmac_key_metadata_gapi, [project, access_id], user_project: other_project_id, options: {}
    storage.service.mocked_service = mock

    hmac_key = storage.hmac_key access_id, user_project: other_project_id

    mock.verify

    _(hmac_key.user_project).must_equal other_project_id
  end
end
