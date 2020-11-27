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

require "helper"

require "gapic/grpc/service_stub"

require "google/cloud/bigtable/admin/v2/bigtable_table_admin"

class ::Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin::HelpersTest < Minitest::Test
  def test_config_channel_args
    ::Gapic::ServiceStub.stub :new, nil do
      client = ::Google::Cloud::Bigtable::Admin::V2::BigtableTableAdmin::Client.new do |config|
        channel_args = config.channel_args
        assert channel_args
        assert_equal 30_000, channel_args["grpc.keepalive_time_ms"]
        assert_equal 10_000, channel_args["grpc.keepalive_timeout_ms"]
        assert_equal 1, channel_args["grpc.service_config_disable_resolution"]
      end
    end
  end
end
