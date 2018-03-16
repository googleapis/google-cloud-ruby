# Copyright 2018 Google LLC
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

describe Google::Cloud::Storage::Bucket, :lock_retention_policy, :storage do
  let(:bucket_name) { "#{$bucket_names.first}-rpol" }
  let :bucket do
    storage.bucket(bucket_name) ||
    storage.create_bucket(bucket_name)
  end
  let(:file_path) { "acceptance/data/CloudPlatform_128px_Retina.png" }

  after do
    if bucket
      bucket.retention_period = nil if bucket.retention_period
      bucket.files.all do |file|
        file.release_temporary_hold! if file.temporary_hold?
        file.release_event_based_hold! if file.event_based_hold?
        file.delete
      end
      bucket.delete
    end
  end

  it "lists buckets with retention policies" do
    bucket.update do |b|
      b.retention_period = 10
      b.default_event_based_hold = true
    end
    buckets = storage.buckets.all
    found = false
    buckets.each do |b|
      if b.name == bucket_name
        found = true

        b.retention_period.must_equal 10
        b.retention_effective_at.must_be_kind_of DateTime
        b.retention_policy_locked?.must_equal false
        b.default_event_based_hold?.must_equal true
      end
    end
    assert found
  end

  it "manages a file with retention_period" do
    bucket.update do |b|
      b.retention_period = 10
      b.default_event_based_hold = false
    end

    bucket.reload!
    bucket.retention_period.must_equal 10
    bucket.retention_effective_at.must_be_kind_of DateTime
    bucket.retention_policy_locked?.must_equal false
    bucket.default_event_based_hold?.must_equal false

    original = File.new file_path

    # create file
    file = bucket.create_file original, "CloudLogo.png"

    # files get
    file = bucket.file file.name
    file.temporary_hold?.must_equal false
    file.event_based_hold?.must_equal false
    file.retention_expires_at.must_be_kind_of DateTime

    # files list
    bucket.files.all.each do |f|
      f.temporary_hold?.must_equal false
      f.event_based_hold?.must_equal false
      f.retention_expires_at.must_be_kind_of DateTime
    end

    err = expect { file.delete }.must_raise Google::Cloud::PermissionDeniedError
    err.message.must_match /is subject to bucket's retention policy/

    bucket.update do |b|
      b.retention_period = nil
    end

    bucket.reload!
    bucket.retention_period.must_be :nil?
    bucket.retention_effective_at.must_be :nil?
    bucket.retention_policy_locked?.must_equal false
    bucket.default_event_based_hold?.must_equal false

    file.reload!
    file.temporary_hold?.must_equal false
    file.event_based_hold?.must_equal false
    file.retention_expires_at.must_be :nil?

    file.delete
  end

  it "manages a file with default_event_based_hold" do
    bucket.update do |b|
      b.retention_period = nil
      b.default_event_based_hold = true
    end

    bucket.reload!
    bucket.retention_period.must_be :nil?
    bucket.retention_effective_at.must_be :nil?
    bucket.retention_policy_locked?.must_equal false
    bucket.default_event_based_hold?.must_equal true

    original = File.new file_path

    # create file
    file = bucket.create_file original, "CloudLogo.png"
    file.temporary_hold?.must_equal false
    file.event_based_hold?.must_equal true
    file.retention_expires_at.must_be :nil?

    err = expect { file.delete }.must_raise Google::Cloud::PermissionDeniedError
    err.message.must_match /is under active Event-Based hold/

    bucket.update do |b|
      b.default_event_based_hold = false
    end

    bucket.reload!
    bucket.retention_period.must_be :nil?
    bucket.retention_effective_at.must_be :nil?
    bucket.retention_policy_locked?.must_equal false
    bucket.default_event_based_hold?.must_equal false

    file.release_event_based_hold!

    file.reload!
    file.temporary_hold?.must_equal false
    file.event_based_hold?.must_equal false
    file.retention_expires_at.must_be :nil?

    file.delete
  end

  it "manages a file with temporary_hold" do
    bucket.retention_period.must_be :nil?
    bucket.retention_effective_at.must_be :nil?
    bucket.retention_policy_locked?.must_equal false
    bucket.default_event_based_hold?.must_equal false

    original = File.new file_path

    # create file
    file = bucket.create_file original, "CloudLogo.png", temporary_hold: true
    file.temporary_hold?.must_equal true
    file.event_based_hold?.must_equal false
    file.retention_expires_at.must_be :nil?

    err = expect { file.delete }.must_raise Google::Cloud::PermissionDeniedError
    err.message.must_match /is under active Temporary hold/

    file.release_temporary_hold!

    file.reload!
    file.temporary_hold?.must_equal false
    file.event_based_hold?.must_equal false
    file.retention_expires_at.must_be :nil?

    file.delete
  end

  it "raises when loaded with skip_lookup: true and attempts to lock its retention_period with lock_retention_policy!" do
    bucket.update do |b|
      b.retention_period = 10
    end

    bucket.reload!
    bucket.retention_period.must_equal 10
    bucket.retention_policy_locked?.must_equal false

    bucket_ref = storage.bucket bucket.name, skip_lookup: true

    err = expect { bucket_ref.lock_retention_policy! }.must_raise Google::Cloud::InvalidArgumentError
    err.message.must_match /Required parameter: ifMetagenerationMatch/
  end

  it "locks its retention_period with lock_retention_policy!" do
    bucket.update do |b|
      b.retention_period = 10
    end

    bucket.reload!
    bucket.retention_period.must_equal 10
    bucket.retention_policy_locked?.must_equal false

    bucket.lock_retention_policy!

    # Call to lock_retention_policy! should update bucket state
    bucket.retention_policy_locked?.must_equal true

    err = expect do
      bucket.update do |b|
        b.retention_period = nil
      end
    end.must_raise Google::Cloud::PermissionDeniedError
    err.message.must_match /has a locked Retention Policy which cannot be removed/
  end
end
