# frozen_string_literal: true

# Copyright 2020 Google LLC
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

describe Google::Cloud::Bigtable::Service, :bigtable do
  let(:config_metadata) { { :"google-cloud-resource-prefix" => "projects/#{bigtable.project_id}" } }
  let(:read_table) { bigtable_read_table }

  it "passes the correct configuration to its v2 instance admin client" do
    _(bigtable.project_id).wont_be :empty?
    config = bigtable.service.instances.configure
    _(config).must_be_kind_of Google::Cloud::Bigtable::Admin::V2::BigtableInstanceAdmin::Client::Configuration
    _(config.lib_name).must_equal "gccl"
    _(config.lib_version).must_equal Google::Cloud::Bigtable::VERSION
    _(config.metadata).must_equal config_metadata
  end

  it "passes the correct configuration to its v2 table admin client" do
    _(bigtable.project_id).wont_be :empty?
    config = bigtable.service.tables.configure
    _(config).must_be_kind_of Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin::Client::Configuration
    _(config.lib_name).must_equal "gccl"
    _(config.lib_version).must_equal Google::Cloud::Bigtable::VERSION
    _(config.metadata).must_equal config_metadata
  end

  it "passes the correct configuration to its v2 client" do
    _(bigtable.project_id).wont_be :empty?
    config = bigtable.service.client(read_table.path, read_table.app_profile_id).configure
    _(config).must_be_kind_of Google::Cloud::Bigtable::V2::Bigtable::Client::Configuration
    _(config.lib_name).must_equal "gccl"
    _(config.lib_version).must_equal Google::Cloud::Bigtable::VERSION
    _(config.metadata).must_equal config_metadata
  end
end
