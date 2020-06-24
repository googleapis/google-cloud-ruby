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
require_relative "../buckets.rb"
require_relative "../storage_enable_bucket_lifecycle_management.rb"
require_relative "../storage_disable_bucket_lifecycle_management.rb"

describe "Buckets Snippets" do
  let(:storage_client)   { Google::Cloud::Storage.new }
  let(:kms_key)          { get_kms_key storage_client.project }
  let(:retention_period) { rand 1..99 }

  let :bucket do
    create_bucket_helper "ruby_storage_sample_#{SecureRandom.hex}"
  end

  let :secondary_bucket do
    create_bucket_helper "ruby_storage_sample_#{SecureRandom.hex}_secondary"
  end

  after do
    delete_bucket_helper bucket.name
    delete_bucket_helper secondary_bucket.name
  end

  describe "bucket lifecycle" do
    it "create_bucket, list_bucket_details, delete_bucket" do
      # create_bucket
      bucket_name = "ruby_storage_sample_#{SecureRandom.hex}"
      refute storage_client.bucket bucket_name

      retry_resource_exhaustion do
        assert_output "Created bucket: #{bucket_name}\n" do
          create_bucket bucket_name: bucket_name
        end
      end

      refute_nil storage_client.bucket bucket_name

      # list_bucket_details
      out, _err = capture_io do
        list_bucket_details bucket_name: bucket.name
      end

      assert_includes out, bucket.name

      # delete_bucket
      assert_output "Deleted bucket: #{bucket.name}\n" do
        delete_bucket bucket_name: bucket.name
      end

      refute storage_client.bucket bucket.name
    end
  end

  describe "create_bucket_class_location" do
    it "creates a storage bucket with a given class and location" do
      bucket_name = "ruby_storage_sample_#{SecureRandom.hex}"
      location = "US"
      storage_class = "STANDARD"
      refute storage_client.bucket bucket_name

      retry_resource_exhaustion do
        assert_output "Created bucket #{bucket_name} in #{location} with #{storage_class} class\n" do
          create_bucket_class_location bucket_name:   bucket_name,
                                       location:      location,
                                       storage_class: storage_class
        end
      end

      refute_nil storage_client.bucket bucket_name
      assert_equal storage_client.bucket(bucket_name).location, location
      assert_equal storage_client.bucket(bucket_name).storage_class, storage_class
      delete_bucket_helper bucket_name
    end
  end

  describe "list_buckets" do
    it "puts the buckets for a GCP project" do
      bucket
      secondary_bucket

      out, _err = capture_io do
        list_buckets
      end

      assert_includes out, bucket.name
      assert_includes out, secondary_bucket.name
    end
  end

  describe "requester_pays" do
    it "enable_requester_pays, get_requester_pays_status, disable_requester_pays" do
      # enable_requester_pays
      bucket.requester_pays = false

      assert_output "Requester pays has been enabled for #{bucket.name}\n" do
        enable_requester_pays bucket_name: bucket.name
      end
      bucket.refresh!
      assert bucket.requester_pays?

      # get_requester_pays_status
      assert_output "Requester Pays is enabled for #{bucket.name}\n" do
        get_requester_pays_status bucket_name: bucket.name
      end

      # disable_requester_pays
      assert_output "Requester pays has been disabled for #{bucket.name}\n" do
        disable_requester_pays bucket_name: bucket.name
      end
      bucket.refresh!
      refute bucket.requester_pays?

      # get_requester_pays_status
      assert_output "Requester Pays is disabled for #{bucket.name}\n" do
        get_requester_pays_status bucket_name: bucket.name
      end
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

      bucket.uniform_bucket_level_access = true
    end
  end

  describe "enable_default_kms_key" do
    it "sets a default kms key for a storage bucket" do
      refute bucket.default_kms_key

      assert_output "Default KMS key for #{bucket.name} was set to #{kms_key}\n" do
        enable_default_kms_key bucket_name:     bucket.name,
                               default_kms_key: kms_key
      end

      bucket.refresh!
      assert_equal bucket.default_kms_key, kms_key
    end
  end

  describe "bucket labels" do
    it "add_bucket_label, list_bucket_labels, delete_bucket_label" do
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


      # list_bucket_labels
      out, _err = capture_io do
        list_bucket_labels bucket_name: bucket.name
      end

      assert_includes out, "#{label_key} = #{label_value}"

      # delete_bucket_label
      assert_output "Deleted label #{label_key} from #{bucket.name}\n" do
        delete_bucket_label bucket_name: bucket.name,
                            label_key:   label_key
      end

      bucket.refresh!
      assert bucket.labels.empty?
    end
  end

  describe "retention policy" do
    it "set_retention_policy, get_retention_policy, remove_retention_policy" do
      # set_retention_policy
      assert_output "Retention period for #{bucket.name} is now #{retention_period} seconds.\n" do
        set_retention_policy bucket_name:      bucket.name,
                             retention_period: retention_period
      end

      bucket.refresh!
      assert_equal bucket.retention_period, retention_period

      # get_retention_policy
      bucket.retention_period = retention_period

      out, _err = capture_io do
        get_retention_policy bucket_name: bucket.name
      end

      assert_includes out, "period: #{retention_period}\n"

      # remove_retention_policy
      bucket.retention_period = retention_period
      secondary_bucket.retention_period = retention_period
      secondary_bucket.lock_retention_policy!

      assert_output "Retention policy for #{bucket.name} has been removed.\n" do
        remove_retention_policy bucket_name: bucket.name
      end

      bucket.refresh!
      refute bucket.retention_period

      assert_output "Policy is locked and retention policy can't be removed.\n" do
        remove_retention_policy bucket_name: secondary_bucket.name
      end
    end
  end

  describe "lock_retention_policy" do
    it "locks the retention policy for a given bucket" do
      # lock_retention_policy
      bucket.retention_period = retention_period
      out, _err = capture_io do
        lock_retention_policy bucket_name: bucket.name
      end

      assert_includes out, "Retention policy for #{bucket.name} is now locked."
      bucket.refresh!
      assert bucket.retention_policy_locked?
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
end
