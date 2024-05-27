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

describe Google::Cloud::Storage::Bucket, :hierarchical_namespace, :mock_storage do
  let(:bucket_name) { "new-bucket-#{Time.now.to_i}" }
  let(:bucket_hash) { random_bucket_hash name: bucket_name }
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json bucket_hash.to_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }

  it "knows its hierarchical_namespace configuration" do
    _(bucket.hierarchical_namespace).must_be_nil
  end

  it "can update its hierarchical_namespace" do
    mock = Minitest::Mock.new
    mock.expect :patch_bucket, resp_bucket_gapi(bucket_hash, hierarchical_namespace: hierarchical_namespace_object),
                [bucket_name, patch_bucket_gapi(hierarchical_namespace: hierarchical_namespace_object)], **patch_bucket_args(options: {retries: 0})

    bucket.service.mocked_service = mock

    bucket.hierarchical_namespace = hierarchical_namespace_object(enabled: true)

    _(bucket.hierarchical_namespace).wont_be_nil
    _(bucket.hierarchical_namespace.enabled).must_equal true

    mock.verify
  end

  def patch_bucket_gapi hierarchical_namespace: nil
    Google::Apis::StorageV1::Bucket.new(
      hierarchical_namespace: hierarchical_namespace
    )
  end

  def resp_bucket_gapi bucket_hash, hierarchical_namespace: {enabled: true}
    b = Google::Apis::StorageV1::Bucket.from_json bucket_hash.to_json
    b.hierarchical_namespace = hierarchical_namespace
    b
  end
end
