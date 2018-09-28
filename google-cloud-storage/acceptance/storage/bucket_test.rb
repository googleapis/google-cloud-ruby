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

  before do
    # always reset the bucket permissions
    bucket.acl.private!
  end

  it "creates and gets and updates and deletes a bucket" do
    one_off_bucket_name = "#{bucket_name}_one_off"

    storage.bucket(one_off_bucket_name).must_be :nil?

    one_off_bucket = safe_gcs_execute { storage.create_bucket one_off_bucket_name, user_project: true }

    storage.bucket(one_off_bucket_name).wont_be :nil?

    one_off_bucket.storage_class.wont_be :nil?
    one_off_bucket.website_main.must_be :nil?
    one_off_bucket.website_404.must_be :nil?
    one_off_bucket.requester_pays.must_be :nil?
    one_off_bucket.labels.must_equal({})
    one_off_bucket.user_project.must_equal true
    one_off_bucket.update do |b|
      b.storage_class = :nearline
      b.website_main = "index.html"
      b.website_404 = "not_found.html"
      b.requester_pays = true
      # update labels with symbols
      b.labels[:foo] = :bar
    end
    one_off_bucket.storage_class.must_equal "NEARLINE"
    one_off_bucket.website_main.must_equal "index.html"
    one_off_bucket.website_404.must_equal "not_found.html"
    one_off_bucket.requester_pays.must_equal true
    # labels with symbols are not strings
    one_off_bucket.labels.must_equal({ "foo" => "bar" })

    one_off_bucket_copy = storage.bucket one_off_bucket_name, user_project: true
    one_off_bucket_copy.wont_be :nil?
    one_off_bucket_copy.storage_class.must_equal "NEARLINE"
    one_off_bucket_copy.website_main.must_equal "index.html"
    one_off_bucket_copy.website_404.must_equal "not_found.html"
    one_off_bucket_copy.requester_pays.must_equal true
    one_off_bucket_copy.user_project.must_equal true

    one_off_bucket.files.all &:delete
    safe_gcs_execute { one_off_bucket.delete }

    storage.bucket(one_off_bucket_name).must_be :nil?
  end

  it "knows its attributes" do
    bucket.id.must_be_kind_of String
    bucket.name.must_equal bucket_name
    bucket.created_at.must_be_kind_of DateTime
    bucket.api_url.must_equal "https://www.googleapis.com/storage/v1/b/#{bucket_name}"
    bucket.location.must_be_kind_of String
    bucket.logging_bucket.must_be :nil?
    bucket.logging_prefix.must_be :nil?
    bucket.storage_class.must_equal "STANDARD"
    bucket.versioning?.must_be :nil?
    bucket.website_main.must_be :nil?
    bucket.website_404.must_be :nil?
    bucket.requester_pays.must_be :nil?
    bucket.labels.must_be :empty?

    bucket.retention_period.must_be :nil?
    bucket.retention_effective_at.must_be :nil?
    bucket.retention_policy_locked?.must_equal false
    bucket.default_event_based_hold?.must_equal false

    bucket.cors.each do |cors|
      cors.must_be_kind_of Google::Cloud::Storage::Bucket::Cors::Rule
      cors.frozen?.must_equal true
    end
    bucket.cors.frozen?.must_equal true

    bucket.lifecycle.each do |r|
      r.must_be_kind_of Google::Cloud::Storage::Bucket::Lifecycle::Rule
      r.frozen?.must_equal true
    end
    bucket.lifecycle.frozen?.must_equal true
  end

  it "sets and updates cors rules" do
    bucket.cors do |c|
      c.add_rule ["http://example.org", "https://example.org"],
                 "*",
                 headers: ["X-My-Custom-Header"],
                 max_age: 300
    end

    bucket.cors.wont_be :empty?
    bucket.cors.last.origin.must_equal ["http://example.org", "https://example.org"]
    bucket.cors.last.methods.must_equal ["*"]
    bucket.cors.last.headers.must_equal ["X-My-Custom-Header"]
    bucket.cors.last.max_age.must_equal 300

    bucket.reload!

    bucket.cors do |c|
      c.last.origin << "https://example.com"
      c.last.methods = ["PUT"]
      c.last.headers << "X-Another-Custom-Header"
      c.last.max_age = 600
    end

    bucket.reload!

    bucket.cors.last.origin.must_equal ["http://example.org", "https://example.org", "https://example.com"]
    bucket.cors.last.methods.must_equal ["PUT"]
    bucket.cors.last.headers.must_equal ["X-My-Custom-Header", "X-Another-Custom-Header"]
    bucket.cors.last.max_age.must_equal 600
  end

  it "sets and updates lifecycle rules" do
    original_count = bucket.lifecycle.count

    bucket.lifecycle do |l|
      l.add_set_storage_class_rule "NEARLINE",
                                   age: 10,
                                   created_before: Date.parse("2013-01-15"), # string in RFC 3339 date format also ok
                                   is_live: true,
                                   matches_storage_class: ["MULTI_REGIONAL"],
                                   num_newer_versions: 3

    end

    bucket.lifecycle.wont_be :empty?
    bucket.lifecycle.count.must_equal original_count + 1
    bucket.lifecycle.last.action.must_equal "SetStorageClass"
    bucket.lifecycle.last.storage_class.must_equal "NEARLINE"
    bucket.lifecycle.last.age.must_equal 10
    bucket.lifecycle.last.created_before.must_equal "2013-01-15"
    bucket.lifecycle.last.is_live.must_equal true
    bucket.lifecycle.last.matches_storage_class.must_equal ["MULTI_REGIONAL"]
    bucket.lifecycle.last.num_newer_versions.must_equal 3

    bucket.reload!

    bucket.lifecycle do |l|
      l.last.storage_class = "COLDLINE"
      l.last.age = 20
      l.last.created_before = "2013-01-20"
      l.last.is_live = false
      l.last.matches_storage_class = ["NEARLINE"]
      l.last.num_newer_versions = 4
    end

    bucket.reload!

    bucket.lifecycle.wont_be :empty?
    bucket.lifecycle.count.must_equal original_count + 1
    bucket.lifecycle.last.action.must_equal "SetStorageClass"
    bucket.lifecycle.last.storage_class.must_equal "COLDLINE"
    bucket.lifecycle.last.age.must_equal 20
    bucket.lifecycle.last.created_before.must_equal "2013-01-20"
    bucket.lifecycle.last.is_live.must_equal false
    bucket.lifecycle.last.matches_storage_class.must_equal ["NEARLINE"]
    bucket.lifecycle.last.num_newer_versions.must_equal 4

    bucket.lifecycle do |l|
      l.delete_at(bucket.lifecycle.count - 1)
    end

    bucket.reload!

    bucket.lifecycle.count.must_equal original_count
  end

  it "does not error when getting a file that does not exist" do
    random_bucket = storage.bucket "#{bucket_name}_does_not_exist"
    random_bucket.must_be :nil?
  end

  describe "IAM Policies and Permissions" do

    it "allows policy to be updated on a bucket" do
      # Check permissions first
      roles = ["storage.buckets.getIamPolicy", "storage.buckets.setIamPolicy"]
      permissions = bucket.test_permissions roles
      skip "Don't have permissions to get/set bucket's policy" unless permissions == roles

      bucket.policy.must_be_kind_of Google::Cloud::Storage::Policy

      # We need a valid service account in order to update the policy
      service_account = storage.service.credentials.client.issuer
      service_account.wont_be :nil?
      role = "roles/storage.objectCreator"
      member = "serviceAccount:#{service_account}"
      bucket.policy do |p|
        p.add role, member
        p.add role, member # duplicate member will not be added to request
      end

      role_member = bucket.policy.role(role).select { |x| x == member }
      role_member.size.must_equal 1
    end

    it "allows permissions to be tested on a bucket" do
      roles = ["storage.buckets.delete", "storage.buckets.get"]
      permissions = bucket.test_permissions roles
      permissions.must_equal roles
    end
  end

  describe "anonymous project" do
    it "raises when creating a bucket without authentication" do
      anonymous_storage = Google::Cloud::Storage.anonymous
      expect { anonymous_storage.create_bucket bucket_name }.must_raise Google::Cloud::UnauthenticatedError
    end
  end
end
