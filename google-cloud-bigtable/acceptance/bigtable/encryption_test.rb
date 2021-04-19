# frozen_string_literal: true

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


require "bigtable_helper"

describe Google::Cloud::Bigtable::Project, :encryption, :bigtable do
  let(:instance_id_cmek) { "google-cloud-ruby-tests-kms" }
  let(:cluster_id_cmek) { "ruby-clstr-kms" }
  let(:cluster_location) { "us-east1-b" }
  let(:kms_key_name) { bigtable_kms_key }
  let(:table_id) { "test-table-#{random_str}" }
  let(:backup_id) { "test-backup-#{random_str}" }

  after do
    @backup.delete if @backup
    @table.delete if @table
    @instance.delete if @instance
  end

  it "creates an instance, cluster, table and backup with CMEK" do
    job = bigtable.create_instance instance_id_cmek, display_name: "Ruby Test with KMS key", type: :DEVELOPMENT do |clusters|
      # "Need to have at least one cluster map element in CreateInstanceRequest."
      clusters.add cluster_id_cmek, cluster_location, kms_key: kms_key_name # nodes not allowed
    end
    job.wait_until_done!
    _(job.error).must_be :nil?

    @instance = job.instance
    _(@instance).must_be_kind_of Google::Cloud::Bigtable::Instance
    _(@instance.clusters.count).must_equal 1

    cluster = @instance.clusters.first
    _(cluster.kms_key).must_equal kms_key_name

    @table = create_test_table instance_id_cmek, table_id, row_count: 5, cleanup: false

    @table.reload! view: :ENCRYPTION_VIEW

    cluster_states = @table.cluster_states
    _(cluster_states).must_be_instance_of Array
    _(cluster_states).wont_be :empty?
    cs = cluster_states.first
    encryption_infos = cs.encryption_infos
    _(encryption_infos).must_be_instance_of Array
    _(encryption_infos).wont_be :empty?
    encryption_infos.each do |encryption_info|
      _(encryption_info).must_be_instance_of Google::Cloud::Bigtable::EncryptionInfo
      _(encryption_info.encryption_type).must_equal :CUSTOMER_MANAGED_ENCRYPTION
      _(encryption_info.encryption_status).must_be_instance_of Google::Cloud::Bigtable::Status
      _(encryption_info.encryption_status.description).must_equal "UNKNOWN"
      _(encryption_info.kms_key_version).must_be :nil?
    end

    job = cluster.create_backup @table, backup_id, (Time.now.round(0) + 60 * 60 * 7)
    job.wait_until_done!
    _(job.error).must_be :nil?

    @backup = job.backup
    _(@backup).must_be_kind_of Google::Cloud::Bigtable::Backup
    _(@backup.ready?).must_equal true
    backup_encryption_info = @backup.encryption_info
    _(backup_encryption_info.encryption_type).must_equal :CUSTOMER_MANAGED_ENCRYPTION
    _(backup_encryption_info.encryption_status).must_be_instance_of Google::Cloud::Bigtable::Status
    _(backup_encryption_info.encryption_status.description).must_equal "UNKNOWN"
    _(backup_encryption_info.kms_key_version).must_be_instance_of String
    _(backup_encryption_info.kms_key_version).must_include "/cryptoKeyVersions/"
  end
end
