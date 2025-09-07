# Copyright 2025 Google LLC
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
require "google/cloud/storage/control"
require_relative "../storage_control_create_anywhere_cache"
require_relative "../storage_control_list_anywhere_caches"
require_relative "../storage_control_get_anywhere_cache"
require_relative "../storage_control_update_anywhere_cache"
require_relative "../storage_control_pause_anywhere_cache"
require_relative "../storage_control_resume_anywhere_cache"
require_relative "../storage_control_disable_anywhere_cache"

describe "Storage Control Anywhere Cache" do
  let(:bucket_name) { random_bucket_name }
  let(:zone) { "us-east1-b" }
  # Set project to "_" to signify global bucket
  let(:anywhere_cache_name) { "projects/_/buckets/#{bucket_name}/anywhereCaches/#{zone}" }

  before :all do
    @bucket = create_bucket_helper bucket_name
  end

  after do
    delete_bucket_helper(bucket_name) until count_anywhere_caches(bucket_name) == 0
  end

  it "handles Anywhere cache lifecycle in sequence" do
    out_create, _err = capture_io do
      create_anywhere_cache bucket_name: bucket_name, zone: zone
    end
    assert_includes out_create, "AnywhereCache created - #{anywhere_cache_name}"

    out_list, _err = capture_io do
      list_anywhere_caches bucket_name: bucket_name
    end
    assert_includes out_list, "AnywhereCache #{anywhere_cache_name} found in list"

    out_get, _err = capture_io do
      get_anywhere_cache bucket_name: bucket_name, anywhere_cache_id: zone
    end
    assert_includes out_get, "AnywhereCache #{anywhere_cache_name} fetched"

    out_update, _err = capture_io do
      update_anywhere_cache bucket_name: bucket_name, anywhere_cache_id: zone
    end
    assert_includes out_update, "AnywhereCache #{anywhere_cache_name} updated"

    out_pause, _err = capture_io do
      pause_anywhere_cache bucket_name: bucket_name, anywhere_cache_id: zone
    end
    assert_includes out_pause, "AnywhereCache #{anywhere_cache_name} paused"

    out_resume, _err = capture_io do
      resume_anywhere_cache bucket_name: bucket_name, anywhere_cache_id: zone
    end
    assert_includes out_resume, "AnywhereCache #{anywhere_cache_name} running"

    out_disable, _err = capture_io do
      disable_anywhere_cache bucket_name: bucket_name, anywhere_cache_id: zone
    end
    assert_includes out_disable, "AnywhereCache #{anywhere_cache_name} disabled"
  end
end

def count_anywhere_caches bucket_name
  sleep 900
  storage_control_client = Google::Cloud::Storage::Control.storage_control
  # Set project to "_" to signify global bucket
  parent = "projects/_/buckets/#{bucket_name}"
  request = Google::Cloud::Storage::Control::V2::ListAnywhereCachesRequest.new(
    parent: parent
  )
  result = storage_control_client.list_anywhere_caches request
  result.response.anywhere_caches.count
end
