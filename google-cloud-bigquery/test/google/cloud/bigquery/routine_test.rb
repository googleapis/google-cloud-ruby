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
require "json"
require "uri"

describe Google::Cloud::Bigquery::Routine, :mock_bigquery do
  # Create a routine object with the project's mocked connection object
  let(:dataset) { "my_dataset" }
  let(:routine_id) { "my_routine" }
  let(:etag) { "etag123456789" }
  let(:description) { "This is my routine" }
  let(:routine_hash) { random_routine_hash dataset, routine_id, description: description }
  let(:routine_gapi) { Google::Apis::BigqueryV2::Routine.from_json routine_hash.to_json }
  let(:routine) { Google::Cloud::Bigquery::Routine.from_gapi routine_gapi, bigquery.service }

  it "knows its attributes" do
    routine.etag.must_equal etag
    routine.description.must_equal description
    routine.return_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    routine.return_type.type_kind.must_equal "INT64"
    routine.body.must_equal "x * 3"
    routine.language.must_equal "SQL"
    routine.type.must_equal "SCALAR_FUNCTION"
    routine.arguments.must_be_kind_of Array
    routine.arguments.size.must_equal 1
    routine.arguments[0].must_be_kind_of Google::Cloud::Bigquery::Argument
    routine.arguments[0].name.must_equal "x"
    routine.arguments[0].data_type.must_be_kind_of Google::Cloud::Bigquery::StandardSql::DataType
    routine.arguments[0].data_type.type_kind.must_equal "INT64"
  end

  it "knows its creation and modification times" do
    now = ::Time.now
    routine_hash["creationTime"] = time_millis
    routine_hash["lastModifiedTime"] = time_millis


    routine.created_at.must_be_close_to now, 1
    routine.modified_at.must_be_close_to now, 1
  end

  it "can test its existence" do
    routine.exists?.must_equal true
  end

  it "can test its existence with force to load resource" do
    mock = Minitest::Mock.new
    mock.expect :get_routine, routine_gapi, [routine.project_id, routine.dataset_id, routine.routine_id]
    routine.service.mocked_service = mock

    routine.exists?(force: true).must_equal true

    mock.verify
  end

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_routine, nil, [project, dataset, routine_id]
    routine.service.mocked_service = mock

    routine.delete.must_equal true

    routine.exists?.must_equal false

    mock.verify
  end

  it "can reload itself" do
    new_description = "New description of the routine."

    mock = Minitest::Mock.new
    routine_hash = random_routine_hash dataset, routine_id, description: new_description
    mock.expect :get_routine, Google::Apis::BigqueryV2::Routine.from_json(routine_hash.to_json),
      [project, dataset, routine_id]
    routine.service.mocked_service = mock

    routine.description.must_equal description
    routine.reload!

    mock.verify

    routine.description.must_equal new_description
  end
end
