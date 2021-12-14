# Copyright 2020 Google LLC
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

describe Google::Cloud::Storage::Bucket, :public_access_prevention, :mock_storage do
  let(:bucket_name) { "new-bucket-#{Time.now.to_i}" }
  let(:bucket_hash) { random_bucket_hash name: bucket_name }
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json bucket_hash.to_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }
  let(:bucket_user_project) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service, user_project: true }

  it "knows its public_access_prevention value" do
    _(bucket.public_access_prevention).must_be :nil?
  end

  it "knows its public_access_prevention_enforced? value" do
    _(bucket.public_access_prevention_enforced?).must_equal false
  end

  it "knows its public_access_prevention_inherited? value" do
    _(bucket.public_access_prevention_inherited?).must_equal false
  end

  it "updates its public_access_prevention" do
    mock = Minitest::Mock.new
    mock.expect :patch_bucket, resp_bucket_gapi(bucket_hash, public_access_prevention: "inherited"),
                patch_bucket_args(bucket_name, patch_bucket_gapi(public_access_prevention: "inherited"))
    mock.expect :patch_bucket, resp_bucket_gapi(bucket_hash, public_access_prevention: "enforced"),
                patch_bucket_args(bucket_name, patch_bucket_gapi(public_access_prevention: "enforced"))
    bucket.service.mocked_service = mock

    _(bucket.public_access_prevention).must_be :nil?
    _(bucket.public_access_prevention_enforced?).must_equal false
    _(bucket.public_access_prevention_inherited?).must_equal false

    bucket.public_access_prevention = :inherited

    _(bucket.public_access_prevention).must_equal "inherited"
    _(bucket.public_access_prevention_enforced?).must_equal false
    _(bucket.public_access_prevention_inherited?).must_equal true

    bucket.public_access_prevention = :enforced

    _(bucket.public_access_prevention).must_equal "enforced"
    _(bucket.public_access_prevention_enforced?).must_equal true
    _(bucket.public_access_prevention_inherited?).must_equal false

    mock.verify
  end

  it "updates its public_access_prevention with user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :patch_bucket, resp_bucket_gapi(bucket_hash, public_access_prevention: "inherited"),
                patch_bucket_args(bucket_name, patch_bucket_gapi(public_access_prevention: "inherited"), user_project: "test")
    mock.expect :patch_bucket, resp_bucket_gapi(bucket_hash, public_access_prevention: "enforced"),
                patch_bucket_args(bucket_name, patch_bucket_gapi(public_access_prevention: "enforced"), user_project: "test")

    bucket_user_project.service.mocked_service = mock

    _(bucket_user_project.public_access_prevention).must_be :nil?
    _(bucket_user_project.public_access_prevention_enforced?).must_equal false
    _(bucket_user_project.public_access_prevention_inherited?).must_equal false

    bucket_user_project.public_access_prevention = :inherited

    _(bucket_user_project.public_access_prevention).must_equal "inherited"
    _(bucket_user_project.public_access_prevention_enforced?).must_equal false
    _(bucket_user_project.public_access_prevention_inherited?).must_equal true

    bucket_user_project.public_access_prevention = :enforced

    _(bucket_user_project.public_access_prevention).must_equal "enforced"
    _(bucket_user_project.public_access_prevention_enforced?).must_equal true
    _(bucket_user_project.public_access_prevention_inherited?).must_equal false

    mock.verify
  end

  def patch_bucket_gapi public_access_prevention: "enforced"
    Google::Apis::StorageV1::Bucket.new(
      iam_configuration: iam_configuration_gapi(public_access_prevention: public_access_prevention)
    )
  end

  def resp_bucket_gapi bucket_hash, public_access_prevention: "enforced"
    b = Google::Apis::StorageV1::Bucket.from_json bucket_hash.to_json
    b.iam_configuration = iam_configuration_gapi public_access_prevention: public_access_prevention
    b
  end
end
