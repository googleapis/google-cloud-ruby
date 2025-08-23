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

  it "can set the column name character map" do
    updater = new_updater
    updater.column_name_character_map = "default"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.column_name_character_map).must_equal "COLUMN_NAME_CHARACTER_MAP_UNSPECIFIED"

    updater.column_name_character_map = "strict"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.column_name_character_map).must_equal "STRICT"

    updater.column_name_character_map = "v1"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.column_name_character_map).must_equal "V1"

    updater.column_name_character_map = "v2"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.column_name_character_map).must_equal "V2"

    updater.column_name_character_map = "SOME_NEW_CHARACTER_MAP"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.column_name_character_map).must_equal "SOME_NEW_CHARACTER_MAP"
  end

  it "can set the source format" do
    updater = new_updater
    updater.format = "csv"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.source_format).must_equal "CSV"

    updater.format = "json"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.source_format).must_equal "NEWLINE_DELIMITED_JSON"

    updater.format = "avro"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.source_format).must_equal "AVRO"

    updater.format = "orc"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.source_format).must_equal "ORC"

    updater.format = :parquet
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.source_format).must_equal "PARQUET"

    updater.format = "SOME_NEW_UNSUPPORTED_FORMAT"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.source_format).must_equal "SOME_NEW_UNSUPPORTED_FORMAT"
  end

  it "can set the create disposition" do
    updater = new_updater
    updater.create = "needed"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.create_disposition).must_equal "CREATE_IF_NEEDED"

    updater.create = "never"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.create_disposition).must_equal "CREATE_NEVER"

    updater.create = "SOME_NEW_UNSUPPORTED_DISPOSITION"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.create_disposition).must_equal "SOME_NEW_UNSUPPORTED_DISPOSITION"
  end

  it "can set the write disposition" do
    updater = new_updater
    updater.write = "append"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.write_disposition).must_equal "WRITE_APPEND"

    updater.write = "truncate"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.write_disposition).must_equal "WRITE_TRUNCATE"

    updater.write = "empty"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.write_disposition).must_equal "WRITE_EMPTY"

    updater.write = "SOME_NEW_UNSUPPORTED_DISPOSITION"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.write_disposition).must_equal "SOME_NEW_UNSUPPORTED_DISPOSITION"
  end

  it "can set null_markers" do
    updater = new_updater
    updater.null_markers = ["", "NULL"]
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.null_markers).must_equal ["", "NULL"]

    updater.null_markers = nil
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.null_markers).must_be :nil?
  end

  it "can set source_column_match" do
    updater = new_updater
    updater.source_column_match = "POSITION"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.source_column_match).must_equal "POSITION"

    updater.source_column_match = nil
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.source_column_match).must_be :nil?
  end

  it "can set time_zone" do
    updater = new_updater
    updater.time_zone = "America/Los_Angeles"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.time_zone).must_equal "America/Los_Angeles"

    updater.time_zone = nil
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.time_zone).must_be :nil?
  end

  it "can set timestamp_format" do
    updater = new_updater
    updater.timestamp_format = "%Y-%m-%d %H:%M:%S.%f %z"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.timestamp_format).must_equal "%Y-%m-%d %H:%M:%S.%f %z"

    updater.timestamp_format = nil
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.timestamp_format).must_be :nil?
  end

  it "can set time_format" do
    updater = new_updater
    updater.time_format = "%H:%M:%S"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.time_format).must_equal "%H:%M:%S"

    updater.time_format = nil
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.time_format).must_be :nil?
  end

  it "can set date_format" do
    updater = new_updater
    updater.date_format = "%Y-%m-%d"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.date_format).must_equal "%Y-%m-%d"

    updater.date_format = nil
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.date_format).must_be :nil?
  end

  it "can set datetime_format" do
    updater = new_updater
    updater.datetime_format = "%Y-%m-%d %H:%M:%S"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.datetime_format).must_equal "%Y-%m-%d %H:%M:%S"

    updater.datetime_format = nil
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.datetime_format).must_be :nil?
  end
  
  it "can set reference_file_schema_uri" do
    updater = new_updater
    updater.reference_file_schema_uri = "gs://bucket/schema.json"
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.reference_file_schema_uri).must_equal "gs://bucket/schema.json"

    updater.reference_file_schema_uri = nil
    job_gapi = updater.to_gapi
    _(job_gapi.configuration.load.reference_file_schema_uri).must_be :nil?
  end
end