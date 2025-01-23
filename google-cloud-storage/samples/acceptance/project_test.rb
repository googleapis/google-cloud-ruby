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
require_relative "../storage_get_soft_deleted_bucket"
require_relative "../storage_get_bucket_class_and_location"

describe "Storage Quickstart" do
  let(:project) { Google::Cloud::Storage.new }
  let(:bucket) { fixture_bucket }
  let(:generation) { bucket.generation }
  let(:new_bucket_name) { random_bucket_name }

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
  let(:storage_client) { Google::Cloud::Storage.new }
  let(:bucket) { fixture_bucket }
  let(:generation) { bucket.generation }
  let(:new_bucket_name) { random_bucket_name }


  it "get soft deleted bucket, its soft_delete_time and hard_delete_time" do
    new_bucket = storage_client.create_bucket new_bucket_name
    new_generation = new_bucket.generation
    # Check if the bucket exist
    puts new_bucket.policy.roles
    assert new_bucket.exists?, "Bucket #{new_bucket_name} should exist"
    check_bucket = storage_client.bucket new_bucket_name
    puts "new bucket name-- #{check_bucket.name}"
    puts "new bucket generation-- #{check_bucket.generation}"

    delete_bucket_helper new_bucket_name
    # Check if the bucket does not exist
    deleted_bucket = storage_client.bucket new_bucket_name
    refute deleted_bucket, "Bucket #{new_bucket_name} should not exist"

    # deleted_bucket_fetch = storage_client.bucket new_bucket_name, generation: new_generation, soft_deleted: true
    # output, _err = capture_io do
    #   get_soft_deleted_bucket bucket_name: new_bucket_name, generation: new_generation
    # end
    # assert_includes output, "soft_delete_time for #{new_bucket_name} is"

    _out, _err = capture_io do
      restore_bucket bucket_name: new_bucket_name, generation: new_generation
    end

    restored_bucket = storage_client.create_bucket new_bucket_name
    assert restored_bucket.exists?, "Bucket #{new_bucket_name} should exist"

  end

  # it "restores a soft deleted bucket" do
  #   delete_bucket_helper bucket.name
  #   _out, _err = capture_io do
  #     restore_bucket bucket_name: bucket.name, generation: generation
  #   end
  #   assert "soft_delete_time", "#{bucket.name} Bucket restored"
  # end
end
