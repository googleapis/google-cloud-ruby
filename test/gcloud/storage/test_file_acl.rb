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

describe Gcloud::Storage::File, :acl, :mock_storage do
  # Create a bucket object with the project's mocked connection object
  let(:bucket_name) { "bucket" }
  let(:bucket) { Gcloud::Storage::Bucket.from_gapi random_bucket_hash(bucket_name),
                                                   storage.connection }

  # Create a file object with the project's mocked connection object
  let(:file_name) { "file.ext" }
  let(:file) { Gcloud::Storage::File.from_gapi random_file_hash(bucket_name, file_name),
                                               storage.connection }

  it "retrieves the ACL" do
    mock_connection.get "/storage/v1/b/#{bucket_name}/o/#{file_name}" do |env|
      URI(env.url).query.must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       random_file_hash(bucket_name, file_name).to_json]
    end

    mock_connection.get "/storage/v1/b/#{bucket_name}/o/#{file_name}/acl" do |env|
      [200, {"Content-Type"=>"application/json"},
       random_file_acl_hash(bucket_name, file_name).to_json]
    end

    file = bucket.find_file file_name
    file.name.must_equal file_name
    file.acl.owners.wont_be  :empty?
    file.acl.writers.must_be :empty?
    file.acl.readers.wont_be :empty?
  end

  it "adds to the ACL" do
    mock_connection.get "/storage/v1/b/#{bucket_name}/o/#{file_name}" do |env|
      URI(env.url).query.must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       random_file_hash(bucket_name, file_name).to_json]
    end

    mock_connection.get "/storage/v1/b/#{bucket_name}/o/#{file_name}/acl" do |env|
      [200, {"Content-Type"=>"application/json"},
       random_file_acl_hash(bucket_name, file_name).to_json]
    end

    file = bucket.find_file file_name
    file.name.must_equal file_name
    file.acl.owners.wont_be  :empty?
    file.acl.writers.must_be :empty?
    file.acl.readers.wont_be :empty?

    writer_entity = "user-user@example.net"
    writer_acl = {
       "kind" => "storage#objectAccessControl",
       "id" => "#{bucket_name}/#{file_name}/123/user-12345678901234567890",
       "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}/o/#{file_name}/acl/#{writer_entity}",
       "bucket" => "#{bucket_name}",
       "object" => "#{file_name}",
       "generation" => "123",
       "entity" => writer_entity,
       "role" => "WRITER",
       "entityId" => "12345678901234567890",
       "etag" => "abcDEF123="
      }

    mock_connection.post "/storage/v1/b/#{bucket_name}/o/#{file_name}/acl" do |env|
      [200, {"Content-Type"=>"application/json"},
       writer_acl.to_json]
    end

    file.acl.add_writer writer_entity
    file.acl.owners.wont_be  :empty?
    file.acl.writers.wont_be :empty?
    file.acl.readers.wont_be :empty?
    file.acl.writers.must_include writer_entity
  end

  it "removes from the ACL" do
    mock_connection.get "/storage/v1/b/#{bucket_name}/o/#{file_name}" do |env|
      URI(env.url).query.must_be :nil?
      [200, {"Content-Type"=>"application/json"},
       random_file_hash(bucket_name, file_name).to_json]
    end

    mock_connection.get "/storage/v1/b/#{bucket_name}/o/#{file_name}/acl" do |env|
      [200, {"Content-Type"=>"application/json"},
       random_file_acl_hash(bucket_name, file_name).to_json]
    end

    file = bucket.find_file file_name
    file.name.must_equal file_name
    file.acl.owners.wont_be  :empty?
    file.acl.writers.must_be :empty?
    file.acl.readers.wont_be :empty?

    reader_entity = file.acl.readers.first

    mock_connection.delete "/storage/v1/b/#{bucket_name}/o/#{file_name}/acl/#{reader_entity}" do |env|
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    file.acl.delete reader_entity

    file.acl.owners.wont_be  :empty?
    file.acl.writers.must_be :empty?
    file.acl.readers.must_be :empty?
  end

  def random_file_acl_hash bucket_name, file_name
    {
     "kind" => "storage#objectAccessControls",
     "items" => [
      {
       "kind" => "storage#objectAccessControl",
       "id" => "#{bucket_name}/#{file_name}/123/project-owners-1234567890",
       "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}/o/#{file_name}/acl/project-owners-1234567890",
       "bucket" => "#{bucket_name}",
       "object" => "#{file_name}",
       "generation" => "123",
       "entity" => "project-owners-1234567890",
       "role" => "OWNER",
       "projectTeam" => {
        "projectNumber" => "1234567890",
        "team" => "owners"
       },
       "etag" => "abcDEF123="
      },
      {
       "kind" => "storage#objectAccessControl",
       "id" => "#{bucket_name}/#{file_name}/123/project-editors-1234567890",
       "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}/o/#{file_name}/acl/project-editors-1234567890",
       "bucket" => "#{bucket_name}",
       "object" => "#{file_name}",
       "generation" => "123",
       "entity" => "project-editors-1234567890",
       "role" => "OWNER",
       "projectTeam" => {
        "projectNumber" => "1234567890",
        "team" => "editors"
       },
       "etag" => "abcDEF123="
      },
      {
       "kind" => "storage#objectAccessControl",
       "id" => "#{bucket_name}/#{file_name}/123/project-viewers-1234567890",
       "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}/o/#{file_name}/acl/project-viewers-1234567890",
       "bucket" => "#{bucket_name}",
       "object" => "#{file_name}",
       "generation" => "123",
       "entity" => "project-viewers-1234567890",
       "role" => "READER",
       "projectTeam" => {
        "projectNumber" => "1234567890",
        "team" => "viewers"
       },
       "etag" => "abcDEF123="
      },
      {
       "kind" => "storage#objectAccessControl",
       "id" => "#{bucket_name}/#{file_name}/123/user-12345678901234567890",
       "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}/o/#{file_name}/acl/user-12345678901234567890",
       "bucket" => "#{bucket_name}",
       "object" => "#{file_name}",
       "generation" => "123",
       "entity" => "user-12345678901234567890",
       "role" => "OWNER",
       "entityId" => "12345678901234567890",
       "etag" => "abcDEF123="
      }
     ]
    }
  end
end
