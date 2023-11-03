# Copyright 2016 Google LLC
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

describe Google::Cloud::Storage::Bucket, :storage do
  let(:bucket_name) { $bucket_names.first }
  let :bucket do
    storage.bucket(bucket_name) ||
    safe_gcs_execute { storage.create_bucket(bucket_name) }
  end
  let(:created_before) { Date.parse "2019-01-15" }
  let(:created_before_2) { Date.parse "2019-01-16" }
  let(:custom_time_before) { Date.parse "2019-02-15" }
  let(:custom_time_before_2) { Date.parse "2019-02-16" }
  let(:noncurrent_time_before) { Date.parse "2019-03-15" }
  let(:noncurrent_time_before_2) { Date.parse "2019-03-16" }

  before do
    # always reset the bucket permissions
    safe_gcs_execute { bucket.acl.private! }
  end

  it "creates and gets and updates and deletes a bucket" do
    one_off_bucket_name = "#{bucket_name}_one_off"

    _(storage.bucket(one_off_bucket_name)).must_be :nil?

    one_off_bucket = safe_gcs_execute { storage.create_bucket one_off_bucket_name, user_project: true }

    _(storage.bucket(one_off_bucket_name)).wont_be :nil?

    _(one_off_bucket.storage_class).wont_be :nil?
    _(one_off_bucket.website_main).must_be :nil?
    _(one_off_bucket.website_404).must_be :nil?
    _(one_off_bucket.requester_pays).must_be :nil?
    _(one_off_bucket.labels).must_equal({})
    _(one_off_bucket.location_type).must_equal "multi-region"
    _(one_off_bucket.user_project).must_equal true
    one_off_bucket.update do |b|
      b.storage_class = :nearline
      b.website_main = "index.html"
      b.website_404 = "not_found.html"
      b.requester_pays = true
      # update labels with symbols
      b.labels[:foo] = :bar
    end
    _(one_off_bucket.storage_class).must_equal "NEARLINE"
    _(one_off_bucket.website_main).must_equal "index.html"
    _(one_off_bucket.website_404).must_equal "not_found.html"
    _(one_off_bucket.requester_pays).must_equal true
    # labels with symbols are not strings
    _(one_off_bucket.labels).must_equal({ "foo" => "bar" })
    _(one_off_bucket.location_type).must_equal "multi-region"

    one_off_bucket_copy = storage.bucket one_off_bucket_name, user_project: true
    _(one_off_bucket_copy).wont_be :nil?
    _(one_off_bucket_copy.storage_class).must_equal "NEARLINE"
    _(one_off_bucket_copy.website_main).must_equal "index.html"
    _(one_off_bucket_copy.website_404).must_equal "not_found.html"
    _(one_off_bucket_copy.requester_pays).must_equal true
    _(one_off_bucket_copy.user_project).must_equal true

    one_off_bucket.files.all &:delete
    safe_gcs_execute { one_off_bucket.delete }

    _(storage.bucket(one_off_bucket_name)).must_be :nil?
  end

  it "knows its attributes" do
    _(bucket.id).must_be_kind_of String
    _(bucket.name).must_equal bucket_name
    _(bucket.created_at).must_be_kind_of DateTime
    _(bucket.api_url).must_equal "https://www.googleapis.com/storage/v1/b/#{bucket_name}"
    _(bucket.location).must_be_kind_of String
    _(bucket.location_type).must_equal "multi-region"
    _(bucket.logging_bucket).must_be :nil?
    _(bucket.logging_prefix).must_be :nil?
    _(bucket.storage_class).must_equal "STANDARD"
    _(bucket.versioning?).wont_equal true
    _(bucket.website_main).must_be :nil?
    _(bucket.website_404).must_be :nil?
    _(bucket.requester_pays).must_be :nil?
    _(bucket.labels).must_be :empty?

    _(bucket.retention_period).must_be :nil?
    _(bucket.retention_effective_at).must_be :nil?
    _(bucket.retention_policy_locked?).must_equal false
    _(bucket.default_event_based_hold?).must_equal false

    bucket.cors.each do |cors|
      _(cors).must_be_kind_of Google::Cloud::Storage::Bucket::Cors::Rule
      _(cors.frozen?).must_equal true
    end
    _(bucket.cors.frozen?).must_equal true

    bucket.lifecycle.each do |r|
      _(r).must_be_kind_of Google::Cloud::Storage::Bucket::Lifecycle::Rule
      _(r.frozen?).must_equal true
    end
    _(bucket.lifecycle.frozen?).must_equal true
  end

  it "sets and updates cors rules" do
    bucket.cors do |c|
      c.add_rule ["http://example.org", "https://example.org"],
                 "*",
                 headers: ["X-My-Custom-Header"],
                 max_age: 300
    end

    _(bucket.cors).wont_be :empty?
    _(bucket.cors.last.origin).must_equal ["http://example.org", "https://example.org"]
    _(bucket.cors.last.methods).must_equal ["*"]
    _(bucket.cors.last.headers).must_equal ["X-My-Custom-Header"]
    _(bucket.cors.last.max_age).must_equal 300

    bucket.reload!

    bucket.cors do |c|
      c.last.origin << "https://example.com"
      c.last.methods = ["PUT"]
      c.last.headers << "X-Another-Custom-Header"
      c.last.max_age = 600
    end

    bucket.reload!

    _(bucket.cors.last.origin).must_equal ["http://example.org", "https://example.org", "https://example.com"]
    _(bucket.cors.last.methods).must_equal ["PUT"]
    _(bucket.cors.last.headers).must_equal ["X-My-Custom-Header", "X-Another-Custom-Header"]
    _(bucket.cors.last.max_age).must_equal 600
  end

  it "sets and updates lifecycle rules" do
    original_count = bucket.lifecycle.count

    bucket.lifecycle do |l|
      l.add_set_storage_class_rule "NEARLINE",
                                   age: 10,
                                   created_before: created_before, # string in RFC 3339 format with only the date part also ok
                                   custom_time_before: "2019-02-15", # string in RFC 3339 format with only the date part also ok
                                   days_since_custom_time: 5,
                                   days_since_noncurrent_time: 14,
                                   is_live: true,
                                   matches_storage_class: ["STANDARD"],
                                   noncurrent_time_before: noncurrent_time_before, # string in RFC 3339 format with only the date part also ok
                                   num_newer_versions: 3,
                                   matches_prefix: ["some_prefix"],
                                   matches_suffix: ["some_suffix"]

    end

    _(bucket.lifecycle).wont_be :empty?
    _(bucket.lifecycle.count).must_equal original_count + 1
    _(bucket.lifecycle.last.action).must_equal "SetStorageClass"
    _(bucket.lifecycle.last.storage_class).must_equal "NEARLINE"
    _(bucket.lifecycle.last.age).must_equal 10
    _(bucket.lifecycle.last.created_before).must_equal created_before
    _(bucket.lifecycle.last.custom_time_before).must_equal custom_time_before
    _(bucket.lifecycle.last.days_since_custom_time).must_equal 5
    _(bucket.lifecycle.last.days_since_noncurrent_time).must_equal 14
    _(bucket.lifecycle.last.is_live).must_equal true
    _(bucket.lifecycle.last.matches_storage_class).must_equal ["STANDARD"]
    _(bucket.lifecycle.last.noncurrent_time_before).must_equal noncurrent_time_before
    _(bucket.lifecycle.last.num_newer_versions).must_equal 3
    _(bucket.lifecycle.last.matches_prefix).must_equal ["some_prefix"]
    _(bucket.lifecycle.last.matches_suffix).must_equal ["some_suffix"]

    bucket.reload!

    bucket.lifecycle do |l|
      l.last.storage_class = "COLDLINE"
      l.last.age = 20
      l.last.created_before = "2019-01-16"
      l.last.custom_time_before = "2019-02-16"
      l.last.days_since_custom_time = 6
      l.last.days_since_noncurrent_time = 15
      l.last.is_live = false
      l.last.matches_storage_class = ["NEARLINE"]
      l.last.noncurrent_time_before = "2019-03-16"
      l.last.num_newer_versions = 4
      l.last.matches_prefix = ["some_other_prefix"]
      l.last.matches_suffix = ["some_other_suffix"]


      _(l.last.created_before).must_be_kind_of String
      _(l.last.noncurrent_time_before).must_be_kind_of String
    end

    _(bucket.lifecycle.last.created_before).must_be_kind_of Date
    _(bucket.lifecycle.last.created_before).must_equal created_before_2
    _(bucket.lifecycle.last.custom_time_before).must_be_kind_of Date
    _(bucket.lifecycle.last.custom_time_before).must_equal custom_time_before_2
    _(bucket.lifecycle.last.noncurrent_time_before).must_be_kind_of Date
    _(bucket.lifecycle.last.noncurrent_time_before).must_equal noncurrent_time_before_2
    _(bucket.lifecycle.last.matches_prefix).must_equal ["some_other_prefix"]
    _(bucket.lifecycle.last.matches_suffix).must_equal ["some_other_suffix"]


    bucket.reload!

    _(bucket.lifecycle).wont_be :empty?
    _(bucket.lifecycle.count).must_equal original_count + 1
    _(bucket.lifecycle.last.action).must_equal "SetStorageClass"
    _(bucket.lifecycle.last.storage_class).must_equal "COLDLINE"
    _(bucket.lifecycle.last.age).must_equal 20
    _(bucket.lifecycle.last.created_before).must_be_kind_of Date
    _(bucket.lifecycle.last.created_before).must_equal created_before_2
    _(bucket.lifecycle.last.custom_time_before).must_be_kind_of Date
    _(bucket.lifecycle.last.custom_time_before).must_equal custom_time_before_2
    _(bucket.lifecycle.last.days_since_custom_time).must_equal 6
    _(bucket.lifecycle.last.days_since_noncurrent_time).must_equal 15
    _(bucket.lifecycle.last.is_live).must_equal false
    _(bucket.lifecycle.last.matches_storage_class).must_equal ["NEARLINE"]
    _(bucket.lifecycle.last.noncurrent_time_before).must_be_kind_of Date
    _(bucket.lifecycle.last.noncurrent_time_before).must_equal noncurrent_time_before_2
    _(bucket.lifecycle.last.num_newer_versions).must_equal 4
    _(bucket.lifecycle.last.matches_prefix).must_equal ["some_other_prefix"]
    _(bucket.lifecycle.last.matches_suffix).must_equal ["some_other_suffix"]

    bucket.lifecycle do |l|
      l.delete_at(bucket.lifecycle.count - 1)
    end

    bucket.reload!

    _(bucket.lifecycle.count).must_equal original_count
  end

  it "adds lifecycle action IncompleteMultipartUpload to bucket" do
    original_count = bucket.lifecycle.count

    bucket.lifecycle do |l|
      l.add_abort_incomplete_multipart_upload_rule age: 10,
                                                   matches_prefix: ["images/", :some_prefix],
                                                   matches_suffix: [".pdf", :some_suffix]
    end

    bucket.reload!

    _(bucket.lifecycle).wont_be :empty?
    _(bucket.lifecycle.count).must_equal original_count + 1
    _(bucket.lifecycle.last.action).must_equal "AbortIncompleteMultipartUpload"
    _(bucket.lifecycle.last.age).must_equal 10
    _(bucket.lifecycle.last.matches_prefix).must_equal ["images/", "some_prefix"]
    _(bucket.lifecycle.last.matches_suffix).must_equal [".pdf", "some_suffix"]

    bucket.lifecycle do |l|
      l.delete_at(bucket.lifecycle.count - 1)
    end

    bucket.reload!

    _(bucket.lifecycle.count).must_equal original_count
  end

  it "does not error when getting a file that does not exist" do
    random_bucket = storage.bucket "#{bucket_name}_does_not_exist"
    _(random_bucket).must_be :nil?
  end

  it "does not create a new bucket when both autoclass and storage_class are specified" do
    one_off_bucket_name = "#{bucket_name}_one_off"

    _(storage.bucket(one_off_bucket_name)).must_be :nil?

    err = expect { storage.create_bucket one_off_bucket_name, user_project: true, autoclass_enabled: true, storage_class: "nearline" }.must_raise Google::Cloud::InvalidArgumentError
    _(err.message).must_match /default storage class on bucket with Autoclass enabled to storage class other than STANDARD/
  end

  it "creates new bucket with autoclass config and then updates it" do
    one_off_bucket_name = "#{bucket_name}_one_off"

    _(storage.bucket(one_off_bucket_name)).must_be :nil?

    one_off_bucket = safe_gcs_execute { storage.create_bucket one_off_bucket_name, user_project: true, autoclass_enabled: true }
    _(storage.bucket(one_off_bucket_name)).wont_be :nil?
    _(one_off_bucket.user_project).must_equal true
    _(one_off_bucket.autoclass_enabled).must_equal true
    _(one_off_bucket.autoclass_terminal_storage_class).must_equal 'NEARLINE'
    _(one_off_bucket.autoclass_terminal_storage_class_update_time).wont_be :nil?
    prev_toggle_time = one_off_bucket.autoclass_toggle_time
    prev_terminal_storage_class_update_time = one_off_bucket.autoclass_terminal_storage_class_update_time

    one_off_bucket.update do |b|
      b.update_autoclass({ enabled: true, terminal_storage_class: "ARCHIVE"})
    end
    _(one_off_bucket.autoclass_enabled).must_equal true
    _(one_off_bucket.autoclass_terminal_storage_class).must_equal "ARCHIVE"

    one_off_bucket.update do |b|
      b.autoclass_enabled= false
    end
    _(one_off_bucket.autoclass_enabled).must_equal false

    one_off_bucket_copy = storage.bucket one_off_bucket_name, user_project: true
    _(one_off_bucket_copy).wont_be :nil?
    _(one_off_bucket_copy.user_project).must_equal true
    _(one_off_bucket_copy.autoclass_enabled).must_equal false
    refute one_off_bucket_copy.autoclass_toggle_time == prev_toggle_time
    refute one_off_bucket_copy.autoclass_terminal_storage_class_update_time == prev_terminal_storage_class_update_time

    one_off_bucket.files.all &:delete
    safe_gcs_execute { one_off_bucket.delete }
    _(storage.bucket(one_off_bucket_name)).must_be :nil?
  end

  describe "anonymous project" do
    it "raises when creating a bucket without authentication" do
      anonymous_storage = Google::Cloud::Storage.anonymous
      expect { anonymous_storage.create_bucket bucket_name }.must_raise Google::Cloud::UnauthenticatedError
    end
  end

  it "creates new bucket with rpo DEFAULT then sets rpo to ASYNC_TURBO" do
    single_use_bucket_name = "single_use_#{bucket_name}"

    _(storage.bucket(single_use_bucket_name)).must_be :nil?

    single_use_bucket = safe_gcs_execute { storage.create_bucket single_use_bucket_name, location: "ASIA1" }

    _(single_use_bucket.rpo).must_equal "DEFAULT"

    single_use_bucket.update do |b|
      b.rpo = :ASYNC_TURBO
    end
    _(single_use_bucket.rpo).must_equal "ASYNC_TURBO"

    single_use_bucket.files.all &:delete
    safe_gcs_execute { single_use_bucket.delete }

    _(storage.bucket(single_use_bucket_name)).must_be :nil?
  end

  it "creates a dual region bucket" do
    one_off_bucket_name = "multi_loc_#{bucket_name}"
    _(storage.bucket(one_off_bucket_name)).must_be :nil?

    one_off_bucket = safe_gcs_execute do
      storage.create_bucket one_off_bucket_name,
                            location: "US",
                            custom_placement_config: { data_locations: ["US-EAST1", "US-WEST1"] }
    end

    _(storage.bucket(one_off_bucket_name)).wont_be :nil?

    _(one_off_bucket.name).must_equal one_off_bucket_name
    _(one_off_bucket.location).must_equal "US"
    _(one_off_bucket.data_locations).must_equal ["US-EAST1", "US-WEST1"]
    _(one_off_bucket.location_type).must_equal "dual-region"

    safe_gcs_execute { one_off_bucket.delete }

    _(storage.bucket(one_off_bucket_name)).must_be :nil?
  end
end
