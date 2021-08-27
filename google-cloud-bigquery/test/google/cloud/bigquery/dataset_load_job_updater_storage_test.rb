# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a load of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Google::Cloud::Bigquery::Dataset, :load_job, :updater, :storage, :mock_bigquery do
  let(:credentials) { OpenStruct.new }
  let(:storage) { Google::Cloud::Storage::Project.new(Google::Cloud::Storage::Service.new(project, credentials)) }
  let(:load_bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json random_bucket_hash.to_json }
  let(:load_bucket) { Google::Cloud::Storage::Bucket.from_gapi load_bucket_gapi, storage.service }
  let(:load_file) { storage_file }
  let(:load_url) { load_file.to_gs_url }

  let(:dataset_id) { "my_dataset" }
  let(:dataset_gapi) { random_dataset_gapi dataset_id }
  let(:dataset) { Google::Cloud::Bigquery::Dataset.from_gapi dataset_gapi, bigquery.service }

  let(:table_id) { "table_id" }
  let(:table_name) { "Target Table" }
  let(:description) { "This is the target table" }
  let(:table_hash) { random_table_hash dataset_id, table_id, table_name, description }
  let(:table_gapi) { Google::Apis::BigqueryV2::Table.from_json table_hash.to_json }
  let(:table) { Google::Cloud::Bigquery::Table.from_gapi table_gapi, bigquery.service }
  let(:labels) { { "foo" => "bar" } }
  let(:kms_key) { "path/to/encryption_key_name" }
  let(:region) { "asia-northeast1" }

  def storage_file path = nil
    gapi = Google::Apis::StorageV1::Object.from_json random_file_hash(load_bucket.name, path).to_json
    Google::Cloud::Storage::File.from_gapi gapi, storage.service
  end

  it "sets a provided job_id prefix in the updater" do
    generated_id = "9876543210"
    prefix = "my_test_job_prefix_"
    job_id = prefix + generated_id
    special_file = storage_file "data.json"
    special_url = special_file.to_gs_url

    mock = Minitest::Mock.new
    job_gapi = load_job_url_gapi table_gapi.table_reference, special_url, job_id: job_id
    job_gapi.configuration.load.source_format = "NEWLINE_DELIMITED_JSON"
    mock.expect :insert_job, load_job_resp_gapi(table, special_url, job_id: job_id),
                [project, job_gapi]
    dataset.service.mocked_service = mock

    job = dataset.load_job table_id, special_file, job_id: job_id do |j|
      _(j.job_id).must_equal job_id
    end
    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob

    mock.verify
  end

  it "can specify a storage file with format" do
    special_file = storage_file "data.json"
    special_url = special_file.to_gs_url

    mock = Minitest::Mock.new
    job_gapi = load_job_url_gapi table_gapi.table_reference, special_url
    job_gapi.configuration.load.source_format = "CSV"
    mock.expect :insert_job, load_job_resp_gapi(table, special_url),
      [project, job_gapi]
    dataset.service.mocked_service = mock

    job = dataset.load_job table_id, special_file do |j|
      j.format = :csv
    end
    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob

    mock.verify
  end

  it "can specify a storage file and derive CSV format with CSV options" do
    special_file = storage_file "data.csv"
    special_url = special_file.to_gs_url

    mock = Minitest::Mock.new
    job_gapi = load_job_csv_options_gapi table_gapi.table_reference
    job_gapi.configuration.load.source_uris = [special_url]
    mock.expect :insert_job, load_job_resp_gapi(table, special_url),
      [project, job_gapi]
    dataset.service.mocked_service = mock

    job = dataset.load_job table_id, special_file do |j|
      j.jagged_rows = true
      j.quoted_newlines = true
      j.autodetect = true
      j.encoding = "ISO-8859-1"
      j.delimiter = "\t"
      j.ignore_unknown = true
      j.max_bad_records = 42
      j.null_marker = "\N"
      j.quote = "'"
      j.skip_leading = 1
    end
    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob

    mock.verify
  end

  it "can load a Datastore backup file and specify projection fields" do
    special_file = storage_file "data.backup_info"
    special_url = special_file.to_gs_url
    projection_fields = ["first_name"]

    mock = Minitest::Mock.new
    job_gapi = load_job_url_gapi table_gapi.table_reference, special_url
    job_gapi.configuration.load.source_format = "DATASTORE_BACKUP"
    job_gapi.configuration.load.projection_fields = projection_fields
    mock.expect :insert_job, load_job_resp_gapi(table, special_url),
      [project, job_gapi]
    dataset.service.mocked_service = mock

    job = dataset.load_job table_id, special_file do |j|
      j.projection_fields = projection_fields
    end
    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob

    mock.verify
  end

  it "can load itself with create disposition" do
    mock = Minitest::Mock.new
    job_gapi = load_job_url_gapi table_gapi.table_reference, load_url
    job_gapi.configuration.load.create_disposition = "CREATE_NEVER"
    mock.expect :insert_job, load_job_resp_gapi(table, load_url),
      [project, job_gapi]
    dataset.service.mocked_service = mock

    job = dataset.load_job table_id, load_url do |j|
      j.create = "CREATE_NEVER"
    end
    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob

    mock.verify
  end

  it "can load itself with create disposition symbol" do
    mock = Minitest::Mock.new
    job_gapi = load_job_url_gapi table_gapi.table_reference, load_url
    job_gapi.configuration.load.create_disposition = "CREATE_NEVER"
    mock.expect :insert_job, load_job_resp_gapi(table, load_url),
      [project, job_gapi]
    dataset.service.mocked_service = mock

    job = dataset.load_job table_id, load_url do |j|
      j.create = :never
    end
    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob

    mock.verify
  end

  it "can load itself with write disposition" do
    mock = Minitest::Mock.new
    job_gapi = load_job_url_gapi table_gapi.table_reference, load_url
    job_gapi.configuration.load.write_disposition = "WRITE_TRUNCATE"
    mock.expect :insert_job, load_job_resp_gapi(table, load_url),
      [project, job_gapi]
    dataset.service.mocked_service = mock

    job = dataset.load_job table_id, load_url do |j|
      j.write = "WRITE_TRUNCATE"
    end
    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob

    mock.verify
  end

  it "can load itself with write disposition symbol" do
    mock = Minitest::Mock.new
    job_gapi = load_job_url_gapi table_gapi.table_reference, load_url
    job_gapi.configuration.load.write_disposition = "WRITE_TRUNCATE"
    mock.expect :insert_job, load_job_resp_gapi(table, load_url),
      [project, job_gapi]
    dataset.service.mocked_service = mock

    job = dataset.load_job table_id, load_url do |j|
      j.write = :truncate
    end
    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob

    mock.verify
  end

  it "can load a storage file with the job labels option" do
    mock = Minitest::Mock.new
    job_gapi = load_job_url_gapi table_gapi.table_reference, load_url
    job_gapi.configuration.labels = labels
    mock.expect :insert_job, load_job_resp_gapi(table, load_url, labels: labels),
      [project, job_gapi]
    dataset.service.mocked_service = mock

    job = dataset.load_job table_id, load_file do |j|
      j.labels = labels
    end
    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
    _(job.labels).must_equal labels

    mock.verify
  end

  it "can load a storage file with the encryption option" do
    mock = Minitest::Mock.new
    job_gapi = load_job_url_gapi table_gapi.table_reference, load_url
    job_gapi.configuration.load.destination_encryption_configuration = encryption_gapi(kms_key)
    mock.expect :insert_job, job_gapi,
                [project, job_gapi]
    dataset.service.mocked_service = mock

    encrypt_config = bigquery.encryption kms_key: kms_key

    job = dataset.load_job table_id, load_file do |j|
      j.encryption = encrypt_config
    end
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
    _(job.encryption).must_be_kind_of Google::Cloud::Bigquery::EncryptionConfiguration
    _(job.encryption.kms_key).must_equal kms_key
  end

  it "can load a storage file with the location option" do
    mock = Minitest::Mock.new
    insert_job_gapi = load_job_url_gapi table_gapi.table_reference, load_url
    return_job_gapi = load_job_url_gapi table_gapi.table_reference, load_url
    insert_job_gapi.job_reference.location = region
    return_job_gapi.job_reference.location = region
    mock.expect :insert_job, return_job_gapi,
                [project, insert_job_gapi]
    dataset.service.mocked_service = mock

    job = dataset.load_job table_id, load_file do |j|
      _(j.location).must_equal "US"
      j.location = region
    end
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
    _(job.location).must_equal region
  end

  it "can load a storage file and unset location" do
    mock = Minitest::Mock.new
    insert_job_gapi = load_job_url_gapi table_gapi.table_reference, load_url
    return_job_gapi = load_job_url_gapi table_gapi.table_reference, load_url
    insert_job_gapi.job_reference.remove_instance_variable :@location
    return_job_gapi.job_reference.location = "US"
    mock.expect :insert_job, return_job_gapi,
                [project, insert_job_gapi]
    dataset.service.mocked_service = mock

    job = dataset.load_job table_id, load_file do |j|
      _(j.location).must_equal "US"
      j.location = nil
    end
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
    _(job.location).must_equal "US"
  end

  it "can specify a storage URI with hive partitioning options" do
    gcs_uri = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/*"
    source_uri_prefix = "gs://cloud-samples-data/bigquery/hive-partitioning-samples/autolayout/"

    mock = Minitest::Mock.new
    hive_partitioning_options = Google::Apis::BigqueryV2::HivePartitioningOptions.new(
      mode: "AUTO",
      source_uri_prefix: source_uri_prefix
    )
    job_gapi = load_job_url_gapi table_gapi.table_reference, gcs_uri, hive_partitioning_options: hive_partitioning_options
    job_gapi.configuration.load.source_format = "PARQUET"
    mock.expect :insert_job,
                load_job_resp_gapi(table, gcs_uri, source_format: "PARQUET", hive_partitioning_options: hive_partitioning_options),
                [project, job_gapi]
    dataset.service.mocked_service = mock

    job = dataset.load_job table_id, gcs_uri do |j|
      j.format = "parquet"
      j.hive_partitioning_mode = :auto
      j.hive_partitioning_source_uri_prefix = source_uri_prefix
    end
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
    _(job.parquet?).must_equal true
    _(job.hive_partitioning?).must_equal true
    _(job.hive_partitioning_mode).must_equal "AUTO"
    _(job.hive_partitioning_source_uri_prefix).must_equal source_uri_prefix
  end

  it "can specify a storage URIs with Parquet options" do
    gcs_uris = ["gs://mybucket/00/*.parquet", "gs://mybucket/01/*.parquet"]

    mock = Minitest::Mock.new
    parquet_options = Google::Apis::BigqueryV2::ParquetOptions.new(
      enable_list_inference: true,
      enum_as_string: true
    )
    job_gapi = load_job_url_gapi table_gapi.table_reference, gcs_uris, parquet_options: parquet_options
    job_gapi.configuration.load.source_format = "PARQUET"
    mock.expect :insert_job,
                load_job_resp_gapi(table, gcs_uris, source_format: "PARQUET", parquet_options: parquet_options),
                [project, job_gapi]
    dataset.service.mocked_service = mock

    job = dataset.load_job table_id, gcs_uris do |j|
      j.parquet_enable_list_inference = true
      j.parquet_enum_as_string = true
    end
    mock.verify

    _(job).must_be_kind_of Google::Cloud::Bigquery::LoadJob
    _(job.parquet?).must_equal true
    _(job.parquet_options?).must_equal true
    _(job.parquet_enable_list_inference?).must_equal true
    _(job.parquet_enum_as_string?).must_equal true
  end

  # Borrowed from MockStorage, load to a common module?

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
