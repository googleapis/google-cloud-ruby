# Copyright 2015 Google Inc. All rights reserved.
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
require "json"
require "uri"

describe Gcloud::Bigquery::CopyJob, :mock_bigquery do
  let(:job) { Gcloud::Bigquery::Job.from_gapi copy_job_hash,
                                              bigquery.connection }
  let(:job_id) { job.job_id }

  it "knows it is copy job" do
    job.must_be_kind_of Gcloud::Bigquery::CopyJob
  end

  it "knows its copy tables" do
    mock_connection.get "/bigquery/v2/projects/source_project_id/datasets/source_dataset_id/tables/source_table_id" do |env|
      [200, {"Content-Type"=>"application/json"},
       source_table_json]
    end

    job.source.must_be_kind_of Gcloud::Bigquery::Table
    job.source.project_id.must_equal "source_project_id"
    job.source.dataset_id.must_equal "source_dataset_id"
    job.source.table_id.must_equal   "source_table_id"

    mock_connection.get "/bigquery/v2/projects/target_project_id/datasets/target_dataset_id/tables/target_table_id" do |env|
      [200, {"Content-Type"=>"application/json"},
       destination_table_json]
    end

    job.destination.must_be_kind_of Gcloud::Bigquery::Table
    job.destination.project_id.must_equal "target_project_id"
    job.destination.dataset_id.must_equal "target_dataset_id"
    job.destination.table_id.must_equal   "target_table_id"
  end

  it "knows its create/write disposition flags" do
    job.must_be :create_if_needed?
    job.wont_be :create_never?
    job.wont_be :write_truncate?
    job.wont_be :write_append?
    job.must_be :write_empty?
  end

  it "knows its copy config" do
    job.config.must_be_kind_of Hash
    job.config["copy"]["sourceTable"]["projectId"].must_equal "source_project_id"
    job.config["copy"]["destinationTable"]["tableId"].must_equal "target_table_id"
    job.config["copy"]["createDisposition"].must_equal "CREATE_IF_NEEDED"
  end

  def copy_job_hash
    hash = random_job_hash
    hash["configuration"]["copy"] = {
      "sourceTable" => {
        "projectId" => "source_project_id",
        "datasetId" => "source_dataset_id",
        "tableId"   => "source_table_id"
      },
      "destinationTable" => {
        "projectId" => "target_project_id",
        "datasetId" => "target_dataset_id",
        "tableId"   => "target_table_id"
      },
      "createDisposition" => "CREATE_IF_NEEDED",
      "writeDisposition" => "WRITE_EMPTY"
    }
    hash
  end

  def source_table_json
    hash = random_table_hash "getting_replaced_dataset_id"
    hash["tableReference"] = {
      "projectId" => "source_project_id",
      "datasetId" => "source_dataset_id",
      "tableId"   => "source_table_id"
    }
    hash.to_json
  end

  def destination_table_json
    hash = random_table_hash "getting_replaced_dataset_id"
    hash["tableReference"] = {
      "projectId" => "target_project_id",
      "datasetId" => "target_dataset_id",
      "tableId"   => "target_table_id"
    }
    hash.to_json
  end
end
