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

describe Gcloud::Storage::Bucket, :acl, :mock_storage do
  # Create a bucket object with the project's mocked connection object
  let(:bucket) { Gcloud::Storage::Bucket.from_gapi random_bucket_hash,
                                                   storage.connection }

  it "retrieves the ACL" do
    bucket_name = "found-bucket"

    mock_connection.get "/storage/v1/b/#{bucket_name}" do |env|
      [200, {"Content-Type"=>"application/json"},
       random_bucket_hash(bucket_name).to_json]
    end

    mock_connection.get "/storage/v1/b/#{bucket_name}/acl" do |env|
      [200, {"Content-Type"=>"application/json"},
       random_bucket_acl_hash(bucket_name).to_json]
    end

    bucket = storage.bucket bucket_name
    bucket.name.must_equal bucket_name
    bucket.acl.owners.wont_be  :empty?
    bucket.acl.writers.must_be :empty?
    bucket.acl.readers.wont_be :empty?
  end

  it "adds to the ACL" do
    bucket_name = "found-bucket"

    mock_connection.get "/storage/v1/b/#{bucket_name}" do |env|
      [200, {"Content-Type"=>"application/json"},
       random_bucket_hash(bucket_name).to_json]
    end

    mock_connection.get "/storage/v1/b/#{bucket_name}/acl" do |env|
      [200, {"Content-Type"=>"application/json"},
       random_bucket_acl_hash(bucket_name).to_json]
    end

    bucket = storage.bucket bucket_name
    bucket.name.must_equal bucket_name
    bucket.acl.owners.wont_be  :empty?
    bucket.acl.writers.must_be :empty?
    bucket.acl.readers.wont_be :empty?

    writer_entity = "user-user@example.net"
    writer_acl = {
       "kind" => "storage#bucketAccessControl",
       "id" => "#{bucket_name}-UUID/#{writer_entity}",
       "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}-UUID/acl/#{writer_entity}",
       "bucket" => "#{bucket_name}-UUID",
       "entity" => writer_entity,
       "email" => "user@example.net",
       "role" => "WRITER",
       "etag" => "CAE="
      }

    mock_connection.post "/storage/v1/b/#{bucket_name}/acl" do |env|
      [200, {"Content-Type"=>"application/json"},
       writer_acl.to_json]
    end

    bucket.acl.add_writer writer_entity
    bucket.acl.owners.wont_be  :empty?
    bucket.acl.writers.wont_be :empty?
    bucket.acl.readers.wont_be :empty?
    bucket.acl.writers.must_include writer_entity
  end

  it "removes from the ACL" do
    bucket_name = "found-bucket"

    mock_connection.get "/storage/v1/b/#{bucket_name}" do |env|
      [200, {"Content-Type"=>"application/json"},
       random_bucket_hash(bucket_name).to_json]
    end

    mock_connection.get "/storage/v1/b/#{bucket_name}/acl" do |env|
      [200, {"Content-Type"=>"application/json"},
       random_bucket_acl_hash(bucket_name).to_json]
    end

    bucket = storage.bucket bucket_name
    bucket.name.must_equal bucket_name
    bucket.acl.owners.wont_be  :empty?
    bucket.acl.writers.must_be :empty?
    bucket.acl.readers.wont_be :empty?

    reader_entity = bucket.acl.readers.first

    mock_connection.delete "/storage/v1/b/#{bucket_name}/acl/#{reader_entity}" do |env|
      [200, {"Content-Type"=>"application/json"}, ""]
    end

    bucket.acl.delete reader_entity

    bucket.acl.owners.wont_be  :empty?
    bucket.acl.writers.must_be :empty?
    bucket.acl.readers.must_be :empty?
  end

  it "sets the predefined ACL rule authenticatedRead" do
    predefined_acl_update "authenticatedRead" do |acl|
      acl.authenticatedRead!
    end
  end

  it "sets the predefined ACL rule auth" do
    predefined_acl_update "authenticatedRead" do |acl|
      acl.auth!
    end
  end

  it "sets the predefined ACL rule auth_read" do
    predefined_acl_update "authenticatedRead" do |acl|
      acl.auth_read!
    end
  end

  it "sets the predefined ACL rule authenticated" do
    predefined_acl_update "authenticatedRead" do |acl|
      acl.authenticated!
    end
  end

  it "sets the predefined ACL rule authenticated_read" do
    predefined_acl_update "authenticatedRead" do |acl|
      acl.authenticated_read!
    end
  end

  it "sets the predefined ACL rule private" do
    predefined_acl_update "private" do |acl|
      acl.private!
    end
  end

  it "sets the predefined ACL rule projectPrivate" do
    predefined_acl_update "projectPrivate" do |acl|
      acl.projectPrivate!
    end
  end

  it "sets the predefined ACL rule project_private" do
    predefined_acl_update "projectPrivate" do |acl|
      acl.project_private!
    end
  end

  it "sets the predefined ACL rule publicRead" do
    predefined_acl_update "publicRead" do |acl|
      acl.publicRead!
    end
  end

  it "sets the predefined ACL rule public" do
    predefined_acl_update "publicRead" do |acl|
      acl.public!
    end
  end

  it "sets the predefined ACL rule public_read" do
    predefined_acl_update "publicRead" do |acl|
      acl.public_read!
    end
  end

  it "sets the predefined ACL rule publicReadWrite" do
    predefined_acl_update "publicReadWrite" do |acl|
      acl.publicReadWrite!
    end
  end

  it "sets the predefined ACL rule public_write" do
    predefined_acl_update "publicReadWrite" do |acl|
      acl.public_write!
    end
  end

  def predefined_acl_update acl_role
    mock_connection.patch "/storage/v1/b/#{bucket.name}" do |env|
      env.params["predefinedAcl"].must_equal acl_role
      [200, {"Content-Type"=>"application/json"},
       random_bucket_hash(bucket.name).to_json]
    end

    yield bucket.acl
  end

  def random_bucket_acl_hash bucket_name
    {
     "kind" => "storage#bucketAccessControls",
     "items" => [
      {
       "kind" => "storage#bucketAccessControl",
       "id" => "#{bucket_name}-UUID/project-owners-1234567890",
       "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}-UUID/acl/project-owners-1234567890",
       "bucket" => "#{bucket_name}-UUID",
       "entity" => "project-owners-1234567890",
       "role" => "OWNER",
       "projectTeam" => {
        "projectNumber" => "1234567890",
        "team" => "owners"
       },
       "etag" => "CAE="
      },
      {
       "kind" => "storage#bucketAccessControl",
       "id" => "#{bucket_name}-UUID/project-editors-1234567890",
       "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}-UUID/acl/project-editors-1234567890",
       "bucket" => "#{bucket_name}-UUID",
       "entity" => "project-editors-1234567890",
       "role" => "OWNER",
       "projectTeam" => {
        "projectNumber" => "1234567890",
        "team" => "editors"
       },
       "etag" => "CAE="
      },
      {
       "kind" => "storage#bucketAccessControl",
       "id" => "#{bucket_name}-UUID/project-viewers-1234567890",
       "selfLink" => "https://www.googleapis.com/storage/v1/b/#{bucket_name}-UUID/acl/project-viewers-1234567890",
       "bucket" => "#{bucket_name}-UUID",
       "entity" => "project-viewers-1234567890",
       "role" => "READER",
       "projectTeam" => {
        "projectNumber" => "1234567890",
        "team" => "viewers"
       },
       "etag" => "CAE="
      }
     ]
    }
  end
end
