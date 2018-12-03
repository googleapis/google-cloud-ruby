# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a extract of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Bigquery::Project, :extract_job, :mock_bigquery do
  let(:credentials) { OpenStruct.new }
  let(:storage) { Google::Cloud::Storage::Project.new(Google::Cloud::Storage::Service.new(project, credentials)) }
  let(:extract_bucket_gapi) {  Google::Apis::StorageV1::Bucket.from_json random_bucket_hash.to_json }
  let(:extract_bucket) { Google::Cloud::Storage::Bucket.from_gapi extract_bucket_gapi,
                                                           storage.service }
  let(:extract_file_gapi) { Google::Apis::StorageV1::Object.from_json random_file_hash(extract_bucket.name).to_json }
  let(:extract_file) { Google::Cloud::Storage::File.from_gapi extract_file_gapi,
                                                       storage.service }
  let(:extract_url) { extract_file.to_gs_url }

  let(:dataset) { "dataset" }
  let(:table_id) { "table_id" }
  let(:table_name) { "Target Table" }
  let(:description) { "This is the target table" }
  let(:table_gapi) { random_table_gapi dataset,
                                       table_id,
                                       table_name,
                                       description }
  let(:table) { Google::Cloud::Bigquery::Table.from_gapi table_gapi,
                                                  bigquery.service }
  let(:table_id_standard_sql) { "#{table.project_id}.#{table.dataset_id}.#{table.table_id}" }
  let(:table_id_legacy_sql) { "#{table.project_id}:#{table.dataset_id}.#{table.table_id}" }
  let(:labels) { { "foo" => "bar" } }
  let(:region) { "asia-northeast1" }

  it "can extract a table to a storage file using a Standard SQL table id" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = extract_job_gapi table, extract_file, location: nil

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.extract_job table_id_standard_sql, extract_file
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::ExtractJob
  end

  it "can extract a table to a storage file using a Legacy SQL table id" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = extract_job_gapi table, extract_file, location: nil

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.extract_job table_id_legacy_sql, extract_file
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::ExtractJob
  end

  it "can extract a table to a storage file" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = extract_job_gapi table, extract_file, location: nil

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.extract_job table, extract_file
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::ExtractJob
  end

  it "can extract a table to a storage url" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = extract_job_gapi table, extract_file, location: nil

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.extract_job table, extract_url
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::ExtractJob
  end

  it "can extract a table and determine the csv format" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = extract_job_gapi table, extract_file, location: nil
    job_gapi.configuration.extract.destination_format = "CSV"
    job_gapi.configuration.extract.destination_uris = [job_gapi.configuration.extract.destination_uris.first + ".csv"]

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.extract_job table, "#{extract_url}.csv"
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::ExtractJob
  end

  it "can extract a table and specify the csv format" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = extract_job_gapi table, extract_file, location: nil
    job_gapi.configuration.extract.destination_format = "CSV"

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.extract_job table, extract_url, format: :csv
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::ExtractJob
  end

  it "can extract a table and specify the csv format and options" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = extract_job_gapi table, extract_file, location: nil
    job_gapi.configuration.extract.destination_format = "CSV"
    job_gapi.configuration.extract.compression = "GZIP"
    job_gapi.configuration.extract.field_delimiter = "\t"
    job_gapi.configuration.extract.print_header = false

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.extract_job table, extract_url, format: :csv, compression: "GZIP", delimiter: "\t", header: false
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::ExtractJob
  end

  it "can extract a table and determine the json format" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = extract_job_gapi table, extract_file, location: nil
    job_gapi.configuration.extract.destination_format = "NEWLINE_DELIMITED_JSON"
    job_gapi.configuration.extract.destination_uris = [job_gapi.configuration.extract.destination_uris.first + ".json"]

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.extract_job table, "#{extract_url}.json"
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::ExtractJob
  end

  it "can extract a table and specify the json format" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = extract_job_gapi table, extract_file, location: nil
    job_gapi.configuration.extract.destination_format = "NEWLINE_DELIMITED_JSON"

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.extract_job table, extract_url, format: :json
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::ExtractJob
  end

  it "can extract a table and determine the avro format" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = extract_job_gapi table, extract_file, location: nil
    job_gapi.configuration.extract.destination_format = "AVRO"
    job_gapi.configuration.extract.destination_uris = [job_gapi.configuration.extract.destination_uris.first + ".avro"]

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.extract_job table, "#{extract_url}.avro"
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::ExtractJob
  end

  it "can extract a table and specify the avro format" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = extract_job_gapi table, extract_file, location: nil
    job_gapi.configuration.extract.destination_format = "AVRO"

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.extract_job table, extract_url, format: :avro
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::ExtractJob
  end

  it "can extract a table with job_id option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_id = "my_test_job_id"
    job_gapi = extract_job_gapi table, extract_file, job_id: job_id, location: nil

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.extract_job table, extract_url, job_id: job_id
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::ExtractJob
    job.job_id.must_equal job_id
  end

  it "can extract a table with prefix option" do
    generated_id = "9876543210"
    prefix = "my_test_job_prefix_"
    job_id = prefix + generated_id

    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = extract_job_gapi table, extract_file, job_id: job_id, location: nil

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.extract_job table, extract_url, prefix: prefix
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::ExtractJob
    job.job_id.must_equal job_id
  end

  it "can extract a table with job_id option if both job_id and prefix options are provided" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_id = "my_test_job_id"
    job_gapi = extract_job_gapi table, extract_file, job_id: job_id, location: nil

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.extract_job table, extract_url, job_id: job_id, prefix: "IGNORED"
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::ExtractJob
    job.job_id.must_equal job_id
  end

  it "can extract a table with the job labels option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    job_gapi = extract_job_gapi table, extract_file, location: nil
    job_gapi.configuration.labels = labels

    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.extract_job table, extract_file, labels: labels
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::ExtractJob
    job.labels.must_equal labels
  end

  it "can extract a table with the location option" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock
    insert_job_gapi = extract_job_gapi(table, extract_file)
    return_job_gapi = extract_job_gapi(table, extract_file)
    insert_job_gapi.job_reference.location = region
    return_job_gapi.job_reference.location = region

    mock.expect :insert_job, return_job_gapi, [project, insert_job_gapi]

    job = bigquery.extract_job table, extract_file do |j|
      j.location = region
    end
    mock.verify

    job.must_be_kind_of Google::Cloud::Bigquery::ExtractJob
    job.location.must_equal region
  end

  # Borrowed from MockStorage, extract to a common module?

  def random_bucket_hash name=random_bucket_name
    {"kind"=>"storage#bucket",
     "id"=>name,
     "selfLink"=>"https://www.googleapis.com/storage/v1/b/#{name}",
     "projectNumber"=>"1234567890",
     "name"=>name,
     "timeCreated"=>::Time.now,
     "metageneration"=>"1",
     "owner"=>{"entity"=>"project-owners-1234567890"},
     "location"=>"US",
     "storageClass"=>"STANDARD",
     "etag"=>"CAE=" }
  end

  def random_file_hash bucket=random_bucket_name, name=random_file_path
    {"kind"=>"storage#object",
     "id"=>"#{bucket}/#{name}/1234567890",
     "selfLink"=>"https://www.googleapis.com/storage/v1/b/#{bucket}/o/#{name}",
     "name"=>"#{name}",
     "bucket"=>"#{bucket}",
     "generation"=>"1234567890",
     "metageneration"=>"1",
     "contentType"=>"text/plain",
     "updated"=>::Time.now,
     "storageClass"=>"STANDARD",
     "size"=>rand(10_000),
     "md5Hash"=>"HXB937GQDFxDFqUGi//weQ==",
     "mediaLink"=>"https://www.googleapis.com/download/storage/v1/b/#{bucket}/o/#{name}?generation=1234567890&alt=media",
     "owner"=>{"entity"=>"user-1234567890", "entityId"=>"abc123"},
     "crc32c"=>"Lm1F3g==",
     "etag"=>"CKih16GjycICEAE="}
  end

  def random_bucket_name
    (0...50).map { ("a".."z").to_a[rand(26)] }.join
  end

  def random_file_path
    [(0...10).map { ("a".."z").to_a[rand(26)] }.join,
     (0...10).map { ("a".."z").to_a[rand(26)] }.join,
     (0...10).map { ("a".."z").to_a[rand(26)] }.join + ".txt"].join "/"
  end
end
