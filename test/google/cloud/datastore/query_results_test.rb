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
require "google/cloud/datastore"

describe Google::Cloud::Datastore::Dataset::QueryResults do
  let(:project)     { "my-todo-project" }
  let(:credentials) { OpenStruct.new }
  let(:dataset)     { Google::Cloud::Datastore::Dataset.new(Google::Cloud::Datastore::Service.new(project, credentials)) }
  let(:run_query_res) do
    run_query_res_entities = 2.times.map do |i|
      Google::Datastore::V1beta3::EntityResult.new(
        entity: Google::Cloud::Datastore::Entity.new.tap do |e|
          e.key = Google::Cloud::Datastore::Key.new "ds-test", "thingie"
          e["name"] = "thingamajig"
        end.to_grpc,
        cursor: "result-cursor-#{i}".force_encoding("ASCII-8BIT")
      )
    end
    Google::Datastore::V1beta3::RunQueryResponse.new(
      batch: Google::Datastore::V1beta3::QueryResultBatch.new(
        entity_results: run_query_res_entities,
        end_cursor: Google::Cloud::GRPCUtils.decode_bytes(query_cursor)
      )
    )
  end
  let(:query_cursor) { Google::Cloud::Datastore::Cursor.new "c3VwZXJhd2Vzb21lIQ==" }
  let(:run_query_res_not_finished) do
    run_query_res.tap do |response|
      response.batch.more_results = :NOT_FINISHED
    end
  end
  let(:run_query_res_more_after_limit) do
    run_query_res.tap do |response|
      response.batch.more_results = :MORE_RESULTS_AFTER_LIMIT
    end
  end
  let(:run_query_res_more_after_cursor) do
    run_query_res.tap do |response|
      response.batch.more_results = :MORE_RESULTS_AFTER_CURSOR
    end
  end
  let(:run_query_res_no_more) do
    run_query_res.tap do |response|
      response.batch.more_results = :NO_MORE_RESULTS
    end
  end

  before do
    dataset.service.mocked_datastore = Minitest::Mock.new
  end

  after do
    dataset.service.mocked_datastore.verify
  end

  it "has more_results not_finished" do
    run_query_req = Google::Datastore::V1beta3::RunQueryRequest.new(
      project_id: project,
      query: Google::Cloud::Datastore::Query.new.kind("User").to_grpc
    )
    dataset.service.mocked_datastore.expect :run_query, run_query_res_not_finished, [run_query_req]

    query = Google::Cloud::Datastore::Query.new.kind("User")
    entities = dataset.run query
    entities.count.must_equal 2
    entities.each do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end
    entities.cursor_for(entities.first).must_equal Google::Cloud::Datastore::Cursor.from_grpc("result-cursor-0")
    entities.cursor_for(entities.last).must_equal  Google::Cloud::Datastore::Cursor.from_grpc("result-cursor-1")
    entities.each_with_cursor do |entity, cursor|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
      cursor.must_be_kind_of Google::Cloud::Datastore::Cursor
    end
    # can use the enumerator without passing a block...
    entities.each_with_cursor.map do |entity, cursor|
      [entity.key, cursor]
    end.each do |result, cursor|
      result.must_be_kind_of Google::Cloud::Datastore::Key
      cursor.must_be_kind_of Google::Cloud::Datastore::Cursor
    end
    entities.cursor.must_equal query_cursor
    entities.more_results.must_equal :NOT_FINISHED
    assert entities.not_finished?
    refute entities.more_after_limit?
    refute entities.more_after_cursor?
    refute entities.no_more?
  end

  it "has more_results more_after_limit" do
    run_query_req = Google::Datastore::V1beta3::RunQueryRequest.new(
      project_id: project,
      query: Google::Cloud::Datastore::Query.new.kind("User").to_grpc
    )
    dataset.service.mocked_datastore.expect :run_query, run_query_res_more_after_limit, [run_query_req]

    query = Google::Cloud::Datastore::Query.new.kind("User")
    entities = dataset.run query
    entities.count.must_equal 2
    entities.each do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end
    entities.cursor_for(entities.first).must_equal Google::Cloud::Datastore::Cursor.from_grpc("result-cursor-0")
    entities.cursor_for(entities.last).must_equal  Google::Cloud::Datastore::Cursor.from_grpc("result-cursor-1")
    entities.each_with_cursor do |entity, cursor|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
      cursor.must_be_kind_of Google::Cloud::Datastore::Cursor
    end
    # can use the enumerator without passing a block...
    entities.each_with_cursor.map do |entity, cursor|
      [entity.key, cursor]
    end.each do |result, cursor|
      result.must_be_kind_of Google::Cloud::Datastore::Key
      cursor.must_be_kind_of Google::Cloud::Datastore::Cursor
    end
    entities.cursor.must_equal query_cursor
    entities.more_results.must_equal :MORE_RESULTS_AFTER_LIMIT
    refute entities.not_finished?
    assert entities.more_after_limit?
    refute entities.more_after_cursor?
    refute entities.no_more?
  end

  it "has more_results more_after_cursor" do
    run_query_req = Google::Datastore::V1beta3::RunQueryRequest.new(
      project_id: project,
      query: Google::Cloud::Datastore::Query.new.kind("User").to_grpc
    )
    dataset.service.mocked_datastore.expect :run_query, run_query_res_more_after_cursor, [run_query_req]

    query = Google::Cloud::Datastore::Query.new.kind("User")
    entities = dataset.run query
    entities.count.must_equal 2
    entities.each do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end
    entities.cursor_for(entities.first).must_equal Google::Cloud::Datastore::Cursor.from_grpc("result-cursor-0")
    entities.cursor_for(entities.last).must_equal  Google::Cloud::Datastore::Cursor.from_grpc("result-cursor-1")
    entities.each_with_cursor do |entity, cursor|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
      cursor.must_be_kind_of Google::Cloud::Datastore::Cursor
    end
    # can use the enumerator without passing a block...
    entities.each_with_cursor.map do |entity, cursor|
      [entity.key, cursor]
    end.each do |result, cursor|
      result.must_be_kind_of Google::Cloud::Datastore::Key
      cursor.must_be_kind_of Google::Cloud::Datastore::Cursor
    end
    entities.cursor.must_equal query_cursor
    entities.more_results.must_equal :MORE_RESULTS_AFTER_CURSOR
    refute entities.not_finished?
    refute entities.more_after_limit?
    assert entities.more_after_cursor?
    refute entities.no_more?
  end

  it "has more_results no_more" do
    run_query_req = Google::Datastore::V1beta3::RunQueryRequest.new(
      project_id: project,
      query: Google::Cloud::Datastore::Query.new.kind("User").to_grpc
    )
    dataset.service.mocked_datastore.expect :run_query, run_query_res_no_more, [run_query_req]

    query = Google::Cloud::Datastore::Query.new.kind("User")
    entities = dataset.run query
    entities.count.must_equal 2
    entities.each do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end
    entities.cursor_for(entities.first).must_equal Google::Cloud::Datastore::Cursor.from_grpc("result-cursor-0")
    entities.cursor_for(entities.last).must_equal  Google::Cloud::Datastore::Cursor.from_grpc("result-cursor-1")
    entities.each_with_cursor do |entity, cursor|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
      cursor.must_be_kind_of Google::Cloud::Datastore::Cursor
    end
    # can use the enumerator without passing a block...
    entities.each_with_cursor.map do |entity, cursor|
      [entity.key, cursor]
    end.each do |result, cursor|
      result.must_be_kind_of Google::Cloud::Datastore::Key
      cursor.must_be_kind_of Google::Cloud::Datastore::Cursor
    end
    entities.cursor.must_equal query_cursor
    entities.more_results.must_equal :NO_MORE_RESULTS
    refute entities.not_finished?
    refute entities.more_after_limit?
    refute entities.more_after_cursor?
    assert entities.no_more?
  end
end
