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

describe Google::Cloud::Bigquery::Dataset, :routine, :mock_bigquery do
  let(:dataset_id) { "my_dataset" }
  let(:dataset_hash) { random_dataset_hash dataset_id }
  let(:dataset_gapi) { Google::Apis::BigqueryV2::Dataset.from_json dataset_hash.to_json }
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi, bigquery.service }
  let(:routine_id) { "my-routine-id" }

  it "creates a routine" do
    mock = Minitest::Mock.new
    insert_routine = Google::Apis::BigqueryV2::Routine.new(
      routine_reference: Google::Apis::BigqueryV2::RoutineReference.new(
        project_id: project, dataset_id: dataset_id, routine_id: routine_id))
    return_routine = insert_routine.dup
    mock.expect :insert_routine, return_routine, [project, dataset_id, insert_routine]
    dataset.service.mocked_service = mock

    routine = dataset.create_routine routine_id

    mock.verify

    routine.must_be_kind_of Google::Cloud::Bigquery::Routine
    routine.routine_id.must_equal routine_id
  end

  it "finds a routine" do
    found_routine_id = "found_routine"

    mock = Minitest::Mock.new
    mock.expect :get_routine, random_routine_gapi(dataset.dataset_id, found_routine_id), [project, dataset.dataset_id, found_routine_id]
    dataset.service.mocked_service = mock

    routine = dataset.routine found_routine_id

    mock.verify

    routine.must_be_kind_of Google::Cloud::Bigquery::Routine
    routine.routine_id.must_equal found_routine_id
  end
end
