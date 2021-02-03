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
  let(:routine_hash) { random_routine_hash dataset_id, routine_id, determinism_level: "DETERMINISTIC" }
  let(:routine_gapi) { Google::Apis::BigqueryV2::Routine.from_json routine_hash.to_json }
  let(:routine_insert_hash) { random_routine_hash dataset_id, routine_id, etag: nil, creation_time: nil, last_modified_time: nil, determinism_level: "DETERMINISTIC" }
  let(:routine_insert_gapi) { Google::Apis::BigqueryV2::Routine.from_json routine_insert_hash.to_json }

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

    _(routine).must_be_kind_of Google::Cloud::Bigquery::Routine
    _(routine.routine_id).must_equal routine_id
  end

  it "creates a routine with attributes in a block" do
    mock = Minitest::Mock.new
    mock.expect :insert_routine, routine_gapi, [project, dataset_id, routine_insert_gapi]
    dataset.service.mocked_service = mock

    routine = dataset.create_routine routine_id do |r|
      # Note: This kitchen sink configuration is unrealistic since it includes all attributes.
      r.routine_type = "SCALAR_FUNCTION"
      r.language = "SQL"
      r.arguments = [
        Google::Cloud::Bigquery::Argument.new(
          name: "arr",
          argument_kind: "FIXED_TYPE",
          mode: "IN",
          data_type: Google::Cloud::Bigquery::StandardSql::DataType.new(
            type_kind: "ARRAY",
            array_element_type: Google::Cloud::Bigquery::StandardSql::DataType.new(
              type_kind: "STRUCT",
              struct_type: Google::Cloud::Bigquery::StandardSql::StructType.new(
                fields: [
                  Google::Cloud::Bigquery::StandardSql::Field.new(
                    name: "my-struct-name",
                    type: Google::Cloud::Bigquery::StandardSql::DataType.new(type_kind: "STRING")
                  ),
                  Google::Cloud::Bigquery::StandardSql::Field.new(
                    name: "my-struct-val",
                    type: Google::Cloud::Bigquery::StandardSql::DataType.new(type_kind: "INT64")
                  )
                ]
              )  
            )
          )
        ),
        Google::Cloud::Bigquery::Argument.new(
          name: "out",
          argument_kind: "ANY_TYPE",
          mode: "OUT",
          data_type: Google::Cloud::Bigquery::StandardSql::DataType.new(type_kind: "STRING")
        )
      ]
      r.return_type = "INT64"
      r.imported_libraries = ["gs://cloud-samples-data/bigquery/udfs/max-value.js"]
      r.body = "x * 3"
      r.description = "This is my routine"
      r.determinism_level = "DETERMINISTIC"
      expect { r.update }.must_raise RuntimeError
      expect { r.delete }.must_raise RuntimeError
      expect { r.reload! }.must_raise RuntimeError
      expect { r.refresh! }.must_raise RuntimeError
    end  

    mock.verify

    _(routine).must_be_kind_of Google::Cloud::Bigquery::Routine
    _(routine.routine_id).must_equal routine_id
  end

  it "finds a routine" do
    found_routine_id = "found_routine"

    mock = Minitest::Mock.new
    mock.expect :get_routine, random_routine_gapi(dataset.dataset_id, found_routine_id), [project, dataset.dataset_id, found_routine_id]
    dataset.service.mocked_service = mock

    routine = dataset.routine found_routine_id

    mock.verify

    _(routine).must_be_kind_of Google::Cloud::Bigquery::Routine
    _(routine.routine_id).must_equal found_routine_id
  end
end
