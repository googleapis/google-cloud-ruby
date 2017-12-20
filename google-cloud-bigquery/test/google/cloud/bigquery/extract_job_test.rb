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

describe Google::Cloud::BigQuery::ExtractJob, :mock_bigquery do
  let(:job) { Google::Cloud::BigQuery::Job.from_gapi extract_job_gapi,
                                              bigquery.service }
  let(:job_id) { job.job_id }

  it "knows it is extract job" do
    job.must_be_kind_of Google::Cloud::BigQuery::ExtractJob
  end

  it "knows its destination uris" do
    job.destinations.must_be_kind_of Array
    job.destinations.count.must_equal 1
    job.destinations.first.must_equal "gs://bucket/file-*.ext"
  end

  it "knows its source table" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :get_table, source_table_gapi, ["source_project_id", "source_dataset_id", "source_table_id"]

    source = job.source
    source.must_be_kind_of Google::Cloud::BigQuery::Table
    source.project_id.must_equal "source_project_id"
    source.dataset_id.must_equal "source_dataset_id"
    source.table_id.must_equal   "source_table_id"
    mock.verify
  end

  it "knows its attributes" do
    job.must_be :compression?
    job.must_be :json?
    job.wont_be :csv?
    job.wont_be :avro?
    job.delimiter.must_equal ","
    job.must_be :print_header?
  end

  it "knows its extract config" do
    job.config.must_be_kind_of Hash
    job.config["extract"]["sourceTable"]["projectId"].must_equal "source_project_id"
    job.config["extract"]["compression"].must_equal "GZIP"
    job.config["extract"]["fieldDelimiter"].must_equal ","
  end

  it "knows its statistics attributes" do
    # stats convenience method
    job.destinations_file_counts.must_be_kind_of Array
    job.destinations_file_counts.count.must_equal 1
    job.destinations_file_counts.first.must_equal 123

    # hash of the uris and the file counts
    job.destinations_counts.must_be_kind_of Hash
    job.destinations_counts.count.must_equal 1
    job.destinations_counts["gs://bucket/file-*.ext"].must_equal 123
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
      "printHeader" => true
    }
    hash["statistics"]["extract"] = {
      "destinationUriFileCounts" => [123]
    }
    hash
  end
end
