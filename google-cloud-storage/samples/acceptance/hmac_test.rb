# Copyright 2020 Google LLC
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

require_relative "helper"
require_relative "../storage_activate_hmac_key.rb"
require_relative "../storage_create_hmac_key.rb"
require_relative "../storage_deactivate_hmac_key.rb"
require_relative "../storage_delete_hmac_key.rb"
require_relative "../storage_get_hmac_key.rb"
require_relative "../storage_list_hmac_keys.rb"

# HMAC key tests are mocked due to the very limited quota of keys per project.
describe "HMAC Snippets" do
  let(:project) { "test" }
  let(:credentials) { OpenStruct.new(client: OpenStruct.new(updater_proc: proc {})) }
  let(:storage) { Google::Cloud::Storage::Project.new Google::Cloud::Storage::Service.new(project, credentials) }

  let(:access_id) { "my-access-id" }
  let(:service_account_email) { "my_service_account@gs-project-accounts.iam.gserviceaccount.com" }
  let :hmac_key_metadata_gapi do
    Google::Apis::StorageV1::HmacKeyMetadata.new(
      access_id:             access_id,
      etag:                  "123456",
      id:                    "test/#{access_id}",
      project_id:            "test",
      self_link:             "https://www.googleapis.com/storage/v1/b/bucket-name/keys/#{access_id}",
      service_account_email: service_account_email,
      state:                 "ACTIVE",
      time_created:          DateTime.now,
      updated:               DateTime.now
    )
  end
  let :hmac_keys_metadata_gapi do
    Google::Apis::StorageV1::HmacKeysMetadata.new(
      items: [hmac_key_metadata_gapi, hmac_key_metadata_gapi, hmac_key_metadata_gapi]
    )
  end
  let :hmac_key_gapi do
    Google::Apis::StorageV1::HmacKey.new(
      secret:   "0123456789012345678901234567890123456789",
      metadata: hmac_key_metadata_gapi
    )
  end

  it "list_hmac_keys" do
    mock = Minitest::Mock.new
    mock.expect :list_project_hmac_keys,
                hmac_keys_metadata_gapi,
                [
                  project,
                  max_results:           nil,
                  page_token:            nil,
                  service_account_email: nil,
                  show_deleted_keys:     nil,
                  user_project:          nil
                ]
    storage.service.mocked_service = mock

    Google::Cloud::Storage.stub :new, storage do
      out, _err = capture_io do
        list_hmac_keys
      end

      assert_includes out, "Service Account Email: #{service_account_email}"
      assert_includes out, "Access ID: #{access_id}"
    end
    mock.verify
  end

  it "create_hmac_key" do
    mock = Minitest::Mock.new
    mock.expect :create_project_hmac_key, hmac_key_gapi, ["test", service_account_email, user_project: nil]
    storage.service.mocked_service = mock

    Google::Cloud::Storage.stub :new, storage do
      out, _err = capture_io do
        create_hmac_key service_account_email: service_account_email
      end

      assert_match(/Access ID:\s+#{access_id}/, out)
      assert_match(/Service Account Email:\s+#{service_account_email}/, out)
    end
    mock.verify
  end

  it "get_hmac_key" do
    mock = Minitest::Mock.new
    mock.expect :get_project_hmac_key, hmac_key_metadata_gapi, [project, access_id, user_project: nil]
    storage.service.mocked_service = mock

    Google::Cloud::Storage.stub :new, storage do
      out, _err = capture_io do
        get_hmac_key access_id: access_id
      end

      assert_match(/Service Account Email:\s+#{service_account_email}/, out)
    end
    mock.verify
  end

  it "activate_hmac_key" do
    mock = Minitest::Mock.new
    inactive_gapi = hmac_key_metadata_gapi.dup
    inactive_gapi.state = "INACTIVE"
    mock.expect :get_project_hmac_key, inactive_gapi, [project, access_id, user_project: nil]
    # Expect any HmacKeyMetadata rather than `hmac_key_metadata_gapi` due to mock matching error.
    update_args = [project, access_id, Google::Apis::StorageV1::HmacKeyMetadata, { user_project: nil }]
    mock.expect :update_project_hmac_key, hmac_key_metadata_gapi, update_args
    storage.service.mocked_service = mock

    Google::Cloud::Storage.stub :new, storage do
      out, _err = capture_io do
        activate_hmac_key access_id: access_id
      end

      assert_match(/Service Account Email:\s+#{service_account_email}/, out)
    end
    mock.verify
  end

  it "deactivate_hmac_key" do
    mock = Minitest::Mock.new
    mock.expect :get_project_hmac_key, hmac_key_metadata_gapi, [project, access_id, user_project: nil]
    inactive_gapi = hmac_key_metadata_gapi.dup
    inactive_gapi.state = "INACTIVE"
    # Expect any HmacKeyMetadata rather than `inactive_gapi` due to mock matching error.
    update_args = [project, access_id, Google::Apis::StorageV1::HmacKeyMetadata, { user_project: nil }]
    mock.expect :update_project_hmac_key, inactive_gapi, update_args
    storage.service.mocked_service = mock

    Google::Cloud::Storage.stub :new, storage do
      out, _err = capture_io do
        deactivate_hmac_key access_id: access_id
      end

      assert_match(/Service Account Email:\s+#{service_account_email}/, out)
    end
    mock.verify
  end

  it "delete_hmac_key" do
    mock = Minitest::Mock.new
    mock.expect :get_project_hmac_key, hmac_key_metadata_gapi, [project, access_id, user_project: nil]
    mock.expect :delete_project_hmac_key, hmac_key_metadata_gapi, [project, access_id, { user_project: nil }]
    mock.expect :get_project_hmac_key, hmac_key_metadata_gapi, [project, access_id, { user_project: nil }]
    storage.service.mocked_service = mock

    Google::Cloud::Storage.stub :new, storage do
      assert_output "The key is deleted, though it may still appear in Client#hmac_keys results.\n" do
        delete_hmac_key access_id: access_id
      end
    end
    mock.verify
  end
end
