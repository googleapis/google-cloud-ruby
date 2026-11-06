# Copyright 2026 Google LLC
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
require_relative "../storage_control_create_rapid_cache"
require_relative "../storage_control_get_rapid_cache"
require_relative "../storage_control_list_rapid_caches"
require_relative "../storage_control_update_rapid_cache"
require_relative "../storage_control_disable_rapid_cache"

describe "Storage Control Rapid Cache" do
  # Rapid Cache Ultra requires a regional bucket with hierarchical namespace
  # enabled, located in the same region as the cache zone.
  let(:zone) { ENV["STORAGE_CONTROL_RAPID_CACHE_ZONE"] || "us-east1-b" }
  let(:bucket_name) { @bucket_name }
  # The Rapid Cache ID must be the same as the zone.
  let(:cache_id) { zone }
  let(:cache_name) { "projects/_/buckets/#{bucket_name}/rapidCaches/#{cache_id}" }
  # The disable operation only completes once the cache has been fully
  # removed, which can take more than an hour, so bound the wait.
  let(:disable_timeout) { 600 }
  # Like the Anywhere Cache tests, these tests are not run in CI because a
  # bucket cannot be deleted until its Rapid Cache has been fully removed,
  # which can take more than 30 minutes. Set
  # STORAGE_CONTROL_RUN_RAPID_CACHE_TESTS to run them.
  let(:run_tests) { ENV["STORAGE_CONTROL_RUN_RAPID_CACHE_TESTS"] }

  before :all do
    next unless run_tests

    @bucket_name = random_bucket_name
    create_bucket_helper @bucket_name,
                         location: zone_region(zone),
                         uniform_bucket_level_access: true,
                         hierarchical_namespace: { enabled: true }
    # Wait for the bucket metadata to propagate to the Storage Control API.
    sleep 20
  end

  after :all do
    # Disable the cache if the test created it but did not disable it, so that
    # it does not outlive the test.
    cache_active = @bucket_name && rapid_cache_active?(@bucket_name, zone)
    if cache_active
      capture_io do
        disable_rapid_cache bucket_name: @bucket_name, cache_id: zone, timeout: disable_timeout
      end
    end
  ensure
    # Best-effort cleanup. The bucket cannot be deleted while it still has a
    # Rapid Cache, so it may be left for the stale bucket cleanup job.
    delete_bucket_with_rapid_cache_helper @bucket_name if @bucket_name
  end

  it "handles Rapid Cache lifecycle in sequence" do
    skip "Set STORAGE_CONTROL_RUN_RAPID_CACHE_TESTS to run Rapid Cache tests" unless run_tests

    out_create, _err = capture_io do
      create_rapid_cache bucket_name: bucket_name, zone: zone
    end
    assert_includes out_create, "Created Rapid Cache: #{cache_name}"
    assert_includes out_create, "Cache type: rapid-cache-ultra"

    out_get, _err = capture_io do
      get_rapid_cache bucket_name: bucket_name, cache_id: cache_id
    end
    assert_includes out_get, "Got Rapid Cache: #{cache_name}"
    assert_includes out_get, "Zone: #{zone}"
    assert_includes out_get, "Cache type: rapid-cache-ultra"
    assert_includes out_get, "State: running"

    out_list, _err = capture_io do
      list_rapid_caches bucket_name: bucket_name
    end
    assert_includes out_list.lines.map(&:chomp), cache_name

    out_update, _err = capture_io do
      update_rapid_cache bucket_name: bucket_name, cache_id: cache_id, ttl_seconds: 172_800
    end
    assert_includes out_update, "Updated Rapid Cache: #{cache_name}"
    assert_includes out_update, "TTL: 172800 seconds"

    out_disable, _err = capture_io do
      disable_rapid_cache bucket_name: bucket_name, cache_id: cache_id, timeout: disable_timeout
    end
    # The disable operation may still be in progress after the timeout.
    assert_includes out_disable, cache_name

    # The cache moves to the "disabled" state shortly after the disable
    # request, even if the operation has not completed yet. Wait up to about
    # two minutes for the state change.
    cache_active = rapid_cache_active? bucket_name, cache_id
    12.times do
      break unless cache_active
      sleep 10
      cache_active = rapid_cache_active? bucket_name, cache_id
    end
    refute cache_active, "Rapid Cache #{cache_name} was not disabled"
  end
end
