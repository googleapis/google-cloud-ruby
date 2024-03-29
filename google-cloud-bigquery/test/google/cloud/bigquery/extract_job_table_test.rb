# Copyright 2015 Google LLC
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

describe Google::Cloud::Bigquery::ExtractJob, :table, :mock_bigquery do
  let(:job) { Google::Cloud::Bigquery::Job.from_gapi extract_job_gapi,
                                              bigquery.service }
  let(:job_id) { job.job_id }

  it "knows it is extract job" do
    _(job).must_be_kind_of Google::Cloud::Bigquery::ExtractJob
  end

  it "knows its destination uris" do
    _(job.destinations).must_be_kind_of Array
    _(job.destinations.count).must_equal 1
    _(job.destinations.first).must_equal "gs://bucket/file-*.ext"
  end

  it "knows its source table" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :get_table, source_table_gapi, ["source_project_id", "source_dataset_id", "source_table_id"], **patch_table_args

    source = job.source
    _(source).must_be_kind_of Google::Cloud::Bigquery::Table
    _(source.project_id).must_equal "source_project_id"
    _(source.dataset_id).must_equal "source_dataset_id"
    _(source.table_id).must_equal   "source_table_id"
    mock.verify
  end

  it "knows its source table with partial prjection of table metadata" do
    %w[unspecified basic storage full].each do |view|
      mock = Minitest::Mock.new
      bigquery.service.mocked_service = mock
      source_table_result = source_table_gapi

      if view == "basic"
        source_table_result = source_table_partial_gapi
      end

      mock.expect :get_table, source_table_result, ["source_project_id", "source_dataset_id", "source_table_id"],
                  **patch_table_args(view: view)

      source = job.source view: view
      _(source).must_be_kind_of Google::Cloud::Bigquery::Table
      _(source.project_id).must_equal "source_project_id"
      _(source.dataset_id).must_equal "source_dataset_id"
      _(source.table_id).must_equal "source_table_id"
      verify_table_metadata source, view

      mock.verify
    end
  end

  it "knows its attributes" do
    _(job).must_be :table?
    _(job).wont_be :model?
    _(job).must_be :compression?
    _(job).must_be :json?
    _(job).wont_be :csv?
    _(job).wont_be :avro?
    _(job.delimiter).must_equal ","
    _(job).must_be :print_header?
    _(job).must_be :use_avro_logical_types?
  end

  it "knows its extract config" do
    _(job.config).must_be_kind_of Hash
    _(job.config["extract"]["sourceTable"]["projectId"]).must_equal "source_project_id"
    _(job.config["extract"]["compression"]).must_equal "GZIP"
    _(job.config["extract"]["fieldDelimiter"]).must_equal ","
  end

  it "knows its statistics attributes" do
    # stats convenience method
    _(job.destinations_file_counts).must_be_kind_of Array
    _(job.destinations_file_counts.count).must_equal 1
    _(job.destinations_file_counts.first).must_equal 123

    # hash of the uris and the file counts
    _(job.destinations_counts).must_be_kind_of Hash
    _(job.destinations_counts.count).must_equal 1
    _(job.destinations_counts["gs://bucket/file-*.ext"]).must_equal 123
  end

  def extract_job_gapi
    Google::Apis::BigqueryV2::Job.from_json extract_job_hash.to_json
  end

  def extract_job_hash
    hash = random_job_hash
    hash["configuration"]["extract"] = {
      "destinationUris" => ["gs://bucket/file-*.ext"],
      "sourceTable" => {
        "projectId" => "source_project_id",
        "datasetId" => "source_dataset_id",
        "tableId"   => "source_table_id"
      },
      "compression" => "GZIP",
      "destinationFormat" => "NEWLINE_DELIMITED_JSON",
      "fieldDelimiter" => ",",
      "printHeader" => true,
      "useAvroLogicalTypes" => true
    }
    hash["statistics"]["extract"] = {
      "destinationUriFileCounts" => [123]
    }
    hash
  end
end
