# Copyright 2014 Google LLC
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

describe Google::Cloud::Storage::Bucket, :mock_storage do
  let(:bucket_hash) { random_bucket_hash }
  let(:bucket_json) { bucket_hash.to_json }
  let(:bucket_gapi) { Google::Apis::StorageV1::Bucket.from_json bucket_json }
  let(:bucket) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service }
  let(:bucket_user_project) { Google::Cloud::Storage::Bucket.from_gapi bucket_gapi, storage.service, user_project: true }

  let(:bucket_name) { "new-bucket-#{Time.now.to_i}" }
  let(:bucket_url_root) { "https://www.googleapis.com/storage/v1" }
  let(:bucket_url) { "#{bucket_url_root}/b/#{bucket_name}" }
  let(:bucket_cors) { [{ "maxAgeSeconds" => 300,
                         "method" => ["*"],
                         "origin" => ["http://example.org", "https://example.org"],
                         "responseHeader" => ["X-My-Custom-Header"] }] }
  let(:bucket_lifecycle) { {"rule" => [{"action" => {"storageClass" => "NEARLINE","type" => "SetStorageClass"},"condition" => {"age" => 32}}]} }
  let(:bucket_location) { "US" }
  let(:bucket_logging_bucket) { "bucket-name-logging" }
  let(:bucket_logging_prefix) { "AccessLog" }
  let(:bucket_storage_class) { "STANDARD" }
  let(:bucket_versioning) { true }
  let(:bucket_website_main) { "index.html" }
  let(:bucket_website_404) { "404.html" }
  let(:bucket_requester_pays) { true }
  let(:bucket_labels) { { "env" => "production", "foo" => "bar" } }
  let :bucket_complete_hash do
    h = random_bucket_hash bucket_name, bucket_url_root,
                           bucket_location, bucket_storage_class, bucket_versioning,
                           bucket_logging_bucket, bucket_logging_prefix, bucket_website_main,
                           bucket_website_404, bucket_cors, bucket_requester_pays, bucket_lifecycle
    h[:labels] = bucket_labels
    h
  end
  let(:bucket_complete_json) { bucket_complete_hash.to_json }
  let(:bucket_complete_gapi) { Google::Apis::StorageV1::Bucket.from_json bucket_complete_json }
  let(:bucket_complete) { Google::Cloud::Storage::Bucket.from_gapi bucket_complete_gapi, storage.service }

  it "knows its attributes" do
    bucket_complete.id.must_equal bucket_complete_hash["id"]
    bucket_complete.name.must_equal bucket_name
    bucket_complete.created_at.must_be_within_delta bucket_complete_hash["timeCreated"].to_datetime
    bucket_complete.api_url.must_equal bucket_url
    bucket_complete.location.must_equal bucket_location
    bucket_complete.logging_bucket.must_equal bucket_logging_bucket
    bucket_complete.logging_prefix.must_equal bucket_logging_prefix
    bucket_complete.storage_class.must_equal bucket_storage_class
    bucket_complete.versioning?.must_equal bucket_versioning
    bucket_complete.website_main.must_equal bucket_website_main
    bucket_complete.website_404.must_equal bucket_website_404
    bucket_complete.requester_pays.must_equal bucket_requester_pays
  end

  it "knows its labels" do
    # mostly emtpy bucket has a labels hash
    bucket.labels.must_equal Hash.new
    # a complete bucket has a labels hash with the correct values
    bucket_complete.labels.must_equal bucket_labels
  end

  it "returns frozen cors" do
    bucket_complete.cors.each do |cors|
      cors.must_be_kind_of Google::Cloud::Storage::Bucket::Cors::Rule
      cors.frozen?.must_equal true
    end
    bucket_complete.cors.frozen?.must_equal true
  end

  it "returns frozen lifecycle (Object Lifecycle Management)" do
    bucket_complete.lifecycle.each do |r|
      r.must_be_kind_of Google::Cloud::Storage::Bucket::Lifecycle::Rule
      r.frozen?.must_equal true
    end
    bucket_complete.lifecycle.frozen?.must_equal true
  end

  it "can delete itself" do
    mock = Minitest::Mock.new
    mock.expect :delete_bucket, nil, [bucket.name, user_project: nil]

    bucket.service.mocked_service = mock

    bucket.delete

    mock.verify
  end

  it "can delete itself with user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :delete_bucket, nil, [bucket_user_project.name, user_project: "test"]

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
        [bucket.name, empty_file_gapi, name: new_file_name, predefined_acl: nil, upload_source: tmpfile, content_encoding: nil, content_type: "text/plain", kms_key_name: nil, user_project: nil, options: {}]

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
        [bucket.name, empty_file_gapi, name: new_file_name, predefined_acl: nil, upload_source: tmpfile, content_encoding: nil, content_type: "text/plain", kms_key_name: nil, user_project: nil, options: {}]

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
        [bucket.name, empty_file_gapi, name: new_file_name, predefined_acl: nil, upload_source: tmpfile, content_encoding: nil, content_type: "text/plain", kms_key_name: nil, user_project: nil, options: {}]

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
      [bucket.name, empty_file_gapi, name: new_file_name, predefined_acl: nil, upload_source: new_file_contents, content_encoding: nil, content_type: "text/plain", kms_key_name: nil, user_project: nil, options: {}]

    bucket.service.mocked_service = mock

    bucket.create_file new_file_contents, new_file_name

    mock.verify
  end

  it "raises when creating a file with a StringIO and missing path" do
    new_file_contents = StringIO.new "Hello world"

    err = expect { bucket.create_file new_file_contents }.must_raise ArgumentError
    err.message.must_equal "must provide path"
  end

  it "creates a file with predefined acl" do
    new_file_name = random_file_path

    Tempfile.open ["google-cloud", ".txt"] do |tmpfile|
      tmpfile.write "Hello world"
      tmpfile.rewind

      mock = Minitest::Mock.new
      mock.expect :insert_object, create_file_gapi(bucket.name, new_file_name),
        [bucket.name, empty_file_gapi, name: new_file_name, predefined_acl: "private", upload_source: tmpfile, content_encoding: nil, content_type: "text/plain", kms_key_name: nil, user_project: nil, options: {}]

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
        [bucket.name, empty_file_gapi, name: new_file_name, predefined_acl: "publicRead", upload_source: tmpfile, content_encoding: nil, content_type: "text/plain", kms_key_name: nil, user_project: nil, options: {}]

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
        [bucket.name, empty_file_gapi(md5: "HXB937GQDFxDFqUGi//weQ=="), name: new_file_name, predefined_acl: nil, upload_source: tmpfile, content_encoding: nil, content_type: "text/plain", kms_key_name: nil, user_project: nil, options: {}]

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
        [bucket.name, empty_file_gapi(crc32c: "Lm1F3g=="), name: new_file_name, predefined_acl: nil, upload_source: tmpfile, content_encoding: nil, content_type: "text/plain", kms_key_name: nil, user_project: nil, options: {}]

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
        [bucket.name, empty_file_gapi(options), name: new_file_name, predefined_acl: nil, upload_source: tmpfile, content_encoding: options[:content_encoding], content_type: options[:content_type], kms_key_name: nil, user_project: nil, options: {}]

      bucket.service.mocked_service = mock

      bucket.create_file tmpfile, new_file_name, options

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
        [bucket.name, empty_file_gapi(metadata: metadata), name: new_file_name, predefined_acl: nil, upload_source: tmpfile, content_encoding: nil, content_type: "text/plain", kms_key_name: nil, user_project: nil, options: {}]

      bucket.service.mocked_service = mock

      bucket.create_file tmpfile, new_file_name, metadata: metadata

      mock.verify
    end
  end

  it "creates a file with temporary_hold" do
    new_file_name = random_file_path

    Tempfile.open ["google-cloud", ".txt"] do |tmpfile|
      tmpfile.write "Hello world"
      tmpfile.rewind

      mock = Minitest::Mock.new
      mock.expect :insert_object, create_file_gapi(bucket.name, new_file_name),
                  [bucket.name, empty_file_gapi(temporary_hold: true), name: new_file_name, predefined_acl: nil, upload_source: tmpfile, content_encoding: nil, content_type: "text/plain", kms_key_name: nil, user_project: nil, options: {}]

      bucket.service.mocked_service = mock

      bucket.create_file tmpfile, new_file_name, temporary_hold: true

      mock.verify
    end
  end

  it "creates a file with event_based_hold" do
    new_file_name = random_file_path

    Tempfile.open ["google-cloud", ".txt"] do |tmpfile|
      tmpfile.write "Hello world"
      tmpfile.rewind

      mock = Minitest::Mock.new
      mock.expect :insert_object, create_file_gapi(bucket.name, new_file_name),
                  [bucket.name, empty_file_gapi(event_based_hold: true), name: new_file_name, predefined_acl: nil, upload_source: tmpfile, content_encoding: nil, content_type: "text/plain", kms_key_name: nil, user_project: nil, options: {}]

      bucket.service.mocked_service = mock

      bucket.create_file tmpfile, new_file_name, event_based_hold: true

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
        [bucket_user_project.name, empty_file_gapi, name: new_file_name, predefined_acl: nil, upload_source: tmpfile, content_encoding: nil, content_type: "text/plain", kms_key_name: nil, user_project: "test", options: {}]

      bucket_user_project.service.mocked_service = mock

      created = bucket_user_project.create_file tmpfile, new_file_name
      created.user_project.must_equal true

      mock.verify
    end
  end

  it "raises when given a file that does not exist" do
    bad_file_path = "/this/file/does/not/exist.ext"

    refute ::File.file?(bad_file_path)

    err = expect {
      bucket.create_file bad_file_path
    }.must_raise ArgumentError
    err.message.must_match bad_file_path
  end

  it "lists files" do
    num_files = 3

    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(num_files),
      [bucket.name, delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil]

    bucket.service.mocked_service = mock

    files = bucket.files

    mock.verify

    files.size.must_equal num_files
    files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end
  end

  it "lists files with find_files alias" do
    num_files = 3

    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(num_files),
      [bucket.name, delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil]

    bucket.service.mocked_service = mock

    files = bucket.find_files

    mock.verify

    files.size.must_equal num_files
    files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end
  end

  it "lists files with prefix set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, nil, ["/prefix/path1/", "/prefix/path2/"]),
      [bucket.name, delimiter: nil, max_results: nil, page_token: nil, prefix: "/prefix/", versions: nil, user_project: nil]

    bucket.service.mocked_service = mock

    files = bucket.files prefix: "/prefix/"

    mock.verify

    files.count.must_equal 3
    files.prefixes.wont_be :empty?
    files.prefixes.must_include "/prefix/path1/"
    files.prefixes.must_include "/prefix/path2/"
    files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end
  end

  it "lists files with delimiter set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, nil, ["/prefix/path1/", "/prefix/path2/"]),
      [bucket.name, delimiter: "/", max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil]

    bucket.service.mocked_service = mock

    files = bucket.files delimiter: "/"

    mock.verify

    files.count.must_equal 3
    files.prefixes.wont_be :empty?
    files.prefixes.must_include "/prefix/path1/"
    files.prefixes.must_include "/prefix/path2/"
    files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end
  end

  it "lists files with max set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name, delimiter: nil, max_results: 3, page_token: nil, prefix: nil, versions: nil, user_project: nil]

    bucket.service.mocked_service = mock

    files = bucket.files max: 3

    mock.verify

    files.count.must_equal 3
    files.token.wont_be :nil?
    files.token.must_equal "next_page_token"
    files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end
  end

  it "lists files with versions set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3),
      [bucket.name, delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: true, user_project: nil]

    bucket.service.mocked_service = mock

    files = bucket.files versions: true

    mock.verify

    files.count.must_equal 3
    files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end
  end

  it "lists files with user_project set to true" do
    num_files = 3

    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(num_files),
      [bucket.name, delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: "test"]

    bucket_user_project.service.mocked_service = mock

    files = bucket_user_project.files

    mock.verify

    files.size.must_equal num_files
    files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_equal true
    end
  end

  it "paginates files" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name, delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil]
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name, delimiter: nil, max_results: nil, page_token: "next_page_token", prefix: nil, versions: nil, user_project: nil]

    bucket.service.mocked_service = mock

    first_files = bucket.files
    second_files = bucket.files token: first_files.token

    mock.verify

    first_files.count.must_equal 3
    first_files.token.wont_be :nil?
    first_files.token.must_equal "next_page_token"
    first_files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end

    second_files.count.must_equal 2
    second_files.token.must_be :nil?
    second_files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end
  end

  it "paginates files with next? and next" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name, delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil]
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name, delimiter: nil, max_results: nil, page_token: "next_page_token", prefix: nil, versions: nil, user_project: nil]

    bucket.service.mocked_service = mock

    first_files = bucket.files
    second_files = first_files.next

    mock.verify

    first_files.count.must_equal 3
    first_files.next?.must_equal true
    first_files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end

    second_files.count.must_equal 2
    second_files.next?.must_equal false
    second_files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end
  end

  it "paginates files with next? and next and prefix set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name, delimiter: nil, max_results: nil, page_token: nil, prefix: "/prefix/", versions: nil, user_project: nil]
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name, delimiter: nil, max_results: nil, page_token: "next_page_token", prefix: "/prefix/", versions: nil, user_project: nil]

    bucket.service.mocked_service = mock

    first_files = bucket.files prefix: "/prefix/"
    second_files = first_files.next

    mock.verify

    first_files.count.must_equal 3
    first_files.next?.must_equal true
    first_files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end

    second_files.count.must_equal 2
    second_files.next?.must_equal false
    second_files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end
  end

  it "paginates files with next? and next and delimiter set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name, delimiter: "/", max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil]
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name, delimiter: "/", max_results: nil, page_token: "next_page_token", prefix: nil, versions: nil, user_project: nil]

    bucket.service.mocked_service = mock

    first_files = bucket.files delimiter: "/"
    second_files = first_files.next

    mock.verify

    first_files.count.must_equal 3
    first_files.next?.must_equal true
    first_files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end

    second_files.count.must_equal 2
    second_files.next?.must_equal false
    second_files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end
  end

  it "paginates files with next? and next and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name, delimiter: nil, max_results: 3, page_token: nil, prefix: nil, versions: nil, user_project: nil]
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name, delimiter: nil, max_results: 3, page_token: "next_page_token", prefix: nil, versions: nil, user_project: nil]

    bucket.service.mocked_service = mock

    first_files = bucket.files max: 3
    second_files = first_files.next

    mock.verify

    first_files.count.must_equal 3
    first_files.next?.must_equal true
    first_files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end

    second_files.count.must_equal 2
    second_files.next?.must_equal false
    second_files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end
  end

  it "paginates files with next? and next and versions set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name, delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: true, user_project: nil]
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name, delimiter: nil, max_results: nil, page_token: "next_page_token", prefix: nil, versions: true, user_project: nil]

    bucket.service.mocked_service = mock

    first_files = bucket.files versions: true
    second_files = first_files.next

    mock.verify

    first_files.count.must_equal 3
    first_files.next?.must_equal true
    first_files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end

    second_files.count.must_equal 2
    second_files.next?.must_equal false
    second_files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end
  end

  it "paginates files with user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name, delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: "test"]
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name, delimiter: nil, max_results: nil, page_token: "next_page_token", prefix: nil, versions: nil, user_project: "test"]

    bucket_user_project.service.mocked_service = mock

    first_files = bucket_user_project.files
    second_files = bucket_user_project.files token: first_files.token

    mock.verify

    first_files.count.must_equal 3
    first_files.token.wont_be :nil?
    first_files.token.must_equal "next_page_token"
    first_files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_equal true
    end

    second_files.count.must_equal 2
    second_files.token.must_be :nil?
    first_files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_equal true
    end
  end

  it "paginates files with all" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name, delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil]
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name, delimiter: nil, max_results: nil, page_token: "next_page_token", prefix: nil, versions: nil, user_project: nil]

    bucket.service.mocked_service = mock

    files = bucket.files.all.to_a

    mock.verify

    files.count.must_equal 5
    files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end
  end

  it "paginates files with all and prefix set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name, delimiter: nil, max_results: nil, page_token: nil, prefix: "/prefix/", versions: nil, user_project: nil]
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name, delimiter: nil, max_results: nil, page_token: "next_page_token", prefix: "/prefix/", versions: nil, user_project: nil]

    bucket.service.mocked_service = mock

    files = bucket.files(prefix: "/prefix/").all.to_a

    mock.verify

    files.count.must_equal 5
    files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end
  end

  it "paginates files with all and delimiter set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name, delimiter: "/", max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil]
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name, delimiter: "/", max_results: nil, page_token: "next_page_token", prefix: nil, versions: nil, user_project: nil]

    bucket.service.mocked_service = mock

    files = bucket.files(delimiter: "/").all.to_a

    mock.verify

    files.count.must_equal 5
    files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end
  end

  it "paginates files with all and max set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name, delimiter: nil, max_results: 3, page_token: nil, prefix: nil, versions: nil, user_project: nil]
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name, delimiter: nil, max_results: 3, page_token: "next_page_token", prefix: nil, versions: nil, user_project: nil]

    bucket.service.mocked_service = mock

    files = bucket.files(max: 3).all.to_a

    mock.verify

    files.count.must_equal 5
    files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end
  end

  it "paginates files with all and versions set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name, delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: true, user_project: nil]
    mock.expect :list_objects, list_files_gapi(2),
      [bucket.name, delimiter: nil, max_results: nil, page_token: "next_page_token", prefix: nil, versions: true, user_project: nil]

    bucket.service.mocked_service = mock

    files = bucket.files(versions: true).all.to_a

    mock.verify

    files.count.must_equal 5
    files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end
  end

  it "paginates files with all using Enumerator" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name, delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil]
    mock.expect :list_objects, list_files_gapi(3, "second_page_token"),
      [bucket.name, delimiter: nil, max_results: nil, page_token: "next_page_token", prefix: nil, versions: nil, user_project: nil]

    bucket.service.mocked_service = mock

    files = bucket.files.all.take(5)

    mock.verify

    files.count.must_equal 5
    files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end
  end

  it "paginates files with all and request_limit set" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket.name, delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: nil]
    mock.expect :list_objects, list_files_gapi(3, "second_page_token"),
      [bucket.name, delimiter: nil, max_results: nil, page_token: "next_page_token", prefix: nil, versions: nil, user_project: nil]

    bucket.service.mocked_service = mock

    files = bucket.files.all(request_limit: 1).to_a

    mock.verify

    files.count.must_equal 6
    files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_be :nil?
    end
  end

  it "paginates files with all and user_project set to true" do
    mock = Minitest::Mock.new
    mock.expect :list_objects, list_files_gapi(3, "next_page_token"),
      [bucket_user_project.name, delimiter: nil, max_results: nil, page_token: nil, prefix: nil, versions: nil, user_project: "test"]
    mock.expect :list_objects, list_files_gapi(3, "second_page_token"),
      [bucket_user_project.name, delimiter: nil, max_results: nil, page_token: "next_page_token", prefix: nil, versions: nil, user_project: "test"]

    bucket_user_project.service.mocked_service = mock

    files = bucket_user_project.files.all(request_limit: 1).to_a

    mock.verify

    files.count.must_equal 6
    files.each do |file|
      file.must_be_kind_of Google::Cloud::Storage::File
      file.user_project.must_equal true
    end
  end

  it "finds a file" do
    file_name = "file.ext"

    mock = Minitest::Mock.new
    mock.expect :get_object, find_file_gapi(bucket.name, file_name),
      [bucket.name, file_name, generation: nil, user_project: nil, options: {}]

    bucket.service.mocked_service = mock

    file = bucket.file file_name

    mock.verify

    file.name.must_equal file_name
    file.user_project.must_be :nil?
    file.wont_be :lazy?
  end

  it "finds a file with find_file alias" do
    file_name = "file.ext"

    mock = Minitest::Mock.new
    mock.expect :get_object, find_file_gapi(bucket.name, file_name),
      [bucket.name, file_name, generation: nil, user_project: nil, options: {}]

    bucket.service.mocked_service = mock

    file = bucket.find_file file_name

    mock.verify

    file.name.must_equal file_name
    file.user_project.must_be :nil?
    file.wont_be :lazy?
  end

  it "finds a file with generation" do
    file_name = "file.ext"
    generation = 123

    mock = Minitest::Mock.new
    mock.expect :get_object, find_file_gapi(bucket.name, file_name),
      [bucket.name, file_name, generation: generation, user_project: nil, options: {}]

    bucket.service.mocked_service = mock

    file = bucket.file file_name, generation: generation

    mock.verify

    file.name.must_equal file_name
    file.user_project.must_be :nil?
    file.wont_be :lazy?
  end

  it "finds a file with user_project set to true" do
    file_name = "file.ext"

    mock = Minitest::Mock.new
    mock.expect :get_object, find_file_gapi(bucket_user_project.name, file_name),
      [bucket_user_project.name, file_name, generation: nil, user_project: "test", options: {}]

    bucket_user_project.service.mocked_service = mock

    file = bucket_user_project.file file_name

    mock.verify

    file.name.must_equal file_name
    file.user_project.must_equal true
    file.wont_be :lazy?
  end

  it "finds a file with skip_lookup" do
    file_name = "file.ext"

    mock = Minitest::Mock.new

    bucket.service.mocked_service = mock

    file = bucket.file file_name, skip_lookup: true

    mock.verify

    file.name.must_equal file_name
    file.generation.must_be :nil?
    file.user_project.must_be :nil?
    file.must_be :lazy?
  end

  it "finds a file with skip_lookup and find_file alias" do
    file_name = "file.ext"

    mock = Minitest::Mock.new

    bucket.service.mocked_service = mock

    file = bucket.find_file file_name, skip_lookup: true

    mock.verify

    file.name.must_equal file_name
    file.generation.must_be :nil?
    file.user_project.must_be :nil?
    file.must_be :lazy?
  end

  it "finds a file with generation and skip_lookup" do
    file_name = "file.ext"
    generation = 123

    mock = Minitest::Mock.new

    bucket.service.mocked_service = mock

    file = bucket.file file_name, generation: generation, skip_lookup: true

    mock.verify

    file.name.must_equal file_name
    file.generation.must_equal generation
    file.user_project.must_be :nil?
    file.must_be :lazy?
  end

  it "finds a file with user_project and skip_lookup set to true" do
    file_name = "file.ext"

    mock = Minitest::Mock.new

    bucket_user_project.service.mocked_service = mock

    file = bucket_user_project.file file_name, skip_lookup: true

    mock.verify

    file.name.must_equal file_name
    file.generation.must_be :nil?
    file.user_project.must_equal true
    file.must_be :lazy?
  end

  it "can reload itself" do
    bucket_name = "found-bucket"
    new_url_root = "https://www.googleapis.com/storage/v2"

    mock = Minitest::Mock.new
    mock.expect :get_bucket, Google::Apis::StorageV1::Bucket.from_json(random_bucket_hash(bucket_name).to_json),
      [bucket_name, {user_project: nil}]
    mock.expect :get_bucket, Google::Apis::StorageV1::Bucket.from_json(random_bucket_hash(bucket_name, new_url_root).to_json),
      [bucket_name, {user_project: nil}]

    bucket.service.mocked_service = mock

    bucket = storage.bucket bucket_name
    bucket.api_url.must_equal "https://www.googleapis.com/storage/v1/b/#{bucket_name}"

    bucket.reload!

    bucket.api_url.must_equal "#{new_url_root}/b/#{bucket_name}"
    mock.verify
  end

  it "can reload itself with user_project set to true" do
    bucket_name = "found-bucket"
    new_url_root = "https://www.googleapis.com/storage/v2"

    mock = Minitest::Mock.new
    mock.expect :get_bucket, Google::Apis::StorageV1::Bucket.from_json(random_bucket_hash(bucket_name).to_json),
      [bucket_name, {user_project: "test"}]
    mock.expect :get_bucket, Google::Apis::StorageV1::Bucket.from_json(random_bucket_hash(bucket_name, new_url_root).to_json),
      [bucket_name, {user_project: "test"}]

    bucket_user_project.service.mocked_service = mock

    bucket = storage.bucket bucket_name, user_project: true
    bucket.api_url.must_equal "https://www.googleapis.com/storage/v1/b/#{bucket_name}"

    bucket.reload!

    bucket.api_url.must_equal "#{new_url_root}/b/#{bucket_name}"
    mock.verify
  end

  def create_file_gapi bucket=nil, name = nil
    Google::Apis::StorageV1::Object.from_json random_file_hash(bucket, name).to_json
  end

  def empty_file_gapi cache_control: nil, content_disposition: nil,
                      content_encoding: nil, content_language: nil,
                      content_type: nil, crc32c: nil, md5: nil, metadata: nil,
                      storage_class: nil, temporary_hold: nil,
                      event_based_hold: nil
    Google::Apis::StorageV1::Object.new({
      cache_control: cache_control, content_type: content_type,
      content_disposition: content_disposition, md5_hash: md5,
      content_encoding: content_encoding, crc32c: crc32c,
      content_language: content_language, metadata: metadata,
      storage_class: storage_class, temporary_hold: temporary_hold,
      event_based_hold: event_based_hold }.delete_if { |_k, v| v.nil? })
  end

  def find_file_gapi bucket=nil, name = nil
    Google::Apis::StorageV1::Object.from_json random_file_hash(bucket, name).to_json
  end

  def list_files_gapi count = 2, token = nil, prefixes = nil
    files = count.times.map { Google::Apis::StorageV1::Object.from_json random_file_hash.to_json }
    Google::Apis::StorageV1::Objects.new kind: "storage#objects", items: files, next_page_token: token, prefixes: prefixes
  end
end
