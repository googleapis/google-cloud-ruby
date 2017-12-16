# Copyright 2017 Google LLC
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

require "spanner_helper"

describe "Spanner Client", :edge, :spanner do
  let(:db) { spanner_client }
  let(:bad_db) { spanner.client db.instance_id, "invalid_database" }
  let(:table_name) { "stuffs" }

  it "reads with invalid database fails" do
    assert_raises Google::Cloud::NotFoundError do
      bad_db.read table_name, [:id, :int]
    end
  end

  it "reads with invalid table fails" do
    assert_raises GRPC::NotFound do
      db.read "invalid_table", [:id, :int]
    end
  end

  it "reads with invalid column fails" do
    assert_raises GRPC::NotFound do
      db.read table_name, [:id, :invalid]
    end
  end

  it "writes to a non-existing table fails" do
    id = SecureRandom.int64
    assert_raises Google::Cloud::NotFoundError do
      db.upsert "invalid_table", { id: id, name: "invalid table" }
    end
  end

  it "writes to a non-existing column fails" do
    id = SecureRandom.int64
    assert_raises Google::Cloud::NotFoundError do
      db.upsert table_name, { id: id, invalid: "invalid column" }
    end
  end

  it "writes with incorrect column type fails" do
    id = SecureRandom.int64
    assert_raises Google::Cloud::FailedPreconditionError do
      db.upsert table_name, { id: id, int: "invalid type" }
    end
  end

  it "queries to a non-existing table fails" do
    assert_raises GRPC::InvalidArgument do
      db.execute "SELECT id, name FROM invalid_table"
    end
  end

  it "queries to a non-existing column fails" do
    assert_raises GRPC::InvalidArgument do
      db.execute "SELECT id, name FROM #{table_name}"
    end
  end

  it "queries with bad SQL fails" do
    assert_raises GRPC::InvalidArgument do
      db.execute "SELECT Apples AND Oranges"
    end
  end
end
