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

describe Google::Cloud::Storage::Bucket, :hierarchical_namespace, :storage do
  let(:bucket_name) { $bucket_names[0] }
  let :bucket do
    storage.bucket(bucket_name) ||
    safe_gcs_execute { storage.create_bucket(bucket_name) }
  end

  before do
    bucket.files.all { |f| f.delete rescue nil }
  end

  describe "Hierarchical Namespace" do
    it "updates the hierarchical namespace configuration" do
      _(bucket.hierarchical_namespace).must_be_nil

      bucket.hierarchical_namespace = Google::Apis::StorageV1::Bucket::HierarchicalNamespace.new(enabled: true)
      _(bucket.hierarchical_namespace).wont_be_nil
      _(bucket.hierarchical_namespace.enabled).must_equal true

      bucket.hierarchical_namespace = Google::Apis::StorageV1::Bucket::HierarchicalNamespace.new(enabled: false)
      _(bucket.hierarchical_namespace.enabled).must_equal false
    end
  end
end
