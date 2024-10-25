# Copyright 2024 Google LLC
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

describe Google::Cloud::Storage::Bucket, :soft_delete, :storage do
  let(:bucket_name) { $bucket_names[0] }
  let :bucket do
    storage.bucket(bucket_name) ||
    safe_gcs_execute { storage.create_bucket(bucket_name) }
  end
  let(:soft_delete_policy) { { retention_duration_seconds: 10*24*60*60 } } # 10 days
  let(:file_path) { "acceptance/data/CloudPlatform_128px_Retina.png" }
  let(:file_name) { "CloudLogo1" }

  before do
    bucket.files.all { |f| f.delete rescue nil }
    file = bucket.create_file file_path, file_name
  end

  describe "Soft delete policy" do
    it "sets the soft delete policy" do
      _(bucket.soft_delete_policy).wont_be_nil

      bucket.soft_delete_policy = soft_delete_policy
      _(bucket.soft_delete_policy.retention_duration_seconds).must_equal 10*24*60*60
    end

    it "fetches soft deleted file" do
      file = bucket.file file_name
      generation = file.generation
      _(file.soft_delete_time).must_be_nil
      _(file.hard_delete_time).must_be_nil

      deleted_file = bucket.file file_name, soft_deleted: true, generation: generation
      _(deleted_file).must_be_nil

      file.delete

      file = bucket.file file_name, soft_deleted: true, generation: generation
      _(file).wont_be_nil
      _(file.soft_delete_time).wont_be_nil
      _(file.hard_delete_time).wont_be_nil
    end

    it "lists soft deleted files" do
      file = bucket.file file_name
      file.delete

      files = bucket.files soft_deleted: true
      _(files).wont_be_empty
    end

    it "restores the deleted file" do
      file = bucket.file file_name
      generation = file.generation
      file.delete

      restored_file = bucket.restore_file file_name, generation

      file = bucket.file file_name
      _(file).wont_be_nil
      _(file.exists?).must_equal true
    end
  end

  describe "soft delete policy for hierarchical namespace enabled bucket" do
    let(:hns_bucket_name) {"gcloud-ruby-acceptance-#{SecureRandom.hex(4)}"}
    let(:hns_bucket) {
      hierarchical_namespace = Google::Apis::StorageV1::Bucket::HierarchicalNamespace.new(enabled: true)
      safe_gcs_execute {
        storage.create_bucket hns_bucket_name do |b|
          b.uniform_bucket_level_access = true
          b.hierarchical_namespace = hierarchical_namespace
        end
      }
    }
    let(:random_restore_token) {"random_string"}
    
    before do
      hns_bucket.create_file file_path, file_name
    end

    it "restores a deleted file from bucket when correct restore token is provided"  do
       binding.pry
      file = hns_bucket.file file_name
      file.delete

      deleted_file = hns_bucket.file file_name, soft_deleted: true, generation: file.generation
      restored_file = hns_bucket.restore_file file_name, deleted_file.generation, restore_token: deleted_file.restore_token
      file = hns_bucket.file file_name
      _(file).wont_be_nil
      _(file.exists?).must_equal true

    end

    it "can not restore a deleted file from bucket using incorrect restore token"  do
      file = hns_bucket.file file_name
      file.delete
      deleted_file = hns_bucket.file file_name, soft_deleted: true, generation: file.generation
      error = assert_raises Google::Cloud::NotFoundError do
        hns_bucket.restore_file file_name, deleted_file.generation, restore_token: random_restore_token
      end
      assert_equal 404, error.status_code
      file = hns_bucket.file file_name
      _(file).must_be_nil
    end
  end
end
