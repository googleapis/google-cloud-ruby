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

require "storage_helper"

describe Google::Cloud::Storage::Bucket, :uniform_bucket_level_access, :storage do
  let(:bucket_name) { $bucket_names.first }
  let :bucket do
    storage.bucket(bucket_name) ||
      safe_gcs_execute { storage.create_bucket bucket_name }
  end

  it "has uniform_bucket_level_access attributes" do
    _(bucket.uniform_bucket_level_access?).must_be_kind_of(TrueClass).or(must_be_kind_of(FalseClass))
    _(bucket.uniform_bucket_level_access_locked_at).must_be_kind_of(Time).or(must_be(:nil?))
  end

  describe "uniform_bucket_level_access is enabled" do
    let(:ubla_bucket_name) { "#{$bucket_names[2]}-ubla" }
    let(:ubla_bucket) { storage.bucket ubla_bucket_name }

    before do
      storage.create_bucket ubla_bucket_name do |b|
        b.uniform_bucket_level_access = true
      end
    end

    after do
      clean_up_storage_bucket ubla_bucket
    end

    it "has uniform_bucket_level_access attributes" do
      _(ubla_bucket.uniform_bucket_level_access?).must_equal true
      _(ubla_bucket.uniform_bucket_level_access_locked_at).must_be_kind_of Time
    end

    it "cannot access ACLs" do
      expect { ubla_bucket.acl.to_a }.must_raise Google::Cloud::InvalidArgumentError
      expect { ubla_bucket.default_acl.to_a }.must_raise Google::Cloud::InvalidArgumentError
    end

    it "can be disabled" do
      ubla_bucket.uniform_bucket_level_access = false
      _(ubla_bucket.uniform_bucket_level_access?).must_equal false
    end
  end
end
