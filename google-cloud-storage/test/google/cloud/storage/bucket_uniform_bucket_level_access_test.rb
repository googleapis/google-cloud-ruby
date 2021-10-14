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

describe Google::Cloud::Storage::Bucket, :uniform_bucket_level_access, :mock_storage do
  let(:bucket_name) { "new-bucket-#{Time.now.to_i}" }
  let(:bucket_hash) { random_bucket_hash name: bucket_name }
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json bucket_hash.to_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }
  let(:bucket_user_project) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service, user_project: true }

  it "knows its uniform_bucket_level_access attrs" do
    _(bucket.uniform_bucket_level_access?).must_equal false
    _(bucket.uniform_bucket_level_access_locked_at).must_be :nil?
  end

  it "updates its uniform_bucket_level_access" do
    mock = Minitest::Mock.new
    mock.expect :patch_bucket, resp_bucket_gapi(bucket_hash, uniform_bucket_level_access: true, locked_time: true),
                patch_bucket_args(bucket_name, patch_bucket_gapi(uniform_bucket_level_access: true))
    bucket.service.mocked_service = mock

    _(bucket.uniform_bucket_level_access?).must_equal false

    bucket.uniform_bucket_level_access = true

    _(bucket.uniform_bucket_level_access?).must_equal true
    _(bucket.uniform_bucket_level_access_locked_at).must_be_kind_of DateTime

    mock.verify
  end

  it "updates its uniform_bucket_level_access with user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :patch_bucket, resp_bucket_gapi(bucket_hash, uniform_bucket_level_access: true, locked_time: true),
                patch_bucket_args(bucket_name, patch_bucket_gapi(uniform_bucket_level_access: true), user_project: "test")

    bucket_user_project.service.mocked_service = mock

    _(bucket_user_project.uniform_bucket_level_access?).must_equal false

    bucket_user_project.uniform_bucket_level_access = true

    _(bucket_user_project.uniform_bucket_level_access?).must_equal true
    _(bucket_user_project.uniform_bucket_level_access_locked_at).must_be_kind_of DateTime

    mock.verify
  end

  it "knows its DEPRECATED policy_only attrs" do
    _(bucket.policy_only?).must_equal false
    _(bucket.policy_only_locked_at).must_be :nil?
  end

  it "updates its DEPRECATED policy_only" do
    mock = Minitest::Mock.new
    mock.expect :patch_bucket, resp_bucket_gapi(bucket_hash, uniform_bucket_level_access: true, locked_time: true),
                patch_bucket_args(bucket_name, patch_bucket_gapi(uniform_bucket_level_access: true))
    bucket.service.mocked_service = mock

    _(bucket.policy_only?).must_equal false

    bucket.policy_only = true

    _(bucket.policy_only?).must_equal true
    _(bucket.policy_only_locked_at).must_be_kind_of DateTime

    mock.verify
  end

  it "updates its DEPRECATED policy_only with user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :patch_bucket, resp_bucket_gapi(bucket_hash, uniform_bucket_level_access: true, locked_time: true),
                patch_bucket_args(bucket_name, patch_bucket_gapi(uniform_bucket_level_access: true), user_project: "test")

    bucket_user_project.service.mocked_service = mock

    _(bucket_user_project.policy_only?).must_equal false

    bucket_user_project.policy_only = true

    _(bucket_user_project.policy_only?).must_equal true
    _(bucket_user_project.policy_only_locked_at).must_be_kind_of DateTime

    mock.verify
  end

  def patch_bucket_gapi uniform_bucket_level_access: true
    Google::Apis::StorageV1::Bucket.new(
      iam_configuration: iam_configuration_gapi(uniform_bucket_level_access: uniform_bucket_level_access, locked_time: false)
    )
  end

  def resp_bucket_gapi bucket_hash, uniform_bucket_level_access: true, locked_time: false
    b = Google::Apis::StorageV1::Bucket.from_json bucket_hash.to_json
    b.iam_configuration = iam_configuration_gapi \
      uniform_bucket_level_access: uniform_bucket_level_access, locked_time: locked_time
    b
  end
end