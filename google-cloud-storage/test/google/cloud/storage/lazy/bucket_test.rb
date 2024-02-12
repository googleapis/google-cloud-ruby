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

describe Google::Cloud::Storage::Bucket, :lazy, :mock_storage do
  let(:bucket_hash) { random_bucket_hash }
  let(:bucket) { Google::Cloud::Storage::Bucket.new_lazy bucket_name, storage.service }
  let(:bucket_user_project) { Google::Cloud::Storage::Bucket.new_lazy bucket_name, storage.service, user_project: true }

  let(:bucket_name) { "new-bucket-#{Time.now.to_i}" }
  let(:bucket_url_root) { "https://www.googleapis.com/storage/v1" }
  let(:bucket_url) { "#{bucket_url_root}/b/#{bucket_name}" }
  let(:bucket_cors) { [{ "maxAgeSeconds" => 300,
                         "method" => ["*"],
                         "origin" => ["http://example.org", "https://example.org"],
                         "responseHeader" => ["X-My-Custom-Header"] }] }
  let(:bucket_location) { "US" }
  let(:bucket_logging_bucket) { "bucket-name-logging" }
  let(:bucket_logging_prefix) { "AccessLog" }
  let(:bucket_storage_class) { "STANDARD" }
  let(:bucket_versioning) { true }
  let(:bucket_website_main) { "index.html" }
  let(:bucket_website_404) { "404.html" }
  let(:bucket_requester_pays) { true }
  let(:bucket_labels) { { "env" => "production", "foo" => "bar" } }

  let(:encryption_key) { "y\x03\"\x0E\xB6\xD3\x9B\x0E\xAB*\x19\xFAv\xDEY\xBEI\xF8ftA|[z\x1A\xFBE\xDE\x97&\xBC\xC7" }
  let(:encryption_key_sha256) { "5\x04_\xDF\x1D\x8A_d\xFEK\e6p[XZz\x13s]E\xF6\xBB\x10aQH\xF6o\x14f\xF9" }
  let(:key_options) do { header: {
      "x-goog-encryption-algorithm"  => "AES256",
      "x-goog-encryption-key"        => Base64.strict_encode64(encryption_key),
      "x-goog-encryption-key-sha256" => Base64.strict_encode64(encryption_key_sha256)
    } }
  end
  let(:metageneration) { 6 }

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_bucket, nil, [bucket.name], **delete_bucket_args

    bucket.service.mocked_service = mock

    bucket.delete

    mock.verify
  end

  it "can delete itself with if_metageneration_match set to a metageneration" do
    mock = Minitest::Mock.new
    mock.expect :delete_bucket, nil, [bucket.name], **delete_bucket_args(if_metageneration_match: metageneration)

    bucket.service.mocked_service = mock

    bucket.delete if_metageneration_match: metageneration

    mock.verify
  end

  it "can delete itself with if_metageneration_not_match set to a metageneration" do
    mock = Minitest::Mock.new
    mock.expect :delete_bucket, nil, [bucket.name], **delete_bucket_args(if_metageneration_not_match: metageneration)

    bucket.service.mocked_service = mock

    bucket.delete if_metageneration_not_match: metageneration

    mock.verify
  end

  it "can delete itself with user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :delete_bucket, nil, [bucket_user_project.name], **delete_bucket_args(user_project: "test")

    bucket_user_project.service.mocked_service = mock

    bucket_user_project.delete

    mock.verify
  end

  it "creates a file" do
    new_file_name = random_file_path

    Tempfile.open ["google-cloud", ".txt"] do |tmpfile|
      tmpfile.write "Hello world"
      tmpfile.rewind

      mock = Minitest::Mock.new
      mock.expect :insert_object, create_file_gapi(bucket.name, new_file_name),
        [bucket.name, empty_file_gapi], **insert_object_args(name: new_file_name, upload_source: tmpfile, options: {retries: 0})

      bucket.service.mocked_service = mock

      bucket.create_file tmpfile, new_file_name

      mock.verify
    end
  end

  it "creates a file with upload_file alias" do
    new_file_name = random_file_path

    Tempfile.open ["google-cloud", ".txt"] do |tmpfile|
      tmpfile.write "Hello world"
      tmpfile.rewind

      mock = Minitest::Mock.new
      mock.expect :insert_object, create_file_gapi(bucket.name, new_file_name),
        [bucket.name, empty_file_gapi], **insert_object_args(name: new_file_name, upload_source: tmpfile, options: {retries: 0})

      bucket.service.mocked_service = mock

      bucket.upload_file tmpfile, new_file_name

      mock.verify
    end
  end

  it "creates a file with new_file alias" do
    new_file_name = random_file_path

    Tempfile.open ["google-cloud", ".txt"] do |tmpfile|
      tmpfile.write "Hello world"
      tmpfile.rewind

      mock = Minitest::Mock.new
      mock.expect :insert_object, create_file_gapi(bucket.name, new_file_name),
        [bucket.name, empty_file_gapi], **insert_object_args(name: new_file_name, upload_source: tmpfile, options: {retries: 0})

      bucket.service.mocked_service = mock

      bucket.new_file tmpfile, new_file_name

      mock.verify
    end
  end

  it "creates a file with a StringIO for file contents" do
    new_file_name = random_file_path
    new_file_contents = StringIO.new "Hello world"

    mock = Minitest::Mock.new
    mock.expect :insert_object, create_file_gapi(bucket.name, new_file_name),
      [bucket.name, empty_file_gapi], **insert_object_args(name: new_file_name, upload_source: new_file_contents, options: {retries: 0})

    bucket.service.mocked_service = mock

    bucket.create_file new_file_contents, new_file_name

    mock.verify
  end

  it "raises when creating a file with a StringIO and missing path" do
    new_file_contents = StringIO.new "Hello world"

    err = expect { bucket.create_file new_file_contents }.must_raise ArgumentError
    _(err.message).must_equal "must provide path"
  end

  it "creates a file with predefined acl" do
    new_file_name = random_file_path

    Tempfile.open ["google-cloud", ".txt"] do |tmpfile|
      tmpfile.write "Hello world"
      tmpfile.rewind

      mock = Minitest::Mock.new
      mock.expect :insert_object, create_file_gapi(bucket.name, new_file_name),
        [bucket.name, empty_file_gapi], **insert_object_args(name: new_file_name, predefined_acl: "private", upload_source: tmpfile, options: {retries: 0})

      bucket.service.mocked_service = mock

      bucket.create_file tmpfile, new_file_name, acl: "private"

      mock.verify
    end
  end

  it "creates a file with predefined acl alias" do
    new_file_name = random_file_path

    Tempfile.open ["google-cloud", ".txt"] do |tmpfile|
      tmpfile.write "Hello world"
      tmpfile.rewind

      mock = Minitest::Mock.new
      mock.expect :insert_object, create_file_gapi(bucket.name, new_file_name),
        [bucket.name, empty_file_gapi], **insert_object_args(name: new_file_name, predefined_acl: "publicRead", upload_source: tmpfile, options: {retries: 0})

      bucket.service.mocked_service = mock

      bucket.create_file tmpfile, new_file_name, acl: :public

      mock.verify
    end
  end

  it "creates a file with md5" do
    new_file_name = random_file_path

    Tempfile.open ["google-cloud", ".txt"] do |tmpfile|
      tmpfile.write "Hello world"
      tmpfile.rewind

      mock = Minitest::Mock.new
      mock.expect :insert_object, create_file_gapi(bucket.name, new_file_name),
        [bucket.name, empty_file_gapi(md5: "HXB937GQDFxDFqUGi//weQ==")], **insert_object_args(name: new_file_name, upload_source: tmpfile, options: {retries: 0})

      bucket.service.mocked_service = mock

      bucket.create_file tmpfile, new_file_name, md5: "HXB937GQDFxDFqUGi//weQ=="

      mock.verify
    end
  end

  it "creates a file with crc32c" do
    new_file_name = random_file_path

    Tempfile.open ["google-cloud", ".txt"] do |tmpfile|
      tmpfile.write "Hello world"
      tmpfile.rewind

      mock = Minitest::Mock.new
      mock.expect :insert_object, create_file_gapi(bucket.name, new_file_name),
        [bucket.name, empty_file_gapi(crc32c: "Lm1F3g==")], **insert_object_args(name: new_file_name, upload_source: tmpfile, options: {retries: 0})

      bucket.service.mocked_service = mock

      bucket.create_file tmpfile, new_file_name, crc32c: "Lm1F3g=="

      mock.verify
    end
  end

  it "creates a file with attributes" do
    new_file_name = random_file_path

    Tempfile.open ["google-cloud", ".txt"] do |tmpfile|
      tmpfile.write "Hello world"
      tmpfile.rewind

      options = {
        cache_control: "public, max-age=3600",
        content_disposition: "attachment; filename=filename.ext",
        content_encoding: "gzip",
        content_language: "en",
        content_type: "image/png",
        storage_class: "NEARLINE"
      }

      mock = Minitest::Mock.new
      mock.expect :insert_object, create_file_gapi(bucket.name, new_file_name),
        [bucket.name, empty_file_gapi(**options)], **insert_object_args(name: new_file_name, upload_source: tmpfile, content_encoding: options[:content_encoding], content_type: options[:content_type], options: {retries: 0})

      bucket.service.mocked_service = mock

      bucket.create_file tmpfile, new_file_name, **options

      mock.verify
    end
  end

  it "creates a file with metadata" do
    new_file_name = random_file_path

    Tempfile.open ["google-cloud", ".txt"] do |tmpfile|
      tmpfile.write "Hello world"
      tmpfile.rewind

      metadata = {
        "player" => "Bob",
        score: 10
      }

      mock = Minitest::Mock.new
      mock.expect :insert_object, create_file_gapi(bucket.name, new_file_name),
        [bucket.name, empty_file_gapi(metadata: metadata)], **insert_object_args(name: new_file_name, upload_source: tmpfile, options: {retries: 0})

      bucket.service.mocked_service = mock

      bucket.create_file tmpfile, new_file_name, metadata: metadata

      mock.verify
    end
  end

  it "creates a file with customer-supplied encryption key" do
    new_file_name = random_file_path

    Tempfile.open ["google-cloud", ".txt"] do |tmpfile|
      tmpfile.write "Hello world"
      tmpfile.rewind

      mock = Minitest::Mock.new
      mock.expect :insert_object, create_file_gapi(bucket.name, new_file_name),
        [bucket.name, empty_file_gapi], **insert_object_args(name: new_file_name, upload_source: tmpfile, options: key_options.merge(retries: 0))

      bucket.service.mocked_service = mock

      bucket.create_file tmpfile, new_file_name, encryption_key: encryption_key

      mock.verify
    end
  end

  it "creates a file with user_project set to true" do
    new_file_name = random_file_path

    Tempfile.open ["google-cloud", ".txt"] do |tmpfile|
      tmpfile.write "Hello world"
      tmpfile.rewind

      mock = Minitest::Mock.new
      mock.expect :insert_object, create_file_gapi(bucket_user_project.name, new_file_name),
        [bucket.name, empty_file_gapi], **insert_object_args(name: new_file_name, upload_source: tmpfile, user_project: "test", options: {retries: 0})

      bucket_user_project.service.mocked_service = mock

      created = bucket_user_project.create_file tmpfile, new_file_name
      _(created.user_project).must_equal true

      mock.verify
    end
  end

  it "creates an empty file" do
    new_file_name = random_file_path

    Tempfile.create ["google-cloud", ".txt"] do |tmpfile|
      mock = Minitest::Mock.new
      mock.expect :insert_object, create_file_gapi(bucket_user_project.name, new_file_name),
        [bucket.name, empty_file_gapi], **insert_object_args(name: new_file_name, upload_source: tmpfile, user_project: "test", options: {retries: 0})

      bucket_user_project.service.mocked_service = mock

      created = bucket_user_project.create_file tmpfile, new_file_name
      _(created.user_project).must_equal true

      mock.verify
    end
  end

  it "raises when given a file that does not exist" do
    bad_file_path = "/this/file/does/not/exist.ext"

    refute ::File.file?(bad_file_path)

    err = expect {
      bucket.create_file bad_file_path
    }.must_raise ArgumentError
    _(err.message).must_match bad_file_path
  end

  it "lists files" do
    num_files = 3

    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(num_files),
      [bucket.name], delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}

    bucket.service.mocked_service = mock

    files = bucket.files

    mock.verify

    _(files.size).must_equal num_files
    files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end
  end

  it "lists files with find_files alias" do
    num_files = 3

    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(num_files),
      [bucket.name], delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}
    bucket.service.mocked_service = mock

    files = bucket.find_files

    mock.verify

    _(files.size).must_equal num_files
    files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end
  end

  it "lists files with prefix set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, nil, ["/prefix/path1/", "/prefix/path2/"]),
      [bucket.name], delimiter: nil, max_results: nil, page_token: nil, prefix: "/prefix/", versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}

    bucket.service.mocked_service = mock

    files = bucket.files prefix: "/prefix/"

    mock.verify

    _(files.count).must_equal 3
    _(files.prefixes).wont_be :empty?
    _(files.prefixes).must_include "/prefix/path1/"
    _(files.prefixes).must_include "/prefix/path2/"
    files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end
  end

  it "lists files with delimiter set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, nil, ["/prefix/path1/", "/prefix/path2/"]),
      [bucket.name], delimiter: "/", max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}
    bucket.service.mocked_service = mock

    files = bucket.files delimiter: "/"

    mock.verify

    _(files.count).must_equal 3
    _(files.prefixes).wont_be :empty?
    _(files.prefixes).must_include "/prefix/path1/"
    _(files.prefixes).must_include "/prefix/path2/"
    files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end
  end

  it "lists files with match_glob set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name], delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil, match_glob: "/foo/**/bar/", include_folders_as_prefixes:nil, options: {}

    bucket.service.mocked_service = mock

    files = bucket.files match_glob: "/foo/**/bar/"

    mock.verify

    _(files.count).must_equal 2
    files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end

  end

  it "lists files with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name], delimiter: nil, max_results: 3, page_token: nil, prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}

    bucket.service.mocked_service = mock

    files = bucket.files max: 3

    mock.verify

    _(files.count).must_equal 3
    _(files.token).wont_be :nil?
    _(files.token).must_equal "next_page_token"
    files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end
  end

  it "lists files with versions set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3),
      [bucket.name], delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: true, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}

    bucket.service.mocked_service = mock

    files = bucket.files versions: true

    mock.verify

    _(files.count).must_equal 3
    files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end
  end

  it "lists files with user_project set to true" do
    num_files = 3

    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(num_files),
      [bucket.name], delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: "test", match_glob: nil, include_folders_as_prefixes:nil, options: {}

    bucket_user_project.service.mocked_service = mock

    files = bucket_user_project.files

    mock.verify

    _(files.size).must_equal num_files
    files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_equal true
    end
  end

  it "paginates files" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name], delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name], delimiter: nil, max_results: nil, page_token: "next_page_token", prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}

    bucket.service.mocked_service = mock

    first_files = bucket.files
    second_files = bucket.files token: first_files.token

    mock.verify

    _(first_files.count).must_equal 3
    _(first_files.token).wont_be :nil?
    _(first_files.token).must_equal "next_page_token"
    first_files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end

    _(second_files.count).must_equal 2
    _(second_files.token).must_be :nil?
    second_files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end
  end

  it "paginates files with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name], delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name], delimiter: nil, max_results: nil, page_token: "next_page_token", prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}
    bucket.service.mocked_service = mock

    first_files = bucket.files
    second_files = first_files.next

    mock.verify

    _(first_files.count).must_equal 3
    _(first_files.next?).must_equal true
    first_files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end

    _(second_files.count).must_equal 2
    _(second_files.next?).must_equal false
    second_files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end
  end

  it "paginates files with next? and next and prefix set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name], delimiter: nil, max_results: nil, page_token: nil, prefix: "/prefix/", versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name], delimiter: nil, max_results: nil, page_token: "next_page_token", prefix: "/prefix/", versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}

    bucket.service.mocked_service = mock

    first_files = bucket.files prefix: "/prefix/"
    second_files = first_files.next

    mock.verify

    _(first_files.count).must_equal 3
    _(first_files.next?).must_equal true
    first_files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end

    _(second_files.count).must_equal 2
    _(second_files.next?).must_equal false
    second_files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end
  end

  it "paginates files with next? and next and delimiter set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name], delimiter: "/", max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name], delimiter: "/", max_results: nil, page_token: "next_page_token", prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}

    bucket.service.mocked_service = mock

    first_files = bucket.files delimiter: "/"
    second_files = first_files.next

    mock.verify

    _(first_files.count).must_equal 3
    _(first_files.next?).must_equal true
    first_files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end

    _(second_files.count).must_equal 2
    _(second_files.next?).must_equal false
    second_files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end
  end

  it "paginates files with next? and next and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name], delimiter: nil, max_results: 3, page_token: nil, prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name], delimiter: nil, max_results: 3, page_token: "next_page_token", prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}
    bucket.service.mocked_service = mock

    first_files = bucket.files max: 3
    second_files = first_files.next

    mock.verify

    _(first_files.count).must_equal 3
    _(first_files.next?).must_equal true
    first_files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end

    _(second_files.count).must_equal 2
    _(second_files.next?).must_equal false
    second_files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end
  end

  it "paginates files with next? and next and versions set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name], delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: true, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name], delimiter: nil, max_results: nil, page_token: "next_page_token", prefix: nil, versions: true, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}

    bucket.service.mocked_service = mock

    first_files = bucket.files versions: true
    second_files = first_files.next

    mock.verify

    _(first_files.count).must_equal 3
    _(first_files.next?).must_equal true
    first_files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end

    _(second_files.count).must_equal 2
    _(second_files.next?).must_equal false
    second_files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end
  end

  it "paginates files with user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name], delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: "test", match_glob: nil, include_folders_as_prefixes:nil, options: {}
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name], delimiter: nil, max_results: nil, page_token: "next_page_token", prefix: nil, versions: nil, user_project: "test", match_glob: nil, include_folders_as_prefixes:nil, options: {}

    bucket_user_project.service.mocked_service = mock

    first_files = bucket_user_project.files
    second_files = bucket_user_project.files token: first_files.token

    mock.verify

    _(first_files.count).must_equal 3
    _(first_files.token).wont_be :nil?
    _(first_files.token).must_equal "next_page_token"
    first_files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_equal true
    end

    _(second_files.count).must_equal 2
    _(second_files.token).must_be :nil?
    first_files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_equal true
    end
  end

  it "paginates files with all" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name], delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name], delimiter: nil, max_results: nil, page_token: "next_page_token", prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}
    bucket.service.mocked_service = mock

    files = bucket.files.all.to_a

    mock.verify

    _(files.count).must_equal 5
    files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end
  end

  it "paginates files with all and prefix set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name], delimiter: nil, max_results: nil, page_token: nil, prefix: "/prefix/", versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name], delimiter: nil, max_results: nil, page_token: "next_page_token", prefix: "/prefix/", versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}

    bucket.service.mocked_service = mock

    files = bucket.files(prefix: "/prefix/").all.to_a

    mock.verify

    _(files.count).must_equal 5
    files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end
  end

  it "paginates files with all and delimiter set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name], delimiter: "/", max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name], delimiter: "/", max_results: nil, page_token: "next_page_token", prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}

    bucket.service.mocked_service = mock

    files = bucket.files(delimiter: "/").all.to_a

    mock.verify

    _(files.count).must_equal 5
    files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end
  end

  it "paginates files with all and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name], delimiter: nil, max_results: 3, page_token: nil, prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name], delimiter: nil, max_results: 3, page_token: "next_page_token", prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}

    bucket.service.mocked_service = mock

    files = bucket.files(max: 3).all.to_a

    mock.verify

    _(files.count).must_equal 5
    files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end
  end

  it "paginates files with all and versions set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name], delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: true, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name], delimiter: nil, max_results: nil, page_token: "next_page_token", prefix: nil, versions: true, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}

    bucket.service.mocked_service = mock

    files = bucket.files(versions: true).all.to_a

    mock.verify

    _(files.count).must_equal 5
    files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end
  end

  it "paginates files with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name], delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}
    mock.expect :list_objects, list_files_gapi(3, "second_page_token"),
      [bucket.name], delimiter: nil, max_results: nil, page_token: "next_page_token", prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}

    bucket.service.mocked_service = mock

    files = bucket.files.all.take(5)

    mock.verify

    _(files.count).must_equal 5
    files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end
  end

  it "paginates files with all and request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name], delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}
    mock.expect :list_objects, list_files_gapi(3, "second_page_token"),
      [bucket.name], delimiter: nil, max_results: nil, page_token: "next_page_token", prefix: nil, versions: nil, user_project: nil, match_glob: nil, include_folders_as_prefixes:nil, options: {}

    bucket.service.mocked_service = mock

    files = bucket.files.all(request_limit: 1).to_a

    mock.verify

    _(files.count).must_equal 6
    files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_be :nil?
    end
  end

  it "paginates files with all and user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket_user_project.name], delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: "test", match_glob: nil, include_folders_as_prefixes:nil, options: {}
    mock.expect :list_objects, list_files_gapi(3, "second_page_token"),
      [bucket_user_project.name], delimiter: nil, max_results: nil, page_token: "next_page_token", prefix: nil, versions: nil, user_project: "test", match_glob: nil, include_folders_as_prefixes:nil, options: {}

    bucket_user_project.service.mocked_service = mock

    files = bucket_user_project.files.all(request_limit: 1).to_a

    mock.verify

    _(files.count).must_equal 6
    files.each do |file|
      _(file).must_be_kind_of Google::Cloud::Storage::File
      _(file.user_project).must_equal true
    end
  end

  it "finds a file" do
    file_name = "file.ext"

    mock = Minitest::Mock.new
    mock.expect :get_object, find_file_gapi(bucket.name, file_name), [bucket.name, file_name], **get_object_args

    bucket.service.mocked_service = mock

    file = bucket.file file_name

    mock.verify

    _(file.name).must_equal file_name
    _(file.user_project).must_be :nil?
    _(file).wont_be :lazy?
  end

  it "finds a file with find_file alias" do
    file_name = "file.ext"

    mock = Minitest::Mock.new
    mock.expect :get_object, find_file_gapi(bucket.name, file_name), [bucket.name, file_name], **get_object_args

    bucket.service.mocked_service = mock

    file = bucket.find_file file_name

    mock.verify

    _(file.name).must_equal file_name
    _(file.user_project).must_be :nil?
    _(file).wont_be :lazy?
  end

  it "finds a file with generation" do
    file_name = "file.ext"
    generation = 123

    mock = Minitest::Mock.new
    mock.expect :get_object, find_file_gapi(bucket.name, file_name),
    [bucket.name, file_name], **get_object_args(generation: generation)

    bucket.service.mocked_service = mock

    file = bucket.file file_name, generation: generation

    mock.verify

    _(file.name).must_equal file_name
    _(file.user_project).must_be :nil?
    _(file).wont_be :lazy?
  end

  it "finds a file with customer-supplied encryption key" do
    file_name = "file.ext"

    mock = Minitest::Mock.new
    mock.expect :get_object, find_file_gapi(bucket.name, file_name),
      [bucket.name, file_name], **get_object_args(options: key_options)

    bucket.service.mocked_service = mock

    file = bucket.file file_name, encryption_key: encryption_key

    mock.verify

    _(file.name).must_equal file_name
    _(file.user_project).must_be :nil?
    _(file).wont_be :lazy?
  end

  it "finds a file with user_project set to true" do
    file_name = "file.ext"

    mock = Minitest::Mock.new
    mock.expect :get_object, find_file_gapi(bucket_user_project.name, file_name),
      [bucket_user_project.name, file_name], **get_object_args(generation: nil, user_project: "test")

    bucket_user_project.service.mocked_service = mock

    file = bucket_user_project.file file_name

    mock.verify

    _(file.name).must_equal file_name
    _(file.user_project).must_equal true
    _(file).wont_be :lazy?
  end

  it "finds a file with skip_lookup" do
    file_name = "file.ext"

    mock = Minitest::Mock.new

    bucket.service.mocked_service = mock

    file = bucket.file file_name, skip_lookup: true

    mock.verify

    _(file.name).must_equal file_name
    _(file.generation).must_be :nil?
    _(file.user_project).must_be :nil?
    _(file).must_be :lazy?
  end

  it "finds a file with skip_lookup and find_file alias" do
    file_name = "file.ext"

    mock = Minitest::Mock.new

    bucket.service.mocked_service = mock

    file = bucket.find_file file_name, skip_lookup: true

    mock.verify

    _(file.name).must_equal file_name
    _(file.generation).must_be :nil?
    _(file.user_project).must_be :nil?
    _(file).must_be :lazy?
  end

  it "finds a file with generation and skip_lookup" do
    file_name = "file.ext"
    generation = 123

    mock = Minitest::Mock.new

    bucket.service.mocked_service = mock

    file = bucket.file file_name, generation: generation, skip_lookup: true

    mock.verify

    _(file.name).must_equal file_name
    _(file.generation).must_equal generation
    _(file.user_project).must_be :nil?
    _(file).must_be :lazy?
  end

  it "finds a file with user_project and skip_lookupset to true" do
    file_name = "file.ext"

    mock = Minitest::Mock.new

    bucket_user_project.service.mocked_service = mock

    file = bucket_user_project.file file_name, skip_lookup: true

    mock.verify

    _(file.name).must_equal file_name
    _(file.generation).must_be :nil?
    _(file.user_project).must_equal true
    _(file).must_be :lazy?
  end

  it "can reload itself" do
    bucket_name = "found-bucket"
    new_url_root = "https://www.googleapis.com/storage/v2"

    mock = Minitest::Mock.new
    mock.expect :get_bucket, Google::Apis::StorageV1::Bucket.from_json(random_bucket_hash(name: bucket_name).to_json),
      [bucket_name], **get_bucket_args
    mock.expect :get_bucket, Google::Apis::StorageV1::Bucket.from_json(random_bucket_hash(name: bucket_name, url_root: new_url_root).to_json),
      [bucket_name], **get_bucket_args

    bucket.service.mocked_service = mock

    bucket = storage.bucket bucket_name
    _(bucket.api_url).must_equal "https://www.googleapis.com/storage/v1/b/#{bucket_name}"

    bucket.reload!

    _(bucket.api_url).must_equal "#{new_url_root}/b/#{bucket_name}"
    mock.verify
  end

  it "can reload itself with user_project set to true" do
    bucket_name = "found-bucket"
    new_url_root = "https://www.googleapis.com/storage/v2"

    mock = Minitest::Mock.new
    mock.expect :get_bucket, Google::Apis::StorageV1::Bucket.from_json(random_bucket_hash(name: bucket_name).to_json),
      [bucket_name], **get_bucket_args(user_project: "test")
    mock.expect :get_bucket, Google::Apis::StorageV1::Bucket.from_json(random_bucket_hash(name: bucket_name, url_root: new_url_root).to_json),
      [bucket_name], **get_bucket_args(user_project: "test")

    bucket_user_project.service.mocked_service = mock

    bucket = storage.bucket bucket_name, user_project: true
    _(bucket.api_url).must_equal "https://www.googleapis.com/storage/v1/b/#{bucket_name}"

    bucket.reload!

    _(bucket.api_url).must_equal "#{new_url_root}/b/#{bucket_name}"
    mock.verify
  end

  def create_file_gapi bucket=nil, name = nil
    Google::Apis::StorageV1::Object.from_json random_file_hash(bucket, name).to_json
  end

  def empty_file_gapi cache_control: nil, content_disposition: nil,
                      content_encoding: nil, content_language: nil,
                      content_type: nil, crc32c: nil, md5: nil, metadata: nil,
                      storage_class: nil
    params = {
      cache_control: cache_control, content_type: content_type,
      content_disposition: content_disposition, md5_hash: md5,
      content_encoding: content_encoding, crc32c: crc32c,
      content_language: content_language, metadata: metadata,
      storage_class: storage_class }.delete_if { |_k, v| v.nil? }
    Google::Apis::StorageV1::Object.new(**params)
  end

  def find_file_gapi bucket=nil, name = nil
    Google::Apis::StorageV1::Object.from_json random_file_hash(bucket, name).to_json
  end

  def list_files_gapi count = 2, token = nil, prefixes = nil
    files = count.times.map { Google::Apis::StorageV1::Object.from_json random_file_hash.to_json }
    Google::Apis::StorageV1::Objects.new kind: "storage#objects", items: files, next_page_token: token, prefixes: prefixes
  end
end
