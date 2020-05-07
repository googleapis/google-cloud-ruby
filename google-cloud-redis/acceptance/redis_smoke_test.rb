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

require "simplecov"
require "minitest/autorun"

require "google/cloud/redis"

class RedisSmokeTest < Minitest::Test
  def test_list_instances_v1
    unless ENV["REDIS_TEST_PROJECT"]
      fail "REDIS_TEST_PROJECT environment variable must be defined"
    end
    project_id = ENV["REDIS_TEST_PROJECT"].freeze

    client = Google::Cloud::Redis.cloud_redis version: :v1
    parent = "projects/#{project_id}/locations/-"
    client.list_instances parent: parent
  end

  def test_list_instances_v1beta1
    unless ENV["REDIS_TEST_PROJECT"]
      fail "REDIS_TEST_PROJECT environment variable must be defined"
    end
    project_id = ENV["REDIS_TEST_PROJECT"].freeze

    client = Google::Cloud::Redis.cloud_redis version: :v1beta1
    parent = "projects/#{project_id}/locations/-"
    client.list_instances parent: parent
  end
end
