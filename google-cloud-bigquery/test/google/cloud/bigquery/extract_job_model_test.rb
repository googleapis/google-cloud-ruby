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

describe Google::Cloud::Bigquery::ExtractJob, :model, :mock_bigquery do
  let(:job) { Google::Cloud::Bigquery::Job.from_gapi extract_job_gapi, bigquery.service }
  let(:job_id) { job.job_id }

  it "knows it is extract job" do
    _(job).must_be_kind_of Google::Cloud::Bigquery::ExtractJob
  end

  it "knows its destination uris" do
    _(job.destinations).must_be_kind_of Array
    _(job.destinations.count).must_equal 1
    _(job.destinations.first).must_equal "gs://bucket/source_model_id"
  end

  it "knows its source model" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :get_model, random_model_full_hash("source_dataset_id", "source_model_id").to_json, ["test-project", "source_dataset_id", "source_model_id"], options: { skip_deserialization: true }

    source = job.source
    _(source).must_be_kind_of Google::Cloud::Bigquery::Model
    _(source.project_id).must_equal "test-project"
    _(source.dataset_id).must_equal "source_dataset_id"
    _(source.model_id).must_equal   "source_model_id"
    mock.verify
  end

  it "knows its attributes" do
    _(job).must_be :model?
    _(job).wont_be :table?
    _(job).must_be :ml_xgboost_booster?
    _(job).wont_be :ml_tf_saved_model?
    _(job).wont_be :compression?
    _(job).wont_be :json?
    _(job).wont_be :csv?
    _(job).wont_be :avro?
    _(job.delimiter).must_be :nil?
    _(job).wont_be :print_header?
    _(job).wont_be :use_avro_logical_types?
  end

  it "knows its extract config" do
    _(job.config).must_be_kind_of Hash
    _(job.config["extract"]["sourceModel"]["projectId"]).must_equal "test-project"
    _(job.config["extract"]["compression"]).must_be :nil?
    _(job.config["extract"]["fieldDelimiter"]).must_be :nil?
  end

  it "knows its statistics attributes" do
    # stats convenience method
    _(job.destinations_file_counts).must_be_kind_of Array
    _(job.destinations_file_counts.count).must_equal 1
    _(job.destinations_file_counts.first).must_equal 123

    # hash of the uris and the file counts
    _(job.destinations_counts).must_be_kind_of Hash
    _(job.destinations_counts.count).must_equal 1
    _(job.destinations_counts["gs://bucket/source_model_id"]).must_equal 123
  end

  def extract_job_gapi
    Google::Apis::BigqueryV2::Job.from_json extract_job_hash.to_json
  end

  def extract_job_hash
    hash = random_job_hash
    hash["configuration"]["extract"] = {
      "destinationUris" => ["gs://bucket/source_model_id"],
      "sourceModel" => {
        "projectId" => "test-project",
        "datasetId" => "source_dataset_id",
        "modelId"   => "source_model_id"
      },
      "destinationFormat" => "ML_XGBOOST_BOOSTER",
    }
    hash["statistics"]["extract"] = {
      "destinationUriFileCounts" => [123]
    }
    hash
  end
end
