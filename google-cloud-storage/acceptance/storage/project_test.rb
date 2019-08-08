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

require "storage_helper"

describe Google::Cloud::Storage::Project, :storage do
  it "should get its project service account email" do
    email = storage.service_account_email
    email.wont_be :nil?
    email.must_be_kind_of String
    # https://stackoverflow.com/questions/22993545/ruby-email-validation-with-regex
    email.must_match /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  end

  it "should create a new HMAC key" do
    hmac_key = nil
    begin
      service_account_email = storage.service.credentials.client.issuer
      # Create key.
      hmac_key = storage.create_hmac_key service_account_email

      hmac_key.wont_be :nil?
      hmac_key.must_be_kind_of Google::Cloud::Storage::HmacKey

      # Check response fields.
      hmac_key.secret.must_be_kind_of String
      hmac_key.secret.length.must_equal 40

      hmac_key.access_id.must_be_kind_of String
      hmac_key.project_id.must_equal storage.project_id
      hmac_key.etag.must_be_kind_of String
      hmac_key.id.must_be_kind_of String
      hmac_key.created_at.must_be_kind_of DateTime
      hmac_key.updated_at.must_be_kind_of DateTime
      hmac_key.service_account_email.must_equal service_account_email
      hmac_key.state.must_equal "ACTIVE"
      hmac_key.must_be :active?

      hmac_keys = storage.hmac_keys
      hmac_keys.wont_be :empty?

      # Verify it shows up in list.
      hmac_key_list_item = hmac_keys.find { |k| k.access_id == hmac_key.access_id }
      hmac_key_list_item.wont_be :nil?

      # sleep to ensure etag consistency
      sleep 1

      # GET the key.
      hmac_key.reload!

      # Update key to INACTIVE state
      hmac_key_list_item.inactive!
      hmac_key_list_item.state.must_equal "INACTIVE"
      hmac_key_list_item.must_be :inactive?

      # Delete key.
      hmac_key.delete!
      hmac_key.state.must_equal "DELETED"
      hmac_key.must_be :deleted?

      # Verify it does not show up in list.
      hmac_keys = storage.hmac_keys
      hmac_key_list_item = hmac_keys.find { |k| k.access_id == hmac_key.access_id }
      hmac_key_list_item.must_be :nil?

      # GET the deleted key.
      hmac_key = storage.hmac_key hmac_key.access_id # similar to reload! above
      hmac_key.state.must_equal "DELETED"
      hmac_key.must_be :deleted?
    ensure
      if hmac_key && !hmac_key.deleted?
        safe_gcs_execute { hmac_key.inactive! }
        safe_gcs_execute { hmac_key.delete! }
      end
    end
  end
end
