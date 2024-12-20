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
require_relative "../storage_get_service_account"
require_relative "../storage_restore_bucket"

describe "Storage Quickstart" do
  let(:project) { Google::Cloud::Storage.new }

  it "get_service_account" do
    email = nil
    out, _err = capture_io do
      email = get_service_account
    end
    assert_includes out,
                    "The GCS service account for project #{project.project_id} is: #{project.service_account_email}"
    assert_includes out, "@gs-project-accounts.iam.gserviceaccount.com"
  end
end

describe "storage_soft_deleted_bucket" do
  let(:storage_client)  { Google::Cloud::Storage.new }
  let(:bucket) { fixture_bucket }
  let(:generation) { bucket.gapi.generation }

  it "restores a soft deleted bucket" do
    bucket.delete
    _out, _err = capture_io do
      restore_bucket bucket_name: bucket.name, generation: generation
    end
    assert "soft_delete_time", "#{bucket.name} Bucket restored"
  end
end
