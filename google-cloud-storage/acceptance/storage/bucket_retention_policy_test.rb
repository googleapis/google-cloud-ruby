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

describe Google::Cloud::Storage::Bucket, :retention_policy, :storage do
  let(:bucket_name) { "#{$bucket_names.first}-rpol" }
  let :bucket do
    storage.bucket(bucket_name) ||
    storage.create_bucket(bucket_name)
  end
  let(:file_path) { "acceptance/data/CloudPlatform_128px_Retina.png" }

  after do
    bucket.update do |b|
      b.retention_period = nil
      b.default_event_based_hold = false
    end
    bucket.files.all.each do |b|
      b.temporary_hold = false
      b.event_based_hold = false
      b.delete
    end
  end

  focus
  it "manages a file with retention_period" do
    bucket.update do |b|
      b.retention_period = 100
      b.default_event_based_hold = false
    end

    bucket.reload!
    bucket.retention_period.must_equal 100
    bucket.retention_effective_at.must_be_kind_of DateTime
    bucket.retention_locked?.must_equal false
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
    bucket.retention_locked?.must_equal false
    bucket.default_event_based_hold?.must_equal false

    file.reload!
    file.temporary_hold?.must_equal false
    file.event_based_hold?.must_equal false
    file.retention_expires_at.must_be :nil?

    file.delete
  end
  focus
  it "manages a file with default_event_based_hold" do
    bucket.update do |b|
      b.retention_period = nil
      b.default_event_based_hold = true
    end

    bucket.reload!
    bucket.retention_period.must_be :nil?
    bucket.retention_effective_at.must_be :nil?
    bucket.retention_locked?.must_equal false
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
    bucket.retention_locked?.must_equal false
    bucket.default_event_based_hold?.must_equal false

    file.event_based_hold = false

    file.reload!
    file.temporary_hold?.must_equal false
    file.event_based_hold?.must_equal false
    file.retention_expires_at.must_be :nil?

    file.delete
  end
  focus
  it "manages a file with temporary_hold" do
    bucket.retention_period.must_be :nil?
    bucket.retention_effective_at.must_be :nil?
    bucket.retention_locked?.must_equal false
    bucket.default_event_based_hold?.must_equal false

    original = File.new file_path

    # create file
    file = bucket.create_file original, "CloudLogo.png", temporary_hold: true
    file.temporary_hold?.must_equal true
    file.event_based_hold?.must_equal false
    file.retention_expires_at.must_be :nil?

    err = expect { file.delete }.must_raise Google::Cloud::PermissionDeniedError
    err.message.must_match /is under active Temporary hold/

    file.temporary_hold = false

    file.reload!
    file.temporary_hold?.must_equal false
    file.event_based_hold?.must_equal false
    file.retention_expires_at.must_be :nil?

    file.delete
  end
end
