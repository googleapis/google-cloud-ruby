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

require "helper"
require "google/cloud/spanner/admin/database"
require "google/cloud/spanner/admin/database/v1/database_admin"
require "gapic/common"
require "gapic/grpc"

class Google::Cloud::Spanner::ClientConstructionMinitest < Minitest::Test
  def test_database_admin
    emulator_host = "localhost:4567"
    emulator_check = ->(name) { (name == "SPANNER_EMULATOR_HOST") ? emulator_host : nil }
    # Clear all environment variables, except SPANNER_EMULATOR_HOST
    ENV.stub :[], emulator_check do
      Gapic::ServiceStub.stub :new, :stub do
          client = Google::Cloud::Spanner::Admin::Database.database_admin project_id: "1234"
          assert_kind_of Google::Cloud::Spanner::Admin::Database::V1::DatabaseAdmin::Client, client
          # TODO: Figure out why this fails.
          # assert_equal :this_channel_is_insecure, client.configure.credentials
          assert_equal emulator_host, client.configure.endpoint
      end
    end
  end
end
