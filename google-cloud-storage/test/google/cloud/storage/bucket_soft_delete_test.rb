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

require "helper"

describe Google::Cloud::Storage::Bucket, :soft_delete_policy, :mock_storage do
  let(:bucket_name) { "new-bucket-#{Time.now.to_i}" }
  let(:bucket_hash) { random_bucket_hash name: bucket_name }
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json bucket_hash.to_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }
  let(:soft_delete_policy) do
      soft_delete_policy_object(retention_duration_seconds: 10*24*60*60)
  end
  let(:file_name) { "file.ext" }
  let(:file_hash) { random_file_hash bucket.name, file_name }
  let(:file_gapi) { Google::Apis::StorageV1::Object.from_json file_hash.to_json }
  let(:file) { Google::Cloud::Storage::File.from_gapi file_gapi, storage.service }
  let(:generation) { 1234567890 }
  let(:soft_delete_time) { DateTime.now }
  let(:hard_delete_time) { soft_delete_time + 10 } # Soft delete time + 10 days

  it "knows its soft_delete_policy value" do
    _(bucket.soft_delete_policy).wont_be_nil
    _(bucket.soft_delete_policy.effective_time).must_be_kind_of DateTime
    _(bucket.soft_delete_policy.retention_duration_seconds).must_equal 604800
  end

  it "can update its soft_delete_policy" do
    mock = Minitest::Mock.new
    mock.expect :patch_bucket, resp_bucket_gapi(bucket_hash, soft_delete_policy: soft_delete_policy),
                [bucket_name, patch_bucket_gapi(soft_delete_policy: soft_delete_policy)], **patch_bucket_args(options: {retries: 0})

    bucket.service.mocked_service = mock

    bucket.soft_delete_policy = soft_delete_policy

    _(bucket.soft_delete_policy.effective_time).must_be_kind_of DateTime
    _(bucket.soft_delete_policy.retention_duration_seconds).must_equal 864000

    mock.verify
  end

  it "can fetch soft deleted file" do
    mock = Minitest::Mock.new
    mock.expect :delete_object, nil, [bucket_name, file.name], **delete_object_args(options: {retries: 0})
    file.service.mocked_service = mock
    file.delete
    mock.verify

    mock.expect :get_object, get_file_gapi(bucket_name, file.name, soft_delete_time: soft_delete_time, hard_delete_time: hard_delete_time),
                 [bucket_name, file.name], **get_object_args(soft_deleted: true, generation: generation)
    bucket.service.mocked_service = mock
    soft_deleted_file = bucket.file file.name, soft_deleted: true, generation: generation
    mock.verify

    _(soft_deleted_file.exists?).must_equal true
    _(soft_deleted_file.soft_delete_time).wont_be_nil
    _(soft_deleted_file.hard_delete_time).wont_be_nil
    _(soft_deleted_file.hard_delete_time).must_equal (soft_deleted_file.soft_delete_time + 10)
  end

  it "can list soft deleted files" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(0),
      [bucket_name], **list_objects_args(soft_deleted: true)
    bucket.service.mocked_service = mock
    files = bucket.files soft_deleted: true
    mock.verify

    _(files).must_be_empty

    mock = Minitest::Mock.new
    mock.expect :delete_object, nil, [bucket_name, file.name], **delete_object_args(options: {retries: 0})
    file.service.mocked_service = mock
    file.delete
    mock.verify

    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(1),
                [bucket_name], **list_objects_args(soft_deleted: true)
    bucket.service.mocked_service = mock
    files = bucket.files soft_deleted: true
    mock.verify

    _(files.count).must_equal 1
  end

  it "can restore soft deleted file" do
    mock = Minitest::Mock.new
    mock.expect :delete_object, nil, [bucket_name, file.name], **delete_object_args(options: {retries: 0})
    file.service.mocked_service = mock
    file.delete
    mock.verify

    mock = Minitest::Mock.new
    mock.expect :restore_object, restore_file_gapi(bucket_name, file_name),
      [bucket_name, file.name, generation], **restore_object_args()
    bucket.service.mocked_service = mock
    file = bucket.restore_file file_name, generation
    mock.verify

    _(file.name).must_equal file_name
    _(file.bucket).must_equal bucket_name
  end

  describe "for hierarchical namespace buckets" do
    
    let(:bucket_hash) { 
      hierarchical_namespace = Google::Apis::StorageV1::Bucket::HierarchicalNamespace.new(enabled: true)
      random_bucket_hash name: bucket_name, hierarchical_namespace: hierarchical_namespace
    }
    let(:file_name) { "file.ext" }
    let(:file_hash) { random_file_hash bucket.name, file_name }
    let(:file_gapi) { Google::Apis::StorageV1::Object.from_json file_hash.to_json }
    let(:file) { Google::Cloud::Storage::File.from_gapi file_gapi, storage.service }
    let(:restore_token){ "test_token" }

    it "can restore soft deleted file" do
      mock = Minitest::Mock.new
      mock.expect :delete_object, nil, [bucket_name, file.name], **delete_object_args(options: {retries: 0})
      file.service.mocked_service = mock
      file.delete
      mock.verify
      mock = Minitest::Mock.new
      mock.expect :restore_object, restore_file_gapi(bucket_name, file_name),
        [bucket_name, file_name, generation], **restore_object_args(restore_token: restore_token)
      bucket.service.mocked_service = mock
      file = bucket.restore_file file_name, generation, restore_token: restore_token
      mock.verify
      _(file.name).must_equal file_name
      _(file.bucket).must_equal bucket_name
    end
  end

  def patch_bucket_gapi soft_delete_policy: nil
    Google::Apis::StorageV1::Bucket.new(
      soft_delete_policy: soft_delete_policy
    )
  end

  def resp_bucket_gapi bucket_hash, soft_delete_policy: nil
    b = Google::Apis::StorageV1::Bucket.from_json bucket_hash.to_json
    b.soft_delete_policy = soft_delete_policy
    b
  end

  def get_file_gapi bucket=nil, name = nil,
                    soft_delete_time: nil,
                    hard_delete_time: nil
    file_hash = random_file_hash(bucket, name,
                                 soft_delete_time: soft_delete_time,
                                 hard_delete_time: hard_delete_time).to_json
    Google::Apis::StorageV1::Object.from_json file_hash
  end
end
