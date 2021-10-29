# Copyright 2021 Google LLC
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

describe Google::Cloud::Storage::Bucket, :rpo, :mock_storage do
  let(:bucket_name) { "new-bucket-#{Time.now.to_i}" }
  let(:bucket_hash) { random_bucket_hash name: bucket_name }
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json bucket_hash.to_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }

  let(:dual_region_bucket_name) { "new-dual-region-bucket-#{Time.now.to_i}" }
  let(:dual_region_bucket_hash) { random_bucket_hash(name: dual_region_bucket_name, location_type: "region") }
  let(:dual_region_bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json dual_region_bucket_hash.to_json }
  let(:dual_region_bucket) { Google::Cloud::Storage::Bucket.from_gapi dual_region_bucket_gapi, storage.service }

  it "knows its rpo value" do
    _(bucket.rpo).must_equal "DEFAULT"
    _(dual_region_bucket.rpo).must_equal "DEFAULT"
  end

  it "updates its rpo" do
    mock = Minitest::Mock.new
    mock.expect :patch_bucket, resp_bucket_gapi(dual_region_bucket_hash, rpo: "ASYNC_TURBO"),
                patch_bucket_args(dual_region_bucket_name, patch_bucket_gapi(rpo: "ASYNC_TURBO"))

    dual_region_bucket.service.mocked_service = mock

    _(dual_region_bucket.rpo).must_equal "DEFAULT"

    dual_region_bucket.rpo = :ASYNC_TURBO

    _(dual_region_bucket.rpo).must_equal "ASYNC_TURBO"

    mock.verify
  end

  it "fails to update its rpo because it's multi-region" do
    mock = Minitest::Mock.new
    mock.expect :patch_bucket, resp_bucket_gapi(bucket_hash, rpo: "DEFAULT"),
                patch_bucket_args(bucket_name, patch_bucket_gapi(rpo: "ASYNC_TURBO"))

    bucket.service.mocked_service = mock

    _(bucket.rpo).must_equal "DEFAULT"

    bucket.rpo = :ASYNC_TURBO

    _(bucket.rpo).must_equal "DEFAULT"

    mock.verify
  end

  def patch_bucket_gapi rpo: "DEFAULT"
    Google::Apis::StorageV1::Bucket.new(
      rpo: rpo
    )
  end

  def resp_bucket_gapi bucket_hash, rpo: "DEFAULT"
    b = Google::Apis::StorageV1::Bucket.from_json bucket_hash.to_json
    b.rpo = rpo
    b
  end
end
