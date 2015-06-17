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
  let(:bucket) { Gcloud::Storage::Bucket.from_gapi random_bucket_hash,
                                                   storage.connection }

  it "can delete itself" do
    mock_connection.delete "/storage/v1/b/#{bucket.name}" do |env|
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    bucket.delete
  end

  it "creates a file" do
    new_file_name = random_file_path

    mock_connection.post "/upload/storage/v1/b/#{bucket.name}/o" do |env|
      env.params.wont_include "predefinedAcl"
      [200, {"Content-Type"=>"application/json"},
       create_file_json(bucket.name, new_file_name)]
    end

    Tempfile.open "gcloud-ruby" do |tmpfile|
      bucket.create_file tmpfile, new_file_name
    end
  end

  it "creates a file with upload_file alias" do
    new_file_name = random_file_path

    mock_connection.post "/upload/storage/v1/b/#{bucket.name}/o" do |env|
      env.params.wont_include "predefinedAcl"
      [200, {"Content-Type"=>"application/json"},
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
      [200, {"Content-Type"=>"application/json"},
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
      [200, {"Content-Type"=>"application/json"},
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
      [200, {"Content-Type"=>"application/json"},
       create_file_json(bucket.name, new_file_name)]
    end

    Tempfile.open "gcloud-ruby" do |tmpfile|
      bucket.create_file tmpfile, new_file_name, acl: :public
    end
  end

  it "creates with resumable" do
    # Mock the upload
    mock_connection.post "/upload/storage/v1/b/#{bucket.name}/o" do |env|
      [200, {"Content-Type"=>"application/json", Location: "/upload/resumable-uri"},
       create_file_json(bucket.name, "resumable.ext")]
    end

    Tempfile.open "gcloud-ruby" do |tmpfile|
      tmpfile.write "The quick brown fox jumps over the lazy dog."
      Gcloud::Storage.stub :resumable_threshold, tmpfile.size/2 do
        bucket.create_file tmpfile, "resumable.ext"
      end
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
      [200, {"Content-Type"=>"application/json", Location: "/upload/resumable-uri"},
       create_file_json(bucket.name, "resumable.ext")]
    end
    Tempfile.open "gcloud-ruby" do |tmpfile|
      10000.times do # write enough to be larger than the chunk_size
        tmpfile.write "The quick brown fox jumps over the lazy dog."
      end
      Gcloud::Storage.stub :resumable_threshold, tmpfile.size/2 do
        bucket.create_file tmpfile, "resumable.ext", chunk_size: invalid_chunk_size
      end
    end
  end

  it "lists files" do
    num_files = 3
    mock_connection.get "/storage/v1/b/#{bucket.name}/o" do |env|
      [200, {"Content-Type"=>"application/json"},
       list_files_json(num_files)]
    end

    files = bucket.files
    files.size.must_equal num_files
  end

  it "paginates files" do
    mock_connection.get "/storage/v1/b/#{bucket.name}/o" do |env|
      env.params.wont_include "pageToken"
      [200, {"Content-Type"=>"application/json"},
       list_files_json(3, "next_page_token")]
    end
    mock_connection.get "/storage/v1/b/#{bucket.name}/o" do |env|
      env.params.must_include "pageToken"
      env.params["pageToken"].must_equal "next_page_token"
      [200, {"Content-Type"=>"application/json"},
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
      [200, {"Content-Type"=>"application/json"},
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
      [200, {"Content-Type"=>"application/json"},
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
      [200, {"Content-Type"=>"application/json"},
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
      [200, {"Content-Type"=>"application/json"},
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
      [200, {"Content-Type"=>"application/json"},
       list_files_json(8)]
    end

    files = bucket.files versions: true
    files.count.must_equal 8
  end

  it "paginates files without versions set" do
    mock_connection.get "/storage/v1/b/#{bucket.name}/o" do |env|
      env.params.wont_include "versions"
      [200, {"Content-Type"=>"application/json"},
       list_files_json(3)]
    end

    files = bucket.files
    files.count.must_equal 3
  end

  it "finds a file without generation" do
    file_name = "file.ext"

    mock_connection.get "/storage/v1/b/#{bucket.name}/o/#{file_name}" do |env|
      URI(env.url).query.must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       find_file_json(bucket.name, file_name)]
    end

    file = bucket.file file_name
    file.name.must_equal file_name
  end

  it "finds a file with find_file alias" do
    file_name = "file.ext"

    mock_connection.get "/storage/v1/b/#{bucket.name}/o/#{file_name}" do |env|
      URI(env.url).query.must_be :nil?
      [200, {"Content-Type"=>"application/json"},
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
      [200, {"Content-Type"=>"application/json"},
       find_file_json(bucket.name, file_name)]
    end

    file = bucket.file file_name, generation: generation
    file.name.must_equal file_name
  end

  def create_file_json bucket=nil, name = nil
    random_file_hash(bucket, name).to_json
  end

  def find_file_json bucket=nil, name = nil
    random_file_hash(bucket, name).to_json
  end

  def list_files_json count = 2, token = nil, prefixes = nil
    files = count.times.map { random_file_hash }
    hash = {"kind"=>"storage#objects", "items"=>files}
    hash["nextPageToken"] = token unless token.nil?
    hash["prefixes"] = prefixes unless prefixes.nil?
    hash.to_json
  end
end
