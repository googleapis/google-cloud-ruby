# Copyright 2014 Google Inc. All rights reserved.
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
require "gcloud/datastore"

describe Gcloud::Datastore::Connection do
  let(:project)     { "my-todo-project" }
  let(:credentials) { OpenStruct.new }
  let(:connection)  { Gcloud::Datastore::Connection.new project, credentials }
  let(:http_mock)   { Minitest::Mock.new }
  let(:mocks)       { [] }

  before do
    connection.http = http_mock
    mocks << http_mock
  end

  it "makes an http POST for allocate_ids" do
    http_mock.expect :post, new_response_mock, [rpc_path("allocateIds")]
    key = Gcloud::Datastore::Key.new "User"
    response = connection.allocate_ids key.to_proto, key.to_proto, key.to_proto
    response.must_be_kind_of Gcloud::Datastore::Proto::AllocateIdsResponse
  end

  it "makes an http POST for lookup" do
    http_mock.expect :post, new_response_mock, [rpc_path("lookup")]
    key1 = Gcloud::Datastore::Key.new "User", "silvolu"
    key2 = Gcloud::Datastore::Key.new "User", "blowmage"
    response = connection.lookup key1.to_proto, key2.to_proto, consistency: nil
    response.must_be_kind_of Gcloud::Datastore::Proto::LookupResponse
  end

  it "makes an http POST for run_query" do
    http_mock.expect :post, new_response_mock, [rpc_path("runQuery")]
    query = Gcloud::Datastore::Query.new.kind("User")
    response = connection.run_query query.to_proto
    response.must_be_kind_of Gcloud::Datastore::Proto::RunQueryResponse
  end

  it "makes an http POST for begin_transaction" do
    http_mock.expect :post, new_response_mock, [rpc_path("beginTransaction")]
    response = connection.begin_transaction
    response.must_be_kind_of Gcloud::Datastore::Proto::BeginTransactionResponse
  end

  it "makes an http POST for commit" do
    http_mock.expect :post, new_response_mock, [rpc_path("commit")]
    mutation_proto = Gcloud::Datastore::Proto::Mutation.new
    response = connection.commit mutation_proto
    response.must_be_kind_of Gcloud::Datastore::Proto::CommitResponse
  end

  it "makes an http POST for commit with transaction" do
    http_mock.expect :post, new_response_mock, [rpc_path("commit")]
    mutation_proto = Gcloud::Datastore::Proto::Mutation.new
    response = connection.commit mutation_proto, "transaction123456"
    response.must_be_kind_of Gcloud::Datastore::Proto::CommitResponse
  end

  it "makes an http POST for rollback" do
    http_mock.expect :post, new_response_mock, [rpc_path("rollback")]
    response = connection.rollback "transaction123456"
    response.must_be_kind_of Gcloud::Datastore::Proto::RollbackResponse
  end

  after do
    mocks.each { |mock| mock.verify }
  end

  def rpc_path method
    connection.send :rpc_path, method
  end

  def new_response_mock
    response_mock = Minitest::Mock.new
    response_mock.expect :success?, true
    response_mock.expect :body, ""
    mocks << response_mock
    response_mock
  end
end
