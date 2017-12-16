# Copyright 2016 Google LLC
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

require "helper"

describe Google::Cloud::Spanner::Instance, :mock_spanner do
  let(:instance_id) { "my-instance-id" }
  let(:database_id) { "my-database-id" }
  let(:database_json) { database_hash(instance_id: instance_id, database_id: database_id).to_json }
  let(:database_grpc) { Google::Spanner::Admin::Database::V1::Database.decode_json database_json }
  let(:database) { Google::Cloud::Spanner::Database.from_grpc database_grpc, spanner.service }

  it "knows the identifiers" do
    database.must_be_kind_of Google::Cloud::Spanner::Database
    database.project_id.must_equal project
    database.instance_id.must_equal instance_id
    database.database_id.must_equal database_id

    database.state.must_equal :READY
    database.must_be :ready?
    database.wont_be :creating?
  end
end
