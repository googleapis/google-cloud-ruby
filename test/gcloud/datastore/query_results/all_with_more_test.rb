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

describe Gcloud::Datastore::Dataset, :all_with_more do
  let(:project)     { "my-todo-project" }
  let(:credentials) { OpenStruct.new }
  let(:dataset)     { Gcloud::Datastore::Dataset.new(Gcloud::Datastore::Service.new(project, credentials)) }
  let(:first_run_query_req) do
    Google::Datastore::V1beta3::RunQueryRequest.new(
      project_id: project,
      query: Gcloud::Datastore::Query.new.kind("Task").to_grpc
    )
  end
  let(:first_run_query_res) do
    run_query_res_entities = 25.times.map do |i|
      Google::Datastore::V1beta3::EntityResult.new(
        entity: Gcloud::Datastore::Entity.new.tap do |e|
          e.key = Gcloud::Datastore::Key.new "ds-test", 1000+i
          e["name"] = "thingamajig"
        end.to_grpc,
        cursor: "result-cursor-1-#{i}".force_encoding("ASCII-8BIT")
      )
    end
    Google::Datastore::V1beta3::RunQueryResponse.new(
      batch: Google::Datastore::V1beta3::QueryResultBatch.new(
        entity_results: run_query_res_entities,
        more_results: :MORE_RESULTS_AFTER_CURSOR,
        end_cursor: "second-page-cursor".force_encoding("ASCII-8BIT")
      )
    )
  end
  let(:next_run_query_req) do
    Google::Datastore::V1beta3::RunQueryRequest.new(
      project_id: project,
      query: Gcloud::Datastore::Query.new.kind("Task").start(
        Gcloud::Datastore::Cursor.from_grpc("second-page-cursor")
      ).to_grpc
    )
  end
  let(:next_run_query_res) do
    run_query_res_entities = 25.times.map do |i|
      Google::Datastore::V1beta3::EntityResult.new(
        entity: Gcloud::Datastore::Entity.new.tap do |e|
          e.key = Gcloud::Datastore::Key.new "ds-test", 2000+i
          e["name"] = "thingamajig"
        end.to_grpc,
        cursor: "result-cursor-2-#{i}".force_encoding("ASCII-8BIT")
      )
    end
    Google::Datastore::V1beta3::RunQueryResponse.new(
      batch: Google::Datastore::V1beta3::QueryResultBatch.new(
        entity_results: run_query_res_entities,
        more_results: :MORE_RESULTS_AFTER_CURSOR,
        end_cursor: "third-page-cursor".force_encoding("ASCII-8BIT")
      )
    )
  end

  before do
    dataset.service.mocked_datastore = Minitest::Mock.new
    dataset.service.mocked_datastore.expect :run_query, first_run_query_res, [first_run_query_req]
    dataset.service.mocked_datastore.expect :run_query, next_run_query_res, [next_run_query_req]
  end

  after do
    dataset.service.mocked_datastore.verify
  end

  it "run will fulfill a query and can use the all and limit api calls" do
    entities = dataset.run dataset.query("Task")
    # change request_limit to 2 to see more requests attempted
    entities.all(request_limit: 1) do |entity|
      entity.must_be_kind_of Gcloud::Datastore::Entity
    end
  end

  it "run will fulfill a query and can use the all as a lazy enumerator" do
    entities = dataset.run dataset.query("Task")
    # change request_limit to 2 to see more requests attempted
    entities.all.lazy.take(30).count.must_equal 30
  end

  it "run will fulfill a query and can use the all_with_cursor and limit api calls" do
    entities = dataset.run dataset.query("Task")
    # change request_limit to 2 to see more requests attempted
    entities.all_with_cursor(request_limit: 1) do |entity, cursor|
      entity.must_be_kind_of Gcloud::Datastore::Entity
      cursor.must_be_kind_of Gcloud::Datastore::Cursor
    end
  end

  it "run will fulfill a query and can use the all_with_cursor as a lazy enumerator" do
    entities = dataset.run dataset.query("Task")
    # change request_limit to 2 to see more requests attempted
    entities.all_with_cursor.lazy.take(30).count.must_equal 30
  end
end
