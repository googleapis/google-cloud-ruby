# frozen_string_literal: true

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "../default_values"
require_relative "helper"

require "google/cloud/storage"


class ComputeDefaultValuesTest < Minitest::Test
  TEST_PREFIX = "some-prefix"

  def setup
    storage_client = ::Google::Cloud::Storage.new project_id: project
    @bucket = storage_client.create_bucket random_bucket_name
  end

  def teardown
    @bucket.delete
  end

  def test_set_usage_export_bucket_default
    assert_output(/default prefix of `usage_gce`/) do
      set_usage_export_bucket project: project, bucket_name: @bucket.name
    end
    uel = get_usage_export_bucket project: project
    assert_equal @bucket.name, uel.bucket_name
    assert_equal "usage_gce", uel.report_name_prefix

    disable_usage_export project: project
    assert_nil get_usage_export_bucket project: project
  end

  def test_set_usage_export_bucket_custom
    out = capture_io do
      set_usage_export_bucket project: project, bucket_name: @bucket.name,
                              report_name_prefix: TEST_PREFIX
    end
    refute_match(/usage_gce/, out.first)
    uel = get_usage_export_bucket project: project
    assert_equal @bucket.name, uel.bucket_name
    assert_equal TEST_PREFIX, uel.report_name_prefix

    disable_usage_export project: project
    assert_nil get_usage_export_bucket project: project
  end
end
