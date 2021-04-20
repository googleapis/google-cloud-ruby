# frozen_string_literal: true

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


require "bigtable_helper"

describe "Instance Tables", :bigtable do
  let(:instance_id) { bigtable_instance_id }
  let(:cluster_id) { bigtable_cluster_id }

  it "create, list all, get table and delete table" do
    table_id = "test-table-#{random_str}"

    table = bigtable.create_table(instance_id, table_id) do |cfs|
      cfs.add("cf", gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(3))
    end

    _(table).must_be_kind_of Google::Cloud::Bigtable::Table
    _(table.table_id).must_equal table_id

    tables = bigtable.tables(instance_id).to_a
    _(tables).wont_be :empty?
    tables.each do |t|
      _(t).must_be_kind_of Google::Cloud::Bigtable::Table
    end

    table = bigtable.table(instance_id, table_id, perform_lookup: true)
    _(table).must_be_kind_of Google::Cloud::Bigtable::Table

    table.delete
    _(table.exists?).must_equal false
  end

  it "create table with initial splits and granularity" do
    table_id = "test-table-#{random_str}"
    initial_splits = ["customer-001", "customer-005", "customer-010"]

    table = bigtable.create_table(
        instance_id,
        table_id,
        initial_splits: initial_splits,
        granularity: :MILLIS) do |cfs|
      cfs.add("cf", gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(1))
    end

    _(table).must_be_kind_of Google::Cloud::Bigtable::Table
    _(table.granularity_millis?).must_equal true
    _(table.exists?).must_equal true

    entries = 10.times.map do |i|
      key = "customer-#{"%03d" % (i+1).to_s}"
      table.new_mutation_entry(key).set_cell("cf", "field1", "v-#{i+1}")
    end

    responses = table.mutate_rows(entries)
    _(responses.count).must_equal entries.count
    responses.each { |r| _(r.status.code).must_equal 0 }

    sample_keys = table.sample_row_keys.to_a.map(&:key)

    initial_splits.each do |key|
      _(sample_keys).must_include(key)
    end

    table.delete
  end

  it "creates a table with column families" do
    table_id = "test-table-#{random_str}"

    table = bigtable.create_table(instance_id, table_id) do |cfs|
      cfs.add("cf1") # default service value for GcRule
      cfs.add("cf2", gc_rule: Google::Cloud::Bigtable::GcRule.max_versions(5))
      cfs.add("cf3", gc_rule: Google::Cloud::Bigtable::GcRule.max_age(600))
    end

    column_families = table.column_families
    _(column_families).must_be_kind_of Google::Cloud::Bigtable::ColumnFamilyMap
    _(column_families).must_be :frozen?
    _(column_families.count).must_equal 3

    cf1 = column_families["cf1"]
    _(cf1).must_be_kind_of Google::Cloud::Bigtable::ColumnFamily
    _(cf1.gc_rule).must_be :nil?

    cf2 = column_families["cf2"]
    _(cf2).must_be_kind_of Google::Cloud::Bigtable::ColumnFamily
    _(cf2.gc_rule.max_versions).must_equal 5

    cf3 = column_families["cf3"]
    _(cf3).must_be_kind_of Google::Cloud::Bigtable::ColumnFamily
    _(cf3.gc_rule.max_age).must_equal 600

    table.delete
  end

  describe "views" do
    let(:table) { bigtable_read_table }

    it "Project#table loads NAME_ONLY by default" do
      _(table.loaded_views).must_equal Set[:NAME_ONLY]

      _(table.name).wont_be :nil?

      _(table.loaded_views).must_equal Set[:NAME_ONLY]

      _(table.grpc.name).wont_be :nil?
      _(table.grpc.cluster_states.count).must_equal 0 # Google::Protobuf::Map does not have #empty?
      _(table.grpc.column_families.count).must_equal 0 # Google::Protobuf::Map does not have #empty?
      _(table.grpc.granularity).must_equal :TIMESTAMP_GRANULARITY_UNSPECIFIED
    end

    it "column_families and granularity loads SCHEMA_VIEW" do
      _(table.column_families).wont_be :empty? # RPC
      _(table.granularity).must_equal :MILLIS

      _(table.loaded_views).must_equal Set[:NAME_ONLY, :SCHEMA_VIEW]

      _(table.grpc.name).wont_be :nil?
      _(table.grpc.cluster_states.count).must_equal 0
      _(table.grpc.column_families.count).must_be :>, 0
      _(table.grpc.granularity).must_equal :MILLIS
    end

    it "cluster_states loads FULL" do
      _(table.cluster_states).wont_be :empty? # RPC

      _(table.loaded_views).must_equal Set[:NAME_ONLY, :FULL]

      _(table.grpc.column_families.count).must_be :>, 0
      _(table.grpc.granularity).must_equal :MILLIS

      cluster_states = table.cluster_states
      _(cluster_states).must_be_instance_of Array
      _(cluster_states).wont_be :empty?
      cs = cluster_states.first
      _(cs).must_be_instance_of Google::Cloud::Bigtable::Table::ClusterState
      _(cs.replication_state).must_equal :READY

      encryption_infos = cs.encryption_infos
      _(encryption_infos).must_be_instance_of Array
      _(encryption_infos).wont_be :empty?
      encryption_infos.each do |encryption_info|
        _(encryption_info).must_be_instance_of Google::Cloud::Bigtable::EncryptionInfo
        _(encryption_info.encryption_type).must_equal :GOOGLE_DEFAULT_ENCRYPTION
        _(encryption_info.encryption_status).must_be :nil?
        _(encryption_info.kms_key_version).must_be :nil?
      end

      _(table.loaded_views).must_equal Set[:NAME_ONLY, :FULL]
    end

    it "column_families, granularity and cluster_states loads SCHEMA_VIEW, FULL" do
      _(table.column_families).wont_be :empty? # RPC
      _(table.granularity).must_equal :MILLIS
      _(table.cluster_states).wont_be :empty? # RPC

      _(table.loaded_views).must_equal Set[:NAME_ONLY, :SCHEMA_VIEW, :FULL]

      _(table.grpc.name).wont_be :nil?
      _(table.grpc.cluster_states.count).must_be :>, 0
      _(table.grpc.column_families.count).must_be :>, 0
      _(table.grpc.granularity).must_equal :MILLIS
    end

    it "reloads without view option" do
      table.reload!

      _(table.loaded_views).must_equal Set[:SCHEMA_VIEW]

      _(table.grpc.name).wont_be :nil?
      _(table.grpc.cluster_states.count).must_equal 0
      _(table.grpc.column_families.count).must_be :>, 0
      _(table.grpc.granularity).must_equal :MILLIS
    end

    it "reloads with view option NAME_ONLY" do
      table.reload! view: :NAME_ONLY

      _(table.loaded_views).must_equal Set[:NAME_ONLY]

      _(table.grpc.name).wont_be :nil?
      _(table.grpc.cluster_states.count).must_equal 0
      _(table.grpc.column_families.count).must_equal 0
      _(table.grpc.granularity).must_equal :TIMESTAMP_GRANULARITY_UNSPECIFIED
    end

    it "reloads with view option SCHEMA_VIEW" do
      table.reload! view: :SCHEMA_VIEW

      _(table.loaded_views).must_equal Set[:SCHEMA_VIEW]

      _(table.grpc.name).wont_be :nil?
      _(table.grpc.cluster_states.count).must_equal 0
      _(table.grpc.column_families.count).must_be :>, 0
      _(table.grpc.granularity).must_equal :MILLIS
    end

    it "reloads with view option ENCRYPTION_VIEW" do
      table.reload! view: :ENCRYPTION_VIEW

      _(table.loaded_views).must_equal Set[:ENCRYPTION_VIEW]

      _(table.grpc.name).wont_be :nil?
      _(table.grpc.column_families.count).must_equal 0
      _(table.grpc.granularity).must_equal :TIMESTAMP_GRANULARITY_UNSPECIFIED

      cluster_states = table.cluster_states
      _(cluster_states).must_be_instance_of Array
      _(cluster_states).wont_be :empty?
      cs = cluster_states.first
      _(cs).must_be_instance_of Google::Cloud::Bigtable::Table::ClusterState
      _(cs.replication_state).must_equal :STATE_NOT_KNOWN

      encryption_infos = cs.encryption_infos
      _(encryption_infos).must_be_instance_of Array
      _(encryption_infos).wont_be :empty?
      encryption_infos.each do |encryption_info|
        _(encryption_info).must_be_instance_of Google::Cloud::Bigtable::EncryptionInfo
        _(encryption_info.encryption_type).must_equal :GOOGLE_DEFAULT_ENCRYPTION
        _(encryption_info.encryption_status).must_be :nil?
        _(encryption_info.kms_key_version).must_be :nil?
      end

      _(table.loaded_views).must_equal Set[:ENCRYPTION_VIEW]
    end

    it "reloads with view option REPLICATION_VIEW" do
      table.reload! view: :REPLICATION_VIEW

      _(table.loaded_views).must_equal Set[:REPLICATION_VIEW]

      _(table.grpc.name).wont_be :nil?
      _(table.grpc.column_families.count).must_equal 0
      _(table.grpc.granularity).must_equal :TIMESTAMP_GRANULARITY_UNSPECIFIED
      
      cluster_states = table.cluster_states
      _(cluster_states).must_be_instance_of Array
      _(cluster_states).wont_be :empty?
      cs = cluster_states.first
      _(cs).must_be_instance_of Google::Cloud::Bigtable::Table::ClusterState
      _(cs.replication_state).must_equal :READY

      encryption_infos = cs.encryption_infos
      _(encryption_infos).must_be_instance_of Array
      _(encryption_infos).must_be :empty?

      _(table.loaded_views).must_equal Set[:REPLICATION_VIEW]
    end

    it "reloads with view option FULL" do
      table.reload! view: :FULL

      _(table.loaded_views).must_equal Set[:FULL]

      _(table.grpc.name).wont_be :nil?
      _(table.grpc.column_families.count).must_be :>, 0
      _(table.grpc.granularity).must_equal :MILLIS

      cluster_states = table.cluster_states
      _(cluster_states).must_be_instance_of Array
      _(cluster_states).wont_be :empty?
      cs = cluster_states.first
      _(cs).must_be_instance_of Google::Cloud::Bigtable::Table::ClusterState
      _(cs.replication_state).must_equal :READY

      encryption_infos = cs.encryption_infos
      _(encryption_infos).must_be_instance_of Array
      _(encryption_infos).wont_be :empty?
      encryption_infos.each do |encryption_info|
        _(encryption_info).must_be_instance_of Google::Cloud::Bigtable::EncryptionInfo
        _(encryption_info.encryption_type).must_equal :GOOGLE_DEFAULT_ENCRYPTION
        _(encryption_info.encryption_status).must_be :nil?
        _(encryption_info.kms_key_version).must_be :nil?
      end

      _(table.loaded_views).must_equal Set[:FULL]
    end
  end

  describe "replication consistency" do
    let(:table) { bigtable_read_table }

    it "generate consistency token and check consistency" do
      token = table.generate_consistency_token
      _(token).wont_be :nil?
      result = table.check_consistency(token)
      _([true, false]).must_include result
    end

    it "generate consistency token and check consistency wail unitil complete" do
      result = table.wait_for_replication(timeout: 600, check_interval: 3)
      _([true, false]).must_include result
    end
  end

  describe "IAM policies and permissions" do
    let(:service_account) { bigtable.service.credentials.client.issuer }
    let(:table) { bigtable_read_table }

    it "tests permissions" do
      roles = ["bigtable.tables.delete", "bigtable.tables.get"]
      permissions = table.test_iam_permissions(roles)
      _(permissions).must_be_kind_of Array
      _(permissions).must_equal roles
    end

    it "allows policy to be updated on a table" do
      _(table.policy).must_be_kind_of Google::Cloud::Bigtable::Policy

      _(service_account).wont_be :nil?

      role = "roles/bigtable.user"
      member = "serviceAccount:#{service_account}"

      policy = table.policy
      policy.add(role, member)
      updated_policy = table.update_policy(policy)

      _(updated_policy.role(role)).wont_be :nil?

      role_member = table.policy.role(role).select { |m| m == member }
      _(role_member.size).must_equal 1
    end
  end
end
