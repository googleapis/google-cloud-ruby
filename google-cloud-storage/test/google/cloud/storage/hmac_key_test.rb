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

describe Google::Cloud::Storage::HmacKey, :mock_storage do
  let(:access_id) { "my-access-id" }
  let(:service_account_email) { "my_service_account@gs-project-accounts.iam.gserviceaccount.com" }
  let(:other_project_id) { "my-other-project" }
  let(:hmac_key_metadata_gapi) do
    Google::Apis::StorageV1::HmacKeyMetadata.new(
      access_id: access_id,
      etag: "123456",
      id: "test/#{access_id}",
      project_id: "test",
      self_link: "https://www.googleapis.com/storage/v1/b/bucket-name/keys/#{access_id}",
      service_account_email: service_account_email,
      state: "ACTIVE",
      time_created: DateTime.now,
      updated: DateTime.now
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
  let(:hmac_key) { Google::Cloud::Storage::HmacKey.from_gapi hmac_key_gapi, storage.service }
  let(:hmac_key_user_project) { Google::Cloud::Storage::HmacKey.from_gapi hmac_key_gapi, storage.service, user_project: true }

  it "knows its attributes" do
    _(hmac_key.secret).must_equal hmac_key_gapi.secret

    _(hmac_key.access_id).must_equal hmac_key_metadata_gapi.access_id
    _(hmac_key.api_url).must_equal hmac_key_metadata_gapi.self_link
    _(hmac_key.created_at).must_equal hmac_key_metadata_gapi.time_created
    _(hmac_key.etag).must_equal hmac_key_metadata_gapi.etag
    _(hmac_key.id).must_equal hmac_key_metadata_gapi.id
    _(hmac_key.project_id).must_equal hmac_key_metadata_gapi.project_id
    _(hmac_key.service_account_email).must_equal hmac_key_metadata_gapi.service_account_email
    _(hmac_key.state).must_equal hmac_key_metadata_gapi.state
    _(hmac_key.updated_at).must_equal hmac_key_metadata_gapi.updated
  end

  it "exposes state query methods" do
    _(hmac_key.active?).must_equal true
    _(hmac_key.inactive?).must_equal false
    _(hmac_key.deleted?).must_equal false
  end

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_project_hmac_key, hmac_key_metadata_gapi, [project, access_id], user_project: nil, options: {}
    mock.expect :get_project_hmac_key, hmac_key_metadata_gapi, [project, access_id], user_project: nil, options: {}
    hmac_key.service.mocked_service = mock

    hmac_key.delete!

    mock.verify
  end

  it "can delete itself with a different project_id" do
    hmac_key.gapi.project_id = other_project_id

    mock = Minitest::Mock.new
    mock.expect :delete_project_hmac_key, hmac_key_metadata_gapi, [other_project_id, access_id], user_project: nil, options: {}
    mock.expect :get_project_hmac_key, hmac_key_metadata_gapi, [other_project_id, access_id], user_project: nil, options: {}
    hmac_key.service.mocked_service = mock

    hmac_key.delete!

    mock.verify
  end

  it "can delete itself with user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :delete_project_hmac_key, hmac_key_metadata_gapi, [project, access_id], user_project: "test", options: {}
    mock.expect :get_project_hmac_key, hmac_key_metadata_gapi, [project, access_id], user_project: "test", options: {}
    hmac_key_user_project.service.mocked_service = mock

    hmac_key_user_project.delete!

    mock.verify
  end

  it "can update its state to ACTIVE" do
    mock = Minitest::Mock.new
    update_gapi = hmac_key_metadata_gapi.dup
    update_gapi.state = "ACTIVE"
    mock.expect :update_project_hmac_key, hmac_key_metadata_gapi, [project, access_id, update_gapi], user_project: nil, options: {}
    hmac_key.service.mocked_service = mock

    hmac_key.active!

    mock.verify
  end

  it "can update its state to ACTIVE with a different project_id" do
    hmac_key.gapi.project_id = other_project_id

    mock = Minitest::Mock.new
    update_gapi = hmac_key_metadata_gapi.dup
    update_gapi.state = "ACTIVE"
    mock.expect :update_project_hmac_key, hmac_key_metadata_gapi, [other_project_id, access_id, update_gapi], user_project: nil, options: {}
    hmac_key.service.mocked_service = mock

    hmac_key.active!

    mock.verify
  end

  it "can update its state to ACTIVE with user_project set to true" do
    mock = Minitest::Mock.new
    update_gapi = hmac_key_metadata_gapi.dup
    update_gapi.state = "ACTIVE"
    mock.expect :update_project_hmac_key, hmac_key_metadata_gapi, [project, access_id, update_gapi], user_project: "test", options: {}
    hmac_key_user_project.service.mocked_service = mock

    hmac_key_user_project.active!

    mock.verify
  end

  it "can update its state to INACTIVE" do
    mock = Minitest::Mock.new
    update_gapi = hmac_key_metadata_gapi.dup
    update_gapi.state = "INACTIVE"
    mock.expect :update_project_hmac_key, hmac_key_metadata_gapi, [project, access_id, update_gapi], user_project: nil, options: {}
    hmac_key.service.mocked_service = mock

    hmac_key.inactive!

    mock.verify
  end

  it "can update its state to INACTIVE with user_project set to true" do
    mock = Minitest::Mock.new
    update_gapi = hmac_key_metadata_gapi.dup
    update_gapi.state = "INACTIVE"
    mock.expect :update_project_hmac_key, hmac_key_metadata_gapi, [project, access_id, update_gapi], user_project: "test", options: {}
    hmac_key_user_project.service.mocked_service = mock

    hmac_key_user_project.inactive!

    mock.verify
  end

  it "can reload itself" do
    mock = Minitest::Mock.new
    mock.expect :get_project_hmac_key, hmac_key_metadata_gapi, [project, access_id], user_project: nil, options: {}
    hmac_key.service.mocked_service = mock

    hmac_key.reload!

    mock.verify
  end

  it "can reload itself with a different project_id" do
    hmac_key.gapi.project_id = other_project_id

    mock = Minitest::Mock.new
    mock.expect :get_project_hmac_key, hmac_key_metadata_gapi, [other_project_id, access_id], user_project: nil, options: {}
    hmac_key.service.mocked_service = mock

    hmac_key.reload!

    mock.verify
  end

  it "can reload itself with user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :get_project_hmac_key, hmac_key_metadata_gapi, [project, access_id], user_project: "test", options: {}
    hmac_key_user_project.service.mocked_service = mock

    hmac_key_user_project.reload!

    mock.verify
  end
end
