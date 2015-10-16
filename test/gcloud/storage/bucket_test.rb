# Copyright 2014 Google Inc. All rights reserved.
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

describe Gcloud::Storage::Bucket, :mock_storage do
  # Create a bucket object with the project's mocked connection object
  let(:bucket_hash) { random_bucket_hash }
  let(:bucket) { Gcloud::Storage::Bucket.from_gapi bucket_hash, storage.connection }

  let(:bucket_name) { "new-bucket-#{Time.now.to_i}" }
  let(:bucket_url_root) { "https://www.googleapis.com/storage/v1" }
  let(:bucket_url) { "#{bucket_url_root}/b/#{bucket_name}" }
  let(:bucket_cors) { [{ "maxAgeSeconds" => 300,
                         "origin" => ["http://example.org", "https://example.org"],
                         "method" => ["*"],
                         "responseHeader" => ["X-My-Custom-Header"] }] }
  let(:bucket_location) { "US" }
  let(:bucket_logging_bucket) { "bucket-name-logging" }
  let(:bucket_logging_prefix) { "AccessLog" }
  let(:bucket_storage_class) { "STANDARD" }
  let(:bucket_versioning) { true }
  let(:bucket_website_main) { "index.html" }
  let(:bucket_website_404) { "404.html" }
  let(:bucket_hash_complete) { random_bucket_hash bucket_name, bucket_url_root,
                                                  bucket_location, bucket_storage_class, bucket_versioning,
                                                  bucket_logging_bucket, bucket_logging_prefix, bucket_website_main,
                                                  bucket_website_404, bucket_cors }
  let(:bucket_complete) { Gcloud::Storage::Bucket.from_gapi bucket_hash_complete, storage.connection }

  it "knows its attributes" do
    bucket_complete.id.must_equal bucket_hash_complete["id"]
    bucket_complete.name.must_equal bucket_name
    bucket_complete.created_at.must_equal bucket_hash_complete["timeCreated"]
    bucket_complete.url.must_equal bucket_url
    bucket_complete.location.must_equal bucket_location
    bucket_complete.logging_bucket.must_equal bucket_logging_bucket
    bucket_complete.logging_prefix.must_equal bucket_logging_prefix
    bucket_complete.storage_class.must_equal bucket_storage_class
    bucket_complete.versioning?.must_equal bucket_versioning
    bucket_complete.website_main.must_equal bucket_website_main
    bucket_complete.website_404.must_equal bucket_website_404
  end

  it "return frozen cors" do
    bucket_complete.cors.must_equal bucket_hash_complete["cors"]
    bucket_complete.cors.frozen?.must_equal true
    bucket_complete.cors.first.frozen?.must_equal true
  end

  it "can delete itself" do
    mock_connection.delete "/storage/v1/b/#{bucket.name}" do |env|
      [200, { "Content-Type" => "application/json" }, ""]
    end

    bucket.delete
  end

  it "creates a file" do
    new_file_name = random_file_path

    mock_connection.post "/upload/storage/v1/b/#{bucket.name}/o" do |env|
      env.params.wont_include "predefinedAcl"

      multipart_params = parse_multipart env
      multipart_params.first[:headers]["Content-Disposition"].must_equal "form-data; name=\"\"; filename=\"file.json\""
      multipart_params.first[:headers]["Content-Length"].must_equal "28"
      multipart_params.first[:headers]["Content-Type"].must_equal "application/json"
      multipart_params.first[:headers]["Content-Transfer-Encoding"].must_equal "binary"
      multipart_params.first[:body].must_equal "{\"contentType\":\"text/plain\"}"
      multipart_params.last[:headers]["Content-Disposition"].must_include "form-data; name=\"\"; filename=\"gcloud-ruby"
      multipart_params.last[:headers]["Content-Length"].must_equal "11"
      multipart_params.last[:headers]["Content-Type"].must_equal "text/plain"
      multipart_params.last[:headers]["Content-Transfer-Encoding"].must_equal "binary"
      multipart_params.last[:body].must_equal "Hello world"


      [200, { "Content-Type" => "application/json" },
       create_file_json(bucket.name, new_file_name)]
    end

    Tempfile.open ["gcloud-ruby", ".txt"] do |tmpfile|
      tmpfile.write "Hello world"
      tmpfile.rewind

      bucket.create_file tmpfile, new_file_name
    end
  end

  it "creates a file with upload_file alias" do
    new_file_name = random_file_path

    mock_connection.post "/upload/storage/v1/b/#{bucket.name}/o" do |env|
      env.params.wont_include "predefinedAcl"
      [200, { "Content-Type" => "application/json" },
       create_file_json(bucket.name, new_file_name)]
    end

    Tempfile.open "gcloud-ruby" do |tmpfile|
      bucket.upload_file tmpfile, new_file_name
    end
  end

  it "creates a file with new_file alias" do
    new_file_name = random_file_path

    mock_connection.post "/upload/storage/v1/b/#{bucket.name}/o" do |env|
      env.params.wont_include "predefinedAcl"
      [200, { "Content-Type" => "application/json" },
       create_file_json(bucket.name, new_file_name)]
    end

    Tempfile.open "gcloud-ruby" do |tmpfile|
      bucket.new_file tmpfile, new_file_name
    end
  end

  it "creates a file with predefined acl" do
    new_file_name = random_file_path

    mock_connection.post "/upload/storage/v1/b/#{bucket.name}/o" do |env|
      env.params.must_include "predefinedAcl"
      env.params["predefinedAcl"].must_equal "private"
      [200, { "Content-Type" => "application/json" },
       create_file_json(bucket.name, new_file_name)]
    end

    Tempfile.open "gcloud-ruby" do |tmpfile|
      bucket.create_file tmpfile, new_file_name, acl: "private"
    end
  end

  it "creates a file with predefined acl alias" do
    new_file_name = random_file_path

    mock_connection.post "/upload/storage/v1/b/#{bucket.name}/o" do |env|
      env.params.must_include "predefinedAcl"
      env.params["predefinedAcl"].must_equal "publicRead"
      [200, { "Content-Type" => "application/json" },
       create_file_json(bucket.name, new_file_name)]
    end

    Tempfile.open "gcloud-ruby" do |tmpfile|
      bucket.create_file tmpfile, new_file_name, acl: :public
    end
  end

  it "creates with resumable" do
    # Mock the upload
    mock_connection.post "/upload/storage/v1/b/#{bucket.name}/o" do |env|
      [200, { "Content-Type" => "application/json", Location: "/upload/resumable-uri" },
       create_file_json(bucket.name, "resumable.ext")]
    end

    Tempfile.open "gcloud-ruby" do |tmpfile|
      tmpfile.write "The quick brown fox jumps over the lazy dog."
      Gcloud::Upload.stub :resumable_threshold, tmpfile.size/2 do
        bucket.create_file tmpfile, "resumable.ext"
      end
    end
  end

  it "creates a file with md5" do
    new_file_name = random_file_path

    mock_connection.post "/upload/storage/v1/b/#{bucket.name}/o" do |env|
      multipart_params = parse_multipart env

      json = JSON.parse multipart_params.first[:body]
      json["md5Hash"].must_equal "HXB937GQDFxDFqUGi//weQ=="
      [200, { "Content-Type" => "application/json" },
       create_file_json(bucket.name, new_file_name)]
    end

    Tempfile.open "gcloud-ruby" do |tmpfile|
      bucket.create_file tmpfile, new_file_name, md5: "HXB937GQDFxDFqUGi//weQ=="
    end
  end

  it "creates a file with crc32c" do
    new_file_name = random_file_path

    mock_connection.post "/upload/storage/v1/b/#{bucket.name}/o" do |env|
      multipart_params = parse_multipart env
      json = JSON.parse multipart_params.first[:body]
      json["crc32c"].must_equal "Lm1F3g=="
      [200, { "Content-Type" => "application/json" },
       create_file_json(bucket.name, new_file_name)]
    end

    Tempfile.open "gcloud-ruby" do |tmpfile|
      bucket.create_file tmpfile, new_file_name, crc32c: "Lm1F3g=="
    end
  end

  it "creates a file with attributes" do
    new_file_name = random_file_path

    mock_connection.post "/upload/storage/v1/b/#{bucket.name}/o" do |env|
      multipart_params = parse_multipart env
      json = JSON.parse multipart_params.first[:body]
      json["cacheControl"].must_equal "public, max-age=3600"
      json["contentDisposition"].must_equal "attachment; filename=filename.ext"
      json["contentEncoding"].must_equal "gzip"
      json["contentLanguage"].must_equal "en"
      json["contentType"].must_equal "image/png"
      [200, { "Content-Type" => "application/json" },
       create_file_json(bucket.name, new_file_name)]
    end
    options = {
      cache_control: "public, max-age=3600",
      content_disposition: "attachment; filename=filename.ext",
      content_encoding: "gzip",
      content_language: "en",
      content_type: "image/png"
    }
    Tempfile.open "gcloud-ruby" do |tmpfile|
      bucket.create_file tmpfile, new_file_name, options
    end
  end

  it "does not error on an invalid chunk_size" do
    # Mock the upload
    valid_chunk_size = 256 * 1024 # 256KB
    invalid_chunk_size = valid_chunk_size + 1
    upload_request = false
    mock_connection.post "/upload/storage/v1/b/#{bucket.name}/o" do |env|
      if upload_request
        # The content length is sent on the second request
        env.request_headers["Content-length"].to_i.must_equal valid_chunk_size
      end
      upload_request = true
      [200, { "Content-Type" => "application/json", Location: "/upload/resumable-uri" },
       create_file_json(bucket.name, "resumable.ext")]
    end
    Tempfile.open "gcloud-ruby" do |tmpfile|
      10000.times do # write enough to be larger than the chunk_size
        tmpfile.write "The quick brown fox jumps over the lazy dog."
      end
      Gcloud::Upload.stub :resumable_threshold, tmpfile.size/2 do
        bucket.create_file tmpfile, "resumable.ext", chunk_size: invalid_chunk_size
      end
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
    mock_connection.get "/storage/v1/b/#{bucket.name}/o" do |env|
      [200, { "Content-Type" => "application/json" },
       list_files_json(num_files)]
    end

    files = bucket.files
    files.size.must_equal num_files
  end

  it "lists files with find_files alias" do
    num_files = 3
    mock_connection.get "/storage/v1/b/#{bucket.name}/o" do |env|
      [200, { "Content-Type" => "application/json" },
       list_files_json(num_files)]
    end

    files = bucket.find_files
    files.size.must_equal num_files
  end

  it "paginates files" do
    mock_connection.get "/storage/v1/b/#{bucket.name}/o" do |env|
      env.params.wont_include "pageToken"
      [200, { "Content-Type" => "application/json" },
       list_files_json(3, "next_page_token")]
    end
    mock_connection.get "/storage/v1/b/#{bucket.name}/o" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      [200, { "Content-Type" => "application/json" },
       list_files_json(2)]
    end

    first_files = bucket.files
    first_files.count.must_equal 3
    first_files.token.wont_be :nil?
    first_files.token.must_equal "next_page_token"

    second_files = bucket.files token: first_files.token
    second_files.count.must_equal 2
    second_files.token.must_be :nil?
  end

  it "paginates files with prefix set" do
    mock_connection.get "/storage/v1/b/#{bucket.name}/o" do |env|
      env.params.must_include "prefix"
      env.params["prefix"].must_equal "/prefix/"
      [200, { "Content-Type" => "application/json" },
       list_files_json(3, nil, ["/prefix/path1/", "/prefix/path2/"])]
    end

    files = bucket.files prefix: "/prefix/"
    files.count.must_equal 3
    files.prefixes.wont_be :empty?
    files.prefixes.must_include "/prefix/path1/"
    files.prefixes.must_include "/prefix/path2/"
  end

  it "paginates files without prefix set" do
    mock_connection.get "/storage/v1/b/#{bucket.name}/o" do |env|
      env.params.wont_include "prefix"
      [200, { "Content-Type" => "application/json" },
       list_files_json(3, nil, ["/prefix/path1/", "/prefix/path2/"])]
    end

    files = bucket.files
    files.count.must_equal 3
    files.prefixes.wont_be :empty?
    files.prefixes.must_include "/prefix/path1/"
    files.prefixes.must_include "/prefix/path2/"
  end

  it "paginates files with max set" do
    mock_connection.get "/storage/v1/b/#{bucket.name}/o" do |env|
      env.params.must_include "maxResults"
      env.params["maxResults"].must_equal "3"
      [200, { "Content-Type" => "application/json" },
       list_files_json(3, "next_page_token")]
    end

    files = bucket.files max: 3
    files.count.must_equal 3
    files.token.wont_be :nil?
    files.token.must_equal "next_page_token"
  end

  it "paginates files without max set" do
    mock_connection.get "/storage/v1/b/#{bucket.name}/o" do |env|
      env.params.wont_include "maxResults"
      [200, { "Content-Type" => "application/json" },
       list_files_json(3, "next_page_token")]
    end

    files = bucket.files
    files.count.must_equal 3
    files.token.wont_be :nil?
    files.token.must_equal "next_page_token"
  end

  it "paginates files with versions set" do
    mock_connection.get "/storage/v1/b/#{bucket.name}/o" do |env|
      env.params.must_include "versions"
      env.params["versions"].must_equal "true"
      [200, { "Content-Type" => "application/json" },
       list_files_json(8)]
    end

    files = bucket.files versions: true
    files.count.must_equal 8
  end

  it "paginates files without versions set" do
    mock_connection.get "/storage/v1/b/#{bucket.name}/o" do |env|
      env.params.wont_include "versions"
      [200, { "Content-Type" => "application/json" },
       list_files_json(3)]
    end

    files = bucket.files
    files.count.must_equal 3
  end

  it "finds a file without generation" do
    file_name = "file.ext"

    mock_connection.get "/storage/v1/b/#{bucket.name}/o/#{file_name}" do |env|
      URI(env.url).query.must_be :nil?
      [200, { "Content-Type" => "application/json" },
       find_file_json(bucket.name, file_name)]
    end

    file = bucket.file file_name
    file.name.must_equal file_name
  end

  it "finds a file with find_file alias" do
    file_name = "file.ext"

    mock_connection.get "/storage/v1/b/#{bucket.name}/o/#{file_name}" do |env|
      URI(env.url).query.must_be :nil?
      [200, { "Content-Type" => "application/json" },
       find_file_json(bucket.name, file_name)]
    end

    file = bucket.find_file file_name
    file.name.must_equal file_name
  end

  it "finds a file with generation" do
    file_name = "file.ext"
    generation = 123

    mock_connection.get "/storage/v1/b/#{bucket.name}/o/#{file_name}" do |env|
      URI(env.url).query.must_equal "generation=#{generation}"
      [200, { "Content-Type" => "application/json" },
       find_file_json(bucket.name, file_name)]
    end

    file = bucket.file file_name, generation: generation
    file.name.must_equal file_name
  end

  it "can reload itself" do
    bucket_name = "found-bucket"

    mock_connection.get "/storage/v1/b/#{bucket_name}" do |env|
      [200, { "Content-Type" => "application/json" },
       random_bucket_hash(bucket_name).to_json]
    end

    new_url_root = "https://www.googleapis.com/storage/v2"
    mock_connection.get "/storage/v1/b/#{bucket_name}" do |env|
      [200, { "Content-Type" => "application/json" },
       random_bucket_hash(bucket_name, new_url_root).to_json]
    end

    bucket = storage.bucket bucket_name
    bucket.url.must_equal "https://www.googleapis.com/storage/v1/b/#{bucket_name}"

    bucket.reload!

    # replace url with a legitimately mutable attribute when issue #91 is closed.
    bucket.url.must_equal "#{new_url_root}/b/#{bucket_name}"
  end

  def create_file_json bucket=nil, name = nil
    random_file_hash(bucket, name).to_json
  end

  def find_file_json bucket=nil, name = nil
    random_file_hash(bucket, name).to_json
  end

  def list_files_json count = 2, token = nil, prefixes = nil
    files = count.times.map { random_file_hash }
    hash = { "kind" => "storage#objects", "items" => files }
    hash["nextPageToken"] = token unless token.nil?
    hash["prefixes"] = prefixes unless prefixes.nil?
    hash.to_json
  end

  def parse_multipart multipart_env
    data = multipart_env.body.read(8000)
    # hardcoded boundry because I can't figure out how to ask the object
    # for the boundary, and its always the same...
    boundary = "-------------RubyApiMultipartPost"
    params = data.split(boundary).map(&:strip)
    params.pop # remove empty last element
    params.shift # remove empty first element
    params.map! do |p|
      raw = p.split "\r\n\r\n";
      headers = Hash[raw.first.split("\r\n").map {|h| h.split(": ")}]
      {headers: headers, body: raw.last}
    end
    params
  end
end
