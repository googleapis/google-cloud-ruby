# Copyright 2018 Google LLC
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

require "google/apis/bigquery_v2"

describe Google::Cloud::Bigquery::LoadJob::Updater do
  def new_updater
    new_job = Google::Apis::BigqueryV2::Job.new(
      configuration: Google::Apis::BigqueryV2::JobConfiguration.new(
        load: Google::Apis::BigqueryV2::JobConfigurationLoad.new
      )
    )
    Google::Cloud::Bigquery::LoadJob::Updater.new new_job
  end

  it "can set the source format" do
    updater = new_updater
    updater.format = "csv"
    job_gapi = updater.to_gapi
    job_gapi.configuration.load.source_format.must_equal "CSV"

    updater.format = "json"
    job_gapi = updater.to_gapi
    job_gapi.configuration.load.source_format.must_equal "NEWLINE_DELIMITED_JSON"

    updater.format = "avro"
    job_gapi = updater.to_gapi
    job_gapi.configuration.load.source_format.must_equal "AVRO"

    updater.format = "orc"
    job_gapi = updater.to_gapi
    job_gapi.configuration.load.source_format.must_equal "ORC"

    updater.format = "parquet"
    job_gapi = updater.to_gapi
    job_gapi.configuration.load.source_format.must_equal "PARQUET"

    updater.format = "SOME_NEW_UNSUPPORTED_FORMAT"
    job_gapi = updater.to_gapi
    job_gapi.configuration.load.source_format.must_equal "SOME_NEW_UNSUPPORTED_FORMAT"
  end

  it "can set the create disposition" do
    updater = new_updater
    updater.create = "needed"
    job_gapi = updater.to_gapi
    job_gapi.configuration.load.create_disposition.must_equal "CREATE_IF_NEEDED"

    updater.create = "never"
    job_gapi = updater.to_gapi
    job_gapi.configuration.load.create_disposition.must_equal "CREATE_NEVER"

    updater.create = "SOME_NEW_UNSUPPORTED_DISPOSITION"
    job_gapi = updater.to_gapi
    job_gapi.configuration.load.create_disposition.must_equal "SOME_NEW_UNSUPPORTED_DISPOSITION"
  end

  it "can set the write disposition" do
    updater = new_updater
    updater.write = "append"
    job_gapi = updater.to_gapi
    job_gapi.configuration.load.write_disposition.must_equal "WRITE_APPEND"

    updater.write = "truncate"
    job_gapi = updater.to_gapi
    job_gapi.configuration.load.write_disposition.must_equal "WRITE_TRUNCATE"

    updater.write = "empty"
    job_gapi = updater.to_gapi
    job_gapi.configuration.load.write_disposition.must_equal "WRITE_EMPTY"

    updater.write = "SOME_NEW_UNSUPPORTED_DISPOSITION"
    job_gapi = updater.to_gapi
    job_gapi.configuration.load.write_disposition.must_equal "SOME_NEW_UNSUPPORTED_DISPOSITION"
  end
end