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

describe Google::Cloud::Datastore::GqlQuery, :mock_datastore do
  it "can set named_bindings" do
    gql = Google::Cloud::Datastore::GqlQuery.new
    gql.query_string = "SELECT * FROM Task WHERE completed = @completed"
    gql.named_bindings = {completed: true}

    gql.query_string.must_equal "SELECT * FROM Task WHERE completed = @completed"
    gql.named_bindings.must_equal({"completed" => true})

    grpc = gql.to_grpc
    grpc.must_be_kind_of Google::Datastore::V1::GqlQuery

    grpc.query_string.must_equal gql.query_string
    grpc.named_bindings.count.must_equal 1
    grpc.named_bindings["completed"].value.boolean_value.must_equal true
  end

  it "can't modify named_bindings" do
    gql = Google::Cloud::Datastore::GqlQuery.new
    gql.query_string = "SELECT * FROM Task WHERE completed = @completed"
    expect { gql.named_bindings["completed"] = true }.must_raise RuntimeError
  end

  it "can set positional_bindings" do
    gql = Google::Cloud::Datastore::GqlQuery.new
    gql.query_string = "SELECT * FROM Task WHERE completed = @1"
    gql.positional_bindings = [true]

    gql.query_string.must_equal "SELECT * FROM Task WHERE completed = @1"
    gql.positional_bindings.must_equal [true]

    grpc = gql.to_grpc
    grpc.must_be_kind_of Google::Datastore::V1::GqlQuery

    grpc.query_string.must_equal gql.query_string
    grpc.positional_bindings.count.must_equal 1
    grpc.positional_bindings.first.value.boolean_value.must_equal true
  end

  it "can't modify positional_bindings" do
    gql = Google::Cloud::Datastore::GqlQuery.new
    gql.query_string = "SELECT * FROM Task WHERE completed = @1"
    expect { gql.positional_bindings[0] = true }.must_raise RuntimeError
  end

  it "can set and modify allow_literals" do
    gql = Google::Cloud::Datastore::GqlQuery.new
    gql.query_string = "SELECT * FROM Task WHERE completed = true"
    gql.allow_literals.must_equal false #default

    gql.allow_literals = true

    gql.query_string.must_equal "SELECT * FROM Task WHERE completed = true"
    gql.allow_literals.must_equal true

    grpc = gql.to_grpc
    grpc.must_be_kind_of Google::Datastore::V1::GqlQuery

    grpc.query_string.must_equal gql.query_string
    grpc.allow_literals.must_equal true
  end

  it "can set a Cursor as a named binding" do
    gql = Google::Cloud::Datastore::GqlQuery.new
    gql.query_string = "SELECT * FROM myKind LIMIT 50 OFFSET @startCursor"
    gql.named_bindings = {startCursor: Google::Cloud::Datastore::Cursor.new("c3VwZXJhd2Vzb21lIQ==")}

    grpc = gql.to_grpc
    grpc.must_be_kind_of Google::Datastore::V1::GqlQuery

    grpc.query_string.must_equal gql.query_string
    grpc.named_bindings.count.must_equal 1
    grpc.named_bindings["startCursor"].cursor.must_equal "superawesome!"
  end

  it "will break if setting a cursor that is not a Cursor object" do
    gql = Google::Cloud::Datastore::GqlQuery.new
    gql.query_string = "SELECT * FROM myKind LIMIT 50 OFFSET @startCursor"
    gql.named_bindings = {startCursor: "c3VwZXJhd2Vzb21lIQ=="}

    grpc = gql.to_grpc
    grpc.must_be_kind_of Google::Datastore::V1::GqlQuery

    grpc.query_string.must_equal gql.query_string
    grpc.named_bindings.count.must_equal 1
    # This is bad. The cursor value is not set properly. Query will fail.
    grpc.named_bindings["startCursor"].value.string_value.must_equal "c3VwZXJhd2Vzb21lIQ=="
  end
end
