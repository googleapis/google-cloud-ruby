# Copyright 2016 Google Inc. All rights reserved.
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
  let(:instance) { Google::Cloud::Spanner::Instance.new instance_id, spanner.service }

  it "knows the identifiers" do
    instance.must_be_kind_of Google::Cloud::Spanner::Instance
    instance.project_id.must_equal project
    instance.instance_id.must_equal instance_id
  end

  it "builds a database" do
    database = instance.database "my-database-id"

    database.must_be_kind_of Google::Cloud::Spanner::Database
    database.database_id.must_equal "my-database-id"
  end

  it "builds a database with the default id" do
    ENV.stub :[], "my-database-id", ["SPANNER_DATABASE"] do
      database = instance.database

      database.must_be_kind_of Google::Cloud::Spanner::Database
      database.database_id.must_equal "my-database-id"
    end
  end
end
