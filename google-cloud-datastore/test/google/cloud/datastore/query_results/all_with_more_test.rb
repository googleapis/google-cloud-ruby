# Copyright 2014 Google LLC
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

describe Google::Cloud::Datastore::Dataset, :all_with_more, :mock_datastore do
  let(:first_run_query) { Google::Cloud::Datastore::Query.new.kind("Task").to_grpc }
  let(:first_run_query_res) do
    run_query_res_entities = 25.times.map do |i|
      Google::Datastore::V1::EntityResult.new(
        entity: Google::Cloud::Datastore::Entity.new.tap do |e|
          e.key = Google::Cloud::Datastore::Key.new "ds-test", 1000+i
          e["name"] = "thingamajig"
        end.to_grpc,
        cursor: "result-cursor-1-#{i}".force_encoding("ASCII-8BIT")
      )
    end
    Google::Datastore::V1::RunQueryResponse.new(
      batch: Google::Datastore::V1::QueryResultBatch.new(
        entity_results: run_query_res_entities,
        more_results: :NOT_FINISHED,
        end_cursor: "second-page-cursor".force_encoding("ASCII-8BIT")
      )
    )
  end
  let(:next_run_query) do
      Google::Cloud::Datastore::Query.new.kind("Task").start(
        Google::Cloud::Datastore::Cursor.from_grpc("second-page-cursor")
      ).to_grpc
    end
  let(:next_run_query_res) do
    run_query_res_entities = 25.times.map do |i|
      Google::Datastore::V1::EntityResult.new(
        entity: Google::Cloud::Datastore::Entity.new.tap do |e|
          e.key = Google::Cloud::Datastore::Key.new "ds-test", 2000+i
          e["name"] = "thingamajig"
        end.to_grpc,
        cursor: "result-cursor-2-#{i}".force_encoding("ASCII-8BIT")
      )
    end
    Google::Datastore::V1::RunQueryResponse.new(
      batch: Google::Datastore::V1::QueryResultBatch.new(
        entity_results: run_query_res_entities,
        more_results: :NOT_FINISHED,
        end_cursor: "third-page-cursor".force_encoding("ASCII-8BIT")
      )
    )
  end

  before do
    dataset.service.mocked_service = Minitest::Mock.new
    dataset.service.mocked_service.expect :run_query, first_run_query_res, [project, nil, read_options: nil, query: first_run_query, gql_query: nil, options: default_options]
    dataset.service.mocked_service.expect :run_query, next_run_query_res, [project, nil, read_options: nil, query: next_run_query, gql_query: nil, options: default_options]
  end

  after do
    dataset.service.mocked_service.verify
  end

  it "run will fulfill a query and can use the all and limit api calls" do
    entities = dataset.run dataset.query("Task")
    # set request_limit to 1 to only make one more request
    entities.all(request_limit: 1) do |entity|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
    end
  end

  it "run will fulfill a query and can use the all as a lazy enumerator" do
    entities = dataset.run dataset.query("Task")
    # no request_limit set, enumerator should only make 2 total requests though
    entities.all.lazy.take(30).count.must_equal 30
  end

  it "run will fulfill a query and can use the all_with_cursor and limit api calls" do
    entities = dataset.run dataset.query("Task")
    # set request_limit to 1 to only make one more request
    entities.all_with_cursor(request_limit: 1) do |entity, cursor|
      entity.must_be_kind_of Google::Cloud::Datastore::Entity
      cursor.must_be_kind_of Google::Cloud::Datastore::Cursor
    end
  end

  it "run will fulfill a query and can use the all_with_cursor as a lazy enumerator" do
    entities = dataset.run dataset.query("Task")
    # no request_limit set, enumerator should only make 2 total requests though
    entities.all_with_cursor.lazy.take(30).count.must_equal 30
  end
end
