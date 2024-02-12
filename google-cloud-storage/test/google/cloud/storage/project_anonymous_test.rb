# Copyright 2017 Google LLC
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

describe Google::Cloud::Storage::Project, :anonymous, :mock_storage do
  let(:bucket_name) { "new-bucket-#{Time.now.to_i}" }
  let(:anonymous_storage) { Google::Cloud::Storage.anonymous }

  it "raises when creating a bucket without authentication" do
    stub = self
    def stub.insert_bucket *args
      _(args.first).must_be_nil # project
      raise Google::Apis::AuthorizationError.new("unauthorized", status_code: 401)
    end
    anonymous_storage.service.mocked_service = stub

    expect { anonymous_storage.create_bucket bucket_name }.must_raise Google::Cloud::UnauthenticatedError
  end

  it "raises when listing buckets without authentication" do
    stub = self
    def stub.list_buckets *args
      _(args.first).must_be_nil # project
      raise Google::Apis::AuthorizationError.new("unauthorized", status_code: 401)
    end
    anonymous_storage.service.mocked_service = stub

    expect { anonymous_storage.buckets }.must_raise Google::Cloud::UnauthenticatedError
  end

  it "finds a public bucket" do
    bucket_name = "found-bucket"

    mock = Minitest::Mock.new
    mock.expect :get_bucket, find_bucket_gapi(bucket_name), [bucket_name], **get_bucket_args

    anonymous_storage.service.mocked_service = mock

    bucket = anonymous_storage.bucket bucket_name

    mock.verify

    _(bucket.name).must_equal bucket_name
    _(bucket).wont_be :lazy?
  end

  it "lists public files" do
    num_files = 3

    mock = Minitest::Mock.new
    mock.expect :get_bucket, find_bucket_gapi(bucket_name), [bucket_name], **get_bucket_args
    mock.expect :list_objects, list_files_gapi(num_files),
      [bucket_name], delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes: nil, options: {}
    anonymous_storage.service.mocked_service = mock

    bucket = anonymous_storage.bucket bucket_name
    files = bucket.files

    mock.verify

    _(files.size).must_equal num_files
    files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end
  end

  it "finds a file" do
    file_name = "file.ext"

    mock = Minitest::Mock.new
    mock.expect :get_bucket, find_bucket_gapi(bucket_name), [bucket_name], **get_bucket_args
    mock.expect :get_object, find_file_gapi(bucket_name, file_name), [bucket_name, file_name], **get_object_args

    anonymous_storage.service.mocked_service = mock

    bucket = anonymous_storage.bucket bucket_name
    file = bucket.file file_name

    mock.verify

    _(file.name).must_equal file_name
    _(file.user_project).must_be :nil?
    _(file).wont_be :lazy?
  end

  it "downloads a public file" do
    file_name = "public-file.txt"
    Tempfile.open "google-cloud" do |tmpfile|
      # write to the file since the mocked call won't
      tmpfile.write "yay!"

      mock = Minitest::Mock.new
      mock.expect :get_bucket, find_bucket_gapi(bucket_name), [bucket_name], **get_bucket_args
      mock.expect :get_object, find_file_gapi(bucket_name, file_name), [bucket_name, file_name], **get_object_args
      mock.expect :get_object, [tmpfile, download_http_resp],
        [bucket_name, file_name], download_dest: tmpfile, generation: 1234567890, user_project: nil, options: {}

      anonymous_storage.service.mocked_service = mock

      bucket = anonymous_storage.bucket bucket_name
      file = bucket.file file_name

      # Stub the md5 to match.
      def file.md5
        "1B2M2Y8AsgTpgAmY7PhCfg=="
      end

      downloaded = file.download tmpfile
      _(downloaded).must_be_kind_of Tempfile

      mock.verify
    end
  end

  def find_bucket_gapi name = nil
    Google::Apis::StorageV1::Bucket.from_json random_bucket_hash(name: name).to_json
  end

  def find_file_gapi bucket=nil, name = nil
    Google::Apis::StorageV1::Object.from_json random_file_hash(bucket, name).to_json
  end

  def list_files_gapi count = 2, token = nil, prefixes = nil
    files = count.times.map { Google::Apis::StorageV1::Object.from_json random_file_hash.to_json }
    Google::Apis::StorageV1::Objects.new kind: "storage#objects", items: files, next_page_token: token, prefixes: prefixes
  end
end
