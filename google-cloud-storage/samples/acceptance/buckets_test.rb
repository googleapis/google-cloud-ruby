# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "helper"
require_relative "../storage_add_bucket_label"
require_relative "../storage_bucket_delete_default_kms_key"
require_relative "../storage_change_default_storage_class"
require_relative "../storage_cors_configuration"
require_relative "../storage_create_bucket"
require_relative "../storage_create_bucket_class_location"
require_relative "../storage_define_bucket_website_configuration"
require_relative "../storage_delete_bucket"
require_relative "../storage_disable_bucket_lifecycle_management"
require_relative "../storage_disable_default_event_based_hold"
require_relative "../storage_disable_requester_pays"
require_relative "../storage_disable_uniform_bucket_level_access"
require_relative "../storage_disable_versioning"
require_relative "../storage_enable_bucket_lifecycle_management"
require_relative "../storage_enable_default_event_based_hold"
require_relative "../storage_enable_requester_pays"
require_relative "../storage_enable_uniform_bucket_level_access"
require_relative "../storage_enable_versioning"
require_relative "../storage_get_bucket_metadata"
require_relative "../storage_get_default_event_based_hold"
require_relative "../storage_get_public_access_prevention"
require_relative "../storage_get_retention_policy"
require_relative "../storage_get_uniform_bucket_level_access"
require_relative "../storage_list_buckets"
require_relative "../storage_lock_retention_policy"
require_relative "../storage_remove_bucket_label"
require_relative "../storage_remove_cors_configuration"
require_relative "../storage_remove_retention_policy"
require_relative "../storage_set_bucket_default_kms_key"
require_relative "../storage_set_public_access_prevention_enforced"
require_relative "../storage_set_public_access_prevention_inherited"
require_relative "../storage_set_retention_policy"

describe "Buckets Snippets" do
  let(:storage_client)   { Google::Cloud::Storage.new }
  let(:kms_key)          { get_kms_key storage_client.project }
  let(:retention_period) { rand 1..99 }
  let(:bucket) { fixture_bucket }

  describe "bucket lifecycle" do
    it "create_bucket, create_bucket_class_location, list_buckets, get_bucket_metadata, delete_bucket" do
      # create_bucket
      bucket_name = random_bucket_name
      refute storage_client.bucket bucket_name

      retry_resource_exhaustion do
        assert_output "Created bucket: #{bucket_name}\n" do
          create_bucket bucket_name: bucket_name
        end
      end

      refute_nil storage_client.bucket bucket_name

      # create_bucket_class_location

      secondary_bucket_name = random_bucket_name
      location = "ASIA"
      storage_class = "COLDLINE"
      refute storage_client.bucket secondary_bucket_name

      retry_resource_exhaustion do
        assert_output "Created bucket #{secondary_bucket_name} in #{location} with #{storage_class} class\n" do
          create_bucket_class_location bucket_name: secondary_bucket_name
        end
      end

      secondary_bucket = storage_client.bucket secondary_bucket_name
      refute_nil secondary_bucket
      assert_equal location, secondary_bucket.location
      assert_equal storage_class, secondary_bucket.storage_class

      # list_buckets
      out, _err = capture_io do
        list_buckets
      end

      assert_includes out, "ruby-storage-samples-"

      # get_bucket_metadata
      out, _err = capture_io do
        get_bucket_metadata bucket_name: bucket_name
      end

      assert_includes out, bucket_name

      # delete_bucket
      assert_output "Deleted bucket: #{bucket_name}\n" do
        delete_bucket bucket_name: bucket_name
      end

      refute storage_client.bucket bucket_name


      delete_bucket_helper bucket_name
      delete_bucket_helper secondary_bucket_name
    end
  end

  describe "cors" do
    it "cors_configuration, remove_cors_configuration" do
      bucket.cors { |c| c.clear }
      assert bucket.cors.empty?

      # cors_configuration
      assert_output "Set CORS policies for bucket #{bucket.name}\n" do
        cors_configuration bucket_name: bucket.name
      end

      bucket.refresh!
      assert_equal 1, bucket.cors.count
      rule = bucket.cors.first
      assert_equal ["*"], rule.origin
      assert_equal ["PUT", "POST"], rule.methods
      assert_equal ["Content-Type", "x-goog-resumable"], rule.headers
      assert_equal 3600, rule.max_age

      # remove_cors_configuration
      assert_output "Remove CORS policies for bucket #{bucket.name}\n" do
        remove_cors_configuration bucket_name: bucket.name
      end
      bucket.refresh!
      assert bucket.cors.empty?
    end
  end

  describe "requester_pays" do
    it "enable_requester_pays, disable_requester_pays" do
      # enable_requester_pays
      bucket.requester_pays = false

      assert_output "Requester pays has been enabled for #{bucket.name}\n" do
        enable_requester_pays bucket_name: bucket.name
      end
      bucket.refresh!
      assert bucket.requester_pays?

      # disable_requester_pays
      assert_output "Requester pays has been disabled for #{bucket.name}\n" do
        disable_requester_pays bucket_name: bucket.name
      end
      bucket.refresh!
      refute bucket.requester_pays?
    end
  end

  describe "uniform_bucket_level_access" do
    it "enable_uniform_bucket_level_access, get_uniform_bucket_level_access, disable_uniform_bucket_level_access" do
      # enable_uniform_bucket_level_access
      bucket.uniform_bucket_level_access = false

      assert_output "Uniform bucket-level access was enabled for #{bucket.name}.\n" do
        enable_uniform_bucket_level_access bucket_name: bucket.name
      end

      bucket.refresh!
      assert bucket.uniform_bucket_level_access?

      # get_uniform_bucket_level_access
      assert_output "Uniform bucket-level access is enabled for #{bucket.name}.\nBucket "\
                    "will be locked on #{bucket.uniform_bucket_level_access_locked_at}.\n" do
        get_uniform_bucket_level_access bucket_name: bucket.name
      end
      assert bucket.uniform_bucket_level_access?

      # disable_uniform_bucket_level_access
      assert_output "Uniform bucket-level access was disabled for #{bucket.name}.\n" do
        disable_uniform_bucket_level_access bucket_name: bucket.name
      end

      bucket.refresh!
      refute bucket.uniform_bucket_level_access?

      # get_uniform_bucket_level_access
      assert_output "Uniform bucket-level access is disabled for #{bucket.name}.\n" do
        get_uniform_bucket_level_access bucket_name: bucket.name
      end
      refute bucket.uniform_bucket_level_access?

      bucket.uniform_bucket_level_access = false
    end
  end

  describe "default Cloud KMS encryption key" do
    it "set_bucket_default_kms_key, bucket_delete_default_kms_key" do
      refute bucket.default_kms_key

      # set_bucket_default_kms_key
      assert_output "Default KMS key for #{bucket.name} was set to #{kms_key}\n" do
        set_bucket_default_kms_key bucket_name:     bucket.name,
                                   default_kms_key: kms_key
      end

      bucket.refresh!
      assert_equal bucket.default_kms_key, kms_key

      # bucket_delete_default_kms_key
      assert_output "Default KMS key was removed from #{bucket.name}\n" do
        bucket_delete_default_kms_key bucket_name: bucket.name
      end

      bucket.refresh!
      refute bucket.default_kms_key
    end
  end

  describe "labels" do
    it "add_bucket_label, remove_bucket_label" do
      # add_bucket_label
      label_key = "label_key"
      label_value = "label_value"

      assert_output "Added label #{label_key} with value #{label_value} to #{bucket.name}\n" do
        add_bucket_label bucket_name: bucket.name,
                         label_value: label_value,
                         label_key:   label_key
      end

      bucket.refresh!
      assert_equal bucket.labels[label_key], label_value

      # remove_bucket_label
      assert_output "Deleted label #{label_key} from #{bucket.name}\n" do
        remove_bucket_label bucket_name: bucket.name,
                            label_key:   label_key
      end

      bucket.refresh!
      assert bucket.labels.empty?
    end
  end

  describe "lifecycle management" do
    let(:bucket) { create_bucket_helper random_bucket_name }
    after { delete_bucket_helper bucket.name }

    it "enable_bucket_lifecycle_management, disable_bucket_lifecycle_management" do
      # enable_bucket_lifecycle_management
      out, _err = capture_io do
        enable_bucket_lifecycle_management bucket_name: bucket.name
      end

      assert_includes out, "Lifecycle management is enabled"

      # disable_bucket_lifecycle_management
      out, _err = capture_io do
        disable_bucket_lifecycle_management bucket_name: bucket.name
      end

      assert_includes out, "Lifecycle management is disabled"
    end
  end

  describe "retention policy" do
    let(:bucket) { create_bucket_helper random_bucket_name }
    after { delete_bucket_helper bucket.name }

    it "set_retention_policy, get_retention_policy, remove_retention_policy" do
      # set_retention_policy
      assert_output "Retention period for #{bucket.name} is now #{retention_period} seconds.\n" do
        set_retention_policy bucket_name:      bucket.name,
                             retention_period: retention_period
      end

      bucket.refresh!
      assert_equal bucket.retention_period, retention_period

      # get_retention_policy
      out, _err = capture_io do
        get_retention_policy bucket_name: bucket.name
      end

      assert_includes out, "period: #{retention_period}\n"

      # remove_retention_policy
      assert_equal bucket.retention_period, retention_period
      assert_output "Retention policy for #{bucket.name} has been removed.\n" do
        remove_retention_policy bucket_name: bucket.name
      end

      bucket.refresh!
      refute bucket.retention_period

      # lock_retention_policy
      bucket.retention_period = retention_period
      out, _err = capture_io do
        lock_retention_policy bucket_name: bucket.name
      end

      assert_includes out, "Retention policy for #{bucket.name} is now locked."
      bucket.refresh!
      assert bucket.retention_policy_locked?

      # remove_retention_policy
      assert_output "Policy is locked and retention policy can't be removed.\n" do
        remove_retention_policy bucket_name: bucket.name
      end
    end
  end

  describe "default_event_based_hold" do
    it "enable_default_event_based_hold, get_default_event_based_hold, disable_default_event_based_hold" do
      # enable_default_event_based_hold
      assert_output "Default event-based hold was enabled for #{bucket.name}.\n" do
        enable_default_event_based_hold bucket_name: bucket.name
      end

      bucket.refresh!
      assert bucket.default_event_based_hold?

      # get_default_event_based_hold
      assert_output "Default event-based hold is enabled for #{bucket.name}.\n" do
        get_default_event_based_hold bucket_name: bucket.name
      end

      # disable_default_event_based_hold
      bucket.update do |b|
        b.default_event_based_hold = true
      end

      assert_output "Default event-based hold was disabled for #{bucket.name}.\n" do
        disable_default_event_based_hold bucket_name: bucket.name
      end

      bucket.refresh!
      refute bucket.default_event_based_hold?

      # get_default_event_based_hold
      assert_output "Default event-based hold is not enabled for #{bucket.name}.\n" do
        get_default_event_based_hold bucket_name: bucket.name
      end
    end
  end

  describe "storage_class" do
    it "change_default_storage_class" do
      assert_equal "STANDARD", bucket.storage_class

      assert_output "Default storage class for bucket #{bucket.name} has been set to COLDLINE\n" do
        change_default_storage_class bucket_name: bucket.name
      end

      bucket.refresh!
      assert_equal "COLDLINE", bucket.storage_class
      # teardown
      bucket.storage_class = "STANDARD"
    end
  end

  describe "versioning" do
    it "enable_versioning, disable_versioning" do
      # enable_versioning
      bucket.versioning = false

      assert_output "Versioning was enabled for bucket #{bucket.name}\n" do
        enable_versioning bucket_name: bucket.name
      end
      bucket.refresh!
      assert bucket.versioning?

      # disable_versioning
      assert_output "Versioning was disabled for bucket #{bucket.name}\n" do
        disable_versioning bucket_name: bucket.name
      end
      bucket.refresh!
      refute bucket.versioning?
    end
  end

  describe "website_configuration" do
    let(:main_page_suffix) { "index.html" }
    let(:not_found_page) { "404.html" }

    it "define_bucket_website_configuration" do
      expected_out = "Static website bucket #{bucket.name} is set up to use #{main_page_suffix} as the index page " \
                     "and #{not_found_page} as the 404 page\n"

      assert_output expected_out do
        define_bucket_website_configuration bucket_name:      bucket.name,
                                            main_page_suffix: main_page_suffix,
                                            not_found_page:   not_found_page
      end

      bucket.refresh!
      assert_equal main_page_suffix, bucket.website_main
      assert_equal not_found_page, bucket.website_404
    end
  end

  describe "public_access_prevention" do
    it "set_public_access_prevention_enforced, get_public_access_prevention, " \
       "set_public_access_prevention_inherited" do
      bucket.public_access_prevention = :inherited
      bucket.refresh!
      _(bucket.public_access_prevention).must_equal "inherited"

      # set_public_access_prevention_enforced
      assert_output "Public access prevention is set to enforced for #{bucket.name}.\n" do
        set_public_access_prevention_enforced bucket_name: bucket.name
      end

      bucket.refresh!
      _(bucket.public_access_prevention).must_equal "enforced"

      # get_public_access_prevention
      assert_output "Public access prevention is 'enforced' for #{bucket.name}.\n" do
        get_public_access_prevention bucket_name: bucket.name
      end
      _(bucket.public_access_prevention).must_equal "enforced"

      # set_public_access_prevention_inherited
      assert_output "Public access prevention is 'inherited' for #{bucket.name}.\n" do
        set_public_access_prevention_inherited bucket_name: bucket.name
      end

      bucket.refresh!
      _(bucket.public_access_prevention).must_equal "inherited"
      bucket.public_access_prevention = :inherited
    end
  end
end
